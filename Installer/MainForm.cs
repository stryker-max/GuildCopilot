using System.Runtime.InteropServices;
using GuildCopilot.Installer.CombatLog;
using Microsoft.Win32;

namespace GuildCopilot.Installer;

/// <summary>
/// Hauptfenster: Kopfbereich, darunter Addon, Warcraft Logs und der
/// Offline-Import aus dem Combat Log in einem Stueck, ganz unten der gemeinsame
/// Verlauf. Bewusst ohne Reiter - ein TabControl setzt einen hellen
/// Systemrahmen ins dunkle Fenster.
/// </summary>
public sealed class MainForm : Form
{
    private const string AutostartKey = @"Software\Microsoft\Windows\CurrentVersion\Run";
    private const string AutostartName = "GuildCopilotInstaller";

    private readonly Settings _settings = Settings.Load();
    private LogsPanel? _logsPanel;
    private CombatLogPanel? _combatLogPanel;

    private readonly ComboBox _addonsPath = new();
    private readonly Label _statusLabel = new();
    // "Nach Updates suchen" ist der Knopf, den man im Normalfall drueckt - er
    // steht deshalb vorn und ist hervorgehoben. Neu installieren braucht man
    // selten, also tritt es farblich zurueck.
    private readonly Button _installButton = Theme.MakeButton("Installieren", 230, primary: false);
    private readonly Button _removeButton = Theme.MakeButton("Entfernen", 160, primary: false);
    private readonly Button _checkButton = Theme.MakeButton("Nach Updates suchen", 200, primary: true);
    private readonly CheckBox _autoStart = new();
    private readonly TextBox _log = Theme.MakeLogBox();

    private string _availableVersion = string.Empty;

    /// <summary>
    /// Ob im Repository eine echte neuere Addon-Fassung liegt. Nur dann darf
    /// "Nach Updates suchen" von selbst installieren - eine Rueckstufung auf
    /// eine aeltere Fassung bleibt eine bewusste Entscheidung von Hand.
    /// </summary>
    private bool _updateAvailable;

    public MainForm()
    {
        Text = "Guild Copilot Installer";
        BackColor = Theme.Background;
        ForeColor = Theme.Text;
        Font = new Font("Segoe UI", 9.75f);
        ClientSize = new Size(960, 780);
        MinimumSize = new Size(860, 700);
        StartPosition = FormStartPosition.CenterScreen;

        var logo = LoadLogo();
        if (logo is Bitmap bitmap)
        {
            var handle = bitmap.GetHicon();
            using var temporary = Icon.FromHandle(handle);
            Icon = (Icon)temporary.Clone();
            DestroyIcon(handle);
        }

        Controls.Add(BuildLayout(logo));

        Load += async (_, _) => await InitializeAsync();
        FormClosing += (_, _) => Persist();
    }

    // -----------------------------------------------------------------
    // Aufbau
    // -----------------------------------------------------------------

