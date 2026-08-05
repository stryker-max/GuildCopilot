using System.Globalization;
using System.Text;
using GuildCopilot.Installer.Wcl;

namespace GuildCopilot.Installer.CombatLog;

public sealed record CombatLogResult(
    string Text, int Sessions, int Participants, long Lines, IReadOnlyList<string> Warnings);

/// <summary>
/// Wertet eine WoWCombatLog.txt aus und erzeugt den Importcode fuer das Addon.
///
/// Warum ueberhaupt der Installer: Ein WoW-Addon darf keine Dateien lesen. Die
/// Datei hat aber alles, was eine Livesitzung auch zaehlt - und zwar auch dann,
/// wenn an dem Abend niemand "Sitzung starten" gedrueckt hat. Genau das ist der
/// Zweck: ein Raidabend ist nicht mehr verloren, nur weil das Addon nicht lief.
///
/// Vier Dinge sind an dem Format leicht zu uebersehen:
///   1. Zeitstempel und Nutzlast trennen zwei Leerzeichen, nicht eines. Und je
///      Spielfassung steht das Jahr im Zeitstempel oder eben nicht.
///   2. Namen stehen in Anfuehrungszeichen und enthalten Bindestriche
///      ("Name-Realm-EU"). Ein Komma-Split ohne Ruecksicht auf die
///      Anfuehrungszeichen zerlegt COMBATANT_INFO-Zeilen in Dutzende Felder.
///   3. COMBATANT_INFO hat gar kein Namensfeld - an Feld 2 steht eine Zahl.
///      Wer die Zeile wie ein gewoehnliches Ereignis liest, bekommt einen
///      Teilnehmer namens "0". Die Zeile taugt aber als Anwesenheitsbeleg:
///      Sie erscheint beim Pull fuer jedes Raidmitglied.
///   4. Die Datei ist mehrere Dutzend MB gross. Sie wird deshalb zeilenweise
///      gestreamt (File.ReadLines) und nie am Stueck geladen.
/// </summary>
public sealed class CombatLogImporter
{
    public const string FormatHeader = "GCPLOG1";

    /// <summary>
    /// Ab dieser Pause zwischen zwei Bosskaempfen gilt der naechste Kampf als
    /// neuer Raidabend. Eine Logdatei laeuft ueber mehrere Abende weiter.
    /// </summary>
    private static readonly TimeSpan SessionGap = TimeSpan.FromHours(2);

    /// <summary>
    /// So weit vor dem ersten und nach dem letzten Pull werden Ereignisse noch
    /// dem Abend zugerechnet. Getrunken wird vor dem Pull, wiederbelebt wird
    /// zwischen den Pulls - beides gehoert dazu.
    /// </summary>
    private static readonly TimeSpan SessionLeadIn = TimeSpan.FromMinutes(30);

    private enum EventKind { Death, Resurrect, Interrupt, Dispel, Consumable }

    private readonly record struct CountedEvent(DateTime When, string Guid, EventKind Kind, int SpellId);

    private sealed class Participant
    {
        public double Seconds;
        public int Deaths;
        public int Resurrects;
        public int Interrupts;
        public int Dispels;
        public readonly Dictionary<int, int> Consumables = new();
    }

    private sealed class LogSession
    {
        public DateTime StartedAt;
        public DateTime EndedAt;
        public int Pulls;
        public int Kills;
        public int Wipes;
        public readonly List<string> Bosses = new();

        // Geschluesselt ueber die GUID, nicht ueber den Namen: Der Name steht
        // nicht in jeder Zeile, die GUID schon.
        public readonly Dictionary<string, Participant> Participants = new(StringComparer.Ordinal);

        public Participant For(string guid)
        {
            if (!Participants.TryGetValue(guid, out var participant))
            {
                participant = new Participant();
                Participants[guid] = participant;
            }
            return participant;
        }
    }

