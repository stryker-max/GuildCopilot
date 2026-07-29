using GuildCopilot.Installer.Wcl;

namespace GuildCopilot.Installer;

/// <summary>
/// Der Warcraft-Logs-Import als Abschnitt des Hauptfensters. Der Verlauf
/// gehoert dem Hauptfenster - beide Abschnitte schreiben in dasselbe Feld.
/// </summary>
public sealed class LogsPanel : UserControl
{
    private readonly Settings _settings;
    private readonly Action<string> _log;

    private readonly TextBox _clientId = new();
    private readonly TextBox _clientSecret = new();
    private readonly CheckBox _remember = new();
    private readonly TextBox _link = new();
    private readonly NumericUpDown _reports = new();
    private readonly Button _run = Theme.MakeButton("Import erzeugen", 220, primary: true);
    private readonly Button _copy = Theme.MakeButton("Erneut kopieren", 190, primary: false);
    private readonly Label _status = new();

    private string _importText = string.Empty;

    public LogsPanel(Settings settings, Action<string> log)
    {
        _settings = settings;
        _log = log;

        // Der Bereich waechst mit seinem Inhalt und steht als Ganzes unter
        // dem Addon-Teil - kein eigener Rahmen, keine eigene Bildlaufleiste.
        Dock = DockStyle.Top;
        AutoSize = true;
        AutoSizeMode = AutoSizeMode.GrowAndShrink;
        BackColor = Theme.Background;
        _copy.Enabled = false;

        Controls.Add(BuildBody());

        _run.Click += async (_, _) => await RunAsync();
        _copy.Click += (_, _) => Copy(_importText, "Erneut in die Zwischenablage kopiert");

        _clientId.Text = _settings.ClientId;
        _link.Text = _settings.LogsUrl.Length > 0 ? _settings.LogsUrl : _settings.GuildUrl;
        _reports.Value = _settings.ReportCount;
        _remember.Checked = _settings.RememberSecret;
        if (_settings.RememberSecret) _clientSecret.Text = _settings.LoadSecret();
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

        var title = Theme.SectionTitle("Warcraft Logs");
        title.Margin = new Padding(0, 0, 0, 2);
        root.Controls.Add(title);

        root.Controls.Add(new Label
        {
            Text = "Liest öffentliche Reports über die offizielle API und legt den Importcode in die Zwischenablage.",
            ForeColor = Theme.Muted,
            AutoSize = true,
            Margin = new Padding(0, 0, 0, 10),
        });

        var fields = new TableLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, ColumnCount = 2, RowCount = 3 };
        fields.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 150));
        fields.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        foreach (var box in new[] { _clientId, _clientSecret, _link })
        {
            Theme.StyleInput(box);
            box.Dock = DockStyle.Fill;
            box.Font = new Font("Segoe UI", 10f);
            box.Margin = new Padding(0, 3, 0, 3);
        }
        _clientSecret.UseSystemPasswordChar = true;
        fields.Controls.Add(RowLabel("Client ID"), 0, 0);
        fields.Controls.Add(_clientId, 1, 0);
        fields.Controls.Add(RowLabel("Client Secret"), 0, 1);
        fields.Controls.Add(_clientSecret, 1, 1);
        fields.Controls.Add(RowLabel("Gilde oder Report"), 0, 2);
        fields.Controls.Add(_link, 1, 2);
        root.Controls.Add(fields);

        _remember.Text = "Zugangsdaten merken (verschlüsselt für dieses Windows-Konto)";
        _remember.AutoSize = true;
        _remember.ForeColor = Theme.Text;
        _remember.Margin = new Padding(150, 10, 0, 12);
        root.Controls.Add(_remember);

        var countRow = new FlowLayoutPanel { AutoSize = true, WrapContents = false, Margin = new Padding(0, 0, 0, 16) };
        countRow.Controls.Add(new Label { Text = "Reports:", ForeColor = Theme.Muted, AutoSize = true, Margin = new Padding(0, 7, 10, 0) });
        _reports.Minimum = 1;
        _reports.Maximum = 12;
        _reports.Width = 60;
        _reports.BackColor = Theme.Input;
        _reports.ForeColor = Theme.Text;
        _reports.BorderStyle = BorderStyle.FixedSingle;
        countRow.Controls.Add(_reports);
        countRow.Controls.Add(new Label
        {
            Text = "Bei einem Reportlink zählt nur dieser eine.",
            ForeColor = Theme.Muted,
            AutoSize = true,
            Margin = new Padding(14, 7, 0, 0),
        });
        root.Controls.Add(countRow);

        root.Controls.Add(Theme.ButtonRow(_run, _copy));

        _status.AutoSize = true;
        _status.MaximumSize = new Size(880, 0);
        _status.ForeColor = Theme.Muted;
        root.Controls.Add(_status);

        return root;
    }

    private static Label RowLabel(string text) => new()
    {
        Text = text,
        ForeColor = Theme.Muted,
        AutoSize = true,
        Anchor = AnchorStyles.Left,
        Margin = new Padding(0, 9, 10, 6),
    };

    private async Task RunAsync()
    {
        var clientId = _clientId.Text.Trim();
        var secret = _clientSecret.Text.Trim();
        var link = _link.Text.Trim();

        if (clientId.Length == 0 || secret.Length == 0)
        {
            Fail("Client ID und Client Secret werden gebraucht. Beides steht unter warcraftlogs.com/api/clients.");
            return;
        }
        if (link.Length == 0)
        {
            Fail("Bitte einen Gilden- oder Reportlink eintragen.");
            return;
        }

        _run.Enabled = false;
        _copy.Enabled = false;
        Cursor = Cursors.WaitCursor;
        _status.ForeColor = Theme.Muted;
        _status.Text = "Läuft …";

        try
        {
            var importer = new WclImporter(new Progress<string>(_log));
            var result = await importer.RunAsync(clientId, secret, link, (int)_reports.Value, CancellationToken.None);

            _importText = result.Text;
            _copy.Enabled = true;
            var copied = Copy(result.Text, null);

            _status.ForeColor = copied ? Theme.Success : Theme.Danger;
            _status.Text = $"{result.Profiles} Spieler und {result.Sessions} Raidauswertungen aus {result.Reports} Reports. "
                         + (copied
                             ? "Der Importcode liegt in der Zwischenablage.\n"
                             : "Die Zwischenablage war nicht erreichbar; mit „Erneut kopieren“ noch einmal versuchen.\n")
                         + "In WoW: /reload, dann Guild Copilot → Warcraft Logs, Feld leeren, Strg+V, Daten importieren.";
            foreach (var warning in result.Warnings) _log($"Hinweis: {warning}");
            Persist();
        }
        catch (Exception error)
        {
            _log($"Import fehlgeschlagen: {error.Message}");
            Fail(error.Message);
        }
        finally
        {
            _run.Enabled = true;
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

    public void Persist()
    {
        _settings.ClientId = _clientId.Text.Trim();
        _settings.LogsUrl = _link.Text.Trim();
        _settings.ReportCount = (int)_reports.Value;
        _settings.RememberSecret = _remember.Checked;
        _settings.SaveSecret(_remember.Checked ? _clientSecret.Text.Trim() : string.Empty);
        _settings.Save();
    }
}