    private Control BuildLayout(Image? logo)
    {
        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 3,
            BackColor = Theme.Background,
        };
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        // Bewusst ohne Reiter: ein TabControl zeichnet seinen Rahmen in den
        // Systemfarben und setzt damit einen hellen Balken mitten ins dunkle
        // Fenster. Beide Bereiche stehen deshalb untereinander in einem Stueck.
        var content = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink,
            ColumnCount = 1,
            BackColor = Theme.Background,
        };
        content.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        content.Controls.Add(BuildControls());
        content.Controls.Add(Theme.Separator());

        _logsPanel = new LogsPanel(_settings, Log);
        content.Controls.Add(_logsPanel);
        content.Controls.Add(Theme.Separator());

        // Der Offline-Import gehoert unter Warcraft Logs: beides erzeugt einen
        // Importcode fuer dasselbe Feld im Addon. Er braucht nur den
        // AddOns-Pfad, weil die Protokolldateien daneben liegen - und zwar bei
        // jedem Wechsel neu, deshalb eine Funktion statt eines Wertes.
        _combatLogPanel = new CombatLogPanel(SelectedPath, Log);
        content.Controls.Add(_combatLogPanel);

        root.Controls.Add(BuildHeader(logo), 0, 0);
        root.Controls.Add(content, 0, 1);
        root.Controls.Add(BuildLogPanel(), 0, 2);
        return root;
    }

    /// <summary>
    /// Feste Pixelpositionen halten hier nicht: bei skalierter Anzeige werden
    /// die Beschriftungen hoeher und die Unterzeile wird am unteren Rand des
    /// Kopfbereich abgeschnitten. Deshalb waechst er mit seinem Inhalt.
    /// </summary>
    private static Control BuildHeader(Image? logo)
    {
        var header = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            BackColor = Theme.Panel,
            ColumnCount = 2,
            RowCount = 1,
            Padding = new Padding(20, 12, 20, 12),
        };
        header.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        header.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        if (logo is not null)
        {
            header.Controls.Add(new PictureBox
            {
                Image = logo,
                SizeMode = PictureBoxSizeMode.Zoom,
                Size = new Size(62, 62),
                BackColor = Color.Transparent,
                Margin = new Padding(0, 0, 14, 0),
                Anchor = AnchorStyles.Left,
            }, 0, 0);
        }

        var text = new FlowLayoutPanel
        {
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink,
            Anchor = AnchorStyles.Left,
            BackColor = Color.Transparent,
        };
        text.Controls.Add(new Label
        {
            Text = "Guild Copilot",
            ForeColor = Theme.Accent,
            Font = new Font("Segoe UI", 20f, FontStyle.Bold),
            AutoSize = true,
            Margin = new Padding(0),
        });
        text.Controls.Add(new Label
        {
            Text = "Installiert und aktualisiert automatisch  ·  Guild Copilot powered by Stryker",
            ForeColor = Theme.Muted,
            AutoSize = true,
            Margin = new Padding(3, 2, 0, 0),
        });
        header.Controls.Add(text, 1, 0);
        header.Controls.Add(new Panel { Dock = DockStyle.Bottom, Height = 2, BackColor = Theme.Accent });
        return header;
    }

    private Control BuildControls()
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink,
            ColumnCount = 1,
            Padding = new Padding(22, 12, 22, 4),
            BackColor = Theme.Background,
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var caption = Theme.Caption("AddOns-Ordner");
        caption.Margin = new Padding(0, 0, 0, 4);
        panel.Controls.Add(caption);

        var pathRow = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            AutoSize = true,
            ColumnCount = 2,
            RowCount = 1,
            Margin = new Padding(0, 0, 0, 10),
        };
        pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));

        _addonsPath.Dock = DockStyle.Fill;
        _addonsPath.DropDownStyle = ComboBoxStyle.DropDown;
        _addonsPath.FlatStyle = FlatStyle.Flat;
        _addonsPath.BackColor = Theme.Input;
        _addonsPath.ForeColor = Theme.Text;
        _addonsPath.Font = new Font("Segoe UI", 10f);
        _addonsPath.SelectedIndexChanged += async (_, _) => await RefreshStatusAsync(checkRemote: false);
        pathRow.Controls.Add(_addonsPath, 0, 0);

        var browse = Theme.MakeButton("Durchsuchen", 170, primary: false);
        browse.Margin = new Padding(12, 0, 0, 0);
        browse.Click += (_, _) => BrowseForFolder();
        pathRow.Controls.Add(browse, 1, 0);
        panel.Controls.Add(pathRow);

        _statusLabel.AutoSize = true;
        _statusLabel.Font = new Font("Segoe UI", 11f, FontStyle.Bold);
        _statusLabel.Margin = new Padding(0, 2, 0, 12);
        panel.Controls.Add(_statusLabel);

        _installButton.Click += async (_, _) => await InstallAsync();
        _removeButton.Click += (_, _) => Remove();
        _checkButton.Click += async (_, _) => await CheckForUpdatesAsync();
        panel.Controls.Add(Theme.ButtonRow(_checkButton, _removeButton, _installButton));

        var switches = new FlowLayoutPanel { AutoSize = true, WrapContents = false, Margin = new Padding(0, 0, 0, 4) };
        _autoStart.Text = "Mit Windows starten";
        _autoStart.AutoSize = true;
        _autoStart.ForeColor = Theme.Text;
        _autoStart.Margin = new Padding(40, 0, 0, 0);
        _autoStart.CheckedChanged += (_, _) => ApplyAutostart();
        switches.Controls.Add(_autoStart);
        panel.Controls.Add(switches);

        return panel;
    }

    private Control BuildLogPanel()
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 2,
            Padding = new Padding(22, 0, 22, 14),
            BackColor = Theme.Background,
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        panel.Controls.Add(Theme.Caption("Verlauf"), 0, 0);
        _log.Dock = DockStyle.Fill;
        _log.Margin = new Padding(0, 4, 0, 0);
        panel.Controls.Add(_log, 0, 1);
        return panel;
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
        void Append() => _log.AppendText($"{DateTime.Now:HH:mm:ss}  {message}{Environment.NewLine}");
        if (_log.InvokeRequired) _log.BeginInvoke(Append);
        else Append();
    }

    private async Task InitializeAsync()
    {
        SelfUpdate.CleanUp();

        var found = GameFinder.FindAddonFolders();
        foreach (var folder in found) _addonsPath.Items.Add(folder);

        var remembered = _settings.AddonsPath;
        if (remembered.Length > 0 && !found.Contains(remembered, StringComparer.OrdinalIgnoreCase))
        {
            _addonsPath.Items.Insert(0, remembered);
        }
        if (remembered.Length > 0)
        {
            _addonsPath.SelectedItem = remembered;
            Log("Zuletzt genutzter Ordner wiederhergestellt.");
        }
        else if (_addonsPath.Items.Count > 0)
        {
            _addonsPath.SelectedIndex = 0;
        }
        Log($"{found.Count} Spielversion(en) erkannt.  Installer {SelfUpdate.CurrentVersion} (eigene Zählung, unabhängig vom Addon).");

        _autoStart.Checked = IsAutostartEnabled();

        await RefreshStatusAsync(checkRemote: true);

        // Beim Öffnen wird immer aktualisiert. Das stand frueher als Haken zur
        // Wahl - aber wer den Installer oeffnet, will einen aktuellen Stand;
        // eine Option dafuer war nur eine Gelegenheit, veraltet zu bleiben.
        if (await UpdateSelfAsync()) return;

        // Dieselbe Entscheidung wie beim Knopf "Nach Updates suchen": Ob eine
        // echte neuere Fassung vorliegt, hat RefreshStatusAsync oben schon
        // festgestellt. Das hier vorher doppelt zu berechnen hiess, dass zwei
        // Stellen dieselbe Frage beantworten - und irgendwann verschieden.
        if (_updateAvailable)
        {
            Log("Automatische Aktualisierung ist aktiv.");
            await InstallAsync();
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

    /// <summary>
    /// "Nach Updates suchen" prueft beides: das Addon und den Installer selbst.
    /// </summary>
    private async Task CheckForUpdatesAsync()
    {
        await RefreshStatusAsync(checkRemote: true);

        // Gefundenes Addon-Update wird sofort eingespielt: Wer auf "Nach
        // Updates suchen" drueckt, will es haben - eine zweite Rueckfrage
        // waere nur ein weiterer Klick auf dem Weg zum selben Ziel.
        if (_updateAvailable)
        {
            Log($"Neue Version {_availableVersion} gefunden – wird direkt installiert.");
            await InstallAsync();
        }

        await UpdateSelfAsync();
    }

    private async Task<bool> UpdateSelfAsync()
    {
        try
        {
            var updated = await SelfUpdate.UpdateAsync(new Progress<string>(Log));
            if (updated)
            {
                // Die neue Fassung läuft bereits. Die alte muss ihr Fenster
                // schließen, damit die beim Update angelegte .old-Datei beim
                // nächsten Start tatsächlich entfernt werden kann.
                BeginInvoke(Close);
            }
            return updated;
        }
        catch (Exception error)
        {
            Log($"Selbstaktualisierung fehlgeschlagen: {error.Message}");
            return false;
        }
    }

    private async Task RefreshStatusAsync(bool checkRemote)
    {
        var path = SelectedPath();
        var installed = path.Length > 0 ? GameFinder.ReadInstalledVersion(path) : null;

        // Die Protokolldateien gehoeren zur gewaehlten Spielversion. Wechselt
        // der Pfad, gilt ein anderer Logs-Ordner.
        _combatLogPanel?.Reload(announce: false);

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
        _updateAvailable = false;
        if (installed is null)
        {
            SetStatus($"Nicht installiert  –  verfügbar: {Display(_availableVersion)}", Theme.Muted);
            _installButton.Text = _availableVersion.Length > 0 ? $"{_availableVersion} installieren" : "Installieren";
            _removeButton.Enabled = false;
        }
        else if (_availableVersion.Length == 0)
        {
            SetStatus($"Installiert: {installed}  –  verfügbare Version unbekannt", Theme.Muted);
            _installButton.Text = "Neu installieren";
            _removeButton.Enabled = true;
        }
        else if (comparison < 0)
        {
            SetStatus($"Veraltet  –  installiert: {installed}   verfügbar: {_availableVersion}", Theme.Danger);
            _installButton.Text = $"Auf {_availableVersion} aktualisieren";
            _removeButton.Enabled = true;
            // Nur hier: Eine echte neuere Fassung. Der Rueckstufungsfall unten
            // bleibt bewusst von Hand.
            _updateAvailable = true;
        }
        else if (comparison > 0)
        {
            SetStatus($"Neuer als GitHub  –  installiert: {installed}   dort: {_availableVersion}", Theme.Muted);
            _installButton.Text = $"Auf {_availableVersion} zurücksetzen";
            _removeButton.Enabled = true;
        }
        else
        {
            SetStatus($"Aktuell  –  Version {installed}", Theme.Success);
            _installButton.Text = "Neu installieren";
            _removeButton.Enabled = true;
        }
    }

    private void SetStatus(string text, Color color)
    {
        _statusLabel.Text = text;
        _statusLabel.ForeColor = color;
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
            _settings.Save();
            await RefreshStatusAsync(checkRemote: false);
            Log("Fertig. In WoW /reload eingeben oder das Spiel neu starten.");
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

    private void SetBusy(bool busy)
    {
        _installButton.Enabled = !busy;
        _checkButton.Enabled = !busy;
        _removeButton.Enabled = !busy && GameFinder.ReadInstalledVersion(SelectedPath()) is not null;
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
            if (_autoStart.Checked)
            {
                using var key = Registry.CurrentUser.CreateSubKey(AutostartKey, writable: true);
                var exe = Environment.ProcessPath;
                if (key is not null && exe is not null) key.SetValue(AutostartName, $"\"{exe}\"");
            }
            else
            {
                using var key = Registry.CurrentUser.OpenSubKey(AutostartKey, writable: true);
                key?.DeleteValue(AutostartName, throwOnMissingValue: false);
            }
        }
        catch (Exception error)
        {
            Log($"Autostart ließ sich nicht ändern: {error.Message}");
        }
    }

    private void Persist()
    {
        _settings.AddonsPath = SelectedPath();
        _settings.Save();
        _logsPanel?.Persist();
    }
}
