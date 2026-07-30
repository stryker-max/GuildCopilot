namespace GuildCopilot.Installer.CombatLog;

/// <summary>
/// Der Offline-Import als Abschnitt des Hauptfensters, gebaut wie der
/// Warcraft-Logs-Abschnitt: derselbe Verlauf, dieselbe Zwischenablage, dasselbe
/// Vorgehen in WoW.
///
/// Der Unterschied ist die Quelle. Warcraft Logs braucht einen Upload und
/// Zugangsdaten; hier liegt die Datei schon auf der Platte. Sie bleibt auch
/// dort - uebertragen wird nur die fertige Auswertung.
/// </summary>
public sealed class CombatLogPanel : UserControl
{
    private readonly Func<string> _addonsPath;
    private readonly Action<string> _log;

    private readonly ComboBox _files = new();
    private readonly Button _refresh = Theme.MakeButton("Dateien suchen", 170, primary: false);
    private readonly Button _run = Theme.MakeButton("Import erzeugen", 220, primary: true);
    private readonly Button _copy = Theme.MakeButton("Erneut kopieren", 190, primary: false);
    private readonly Label _status = new();

    private List<FileInfo> _found = new();
    private string _importText = string.Empty;

    public CombatLogPanel(Func<string> addonsPath, Action<string> log)
    {
        _addonsPath = addonsPath;
        _log = log;

        Dock = DockStyle.Top;
        AutoSize = true;
        AutoSizeMode = AutoSizeMode.GrowAndShrink;
        BackColor = Theme.Background;
        _copy.Enabled = false;
        _run.Enabled = false;

        Controls.Add(BuildBody());

        _refresh.Click += (_, _) => Reload(announce: true);
        _run.Click += async (_, _) => await RunAsync();
        _copy.Click += (_, _) => Copy(_importText, "Erneut in die Zwischenablage kopiert");

        Reload(announce: false);
    }

    private Control BuildBody()
    {
        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink,
            Padding = new Padding(22, 2, 22, 8),
            ColumnCount = 1,
            BackColor = Theme.Background,
        };
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var title = Theme.SectionTitle("Raidabend aus dem Combat Log");
        title.Margin = new Padding(0, 0, 0, 2);
        root.Controls.Add(title);

        root.Controls.Add(new Label
        {
            Text = "Wertet eine WoWCombatLog.txt aus – auch nachträglich, wenn niemand „Sitzung starten“ gedrückt hat."
                 + " Ohne Upload, ohne Zugangsdaten. Die Datei bleibt auf deinem Rechner.",
            ForeColor = Theme.Muted,
            AutoSize = true,
            MaximumSize = new Size(880, 0),
            Margin = new Padding(0, 0, 0, 10),
        });

