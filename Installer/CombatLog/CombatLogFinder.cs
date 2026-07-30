namespace GuildCopilot.Installer.CombatLog;

/// <summary>
/// Findet die Combat-Log-Dateien einer Spielinstallation. WoW legt sie unter
/// &lt;Spielversion&gt;\Logs\WoWCombatLog*.txt ab - also zwei Ebenen ueber dem
/// AddOns-Ordner, den der Installer ohnehin schon kennt.
/// </summary>
public static class CombatLogFinder
{
    /// <summary>
    /// Liefert die Protokolldateien zu einem AddOns-Pfad, neueste zuerst.
    /// </summary>
    public static List<FileInfo> Find(string addonsPath)
    {
        var found = new List<FileInfo>();
        var logs = LogFolder(addonsPath);
        if (logs is null) return found;

        try
        {
            foreach (var file in logs.EnumerateFiles("WoWCombatLog*.txt"))
            {
                if (file.Length > 0) found.Add(file);
            }
        }
        catch
        {
            // Ein gesperrter oder gerade verschobener Ordner darf den Installer
            // nicht anhalten - dann gibt es eben nichts anzubieten.
            return found;
        }

        found.Sort((left, right) => right.LastWriteTimeUtc.CompareTo(left.LastWriteTimeUtc));
        return found;
    }

    /// <summary>
    /// Der Logs-Ordner der Spielversion, zu der dieser AddOns-Ordner gehoert:
    /// ...\_anniversary_\Interface\AddOns wird zu ...\_anniversary_\Logs.
    /// </summary>
    public static DirectoryInfo? LogFolder(string addonsPath)
    {
        if (string.IsNullOrWhiteSpace(addonsPath)) return null;
        try
        {
            var addons = new DirectoryInfo(addonsPath);
            var flavour = addons.Parent?.Parent;
            if (flavour is null) return null;
            var logs = new DirectoryInfo(Path.Combine(flavour.FullName, "Logs"));
            return logs.Exists ? logs : null;
        }
        catch
        {
            return null;
        }
    }

    public static string Describe(FileInfo file)
    {
        var megabytes = file.Length / (1024.0 * 1024.0);
        return $"{file.Name} ({megabytes:0.#} MB, {file.LastWriteTime:dd.MM.yyyy HH:mm})";
    }
}
