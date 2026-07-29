using System.Runtime.InteropServices;
using GuildCopilot.Installer.Wcl;
using Microsoft.Win32;

namespace GuildCopilot.Installer;

public sealed class MainForm : Form
{
    private static readonly Color Background = Color.FromArgb(24, 28, 34);
    private static readonly Color Panel = Color.FromArgb(32, 38, 46);
    private static readonly Color Accent = Color.FromArgb(41, 182, 246);
    private static readonly Color TextColor = Color.FromArgb(228, 233, 240);
    private static readonly Color MutedColor = Color.FromArgb(145, 163, 184);
    private static readonly Color DangerColor = Color.FromArgb(232, 90, 90);
    private static readonly Color SuccessColor = Color.FromArgb(89, 230, 149);

    private const string AutostartKey = @"Software\Microsoft\Windows\CurrentVersion\Run";
    private const string AutostartName = "GuildCopilotInstaller";

    private readonly Settings _settings = Settings.Load();

    private readonly ComboBox _addonsPath = new();
    private readonly Label _statusLabel = new();
    private readonly Button _installButton = new();
    private readonly Button _removeButton = new();
    private readonly Button _checkButton = new();
    private readonly CheckBox _autoUpdate = new();
    private readonly CheckBox _autoStart = new();
    private readonly TextBox _log = new();

    private readonly TextBox _clientId = new();
    private readonly TextBox _clientSecret = new();
    private readonly CheckBox _rememberSecret = new();
    private readonly TextBox _logsUrl = new();
    private readonly NumericUpDown _reportCount = new();
    private readonly Button _importButton = new();
    private readonly Button _copyButton = new();
    private readonly Label _importStatus = new();

    private string _availableVersion = string.Empty;
    private string _importText = string.Empty;
    private bool _busy;

    public MainForm()
    {
        Text = "Guild Copilot Installer";
        BackColor = Background;
        ForeColor = TextColor;
        Font = new Font("Segoe UI", 9.75f);
        ClientSize = new Size(880, 720);
        MinimumSize = new Size(760, 620);
        StartPosition = FormStartPosition.CenterScreen;

        var logo = LoadLogo();
        if (logo is Bitmap bitmap)
        {
            var handle = bitmap.GetHicon();
            using var icon = Icon.FromHandle(handle);
            Icon = (Icon)icon.Clone();
            DestroyIcon(handle);
        }

        Controls.Add(BuildBody(logo));
        Controls.Add(BuildHeader(logo));

        Load += async (_, _) => await InitializeAsync();
        FormClosing += (_, _) => PersistSettings();
    }

    // -----------------------------------------------------------------
    // Aufbau
    // -----------------------------------------------------------------

    private Control BuildHeader(Image? logo)
    {
        var header = new Panel { Dock = DockStyle.Top, Height = 92, BackColor = Panel, Padding = new Padding(20, 14, 20, 14) };

        if (logo is not null)
        {
            header.Controls.Add(new PictureBox
            {
                Image = logo,
                SizeMode = PictureBoxSizeMode.Zoom,
                Bounds = new Rectangle(20, 14, 60, 60),
            });
        }

        header.Controls.Add(new Label
        {
            Text = "Guild Copilot",
            ForeColor = Accent,
            Font = new Font("Segoe UI", 20f, FontStyle.Bold),
            AutoSize = true,
            Location = new Point(94, 14),
        });
        header.Controls.Add(new Label
        {
            Text = $"Installiert und aktualisiert direkt aus GitHub – {AddonSource.Owner}/{AddonSource.Repo}",
            ForeColor = MutedColor,
            AutoSize = true,
            Location = new Point(97, 54),
        });
        header.Controls.Add(new Panel { Dock = DockStyle.Bottom, Height = 2, BackColor = Accent });
        return header;
    }