        var fileRow = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            AutoSize = true,
            ColumnCount = 2,
            RowCount = 1,
            Margin = new Padding(0, 0, 0, 14),
        };
        fileRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        fileRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        _files.DropDownStyle = ComboBoxStyle.DropDownList;
        _files.Dock = DockStyle.Fill;
        _files.BackColor = Theme.Input;
        _files.ForeColor = Theme.Text;
        _files.FlatStyle = FlatStyle.Flat;
        _files.Font = new Font("Segoe UI", 10f);
        _files.Margin = new Padding(0, 3, 10, 3);
        fileRow.Controls.Add(_files, 0, 0);
        fileRow.Controls.Add(_refresh, 1, 0);
        root.Controls.Add(fileRow);

        root.Controls.Add(Theme.ButtonRow(_run, _copy));

        _status.AutoSize = true;
        _status.MaximumSize = new Size(880, 0);
        _status.ForeColor = Theme.Muted;
        root.Controls.Add(_status);

        return root;
    }

    /// <summary>
    /// Sucht die Protokolldateien neben dem gewaehlten AddOns-Ordner. Wird auch
    /// aufgerufen, wenn dort ein anderer Pfad eingestellt wird - die Logs
    /// gehoeren zur Spielversion, nicht zum Installer.
    /// </summary>
    public void Reload(bool announce)
    {
        var path = _addonsPath();
        _found = CombatLogFinder.Find(path);
        _files.Items.Clear();
        foreach (var file in _found) _files.Items.Add(CombatLogFinder.Describe(file));

        if (_found.Count > 0)
        {
            _files.SelectedIndex = 0;
            _run.Enabled = true;
            if (announce) _log($"{_found.Count} Protokolldatei(en) gefunden.");
            if (_status.Text.Length == 0)
            {
                _status.ForeColor = Theme.Muted;
                _status.Text = "Neueste Datei zuerst. Ein Raidabend ist ein Block aus Bosskämpfen;"
                             + " längere Pausen trennen zwei Abende.";
            }
            return;
        }

        _run.Enabled = false;
        var logs = CombatLogFinder.LogFolder(path);
        _status.ForeColor = Theme.Muted;
        _status.Text = logs is null
            ? "Kein Logs-Ordner gefunden. Zuerst oben den AddOns-Ordner der richtigen Spielversion wählen."
            : $"In {logs.FullName} liegt keine WoWCombatLog-Datei. "
              + "Aufzeichnen lässt sich ein Raid im Spiel mit /combatlog.";
        if (announce) _log(_status.Text);
    }

    private async Task RunAsync()
    {
        if (_files.SelectedIndex < 0 || _files.SelectedIndex >= _found.Count)
        {
            Fail("Bitte zuerst eine Protokolldatei auswählen.");
            return;
        }
        var file = _found[_files.SelectedIndex];

        _run.Enabled = false;
        _refresh.Enabled = false;
        _copy.Enabled = false;
        Cursor = Cursors.WaitCursor;
        _status.ForeColor = Theme.Muted;
        _status.Text = "Läuft …";

        try
        {
            // Eine 46-MB-Datei zeilenweise durchzugehen dauert Sekunden. Das
            // gehoert nicht in den Oberflaechen-Thread, sonst friert das Fenster.
            var progress = new Progress<string>(_log);
            var result = await Task.Run(
                () => new CombatLogImporter().Run(file.FullName, progress, CancellationToken.None));

            _importText = result.Text;
            _copy.Enabled = true;
            var copied = Copy(result.Text, null);

            _status.ForeColor = copied ? Theme.Success : Theme.Danger;
            _status.Text = $"{result.Sessions} Raidabend(e) mit {result.Participants} Teilnehmerzeilen "
                         + $"aus {result.Lines:N0} Logzeilen. "
                         + (copied
                             ? "Der Importcode liegt in der Zwischenablage.\n"
                             : "Die Zwischenablage war nicht erreichbar; mit „Erneut kopieren“ noch einmal versuchen.\n")
                         + "In WoW: /reload, dann Guild Copilot → Warcraft Logs, Feld leeren, Strg+V, Daten importieren.";
            foreach (var warning in result.Warnings) _log($"Hinweis: {warning}");
        }
        catch (Exception error)
        {
            _log($"Offline-Import fehlgeschlagen: {error.Message}");
            Fail(error.Message);
        }
        finally
        {
            _run.Enabled = true;
            _refresh.Enabled = true;
            Cursor = Cursors.Default;
        }
    }

    private void Fail(string message)
    {
        _status.ForeColor = Theme.Danger;
        _status.Text = message;
    }

    private bool Copy(string text, string? confirmation)
    {
        if (text.Length == 0) return false;
        try
        {
            Clipboard.SetText(text);
            if (confirmation is not null)
            {
                _status.ForeColor = Theme.Success;
                _status.Text = $"{confirmation} ({DateTime.Now:HH:mm:ss}).";
            }
            return true;
        }
        catch (Exception error)
        {
            _log($"Zwischenablage nicht erreichbar: {error.Message}");
            _status.ForeColor = Theme.Danger;
            _status.Text = "Die Zwischenablage ist gerade nicht erreichbar. Bitte „Erneut kopieren“ versuchen.";
            return false;
        }
    }
}