    public CombatLogResult Run(string path, IProgress<string> log, CancellationToken token)
    {
        var file = new FileInfo(path);
        if (!file.Exists) throw new FileNotFoundException("Die Protokolldatei wurde nicht gefunden.", path);

        var warnings = new List<string>();
        var sessions = new List<LogSession>();
        LogSession? current = null;

        // GUID zu Kurzname, ueber die ganze Datei. Nicht jede Zeile nennt einen
        // Namen (COMBATANT_INFO etwa nicht), deshalb wird er einmal gemerkt und
        // erst bei der Ausgabe aufgeloest.
        var names = new Dictionary<string, string>(StringComparer.Ordinal);

        // Ereignisse vor dem ersten Pull eines Abends. Sie werden nachgetragen,
        // sobald der Abend beginnt - sonst fehlte jedes Flaeschchen.
        var pending = new List<CountedEvent>();

        // Innerhalb eines Bosskampfes: wer auftaucht, war dabei. Die Anwesenheit
        // kommt aus den Kampfdauern, denn eine Rosterzeile steht im Log nicht.
        var encounterStart = DateTime.MinValue;
        var seenInEncounter = new HashSet<string>(StringComparer.Ordinal);
        var inEncounter = false;

        long lines = 0;
        long unparsable = 0;

        // Aeltere Spielfassungen schreiben kein Jahr in den Zeitstempel. Bis
        // 1.0.6 bekam deshalb jede Zeile das Jahr der Datei - ein Raidabend
        // ueber Silvester landete damit komplett im Jahr des 1. Januar, und
        // der Dezemberteil sprang um ein Jahr nach vorn.
        //
        // Im Log zeigt sich der Jahreswechsel als Monatsruecksprung (12 -> 1).
        // Die Datei endet im Jahr ihres Zeitstempels; sie faengt also im Jahr
        // davor an, wenn ihr erster Monat hinter dem letzten liegt.
        var fileYear = file.LastWriteTime.Year;
        var firstMonth = FirstLoggedMonth(file);
        var year = firstMonth > file.LastWriteTime.Month ? fileYear - 1 : fileYear;
        var previousMonth = 0;

        log.Report($"Lese {CombatLogFinder.Describe(file)} …");

        foreach (var line in File.ReadLines(file.FullName, Encoding.UTF8))
        {
            token.ThrowIfCancellationRequested();
            lines++;
            if (lines % 250_000 == 0) log.Report($"  {lines:N0} Zeilen …");

            if (!TryParseTimestamp(line, year, out var when, out var payload, out var yearFromLog))
            {
                unparsable++;
                continue;
            }

            // Nur selbst gesetzte Jahre duerfen nachgezogen werden. Steht das
            // Jahr im Log, ist es richtig und der Ruecksprung schon eingebaut.
            if (!yearFromLog)
            {
                if (previousMonth > 0 && when.Month < previousMonth)
                {
                    year++;
                    when = when.AddYears(1);
                }
                previousMonth = when.Month;
            }

            var comma = payload.IndexOf(',');
            var subevent = comma < 0 ? payload : payload[..comma];

            if (subevent == "ENCOUNTER_START")
            {
                var boss = Unquote(Field(SplitFields(payload, 3), 2));

                // Ein Versuch ohne ENCOUNTER_END, auf den sofort der naechste
                // folgt: Das ist ein Wipe oder ein Reset, dessen Schlusszeile
                // das Log verloren hat. In der Testdatei stehen vier Starts,
                // aber nur drei Enden - ohne diesen Abschluss haette der Abend
                // vier Versuche bei drei Ergebnissen.
                if (inEncounter && current is not null)
                {
                    CloseEncounter(current, seenInEncounter, encounterStart, when, kill: false);
                }

                encounterStart = when;
                inEncounter = true;
                seenInEncounter.Clear();

                if (current is null || when - current.EndedAt > SessionGap)
                {
                    current = new LogSession { StartedAt = when, EndedAt = when };
                    sessions.Add(current);
                    FlushPending(pending, current);
                }
                current.Pulls++;
                if (boss.Length > 0 && !current.Bosses.Contains(boss, StringComparer.Ordinal))
                {
                    current.Bosses.Add(boss);
                }
                continue;
            }

            if (subevent == "ENCOUNTER_END")
            {
                // Ein Log kann mitten im Kampf beginnen. Dann fehlt der Start,
                // und der Versuch wird nicht gezaehlt, statt eine Dauer aus dem
                // Nichts zu erfinden.
                if (!inEncounter || current is null)
                {
                    inEncounter = false;
                    continue;
                }
                CloseEncounter(current, seenInEncounter, encounterStart, when,
                    kill: Field(SplitFields(payload, 6), 5) == "1");
                inEncounter = false;
                continue;
            }

            // COMBATANT_INFO nennt beim Pull jedes Raidmitglied - auch die, die
            // im Kampf sonst kein einziges gezaehltes Ereignis erzeugen. Die
            // Zeile belegt nur Anwesenheit; ein Name steht nicht darin.
            if (subevent == "COMBATANT_INFO")
            {
                if (inEncounter)
                {
                    var guid = Field(SplitFields(payload, 2), 1);
                    if (IsPlayer(guid)) seenInEncounter.Add(guid);
                }
                continue;
            }

            // Alles andere - und das ist die ueberwaeltigende Mehrheit der Datei
            // - wird hier abgewiesen, bevor irgendetwas zerlegt wird.
            var relevant = RelevantSubevent(subevent);
            if (!relevant && !inEncounter) continue;

            var fields = SplitFields(payload, relevant ? 11 : 7);
            var sourceGuid = Field(fields, 1);
            var destGuid = Field(fields, 5);
            NoteName(names, sourceGuid, Unquote(Field(fields, 2)));
            NoteName(names, destGuid, Unquote(Field(fields, 6)));

            if (inEncounter)
            {
                if (IsPlayer(sourceGuid)) seenInEncounter.Add(sourceGuid);
                if (IsPlayer(destGuid)) seenInEncounter.Add(destGuid);
            }

            if (!relevant) continue;

            var spellId = ParseInt(Field(fields, 9));
            var kind = Classify(subevent, spellId);
            if (kind is null) continue;

            // Wer gezaehlt wird, haengt am Ereignis: Der Tod trifft das Ziel,
            // gewirkt wird von der Quelle. Als Aura kommt hier nur noch Essen
            // an (siehe Classify), und der Sattgegessen-Buff landet auf dem,
            // der gegessen hat - also auf dem Ziel.
            var guidOfInterest = kind switch
            {
                EventKind.Death => destGuid,
                EventKind.Consumable when subevent != "SPELL_CAST_SUCCESS" => destGuid,
                _ => sourceGuid,
            };
            if (!IsPlayer(guidOfInterest)) continue;

            var counted = new CountedEvent(when, guidOfInterest, kind.Value, spellId);
            if (current is not null && when - current.EndedAt <= SessionLeadIn)
            {
                Apply(counted, current);
            }
            else
            {
                pending.Add(counted);
                // Der Puffer darf nicht unbegrenzt wachsen, wenn eine Datei
                // stundenlang Ereignisse ohne einen einzigen Bosskampf enthaelt.
                if (pending.Count > 20_000) pending.RemoveRange(0, 10_000);
            }
        }

        if (unparsable > 0)
        {
            warnings.Add($"{unparsable:N0} Zeilen ohne lesbaren Zeitstempel übersprungen.");
        }

        var output = new StringBuilder();
        var blocks = new List<List<string>>();
        var participantCount = 0;
        var namelessTotal = 0;
        foreach (var session in sessions.OrderBy(session => session.StartedAt))
        {
            var (block, nameless) = BuildSessionLines(session, names);
            namelessTotal += nameless;
            if (block.Count <= 1) continue;
            blocks.Add(block);
            participantCount += block.Count - 1;
            log.Report($"  {session.StartedAt:dd.MM.yyyy HH:mm}: {session.Pulls} Versuche, "
                       + $"{session.Kills} Siege, {session.Wipes} Wipes, {block.Count - 1} Teilnehmer.");
        }

        if (namelessTotal > 0)
        {
            warnings.Add($"{namelessTotal} Teilnehmer ohne im Log genannten Namen verworfen.");
        }
        if (blocks.Count == 0)
        {
            throw new InvalidOperationException(
                "In der Datei stehen keine auswertbaren Bosskämpfe. "
                + "Wurde das Protokoll (/combatlog) während des Raids überhaupt aufgezeichnet?");
        }

        // Ein WoWCombatLog.txt sammelt oft viele Raidabende. Passt nicht alles
        // in das Importfeld des Addons, gehen die aeltesten - importieren will
        // man den letzten Abend. Geschnitten wird ausschliesslich an der
        // Abendgrenze: WoW wuerde den Text sonst stumm mitten in einer Zeile
        // abschneiden, und das Addon nimmt den Rest als gueltigen Teilimport
        // an. Ein halber Abend saehe hinterher aus wie ein vollstaendiger.
        var kept = blocks;
        if (HeaderLength(blocks.Count) + blocks.Sum(BlockLength) > AddonImport.Limit)
        {
            var fitting = new List<List<string>>();
            var used = 0;
            for (var index = blocks.Count - 1; index >= 0; index--)
            {
                var cost = BlockLength(blocks[index]);
                if (HeaderLength(fitting.Count + 1) + used + cost > AddonImport.Limit) break;
                fitting.Insert(0, blocks[index]);
                used += cost;
            }
            if (fitting.Count == 0)
            {
                throw new InvalidOperationException(
                    $"Schon der letzte Raidabend allein ist mit {BlockLength(blocks[^1]):N0} Zeichen "
                    + $"groesser als die {AddonImport.Limit:N0} Zeichen, die das Importfeld im Addon "
                    + "aufnimmt. Bitte den Raid in kuerzeren Protokolldateien aufzeichnen.");
            }
            warnings.Add($"Nur die letzten {fitting.Count} von {blocks.Count} Raidabenden passen in das "
                         + $"Importfeld ({AddonImport.Limit:N0} Zeichen); die {blocks.Count - fitting.Count} "
                         + "aelteren wurden weggelassen.");
            kept = fitting;
            participantCount = fitting.Sum(block => block.Count - 1);
        }

        output.Append(FormatHeader).Append('|').Append(kept.Count).Append('\n');
        foreach (var block in kept)
        {
            foreach (var text in block) output.Append(text).Append('\n');
        }

        return new CombatLogResult(output.ToString(), kept.Count, participantCount, lines, warnings);
    }