    private Control BuildBody(Image? logo)
    {
        var tabs = new TabControl { Dock = DockStyle.Fill, Padding = new Point(16, 6) };

        var addonTab = new TabPage("Addon") { BackColor = Background, Padding = new Padding(20) };
        addonTab.Controls.Add(BuildAddonPage());
        tabs.TabPages.Add(addonTab);

        var logsTab = new TabPage("Warcraft Logs") { BackColor = Background, Padding = new Padding(20) };
        logsTab.Controls.Add(BuildLogsPage());
        tabs.TabPages.Add(logsTab);

        var container = new Panel { Dock = DockStyle.Fill, Padding = new Padding(0) };
        container.Controls.Add(tabs);
        container.Controls.Add(BuildLogPanel());
        return container;
    }

    private Control BuildLogPanel()
    {
        var panel = new Panel { Dock = DockStyle.Bottom, Height = 210, Padding = new Padding(20, 8, 20, 16) };
        panel.Controls.Add(_log);

        _log.Dock = DockStyle.Fill;
        _log.Multiline = true;
        _log.ReadOnly = true;
        _log.ScrollBars = ScrollBars.Vertical;
        _log.BackColor = Color.FromArgb(18, 21, 26);
        _log.ForeColor = MutedColor;
        _log.BorderStyle = BorderStyle.FixedSingle;
        _log.Font = new Font("Consolas", 9f);

        var caption = new Label { Text = "Verlauf", Dock = DockStyle.Top, Height = 22, ForeColor = MutedColor };
        panel.Controls.Add(caption);
        caption.BringToFront();
        return panel;
    }

    private Control BuildAddonPage()
    {
        var layout = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
            AutoScroll = true,
        };

        layout.Controls.Add(Caption("AddOns-Ordner"));

        var pathRow = new FlowLayoutPanel { AutoSize = true, FlowDirection = FlowDirection.LeftToRight, WrapContents = false, Margin = new Padding(0, 0, 0, 10) };
        _addonsPath.Width = 610;
        _addonsPath.DropDownStyle = ComboBoxStyle.DropDown;
        _addonsPath.BackColor = Color.FromArgb(18, 21, 26);
        _addonsPath.ForeColor = TextColor;
        _addonsPath.FlatStyle = FlatStyle.Flat;
        _addonsPath.SelectedIndexChanged += async (_, _) => await RefreshStatusAsync(checkRemote: false);
        pathRow.Controls.Add(_addonsPath);

        var browse = MakeButton("Durchsuchen", 150, secondary: true);
        browse.Margin = new Padding(10, 0, 0, 0);
        browse.Click += (_, _) => BrowseForFolder();
        pathRow.Controls.Add(browse);
        layout.Controls.Add(pathRow);

        _statusLabel.AutoSize = true;
        _statusLabel.Font = new Font("Segoe UI", 10.5f, FontStyle.Bold);
        _statusLabel.Margin = new Padding(0, 0, 0, 12);
        layout.Controls.Add(_statusLabel);

        var buttonRow = new FlowLayoutPanel { AutoSize = true, FlowDirection = FlowDirection.LeftToRight, WrapContents = false, Margin = new Padding(0, 0, 0, 14) };
        ConfigureButton(_installButton, "Installieren", 230, secondary: false);
        _installButton.Click += async (_, _) => await InstallAsync();
        buttonRow.Controls.Add(_installButton);

        ConfigureButton(_removeButton, "Entfernen", 160, secondary: true);
        _removeButton.Margin = new Padding(10, 0, 0, 0);
        _removeButton.Click += (_, _) => Remove();
        buttonRow.Controls.Add(_removeButton);

        ConfigureButton(_checkButton, "Nach Updates suchen", 200, secondary: true);
        _checkButton.Margin = new Padding(10, 0, 0, 0);
        _checkButton.Click += async (_, _) => await RefreshStatusAsync(checkRemote: true);
        buttonRow.Controls.Add(_checkButton);
        layout.Controls.Add(buttonRow);

