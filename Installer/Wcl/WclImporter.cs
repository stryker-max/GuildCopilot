using System.Globalization;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace GuildCopilot.Installer.Wcl;

public sealed record ImportResult(string Text, int Profiles, int Sessions, int Reports, IReadOnlyList<string> Warnings);

/// <summary>
/// Liest oeffentliche Warcraft-Logs-Reports ueber die offizielle GraphQL-API v2
/// und erzeugt den Importcode fuer das Addon.
///
/// Zwei Dinge sind an dieser API leicht zu uebersehen und haben den Import
/// frueher zuverlaessig scheitern lassen:
///   1. "playerDetails" und "table" brauchen ein echtes Zeitfenster. Sind
///      startTime und endTime beide 0, antwortet die API mit einem Fehler
///      statt mit leeren Daten.
///   2. Die JSON-Form der "table"-Antworten haengt am Datentyp. Deshalb wird
///      hier ueber "events" aggregiert: dort steht je Ereignis eine
///      Akteurs-ID und eine Spell-ID, das ist unabhaengig von der Tabellenform.
/// </summary>
public sealed class WclImporter
{
    public const string FormatHeader = "GCPWCL3";

    private static readonly Dictionary<string, string> ClassKeys = new(StringComparer.OrdinalIgnoreCase)
    {
        ["warrior"] = "WARRIOR", ["paladin"] = "PALADIN", ["hunter"] = "HUNTER",
        ["rogue"] = "ROGUE", ["priest"] = "PRIEST", ["shaman"] = "SHAMAN",
        ["mage"] = "MAGE", ["warlock"] = "WARLOCK", ["druid"] = "DRUID",
    };

    private static readonly Dictionary<string, string> SpecKeys = new(StringComparer.OrdinalIgnoreCase)
    {
        ["warrior:arms"] = "WARRIOR:1", ["warrior:fury"] = "WARRIOR:2", ["warrior:protection"] = "WARRIOR:3",
        ["paladin:holy"] = "PALADIN:1", ["paladin:protection"] = "PALADIN:2", ["paladin:retribution"] = "PALADIN:3",
        ["hunter:beastmastery"] = "HUNTER:1", ["hunter:marksmanship"] = "HUNTER:2", ["hunter:survival"] = "HUNTER:3",
        ["rogue:assassination"] = "ROGUE:1", ["rogue:combat"] = "ROGUE:2", ["rogue:subtlety"] = "ROGUE:3",
        ["priest:discipline"] = "PRIEST:1", ["priest:holy"] = "PRIEST:2", ["priest:shadow"] = "PRIEST:3",
        ["shaman:elemental"] = "SHAMAN:1", ["shaman:enhancement"] = "SHAMAN:2", ["shaman:restoration"] = "SHAMAN:3",
        ["mage:arcane"] = "MAGE:1", ["mage:fire"] = "MAGE:2", ["mage:frost"] = "MAGE:3",
        ["warlock:affliction"] = "WARLOCK:1", ["warlock:demonology"] = "WARLOCK:2", ["warlock:destruction"] = "WARLOCK:3",
        ["druid:balance"] = "DRUID:1", ["druid:feral"] = "DRUID:2", ["druid:guardian"] = "DRUID:2",
        ["druid:restoration"] = "DRUID:3",
    };

    private static readonly HttpClient Http = CreateHttpClient();
    private readonly IProgress<string> _log;
    private string _token = string.Empty;
    private string _origin = string.Empty;

    public WclImporter(IProgress<string> log)
    {
        _log = log;
    }