    /// <summary>
    /// Zeichen, die ein Raidabend im Importfeld belegt - jede Zeile plus ihr
    /// Zeilenumbruch, genau so, wie sie unten geschrieben wird.
    /// </summary>
    private static int BlockLength(List<string> block) => block.Sum(line => line.Length + 1);

    private static int HeaderLength(int blockCount) =>
        FormatHeader.Length + 1
        + blockCount.ToString(CultureInfo.InvariantCulture).Length + 1;

    // ---------------------------------------------------------------------
    // Auswertung
    // ---------------------------------------------------------------------

    /// <summary>
    /// Schliesst einen Bosskampf ab: Ergebnis verbuchen und jedem, der darin
    /// aufgetaucht ist, die Kampfdauer als Anwesenheit anrechnen. Die
    /// Obergrenze von einer Stunde faengt einen verlorenen ENCOUNTER_END ab,
    /// dessen Kampf sonst bis zum naechsten Pull "gedauert" haette.
    /// </summary>
    private static void CloseEncounter(
        LogSession session, HashSet<string> seen, DateTime startedAt, DateTime endedAt, bool kill)
    {
        if (kill) session.Kills++;
        else session.Wipes++;

        var duration = (endedAt - startedAt).TotalSeconds;
        if (duration is > 0 and < 3600)
        {
            foreach (var guid in seen) session.For(guid).Seconds += duration;
        }
        session.EndedAt = endedAt;
    }

