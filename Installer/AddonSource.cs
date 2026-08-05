using System.IO.Compression;
using System.Net.Http.Headers;
using System.Text.RegularExpressions;

namespace GuildCopilot.Installer;

/// <summary>
/// Holt das Addon direkt aus dem GitHub-Repository - ohne Zwischenschritt ueber
/// eine heruntergeladene ZIP-Datei, die jemand von Hand entpacken muss.
/// </summary>
public static class AddonSource
{
    public const string Owner = "stryker-max";
    public const string Repo = "GuildCopilot";
    public const string Branch = "main";

    private static readonly HttpClient Http = CreateClient();

    private static HttpClient CreateClient()
    {
        var client = new HttpClient { Timeout = TimeSpan.FromMinutes(2) };
        client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("GuildCopilot-Installer", "1.0"));
        return client;
    }

    public static string ParseVersion(string tocContent)
    {
        var match = Regex.Match(tocContent, @"^##\s*Version:\s*(.+)$", RegexOptions.Multiline);
        return match.Success ? match.Groups[1].Value.Trim() : string.Empty;
    }

    /// <summary>
    /// Die verfuegbare Version steht in der TOC im Repository. Gelesen wird
    /// ueber die API und nicht ueber raw.githubusercontent.com: deren CDN
    /// liefert nach einem Push noch minutenlang den alten Stand aus, was wie
    /// ein fehlgeschlagener Upload aussieht.
    /// </summary>
    public static async Task<string> GetAvailableVersionAsync(CancellationToken token = default)
    {
        var url = $"https://api.github.com/repos/{Owner}/{Repo}/contents/GuildCopilot/GuildCopilot.toc?ref={Branch}";
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github.raw"));
        request.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true };

        using var response = await Http.SendAsync(request, token);
        response.EnsureSuccessStatusCode();
        var toc = await response.Content.ReadAsStringAsync(token);

        var version = ParseVersion(toc);
        if (version.Length == 0)
        {
            throw new InvalidOperationException("In der TOC im Repository steht keine Version.");
        }
        return version;
    }

    /// <summary>
    /// Laedt den Branch als ZIP, entpackt und prueft ihn vollstaendig, bevor
    /// der vorhandene Addon-Ordner beruehrt wird. Fehler beim anschliessenden
    /// Ueberschreiben werden gemeldet; SavedVariables liegen ausserhalb dieses
    /// Ordners und bleiben davon unberuehrt.
    /// </summary>
    public static async Task<string> InstallAsync(string addonsPath, IProgress<string> log, CancellationToken token = default)
    {
        if (!Directory.Exists(addonsPath))
        {
            throw new DirectoryNotFoundException($"Der AddOns-Ordner existiert nicht: {addonsPath}");
        }

        var staging = Path.Combine(Path.GetTempPath(), "GuildCopilot-Installer", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(staging);
        try
        {
            log.Report($"Lade {Owner}/{Repo} ({Branch}) …");
            var zipUrl = $"https://codeload.github.com/{Owner}/{Repo}/zip/refs/heads/{Branch}";
            var archive = Path.Combine(staging, "source.zip");
            await using (var stream = await Http.GetStreamAsync(zipUrl, token))
            await using (var file = File.Create(archive))
            {
                await stream.CopyToAsync(file, token);
            }

            var extracted = Path.Combine(staging, "extracted");
            ZipFile.ExtractToDirectory(archive, extracted);

            var source = Directory
                .EnumerateDirectories(extracted)
                .Select(root => Path.Combine(root, "GuildCopilot"))
                .FirstOrDefault(candidate => File.Exists(Path.Combine(candidate, "GuildCopilot.toc")));
            if (source is null)
            {
                throw new InvalidOperationException("Im Download war kein Ordner GuildCopilot mit GuildCopilot.toc.");
            }

            var version = ParseVersion(await File.ReadAllTextAsync(Path.Combine(source, "GuildCopilot.toc"), token));
            var target = Path.Combine(addonsPath, "GuildCopilot");

            if (Directory.Exists(target))
            {
                log.Report("Ersetze die vorhandene Fassung. Gespeicherte Einstellungen liegen im WTF-Ordner und bleiben erhalten.");
            }

            // Der Ordner wird ueberschrieben statt geloescht oder umbenannt.
            // Ein geoeffnetes Explorer-Fenster oder eine laufende Datei im
            // Companion-Ordner sperrt sonst das Loeschen und die Installation
            // bricht ab - fuer ein offenes Fenster ist das kein akzeptabler
            // Grund. Aus demselben Grund gibt es keinen Verzeichnistausch:
            // Auch das Umbenennen des Live-Ordners scheitert an einer offenen
            // Datei darin.
            //
            // Jede Datei geht deshalb einzeln und in einem Schritt an ihren
            // Platz (File.Replace), die vorherige Fassung wandert dabei in
            // eine Sicherung. Bricht das Kopieren mittendrin ab - Datei
            // gesperrt, Platte voll -, wird der vorherige Stand daraus wieder
            // hergestellt. Vorher blieb in dem Fall eine Mischung aus zwei
            // Versionen liegen, die im Spiel schwer zu deuten ist.
            var replaced = new List<Replacement>();
            try
            {
                InstallDirectory(source, target, replaced);

                if (!File.Exists(Path.Combine(target, "GuildCopilot.toc")))
                {
                    throw new InvalidOperationException("Nach dem Kopieren fehlt GuildCopilot.toc.");
                }
            }
            catch
            {
                log.Report("Installation abgebrochen – der vorherige Stand wird wiederhergestellt.");
                Rollback(replaced);
                throw;
            }

            // Ab hier steht die neue Fassung. Die Sicherungen werden nicht mehr
            // gebraucht, und erst jetzt darf aufgeraeumt werden: Was
            // RemoveStaleEntries loescht, holt kein Rollback zurueck.
            DropBackups(replaced);
            RemoveStaleEntries(source, target, log);
            log.Report($"Version {version} installiert nach {target}");
            return version;
        }
        finally
        {
            TryDelete(staging);
        }
    }

    public static bool Uninstall(string addonsPath, IProgress<string> log)
    {
        var target = Path.Combine(addonsPath, "GuildCopilot");
        if (!Directory.Exists(target))
        {
            log.Report("Dort ist Guild Copilot nicht installiert.");
            return false;
        }
        Directory.Delete(target, recursive: true);
        log.Report($"Entfernt: {target}. Gespeicherte Einstellungen im WTF-Ordner bleiben erhalten.");
        return true;
    }

    /// <summary>
    /// Vergleicht zwei Versionen wie "0.9.17" der Stelle nach. Wichtig, damit
    /// eine aeltere Fassung im Repository nicht als Aktualisierung angeboten
    /// wird - ein blosser Ungleichheitsvergleich stuft sonst herunter.
    /// </summary>
    public static int CompareVersions(string? left, string? right)
    {
        var leftParts = SplitVersion(left);
        var rightParts = SplitVersion(right);
        for (var index = 0; index < Math.Max(leftParts.Length, rightParts.Length); index++)
        {
            var leftValue = index < leftParts.Length ? leftParts[index] : 0;
            var rightValue = index < rightParts.Length ? rightParts[index] : 0;
            if (leftValue != rightValue)
            {
                return leftValue.CompareTo(rightValue);
            }
        }
        return 0;
    }

    private static int[] SplitVersion(string? version)
    {
        if (string.IsNullOrWhiteSpace(version))
        {
            return Array.Empty<int>();
        }
        return version
            .Split('.', StringSplitOptions.RemoveEmptyEntries)
            .Select(part => int.TryParse(new string(part.TakeWhile(char.IsDigit).ToArray()), out var value) ? value : 0)
            .ToArray();
    }

    /// <summary>
    /// Entfernt, was es in der neuen Fassung nicht mehr gibt. Gesperrte
    /// Eintraege werden benannt und uebersprungen - eine Altdatei mehr ist
    /// harmlos, eine abgebrochene Installation nicht.
    /// </summary>
    private static void RemoveStaleEntries(string source, string target, IProgress<string> log)
    {
        var blocked = 0;

        foreach (var file in Directory.EnumerateFiles(target))
        {
            if (File.Exists(Path.Combine(source, Path.GetFileName(file)))) continue;
            try
            {
                File.Delete(file);
            }
            catch
            {
                blocked++;
            }
        }

        foreach (var folder in Directory.EnumerateDirectories(target))
        {
            var name = Path.GetFileName(folder);
            var counterpart = Path.Combine(source, name);
            if (Directory.Exists(counterpart))
            {
                RemoveStaleEntries(counterpart, folder, log);
                continue;
            }
            try
            {
                Directory.Delete(folder, recursive: true);
            }
            catch
            {
                blocked++;
            }
        }

        if (blocked > 0)
        {
            log.Report($"{blocked} veraltete Einträge waren gesperrt und bleiben liegen "
                     + "(meist ein geöffnetes Explorer-Fenster). Das Addon selbst ist vollständig.");
        }
    }

    /// <summary>
    /// Eine ersetzte Datei und die Sicherung ihrer vorherigen Fassung.
    /// <c>Backup</c> ist null, wenn die Datei neu hinzugekommen ist - dann
    /// gibt es nichts wiederherzustellen, sie muss beim Rollback weg.
    /// </summary>
    private sealed record Replacement(string Target, string? Backup);

    private const string StagedSuffix = ".gcnew";
    private const string BackupSuffix = ".gcold";

    /// <summary>
    /// Kopiert den Addon-Ordner Datei fuer Datei ueber die Installation.
    /// Geschrieben wird immer erst daneben und dann in einem Schritt an den
    /// richtigen Platz: Ein abgebrochener Schreibvorgang kann so keine halbe
    /// Datei hinterlassen, die WoW spaeter zu laden versucht.
    /// </summary>
    private static void InstallDirectory(string source, string target, List<Replacement> replaced)
    {
        Directory.CreateDirectory(target);
        foreach (var file in Directory.EnumerateFiles(source))
        {
            var destination = Path.Combine(target, Path.GetFileName(file));
            var staged = destination + StagedSuffix;
            File.Copy(file, staged, overwrite: true);
            if (File.Exists(destination))
            {
                var backup = destination + BackupSuffix;
                File.Replace(staged, destination, backup, ignoreMetadataErrors: true);
                replaced.Add(new Replacement(destination, backup));
            }
            else
            {
                File.Move(staged, destination);
                replaced.Add(new Replacement(destination, null));
            }
        }
        foreach (var folder in Directory.EnumerateDirectories(source))
        {
            InstallDirectory(folder, Path.Combine(target, Path.GetFileName(folder)), replaced);
        }
    }

    /// <summary>
    /// Stellt den Stand vor der Installation wieder her - rueckwaerts, damit
    /// zuerst zurueckgeht, was zuletzt ersetzt wurde. Fehler werden hier
    /// geschluckt: Es laeuft bereits eine Ausnahme, und die ist die
    /// interessantere Nachricht.
    /// </summary>
    private static void Rollback(List<Replacement> replaced)
    {
        for (var index = replaced.Count - 1; index >= 0; index--)
        {
            var entry = replaced[index];
            try
            {
                if (entry.Backup is null)
                {
                    File.Delete(entry.Target);
                }
                else if (File.Exists(entry.Backup))
                {
                    File.Move(entry.Backup, entry.Target, overwrite: true);
                }
            }
            catch
            {
                // Weitermachen: Jede Datei, die zurueckgeht, ist ein Gewinn.
            }
        }
    }

    private static void DropBackups(List<Replacement> replaced)
    {
        foreach (var entry in replaced)
        {
            if (entry.Backup is null) continue;
            try
            {
                File.Delete(entry.Backup);
            }
            catch
            {
                // Eine liegengebliebene Sicherung raeumt RemoveStaleEntries auf.
            }
        }
    }

    private static void TryDelete(string path)
    {
        try
        {
            if (Directory.Exists(path)) Directory.Delete(path, recursive: true);
        }
        catch
        {
            // Ein liegengebliebener Temp-Ordner ist kein Grund für eine Fehlermeldung.
        }
    }
}