    private static HttpClient CreateHttpClient()
    {
        var client = new HttpClient { Timeout = TimeSpan.FromMinutes(3) };
        client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("GuildCopilot-Installer", "1.0"));
        return client;
    }

    public async Task<ImportResult> RunAsync(
        string clientId, string clientSecret, string link, int reportLimit, CancellationToken token)
    {
        var target = WclTarget.Parse(link);
        reportLimit = Math.Clamp(reportLimit, 1, 12);

        _log.Report("Schritt 1: Anmeldung");
        _token = await GetAccessTokenAsync(clientId, clientSecret, token);
        _log.Report("  Zugriffstoken erhalten.");

        _log.Report("Schritt 2: Reports suchen");
        var reports = await ResolveReportsAsync(target, reportLimit, token);

        var players = new Dictionary<string, PlayerProfile>(StringComparer.OrdinalIgnoreCase);
        var sessionBlocks = new List<List<string>>();
        var warnings = new List<string>();

        var selected = reports.Take(reportLimit).ToList();
        for (var index = 0; index < selected.Count; index++)
        {
            token.ThrowIfCancellationRequested();
            var code = selected[index];
            _log.Report($"Schritt 3.{index + 1}: Report {code}");

            var detail = await QueryAsync("report", MetaQuery, new { code }, token);
            var report = detail.GetProperty("reportData").GetProperty("report");
            if (report.ValueKind != JsonValueKind.Object)
            {
                warnings.Add($"Report {code} ließ sich nicht laden.");
                continue;
            }

            var startTime = GetDouble(report, "startTime");
            var endTime = GetDouble(report, "endTime");
            var duration = Math.Max(1, endTime - startTime);

            var fights = report.TryGetProperty("fights", out var fightList) && fightList.ValueKind == JsonValueKind.Array
                ? fightList.EnumerateArray().ToList()
                : new List<JsonElement>();
            var actors = BuildActorIndex(report);

            // masterData fuehrt jeden Akteur, den das Log je gesehen hat - auch
            // Umstehende und Trash. Ausgewertet wird nur, wer in einem Encounter
            // steht; deshalb werden beide Zahlen getrennt genannt.
            var participants = new HashSet<int>();
            foreach (var fight in fights)
            {
                foreach (var actorId in EnumerateFriendlyPlayers(fight)) participants.Add(actorId);
            }
            _log.Report($"  {fights.Count} Encounter-Kämpfe, {participants.Count} Teilnehmer ({actors.Count} Akteure im Log).");

            try
            {
                var details = await QueryAsync("playerDetails", DetailsQuery,
                    new { code, start = 0.0, end = duration }, token);
                var before = players.Count;
                CollectPlayers(details.GetProperty("reportData").GetProperty("report")
                    .GetProperty("playerDetails"), endTime, players);
                _log.Report($"  Profile: {players.Count - before} neu, {players.Count} gesamt.");
            }
            catch (Exception error)
            {
                warnings.Add($"Report {code} ohne Profile: {error.Message}");
            }

            if (fights.Count == 0)
            {
                warnings.Add($"Report {code} hat keine Encounter-Kämpfe.");
                continue;
            }

            // Jede Ereignisart wird einzeln abgesichert. Vorher riss eine einzige
            // fehlgeschlagene Abfrage die komplette Auswertung mit - aus einem
            // fehlenden Feld wurde so ein vollstaendiger Datenverlust.
            //
            // Bewusst ueber den ganzen Report statt nur ueber die Bosskaempfe:
            // wiederbelebt wird fast immer zwischen den Pulls, dispelt und
            // unterbrochen wird auch auf Trash, und getrunken wird vor dem Pull.
            var consumableFilter = "ability.id in (" + string.Join(", ", SpellIds.Consumables) + ")";
            var resurrectFilter = "ability.id in (" + string.Join(", ", SpellIds.Resurrects) + ")";
            var requests = new (string Key, string DataType, string? Filter)[]
            {
                ("deaths", "Deaths", null),
                ("resurrects", "Casts", resurrectFilter),
                ("interrupts", "Interrupts", null),
                ("dispels", "Dispels", null),
                ("casts", "Casts", consumableFilter),
                ("buffs", "Buffs", consumableFilter),
            };

            var events = new Dictionary<string, List<JsonElement>>();
            var failed = new List<string>();
            foreach (var (key, dataType, filter) in requests)
            {
                try
                {
                    events[key] = await FetchEventsAsync(code, dataType, duration, filter, token);
                }
                catch (Exception error)
                {
                    events[key] = new List<JsonElement>();
                    failed.Add(key);
                    warnings.Add($"Report {code}, {key}: {error.Message}");
                }
            }

            var lines = BuildSessionLines(code, report, actors, fights, events);
            if (lines.Count > 1)
            {
                sessionBlocks.Add(lines);
                var missing = failed.Count > 0 ? ", ohne " + string.Join("/", failed) : string.Empty;
                _log.Report($"  Auswertung: {lines.Count - 1} Teilnehmer, {events["deaths"].Count} Tode{missing}.");
            }
            else
            {
                warnings.Add($"Report {code} enthielt keine auswertbaren Teilnehmer.");
            }
        }

        var profileLines = BuildProfileLines(players);
        if (profileLines.Count == 0 && sessionBlocks.Count == 0)
        {
            var detail = warnings.Count > 0 ? "\n  " + string.Join("\n  ", warnings) : string.Empty;
            throw new InvalidOperationException("In den Reports konnten weder Spieler noch Raiddaten erkannt werden." + detail);
        }

        var output = new StringBuilder();
        output.Append(FormatHeader).Append('|').Append(selected.Count).Append('\n');
        foreach (var line in profileLines) output.Append(line).Append('\n');
        foreach (var block in sessionBlocks)
        {
            foreach (var line in block) output.Append(line).Append('\n');
        }

        return new ImportResult(output.ToString(), profileLines.Count, sessionBlocks.Count, selected.Count, warnings);
    }

    // ---------------------------------------------------------------------
    // Auswertung
    // ---------------------------------------------------------------------

    private sealed class PlayerProfile
    {
        public string Name = string.Empty;
        public string ClassFile = string.Empty;
        public readonly Dictionary<string, double> Specs = new(StringComparer.Ordinal);
    }

    private sealed record Actor(string Name, string ClassFile);

    private static string Sanitize(string? value) =>
        new((value ?? string.Empty).Where(c => c is not ('|' or ';' or ',' or '\r' or '\n')).ToArray());

    private static string Normalize(string? value) =>
        new((value ?? string.Empty).ToLowerInvariant().Where(char.IsAsciiLetterLower).ToArray());

    private static double GetDouble(JsonElement element, string name) =>
        element.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.Number
            ? value.GetDouble()
            : 0;

    private static IEnumerable<int> EnumerateFriendlyPlayers(JsonElement fight)
    {
        if (!fight.TryGetProperty("friendlyPlayers", out var list) || list.ValueKind != JsonValueKind.Array)
        {
            yield break;
        }
        foreach (var entry in list.EnumerateArray())
        {
            if (entry.ValueKind == JsonValueKind.Number) yield return entry.GetInt32();
        }
    }

    private static Dictionary<int, Actor> BuildActorIndex(JsonElement report)
    {
        var actors = new Dictionary<int, Actor>();
        if (!report.TryGetProperty("masterData", out var master)
            || !master.TryGetProperty("actors", out var list)
            || list.ValueKind != JsonValueKind.Array)
        {
            return actors;
        }
        foreach (var actor in list.EnumerateArray())
        {
            if (!actor.TryGetProperty("id", out var id) || id.ValueKind != JsonValueKind.Number) continue;
            var name = actor.TryGetProperty("name", out var nameValue) ? nameValue.GetString() : null;
            if (name is null) continue;
            var subType = actor.TryGetProperty("subType", out var sub) ? sub.GetString() : null;
            ClassKeys.TryGetValue(Normalize(subType), out var classFile);
            actors[id.GetInt32()] = new Actor(Sanitize(name), classFile ?? string.Empty);
        }
        return actors;
    }

    private static void CollectPlayers(JsonElement root, double reportTime, Dictionary<string, PlayerProfile> players)
    {
        // playerDetails liefert je Report unterschiedlich verschachtelte Objekte
        // (tanks/healers/dps, teils noch eine Ebene "data" darueber). Statt auf
        // eine feste Form zu setzen wird der Baum durchsucht.
        void Visit(JsonElement element)
        {
            switch (element.ValueKind)
            {
                case JsonValueKind.Array:
                    foreach (var item in element.EnumerateArray()) Visit(item);
                    return;
                case JsonValueKind.Object:
                    break;
                default:
                    return;
            }

            var classFile = ClassFromObject(element);
            var name = element.TryGetProperty("name", out var nameValue) ? nameValue.GetString() : null;
            if (classFile is not null && name is not null)
            {
                var specs = CollectSpecNames(element)
                    .Select(spec => SpecKeys.TryGetValue($"{classFile.ToLowerInvariant()}:{Normalize(spec)}", out var key) ? key : null)
                    .Where(key => key is not null)
                    .Select(key => key!)
                    .ToList();
                if (specs.Count > 0)
                {
                    var safeName = Sanitize(name);
                    if (!players.TryGetValue(safeName, out var player))
                    {
                        player = new PlayerProfile { Name = safeName, ClassFile = classFile };
                        players[safeName] = player;
                    }
                    foreach (var spec in specs)
                    {
                        player.Specs[spec] = Math.Max(player.Specs.GetValueOrDefault(spec), reportTime);
                    }
                }
            }

            foreach (var property in element.EnumerateObject()) Visit(property.Value);
        }

        Visit(root);
    }

    private static string? ClassFromObject(JsonElement element)
    {
        foreach (var field in new[] { "type", "class", "className", "subType" })
        {
            if (element.TryGetProperty(field, out var value) && value.ValueKind == JsonValueKind.String
                && ClassKeys.TryGetValue(Normalize(value.GetString()), out var classFile))
            {
                return classFile;
            }
        }
        if (element.TryGetProperty("icon", out var icon) && icon.ValueKind == JsonValueKind.String)
        {
            var head = (icon.GetString() ?? string.Empty).Split('-')[0];
            if (ClassKeys.TryGetValue(Normalize(head), out var fromIcon)) return fromIcon;
        }
        return null;
    }

    private static List<string> CollectSpecNames(JsonElement element)
    {
        var names = new List<string>();
        foreach (var field in new[] { "spec", "specName", "specialization" })
        {
            if (element.TryGetProperty(field, out var value) && value.ValueKind == JsonValueKind.String)
            {
                names.Add(value.GetString()!);
            }
        }
        if (element.TryGetProperty("specs", out var specs) && specs.ValueKind == JsonValueKind.Array)
        {
            foreach (var spec in specs.EnumerateArray())
            {
                if (spec.ValueKind == JsonValueKind.String)
                {
                    names.Add(spec.GetString()!);
                }
                else if (spec.ValueKind == JsonValueKind.Object)
                {
                    foreach (var field in new[] { "spec", "name", "specialization" })
                    {
                        if (spec.TryGetProperty(field, out var value) && value.ValueKind == JsonValueKind.String)
                        {
                            names.Add(value.GetString()!);
                        }
                    }
                }
            }
        }
        if (element.TryGetProperty("icon", out var icon) && icon.ValueKind == JsonValueKind.String)
        {
            var parts = (icon.GetString() ?? string.Empty).Split('-');
            if (parts.Length > 1) names.Add(string.Concat(parts.Skip(1)));
        }
        return names;
    }

    private static Dictionary<int, int> CountByActor(IEnumerable<JsonElement> events, string field, string type)
    {
        var counts = new Dictionary<int, int>();
        foreach (var element in events)
        {
            if (!element.TryGetProperty("type", out var kind) || kind.GetString() != type) continue;
            if (!element.TryGetProperty(field, out var actor) || actor.ValueKind != JsonValueKind.Number) continue;
            var id = actor.GetInt32();
            counts[id] = counts.GetValueOrDefault(id) + 1;
        }
        return counts;
    }

    private static Dictionary<int, int> CountCastsOfSpells(IEnumerable<JsonElement> events, HashSet<int> allowed)
    {
        var counts = new Dictionary<int, int>();
        foreach (var element in events)
        {
            if (!element.TryGetProperty("type", out var kind) || kind.GetString() != "cast") continue;
            if (!element.TryGetProperty("abilityGameID", out var ability) || ability.ValueKind != JsonValueKind.Number) continue;
            if (!allowed.Contains(ability.GetInt32())) continue;
            if (!element.TryGetProperty("sourceID", out var source) || source.ValueKind != JsonValueKind.Number) continue;
            var id = source.GetInt32();
            counts[id] = counts.GetValueOrDefault(id) + 1;
        }
        return counts;
    }

    /// <summary>
    /// Verbrauchsgegenstaende tauchen je nach Gegenstand als Zauber (Traenke,
    /// Runen, Trommeln) oder nur als Buff (Elixiere, Flaeschchen, Essen, Oele)
    /// auf. Entscheidend ist die Richtung: Ein Zauber nennt den Verursacher,
    /// ein Buff nur den Beschenkten. Trommeln buffen die ganze Gruppe - wer den
    /// Buff bekommt, hat deshalb noch lange nichts verbraucht.
    ///
    /// Die Regel lautet je Spell-ID: Gibt es ueberhaupt Zauber dazu, ist der
    /// Zauber massgeblich und der Buff wird ignoriert. Nur wenn ein Gegenstand
    /// gar keinen Zauber erzeugt, wird der Buff beim Ziel gezaehlt.
    /// </summary>
    private static Dictionary<int, Dictionary<int, int>> CollectConsumables(
        IEnumerable<JsonElement> castEvents, IEnumerable<JsonElement> buffEvents)
    {
        var castsByActor = new Dictionary<int, Dictionary<int, int>>();
        var buffsByActor = new Dictionary<int, Dictionary<int, int>>();
        var abilitiesWithCasts = new HashSet<int>();

        void Tally(IEnumerable<JsonElement> events, string field, HashSet<string> types,
            Dictionary<int, Dictionary<int, int>> target, bool markCasts)
        {
            foreach (var element in events)
            {
                if (!element.TryGetProperty("type", out var kind) || !types.Contains(kind.GetString() ?? "")) continue;
                if (!element.TryGetProperty("abilityGameID", out var ability) || ability.ValueKind != JsonValueKind.Number) continue;
                var abilityId = ability.GetInt32();
                if (!SpellIds.ConsumableSet.Contains(abilityId)) continue;
                if (!element.TryGetProperty(field, out var actor) || actor.ValueKind != JsonValueKind.Number) continue;

                var actorId = actor.GetInt32();
                if (!target.TryGetValue(actorId, out var counts))
                {
                    counts = new Dictionary<int, int>();
                    target[actorId] = counts;
                }
                counts[abilityId] = counts.GetValueOrDefault(abilityId) + 1;
                if (markCasts) abilitiesWithCasts.Add(abilityId);
            }
        }

        Tally(castEvents, "sourceID", new HashSet<string> { "cast" }, castsByActor, markCasts: true);
        // "refreshbuff" gehoert dazu: Wer nach einem Wipe dasselbe Gericht noch
        // einmal isst, waehrend der Buff laeuft, erzeugt eine Auffrischung statt
        // einer neuen Anwendung. Ohne sie zaehlte ein ganzer Raidabend Essen als
        // ein einziges Essen.
        Tally(buffEvents, "targetID", new HashSet<string> { "applybuff", "refreshbuff" }, buffsByActor, markCasts: false);

        var merged = new Dictionary<int, Dictionary<int, int>>();
        foreach (var (actorId, counts) in castsByActor)
        {
            merged[actorId] = new Dictionary<int, int>(counts);
        }
        foreach (var (actorId, counts) in buffsByActor)
        {
            foreach (var (abilityId, amount) in counts)
            {
                if (abilitiesWithCasts.Contains(abilityId)) continue;
                if (!merged.TryGetValue(actorId, out var flat))
                {
                    flat = new Dictionary<int, int>();
                    merged[actorId] = flat;
                }
                flat[abilityId] = Math.Max(flat.GetValueOrDefault(abilityId), amount);
            }
        }
        return merged;
    }

    /// <summary>
    /// Spielt eine aufgezeichnete API-Antwort durch die Auswertung, ohne Netz
    /// und ohne Zugangsdaten. Damit laesst sich belegen, dass diese Fassung
    /// dieselben Zeilen erzeugt wie die zuvor gegen echte Reports gepruefte.
    /// </summary>
    internal static List<string> ReplayRecorded(JsonElement report, Dictionary<string, List<JsonElement>> events)
    {
        var actors = BuildActorIndex(report);
        var fights = report.TryGetProperty("fights", out var list) && list.ValueKind == JsonValueKind.Array
            ? list.EnumerateArray().ToList()
            : new List<JsonElement>();
        var code = report.TryGetProperty("code", out var value) ? value.GetString() ?? string.Empty : string.Empty;
        return BuildSessionLines(code, report, actors, fights, events);
    }

    private static List<string> BuildSessionLines(
        string code, JsonElement report, Dictionary<int, Actor> actors,
        List<JsonElement> fights, Dictionary<string, List<JsonElement>> events)
    {
        var seconds = new Dictionary<int, double>();
        var kills = 0;
        var wipes = 0;
        foreach (var fight in fights)
        {
            if (fight.TryGetProperty("kill", out var kill) && kill.ValueKind == JsonValueKind.True) kills++;
            else if (kill.ValueKind == JsonValueKind.False) wipes++;

            var duration = Math.Max(0, GetDouble(fight, "endTime") - GetDouble(fight, "startTime")) / 1000.0;
            foreach (var actorId in EnumerateFriendlyPlayers(fight))
            {
                if (!actors.ContainsKey(actorId)) continue;
                seconds[actorId] = seconds.GetValueOrDefault(actorId) + duration;
            }
        }

        var deaths = CountByActor(events["deaths"], "targetID", "death");
        var resurrects = CountCastsOfSpells(events["resurrects"], SpellIds.ResurrectSet);
        var interrupts = CountByActor(events["interrupts"], "sourceID", "interrupt");
        var dispels = CountByActor(events["dispels"], "sourceID", "dispel");
        var consumables = CollectConsumables(events["casts"], events["buffs"]);

        // Ereignisse kommen absichtlich aus dem ganzen Report. In die Sitzung
        // gehören trotzdem nur Akteure, die an einem Encounter teilnahmen;
        // sonst erscheinen Trash-Helfer und Zuschauer mit null Anwesenheit.
        var actorIds = new HashSet<int>(seconds.Keys);
        if (actorIds.Count == 0) return new List<string>();

        var zone = report.TryGetProperty("zone", out var zoneValue) && zoneValue.ValueKind == JsonValueKind.Object
            ? Sanitize(zoneValue.TryGetProperty("name", out var zoneName) ? zoneName.GetString() : null)
            : string.Empty;
        var startedAt = (long)Math.Floor(GetDouble(report, "startTime") / 1000.0);
        var endedAt = (long)Math.Floor(GetDouble(report, "endTime") / 1000.0);

        var lines = new List<string>
        {
            string.Create(CultureInfo.InvariantCulture,
                $"S|{code}|{startedAt}|{endedAt}|{zone}|{fights.Count}|{kills}|{wipes}"),
        };

        var rows = new List<string>();
        foreach (var actorId in actorIds)
        {
            if (!actors.TryGetValue(actorId, out var actor) || actor.Name.Length == 0) continue;
            var counts = consumables.GetValueOrDefault(actorId);
            var consumableText = counts is null
                ? string.Empty
                : string.Join(",", counts.Where(pair => pair.Value > 0).Select(pair => $"{pair.Key}:{pair.Value}"));
            rows.Add(string.Create(CultureInfo.InvariantCulture,
                $"P|{actor.Name}|{actor.ClassFile}|{(long)Math.Round(seconds.GetValueOrDefault(actorId))}|" +
                $"{deaths.GetValueOrDefault(actorId)}|{interrupts.GetValueOrDefault(actorId)}|" +
                $"{dispels.GetValueOrDefault(actorId)}|{consumableText}|{resurrects.GetValueOrDefault(actorId)}"));
        }
        if (rows.Count == 0) return new List<string>();

        rows.Sort(StringComparer.Ordinal);
        lines.AddRange(rows);
        return lines;
    }

    private static List<string> BuildProfileLines(Dictionary<string, PlayerProfile> players)
    {
        return players.Values
            .OrderBy(player => player.Name, StringComparer.Ordinal)
            .Select(player =>
            {
                var specs = player.Specs.OrderByDescending(pair => pair.Value).Select(pair => pair.Key).ToList();
                var primary = specs.Count > 0 ? specs[0] : string.Empty;
                var secondary = specs.Count > 1 ? specs[1] : string.Empty;
                return $"{player.Name};{player.ClassFile};{primary};{secondary}";
            })
            .ToList();
    }

    // ---------------------------------------------------------------------
    // Netzzugriff
    // ---------------------------------------------------------------------

    private async Task<string> GetAccessTokenAsync(string clientId, string clientSecret, CancellationToken token)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, "https://www.warcraftlogs.com/oauth/token");
        var basic = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{clientId}:{clientSecret}"));
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic", basic);
        request.Content = new FormUrlEncodedContent(new Dictionary<string, string> { ["grant_type"] = "client_credentials" });

        using var response = await Http.SendAsync(request, token);
        if (!response.IsSuccessStatusCode)
        {
            var hint = (int)response.StatusCode == 401 ? " Client ID oder Client Secret stimmen nicht." : string.Empty;
            throw new InvalidOperationException($"WCL-Anmeldung fehlgeschlagen ({(int)response.StatusCode}).{hint}");
        }

        using var payload = JsonDocument.Parse(await response.Content.ReadAsStringAsync(token));
        if (!payload.RootElement.TryGetProperty("access_token", out var accessToken))
        {
            throw new InvalidOperationException("Warcraft Logs hat kein Zugriffstoken geliefert.");
        }
        return accessToken.GetString() ?? throw new InvalidOperationException("Leeres Zugriffstoken.");
    }

    private async Task<List<string>> ResolveReportsAsync(WclTarget target, int limit, CancellationToken token)
    {
        var attempts = new List<string>();

        foreach (var origin in target.Origins)
        {
            _origin = origin;

            if (target.Kind == TargetKind.Report)
            {
                try
                {
                    var data = await QueryAsync("report", MetaQuery, new { code = target.ReportCode }, token);
                    var report = data.GetProperty("reportData").GetProperty("report");
                    if (report.ValueKind == JsonValueKind.Object
                        && report.TryGetProperty("code", out var code) && code.ValueKind == JsonValueKind.String)
                    {
                        _log.Report($"  Report {target.ReportCode} auf {origin} gefunden.");
                        return new List<string> { code.GetString()! };
                    }
                    attempts.Add($"{origin}: Report unbekannt");
                }
                catch (Exception error)
                {
                    attempts.Add($"{origin}: {error.Message}");
                }
                continue;
            }

            var names = target.GuildId.HasValue ? new List<string?> { null } : target.GuildNames.Cast<string?>().ToList();
            foreach (var guildName in names)
            {
                try
                {
                    var variables = new
                    {
                        guildName,
                        serverSlug = guildName is null ? null : target.ServerSlug,
                        region = guildName is null ? null : target.Region,
                        guildID = target.GuildId,
                        limit,
                    };
                    var data = await QueryAsync("reports", ReportsQuery, variables, token);
                    var list = data.GetProperty("reportData").GetProperty("reports").GetProperty("data");
                    if (list.ValueKind == JsonValueKind.Array && list.GetArrayLength() > 0)
                    {
                        var codes = list.EnumerateArray()
                            .OrderByDescending(report => GetDouble(report, "endTime"))
                            .Select(report => report.GetProperty("code").GetString()!)
                            .ToList();
                        var suffix = guildName is null ? string.Empty : $" für \"{guildName}\"";
                        _log.Report($"  {codes.Count} Reports auf {origin}{suffix} gefunden.");
                        return codes;
                    }
                    attempts.Add($"{origin}{(guildName is null ? "" : $" / \"{guildName}\"")}: 0 Reports");
                }
                catch (Exception error)
                {
                    attempts.Add($"{origin}{(guildName is null ? "" : $" / \"{guildName}\"")}: {error.Message}");
                }
            }
        }

        throw new InvalidOperationException(
            "Keine öffentlichen Reports gefunden.\nVersucht wurde:\n  " + string.Join("\n  ", attempts));
    }

    private async Task<List<JsonElement>> FetchEventsAsync(
        string code, string dataType, double duration, string? filter, CancellationToken token)
    {
        var collected = new List<JsonElement>();
        double start = 0;
        for (var page = 0; page < 40; page++)
        {
            var data = await QueryAsync($"events({dataType})", EventsQuery,
                new { code, dataType, start, end = duration, filter }, token);
            var paginator = data.GetProperty("reportData").GetProperty("report").GetProperty("events");
            if (paginator.TryGetProperty("data", out var rows) && rows.ValueKind == JsonValueKind.Array)
            {
                collected.AddRange(rows.EnumerateArray().Select(row => row.Clone()));
            }
            if (!paginator.TryGetProperty("nextPageTimestamp", out var next) || next.ValueKind != JsonValueKind.Number)
            {
                break;
            }
            var nextStart = next.GetDouble();
            if (nextStart <= start) break;
            start = nextStart;
        }
        return collected;
    }

    private async Task<JsonElement> QueryAsync(string label, string query, object variables, CancellationToken token)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, $"{_origin}/api/v2/client");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _token);
        var body = JsonSerializer.Serialize(new { query, variables },
            new JsonSerializerOptions { DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.Never });
        request.Content = new StringContent(body, Encoding.UTF8, "application/json");

        using var response = await Http.SendAsync(request, token);
        var text = await response.Content.ReadAsStringAsync(token);

        JsonDocument payload;
        try
        {
            payload = JsonDocument.Parse(text);
        }
        catch
        {
            throw new InvalidOperationException($"{label}: unlesbare Antwort ({(int)response.StatusCode}).");
        }

        using (payload)
        {
            if (payload.RootElement.TryGetProperty("errors", out var errors) && errors.ValueKind == JsonValueKind.Array
                && errors.GetArrayLength() > 0)
            {
                var messages = errors.EnumerateArray()
                    .Select(error => error.TryGetProperty("message", out var message) ? message.GetString() : null)
                    .Where(message => message is not null);
                throw new InvalidOperationException(string.Join("; ", messages));
            }
            if (!response.IsSuccessStatusCode)
            {
                throw new InvalidOperationException($"{label}: WCL-API-Fehler ({(int)response.StatusCode}).");
            }
            return payload.RootElement.GetProperty("data").Clone();
        }
    }

    private const string ReportsQuery = """
        query GuildCopilotReports($guildName: String, $serverSlug: String, $region: String, $guildID: Int, $limit: Int!) {
          reportData {
            reports(guildName: $guildName, guildServerSlug: $serverSlug, guildServerRegion: $region,
                    guildID: $guildID, limit: $limit) {
              total
              data { code startTime endTime title }
            }
          }
        }
        """;

    private const string MetaQuery = """
        query GuildCopilotMeta($code: String!) {
          reportData {
            report(code: $code) {
              code
              title
              startTime
              endTime
              zone { name }
              masterData { actors(type: "Player") { id name subType } }
              fights(killType: Encounters) { id name kill startTime endTime friendlyPlayers }
            }
          }
        }
        """;

    private const string DetailsQuery = """
        query GuildCopilotDetails($code: String!, $start: Float!, $end: Float!) {
          reportData { report(code: $code) { playerDetails(startTime: $start, endTime: $end) } }
        }
        """;

    private const string EventsQuery = """
        query GuildCopilotEvents($code: String!, $dataType: EventDataType!, $start: Float!, $end: Float!, $filter: String) {
          reportData {
            report(code: $code) {
              events(dataType: $dataType, startTime: $start, endTime: $end, hostilityType: Friendlies,
                     filterExpression: $filter, limit: 10000) {
                data
                nextPageTimestamp
              }
            }
          }
        }
        """;
}
