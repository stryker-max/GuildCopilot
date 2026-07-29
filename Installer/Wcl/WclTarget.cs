using System.Text.RegularExpressions;

namespace GuildCopilot.Installer.Wcl;

public enum TargetKind { Guild, Report }

/// <summary>
/// Aus einem Link wird entweder eine Gilde oder ein einzelner Report.
/// </summary>
public sealed class WclTarget
{
    public TargetKind Kind { get; private init; }
    public string ReportCode { get; private init; } = string.Empty;
    public string Region { get; private init; } = string.Empty;
    public string ServerSlug { get; private init; } = string.Empty;
    public int? GuildId { get; private init; }
    public IReadOnlyList<string> GuildNames { get; private init; } = Array.Empty<string>();
    public IReadOnlyList<string> Origins { get; private init; } = Array.Empty<string>();

    /// <summary>
    /// Warcraft Logs betreibt je Spielvariante eine eigene Seite mit eigener
    /// API. Der Link nennt die richtige, aber wenn dort nichts gefunden wird,
    /// sind die anderen einen Versuch wert - das ist der haeufigste Grund fuer
    /// "keine Reports gefunden".
    /// </summary>
    public static List<string> DefaultOrigins(string hostname)
    {
        var origins = new List<string>();
        void Push(string origin)
        {
            if (!origins.Contains(origin, StringComparer.OrdinalIgnoreCase)) origins.Add(origin);
        }

        var host = hostname ?? string.Empty;
        if (host.Contains("fresh.", StringComparison.OrdinalIgnoreCase)) Push("https://fresh.warcraftlogs.com");
        if (host.Contains("classic.", StringComparison.OrdinalIgnoreCase)) Push("https://classic.warcraftlogs.com");
        if (host.Contains("sod.", StringComparison.OrdinalIgnoreCase)) Push("https://sod.warcraftlogs.com");
        if (host.Contains("vanilla.", StringComparison.OrdinalIgnoreCase)) Push("https://vanilla.warcraftlogs.com");
        Push("https://fresh.warcraftlogs.com");
        Push("https://classic.warcraftlogs.com");
        Push("https://www.warcraftlogs.com");
        return origins;
    }

    public static WclTarget Parse(string input)
    {
        var raw = (input ?? string.Empty).Trim();
        if (raw.Length == 0)
        {
            throw new ArgumentException("Bitte einen Warcraft-Logs-Link oder einen Reportcode angeben.");
        }

        if (!raw.Contains('/') && Regex.IsMatch(raw, "^[a-zA-Z0-9]{10,}$"))
        {
            return new WclTarget { Kind = TargetKind.Report, ReportCode = raw, Origins = DefaultOrigins(string.Empty) };
        }

        var candidate = Regex.IsMatch(raw, "^https?://", RegexOptions.IgnoreCase)
            ? raw
            : "https://" + raw;
        if (!Uri.TryCreate(candidate, UriKind.Absolute, out var url)
            || (url.Scheme != Uri.UriSchemeHttp && url.Scheme != Uri.UriSchemeHttps))
        {
            throw new ArgumentException("Der Warcraft-Logs-Link ist ungültig.");
        }
        if (!url.Host.Equals("warcraftlogs.com", StringComparison.OrdinalIgnoreCase)
            && !url.Host.EndsWith(".warcraftlogs.com", StringComparison.OrdinalIgnoreCase))
        {
            throw new ArgumentException("Der Link gehört nicht zu Warcraft Logs.");
        }
        var origins = DefaultOrigins(url.Host);

        var report = Regex.Match(url.AbsolutePath, @"^/reports/([a-zA-Z0-9]+)/?$");
        if (report.Success)
        {
            return new WclTarget { Kind = TargetKind.Report, ReportCode = report.Groups[1].Value, Origins = origins };
        }

        var guildId = Regex.Match(url.AbsolutePath, @"^/guild/id/(\d+)/?$");
        if (guildId.Success)
        {
            return new WclTarget { Kind = TargetKind.Guild, GuildId = int.Parse(guildId.Groups[1].Value), Origins = origins };
        }

        var guild = Regex.Match(url.AbsolutePath, @"^/guild/([^/]+)/([^/]+)/([^/]+)/?$");
        if (!guild.Success)
        {
            throw new ArgumentException("Der Link ist weder eine Warcraft-Logs-Gildenseite noch ein Report.");
        }

        // Der Gildenname steht in der URL nur als Slug ("die-waechter"); die API
        // erwartet den echten Namen. Deshalb mehrere Schreibweisen anbieten und
        // spaeter die erste nehmen, die Reports liefert.
        var decoded = Uri.UnescapeDataString(guild.Groups[3].Value.Replace("+", " "));
        var region = guild.Groups[1].Value.ToLowerInvariant();
        if (region is not ("eu" or "us" or "kr" or "tw" or "cn")
            || decoded.Length == 0
            || decoded.Any(character => character is '/' or '\\' || char.IsControl(character)))
        {
            throw new ArgumentException("Der Warcraft-Logs-Gildenlink enthält ungültige Angaben.");
        }
        var names = new List<string> { decoded };
        if (decoded.Contains('-')) names.Add(decoded.Replace('-', ' '));
        var titled = string.Join(' ', names[^1]
            .Split(' ')
            .Select(word => word.Length > 0 ? char.ToUpperInvariant(word[0]) + word[1..] : word));
        if (!names.Contains(titled)) names.Add(titled);

        return new WclTarget
        {
            Kind = TargetKind.Guild,
            Region = region,
            ServerSlug = guild.Groups[2].Value.ToLowerInvariant(),
            GuildNames = names,
            Origins = origins,
        };
    }
}