    private static void NoteName(Dictionary<string, string> names, string guid, string name)
    {
        if (name.Length == 0 || name == "nil" || !IsPlayer(guid)) return;
        names[guid] = ShortName(name);
    }

    private static void FlushPending(List<CountedEvent> pending, LogSession session)
    {
        foreach (var counted in pending)
        {
            if (session.StartedAt - counted.When <= SessionLeadIn) Apply(counted, session);
        }
        pending.Clear();
    }

    private static void Apply(CountedEvent counted, LogSession session)
    {
        var participant = session.For(counted.Guid);
        switch (counted.Kind)
        {
            case EventKind.Death: participant.Deaths++; break;
            case EventKind.Resurrect: participant.Resurrects++; break;
            case EventKind.Interrupt: participant.Interrupts++; break;
            case EventKind.Dispel: participant.Dispels++; break;
            case EventKind.Consumable:
                participant.Consumables[counted.SpellId] =
                    participant.Consumables.GetValueOrDefault(counted.SpellId) + 1;
                break;
        }
    }

    private static bool RelevantSubevent(string subevent) => subevent switch
    {
        "UNIT_DIED" => true,
        "SPELL_RESURRECT" => true,
        "SPELL_INTERRUPT" => true,
        "SPELL_DISPEL" => true,
        "SPELL_STOLEN" => true,
        "SPELL_CAST_SUCCESS" => true,
        "SPELL_AURA_APPLIED" => true,
        "SPELL_AURA_REFRESH" => true,
        _ => false,
    };

