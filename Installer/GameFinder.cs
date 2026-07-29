namespace GuildCopilot.Installer;

/// <summary>
/// Findet die AddOns-Ordner der installierten Spielversionen. Guild Copilot
/// ist fuer TBC Classic Anniversary (_anniversary_) gedacht, die uebrigen
/// Varianten werden trotzdem angeboten - wer zwei Installationen hat, soll
/// selbst waehlen koennen statt zu raten.
/// </summary>
public static class GameFinder
{
    private static readonly string[] Flavours =
    {
        "_anniversary_", "_classic_era_", "_classic_", "_retail_", "_ptr_",
    };

    public static List<string> FindAddonFolders()
    {
        var found = new List<string>();

        foreach (var root in CandidateRoots())
        {
            foreach (var flavour in Flavours)
            {
                var addons = Path.Combine(root, flavour, "Interface", "AddOns");
                if (Directory.Exists(addons) && !found.Contains(addons, StringComparer.OrdinalIgnoreCase))
                {
                    found.Add(addons);
                }
            }
        }

        // Anniversary zuerst: das ist die Version, fuer die das Addon gebaut ist.
        found.Sort((left, right) =>
        {
            var leftScore = left.Contains("_anniversary_", StringComparison.OrdinalIgnoreCase) ? 0 : 1;
            var rightScore = right.Contains("_anniversary_", StringComparison.OrdinalIgnoreCase) ? 0 : 1;
            return leftScore != rightScore
                ? leftScore.CompareTo(rightScore)
                : string.Compare(left, right, StringComparison.OrdinalIgnoreCase);
        });
        return found;
    }

    private static IEnumerable<string> CandidateRoots()
    {
        var names = new[] { "World of Warcraft", "Games\\World of Warcraft", "Blizzard\\World of Warcraft" };

        var programFiles = new[]
        {
            Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86),
            Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),
        };

        foreach (var baseFolder in programFiles)
        {
            if (string.IsNullOrEmpty(baseFolder)) continue;
            foreach (var name in names)
            {
                yield return Path.Combine(baseFolder, name);
            }
        }

        // Viele Installationen liegen nicht unter Programme, sondern direkt auf
        // einer zweiten Platte. Nur vorhandene, feste Laufwerke werden angesehen.
        foreach (var drive in DriveInfo.GetDrives())
        {
            if (!drive.IsReady || drive.DriveType != DriveType.Fixed) continue;
            foreach (var name in names)
            {
                yield return Path.Combine(drive.RootDirectory.FullName, name);
            }
        }
    }

    /// <summary>
    /// Liest "## Version:" aus einer GuildCopilot.toc. Fehlt die Datei, ist das
    /// Addon dort nicht installiert.
    /// </summary>
    public static string? ReadInstalledVersion(string addonsPath)
    {
        try
        {
            var toc = Path.Combine(addonsPath, "GuildCopilot", "GuildCopilot.toc");
            return File.Exists(toc) ? AddonSource.ParseVersion(File.ReadAllText(toc)) : null;
        }
        catch
        {
            return null;
        }
    }
}
