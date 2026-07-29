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
    /// Ein TabControl zeichnet seine Reiter sonst in den Systemfarben - hell,
    /// mitten im dunklen Fenster. Deshalb werden sie selbst gezeichnet.
    /// </summary>
    public static TabControl MakeTabs()
    {
        var tabs = new TabControl
        {
            Dock = DockStyle.Fill,
            DrawMode = TabDrawMode.OwnerDrawFixed,
            SizeMode = TabSizeMode.Fixed,
            ItemSize = new Size(190, 34),
            Padding = new Point(0, 0),
            BackColor = Background,
        };

        tabs.DrawItem += (sender, args) =>
        {
            var control = (TabControl)sender!;
            var page = control.TabPages[args.Index];
            var selected = control.SelectedIndex == args.Index;
            var bounds = args.Bounds;

            using var background = new SolidBrush(selected ? Background : Panel);
            args.Graphics.FillRectangle(background, bounds);

            if (selected)
            {
                using var underline = new SolidBrush(Accent);
                args.Graphics.FillRectangle(underline, bounds.Left, bounds.Bottom - 3, bounds.Width, 3);
            }

            using var text = new SolidBrush(selected ? Accent : Muted);
            using var format = new StringFormat
            {
                Alignment = StringAlignment.Center,
                LineAlignment = StringAlignment.Center,
            };
            using var font = new Font("Segoe UI", 10.5f, selected ? FontStyle.Bold : FontStyle.Regular);
            args.Graphics.DrawString(page.Text, font, text, bounds, format);
        };
        return tabs;
    }

    public static TabPage MakePage(string title) => new(title)
    {
        BackColor = Background,
        ForeColor = Text,
        UseVisualStyleBackColor = false,
    };

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
