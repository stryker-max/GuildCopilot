using System.Diagnostics;
using System.Net.Http.Headers;
using System.Reflection;

namespace GuildCopilot.Installer;

/// <summary>
/// Der Installer haelt sich selbst aktuell. Die fertige .exe und eine
/// Versionsdatei liegen im Repository unter Installer/dist - bewusst
/// ausserhalb des Ordners GuildCopilot, damit nichts davon im Addon landet.
///
/// Eine laufende .exe kann sich nicht selbst ueberschreiben. Deshalb wird die
/// neue Fassung daneben abgelegt, die alte umbenannt und das Programm neu
/// gestartet; beim naechsten Start wird die umbenannte Datei entfernt.
/// </summary>
public static class SelfUpdate
{
    private const string VersionPath = "Installer/dist/version.txt";
    private const string ExecutablePath = "Installer/dist/GuildCopilot-Installer.exe";

    private static readonly HttpClient Http = CreateClient();

    private static HttpClient CreateClient()
    {
        var client = new HttpClient { Timeout = TimeSpan.FromMinutes(2) };
        client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("GuildCopilot-Installer", "1.0"));
        return client;
    }

    public static string CurrentVersion =>
        Assembly.GetExecutingAssembly().GetName().Version is { } version
            ? $"{version.Major}.{version.Minor}.{version.Build}"
            : "0.0.0";

    /// <summary>
    /// Raeumt die beim letzten Update umbenannte Fassung weg. Wird beim Start
    /// aufgerufen und darf niemals stoeren.
    /// </summary>
    public static void CleanUp()
    {
        try
        {
            var current = Environment.ProcessPath;
            if (current is null) return;
            var stale = current + ".old";
            if (File.Exists(stale)) File.Delete(stale);
        }
        catch
        {
            // Eine noch gesperrte Datei wird beim naechsten Start entfernt.
        }
    }

    public static async Task<string?> GetAvailableVersionAsync(CancellationToken token = default)
    {
        var url = $"https://api.github.com/repos/{AddonSource.Owner}/{AddonSource.Repo}/contents/{VersionPath}"
                + $"?ref={AddonSource.Branch}";
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github.raw"));
        request.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true };

        using var response = await Http.SendAsync(request, token);
        if (!response.IsSuccessStatusCode)
        {
            // Solange noch keine Fassung veroeffentlicht wurde, ist das kein
            // Fehler - es gibt schlicht nichts Neueres.
            return null;
        }
        var text = (await response.Content.ReadAsStringAsync(token)).Trim();
        return text.Length == 0 ? null : text;
    }

    /// <summary>
    /// Laedt die neue Fassung, tauscht sie ein und startet neu. Gibt false
    /// zurueck, wenn nichts zu tun war.
    /// </summary>
    public static async Task<bool> UpdateAsync(IProgress<string> log, CancellationToken token = default)
    {
        var available = await GetAvailableVersionAsync(token);
        if (available is null)
        {
            log.Report("Für den Installer liegt keine veröffentlichte Fassung vor.");
            return false;
        }
        if (AddonSource.CompareVersions(CurrentVersion, available) >= 0)
        {
            log.Report($"Installer ist aktuell ({CurrentVersion}).");
            return false;
        }

        var current = Environment.ProcessPath;
        if (current is null || !current.EndsWith(".exe", StringComparison.OrdinalIgnoreCase))
        {
            log.Report("Selbstaktualisierung geht nur aus der fertigen .exe heraus.");
            return false;
        }

        log.Report($"Neue Installer-Fassung {available} wird geladen …");
        var url = $"https://api.github.com/repos/{AddonSource.Owner}/{AddonSource.Repo}/contents/{ExecutablePath}"
                + $"?ref={AddonSource.Branch}";
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github.raw"));
        request.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true };

        using var response = await Http.SendAsync(request, token);
        response.EnsureSuccessStatusCode();

        var incoming = current + ".new";
        await using (var stream = await response.Content.ReadAsStreamAsync(token))
        await using (var file = File.Create(incoming))
        {
            await stream.CopyToAsync(file, token);
        }

        if (new FileInfo(incoming).Length < 100_000)
        {
            File.Delete(incoming);
            throw new InvalidOperationException("Die heruntergeladene Datei ist zu klein - Download unvollständig.");
        }

        var stale = current + ".old";
        if (File.Exists(stale)) File.Delete(stale);
        File.Move(current, stale);
        File.Move(incoming, current);

        log.Report($"Installer auf {available} aktualisiert, Neustart …");
        Process.Start(new ProcessStartInfo(current) { UseShellExecute = true });
        return true;
    }
}