    /// <summary>
    /// Gezaehlt wird genau das, was die Livesitzung auch zaehlt - beide Quellen
    /// muessen dieselbe Bedeutung haben, sonst sind ihre Zahlen nicht
    /// vergleichbar.
    ///
    /// Wichtig bei Wiederbelebungen: Nur SPELL_RESURRECT zaehlt, nicht der
    /// gewirkte Zauber. Beides zusammen zaehlt jede Wiederbelebung doppelt -
    /// gegen die Testdatei gemessen: 24 SPELL_RESURRECT, aber 47 gezaehlte
    /// Wiederbelebungen bei nur 39 Spielertoden. Der Warcraft-Logs-Import
    /// zaehlt umgekehrt ueber den Zauber, weil die API kein SPELL_RESURRECT
    /// kennt; hier gibt es es, und dann ist es die genauere Quelle.
    ///
    /// Dieselbe Falle stellen die Verbrauchsgegenstaende, und hier stand sie
    /// bis 1.0.6 offen: Gezaehlt wurden Wirkereignis UND Aura, aus einer
    /// einzigen flachen Liste. Das ist genau der Fehler, den die Livesitzung
    /// in 0.9.87 abgelegt hat (GC.ConsumableCategories, track = CAST/AURA):
    ///   - Eine Trommel bufft die ganze Gruppe. Ueber die Aura bekam sie jedes
    ///     Gruppenmitglied gutgeschrieben - im Vergleichslog vom 02.08.2026
    ///     warfen fuenf Spieler Trommeln, angezeigt wurden acht, einer mit 68
    ///     statt 28.
    ///   - Hast-, Zerstoerungs- und Heldentrank erzeugen Zauber UND eigene
    ///     Aura: vier Traenke standen als acht da.
    ///   - Flaeschchen und Elixiere zaehlten ueber SPELL_AURA_REFRESH mehrfach.
    /// Deshalb gilt jetzt je Gruppe genau eine Quelle - fuer Essen die Aura
    /// (ein Wirkereignis gibt es dafuer nie), fuer alles andere der Zauber.
    /// </summary>
    private static EventKind? Classify(string subevent, int spellId) => subevent switch
    {
        "UNIT_DIED" => EventKind.Death,
        "SPELL_RESURRECT" => EventKind.Resurrect,
        "SPELL_INTERRUPT" => EventKind.Interrupt,
        "SPELL_DISPEL" or "SPELL_STOLEN" => EventKind.Dispel,
        "SPELL_CAST_SUCCESS" when SpellIds.ConsumableSet.Contains(spellId)
            && !SpellIds.FoodAuraSet.Contains(spellId) => EventKind.Consumable,
        "SPELL_AURA_APPLIED" or "SPELL_AURA_REFRESH"
            when SpellIds.FoodAuraSet.Contains(spellId) => EventKind.Consumable,
        _ => null,
    };

