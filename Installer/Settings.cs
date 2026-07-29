using System.Runtime.InteropServices;
using System.Text;

namespace GuildCopilot.Installer;

/// <summary>
/// Einstellungen liegen wie bisher in %AppData%\GuildCopilotInstaller\settings.ini.
/// Die vorhandene Datei der alten Fassung wird weiterverwendet, damit der einmal
/// gewaehlte AddOns-Pfad erhalten bleibt.
/// </summary>
public sealed class Settings
{
    private static readonly string Folder = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "GuildCopilotInstaller");

    private static readonly string File = Path.Combine(Folder, "settings.ini");

    private readonly Dictionary<string, string> _values = new(StringComparer.OrdinalIgnoreCase);

    public string AddonsPath
    {
        get => Get("path");
        set => Set("path", value);
    }

    public string SourcePath
    {
        get => Get("source");
        set => Set("source", value);
    }

    public string ClientId
    {
        get => Get("wcl_client_id");
        set => Set("wcl_client_id", value);
    }

    public string LogsUrl
    {
        get => Get("wcl_url");
        set => Set("wcl_url", value);
    }

    /// <summary>Von der alten Fassung uebernommener Gildenlink, falls vorhanden.</summary>
    public string GuildUrl => Get("guild_url");

    public int ReportCount
    {
        get => int.TryParse(Get("wcl_reports"), out var value) ? Math.Clamp(value, 1, 12) : 1;
        set => Set("wcl_reports", Math.Clamp(value, 1, 12).ToString());
    }

    public bool RememberSecret
    {
        get => Get("wcl_remember") == "1";
        set => Set("wcl_remember", value ? "1" : "0");
    }

    public bool AutoUpdate
    {
        get => Get("autoupdate") == "1";
        set => Set("autoupdate", value ? "1" : "0");
    }

    /// <summary>
    /// Das Client Secret liegt nie im Klartext auf der Platte. Windows
    /// verschluesselt es an den angemeldeten Benutzer gebunden (DPAPI); eine
    /// kopierte Datei ist auf einem anderen Rechner wertlos.
    /// </summary>
    public string LoadSecret()
    {
        var stored = Get("wcl_secret");
        if (stored.Length == 0)
        {
            return string.Empty;
        }
        try
        {
            return Dpapi.Unprotect(Convert.FromBase64String(stored));
        }
        catch
        {
            // Auf einem anderen Benutzerkonto oder nach einem Profilwechsel
            // laesst sich der Wert nicht mehr entschluesseln. Dann gilt er
            // schlicht als nicht gespeichert.
            return string.Empty;
        }
    }

    public void SaveSecret(string secret)
    {
        if (string.IsNullOrEmpty(secret))
        {
            Set("wcl_secret", string.Empty);
            return;
        }
        Set("wcl_secret", Convert.ToBase64String(Dpapi.Protect(secret)));
    }

    private string Get(string key) => _values.TryGetValue(key, out var value) ? value : string.Empty;

    private void Set(string key, string value) => _values[key] = value ?? string.Empty;

    public static Settings Load()
    {
        var settings = new Settings();
        try
        {
            if (!System.IO.File.Exists(File))
            {
                return settings;
            }
            foreach (var line in System.IO.File.ReadAllLines(File, Encoding.UTF8))
            {
                var separator = line.IndexOf('=');
                if (separator <= 0)
                {
                    continue;
                }
                settings._values[line[..separator].Trim()] = line[(separator + 1)..].Trim();
            }
        }
        catch
        {
            // Eine unlesbare Einstellungsdatei darf den Start nicht verhindern.
        }
        return settings;
    }

    public void Save()
    {
        try
        {
            Directory.CreateDirectory(Folder);
            var builder = new StringBuilder();
            foreach (var pair in _values)
            {
                builder.Append(pair.Key).Append('=').AppendLine(pair.Value);
            }
            System.IO.File.WriteAllText(File, builder.ToString(), Encoding.UTF8);
        }
        catch
        {
            // Nicht speichern zu koennen ist aergerlich, aber kein Grund
            // abzubrechen - der Import funktioniert trotzdem.
        }
    }
}

/// <summary>
/// Windows-eigene Verschluesselung. Direkt angebunden, damit der Installer
/// ohne zusaetzliches NuGet-Paket auskommt.
/// </summary>
internal static class Dpapi
{
    [StructLayout(LayoutKind.Sequential)]
    private struct DataBlob
    {
        public int cbData;
        public IntPtr pbData;
    }

    [DllImport("crypt32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    private static extern bool CryptProtectData(
        ref DataBlob input, string? description, IntPtr entropy, IntPtr reserved,
        IntPtr prompt, int flags, ref DataBlob output);

    [DllImport("crypt32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    private static extern bool CryptUnprotectData(
        ref DataBlob input, IntPtr description, IntPtr entropy, IntPtr reserved,
        IntPtr prompt, int flags, ref DataBlob output);

    [DllImport("kernel32.dll")]
    private static extern IntPtr LocalFree(IntPtr handle);

    private const int CryptprotectUiForbidden = 0x1;

    public static byte[] Protect(string plainText)
    {
        var bytes = Encoding.UTF8.GetBytes(plainText);
        return Run(bytes, protect: true);
    }

    public static string Unprotect(byte[] encrypted)
    {
        return Encoding.UTF8.GetString(Run(encrypted, protect: false));
    }

    private static byte[] Run(byte[] data, bool protect)
    {
        var input = new DataBlob();
        var output = new DataBlob();
        try
        {
            input.cbData = data.Length;
            input.pbData = Marshal.AllocHGlobal(data.Length);
            Marshal.Copy(data, 0, input.pbData, data.Length);

            var ok = protect
                ? CryptProtectData(ref input, "Guild Copilot", IntPtr.Zero, IntPtr.Zero,
                    IntPtr.Zero, CryptprotectUiForbidden, ref output)
                : CryptUnprotectData(ref input, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero,
                    IntPtr.Zero, CryptprotectUiForbidden, ref output);
            if (!ok)
            {
                throw new InvalidOperationException("Windows konnte den Wert nicht verarbeiten.");
            }

            var result = new byte[output.cbData];
            Marshal.Copy(output.pbData, result, 0, output.cbData);
            return result;
        }
        finally
        {
            if (input.pbData != IntPtr.Zero) Marshal.FreeHGlobal(input.pbData);
            if (output.pbData != IntPtr.Zero) LocalFree(output.pbData);
        }
    }
}
