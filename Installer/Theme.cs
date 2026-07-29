namespace GuildCopilot.Installer;

/// <summary>
/// Farben und Bausteine, damit Hauptfenster und Logs-Fenster gleich aussehen.
/// </summary>
public static class Theme
{
    public static readonly Color Background = Color.FromArgb(24, 28, 34);
    public static readonly Color Panel = Color.FromArgb(32, 38, 46);
    public static readonly Color Input = Color.FromArgb(18, 21, 26);
    public static readonly Color Accent = Color.FromArgb(41, 182, 246);
    public static readonly Color Text = Color.FromArgb(228, 233, 240);
    public static readonly Color Muted = Color.FromArgb(145, 163, 184);
    public static readonly Color Danger = Color.FromArgb(232, 90, 90);
    public static readonly Color Success = Color.FromArgb(89, 230, 149);

    public static Label Caption(string text) => new()
    {
        Text = text,
        ForeColor = Muted,
        AutoSize = true,
    };

    public static void StyleInput(TextBox box)
    {
        box.BackColor = Input;
        box.ForeColor = Text;
        box.BorderStyle = BorderStyle.FixedSingle;
    }

    public static Button MakeButton(string text, int width, bool primary)
    {
        var button = new Button
        {
            Text = text,
            Width = width,
            Height = 44,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 10.5f, FontStyle.Bold),
            BackColor = primary ? Accent : Panel,
            ForeColor = primary ? Color.Black : Text,
        };
        button.FlatAppearance.BorderColor = primary ? Accent : Color.FromArgb(70, 80, 92);
        return button;
    }

    /// <summary>
    /// Duenne Trennlinie zwischen zwei Bereichen - deutlich genug, um sie zu
    /// gliedern, ohne einen Rahmen ins Fenster zu setzen.
    /// </summary>
    public static Control Separator() => new Panel
    {
        Height = 1,
        Dock = DockStyle.Fill,
        BackColor = Color.FromArgb(52, 60, 70),
        Margin = new Padding(22, 6, 22, 10),
    };

    /// <summary>Ueberschrift eines Bereichs.</summary>
    public static Label SectionTitle(string text) => new()
    {
        Text = text,
        ForeColor = Accent,
        Font = new Font("Segoe UI", 12f, FontStyle.Bold),
        AutoSize = true,
    };

    /// <summary>
    /// Knopfreihe, die die volle Breite ausnutzt: gleich breite Spalten statt
    /// linksbuendiger Knoepfe mit viel totem Rand rechts daneben.
    /// </summary>
    public static Control ButtonRow(params Button[] buttons)
    {
        var row = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink,
            ColumnCount = buttons.Length,
            RowCount = 1,
            Margin = new Padding(0, 0, 0, 12),
        };
        for (var index = 0; index < buttons.Length; index++)
        {
            row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100f / buttons.Length));
            var button = buttons[index];
            button.Dock = DockStyle.Fill;
            button.Margin = new Padding(index == 0 ? 0 : 6, 0, index == buttons.Length - 1 ? 0 : 6, 0);
            row.Controls.Add(button, index, 0);
        }
        return row;
    }

    public static TextBox MakeLogBox() => new()
    {
        Multiline = true,
        ReadOnly = true,
        ScrollBars = ScrollBars.Vertical,
        BackColor = Input,
        ForeColor = Muted,
        BorderStyle = BorderStyle.FixedSingle,
        Font = new Font("Consolas", 9.5f),
    };
}