    private static (List<string> Lines, int Nameless) BuildSessionLines(
        LogSession session, Dictionary<string, string> names)
    {
        var startedAt = ToUnixSeconds(session.StartedAt);
        var endedAt = ToUnixSeconds(session.EndedAt);
        // Der Code ist der Schluessel der Sitzung im Addon. Er kommt aus der
        // Startzeit, damit dieselbe Datei zweimal eingelesen denselben Abend
        // trifft statt ihn zu verdoppeln.
        var code = session.StartedAt.ToString("yyyyMMdd-HHmm", CultureInfo.InvariantCulture);

        var lines = new List<string>
        {
            // Feld 5 bleibt leer: Die Zone loest das Addon aus den Bossnamen
            // auf, dort steht die Zuordnung schon (GC.RaidBosses). Feld 9 mit
            // den Bossnamen haengt am Ende, damit ein aelteres Addon die Zeile
            // weiter lesen kann.
            string.Create(CultureInfo.InvariantCulture,
                $"S|{code}|{startedAt}|{endedAt}||{session.Pulls}|{session.Kills}|{session.Wipes}|"
                + $"{string.Join(",", session.Bosses.Select(Sanitize))}"),
        };

        var rows = new List<string>();
        var nameless = 0;
        foreach (var (guid, participant) in session.Participants)
        {
            // Ereignisse werden absichtlich aus dem ganzen Abend gezaehlt, auch
            // vor dem Pull. Damit gerieten aber auch Leute in die Liste, die nur
            // in der Naehe standen und sich selbst gebufft haben - in der
            // Testdatei elf Namen mit null Anwesenheit neben 26 echten
            // Teilnehmern. In den Abend gehoert nur, wer in einem Bosskampf war.
            if (participant.Seconds <= 0) continue;
            var name = Sanitize(names.GetValueOrDefault(guid, string.Empty));
            if (name.Length == 0)
            {
                nameless++;
                continue;
            }
            var consumables = string.Join(",", participant.Consumables
                .Where(pair => pair.Value > 0)
                .OrderBy(pair => pair.Key)
                .Select(pair => $"{pair.Key}:{pair.Value}"));
            // Feld 3 bleibt leer: Die Klasse steht im Combat Log nicht. Das
            // Addon zeigt den Namen dann ohne Klassenfarbe, statt eine geratene
            // Klasse zu behaupten.
            rows.Add(string.Create(CultureInfo.InvariantCulture,
                $"P|{name}||{(long)Math.Round(participant.Seconds)}|{participant.Deaths}|"
                + $"{participant.Interrupts}|{participant.Dispels}|{consumables}|{participant.Resurrects}"));
        }
        rows.Sort(StringComparer.Ordinal);
        lines.AddRange(rows);
        return (lines, nameless);
    }

    // ---------------------------------------------------------------------
    // Zeilenzerlegung
    // ---------------------------------------------------------------------

    private static readonly string[] TimestampFormats =
    {
        "M/d/yyyy HH:mm:ss.ffff",
        "M/d/yyyy HH:mm:ss.fff",
        "M/d HH:mm:ss.ffff",
        "M/d HH:mm:ss.fff",
    };

    /// <summary>
    /// Trennt "7/28/2026 19:48:26.6772  UNIT_DIED,..." in Zeitstempel und
    /// Nutzlast. Aeltere Spielfassungen schreiben kein Jahr; dann gilt das Jahr
    /// der Datei.
    /// </summary>
    internal static bool TryParseTimestamp(string line, int fallbackYear, out DateTime when, out string payload)
        => TryParseTimestamp(line, fallbackYear, out when, out payload, out _);