        _autoUpdate.Text = "Beim Öffnen automatisch aktualisieren";
        _autoUpdate.AutoSize = true;
        _autoUpdate.ForeColor = TextColor;
        layout.Controls.Add(_autoUpdate);

        _autoStart.Text = "Mit Windows starten";
        _autoStart.AutoSize = true;
        _autoStart.ForeColor = TextColor;
        _autoStart.CheckedChanged += (_, _) => ApplyAutostart();
        layout.Controls.Add(_autoStart);

        return layout;
    }

    private Control BuildLogsPage()
    {
        var layout = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
            AutoScroll = true,
        };

        layout.Controls.Add(new Label
        {
            Text = "Ein WoW-Addon darf nicht ins Netz. Dieser Bereich liest öffentliche Reports über die\n"
                 + "offizielle Warcraft-Logs-API und legt den Importcode in die Zwischenablage.",
            ForeColor = MutedColor,
            AutoSize = true,
            Margin = new Padding(0, 0, 0, 14),
        });

        layout.Controls.Add(Caption("Client ID"));
        ConfigureInput(_clientId, 610);
        layout.Controls.Add(_clientId);

        layout.Controls.Add(Caption("Client Secret"));
        ConfigureInput(_clientSecret, 610);
        _clientSecret.UseSystemPasswordChar = true;
        layout.Controls.Add(_clientSecret);

        _rememberSecret.Text = "Zugangsdaten merken (verschlüsselt für dieses Windows-Konto)";
        _rememberSecret.AutoSize = true;
        _rememberSecret.ForeColor = TextColor;
        _rememberSecret.Margin = new Padding(0, 4, 0, 12);
        layout.Controls.Add(_rememberSecret);

        layout.Controls.Add(Caption("Gilden- oder Reportlink"));
        ConfigureInput(_logsUrl, 610);
        layout.Controls.Add(_logsUrl);

        var countRow = new FlowLayoutPanel { AutoSize = true, FlowDirection = FlowDirection.LeftToRight, WrapContents = false, Margin = new Padding(0, 10, 0, 12) };
        countRow.Controls.Add(new Label { Text = "Reports:", ForeColor = MutedColor, AutoSize = true, Margin = new Padding(0, 6, 8, 0) });
        _reportCount.Minimum = 1;
        _reportCount.Maximum = 12;
        _reportCount.Width = 60;
        _reportCount.BackColor = Color.FromArgb(18, 21, 26);
        _reportCount.ForeColor = TextColor;
        countRow.Controls.Add(_reportCount);
        countRow.Controls.Add(new Label
        {
            Text = "Bei einem Reportlink zählt nur dieser eine.",
            ForeColor = MutedColor,
            AutoSize = true,
            Margin = new Padding(12, 6, 0, 0),
        });
        layout.Controls.Add(countRow);

        var actionRow = new FlowLayoutPanel { AutoSize = true, FlowDirection = FlowDirection.LeftToRight, WrapContents = false };
        ConfigureButton(_importButton, "Import erzeugen", 200, secondary: false);
        _importButton.Click += async (_, _) => await RunImportAsync();
        actionRow.Controls.Add(_importButton);

        ConfigureButton(_copyButton, "In Zwischenablage", 190, secondary: true);
        _copyButton.Margin = new Padding(10, 0, 0, 0);
        _copyButton.Enabled = false;
        _copyButton.Click += (_, _) => CopyImport();
        actionRow.Controls.Add(_copyButton);
        layout.Controls.Add(actionRow);

        _importStatus.AutoSize = true;
        _importStatus.MaximumSize = new Size(760, 0);
        _importStatus.Margin = new Padding(0, 12, 0, 0);
        _importStatus.ForeColor = MutedColor;
        layout.Controls.Add(_importStatus);

        return layout;
    }

    private static Label Caption(string text) => new()
    {
        Text = text,
        ForeColor = MutedColor,
        AutoSize = true,
        Margin = new Padding(0, 6, 0, 4),
    };

    private static void ConfigureInput(TextBox box, int width)
    {
        box.Width = width;
        box.BackColor = Color.FromArgb(18, 21, 26);
        box.ForeColor = TextColor;
        box.BorderStyle = BorderStyle.FixedSingle;
    }

    private Button MakeButton(string text, int width, bool secondary)
    {
        var button = new Button();
        ConfigureButton(button, text, width, secondary);
        return button;
    }

    private static void ConfigureButton(Button button, string text, int width, bool secondary)
    {
        button.Text = text;
        button.Width = width;
        button.Height = 40;
        button.FlatStyle = FlatStyle.Flat;
        button.FlatAppearance.BorderColor = secondary ? MutedColor : Accent;
        button.BackColor = secondary ? Panel : Accent;
        button.ForeColor = secondary ? TextColor : Color.Black;
        button.Font = new Font("Segoe UI", 10f, FontStyle.Bold);
        button.Margin = new Padding(0);
    }

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool DestroyIcon(IntPtr handle);

    private static Image? LoadLogo()
    {
        try
        {
            var name = typeof(MainForm).Assembly.GetManifestResourceNames()
                .FirstOrDefault(entry => entry.EndsWith("GuildCopilotLogo.png", StringComparison.OrdinalIgnoreCase));
            if (name is null) return null;
            using var stream = typeof(MainForm).Assembly.GetManifestResourceStream(name);
            return stream is null ? null : new Bitmap(Image.FromStream(stream), 128, 128);
        }
        catch
        {
            return null;
        }
    }

    // -----------------------------------------------------------------
    // Ablauf
    // -----------------------------------------------------------------

    private void Log(string message)
    {
        void Append()
        {
            _log.AppendText($"{DateTime.Now:HH:mm:ss}  {message}{Environment.NewLine}");
        }
        if (_log.InvokeRequired) _log.BeginInvoke(Append);
        else Append();
    }

    private async Task InitializeAsync()
    {
        var found = GameFinder.FindAddonFolders();
        foreach (var folder in found) _addonsPath.Items.Add(folder);

        var remembered = _settings.AddonsPath;
        if (remembered.Length > 0 && !found.Contains(remembered, StringComparer.OrdinalIgnoreCase))
        {
            _addonsPath.Items.Insert(0, remembered);
        }
        _addonsPath.SelectedItem = remembered.Length > 0 ? remembered : found.FirstOrDefault();
        if (_addonsPath.SelectedItem is null && _addonsPath.Items.Count > 0) _addonsPath.SelectedIndex = 0;
        Log($"{found.Count} Spielversion(en) automatisch erkannt.");

        _autoUpdate.Checked = _settings.AutoUpdate;
        _autoStart.Checked = IsAutostartEnabled();
        _clientId.Text = _settings.ClientId;
        _logsUrl.Text = _settings.LogsUrl;
        _reportCount.Value = _settings.ReportCount;
        _rememberSecret.Checked = _settings.RememberSecret;
        if (_settings.RememberSecret) _clientSecret.Text = _settings.LoadSecret();

        await RefreshStatusAsync(checkRemote: true);

        if (_autoUpdate.Checked && _availableVersion.Length > 0)
        {
            var installed = GameFinder.ReadInstalledVersion(SelectedPath());
            if (AddonSource.CompareVersions(installed, _availableVersion) < 0)
            {
                Log("Automatische Aktualisierung ist aktiv.");
                await InstallAsync();
            }
        }
    }

    private string SelectedPath() => (_addonsPath.Text ?? string.Empty).Trim();

    private void BrowseForFolder()
    {
        using var dialog = new FolderBrowserDialog
        {
            Description = "AddOns-Ordner der WoW-Installation wählen",
            UseDescriptionForTitle = true,
            SelectedPath = SelectedPath(),
        };
        if (dialog.ShowDialog(this) != DialogResult.OK) return;
        _addonsPath.Text = dialog.SelectedPath;
        _ = RefreshStatusAsync(checkRemote: false);
    }

    private async Task RefreshStatusAsync(bool checkRemote)
    {
        var path = SelectedPath();
        var installed = path.Length > 0 ? GameFinder.ReadInstalledVersion(path) : null;

        if (checkRemote)
        {
            try
            {
                _availableVersion = await AddonSource.GetAvailableVersionAsync();
                Log($"Verfügbare Version: {_availableVersion}");
            }
            catch (Exception error)
            {
                Log($"Versionsabfrage fehlgeschlagen: {error.Message}");
            }
        }

        // Verglichen wird der Stelle nach, nicht auf ungleich: eine aeltere
        // Fassung im Repository darf nie als Aktualisierung angeboten werden.
        var comparison = AddonSource.CompareVersions(installed, _availableVersion);
        if (installed is null)
        {
            _statusLabel.Text = $"Nicht installiert  –  verfügbar: {Display(_availableVersion)}";
            _statusLabel.ForeColor = MutedColor;
            _installButton.Text = _availableVersion.Length > 0 ? $"{_availableVersion} installieren" : "Installieren";
            _removeButton.Enabled = false;
        }
        else if (_availableVersion.Length == 0)
        {
            _statusLabel.Text = $"Installiert: {installed}  –  verfügbare Version unbekannt";
            _statusLabel.ForeColor = MutedColor;
            _installButton.Text = "Neu installieren";
            _removeButton.Enabled = true;
        }
        else if (comparison < 0)
        {
            _statusLabel.Text = $"Veraltet  –  installiert: {installed}   verfügbar: {_availableVersion}";
            _statusLabel.ForeColor = DangerColor;
            _installButton.Text = $"Auf {_availableVersion} aktualisieren";
            _removeButton.Enabled = true;
        }
        else if (comparison > 0)
        {
            _statusLabel.Text = $"Neuer als GitHub  –  installiert: {installed}   dort: {_availableVersion}";
            _statusLabel.ForeColor = MutedColor;
            _installButton.Text = $"Auf {_availableVersion} zurücksetzen";
            _removeButton.Enabled = true;
        }
        else
        {
            _statusLabel.Text = $"Aktuell  –  {installed}";
            _statusLabel.ForeColor = SuccessColor;
            _installButton.Text = "Neu installieren";
            _removeButton.Enabled = true;
        }
    }

    private static string Display(string value) => value.Length > 0 ? value : "unbekannt";

    private async Task InstallAsync()
    {
        var path = SelectedPath();
        if (path.Length == 0 || !Directory.Exists(path))
        {
            MessageBox.Show(this, "Bitte zuerst einen gültigen AddOns-Ordner wählen.", "Guild Copilot",
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        SetBusy(true);
        try
        {
            var progress = new Progress<string>(Log);
            await Task.Run(() => AddonSource.InstallAsync(path, progress));
            _settings.AddonsPath = path;
            await RefreshStatusAsync(checkRemote: false);
        }
        catch (Exception error)
        {
            Log($"Fehlgeschlagen: {error.Message}");
            MessageBox.Show(this, error.Message, "Installation fehlgeschlagen",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            SetBusy(false);
        }
    }

    private void Remove()
    {
        var path = SelectedPath();
        if (path.Length == 0) return;

        var answer = MessageBox.Show(this,
            $"Guild Copilot aus\n{path}\nentfernen?\n\nGespeicherte Einstellungen im WTF-Ordner bleiben erhalten.",
            "Entfernen", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
        if (answer != DialogResult.Yes) return;

        try
        {
            AddonSource.Uninstall(path, new Progress<string>(Log));
            _ = RefreshStatusAsync(checkRemote: false);
        }
        catch (Exception error)
        {
            Log($"Entfernen fehlgeschlagen: {error.Message}");
        }
    }

    private async Task RunImportAsync()
    {
        var clientId = _clientId.Text.Trim();
        var secret = _clientSecret.Text.Trim();
        var link = _logsUrl.Text.Trim();

        if (clientId.Length == 0 || secret.Length == 0)
        {
            _importStatus.ForeColor = DangerColor;
            _importStatus.Text = "Client ID und Client Secret werden gebraucht. Beides steht unter warcraftlogs.com/api/clients.";
            return;
        }
        if (link.Length == 0)
        {
            _importStatus.ForeColor = DangerColor;
            _importStatus.Text = "Bitte einen Gilden- oder Reportlink eintragen.";
            return;
        }

        SetBusy(true);
        _copyButton.Enabled = false;
        _importStatus.ForeColor = MutedColor;
        _importStatus.Text = "Läuft …";

        try
        {
            var importer = new WclImporter(new Progress<string>(Log));
            var result = await importer.RunAsync(clientId, secret, link, (int)_reportCount.Value, CancellationToken.None);

            _importText = result.Text;
            _copyButton.Enabled = true;
            SetClipboard(result.Text);

            _importStatus.ForeColor = SuccessColor;
            _importStatus.Text = $"{result.Profiles} Spieler und {result.Sessions} Raidauswertungen aus {result.Reports} Reports. "
                               + "Der Importcode liegt in der Zwischenablage – in WoW einfügen unter Guild Copilot → Warcraft Logs.";
            foreach (var warning in result.Warnings) Log($"Hinweis: {warning}");

            _settings.ClientId = clientId;
            _settings.LogsUrl = link;
            _settings.ReportCount = (int)_reportCount.Value;
            _settings.RememberSecret = _rememberSecret.Checked;
            _settings.SaveSecret(_rememberSecret.Checked ? secret : string.Empty);
            _settings.Save();
        }
        catch (Exception error)
        {
            Log($"Import fehlgeschlagen: {error.Message}");
            _importStatus.ForeColor = DangerColor;
            _importStatus.Text = error.Message;
        }
        finally
        {
            SetBusy(false);
        }
    }

    private void CopyImport()
    {
        if (_importText.Length == 0) return;
        SetClipboard(_importText);
        _importStatus.ForeColor = SuccessColor;
        _importStatus.Text = $"In die Zwischenablage kopiert ({DateTime.Now:HH:mm:ss}).";
    }

    private void SetClipboard(string text)
    {
        try
        {
            Clipboard.SetText(text);
        }
        catch (Exception error)
        {
            Log($"Zwischenablage nicht erreichbar: {error.Message}");
        }
    }

    private void SetBusy(bool busy)
    {
        _busy = busy;
        _installButton.Enabled = !busy;
        _removeButton.Enabled = !busy && GameFinder.ReadInstalledVersion(SelectedPath()) is not null;
        _checkButton.Enabled = !busy;
        _importButton.Enabled = !busy;
        Cursor = busy ? Cursors.WaitCursor : Cursors.Default;
    }

    private static bool IsAutostartEnabled()
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(AutostartKey);
            return key?.GetValue(AutostartName) is not null;
        }
        catch
        {
            return false;
        }
    }

    private void ApplyAutostart()
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(AutostartKey, writable: true);
            if (key is null) return;
            if (_autoStart.Checked)
            {
                var exe = Environment.ProcessPath;
                if (exe is not null) key.SetValue(AutostartName, $"\"{exe}\"");
            }
            else
            {
                key.DeleteValue(AutostartName, throwOnMissingValue: false);
            }
        }
        catch (Exception error)
        {
            Log($"Autostart ließ sich nicht ändern: {error.Message}");
        }
    }

    private void PersistSettings()
    {
        _settings.AddonsPath = SelectedPath();
        _settings.AutoUpdate = _autoUpdate.Checked;
        _settings.ClientId = _clientId.Text.Trim();
        _settings.LogsUrl = _logsUrl.Text.Trim();
        _settings.ReportCount = (int)_reportCount.Value;
        _settings.RememberSecret = _rememberSecret.Checked;
        _settings.SaveSecret(_rememberSecret.Checked ? _clientSecret.Text.Trim() : string.Empty);
        _settings.Save();
    }
}