    /// <summary>
    /// <paramref name="yearFromLog"/> meldet, ob das Jahr aus der Zeile kam.
    /// Nur ein selbst gesetztes Jahr darf der Aufrufer beim Jahreswechsel
    /// nachziehen.
    /// </summary>
    internal static bool TryParseTimestamp(string line, int fallbackYear, out DateTime when,
        out string payload, out bool yearFromLog)
    {
        when = default;
        payload = string.Empty;
        yearFromLog = false;
        var separator = line.IndexOf("  ", StringComparison.Ordinal);
        if (separator <= 0) return false;

        var stamp = line[..separator];
        payload = line[(separator + 2)..].TrimStart();
        if (payload.Length == 0) return false;

        if (!DateTime.TryParseExact(stamp, TimestampFormats, CultureInfo.InvariantCulture,
                DateTimeStyles.None, out when))
        {
            return false;
        }
        yearFromLog = stamp.Count(character => character == '/') >= 2;
        if (!yearFromLog)
        {
            when = new DateTime(fallbackYear, when.Month, when.Day, when.Hour, when.Minute, when.Second,
                when.Millisecond, DateTimeKind.Unspecified);
        }
        return true;
    }

    /// <summary>
    /// Monat der ersten lesbaren Zeitstempelzeile - die Grundlage dafuer, ob
    /// die Datei ueber einen Jahreswechsel reicht. Unlesbare Kopfzeilen werden
    /// uebersprungen; findet sich gar nichts, meldet die Methode 0.
    /// </summary>
    private static int FirstLoggedMonth(FileInfo file)
    {
        foreach (var line in File.ReadLines(file.FullName, Encoding.UTF8))
        {
            if (TryParseTimestamp(line, file.LastWriteTime.Year, out var when, out _)) return when.Month;
        }
        return 0;
    }

    /// <summary>
    /// Zerlegt die Nutzlast an Kommas, achtet dabei aber auf
    /// Anfuehrungszeichen. Nach maxFields wird abgebrochen - die vorderen
    /// Felder reichen, und COMBATANT_INFO-Zeilen haben hunderte.
    /// </summary>
    internal static List<string> SplitFields(string payload, int maxFields)
    {
        var fields = new List<string>(maxFields);
        var start = 0;
        var quoted = false;
        for (var index = 0; index < payload.Length && fields.Count < maxFields; index++)
        {
            var character = payload[index];
            if (character == '"') quoted = !quoted;
            else if (character == ',' && !quoted)
            {
                fields.Add(payload[start..index]);
                start = index + 1;
            }
        }
        // Der Rest ist das letzte Feld. Ein Komma darin steckt zwangslaeufig in
        // Anfuehrungszeichen, sonst haette die Schleife dort getrennt.
        if (fields.Count < maxFields && start <= payload.Length) fields.Add(payload[start..]);
        return fields;
    }

    private static string Field(List<string> fields, int index) =>
        index < fields.Count ? fields[index] : string.Empty;

    private static string Unquote(string value) =>
        value.Length >= 2 && value[0] == '"' && value[^1] == '"' ? value[1..^1] : value;

    private static bool IsPlayer(string guid) => guid.StartsWith("Player-", StringComparison.Ordinal);

    /// <summary>
    /// "Buffdaeddy-Thunderstrike-EU" wird zu "Buffdaeddy". Die Livesitzung
    /// speichert ebenfalls den Kurznamen; beide Quellen muessen dieselbe Form
    /// haben, sonst steht derselbe Spieler zweimal in der Liste.
    /// </summary>
    private static string ShortName(string name)
    {
        var dash = name.IndexOf('-');
        return dash < 0 ? name : name[..dash];
    }

    private static int ParseInt(string value) =>
        int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out var number) ? number : 0;

    private static string Sanitize(string value) =>
        new(value.Where(character => character is not ('|' or ';' or ',' or '"' or '\r' or '\n')).ToArray());

    private static long ToUnixSeconds(DateTime local) =>
        new DateTimeOffset(local, TimeZoneInfo.Local.GetUtcOffset(local)).ToUnixTimeSeconds();
}
