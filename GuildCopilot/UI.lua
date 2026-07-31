local _, GC = ...

GC.UI = {
    pages = {},
    tabs = {},
    activePage = "ROSTER",
    selectedLead = 1,
}

local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local CLASS_TEXTURE = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"

local THEME = {
    window = { 0.035, 0.047, 0.066, 0.98 },
    sidebar = { 0.055, 0.070, 0.094, 0.98 },
    card = { 0.075, 0.091, 0.118, 0.96 },
    cardHover = { 0.095, 0.119, 0.150, 1 },
    input = { 0.025, 0.035, 0.050, 1 },
    border = { 0.17, 0.21, 0.27, 1 },
    accent = { 0.18, 0.78, 0.86, 1 },
    accentDark = { 0.09, 0.39, 0.46, 1 },
    text = { 0.93, 0.96, 1.00, 1 },
    muted = { 0.57, 0.64, 0.72, 1 },
    success = { 0.35, 0.90, 0.58, 1 },
    warning = { 1.00, 0.72, 0.25, 1 },
    danger = { 1.00, 0.38, 0.40, 1 },
}

-- Die eine Quelle aller Chatbefehle: Hilfe im Chat, Addon-Optionen und die
-- Karte auf der Einstellungsseite lesen alle hier. Zwei Listen liefen
-- auseinander (Lektion aus 0.9.47).
local SLASH_COMMANDS = {
    { command = "/gcp", description = "öffnet und schließt Guild Copilot" },
    { command = "/gcp ver", description = "prüft, wer in Gruppe oder Gilde das Addon hat und in welcher Version" },
    { command = "/gcp welcome", description = "zeigt das Willkommensfenster mit der Einrichtung" },
    { command = "/gcp recruite", description = "blendet den Werbebalken ein oder aus" },
    { command = "/gcp debug", description = "misst die Laufzeit; ein zweiter Aufruf zeigt das Ergebnis" },
    { command = "/gcp help", description = "zeigt diese Liste im Chat" },
}

-- Masse der Seitenleiste. Sie muessen zur Fensterhoehe passen: kommt ein
-- Navigationspunkt dazu, prueft tests/validate.mjs, ob noch alles hineinpasst.
local NAV_TOP = 10
local NAV_SECTION_GAP = 3
local NAV_SECTION_HEIGHT = 22
local NAV_TAB_HEIGHT = 32
local NAV_TAB_SPACING = 34

-- Masse der Profilseite. Ganz oben steht die Checkliste "Erste Schritte", und
-- sie erscheint nur, solange etwas offen ist. Deshalb stehen die Abstaende der
-- Karten hier und nicht verstreut im Aufbau: Kommt die Checkliste dazu oder
-- faellt sie weg, wandern alle Karten darunter um denselben Betrag mit, statt
-- eine Luecke zu lassen. tests/validate.mjs liest diese Tabelle und prueft, ob
-- sich zwei Karten ueberlappen - genau der Fehler aus 0.9.44, nur eine Seite
-- weiter.
local ROSTER_ONBOARDING_HEIGHT = 228
local ROSTER_CARD_GAP = 12
local ROSTER_CONTENT_HEIGHT = 786
local ROSTER_CARDS = {
    { key = "profileCard", top = 0, height = 408 },
    { key = "professionCard", top = 0, height = 408, anchor = "TOPRIGHT" },
    { key = "absenceCard", top = 420, height = 180 },
    { key = "gearCard", top = 612, height = 162 },
}

local TAB_DEFINITIONS = {
    { key = "ROSTER", section = "COPILOT", label = "Profil", icon = "Interface\\Icons\\INV_Misc_GroupLooking" },
    { key = "OVERVIEW", section = "COPILOT", label = "Übersicht", icon = "Interface\\Icons\\INV_Misc_Note_01" },
    { key = "GUILD", section = "REKRUTIERUNG", label = "Gildenprofil", icon = "Interface\\Icons\\INV_Misc_TabardPVP_01" },
    { key = "SUGGESTIONS", section = "REKRUTIERUNG", label = "Vorschläge", icon = "Interface\\Icons\\INV_Misc_Note_05" },
    { key = "RECRUITMENT", section = "REKRUTIERUNG", label = "Klassen & Specs", icon = "Interface\\Icons\\INV_Misc_GroupLooking" },
    { key = "POST", section = "REKRUTIERUNG", label = "Werbung posten", icon = "Interface\\Icons\\INV_Letter_15" },
    { key = "INBOX", section = "REKRUTIERUNG", label = "Postfach", icon = "Interface\\Icons\\INV_Letter_05" },
    { key = "MEMBERCARE", section = "ROSTER", label = "Mitgliederpflege", icon = "Interface\\Icons\\INV_Misc_Note_06" },
    { key = "WORKSHOP", section = "ROSTER", label = "Gildenwerkstatt", icon = "Interface\\Icons\\INV_Hammer_20" },
    { key = "WCL", section = "ROSTER", label = "Warcraft Logs", icon = "Interface\\Icons\\INV_Misc_Book_09" },
    { key = "STATISTICS", section = "RAID", label = "Raidauswertung", icon = "Interface\\Icons\\INV_Misc_Book_11" },
    { key = "GEAR", section = "RAID", label = "Ausrüstung", icon = "Interface\\Icons\\INV_Chest_Plate06" },
    { key = "SETTINGS", section = "SYSTEM", label = "Einstellungen", icon = "Interface\\Icons\\INV_Gizmo_02" },
}

local function SetTextColor(fontString, color)
    fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local function SetTextureColor(texture, color)
    texture:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
end

-- Wann eine Postfachnachricht kam. Heute reicht die Uhrzeit - beim Beantworten
-- will man wissen, ob jemand vor zehn Minuten geschrieben hat oder vorletzte
-- Woche, und das Jahr steht dabei nur im Weg.
local function FormatInboxTime(timestamp)
    local value = tonumber(timestamp)
    if not value or value <= 0 then
        return ""
    end
    if date("%Y-%m-%d", value) == date("%Y-%m-%d") then
        return "heute " .. date("%H:%M", value)
    end
    return date("%d.%m. %H:%M", value)
end

-- Die Hoehe eines umbrechenden Textes. GetStringHeight liefert je nach
-- Zeitpunkt nur die Hoehe einer Zeile; dann klemmt der Text sichtbar ab ("..").
-- Deshalb wird zusaetzlich aus der Zeichenzahl abgeschaetzt und das Groessere
-- genommen - zu viel Platz ist harmlos, zu wenig schneidet Inhalt ab.
local function WrappedTextHeight(fontString, text, width, lineHeight)
    lineHeight = lineHeight or 15
    local plain = tostring(text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    local measured = tonumber(fontString and fontString.GetStringHeight
        and fontString:GetStringHeight()) or 0
    local lines = 0
    for segment in (plain .. "\n"):gmatch("(.-)\n") do
        lines = lines + math.max(1, math.ceil((#segment + 1) / math.max(12, width / 6.6)))
    end
    return math.max(measured, lines * lineHeight)
end

-- Klassenfarben stehen als RGB in GC.Classes und entsprechen den Blizzard-
-- Vorgaben. Fuer Inline-Text im Chat-Farbformat braucht es sie hexadezimal.
local function ClassColorCode(classFile)
    local classInfo = GC.Classes[classFile or ""]
    if not classInfo or type(classInfo.color) ~= "table" then
        return nil
    end
    return string.format("|cff%02x%02x%02x",
        math.floor((classInfo.color[1] or 1) * 255 + 0.5),
        math.floor((classInfo.color[2] or 1) * 255 + 0.5),
        math.floor((classInfo.color[3] or 1) * 255 + 0.5))
end

-- Name in Klassenfarbe. Ist die Klasse unbekannt, bleibt der Name schlicht -
-- lieber neutral als falsch gefaerbt.
local function ClassColoredName(name, classFile)
    name = tostring(name or "")
    local colorCode = ClassColorCode(classFile)
    if not colorCode then
        return name
    end
    return colorCode .. name .. "|r"
end

local function CreatePanel(parent, color, borderColor, name)
    local panel = CreateFrame("Frame", name, parent, BACKDROP_TEMPLATE)
    panel:SetBackdrop({
        bgFile = WHITE_TEXTURE,
        edgeFile = WHITE_TEXTURE,
        edgeSize = 1,
    })
    local background = color or THEME.card
    local border = borderColor or THEME.border
    panel:SetBackdropColor(background[1], background[2], background[3], background[4] or 1)
    panel:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
    return panel
end

local function CreateLabel(parent, text, style)
    style = style or {}
    local font = style.font or (style.title and "GameFontNormalLarge" or "GameFontNormal")
    local label = parent:CreateFontString(nil, "OVERLAY", font)
    label:SetText(text or "")
    label:SetJustifyH(style.align or "LEFT")
    label:SetJustifyV(style.vertical or "MIDDLE")
    SetTextColor(label, style.color or (style.muted and THEME.muted or THEME.text))
    if style.width then
        label:SetWidth(style.width)
    end
    if style.height then
        label:SetHeight(style.height)
    end
    -- Umbrechen ist die Ausnahme, nicht die Regel.
    --
    -- Eine umgebrochene Zelle waechst ueber ihre Zeile hinaus und schiebt sich
    -- in die Nachbarzeilen. Genau dieser Fehler ist an vier Stellen unabhaengig
    -- voneinander entstanden - Slot-Tabelle, Mitgliederpflege, Raidauswertung
    -- und Gildenuebersicht -, weil Umbrechen die Voreinstellung war und jede
    -- Tabelle einzeln daran denken musste.
    --
    -- Massgeblich ist, ob der Aufrufer eine feste Hoehe verlangt hat: Wer das
    -- tut, hat sich auf einen Kasten festgelegt, und daraus soll nichts
    -- herauswachsen. Ohne Hoehe darf eine Beschriftung weiter mitwachsen -
    -- freistehende Meldungen wie Importergebnisse leben davon.
    --
    -- Ausdruecklich mehrzeilig bleibt, was sich als Textblock zu erkennen
    -- gibt: ueber "vertical = TOP", das Hilfetexte ohnehin setzen, oder ueber
    -- ein ausdrueckliches "multiline" bei fester Hoehe.
    local wraps = style.multiline == true
        or style.vertical == "TOP"
        or style.height == nil
    if not wraps and label.SetWordWrap then
        label:SetWordWrap(false)
    end
    return label
end

-- Tooltips an Tabellenzeilen hingen fest rechts. Steht das Fenster am rechten
-- Bildschirmrand, laeuft der Tooltip hinaus - und abgeschnitten wird die
-- rechte Spalte, also ausgerechnet die Zahlen. Die Seite wird deshalb nach
-- verfuegbarem Platz gewaehlt.
local function AnchorRowTooltip(frame)
    if not GameTooltip then
        return false
    end
    GameTooltip:SetOwner(frame, "ANCHOR_NONE")
    GameTooltip:SetClampedToScreen(true)
    GameTooltip:ClearAllPoints()

    -- GetRight liefert Koordinaten im Massstab des jeweiligen Rahmens. Ohne
    -- Umrechnung auf Bildschirmeinheiten vergleicht man zwei verschiedene
    -- Systeme, und die Entscheidung faellt falsch aus.
    local right = (frame:GetRight() or 0) * (frame:GetEffectiveScale() or 1)
    local screenRight = (UIParent:GetRight() or 0) * (UIParent:GetEffectiveScale() or 1)
    if screenRight - right < 340 * (UIParent:GetEffectiveScale() or 1) then
        GameTooltip:SetPoint("TOPRIGHT", frame, "TOPLEFT", -8, 0)
    else
        GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT", 8, 0)
    end
    return true
end

local function CreatePageTitle(page, title, subtitle)
    local heading = CreateLabel(page, title, { title = true })
    heading:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
    local help = CreateLabel(page, subtitle, { muted = true, width = 770, height = 32, vertical = "TOP" })
    help:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -7)
    return heading, help
end

local function CreateButton(parent, text, width, height, onClick, kind)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 130, height or 34)
    button.kind = kind or "SECONDARY"
    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:SetAllPoints()
    button.border = button:CreateTexture(nil, "BORDER")
    button.border:SetPoint("TOPLEFT", -1, 1)
    button.border:SetPoint("BOTTOMRIGHT", 1, -1)
    button.border:SetColorTexture(THEME.border[1], THEME.border[2], THEME.border[3], 1)
    button.background:SetDrawLayer("BORDER", 1)
    button.label = CreateLabel(button, text, { align = "CENTER" })
    button.label:SetAllPoints()
    button.active = false

    function button:SetText(value)
        self.label:SetText(value or "")
    end

    function button:SetActive(active)
        self.active = active == true
        if self.active or self.kind == "PRIMARY" then
            SetTextureColor(self.background, self.active and THEME.accent or THEME.accentDark)
            self.label:SetTextColor(1, 1, 1)
        else
            SetTextureColor(self.background, THEME.card)
            SetTextColor(self.label, THEME.text)
        end
    end

    button:SetActive(false)
    button:SetScript("OnEnter", function(self)
        if not self.active then
            SetTextureColor(self.background, THEME.cardHover)
        end
    end)
    button:SetScript("OnLeave", function(self)
        self:SetActive(self.active)
    end)
    button:SetScript("OnClick", onClick)
    return button
end

-- Live, per Addon verteilt oder aus Warcraft Logs nachgereicht.
local SESSION_SOURCE_LABEL = {
    LIVE = "Live",
    SYNC = "Addon-Sync",
    WCL = "Warcraft Logs",
    LOG = "Combat Log",
}

-- Kurzzeichen für die Sitzungsliste. Dort ist kein Platz für ganze Wörter, und
-- sie erscheinen nur, wenn derselbe Abend aus mehreren Quellen vorliegt.
local SESSION_SOURCE_MARK = {
    LIVE = "Live",
    SYNC = "Sync",
    WCL = "Logs",
    LOG = "Datei",
}

-- Quellen, deren Anwesenheit reine Encounter-Zeit ist. Beginn und Ende
-- beschreiben dort den ganzen Abend samt Pausen und Trash; ein Prozentwert
-- gegen diese Gesamtdauer waere fuer jeden Teilnehmer viel zu niedrig.
local ENCOUNTER_TIME_SOURCES = {
    WCL = true,
    LOG = true,
}

local function SetButtonEnabled(button, enabled)
    if enabled then
        button:Enable()
    else
        button:Disable()
    end
    button.label:SetAlpha(enabled and 1 or 0.45)
end

local function CreateToggle(parent, text, onClick)
    local toggle = CreateFrame("CheckButton", nil, parent)
    toggle:SetSize(22, 22)
    toggle.box = CreatePanel(toggle, THEME.input)
    toggle.box:SetAllPoints()
    toggle.mark = toggle:CreateTexture(nil, "OVERLAY")
    toggle.mark:SetPoint("TOPLEFT", toggle, "TOPLEFT", -4, 4)
    toggle.mark:SetPoint("BOTTOMRIGHT", toggle, "BOTTOMRIGHT", 4, -4)
    toggle.mark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    toggle.text = CreateLabel(toggle, text)
    toggle.text:SetPoint("LEFT", toggle, "RIGHT", 8, 0)

    function toggle:RefreshVisual()
        local checked = not not self:GetChecked()
        if checked then
            self.mark:Show()
            self.box:SetBackdropColor(THEME.accentDark[1], THEME.accentDark[2], THEME.accentDark[3], 1)
            SetTextColor(self.text, THEME.text)
        else
            self.mark:Hide()
            self.box:SetBackdropColor(THEME.input[1], THEME.input[2], THEME.input[3], 1)
            SetTextColor(self.text, THEME.muted)
        end
        local color = checked and THEME.accent or THEME.border
        self.box:SetBackdropBorderColor(color[1], color[2], color[3], 1)
    end

    toggle:SetScript("OnClick", function(self)
        self:RefreshVisual()
        onClick(not not self:GetChecked())
    end)
    toggle:SetScript("OnEnter", function(self)
        if not self:GetChecked() then
            self.box:SetBackdropBorderColor(THEME.accent[1], THEME.accent[2], THEME.accent[3], 0.65)
        end
    end)
    toggle:SetScript("OnLeave", function(self)
        self:RefreshVisual()
    end)
    toggle:RefreshVisual()
    return toggle
end

local function SetToggle(toggle, checked)
    toggle:SetChecked(checked == true)
    toggle:RefreshVisual()
end

local function ConfigureEdit(edit, maxLetters)
    edit:SetAutoFocus(false)
    edit:SetFontObject("ChatFontNormal")
    edit:SetTextColor(THEME.text[1], THEME.text[2], THEME.text[3], 1)
    edit:SetMaxLetters(maxLetters or 2000)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        if GC.UI.frame and GC.UI.frame:IsShown() then
            GC.UI.frame:Hide()
        end
    end)
end

local function CreateEdit(parent, width, height)
    local container = CreatePanel(parent, THEME.input)
    container:SetSize(width, height)
    local edit = CreateFrame("EditBox", nil, container)
    edit:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -6)
    edit:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 6)
    ConfigureEdit(edit, 1000)
    edit.container = container
    return edit
end

local function CreateModernScrollFrame(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll.track = scroll:CreateTexture(nil, "BACKGROUND")
    scroll.track:SetWidth(3)
    scroll.track:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -6, -8)
    scroll.track:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -6, 8)
    SetTextureColor(scroll.track, { 0.12, 0.15, 0.19, 1 })
    scroll.thumb = scroll:CreateTexture(nil, "ARTWORK")
    scroll.thumb:SetWidth(3)
    SetTextureColor(scroll.thumb, THEME.accent)

    function scroll:UpdateModernThumb()
        local range = self:GetVerticalScrollRange() or 0
        local trackHeight = self.track:GetHeight() or 0
        if range <= 0 or trackHeight <= 0 then
            self.thumb:Hide()
            return
        end
        local visibleHeight = self:GetHeight() or 1
        local thumbHeight = math.max(24, trackHeight * (visibleHeight / (visibleHeight + range)))
        local offset = (self:GetVerticalScroll() / range) * (trackHeight - thumbHeight)
        self.thumb:ClearAllPoints()
        self.thumb:SetPoint("TOP", self.track, "TOP", 0, -offset)
        self.thumb:SetHeight(thumbHeight)
        self.thumb:Show()
    end

    scroll:SetScript("OnScrollRangeChanged", function(self)
        -- Ein veraltetes Animationsziel (Seitenwechsel, neuer Inhalt) darf
        -- den naechsten Radtick nicht an eine alte Position springen lassen.
        self.targetScroll = nil
        self:UpdateModernThumb()
    end)
    scroll:SetScript("OnVerticalScroll", function(self)
        self:UpdateModernThumb()
    end)

    -- Weiches Scrollen: Das Rad setzt nur ein Ziel, ein kurzlebiges OnUpdate
    -- naehert sich ihm exponentiell (bildratenunabhaengig). Vorher sprang die
    -- Position in harten 24-Pixel-Schritten - auf der 1700 Pixel hohen
    -- Einstellungsseite fuehlte sich das stockend an. Das OnUpdate haengt nur
    -- waehrend der Animation am Rahmen; Leerlauf kostet keinen Handleraufruf.
    local function SmoothScrollStep(self, elapsed)
        local current = self:GetVerticalScroll() or 0
        local target = self.targetScroll
        if not target then
            self:SetScript("OnUpdate", nil)
            return
        end
        local difference = target - current
        if math.abs(difference) < 1 then
            self:SetVerticalScroll(target)
            self.targetScroll = nil
            self:SetScript("OnUpdate", nil)
        else
            self:SetVerticalScroll(current
                + (difference * math.min(1, (tonumber(elapsed) or 0) * 14)))
        end
        self:UpdateModernThumb()
    end

    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local base = self.targetScroll or self:GetVerticalScroll() or 0
        self.targetScroll = math.max(0,
            math.min(base - (delta * 64), self:GetVerticalScrollRange() or 0))
        self:SetScript("OnUpdate", SmoothScrollStep)
    end)
    return scroll
end

local function CreateTextArea(parent, width, height, maxLetters)
    local container = CreatePanel(parent, THEME.input)
    container:SetSize(width, height)

    local scroll = CreateModernScrollFrame(container)
    scroll:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -9)
    scroll:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -14, 9)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetWidth(width - 34)
    edit:SetHeight(height - 18)
    edit:SetJustifyH("LEFT")
    edit:SetJustifyV("TOP")
    ConfigureEdit(edit, maxLetters or 4000)
    scroll:SetScrollChild(edit)
    edit.container = container
    edit.scrollFrame = scroll

    -- Ein Klick neben den Text traf bisher ins Leere: die EditBox belegt nur
    -- die Fläche innerhalb des Scrollbereichs, Rahmen und Rand gehören ihr
    -- nicht. Man musste also eine passende Stelle treffen, um überhaupt einen
    -- Cursor zu bekommen. Beide reichen den Klick jetzt weiter.
    local function FocusEdit()
        edit:SetFocus()
        edit:SetCursorPosition(edit:GetNumLetters())
    end
    container:EnableMouse(true)
    container:SetScript("OnMouseDown", FocusEdit)
    scroll:EnableMouse(true)
    scroll:SetScript("OnMouseDown", FocusEdit)

    edit:SetScript("OnCursorChanged", function(_, x, y, cursorWidth, cursorHeight)
        local offset = scroll:GetVerticalScroll()
        local visibleHeight = scroll:GetHeight()
        if -y < offset then
            scroll:SetVerticalScroll(math.max(0, -y))
        elseif (-y + cursorHeight) > (offset + visibleHeight) then
            scroll:SetVerticalScroll((-y + cursorHeight) - visibleHeight)
        end
    end)
    return edit
end

local function CreateCard(parent, title)
    local card = CreatePanel(parent, THEME.card)
    if title then
        card.title = CreateLabel(card, title, { title = true })
        card.title:SetPoint("TOPLEFT", card, "TOPLEFT", 18, -16)
    end
    return card
end

local function ClassColor(classFile)
    local classInfo = GC.Classes[classFile]
    if not classInfo then
        return 1, 1, 1
    end
    return classInfo.color[1], classInfo.color[2], classInfo.color[3]
end

local function SetClassIcon(texture, classFile)
    texture:SetTexture(CLASS_TEXTURE)
    local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classFile]
    if coords then
        texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    end
end

local function SetRaidMarkerIcon(texture, markerIndex)
    texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    if SetRaidTargetIconTexture then
        SetRaidTargetIconTexture(texture, markerIndex)
        return
    end
    local column = (markerIndex - 1) % 4
    local row = math.floor((markerIndex - 1) / 4)
    texture:SetTexCoord(column * 0.25, (column + 1) * 0.25, row * 0.5, (row + 1) * 0.5)
end

local function CreateRaidMarkerButton(parent, markerIndex, onClick)
    local button = CreateButton(parent, "", 26, 26, onClick)
    button.markerIndex = markerIndex
    button.label:Hide()
    button.markerIcon = button:CreateTexture(nil, "ARTWORK")
    button.markerIcon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    button.markerIcon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
    SetRaidMarkerIcon(button.markerIcon, markerIndex)
    return button
end

local function CreateChoiceDropdown(parent, width, options, onSelected, openBelow, emptyLabel, iconResolver)
    local dropdown
    dropdown = CreateButton(parent, "Nicht gesetzt", width, 32, function()
        local show = not dropdown.popup:IsShown()
        if show then
            dropdown:PlacePopup()
            if dropdown.popup.scroll then
                dropdown.popup.scroll:SetVerticalScroll(0)
                dropdown.popup.scroll:UpdateModernThumb()
            end
        end
        dropdown.popup:SetShown(show)
    end)
    dropdown.value = ""
    if iconResolver then
        dropdown.choiceIcon = dropdown:CreateTexture(nil, "ARTWORK")
        dropdown.choiceIcon:SetSize(21, 21)
        dropdown.choiceIcon:SetPoint("LEFT", dropdown, "LEFT", 8, 0)
        dropdown.label:ClearAllPoints()
        dropdown.label:SetPoint("LEFT", dropdown, "LEFT", 37, 0)
        dropdown.label:SetPoint("RIGHT", dropdown, "RIGHT", -8, 0)
        dropdown.label:SetJustifyH("LEFT")
    end

    -- Lange Listen wurden frueher als eine hohe Flaeche gezeichnet: Bei elf
    -- Berufen sind das 283 Pixel, die nach oben aus dem Fenster herausragten
    -- und sich nicht erreichen liessen. Ab MAX_ROWS bekommt das Menue deshalb
    -- eine feste Hoehe und scrollt darin.
    local MAX_ROWS = 8
    local ROW_HEIGHT = 25
    local visibleRows = math.min(#options, MAX_ROWS)
    local scrollable = #options > MAX_ROWS

    -- Das Menue haengt bewusst NICHT unter der Karte, sondern unter dem
    -- Hauptfenster. Mehrere Seiten liegen in einem ScrollFrame, und ein
    -- ScrollFrame beschneidet alles, was ueber seinen Rand hinausragt. Als Kind
    -- der Karte waere das aufgeklappte Menue also innerhalb des Scrollbereichs
    -- und wuerde oben abgeschnitten - unabhaengig von seiner Hoehe. Verankert
    -- wird trotzdem am Knopf, die Position stimmt also weiterhin.
    local popupHost = GC.UI.frame or UIParent
    local popup = CreatePanel(popupHost, THEME.input, THEME.accent)
    popup:SetSize(width, (visibleRows * ROW_HEIGHT) + 8)
    popup:SetFrameStrata(popupHost.GetFrameStrata and popupHost:GetFrameStrata() or "DIALOG")
    local hostLevel = popupHost.GetFrameLevel and popupHost:GetFrameLevel() or 1
    popup:SetFrameLevel((hostLevel or 1) + 60)
    popup:Hide()
    dropdown.popup = popup

    -- Verschwindet der Knopf, muss das Menue mit. Sonst bliebe es beim
    -- Seitenwechsel stehen, weil es nicht mehr am selben Elternteil haengt.
    dropdown:HookScript("OnHide", function()
        popup:Hide()
    end)

    -- Richtung erst beim Aufklappen bestimmen: Nach oben nur, wenn es dort
    -- reicht, sonst nach unten. GetTop und GetBottom messen beide vom unteren
    -- Bildschirmrand.
    function dropdown:PlacePopup()
        popup:ClearAllPoints()
        local needed = popup:GetHeight() + 5
        local spaceAbove = UIParent:GetHeight() - (self:GetTop() or 0)
        local spaceBelow = self:GetBottom() or 0
        if openBelow or (spaceAbove < needed and spaceBelow >= needed) then
            popup:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
        else
            popup:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
        end
    end

    local rowParent = popup
    local rowWidth = width - 8
    if scrollable then
        local scroll = CreateModernScrollFrame(popup)
        scroll:SetPoint("TOPLEFT", popup, "TOPLEFT", 4, -4)
        scroll:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -4, 4)
        local list = CreateFrame("Frame", nil, scroll)
        list:SetWidth(width - 8)
        list:SetHeight(#options * ROW_HEIGHT)
        scroll:SetScrollChild(list)
        popup.scroll = scroll
        rowParent = list
        rowWidth = width - 18
    end

    for index, option in ipairs(options) do
        local selectedOption = option
        local optionButton = CreateButton(rowParent, option ~= "" and option or (emptyLabel or "Nicht gesetzt"), rowWidth, 23, function()
            dropdown:SetValue(selectedOption)
            popup:Hide()
            onSelected(selectedOption)
        end)
        if scrollable then
            optionButton:SetPoint("TOPLEFT", rowParent, "TOPLEFT", 0, -((index - 1) * ROW_HEIGHT))
        else
            optionButton:SetPoint("TOPLEFT", rowParent, "TOPLEFT", 4, -4 - ((index - 1) * ROW_HEIGHT))
        end
        if iconResolver then
            optionButton.choiceIcon = optionButton:CreateTexture(nil, "ARTWORK")
            optionButton.choiceIcon:SetSize(17, 17)
            optionButton.choiceIcon:SetPoint("LEFT", optionButton, "LEFT", 7, 0)
            optionButton.choiceIcon:SetTexture(iconResolver(option))
            optionButton.label:ClearAllPoints()
            optionButton.label:SetPoint("LEFT", optionButton, "LEFT", 31, 0)
            optionButton.label:SetPoint("RIGHT", optionButton, "RIGHT", -6, 0)
            optionButton.label:SetJustifyH("LEFT")
        end
    end

    function dropdown:SetValue(value)
        self.value = value or ""
        self:SetText(self.value ~= "" and self.value or (emptyLabel or "Nicht gesetzt"))
        if self.choiceIcon then
            self.choiceIcon:SetTexture(iconResolver(self.value))
        end
    end

    return dropdown
end

function GC.UI:CreateMainFrame()
    if self.frame then
        return
    end

    local frame = CreatePanel(UIParent, THEME.window, { 0.12, 0.55, 0.63, 1 }, "GuildCopilotFrame")
    frame:SetSize(1020, 690)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:EnableKeyboard(true)
    if frame.SetPropagateKeyboardInput then
        frame:SetPropagateKeyboardInput(true)
    end
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            if self.SetPropagateKeyboardInput then
                self:SetPropagateKeyboardInput(false)
            end
            self:Hide()
        elseif self.SetPropagateKeyboardInput then
            self:SetPropagateKeyboardInput(true)
        end
    end)
    frame:SetScript("OnKeyUp", function(self)
        if self.SetPropagateKeyboardInput then
            self:SetPropagateKeyboardInput(true)
        end
    end)
    frame:Hide()
    table.insert(UISpecialFrames, "GuildCopilotFrame")

    local header = CreatePanel(frame, THEME.sidebar, THEME.sidebar)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    header:SetHeight(58)
    frame.header = header

    local mark = header:CreateTexture(nil, "ARTWORK")
    mark:SetSize(36, 36)
    mark:SetPoint("LEFT", header, "LEFT", 16, 0)
    mark:SetTexture("Interface\\AddOns\\GuildCopilot\\Media\\GuildCopilotLogo")

    local title = CreateLabel(header, "Guild Copilot", { title = true })
    title:SetPoint("LEFT", mark, "RIGHT", 12, 7)
    local subtitle = CreateLabel(header, "TBC Anniversary  •  v" .. GC.Constants.VERSION, { muted = true })
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)

    -- Sichtbar neben der Version: Laeuft der Abgleich mit der Gilde, und fahren
    -- alle denselben Stand? Ein Klick fragt sofort nach, statt auf den naechsten
    -- Login zu warten.
    self.syncBadge = CreateButton(header, "", 250, 20, function()
        GC.Sync:RequestSync()
        GC.UI:RefreshSyncBadge()
    end)
    self.syncBadge:SetPoint("LEFT", subtitle, "RIGHT", 14, 0)
    self.syncBadge.background:Hide()
    self.syncBadge.border:Hide()
    self.syncBadge.label:ClearAllPoints()
    self.syncBadge.label:SetPoint("LEFT", self.syncBadge, "LEFT", 0, 0)
    self.syncBadge.label:SetJustifyH("LEFT")
    self.syncBadge.label:SetFontObject("GameFontNormalSmall")
    self.syncBadge:SetScript("OnEnter", function(badge)
        if not GameTooltip then
            return
        end
        local stats = GC.Sync:GetAddonUserStats()
        GameTooltip:SetOwner(badge, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Abgleich mit der Gilde")
        GameTooltip:AddLine(stats.players .. " Spieler mit "
            .. stats.known .. " erkannten Charakteren, davon " .. stats.compatible
            .. " mit gleicher Datenversion.", 1, 1, 1, true)
        if #stats.outdatedNames > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Abweichende Datenversion:", 1, 0.72, 0.25)
            GameTooltip:AddLine(table.concat(stats.outdatedNames, ", "), 1, 1, 1, true)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Erkannt wird nur, wer das Addon aktiv nutzt und seit deinem"
            .. " Login etwas gesendet hat.", 0.57, 0.64, 0.72, true)
        GameTooltip:AddLine("Klick fragt sofort bei allen nach.", 0.31, 0.79, 1, true)
        GameTooltip:Show()
    end)
    self.syncBadge:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    local close = CreateButton(header, "×", 34, 34, function()
        frame:Hide()
    end)
    close:SetPoint("RIGHT", header, "RIGHT", -13, 0)
    close.label:SetFontObject("GameFontNormalLarge")

    -- Die Checkliste "Erste Schritte" laesst sich jederzeit wieder aufrufen -
    -- auch nach "Nicht mehr anzeigen" und auch, wenn schon alles erledigt ist.
    -- Ein eigener Navigationspunkt kam dafuer nicht in Frage: Die Seitenleiste
    -- hat keine Bildlaufleiste und ist voll.
    local setup = CreateButton(header, "Einrichtung", 110, 26, function()
        GC.Onboarding:Reopen()
        GC.UI:ShowPage("ROSTER")
        local page = GC.UI.pages.ROSTER
        if page and page.profileScroll then
            page.profileScroll:SetVerticalScroll(0)
            page.profileScroll:UpdateModernThumb()
        end
    end)
    setup:SetPoint("RIGHT", close, "LEFT", -8, 0)
    setup:SetScript("OnEnter", function(selfButton)
        SetTextureColor(selfButton.background, THEME.cardHover)
        if not GameTooltip then
            return
        end
        GameTooltip:SetOwner(selfButton, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Erste Schritte")
        GameTooltip:AddLine("Zeigt die Einrichtungs-Checkliste im Profil wieder an.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    setup:SetScript("OnLeave", function(selfButton)
        selfButton:SetActive(selfButton.active)
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    -- Ist alles erledigt, bleibt die Erfolgsmeldung bis zum Schliessen stehen.
    frame:SetScript("OnHide", function()
        GC.Onboarding:NoteWindowClosed()
    end)

    local sidebar = CreatePanel(frame, THEME.sidebar, THEME.sidebar)
    sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -59)
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
    sidebar:SetWidth(190)
    frame.sidebar = sidebar

    local navigationY = -NAV_TOP
    local currentSection
    for _, definition in ipairs(TAB_DEFINITIONS) do
        if definition.section ~= currentSection then
            if currentSection then
                navigationY = navigationY - NAV_SECTION_GAP
            end
            currentSection = definition.section
            local sectionLabel = CreateLabel(sidebar, currentSection, {
                muted = true,
                font = "GameFontNormalSmall",
                align = "CENTER",
                width = 160,
                height = 18,
            })
            sectionLabel:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 14, navigationY)
            navigationY = navigationY - NAV_SECTION_HEIGHT
        end
        local pageKey = definition.key
        local tab = CreateButton(sidebar, definition.label, 160, NAV_TAB_HEIGHT, function()
            self:ShowPage(pageKey)
        end)
        tab:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 14, navigationY)
        navigationY = navigationY - NAV_TAB_SPACING
        tab.key = pageKey
        tab.label:ClearAllPoints()
        tab.label:SetPoint("LEFT", tab, "LEFT", 43, 0)
        tab.label:SetPoint("RIGHT", tab, "RIGHT", -8, 0)
        tab.label:SetJustifyH("LEFT")
        tab.icon = tab:CreateTexture(nil, "ARTWORK")
        tab.icon:SetSize(22, 22)
        tab.icon:SetPoint("LEFT", tab, "LEFT", 13, 0)
        tab.icon:SetTexture(definition.icon)

        -- Ranggeschützte Punkte verschwinden nicht mehr, sie tragen ein
        -- Schloss (Owner-Entscheidung): Sichtbar heißt "gibt es, braucht
        -- Rang" - unsichtbar hieße "gibt es nicht".
        tab.lock = tab:CreateTexture(nil, "OVERLAY")
        tab.lock:SetSize(14, 14)
        tab.lock:SetPoint("RIGHT", tab, "RIGHT", -8, 0)
        tab.lock:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
        tab.lock:Hide()
        function tab:SetLocked(locked)
            self.locked = locked == true
            self.lock:SetShown(self.locked)
            if self.SetAlpha then
                self:SetAlpha(self.locked and 0.45 or 1)
            end
        end
        tab:HookScript("OnEnter", function(self)
            if self.locked and GameTooltip then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Für deinen Gildenrang gesperrt")
                GameTooltip:AddLine("Berechtigte Ränge legen die Freigabe in den Einstellungen fest.",
                    1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        tab:HookScript("OnLeave", function(self)
            if self.locked and GameTooltip then
                GameTooltip:Hide()
            end
        end)
        self.tabs[#self.tabs + 1] = tab

        local page = CreateFrame("Frame", nil, frame)
        page:SetPoint("TOPLEFT", frame, "TOPLEFT", 215, -82)
        page:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -22, 22)
        page:Hide()
        self.pages[pageKey] = page
    end

    self.frame = frame
    self:BuildDashboardPage()
    self:BuildSettingsPage()
    self:BuildRosterPage()
    self:BuildMemberCarePage()
    self:BuildWorkshopPage()
    self:BuildSuggestionsPage()
    self:BuildRecruitmentPage()
    self:BuildPostPage()
    self:BuildInboxPage()
    self:BuildGuildPage()
    self:BuildWarcraftLogsPage()
    self:BuildStatisticsPage()
    self:BuildGearPage()
    self:ShowPage(self.activePage)
end

function GC.UI:ShowPage(pageKey)
    if pageKey == "MEMBERCARE" and not GC.Roster:CanAccessMemberCare() then
        pageKey = "ROSTER"
        GC:Print("Mitgliederpflege ist für deinen Gildenrang gesperrt – "
            .. "berechtigte Ränge legen die Freigabe in den Einstellungen fest.")
    end
    self.activePage = pageKey
    for key, page in pairs(self.pages) do
        page:SetShown(key == pageKey)
    end
    for _, tab in ipairs(self.tabs) do
        tab:SetActive(tab.key == pageKey)
    end
    -- Die aufgeschlagene Seite wird immer neu gezeichnet, auch wenn sie nicht
    -- als veraltet vorgemerkt war: Ein Klick auf einen Reiter soll den
    -- aktuellen Stand zeigen, nicht den von vorhin.
    if self:IsVisible() then
        self:RefreshSyncBadge()
        self:RefreshNavigationAccess()
        self:RefreshPage(pageKey)
    end
end

function GC.UI:RefreshNavigationAccess()
    local canAccessMemberCare = GC.Roster:CanAccessMemberCare()
    for _, tab in ipairs(self.tabs) do
        if tab.key == "MEMBERCARE" then
            -- Sichtbar bleiben, aber mit Schloss und gedimmt statt versteckt.
            tab:SetShown(true)
            tab:SetLocked(not canAccessMemberCare)
        end
    end
    if self.activePage == "MEMBERCARE" and not canAccessMemberCare then
        self:ShowPage("ROSTER")
    end
end

function GC.UI:Toggle()
    self:CreateMainFrame()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
        self:Refresh()
    end
end

local function ProfessionSummary(profile)
    local labels = {}
    for slot = 1, 2 do
        local profession = profile and profile.professions and profile.professions[slot]
        if profession and profession.name then
            local label = profession.name
            if (tonumber(profession.skillLevel) or 0) > 0 then
                label = label .. " " .. profession.skillLevel
            end
            labels[#labels + 1] = label
        end
    end
    return #labels > 0 and table.concat(labels, " / ") or "–"
end

local function LastOnlineLabel(member)
    if member.online then
        return "|cff59e695online|r"
    end
    local hours = member.lastOnlineHours
    if hours == nil then
        return "unbekannt"
    elseif hours < 24 then
        return "vor " .. math.max(1, math.floor(hours)) .. "h"
    elseif hours < 24 * 365 then
        return "vor " .. math.floor(hours / 24) .. "T"
    end
    return "> 1 Jahr"
end

function GC.UI:BuildDashboardPage()
    local page = self.pages.OVERVIEW
    CreatePageTitle(page, "Gildenübersicht", "Bis zu 25 zuletzt aktive Level-70-Spieler – nach gewählten Raider-Rängen, mit Raidprofil und Berufen.")

    page.metricCards = {}
    local metrics = {
        { key = "MEMBERS", label = "MITGLIEDER" },
        { key = "ONLINE", label = "ONLINE" },
        { key = "PROFILES", label = "BEKANNTE PROFILE" },
        { key = "ADDON", label = "MIT ADDON" },
    }
    for index, metric in ipairs(metrics) do
        local card = CreateCard(page)
        card:SetSize(185, 82)
        card:SetPoint("TOPLEFT", page, "TOPLEFT", (index - 1) * 197, -66)
        card.value = CreateLabel(card, "0", { title = true })
        card.value:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -13)
        -- Feste Breite und Hoehe, sonst waechst die Beschriftung aus der Karte
        -- heraus: "MIT ADDON  •  20 CHARAKTERE  •  4 ABWEICHEND" stand quer
        -- ueber dem halben Bildschirm, weil eine FontString ohne Breite
        -- einfach weiterlaeuft.
        card.caption = CreateLabel(card, metric.label, { muted = true, width = 153, height = 14 })
        card.caption:SetPoint("TOPLEFT", card.value, "BOTTOMLEFT", 0, -4)
        -- Zweite Zeile fuer Zusaetze. Sie bleibt leer, solange es nichts zu
        -- sagen gibt, und uebernimmt sonst die Warnfarbe.
        card.detail = CreateLabel(card, "", {
            muted = true,
            font = "GameFontNormalSmall",
            width = 153,
            height = 13,
        })
        card.detail:SetPoint("TOPLEFT", card.caption, "BOTTOMLEFT", 0, -2)
        page.metricCards[metric.key] = card
    end

    local addonCard = page.metricCards.ADDON
    addonCard:EnableMouse(true)
    addonCard:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        local stats = GC.Sync:GetAddonUserStats()
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Guild Copilot in der Gilde")
        GameTooltip:AddLine(stats.players .. " Spieler mit "
            .. stats.known .. " erkannten Charakteren, davon " .. stats.compatible
            .. " mit passender Datenversion", 1, 1, 1, true)
        if stats.known > stats.players then
            GameTooltip:AddLine("Charaktere eines Spielers werden zusammengefasst,"
                .. " sobald sein Client sich einmal vorgestellt hat.", 0.57, 0.64, 0.72, true)
        end
        if #stats.outdatedNames > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Abweichende Datenversion:", 1, 0.72, 0.25)
            GameTooltip:AddLine(table.concat(stats.outdatedNames, ", "), 1, 1, 1, true)
            GameTooltip:AddLine("Mit ihnen werden Rezepte und gildenweite Einstellungen"
                .. " nicht ausgetauscht.", 1, 1, 1, true)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Erkannt wird nur, wer das Addon aktiv nutzt.", 0.57, 0.64, 0.72, true)
        GameTooltip:Show()
    end)
    addonCard:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    local rosterCard = CreateCard(page, "Aktive Raider  •  Level 70")
    rosterCard:SetSize(776, 408)
    rosterCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -158)
    page.rankFilterButton = CreateButton(rosterCard, "Ränge: alle", 154, 28, function()
        GC.UI:ShowPage("SETTINGS")
    end)
    page.rankFilterButton:SetPoint("TOPRIGHT", rosterCard, "TOPRIGHT", -18, -12)
    -- STATUS war 74 Pixel breit, "nicht bestaetigt" braucht rund 95. Der Text
    -- brach um und sprengte die 25 Pixel hohe Zeile. Die Spalte bekommt mehr
    -- Platz, die Berufe geben ihn ab - sie sind ohnehin selten voll.
    local headers = {
        { text = "SPIELER", x = 18, width = 128 },
        { text = "SPEC", x = 154, width = 164 },
        { text = "STATUS", x = 326, width = 92 },
        { text = "BERUFE", x = 426, width = 214 },
        { text = "AKTIV", x = 648, width = 100 },
    }
    for _, headerDefinition in ipairs(headers) do
        local headerLabel = CreateLabel(rosterCard, headerDefinition.text, {
            muted = true,
            font = "GameFontNormalSmall",
            width = headerDefinition.width,
        })
        headerLabel:SetPoint("TOPLEFT", rosterCard, "TOPLEFT", headerDefinition.x, -49)
    end

    local scroll = CreateModernScrollFrame(rosterCard)
    scroll:SetPoint("TOPLEFT", rosterCard, "TOPLEFT", 14, -70)
    scroll:SetPoint("BOTTOMRIGHT", rosterCard, "BOTTOMRIGHT", -16, 14)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(742)
    content:SetHeight(25 * 27)
    scroll:SetScrollChild(content)
    page.raiderRows = {}
    for index = 1, 25 do
        local row = CreatePanel(content, index % 2 == 0 and THEME.input or THEME.card)
        row:SetSize(740, 25)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * 27))
        -- Durchgehend einzeilig: Jede umbrechende Zelle waechst ueber ihre
        -- Zeile hinaus und schiebt sich optisch in die Nachbarzeilen.
        local columns = {
            { key = "name", x = 5, width = 128 },
            { key = "spec", x = 141, width = 164 },
            { key = "status", x = 313, width = 92 },
            { key = "professions", x = 413, width = 214 },
            { key = "activity", x = 635, width = 100 },
        }
        for _, column in ipairs(columns) do
            row[column.key] = CreateLabel(row, "", {
                width = column.width,
                height = 25,
            })
            row[column.key]:SetPoint("LEFT", row, "LEFT", column.x, 0)
        end

        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self)
            if not self.member or not GameTooltip then
                return
            end
            AnchorRowTooltip(self)
            GameTooltip:SetText(GC.Util.PlayerShortName(self.member.name))
            GameTooltip:AddLine(self.tooltipSpec or "", 1, 1, 1, true)
            if self.tooltipProfessions and self.tooltipProfessions ~= "" then
                GameTooltip:AddLine("Berufe: " .. self.tooltipProfessions, 1, 1, 1, true)
            end
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(self.tooltipStatus or "", 0.57, 0.64, 0.72, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        page.raiderRows[index] = row
    end

end

function GC.UI:RefreshDashboard()
    local page = self.pages.OVERVIEW
    if not page then
        return
    end
    local summary = GC.Roster:GetSummary()
    page.metricCards.MEMBERS.value:SetText(summary.total)
    page.metricCards.ONLINE.value:SetText(summary.online)
    page.metricCards.PROFILES.value:SetText(summary.knownProfiles)

    local addonStats = GC.Sync:GetAddonUserStats()
    local addonCard = page.metricCards.ADDON
    -- Gezaehlt werden Spieler, nicht Charaktere: wer mit Main und Twinks
    -- unterwegs war, ist einer. Die Charakterzahl steht daneben, solange sie
    -- abweicht.
    addonCard.value:SetText(addonStats.players)
    local incompatible = addonStats.outdated + addonStats.ahead
    -- Die Karte ist 185 Pixel breit. Alles, was nicht hineinpasst, steht in der
    -- zweiten Zeile, im Tooltip der Karte und ohnehin in der Titelzeile des
    -- Fensters - dreimal derselbe Satz nebeneinander war der Fehler.
    local details = {}
    if addonStats.known > addonStats.players then
        details[#details + 1] = addonStats.known .. " CHARS"
    end
    if incompatible > 0 then
        details[#details + 1] = incompatible .. " ABWEICHEND"
    end
    addonCard.detail:SetText(table.concat(details, "  •  "))
    SetTextColor(addonCard.detail, incompatible > 0 and THEME.warning or THEME.muted)

    local ranks = GC.Roster:GetRankDefinitions()
    local selectedRanks = 0
    for _, rank in ipairs(ranks) do
        if GC.Roster:IsRankActive(rank.index) then
            selectedRanks = selectedRanks + 1
        end
    end
    if #ranks == 0 or selectedRanks == #ranks then
        page.rankFilterButton:SetText("Ränge: alle")
    else
        page.rankFilterButton:SetText("Ränge: " .. selectedRanks .. "/" .. #ranks)
    end

    local raiders = GC.Roster:GetActiveRaiders(25)
    for index, row in ipairs(page.raiderRows) do
        local member = raiders[index]
        row:SetShown(member ~= nil)
        if member then
            local profile = GC.Roster:GetProfile(member.name)
            local primary = profile and GC.SpecByKey[profile.raidSpecKey or profile.detectedSpecKey or ""]
            local secondary = profile and GC.SpecByKey[profile.secondarySpecKey or ""]
            local specText = primary and primary.name or (member.className or "–")
            if secondary then
                specText = specText .. " / " .. secondary.name
            end
            -- Der Status trug frueher drei verschiedene Aussagen in einem Wort.
            -- Farbe und Tooltip trennen sie jetzt: Wer gar kein Profil hat,
            -- ist etwas anderes als wer eines hat und es nicht bestaetigt hat.
            local statusText, statusColor, statusHint
            if not profile then
                statusText = "kein Profil"
                statusColor = THEME.muted
                statusHint = "Dieser Spieler hat sein Raidprofil noch nie ausgefüllt."
            else
                if profile.source == "WARCRAFT_LOGS" then
                    statusText = "Logs"
                    statusHint = "Stammt aus einem Warcraft-Logs-Import, nicht vom Spieler selbst."
                elseif profile.source == "MANUAL" then
                    statusText = "Manuell"
                    statusHint = "Wurde von Hand eingetragen, nicht vom Spieler selbst."
                else
                    -- Angezeigt wird "Twink"; gespeichert und uebertragen wird
                    -- weiterhin "ALT", sonst verstehen sich alte und neue
                    -- Clients beim Abgleich nicht mehr.
                    statusText = profile.mainStatus == "ALT" and "Twink" or "Main"
                    statusHint = profile.mainStatus == "ALT"
                        and "Als Zweitcharakter gemeldet."
                        or "Als Hauptcharakter gemeldet."
                end
                if not profile.confirmed and profile.source ~= "WARCRAFT_LOGS" then
                    statusText = statusText .. " ?"
                    statusColor = THEME.warning
                    statusHint = statusHint .. " Der Spieler hat das Profil noch nicht bestätigt."
                else
                    statusColor = THEME.text
                end
            end

            local professionText = ProfessionSummary(profile)
            row.member = member
            row.tooltipSpec = specText
            row.tooltipProfessions = professionText ~= "–" and professionText or ""
            row.tooltipStatus = statusHint

            row.name:SetText(GC.Util.PlayerShortName(member.name))
            row.name:SetTextColor(ClassColor(member.classFile))
            row.spec:SetText(specText)
            row.status:SetText(statusText)
            SetTextColor(row.status, statusColor)
            row.professions:SetText(professionText)
            SetTextColor(row.professions, professionText == "–" and THEME.muted or THEME.text)
            row.activity:SetText(LastOnlineLabel(member))
        else
            row.member = nil
        end
    end
end

function GC.UI:BuildSettingsPage()
    local page = self.pages.SETTINGS
    CreatePageTitle(page, "Einstellungen",
        "Lokale Komfortoptionen und gildenweite Berechtigungen für Guild Copilot.")

    local scroll = CreateModernScrollFrame(page)
    scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -58)
    scroll:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -4, 0)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(752)
    content:SetHeight(2000)
    scroll:SetScrollChild(content)
    page.settingsScroll = scroll

    local function BuildRankCard(title, x, helpText, onChanged)
        local card = CreateCard(content, title)
        card:SetSize(370, 240)
        card:SetPoint("TOPLEFT", content, "TOPLEFT", x, 0)
        local help = CreateLabel(card, helpText, {
            muted = true,
            width = 334,
            height = 32,
            vertical = "TOP",
        })
        help:SetPoint("TOPLEFT", card, "TOPLEFT", 18, -47)
        local toggles = {}
        for index = 1, 10 do
            local toggle
            toggle = CreateToggle(card, "", function(checked)
                if toggle.rankIndex ~= nil then
                    onChanged(toggle.rankIndex, checked)
                end
            end)
            local column = (index - 1) % 2
            local row = math.floor((index - 1) / 2)
            toggle:SetPoint("TOPLEFT", card, "TOPLEFT", 18 + (column * 175), -82 - (row * 29))
            toggle.text:SetWidth(137)
            toggle.text:SetJustifyH("LEFT")
            toggles[index] = toggle
        end
        return card, toggles
    end

    page.activeRankCard, page.activeRankToggles = BuildRankCard(
        "Aktive Raider",
        0,
        "Diese Ränge erscheinen als Level-70-Raider in der Übersicht.",
        function(rankIndex, checked)
            GC.Roster:SetRankActive(rankIndex, checked)
        end
    )
    page.editorRankCard, page.editorRankToggles = BuildRankCard(
        "Gildenweite Einstellungen bearbeiten",
        382,
        "Nur diese Ränge dürfen Profil, Regeln, Rangfreigaben und Vorlagen ändern.",
        function(rankIndex, checked)
            local success, reason = GC.Roster:SetGuildProfileRankActive(rankIndex, checked)
            if not success then
                if reason == "OWN_RANK" then
                    page.settingsStatus:SetText("Den eigenen Rang kannst du nicht abwählen.")
                elseif reason == "HIGHER_RANK_REQUIRED" then
                    page.settingsStatus:SetText("Diesen Rang darf nur ein höherer Gildenrang abwählen.")
                elseif reason == "LAST_EDITOR" then
                    page.settingsStatus:SetText("Mindestens ein berechtigter Rang muss erhalten bleiben.")
                else
                    page.settingsStatus:SetText("Dein Gildenrang darf diese Berechtigung nicht ändern.")
                end
                SetTextColor(page.settingsStatus, THEME.danger)
                GC.UI:RefreshSettings()
            elseif reason == "RECOVERED" then
                page.settingsStatus:SetText("Dein eigener Rang wurde einmalig wieder freigeschaltet.")
                SetTextColor(page.settingsStatus, THEME.success)
            end
        end
    )

    local accessCard = CreateCard(content, "Mitgliederpflege öffnen")
    accessCard:SetSize(752, 180)
    accessCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -252)
    local accessHelp = CreateLabel(accessCard,
        "Nur diese Ränge sehen die Mitgliederpflege. Die Freigabe wird gildenweit synchronisiert.",
        { muted = true, width = 716, height = 28, vertical = "TOP" })
    accessHelp:SetPoint("TOPLEFT", accessCard, "TOPLEFT", 18, -47)
    page.memberCareAccessToggles = {}
    for index = 1, 10 do
        local toggle
        toggle = CreateToggle(accessCard, "", function(checked)
            if toggle.rankIndex ~= nil
                and not GC.Roster:SetMemberCareAccessRank(toggle.rankIndex, checked) then
                page.settingsStatus:SetText("Mindestens ein Rang muss Zugriff auf die Mitgliederpflege behalten.")
                SetTextColor(page.settingsStatus, THEME.danger)
                GC.UI:RefreshSettings()
            end
        end)
        local column = (index - 1) % 5
        local row = math.floor((index - 1) / 5)
        toggle:SetPoint("TOPLEFT", accessCard, "TOPLEFT", 18 + (column * 145), -85 - (row * 31))
        toggle.text:SetWidth(112)
        toggle.text:SetJustifyH("LEFT")
        page.memberCareAccessToggles[index] = toggle
    end

    local notificationCard = CreateCard(content, "Benachrichtigungen & Zugriff")
    notificationCard:SetSize(752, 226)
    notificationCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -444)
    page.successSoundToggle = CreateToggle(notificationCard, "Erfolgssound aktiv", function(checked)
        GC.DB:GetSettings().successSound = checked
    end)
    page.successSoundToggle:SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 18, -55)

    local soundNames = {}
    for _, sound in ipairs(GC.SuccessSoundOptions) do
        soundNames[#soundNames + 1] = sound.name
    end
    page.successSoundDropdown = CreateChoiceDropdown(notificationCard, 190, soundNames, function(value)
        for _, sound in ipairs(GC.SuccessSoundOptions) do
            if sound.name == value then
                GC.DB:GetSettings().successSoundKey = sound.key
                break
            end
        end
    end, false)
    page.successSoundDropdown:SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 205, -50)
    local testSound = CreateButton(notificationCard, "Sound testen", 130, 32, function()
        GC.Chat:PlaySuccessSound()
    end)
    testSound:SetPoint("LEFT", page.successSoundDropdown, "RIGHT", 8, 0)

    page.captureDuringSearchToggle = CreateToggle(notificationCard, "Whispers nur während einer Suche prüfen", function(checked)
        GC.DB:GetSettings().captureOnlyDuringSearch = checked
    end)
    page.captureDuringSearchToggle:SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 18, -105)
    page.captureDuringSearchToggle.text:SetWidth(290)
    page.watchChannelToggle = CreateToggle(notificationCard, "Öffentliche „Suche Gilde“-Nachrichten erkennen", function(checked)
        GC.DB:GetSettings().watchRecruitmentTriggers = checked
    end)
    page.watchChannelToggle:SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 385, -105)
    page.watchChannelToggle.text:SetWidth(310)

    page.minimapToggle = CreateToggle(notificationCard, "Minimap-Symbol anzeigen", function(checked)
        GC.DB:GetSettings().minimap.hidden = not checked
        GC.UI:RefreshMinimapButton()
    end)
    page.minimapToggle:SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 18, -150)
    page.minimapToggle.text:SetWidth(260)

    -- Der Rueckweg, in einer eigenen Zeile. Neben dem Schalter waere kein Platz:
    -- Rechts davon steht schon die Profilbestaetigung, und beides in eine Zeile
    -- zu quetschen hiesse, dass der Knopf ueber der Beschriftung liegt.
    page.minimapResetButton = CreateButton(notificationCard, "Symbol zurück an die Minimap", 230, 28, function()
        GC.UI:ResetMinimapButton()
        GC.UI:RefreshSettings()
    end)
    page.minimapResetButton:SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 18, -186)
    CreateLabel(notificationCard,
        "Das Symbol lässt sich frei ziehen: nahe der Minimap am Ring entlang, weiter weg überall hin.", {
        muted = true,
        width = 460,
        height = 28,
    }):SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 258, -186)

    -- Eigener Ton fuer die Bestaetigung des eigenen Raidprofils. Bewusst vom
    -- Bewerberklang getrennt: Der eine meldet einen fremden Interessenten, der
    -- andere bestaetigt die eigene Eingabe.
    CreateLabel(notificationCard, "Profilbestätigung:", { muted = true, width = 118, height = 32 })
        :SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 385, -145)
    page.profileSoundDropdown = CreateChoiceDropdown(notificationCard, 190, soundNames, function(value)
        for _, sound in ipairs(GC.SuccessSoundOptions) do
            if sound.name == value then
                GC.DB:GetSettings().profileSoundKey = sound.key
                GC.Chat:PlayProfileSound()
                break
            end
        end
    end, false)
    page.profileSoundDropdown:SetPoint("TOPLEFT", notificationCard, "TOPLEFT", 508, -142)

    -- Der Bewerberton meldet einen fremden Interessenten. Wer nicht rekrutiert,
    -- will ihn nicht hoeren, weiss aber meist nicht, dass er ihn abschalten
    -- koennte - deshalb haengt er am Gildenrang und nicht an jedem selbst.
    local soundRankCard = CreateCard(content, "Bewerberton hören")
    soundRankCard:SetSize(752, 180)
    soundRankCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -684)
    local soundRankHelp = CreateLabel(soundRankCard,
        "Nur diese Ränge hören den Ton, wenn sich jemand im Postfach meldet. Das Postfach füllt sich für alle weiter,"
        .. " nur still. Die Freigabe wird gildenweit synchronisiert.",
        { muted = true, width = 716, height = 28, vertical = "TOP" })
    soundRankHelp:SetPoint("TOPLEFT", soundRankCard, "TOPLEFT", 18, -47)
    page.inboxSoundRankToggles = {}
    for index = 1, 10 do
        local toggle
        toggle = CreateToggle(soundRankCard, "", function(checked)
            if toggle.rankIndex ~= nil
                and not GC.Roster:SetInboxSoundRank(toggle.rankIndex, checked) then
                page.settingsStatus:SetText("Nur freigegebene Gildenränge dürfen den Bewerberton umstellen.")
                SetTextColor(page.settingsStatus, THEME.danger)
                GC.UI:RefreshSettings()
            end
        end)
        local column = (index - 1) % 5
        local row = math.floor((index - 1) / 5)
        toggle:SetPoint("TOPLEFT", soundRankCard, "TOPLEFT", 18 + (column * 145), -85 - (row * 31))
        toggle.text:SetWidth(112)
        toggle.text:SetJustifyH("LEFT")
        page.inboxSoundRankToggles[index] = toggle
    end

    -- Trigger- und Ausschlusswoerter. Bewusst lokal: Sie aendern nur, was im
    -- eigenen Postfach landet. Oeffentliche Nachrichten und Fluestern bleiben
    -- getrennt, weil die Fehlerkosten verschieden sind - ein zu weiter
    -- Whisper-Trigger nervt nur einen selbst, ein zu weiter Chat-Trigger
    -- erzeugt Muell aus dem ganzen Realm.
    local triggerCard = CreateCard(content, "Postfach-Erkennung: eigene Wörter")
    triggerCard:SetSize(752, 400)
    triggerCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -876)
    CreateLabel(triggerCard,
        "Ein Wort oder eine Wendung je Zeile, Groß- und Kleinschreibung ist gleich. Ein Ausschlusswort verhindert den"
        .. " Eintrag auch dann, wenn ein Trigger passt. Leere Trigger-Felder bedeuten „Vorgabe“, nicht „nichts“ –"
        .. " abschalten lässt sich die Erkennung über die Schalter darüber. Diese Listen gelten nur für dich.",
        { muted = true, width = 716, height = 44, vertical = "TOP" })
        :SetPoint("TOPLEFT", triggerCard, "TOPLEFT", 18, -44)

    page.recruitmentWordEdits = {}
    local wordFields = {
        { key = "chatTriggers", label = "Öffentlicher Chat – Trigger", x = 18, y = -96 },
        { key = "chatExclusions", label = "Öffentlicher Chat – Ausschluss", x = 386, y = -96 },
        { key = "whisperTriggers", label = "Flüstern – Trigger", x = 18, y = -212 },
        { key = "whisperExclusions", label = "Flüstern – Ausschluss", x = 386, y = -212 },
    }
    for _, definition in ipairs(wordFields) do
        CreateLabel(triggerCard, definition.label, { muted = true, width = 348, height = 18 })
            :SetPoint("TOPLEFT", triggerCard, "TOPLEFT", definition.x, definition.y)
        local edit = CreateTextArea(triggerCard, 348, 88, 800)
        edit.container:SetPoint("TOPLEFT", triggerCard, "TOPLEFT", definition.x, definition.y - 20)
        page.recruitmentWordEdits[definition.key] = edit
    end

    page.saveRecruitmentWords = CreateButton(triggerCard, "Wörter speichern", 160, 34, function()
        for key, edit in pairs(page.recruitmentWordEdits) do
            GC.Chat:SetRecruitmentWordText(key, edit:GetText())
        end
        page.recruitmentWordStatus:SetText("Gespeichert. Leere Trigger-Felder nutzen wieder die Vorgabe.")
        SetTextColor(page.recruitmentWordStatus, THEME.success)
        GC.UI:RefreshSettings()
    end, "PRIMARY")
    page.saveRecruitmentWords:SetPoint("TOPLEFT", triggerCard, "TOPLEFT", 18, -324)

    CreateButton(triggerCard, "Vorgabe wiederherstellen", 200, 34, function()
        GC.Chat:RestoreRecruitmentDefaults()
        page.recruitmentWordStatus:SetText("Alle vier Listen stehen wieder auf der Vorgabe.")
        SetTextColor(page.recruitmentWordStatus, THEME.success)
        GC.UI:RefreshSettings()
    end):SetPoint("TOPLEFT", triggerCard, "TOPLEFT", 186, -324)

    -- Wer die Vorgabe nur um ein Wort ergaenzen will, soll sie nicht abtippen
    -- muessen. Der Knopf traegt sie in die Felder ein, gespeichert wird erst
    -- mit "Woerter speichern".
    CreateButton(triggerCard, "Vorgabe eintragen", 170, 34, function()
        for key, edit in pairs(page.recruitmentWordEdits) do
            edit:SetText(GC.Chat:GetRecruitmentDefaultText(key))
        end
        page.recruitmentWordStatus:SetText("Vorgabe eingetragen – jetzt bearbeiten und speichern.")
        SetTextColor(page.recruitmentWordStatus, THEME.muted)
    end):SetPoint("TOPLEFT", triggerCard, "TOPLEFT", 394, -324)

    page.recruitmentWordStatus = CreateLabel(triggerCard, "", { width = 716, height = 18 })
    page.recruitmentWordStatus:SetPoint("TOPLEFT", triggerCard, "TOPLEFT", 18, -366)

    local gearCard = CreateCard(content, "Ausrüstung – Hintergrundabgleich")
    gearCard:SetSize(752, 132)
    gearCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -1288)
    CreateLabel(gearCard,
        "Die eigene Ausrüstung wird immer automatisch geprüft und kompakt mit Addon-Nutzern der Gilde abgeglichen.", {
        muted = true,
        width = 716,
        height = 18,
    }):SetPoint("TOPLEFT", gearCard, "TOPLEFT", 18, -44)

    page.gearAcceptToggle = CreateToggle(gearCard, "Vorhandene Verzauberung gilt als in Ordnung", function(checked)
        GC.DB:GetSettings().gearAudit.acceptUnratedEnchants = checked
        GC.GearAudit:ReapplyEnchantRules()
        GC.UI:RefreshGear()
    end)
    page.gearAcceptToggle:SetPoint("TOPLEFT", gearCard, "TOPLEFT", 18, -70)
    page.gearAcceptToggle.text:SetWidth(360)

    CreateLabel(gearCard, "Ohne diesen Schalter bleibt jede nicht bewertete Verzauberung \"Unbekannt\"."
        .. " Er bewertet keine Qualität, er unterscheidet nur verzaubert von nicht verzaubert.", {
        muted = true,
        width = 716,
        height = 30,
        vertical = "TOP",
    }):SetPoint("TOPLEFT", gearCard, "TOPLEFT", 18, -96)

    -- Klang und Bildschirmmeldung der Gildenaufträge. Jedes Ereignis hat
    -- seinen eigenen Ton aus der bekannten Klangliste; "Aus" schaltet es ab.
    local orderCard = CreateCard(content, "Gildenaufträge")
    orderCard:SetSize(752, 352)
    orderCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -1432)
    local orderSoundNames = { "Aus" }
    for _, sound in ipairs(GC.SuccessSoundOptions) do
        orderSoundNames[#orderSoundNames + 1] = sound.name
    end
    local function OrderSoundDropdown(labelText, y, eventKey)
        CreateLabel(orderCard, labelText, { muted = true, width = 236, height = 30 })
            :SetPoint("TOPLEFT", orderCard, "TOPLEFT", 18, y)
        local dropdown = CreateChoiceDropdown(orderCard, 190, orderSoundNames, function(value)
            local settings = GC.DB:GetSettings()
            settings.orderSounds = settings.orderSounds or {}
            if value == "Aus" then
                settings.orderSounds[eventKey] = ""
                return
            end
            for _, sound in ipairs(GC.SuccessSoundOptions) do
                if sound.name == value then
                    settings.orderSounds[eventKey] = sound.key
                    GC.Chat:PlaySuccessSound(sound.key)
                    break
                end
            end
        end, false)
        dropdown:SetPoint("TOPLEFT", orderCard, "TOPLEFT", 262, y)
        return dropdown
    end
    page.orderSoundNew = OrderSoundDropdown("Neuer machbarer Auftrag", -48, "newOrder")
    page.orderSoundAccepted = OrderSoundDropdown("Auftrag angenommen", -86, "accepted")
    page.orderSoundProgress = OrderSoundDropdown("Fortschritt an eigenen Aufträgen", -124, "progress")
    page.orderSoundDone = OrderSoundDropdown("Auftrag abgeschlossen", -162, "done")

    CreateLabel(orderCard, "Anzeigedauer der Meldung (Sekunden)",
        { muted = true, width = 236, height = 30 })
        :SetPoint("TOPLEFT", orderCard, "TOPLEFT", 18, -200)
    page.orderBannerHold = CreateEdit(orderCard, 60, 26)
    page.orderBannerHold.container:SetPoint("TOPLEFT", orderCard, "TOPLEFT", 262, -202)
    page.orderBannerHold:SetScript("OnTextChanged", function(edit)
        local seconds = tonumber(GC.Util.Trim(edit:GetText()))
        if seconds then
            GC.DB:GetSettings().orderBanner.holdSeconds =
                math.max(1, math.min(30, math.floor(seconds)))
        end
    end)

    page.orderBannerToggle = CreateToggle(orderCard,
        "Bildschirmmeldung bei neuen machbaren Aufträgen", function(checked)
        GC.DB:GetSettings().orderBanner.enabled = checked
    end)
    page.orderBannerToggle:SetPoint("TOPLEFT", orderCard, "TOPLEFT", 18, -238)
    page.orderBannerToggle.text:SetWidth(340)

    page.orderBannerTest = CreateButton(orderCard, "Meldung testen", 150, 30, function()
        -- Klang und Meldung zusammen, wie im Ernstfall. Der Positionier-Modus
        -- zeigt Kasten und Rand, damit sich der Anker mit der Maus greifen
        -- und verschieben lässt.
        GC.Orders:PlayEventSound("newOrder")
        GC.UI:ShowOrderBanner("Neuer Gildenauftrag von "
            .. GC.Util.PlayerShortName(GC:GetPlayerFullName()), true)
    end)
    page.orderBannerTest:SetPoint("TOPRIGHT", orderCard, "TOPRIGHT", -14, -196)
    page.orderBannerReset = CreateButton(orderCard, "Position zurücksetzen", 150, 26, function()
        local bannerSettings = GC.DB:GetSettings().orderBanner
        bannerSettings.x = 0
        bannerSettings.y = 200
        if GC.UI.orderBanner then
            GC.UI.orderBanner:ClearAllPoints()
            GC.UI.orderBanner:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
        end
        GC.UI:ShowOrderBanner("Neuer Gildenauftrag von "
            .. GC.Util.PlayerShortName(GC:GetPlayerFullName()), true)
    end)
    page.orderBannerReset:SetPoint("TOPRIGHT", orderCard, "TOPRIGHT", -14, -232)

    -- Der Übergabetext fürs Anflüstern: {name} und {rezept} werden ersetzt,
    -- gesendet wird erst mit Enter im Chat.
    CreateLabel(orderCard, "Übergabetext ({name} und {rezept} werden ersetzt)",
        { muted = true, width = 400, height = 15 })
        :SetPoint("TOPLEFT", orderCard, "TOPLEFT", 18, -272)
    page.orderWhisperEdit = CreateEdit(orderCard, 698, 26)
    page.orderWhisperEdit.container:SetPoint("TOPLEFT", orderCard, "TOPLEFT", 18, -290)
    page.orderWhisperEdit:SetScript("OnTextChanged", function(edit)
        local text = GC.Util.Trim(edit:GetText())
        if text ~= "" then
            GC.DB:GetSettings().orderWhisperText = text
        end
    end)

    CreateLabel(orderCard,
        "Die Meldung lässt sich mit der Maus dorthin schieben, wo sie nichts verdeckt.", {
        muted = true,
        width = 716,
        height = 16,
    }):SetPoint("TOPLEFT", orderCard, "TOPLEFT", 18, -326)

    -- Die Chatbefehle dort, wo man sie sucht (Owner-Wunsch): auf der
    -- Einstellungsseite, gespeist aus derselben Tabelle wie /gcp help.
    local commandCard = CreateCard(content, "Chat-Befehle")
    commandCard:SetSize(752, 156)
    commandCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -1800)
    for index, entry in ipairs(SLASH_COMMANDS) do
        CreateLabel(commandCard, "|cffffffff" .. entry.command .. "|r – " .. entry.description, {
            muted = true,
            font = "GameFontNormalSmall",
            width = 716,
            height = 15,
        }):SetPoint("TOPLEFT", commandCard, "TOPLEFT", 18, -40 - ((index - 1) * 18))
    end

    page.settingsStatus = CreateLabel(content, "", { width = 716, height = 18 })
    page.settingsStatus:SetPoint("TOPLEFT", content, "TOPLEFT", 18, -1968)
end

function GC.UI:RefreshSettings()
    local page = self.pages.SETTINGS
    if not page then
        return
    end
    local ranks = GC.Roster:GetRankDefinitions()
    local canEditGuildProfile = GC.Roster:CanEditGuildProfile()
    for index = 1, 10 do
        local rank = ranks[index]
        local activeToggle = page.activeRankToggles[index]
        local editorToggle = page.editorRankToggles[index]
        local memberCareAccessToggle = page.memberCareAccessToggles[index]
        local inboxSoundToggle = page.inboxSoundRankToggles[index]
        activeToggle:SetShown(rank ~= nil)
        editorToggle:SetShown(rank ~= nil)
        memberCareAccessToggle:SetShown(rank ~= nil)
        inboxSoundToggle:SetShown(rank ~= nil)
        if rank then
            activeToggle.rankIndex = rank.index
            activeToggle.text:SetText(rank.name)
            SetToggle(activeToggle, GC.Roster:IsRankActive(rank.index))
            if canEditGuildProfile then
                activeToggle:Enable()
            else
                activeToggle:Disable()
            end
            editorToggle.rankIndex = rank.index
            editorToggle.text:SetText(rank.name)
            SetToggle(editorToggle, GC.Roster:IsGuildProfileEditorRank(rank.index))
            memberCareAccessToggle.rankIndex = rank.index
            memberCareAccessToggle.text:SetText(rank.name)
            SetToggle(memberCareAccessToggle, GC.Roster:IsMemberCareAccessRank(rank.index))
            inboxSoundToggle.rankIndex = rank.index
            inboxSoundToggle.text:SetText(rank.name)
            SetToggle(inboxSoundToggle, GC.Roster:IsInboxSoundRank(rank.index))
            if canEditGuildProfile then
                inboxSoundToggle:Enable()
            else
                inboxSoundToggle:Disable()
            end
            if canEditGuildProfile or GC.Roster:CanUseEditorRecovery(rank.index) then
                editorToggle:Enable()
            else
                editorToggle:Disable()
            end
            if canEditGuildProfile then
                memberCareAccessToggle:Enable()
            else
                memberCareAccessToggle:Disable()
            end
        else
            activeToggle.rankIndex = nil
            editorToggle.rankIndex = nil
            memberCareAccessToggle.rankIndex = nil
            inboxSoundToggle.rankIndex = nil
        end
    end

    local settings = GC.DB:GetSettings()
    SetToggle(page.successSoundToggle, settings.successSound)
    SetToggle(page.captureDuringSearchToggle, settings.captureOnlyDuringSearch)
    SetToggle(page.watchChannelToggle, settings.watchRecruitmentTriggers)
    SetToggle(page.minimapToggle, not settings.minimap.hidden)
    -- Der Rueckholknopf hat nur einen Sinn, wenn das Symbol tatsaechlich frei
    -- steht und sichtbar ist.
    SetButtonEnabled(page.minimapResetButton,
        settings.minimap.free == true and settings.minimap.hidden ~= true)
    SetToggle(page.gearAcceptToggle, GC.GearAudit:AcceptsUnratedEnchants())
    local selectedSoundName = GC.SuccessSoundOptions[1].name
    for _, sound in ipairs(GC.SuccessSoundOptions) do
        if sound.key == settings.successSoundKey then
            selectedSoundName = sound.name
            break
        end
    end
    page.successSoundDropdown:SetValue(selectedSoundName)

    local profileSoundName
    for _, sound in ipairs(GC.SuccessSoundOptions) do
        if sound.key == (settings.profileSoundKey or GC.DefaultProfileSoundKey) then
            profileSoundName = sound.name
            break
        end
    end
    page.profileSoundDropdown:SetValue(profileSoundName or GC.SuccessSoundOptions[1].name)

    local orderSounds = settings.orderSounds or {}
    local function OrderSoundName(eventKey, fallbackKey)
        local key = orderSounds[eventKey]
        if key == "" then
            return "Aus"
        end
        key = key or fallbackKey
        for _, sound in ipairs(GC.SuccessSoundOptions) do
            if sound.key == key then
                return sound.name
            end
        end
        return "Aus"
    end
    page.orderSoundNew:SetValue(OrderSoundName("newOrder", "LEVEL_UP"))
    page.orderSoundAccepted:SetValue(OrderSoundName("accepted", "IG_QUEST_ACTIVATE"))
    page.orderSoundProgress:SetValue(OrderSoundName("progress", "MAP_PING"))
    page.orderSoundDone:SetValue(OrderSoundName("done", "IG_QUEST_LIST_COMPLETE"))
    SetToggle(page.orderBannerToggle, settings.orderBanner.enabled ~= false)
    page.orderBannerHold:SetText(tostring(tonumber(settings.orderBanner.holdSeconds) or 3))
    page.orderWhisperEdit:SetText(settings.orderWhisperText or "")

    -- Ein leeres Feld heisst "Vorgabe". Damit niemand raten muss, welche
    -- Erkennung gerade greift, steht es ausgeschrieben unter den Feldern.
    local defaultLabels = {
        chatTriggers = "öffentlicher Chat",
        whisperTriggers = "Flüstern",
    }
    local usingDefaults = {}
    for _, key in ipairs({ "chatTriggers", "whisperTriggers" }) do
        if GC.Chat:GetRecruitmentWordText(key) == "" then
            usingDefaults[#usingDefaults + 1] = defaultLabels[key]
        end
    end
    for key, edit in pairs(page.recruitmentWordEdits) do
        if not edit:HasFocus() then
            edit:SetText(GC.Chat:GetRecruitmentWordText(key))
        end
    end
    if page.recruitmentWordStatus:GetText() == "" then
        if #usingDefaults > 0 then
            page.recruitmentWordStatus:SetText("Vorgabe greift bei: "
                .. GC.Util.JoinGerman(usingDefaults) .. ".")
        else
            page.recruitmentWordStatus:SetText("Es gelten durchgehend deine eigenen Listen.")
        end
        SetTextColor(page.recruitmentWordStatus, THEME.muted)
    end

    if canEditGuildProfile then
        if page.settingsStatus:GetText() == "" then
            page.settingsStatus:SetText("Gildenweite Änderungen sind für deinen Rang freigegeben.")
            SetTextColor(page.settingsStatus, THEME.muted)
        end
    else
        page.settingsStatus:SetText(
            "Gildenweite Einstellungen sind für deinen Rang schreibgeschützt; lokale Optionen bleiben änderbar.")
        SetTextColor(page.settingsStatus, THEME.warning)
    end

    page.settingsScroll:UpdateModernThumb()
end

-- === Willkommensfenster ====================================================
--
-- Beim ersten Login eines Charakters: das Schriftlogo und genau ein Knopf.
-- Kein Text, keine zweite Wahl - was zu tun ist, steht danach als Checkliste
-- auf der Profilseite, und die ist der eigentliche Inhalt. Ein Fenster, das
-- schon hier alles erklaert, wird ueberblaettert.
function GC.UI:CreateWelcomeFrame()
    if self.welcomeFrame then
        return self.welcomeFrame
    end

    local frame = CreatePanel(UIParent, THEME.window, THEME.accent, "GuildCopilotWelcomeFrame")
    frame:SetSize(420, 380)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:Hide()
    table.insert(UISpecialFrames, "GuildCopilotWelcomeFrame")

    local wordmark = frame:CreateTexture(nil, "ARTWORK")
    wordmark:SetSize(300, 300)
    wordmark:SetPoint("TOP", frame, "TOP", 0, -8)
    wordmark:SetTexture("Interface\\AddOns\\GuildCopilot\\Media\\GuildCopilotWordmark")

    local start = CreateButton(frame, "Einrichtung starten", 240, 42, function()
        GC.UI:HideWelcome()
        GC.UI:CreateMainFrame()
        GC.UI.frame:Show()
        GC.UI:ShowPage("ROSTER")
        local page = GC.UI.pages.ROSTER
        if page and page.profileScroll then
            page.profileScroll:SetVerticalScroll(0)
            page.profileScroll:UpdateModernThumb()
        end
    end, "PRIMARY")
    start:SetPoint("BOTTOM", frame, "BOTTOM", 0, 28)
    start.label:SetFontObject("GameFontNormalLarge")

    -- Ein × und die Escape-Taste, sonst waere das Fenster eine Falle. Es ist
    -- bewusst unscheinbar: Der eine Knopf soll der Weg sein, nicht dieser.
    local close = CreateButton(frame, "×", 24, 24, function()
        GC.UI:HideWelcome()
    end)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)

    self.welcomeFrame = frame
    return frame
end

function GC.UI:ShowWelcome()
    self:CreateWelcomeFrame()
    self.welcomeFrame:Show()
end

function GC.UI:HideWelcome()
    if self.welcomeFrame then
        self.welcomeFrame:Hide()
    end
end

-- Zu welcher Karte ein Klick auf eine Checklistenzeile rollt. Alle drei
-- Schritte liegen auf dieser Seite, es ist also ein Rollen und kein
-- Seitenwechsel.
local ONBOARDING_SCROLL_TARGET = {
    PROFILE = "profileCard",
    PROFESSIONS = "professionCard",
    GEAR = "gearCard",
}

-- Rollt die Profilseite an den Kopf einer Karte. Die Position kommt aus
-- ROSTER_CARDS samt der Verschiebung durch die Checkliste, damit hier keine
-- zweite Kopie derselben Masse entsteht.
function GC.UI:ScrollRosterToCard(cardKey)
    local page = self.pages.ROSTER
    if not page or not page.profileScroll then
        return
    end
    local target = 0
    for _, definition in ipairs(ROSTER_CARDS) do
        if definition.key == cardKey then
            target = definition.top
        end
    end
    if page.onboardingCard and page.onboardingCard:IsShown() then
        target = target + ROSTER_ONBOARDING_HEIGHT + ROSTER_CARD_GAP
    end
    local range = tonumber(page.profileScroll:GetVerticalScrollRange()) or 0
    page.profileScroll:SetVerticalScroll(math.max(0, math.min(target, range)))
    page.profileScroll:UpdateModernThumb()
end

-- Die Checkliste "Erste Schritte". Kein Wizard-Fenster: Die drei Schritte
-- stehen auf genau dieser Seite, die Karte zeigt nur, was davon noch offen
-- ist. Einen "Weiter"-Knopf gibt es deshalb nicht - die echte Aktion schiebt
-- die Liste weiter.
--
-- Die Zustandszeichen sind Texturen und keine Schriftzeichen: Die Spielschrift
-- kennt weder Haken noch Pfeil und zeichnet dafuer leere Kaesten (dieselbe
-- Lektion wie bei der Profilbestaetigung in 0.9.39).
function GC.UI:BuildOnboardingCard(page, content)
    local card = CreateCard(content, "Erste Schritte")
    card:SetSize(752, ROSTER_ONBOARDING_HEIGHT)
    card:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    card:Hide()
    page.onboardingCard = card

    local close = CreateButton(card, "×", 24, 24, function()
        GC.Onboarding:HideForSession()
        GC.UI:RefreshRoster()
    end)
    close:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -12)

    page.onboardingRows = {}
    for index = 1, 3 do
        local row = CreateFrame("Button", nil, card)
        row:SetSize(716, 40)
        row:SetPoint("TOPLEFT", card, "TOPLEFT", 18, -52 - ((index - 1) * 44))
        row:SetScript("OnClick", function(selfRow)
            GC.UI:ScrollRosterToCard(ONBOARDING_SCROLL_TARGET[selfRow.stepKey or ""])
        end)

        row.dot = row:CreateTexture(nil, "ARTWORK")
        row.dot:SetSize(10, 10)
        row.dot:SetTexture(WHITE_TEXTURE)
        row.dot:SetPoint("TOPLEFT", row, "TOPLEFT", 5, -5)

        row.mark = row:CreateTexture(nil, "OVERLAY")
        row.mark:SetSize(22, 22)
        row.mark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        row.mark:SetPoint("TOPLEFT", row, "TOPLEFT", -1, 3)
        row.mark:Hide()

        row.label = CreateLabel(row, "", { width = 420, height = 18 })
        row.label:SetPoint("TOPLEFT", row, "TOPLEFT", 26, 0)
        row.detail = CreateLabel(row, "", {
            muted = true,
            font = "GameFontNormalSmall",
            width = 560,
            height = 18,
        })
        row.detail:SetPoint("TOPLEFT", row, "TOPLEFT", 26, -19)

        row.skip = CreateButton(row, "Überspringen", 106, 22, function(selfButton)
            GC.Onboarding:SetStepSkipped(selfButton.stepKey, true)
            GC.UI:RefreshRoster()
        end)
        row.skip:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -1)
        row.skip.label:SetFontObject("GameFontNormalSmall")

        page.onboardingRows[index] = row
    end

    page.onboardingDismiss = CreateButton(card, "Nicht mehr anzeigen", 150, 24, function()
        GC.Onboarding:Dismiss()
        GC.UI:RefreshRoster()
    end)
    page.onboardingDismiss:SetPoint("TOPLEFT", card, "TOPLEFT", 18, -190)
    page.onboardingDismiss.label:SetFontObject("GameFontNormalSmall")

    page.onboardingStatus = CreateLabel(card, "", { width = 540, height = 24 })
    page.onboardingStatus:SetPoint("LEFT", page.onboardingDismiss, "RIGHT", 12, 0)
end

-- Der Punkt am Minimap-Symbol. Getrennt vom Zeichnen der Karte, weil er auch
-- dann stimmen muss, wenn das Fenster zu ist - und das ist der Regelfall.
-- Wendet die Handordnung einer Auswertung auf die Teilnehmerliste an.
-- Unbekannte Namen (nachträglich empfangene Teilnehmer) hängen hinten an,
-- damit niemand aus der Liste fällt.
function GC.UI.ArrangeParticipants(participants, manualOrder)
    if type(manualOrder) ~= "table" or #manualOrder == 0 then
        return participants
    end
    local byName = {}
    for _, participant in ipairs(participants) do
        byName[GC.Util.NormalizeName(participant.name)] = participant
    end
    local arranged = {}
    for _, name in ipairs(manualOrder) do
        local key = GC.Util.NormalizeName(name)
        if byName[key] then
            arranged[#arranged + 1] = byName[key]
            byName[key] = nil
        end
    end
    for _, participant in ipairs(participants) do
        if byName[GC.Util.NormalizeName(participant.name)] then
            arranged[#arranged + 1] = participant
        end
    end
    return arranged
end

-- Das Ziehen einer Teilnehmerzeile: Die gerade angezeigte Reihenfolge wird
-- zur Handordnung dieser Auswertung, die gezogene Zeile wandert an die
-- Zielposition, und die Spaltensortierung tritt zurück.
function GC.UI:MoveParticipantRow(fromIndex, toIndex)
    local page = self.pages.STATISTICS
    local displayed = page and page.displayedParticipants
    local selected = page and page.selectedSummary
    if not displayed or not selected or not displayed[fromIndex] then
        return false
    end
    local names = {}
    for index, participant in ipairs(displayed) do
        names[index] = participant.name
    end
    local moved = table.remove(names, fromIndex)
    table.insert(names, math.max(1, math.min(toIndex, #names + 1)), moved)
    selected.manualOrder = names
    page.sortKey = nil
    self:RefreshStatistics()
    return true
end

function GC.UI:RefreshMinimapMarker()
    local button = self.minimapButton
    if not button or not button.pending then
        return
    end
    -- Der Punkt zeigt "hier wartet etwas auf dich": offene Einrichtung oder
    -- Gildenaufträge, bei denen der eigene Account dran ist.
    button.pending:SetShown(GC.Onboarding:IsPending()
        or (GC.Orders and GC.Orders:GetActionableCount() > 0))
end

function GC.UI:RefreshOnboarding()
    self:RefreshMinimapMarker()
    local page = self.pages.ROSTER
    if not page or not page.onboardingCard then
        return
    end

    local show = GC.Onboarding:ShouldShow()
    self:LayoutRosterPage(show)
    if not show then
        return
    end

    local steps = GC.Onboarding:GetSteps()
    for index, row in ipairs(page.onboardingRows) do
        local step = steps[index]
        row:SetShown(step ~= nil)
        if step then
            row.stepKey = step.key
            row.skip.stepKey = step.key
            row.label:SetText(step.label)
            row.skip:SetShown(not step.done and not step.skipped)

            if step.done then
                row.mark:Show()
                row.dot:Hide()
                SetTextColor(row.label, THEME.text)
                row.detail:SetText(step.detail or "")
            elseif step.active then
                row.mark:Hide()
                row.dot:Show()
                SetTextureColor(row.dot, THEME.accent)
                SetTextColor(row.label, THEME.text)
                -- Nur der aktuelle Schritt erklaert sich; drei Erklaerungen
                -- gleichzeitig sind keine Anleitung mehr, sondern ein Text.
                row.detail:SetText(step.hint or "")
            else
                row.mark:Hide()
                row.dot:Show()
                -- Uebersprungen tritt weiter zurueck als bloss offen: Der eine
                -- Schritt ist abgewaehlt, der andere kommt noch.
                SetTextureColor(row.dot, step.skipped and THEME.border or THEME.muted)
                SetTextColor(row.label, THEME.muted)
                row.detail:SetText(step.skipped and "Übersprungen" or "")
            end
        end
    end

    if GC.Onboarding:IsFinished() then
        if GC.Onboarding:NoteCompleted() and GC.Chat and GC.Chat.PlayProfileSound then
            GC.Chat:PlayProfileSound()
        end
        page.onboardingStatus:SetText("Fertig – dieser Charakter ist eingerichtet.")
        SetTextColor(page.onboardingStatus, THEME.success)
    else
        page.onboardingStatus:SetText("")
    end
end

function GC.UI:BuildRosterPage()
    local page = self.pages.ROSTER
    CreatePageTitle(page, "Dein Profil",
        "Raidprofil, Berufe und Abmeldung an einem Ort – diese Angaben werden mit Guild-Copilot-Nutzern in deiner Gilde synchronisiert.")

    local scroll = CreateModernScrollFrame(page)
    scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -58)
    scroll:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -4, 0)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(752)
    content:SetHeight(ROSTER_CONTENT_HEIGHT)
    scroll:SetScrollChild(content)
    page.profileScroll = scroll
    page.profileContent = content

    self:BuildOnboardingCard(page, content)

    local profileCard = CreateCard(content, "Dein Raidprofil")
    profileCard:SetSize(374, 408)
    page.profileCard = profileCard

    page.detectedText = CreateLabel(profileCard, "", { muted = true, width = 338, height = 36, vertical = "TOP" })
    page.detectedText:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -50)

    local primaryLabel = CreateLabel(profileCard, "Primär-Spec")
    primaryLabel:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -95)
    page.profileSpecButtons = {}
    for index = 1, 3 do
        local button = CreateButton(profileCard, "", 106, 32, function(selfButton)
            page.selectedProfileSpec = selfButton.specKey
            if page.selectedSecondarySpec == selfButton.specKey then
                page.selectedSecondarySpec = nil
            end
            GC.UI:RefreshRoster()
        end)
        button:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18 + ((index - 1) * 113), -120)
        page.profileSpecButtons[index] = button
    end

    local secondaryLabel = CreateLabel(profileCard, "Dual-Spec (optional)")
    secondaryLabel:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -169)
    page.noSecondaryButton = CreateButton(profileCard, "Keiner", 78, 32, function()
        page.selectedSecondarySpec = nil
        GC.UI:RefreshRoster()
    end)
    page.noSecondaryButton:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -194)
    page.secondarySpecButtons = {}
    for index = 1, 3 do
        local button = CreateButton(profileCard, "", 80, 32, function(selfButton)
            if selfButton.specKey ~= page.selectedProfileSpec then
                page.selectedSecondarySpec = selfButton.specKey
            end
            GC.UI:RefreshRoster()
        end)
        button:SetPoint("LEFT", page.noSecondaryButton, "RIGHT", 7 + ((index - 1) * 87), 0)
        page.secondarySpecButtons[index] = button
    end

    -- Jede Aenderung frischt die Karte auf: Nur so faellt der Haken der letzten
    -- Bestaetigung weg und der Hinweis erscheint, dass erneut zu bestaetigen
    -- ist. Ohne den Aufruf blieb die Rueckmeldung bis zum naechsten
    -- Seitenwechsel auf dem alten Stand.
    page.mainCheck = CreateToggle(profileCard, "Main", function(enabled)
        if enabled then
            page.selectedMainStatus = "MAIN"
            SetToggle(page.altCheck, false)
        else
            SetToggle(page.mainCheck, true)
        end
        GC.UI:RefreshRoster()
    end)
    page.mainCheck:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -251)

    page.altCheck = CreateToggle(profileCard, "Twink", function(enabled)
        if enabled then
            page.selectedMainStatus = "ALT"
            SetToggle(page.mainCheck, false)
        else
            SetToggle(page.altCheck, true)
        end
        GC.UI:RefreshRoster()
    end)
    page.altCheck:SetPoint("LEFT", page.mainCheck, "RIGHT", 92, 0)

    page.flexCheck = CreateToggle(profileCard, "Flexibel einsetzbar", function(enabled)
        page.selectedFlex = enabled
        GC.UI:RefreshRoster()
    end)
    page.flexCheck:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -292)

    local confirm = CreateButton(profileCard, "Bestätigen", 190, 38, function()
        local profile, message = GC.Profile:Confirm(
            page.selectedProfileSpec,
            page.selectedSecondarySpec,
            page.selectedMainStatus,
            page.selectedFlex
        )
        if not profile and message then
            GC:Print(message)
        end
        GC.UI:RefreshRoster()
    end, "PRIMARY")
    confirm:SetPoint("BOTTOMLEFT", profileCard, "BOTTOMLEFT", 18, 18)

    -- Ergebnis der letzten Bestaetigung. Im Chat war es nach ein paar
    -- Kampfmeldungen weggescrollt; hier steht es, bis sich etwas aendert.
    --
    -- Der Erfolgsfall braucht keine Worte: ein Haken genuegt, und ein Datum
    -- passte neben dem Knopf ohnehin nicht hin. Nur ein Fehlschlag muss
    -- erklaeren, was zu tun ist.
    page.profileStatusMark = profileCard:CreateTexture(nil, "OVERLAY")
    page.profileStatusMark:SetSize(28, 28)
    page.profileStatusMark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    page.profileStatusMark:SetPoint("LEFT", confirm, "RIGHT", 8, 0)
    page.profileStatusMark:Hide()

    -- Die Rueckmeldung steht ueber dem Knopf und nicht daneben: Neben ihm blieb
    -- nur eine schmale Spalte, in der jeder erklaerende Satz abgeschnitten
    -- wurde - und ausgerechnet der Fehlschlag muss sagen, was zu tun ist.
    page.profileStatus = CreateLabel(profileCard, "",
        { width = 338, height = 32, font = "GameFontNormalSmall", multiline = true, vertical = "TOP" })
    page.profileStatus:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -316)

    local professions = CreateCard(content, "Deine Berufe")
    professions:SetSize(388, 408)
    page.professionCard = professions
    -- Zwei Dinge, die beide "Berufe" heissen und leicht verwechselt werden:
    -- die Namen hier oben liest das Addon selbst aus deinen Faehigkeiten, die
    -- Rezepte dagegen gibt WoW nur bei geoeffnetem Berufsfenster heraus.
    local professionHelp = CreateLabel(professions,
        "Deine beiden Hauptberufe – vom Addon aus deinen Fähigkeiten gelesen, sonst hier von Hand wählbar. Für die Rezepte in der Gildenwerkstatt musst du dein Berufsfenster einmal öffnen; die Namen allein genügen dafür nicht.",
        { muted = true, width = 352, height = 64, vertical = "TOP" })
    professionHelp:SetPoint("TOPLEFT", professions, "TOPLEFT", 18, -54)

    page.professionDropdowns = {}
    for slot = 1, 2 do
        local professionSlot = slot
        local dropdown = CreateChoiceDropdown(professions, 170, GC.ProfessionOptions, function(value)
            if GC.Util.Trim(value) == "" then
                -- Die leere Auswahl heißt: wieder automatisch aus den
                -- Fähigkeiten lesen. Den früheren Übernehmen-Knopf ersetzt
                -- das vollständig.
                GC.Profile:EnableProfessionSync()
            else
                GC.Profile:SetProfession(professionSlot, value)
            end
            GC.UI:RefreshRoster()
        end)
        dropdown:SetPoint("TOPLEFT", professions, "TOPLEFT", 18 + ((slot - 1) * 182), -130)
        page.professionDropdowns[slot] = dropdown
    end
    -- Statt eines Übernehmen-Knopfs (die Übernahme läuft von selbst) steht
    -- hier der Werkstatt-Stand je Beruf: Skill, geteilte Rezepte, Alter des
    -- letzten Einlesens - und der nächste Schritt, wenn Rezepte fehlen.
    page.professionLines = {}
    for slot = 1, 2 do
        local line = CreateLabel(professions, "", { width = 352, height = 20 })
        line:SetPoint("TOPLEFT", professions, "TOPLEFT", 18, -184 - ((slot - 1) * 24))
        page.professionLines[slot] = line
    end
    page.professionStatus = CreateLabel(professions, "", { muted = true, width = 352, height = 42, vertical = "TOP" })
    page.professionStatus:SetPoint("TOPLEFT", professions, "TOPLEFT", 18, -238)
    local workshopButton = CreateButton(professions, "Zur Gildenwerkstatt", 210, 36, function()
        GC.UI:ShowPage("WORKSHOP")
    end)
    workshopButton:SetPoint("BOTTOMLEFT", professions, "BOTTOMLEFT", 18, 18)

    local absenceCard = CreateCard(content, "Deine Abmeldung")
    absenceCard:SetSize(752, 180)
    page.absenceCard = absenceCard
    local absenceHelp = CreateLabel(absenceCard,
        "Trage hier direkt ein, wann du nicht verfügbar bist. Mitgliederpflege und Roster berücksichtigen den Zeitraum automatisch.",
        { muted = true, width = 716 })
    absenceHelp:SetPoint("TOPLEFT", absenceCard, "TOPLEFT", 18, -46)

    local absenceFields = {
        { key = "FROM", label = "Von  •  JJJJ-MM-TT", x = 18, width = 142 },
        { key = "TO", label = "Bis  •  JJJJ-MM-TT", x = 170, width = 142 },
        { key = "REASON", label = "Grund (optional)", x = 322, width = 412 },
    }
    page.absenceEdits = {}
    for _, field in ipairs(absenceFields) do
        local label = CreateLabel(absenceCard, field.label, {
            muted = true,
            font = "GameFontNormalSmall",
            width = field.width,
        })
        label:SetPoint("TOPLEFT", absenceCard, "TOPLEFT", field.x, -72)
        local edit = CreateEdit(absenceCard, field.width, 34)
        edit.container:SetPoint("TOPLEFT", absenceCard, "TOPLEFT", field.x, -91)
        edit:SetMaxLetters(field.key == "REASON" and 80 or 10)
        page.absenceEdits[field.key] = edit
    end
    page.saveAbsence = CreateButton(absenceCard, "Abmelden", 130, 32, function()
        local success, message = GC.Profile:SetAbsence(
            page.absenceEdits.FROM:GetText(),
            page.absenceEdits.TO:GetText(),
            page.absenceEdits.REASON:GetText()
        )
        page.absenceStatus:SetText(message or "")
        SetTextColor(page.absenceStatus, success and THEME.success or THEME.danger)
        if success then
            GC.UI:RefreshRoster()
        end
    end, "PRIMARY")
    page.saveAbsence:SetPoint("TOPLEFT", absenceCard, "TOPLEFT", 18, -135)
    page.clearAbsence = CreateButton(absenceCard, "Abmeldung löschen", 160, 32, function()
        GC.Profile:ClearAbsence()
        page.absenceStatus:SetText("Abmeldung gelöscht und mit der Gilde synchronisiert.")
        SetTextColor(page.absenceStatus, THEME.success)
        GC.UI:RefreshRoster()
    end)
    page.clearAbsence:SetPoint("LEFT", page.saveAbsence, "RIGHT", 8, 0)
    -- Meldungen wie "Abmeldung gespeichert und fuer die Gilde synchronisiert."
    -- brauchen gelegentlich zwei Zeilen; die Hoehe ist dafuer ausgelegt.
    page.absenceStatus = CreateLabel(absenceCard, "", { width = 402, height = 32, multiline = true })
    page.absenceStatus:SetPoint("LEFT", page.clearAbsence, "RIGHT", 12, 0)

    local gearCard = CreateCard(content, "Deine Ausrüstung")
    gearCard:SetSize(752, 162)
    page.gearCard = gearCard
    local gearHelp = CreateLabel(gearCard,
        "Prüft deine eigene Ausrüstung auf fehlende Verzauberungen und leere Sockel. Läuft nur bei dir und ohne Gruppe.",
        { muted = true, width = 560, height = 18, vertical = "TOP" })
    gearHelp:SetPoint("TOPLEFT", gearCard, "TOPLEFT", 18, -46)

    page.profileGearFindings = CreateLabel(gearCard, "", { width = 560, height = 62, vertical = "TOP" })
    page.profileGearFindings:SetPoint("TOPLEFT", gearCard, "TOPLEFT", 18, -70)
    page.profileGearAge = CreateLabel(gearCard, "", { muted = true, width = 560, height = 18 })
    page.profileGearAge:SetPoint("BOTTOMLEFT", gearCard, "BOTTOMLEFT", 18, 12)

    page.profileGearButton = CreateButton(gearCard, "Ausrüstung prüfen", 150, 30, function()
        local ok, message = GC.GearAudit:AuditSelf()
        if not ok and message then
            GC:Print(message)
        end
        GC.UI:RefreshRoster()
    end, "PRIMARY")
    page.profileGearButton:SetPoint("TOPRIGHT", gearCard, "TOPRIGHT", -18, -46)

    page.profileGearOpen = CreateButton(gearCard, "Alle Prüfungen", 150, 26, function()
        GC.UI:ShowPage("GEAR")
    end)
    page.profileGearOpen:SetPoint("TOPRIGHT", page.profileGearButton, "BOTTOMRIGHT", 0, -6)

    -- Alle Kartenpositionen kommen aus ROSTER_CARDS, auch die erste Fassung:
    -- Zwei Quellen fuer dieselben Masse waeren zwei Gelegenheiten, sie
    -- auseinanderlaufen zu lassen.
    self:LayoutRosterPage(false)
end

-- Verschiebt die Karten der Profilseite, je nachdem ob die Checkliste "Erste
-- Schritte" darueber steht. Sie ist die einzige Karte, die kommt und geht -
-- der Rest wandert geschlossen um denselben Betrag mit.
function GC.UI:LayoutRosterPage(showOnboarding)
    local page = self.pages.ROSTER
    if not page or not page.profileContent then
        return
    end
    local shift = showOnboarding and (ROSTER_ONBOARDING_HEIGHT + ROSTER_CARD_GAP) or 0
    if page.onboardingCard then
        page.onboardingCard:SetShown(showOnboarding == true)
    end
    for _, definition in ipairs(ROSTER_CARDS) do
        local card = page[definition.key]
        if card then
            local anchor = definition.anchor or "TOPLEFT"
            card:ClearAllPoints()
            card:SetPoint(anchor, page.profileContent, anchor, 0, -(definition.top + shift))
        end
    end
    page.profileContent:SetHeight(ROSTER_CONTENT_HEIGHT + shift)
end

function GC.UI:RefreshProfileGear()
    local page = self.pages.ROSTER
    if not page or not page.profileGearFindings then
        return
    end
    local audit = GC.GearAudit:GetAudit(GC:GetPlayerFullName())
    if not audit then
        page.profileGearFindings:SetText("|cff91a3b8Noch nicht geprüft. Ein Klick auf "
            .. "\"Ausrüstung prüfen\" liest deine angelegten Gegenstände aus.|r")
        page.profileGearAge:SetText("")
        return
    end
    page.profileGearFindings:SetText(self:FormatGearFindings(audit, 3))
    local ageMinutes = math.max(0, math.floor((GC.Util.Now() - (audit.inspectedAt or 0)) / 60))
    page.profileGearAge:SetText("Zuletzt geprüft vor " .. ageMinutes .. " Minuten.")
end

-- Weicht die Auswahl auf der Karte vom gespeicherten Profil ab? Dann ist sie
-- noch nicht bestaetigt. Verglichen wird gegen genau die Werte, mit denen die
-- Karte auch vorbelegt wird - sonst gaelte ein frisches Profil schon beim
-- Aufschlagen als geaendert.
local function ProfileSelectionChanged(page, profile)
    if page.selectedProfileSpec ~= (profile.raidSpecKey or profile.detectedSpecKey) then
        return true
    end
    if page.selectedSecondarySpec ~= profile.secondarySpecKey then
        return true
    end
    if (page.selectedMainStatus or "MAIN") ~= (profile.mainStatus or "MAIN") then
        return true
    end
    return (page.selectedFlex == true) ~= (profile.flex == true)
end

function GC.UI:RefreshRoster()
    local page = self.pages.ROSTER
    if not page then
        return
    end
    self:RefreshOnboarding()
    self:RefreshProfileGear()

    local profile = GC.Profile:Get()
    local detected = GC.SpecByKey[profile.detectedSpecKey or ""]
    page.detectedText:SetText("Erkannt: " .. (detected and detected.name or "noch nicht ermittelbar")
        .. "  •  Talente " .. (profile.talentSignature or "0/0/0"))

    -- Die Vorbelegung steht vor der Rueckmeldung: Ohne sie waere die Auswahl
    -- beim ersten Aufschlagen noch leer und damit rechnerisch "geaendert".
    if page.selectedProfileSpec == nil then
        page.selectedProfileSpec = profile.raidSpecKey or profile.detectedSpecKey
    end
    if page.secondaryInitialized ~= true then
        page.selectedSecondarySpec = profile.secondarySpecKey
        page.secondaryInitialized = true
    end
    page.selectedMainStatus = page.selectedMainStatus or profile.mainStatus or "MAIN"
    if page.selectedFlex == nil then
        page.selectedFlex = profile.flex == true
    end

    -- Der Bestaetigungsstatus bleibt stehen: erst die letzte Rueckmeldung,
    -- sonst der gespeicherte Stand des Profils.
    if page.profileStatus then
        local confirmation = GC.Profile:GetLastConfirmation()
        local changed = ProfileSelectionChanged(page, profile)
        if confirmation and not confirmation.ok then
            -- Nur der Fehlschlag braucht Worte: Er sagt, was zu tun ist.
            page.profileStatusMark:Hide()
            page.profileStatus:SetText(confirmation.message or "Bestätigung fehlgeschlagen.")
            SetTextColor(page.profileStatus, THEME.danger)
        elseif changed and profile.confirmed then
            -- Der Haken der letzten Bestaetigung darf nicht ueber einer
            -- laengst geaenderten Auswahl stehen bleiben: Gespeichert und
            -- gildenweit geteilt ist weiterhin der alte Stand.
            page.profileStatusMark:Hide()
            page.profileStatus:SetText("Geändert – noch nicht bestätigt. "
                .. "In der Gilde steht weiter der zuletzt bestätigte Stand.")
            SetTextColor(page.profileStatus, THEME.warning)
        elseif profile.confirmed then
            page.profileStatusMark:Show()
            page.profileStatus:SetText("")
        else
            page.profileStatusMark:Hide()
            page.profileStatus:SetText("Noch nicht bestätigt.")
            SetTextColor(page.profileStatus, THEME.muted)
        end
    end

    local classInfo = GC.Classes[profile.classFile or ""]
    for index, button in ipairs(page.profileSpecButtons) do
        local spec = classInfo and classInfo.specs[index]
        button:SetShown(spec ~= nil)
        if spec then
            button.specKey = spec.key
            button:SetText(spec.name)
            button:SetActive(page.selectedProfileSpec == spec.key)
        end
    end
    for index, button in ipairs(page.secondarySpecButtons) do
        local spec = classInfo and classInfo.specs[index]
        button:SetShown(spec ~= nil)
        if spec then
            button.specKey = spec.key
            button:SetText(spec.name)
            button:SetActive(page.selectedSecondarySpec == spec.key)
        end
    end
    page.noSecondaryButton:SetActive(page.selectedSecondarySpec == nil)
    SetToggle(page.mainCheck, page.selectedMainStatus ~= "ALT")
    SetToggle(page.altCheck, page.selectedMainStatus == "ALT")
    SetToggle(page.flexCheck, page.selectedFlex)
    for slot = 1, 2 do
        local profession = profile.professions and profile.professions[slot]
        page.professionDropdowns[slot]:SetValue(profession and profession.name or "")
    end
    -- Werkstatt-Stand je Beruf: Wie viele Rezepte hängen schon in der
    -- Gildenwerkstatt, und wie alt ist der Stand? Fehlen Rezepte, steht der
    -- nächste Schritt gleich daneben - das Einlesen braucht ein einmal
    -- geöffnetes Berufsfenster.
    for slot = 1, 2 do
        local line = page.professionLines[slot]
        local profession = (profile.professions or {})[slot]
        local professionName = profession and GC.Util.Trim(profession.name or "") or ""
        if professionName == "" then
            line:SetText("")
        else
            local skill = tonumber(profession.skillLevel) or 0
            local maxSkill = tonumber(profession.maxSkillLevel) or 0
            local skillText = skill > 0
                and (" " .. skill .. (maxSkill > 0 and ("/" .. maxSkill) or ""))
                or ""
            local stored = GC.Workshop:GetOwnProfession(professionName)
            local recipeCount = 0
            for _ in pairs((stored and stored.recipes) or {}) do
                recipeCount = recipeCount + 1
            end
            -- Knapp halten: Die Karte ist 388 Pixel breit, und
            -- "Verzauberkunst 375/375" braucht davon schon die Hälfte.
            -- Dass die Rezepte in der Werkstatt liegen, erklärt der Text
            -- direkt darunter.
            if recipeCount > 0 then
                local ageMinutes = math.max(0,
                    math.floor((GC.Util.Now() - (stored.updatedAt or 0)) / 60))
                local ageText = ageMinutes < 120 and (ageMinutes .. " Min.")
                    or ageMinutes < 2880 and (math.floor(ageMinutes / 60) .. " Std.")
                    or (math.floor(ageMinutes / 1440) .. " Tagen")
                line:SetText(professionName .. skillText .. " · |cff59e695"
                    .. recipeCount .. " Rezepte|r · vor " .. ageText)
                SetTextColor(line, THEME.text)
            else
                line:SetText(professionName .. skillText
                    .. " · |cffffb840Rezepte fehlen|r – Beruf einmal öffnen.")
                SetTextColor(line, THEME.text)
            end
        end
    end

    -- Die Statuszeile sagt, was tatsaechlich passiert ist. Bis 0.9.45 meldete
    -- sie unterschiedslos eine laufende Uebernahme, auch wenn der Client die
    -- Berufsliste gar nicht herausgibt - dann blieb die Angabe von Hand stehen
    -- und sah aus wie ein Ergebnis.
    local professionSource = GC.Profile:GetProfessionSource(profile)
    if professionSource == "OK" then
        page.professionStatus:SetText("Automatisch aus deinen Fähigkeiten übernommen. "
            .. "Neue Rezepte wandern beim Öffnen des Berufsfensters von selbst in die Werkstatt.")
        SetTextColor(page.professionStatus, THEME.muted)
    elseif professionSource == "EMPTY" then
        page.professionStatus:SetText("Nachgesehen: Dieser Charakter hat keinen Hauptberuf erlernt.")
        SetTextColor(page.professionStatus, THEME.muted)
    elseif professionSource == "MANUAL" then
        page.professionStatus:SetText("Von Hand gewählt. Die leere Auswahl oben schaltet zurück "
            .. "auf die automatische Erkennung.")
        SetTextColor(page.professionStatus, THEME.muted)
    else
        page.professionStatus:SetText("Deine Fähigkeiten ließen sich nicht lesen – "
            .. "bitte oben von Hand wählen.")
        SetTextColor(page.professionStatus, THEME.warning)
    end

    local absence = profile.absence or {}
    if not page.absenceEdits.FROM:HasFocus() then
        page.absenceEdits.FROM:SetText(absence.from or "")
    end
    if not page.absenceEdits.TO:HasFocus() then
        page.absenceEdits.TO:SetText(absence.to or "")
    end
    if not page.absenceEdits.REASON:HasFocus() then
        page.absenceEdits.REASON:SetText(absence.reason or "")
    end
    local absenceState = GC.Profile:GetAbsenceState(profile)
    if absenceState == "ACTIVE" then
        page.absenceStatus:SetText("Aktiv bis " .. absence.to .. ".")
        SetTextColor(page.absenceStatus, THEME.success)
        page.clearAbsence:Enable()
    elseif absenceState == "UPCOMING" then
        page.absenceStatus:SetText("Geplant ab " .. absence.from .. ".")
        SetTextColor(page.absenceStatus, THEME.warning)
        page.clearAbsence:Enable()
    elseif absenceState == "EXPIRED" then
        page.absenceStatus:SetText("Abmeldung abgelaufen – neu eintragen oder löschen.")
        SetTextColor(page.absenceStatus, THEME.muted)
        page.clearAbsence:Enable()
    else
        page.absenceStatus:SetText("Keine Abmeldung eingetragen.")
        SetTextColor(page.absenceStatus, THEME.muted)
        page.clearAbsence:Disable()
    end
    page.profileScroll:UpdateModernThumb()
end

local function MissingGuildProfileFields()
    local profile = GC.DB:GetGuild().profile
    local missing = {}
    local fields = {
        { key = "description", label = "Kurzbeschreibung" },
        { key = "raidTimes", label = "Raidzeiten" },
        { key = "lootSystem", label = "Lootsystem" },
        { key = "discord", label = "Discord" },
    }
    for _, field in ipairs(fields) do
        if GC.Util.Trim(profile[field.key]) == "" then
            missing[#missing + 1] = field.label
        end
    end
    return missing
end

function GC.UI:BuildSuggestionsPage()
    local page = self.pages.SUGGESTIONS
    CreatePageTitle(page, "Copilot-Vorschläge",
        "Gildenroster, bestätigte Profile und importierte Logs ergeben einen Vorschlag für die Rekrutierung.")

    page.metricCards = {}
    local metrics = {
        { key = "PROFILE", label = "GILDENPROFIL" },
        { key = "COVERAGE", label = "BEKANNTE SPECS" },
        { key = "IMPORTS", label = "LOG-PROFILE" },
    }
    for index, metric in ipairs(metrics) do
        local card = CreateCard(page)
        card:SetSize(247, 76)
        card:SetPoint("TOPLEFT", page, "TOPLEFT", (index - 1) * 260, -66)
        card.value = CreateLabel(card, "0", { title = true })
        card.value:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -13)
        card.caption = CreateLabel(card, metric.label, { muted = true })
        card.caption:SetPoint("TOPLEFT", card.value, "BOTTOMLEFT", 0, -5)
        page.metricCards[metric.key] = card
    end

    local card = CreateCard(page, "Empfohlener Rekrutierungsbedarf")
    card:SetSize(776, 408)
    card:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -158)
    page.rosterRefresh = CreateButton(card, "Roster aktualisieren", 170, 28, function()
        page.rosterRefreshStatus:SetText("Roster wird neu abgefragt …")
        SetTextColor(page.rosterRefreshStatus, THEME.accent)
        GC.Roster:Refresh()
    end)
    page.rosterRefresh:SetPoint("TOPRIGHT", card, "TOPRIGHT", -18, -12)
    page.rosterRefreshStatus = CreateLabel(card, "", {
        muted = true,
        align = "RIGHT",
        width = 210,
        font = "GameFontNormalSmall",
    })
    page.rosterRefreshStatus:SetPoint("TOPRIGHT", card, "TOPRIGHT", -18, -47)
    page.suggestionRows = {}
    for index = 1, 7 do
        local row = CreatePanel(card, index % 2 == 0 and THEME.input or THEME.card)
        row:SetSize(740, 33)
        row:SetPoint("TOPLEFT", card, "TOPLEFT", 18, -72 - ((index - 1) * 37))
        row.priority = CreateLabel(row, "", { width = 64, height = 33, font = "GameFontNormalSmall" })
        row.priority:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.name = CreateLabel(row, "", { width = 190, height = 33 })
        row.name:SetPoint("LEFT", row, "LEFT", 78, 0)
        row.reason = CreateLabel(row, "", { muted = true, width = 450, height = 33 })
        row.reason:SetPoint("LEFT", row, "LEFT", 276, 0)
        page.suggestionRows[index] = row
    end

    page.suggestionNotice = CreateLabel(card, "", { muted = true, width = 740, height = 20, vertical = "TOP" })
    page.suggestionNotice:SetPoint("TOPLEFT", card, "TOPLEFT", 18, -331)
    local profileButton = CreateButton(card, "Gildenprofil prüfen", 180, 36, function()
        GC.UI:ShowPage("GUILD")
    end)
    profileButton:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 18, 16)
    page.applySuggestions = CreateButton(card, "Vorschläge übernehmen", 220, 36, function()
        local suggestions = GC.Recruitment:GetSuggestions()
        for _, suggestion in ipairs(suggestions) do
            GC.Recruitment:SetSpec(suggestion.specKey, true)
        end
        GC.UI:ShowPage("RECRUITMENT")
    end, "PRIMARY")
    page.applySuggestions:SetPoint("LEFT", profileButton, "RIGHT", 8, 0)
    local manualButton = CreateButton(card, "Manuell auswählen", 170, 36, function()
        GC.UI:ShowPage("RECRUITMENT")
    end)
    manualButton:SetPoint("LEFT", page.applySuggestions, "RIGHT", 8, 0)
end

function GC.UI:RefreshSuggestions()
    local page = self.pages.SUGGESTIONS
    if not page then
        return
    end
    local summary = GC.Roster:GetSummary()
    local missing = MissingGuildProfileFields()
    if GC.Roster.lastUpdate and GC.Roster.lastUpdate > 0 and date then
        page.rosterRefreshStatus:SetText("Stand: " .. date("%H:%M", GC.Roster.lastUpdate))
    elseif GC.Roster.lastUpdate and GC.Roster.lastUpdate > 0 then
        page.rosterRefreshStatus:SetText("Roster aktuell")
    else
        page.rosterRefreshStatus:SetText("Noch nicht abgefragt")
    end
    page.metricCards.PROFILE.value:SetText(#missing == 0 and "BEREIT" or (#missing .. " OFFEN"))
    page.metricCards.COVERAGE.value:SetText(summary.knownProfiles .. "/" .. summary.total)
    page.metricCards.IMPORTS.value:SetText(summary.importedProfiles)

    local suggestions = GC.Recruitment:GetSuggestions()
    for index, row in ipairs(page.suggestionRows) do
        local suggestion = suggestions[index]
        row:SetShown(suggestion ~= nil)
        if suggestion then
            local spec = GC.SpecByKey[suggestion.specKey]
            row.priority:SetText(suggestion.priority)
            SetTextColor(row.priority, suggestion.priority == "HOCH" and THEME.warning or THEME.accent)
            row.name:SetText(spec and spec.recruitLabel or suggestion.specKey)
            row.reason:SetText(suggestion.reason)
        end
    end

    if #suggestions == 0 then
        page.suggestionNotice:SetText("|cff59e695Keine automatische Lücke erkannt.|r Du kannst trotzdem Klassen und Specs manuell wählen.")
        page.applySuggestions:Disable()
    else
        page.applySuggestions:Enable()
        if #missing > 0 then
            page.suggestionNotice:SetText("|cffffb84dVor dem Posten ergänzen:|r " .. table.concat(missing, ", ") .. ".")
        elseif summary.knownProfiles < math.max(1, math.floor(summary.total * 0.5)) then
            page.suggestionNotice:SetText("|cffffb84dDatenlage noch dünn:|r Mehr Mitglieder sollten ihr Profil bestätigen oder Logs importiert werden.")
        else
            page.suggestionNotice:SetText("|cff59e695Workflow bereit:|r Vorschläge übernehmen, Auswahl prüfen und anschließend den Werbetext bestätigen.")
        end
    end
end

function GC.UI:BuildMemberCarePage()
    local page = self.pages.MEMBERCARE
    CreatePageTitle(page, "Mitgliederpflege",
        "Abmeldungen berücksichtigen und lange Inaktivität nachvollziehbar prüfen – niemals automatisch entfernen.")

    local scroll = CreateModernScrollFrame(page)
    scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -58)
    scroll:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -4, 0)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(752)
    content:SetHeight(1100)
    scroll:SetScrollChild(content)
    page.memberCareScroll = scroll

    local rulesCard = CreateCard(content, "Prüfregeln")
    rulesCard:SetSize(752, 230)
    rulesCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    local rulesHelp = CreateLabel(rulesCard,
        "Nur berechtigte Einstellungs-Ränge ändern diese gildenweiten Regeln. Geschützte Ränge erscheinen nie als Vorschlag.",
        { muted = true, width = 716, height = 30, vertical = "TOP" })
    rulesHelp:SetPoint("TOPLEFT", rulesCard, "TOPLEFT", 18, -46)

    local thresholdLabel = CreateLabel(rulesCard, "Vorschlag ab", { muted = true, width = 100 })
    thresholdLabel:SetPoint("TOPLEFT", rulesCard, "TOPLEFT", 18, -88)
    local thresholdOptions = { "30 Tage", "45 Tage", "60 Tage", "90 Tage", "120 Tage", "180 Tage" }
    page.memberCareThreshold = CreateChoiceDropdown(rulesCard, 150, thresholdOptions, function(value)
        local days = tonumber(tostring(value):match("(%d+)"))
        if not GC.Roster:SetMemberCareInactivityDays(days) then
            page.memberCareRulesStatus:SetText("Dein Gildenrang darf die Prüfregeln nicht ändern.")
            SetTextColor(page.memberCareRulesStatus, THEME.danger)
            GC.UI:RefreshMemberCare()
        end
    end, true)
    page.memberCareThreshold:SetPoint("TOPLEFT", rulesCard, "TOPLEFT", 120, -82)
    page.memberCareRulesStatus = CreateLabel(rulesCard, "", { muted = true, width = 442 })
    page.memberCareRulesStatus:SetPoint("LEFT", page.memberCareThreshold, "RIGHT", 12, 0)

    local protectedLabel = CreateLabel(rulesCard, "Geschützte Ränge", { muted = true, width = 200 })
    protectedLabel:SetPoint("TOPLEFT", rulesCard, "TOPLEFT", 18, -128)
    page.memberCareRankToggles = {}
    for index = 1, 10 do
        local toggle
        toggle = CreateToggle(rulesCard, "", function(checked)
            if toggle.rankIndex ~= nil and not GC.Roster:SetMemberCareRankProtected(toggle.rankIndex, checked) then
                page.memberCareRulesStatus:SetText("Dein Gildenrang darf den Rangschutz nicht ändern.")
                SetTextColor(page.memberCareRulesStatus, THEME.danger)
                GC.UI:RefreshMemberCare()
            end
        end)
        local column = (index - 1) % 5
        local row = math.floor((index - 1) / 5)
        toggle:SetPoint("TOPLEFT", rulesCard, "TOPLEFT", 18 + (column * 145), -153 - (row * 31))
        toggle.text:SetWidth(112)
        toggle.text:SetJustifyH("LEFT")
        page.memberCareRankToggles[index] = toggle
    end

    local absencesCard = CreateCard(content, "Aktuelle Abmeldungen")
    absencesCard:SetSize(752, 210)
    absencesCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -880)
    page.guildAbsencesTitle = absencesCard.title
    page.guildAbsenceRows = {}
    for index = 1, 5 do
        local row = CreatePanel(absencesCard, index % 2 == 0 and THEME.input or THEME.cardHover)
        row:SetSize(716, 26)
        row:SetPoint("TOPLEFT", absencesCard, "TOPLEFT", 18, -48 - ((index - 1) * 29))
        row.name = CreateLabel(row, "", { width = 140, height = 26 })
        row.name:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.range = CreateLabel(row, "", { muted = true, width = 190, height = 26 })
        row.range:SetPoint("LEFT", row, "LEFT", 154, 0)
        row.reason = CreateLabel(row, "", { muted = true, width = 284, height = 26 })
        row.reason:SetPoint("LEFT", row, "LEFT", 350, 0)
        row.state = CreateLabel(row, "", { align = "RIGHT", width = 70, height = 26 })
        row.state:SetPoint("RIGHT", row, "RIGHT", -9, 0)
        page.guildAbsenceRows[index] = row
    end
    page.guildAbsenceNotice = CreateLabel(absencesCard, "", { muted = true, width = 716 })
    page.guildAbsenceNotice:SetPoint("BOTTOMLEFT", absencesCard, "BOTTOMLEFT", 18, 10)

    local suggestionsCard = CreateCard(content, "Pflegevorschläge")
    suggestionsCard:SetSize(752, 368)
    suggestionsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -242)
    page.memberCareSuggestionsTitle = suggestionsCard.title
    local suggestionHelp = CreateLabel(suggestionsCard,
        "Twinks, aktiv Abgemeldete und geschützte Ränge werden ausgeblendet. „Prüfen“ bedeutet: Main/Twink-Status ist nicht bestätigt.",
        { muted = true, width = 716, height = 30, vertical = "TOP" })
    suggestionHelp:SetPoint("TOPLEFT", suggestionsCard, "TOPLEFT", 18, -46)
    page.memberCareSuggestionRows = {}
    for index = 1, 9 do
        local row = CreatePanel(suggestionsCard, index % 2 == 0 and THEME.input or THEME.cardHover)
        row:SetSize(716, 27)
        row:SetPoint("TOPLEFT", suggestionsCard, "TOPLEFT", 18, -81 - ((index - 1) * 29))
        row.name = CreateLabel(row, "", { width = 116, height = 27 })
        row.name:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.status = CreateLabel(row, "", { width = 76, height = 27 })
        row.status:SetPoint("LEFT", row, "LEFT", 129, 0)
        -- Der Grund umbrach auf zwei Zeilen und lief damit ueber die 27 Pixel
        -- Zeilenhoehe hinaus in die Nachbarzeilen. Er bleibt jetzt einzeilig,
        -- vollstaendig steht er im Tooltip.
        row.reason = CreateLabel(row, "", { muted = true, width = 196, height = 27 })
        row.reason:SetPoint("LEFT", row, "LEFT", 209, 0)
        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self)
            if not GameTooltip or not self.tooltipText or self.tooltipText == "" then
                return
            end
            AnchorRowTooltip(self)
            GameTooltip:SetText(self.tooltipName or "")
            GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)

        local function DecideRow(status)
            if not row.playerName then
                return
            end
            local ok, message = GC.Roster:SetMemberCareDecision(row.playerName, status)
            page:SetMemberCareStatus(message, ok)
            GC.UI:RefreshMemberCare()
        end

        row.ignoreButton = CreateButton(row, "Ausnahme", 74, 21, function()
            DecideRow("IGNORED")
        end)
        row.ignoreButton:SetPoint("LEFT", row, "LEFT", 409, 0)
        row.postponeButton = CreateButton(row, "Später", 60, 21, function()
            DecideRow("POSTPONED")
        end)
        row.postponeButton:SetPoint("LEFT", row, "LEFT", 487, 0)
        row.doneButton = CreateButton(row, "Erledigt", 66, 21, function()
            DecideRow("DONE")
        end)
        row.doneButton:SetPoint("LEFT", row, "LEFT", 551, 0)

        -- Entfernen verlangt einen zweiten, ausdrücklichen Klick auf derselben
        -- Zeile. Der erste Klick bewaffnet nur und beschriftet um.
        row.removeButton = CreateButton(row, "Entfernen", 84, 21, function()
            if not row.playerName then
                return
            end
            if not row.removeArmed then
                local allowed, reason = GC.Roster:CanRemoveMember(row.playerName)
                if not allowed then
                    page:SetMemberCareStatus(reason, false)
                    return
                end
                row.removeArmed = true
                row.removeButton:SetText("Sicher?")
                page:SetMemberCareStatus("Noch einmal klicken, um "
                    .. GC.Util.PlayerShortName(row.playerName) .. " endgültig zu entfernen.", false)
                return
            end
            row.removeArmed = false
            local ok, message = GC.Roster:RemoveMember(row.playerName)
            page:SetMemberCareStatus(message, ok)
            GC.UI:RefreshMemberCare()
        end)
        row.removeButton:SetPoint("LEFT", row, "LEFT", 621, 0)
        page.memberCareSuggestionRows[index] = row
    end
    page.memberCareSuggestionNotice = CreateLabel(suggestionsCard, "", { muted = true, width = 716 })
    page.memberCareSuggestionNotice:SetPoint("BOTTOMLEFT", suggestionsCard, "BOTTOMLEFT", 18, 10)

    local decisionsCard = CreateCard(content, "Ausnahmen und Entscheidungen")
    decisionsCard:SetSize(752, 246)
    decisionsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -622)
    page.memberCareDecisionsTitle = decisionsCard.title
    local decisionsHelp = CreateLabel(decisionsCard,
        "Diese Einträge werden gildenweit synchronisiert, damit nicht zwei Offiziere denselben Fall bearbeiten.",
        { muted = true, width = 716, height = 18, vertical = "TOP" })
    decisionsHelp:SetPoint("TOPLEFT", decisionsCard, "TOPLEFT", 18, -46)

    page.memberCareStatus = CreateLabel(decisionsCard, "", { width = 716, height = 18, vertical = "TOP" })
    page.memberCareStatus:SetPoint("TOPLEFT", decisionsCard, "TOPLEFT", 18, -66)

    function page:SetMemberCareStatus(message, ok)
        message = GC.Util.Trim(message)
        self.memberCareStatus:SetText(message)
        SetTextColor(self.memberCareStatus, ok == false and THEME.danger or THEME.success)
        if message ~= "" then
            GC:Print(message)
        end
    end

    page.memberCareDecisionRows = {}
    for index = 1, 5 do
        local row = CreatePanel(decisionsCard, index % 2 == 0 and THEME.input or THEME.cardHover)
        row:SetSize(716, 26)
        row:SetPoint("TOPLEFT", decisionsCard, "TOPLEFT", 18, -90 - ((index - 1) * 29))
        row.name = CreateLabel(row, "", { width = 150, height = 26 })
        row.name:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.status = CreateLabel(row, "", { width = 130, height = 26 })
        row.status:SetPoint("LEFT", row, "LEFT", 165, 0)
        row.detail = CreateLabel(row, "", { muted = true, width = 300, height = 26 })
        row.detail:SetPoint("LEFT", row, "LEFT", 301, 0)
        row.restoreButton = CreateButton(row, "Zurückholen", 96, 21, function()
            if row.playerName then
                local ok, message = GC.Roster:ClearMemberCareDecision(row.playerName)
                page:SetMemberCareStatus(message, ok)
                GC.UI:RefreshMemberCare()
            end
        end)
        row.restoreButton:SetPoint("RIGHT", row, "RIGHT", -9, 0)
        page.memberCareDecisionRows[index] = row
    end
    page.memberCareDecisionNotice = CreateLabel(decisionsCard, "", { muted = true, width = 716 })
    page.memberCareDecisionNotice:SetPoint("BOTTOMLEFT", decisionsCard, "BOTTOMLEFT", 18, 10)
end

function GC.UI:RefreshMemberCare()
    local page = self.pages.MEMBERCARE
    if not page then
        return
    end

    local careSettings = GC.DB:GetGuild().memberCare
    page.memberCareThreshold:SetValue((careSettings.inactivityDays or 60) .. " Tage")
    local canEdit = GC.Roster:CanEditGuildProfile()
    if canEdit then
        page.memberCareThreshold:Enable()
        page.memberCareRulesStatus:SetText("Regeln werden gildenweit synchronisiert.")
        SetTextColor(page.memberCareRulesStatus, THEME.muted)
    else
        page.memberCareThreshold:Disable()
        page.memberCareRulesStatus:SetText("Prüfregeln sind für deinen Rang schreibgeschützt.")
        SetTextColor(page.memberCareRulesStatus, THEME.warning)
    end

    local ranks = GC.Roster:GetRankDefinitions()
    for index = 1, 10 do
        local rank = ranks[index]
        local toggle = page.memberCareRankToggles[index]
        toggle:SetShown(rank ~= nil)
        if rank then
            toggle.rankIndex = rank.index
            toggle.text:SetText(rank.name)
            SetToggle(toggle, GC.Roster:IsMemberCareRankProtected(rank.index))
            if canEdit then
                toggle:Enable()
            else
                toggle:Disable()
            end
        else
            toggle.rankIndex = nil
        end
    end

    local guildAbsences = GC.Roster:GetGuildAbsences()
    page.guildAbsencesTitle:SetText("Aktuelle Abmeldungen  •  " .. #guildAbsences)
    for index, row in ipairs(page.guildAbsenceRows) do
        local entry = guildAbsences[index]
        row:SetShown(entry ~= nil)
        if entry then
            row.name:SetText(GC.Util.PlayerShortName(entry.member.name))
            row.name:SetTextColor(ClassColor(entry.member.classFile))
            row.range:SetText(entry.absence.from .. " – " .. entry.absence.to)
            row.reason:SetText(entry.absence.reason ~= "" and entry.absence.reason or "Kein Grund angegeben")
            row.state:SetText(entry.state == "ACTIVE" and "AKTIV" or "GEPLANT")
            SetTextColor(row.state, entry.state == "ACTIVE" and THEME.success or THEME.warning)
        end
    end
    if #guildAbsences == 0 then
        page.guildAbsenceNotice:SetText("Keine aktiven oder geplanten Abmeldungen bekannt.")
    elseif #guildAbsences > #page.guildAbsenceRows then
        page.guildAbsenceNotice:SetText("Weitere " .. (#guildAbsences - #page.guildAbsenceRows)
            .. " Abmeldungen sind gespeichert.")
    else
        page.guildAbsenceNotice:SetText("")
    end

    local candidates = GC.Roster:GetMemberCareCandidates()
    page.memberCareSuggestionsTitle:SetText(
        "Pflegevorschläge  •  ab " .. (careSettings.inactivityDays or 60) .. " Tagen  •  " .. #candidates)
    for index, row in ipairs(page.memberCareSuggestionRows) do
        local candidate = candidates[index]
        row:SetShown(candidate ~= nil)
        if candidate then
            row.playerName = candidate.member.name
            row.removeArmed = false
            row.removeButton:SetText("Entfernen")
            row.name:SetText(GC.Util.PlayerShortName(candidate.member.name))
            row.name:SetTextColor(ClassColor(candidate.member.classFile))
            row.status:SetText(candidate.status)
            SetTextColor(row.status, candidate.status == "VORSCHLAG" and THEME.danger or THEME.warning)
            row.reason:SetText(candidate.reason)
            row.tooltipName = GC.Util.PlayerShortName(candidate.member.name)
            row.tooltipText = candidate.reason

            local canDecide = GC.Roster:CanAccessMemberCare()
            SetButtonEnabled(row.ignoreButton, canDecide)
            SetButtonEnabled(row.postponeButton, canDecide)
            SetButtonEnabled(row.doneButton, canDecide)
            SetButtonEnabled(row.removeButton, GC.Roster:CanRemoveMember(candidate.member.name) == true)
        else
            row.playerName = nil
        end
    end

    local decisions = GC.Roster:GetMemberCareDecisions()
    page.memberCareDecisionsTitle:SetText("Ausnahmen und Entscheidungen  •  " .. #decisions)
    for index, row in ipairs(page.memberCareDecisionRows) do
        local decision = decisions[index]
        row:SetShown(decision ~= nil)
        if decision then
            row.playerName = decision.name
            local definition = GC.MemberCareDecisions[decision.status]
            row.name:SetText(decision.name)
            row.status:SetText(definition and definition.label or decision.status)
            SetTextColor(row.status, decision.status == "IGNORED" and THEME.warning or THEME.muted)
            local detail = definition and definition.help or ""
            if decision.status == "POSTPONED" and decision.until_ ~= "" then
                detail = "Wieder ab " .. decision.until_ .. "."
            end
            if decision.by and decision.by ~= "" then
                detail = detail .. "  •  " .. decision.by
            end
            row.detail:SetText(detail)
            SetButtonEnabled(row.restoreButton, GC.Roster:CanAccessMemberCare())
        else
            row.playerName = nil
        end
    end
    page.memberCareDecisionNotice:SetText(#decisions == 0
        and "Keine Ausnahmen hinterlegt. Vorschläge lassen sich als Ausnahme, später oder erledigt ablegen."
        or "")
    if #candidates == 0 then
        page.memberCareSuggestionNotice:SetText("Keine Mitglieder erfüllen die aktuellen Prüfregeln.")
    elseif #candidates > #page.memberCareSuggestionRows then
        page.memberCareSuggestionNotice:SetText("Weitere "
            .. (#candidates - #page.memberCareSuggestionRows) .. " Vorschläge sind vorhanden.")
    else
        page.memberCareSuggestionNotice:SetText("Nur Vorschläge – keine automatische Entfernung.")
    end
end

function GC.UI:BuildWorkshopPage()
    local page = self.pages.WORKSHOP
    local _, workshopHelp = CreatePageTitle(page, "Gildenwerkstatt",
        "Rezepte werden automatisch erfasst, sobald ein Spieler sein WoW-Berufsfenster öffnet.")
    -- Die Unterreiter-Knöpfe stehen oben rechts auf Höhe des Hilfetexts.
    -- Mit voller Breite liefe der Text hinter die Knöpfe; schmaler bricht er
    -- vor ihnen um.
    workshopHelp:SetWidth(460)

    -- Zwei Unterreiter: der Katalog und das Auftragsboard
    -- (docs/KONZEPT-werkstatt-gildenauftraege.md). Beide teilen sich die
    -- Seite; gewechselt wird über die Knöpfe oben rechts.
    page.workshopView = "CATALOG"
    page.workshopTabCatalog = CreateButton(page, "Katalog", 100, 30, function()
        GC.UI:SetWorkshopView("CATALOG")
    end)
    page.workshopTabCatalog:SetPoint("TOPRIGHT", page, "TOPRIGHT", -196, 0)
    page.workshopTabOrders = CreateButton(page, "Gildenaufträge", 188, 30, function()
        GC.UI:SetWorkshopView("ORDERS")
    end)
    page.workshopTabOrders:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, 0)

    page.metricCards = {}
    local metrics = {
        { key = "RECIPES", label = "REZEPTE" },
        { key = "CRAFTERS", label = "HERSTELLER" },
        { key = "PROFESSIONS", label = "BERUFE" },
    }
    for index, metric in ipairs(metrics) do
        local card = CreateCard(page)
        card:SetSize(247, 72)
        card:SetPoint("TOPLEFT", page, "TOPLEFT", (index - 1) * 260, -66)
        card.value = CreateLabel(card, "0", { title = true })
        card.value:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -11)
        card.caption = CreateLabel(card, metric.label, { muted = true })
        card.caption:SetPoint("TOPLEFT", card.value, "BOTTOMLEFT", 0, -4)
        page.metricCards[metric.key] = card
    end

    local searchCard = CreateCard(page)
    searchCard:SetSize(776, 62)
    searchCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -150)
    local professionFilters = {}
    for _, professionName in ipairs(GC.ProfessionOptions) do
        professionFilters[#professionFilters + 1] = professionName
    end
    professionFilters[#professionFilters + 1] = "Kochkunst"
    professionFilters[#professionFilters + 1] = "Erste Hilfe"
    page.workshopProfession = CreateChoiceDropdown(searchCard, 176, professionFilters, function()
        page.workshopPage = 1
        page.selectedWorkshopRecipe = nil
        GC.UI:RefreshWorkshop()
    end, true, "Alle Berufe", function(professionName)
        return GC.ProfessionIcons[professionName or ""] or GC.ProfessionIcons[""]
    end)
    page.workshopProfession:SetPoint("TOPLEFT", searchCard, "TOPLEFT", 14, -14)
    page.workshopProfession:SetValue("")

    page.workshopSearch = CreateEdit(searchCard, 238, 34)
    page.workshopSearch.container:SetPoint("LEFT", page.workshopProfession, "RIGHT", 8, 0)
    -- Das × leert die Suche mit einem Klick; es erscheint nur, wenn etwas
    -- drinsteht (Owner-Wunsch).
    page.workshopSearchClear = CreateButton(page.workshopSearch.container, "×", 20, 20, function()
        page.workshopSearch:SetText("")
        page.workshopSearch:ClearFocus()
    end)
    page.workshopSearchClear:SetPoint("RIGHT", page.workshopSearch.container, "RIGHT", -5, 0)
    page.workshopSearchClear:Hide()
    page.workshopSearch:SetScript("OnTextChanged", function(edit)
        page.workshopPage = 1
        page.workshopSearchClear:SetShown(GC.Util.Trim(edit:GetText()) ~= "")
        GC.UI:RefreshWorkshop()
    end)
    local searchHint = CreateLabel(page.workshopSearch.container, "Rezept oder Spieler suchen", {
        muted = true,
        width = 205,
    })
    searchHint:SetPoint("LEFT", page.workshopSearch.container, "LEFT", 10, 0)
    page.workshopSearch:SetScript("OnEditFocusGained", function()
        searchHint:Hide()
    end)
    page.workshopSearch:SetScript("OnEditFocusLost", function(edit)
        searchHint:SetShown(edit:GetText() == "")
    end)

    page.workshopFavorites = CreateButton(searchCard, "Favoriten", 134, 34, function()
        page.workshopFavoritesOnly = not page.workshopFavoritesOnly
        page.workshopPage = 1
        page.selectedWorkshopRecipe = nil
        GC.UI:RefreshWorkshop()
    end)
    page.workshopFavorites:SetPoint("LEFT", page.workshopSearch.container, "RIGHT", 8, 0)
    page.workshopFavorites.favoriteIcon = page.workshopFavorites:CreateTexture(nil, "ARTWORK")
    page.workshopFavorites.favoriteIcon:SetSize(18, 18)
    page.workshopFavorites.favoriteIcon:SetPoint("LEFT", page.workshopFavorites, "LEFT", 9, 0)
    SetRaidMarkerIcon(page.workshopFavorites.favoriteIcon, 1)
    page.workshopFavorites.label:ClearAllPoints()
    page.workshopFavorites.label:SetPoint("LEFT", page.workshopFavorites, "LEFT", 31, 0)
    page.workshopFavorites.label:SetPoint("RIGHT", page.workshopFavorites, "RIGHT", -8, 0)
    page.workshopFavorites.label:SetJustifyH("LEFT")

    page.workshopRequest = CreateButton(searchCard, "Daten anfragen", 176, 34, function()
        local success, message = GC.Workshop:RequestGuildData()
        page.workshopStatus:SetText(message or "")
        SetTextColor(page.workshopStatus, success and THEME.success or THEME.danger)
    end, "PRIMARY")
    page.workshopRequest:SetPoint("TOPRIGHT", searchCard, "TOPRIGHT", -14, -14)

    local listCard = CreateCard(page, "Gefundene Rezepte")
    listCard:SetSize(418, 342)
    listCard:SetPoint("TOPLEFT", searchCard, "BOTTOMLEFT", 0, -12)
    page.workshopListTitle = listCard.title
    page.workshopRows = {}
    for index = 1, 7 do
        local rowIndex = index
        local row = CreateButton(listCard, "", 382, 31, function()
            local recipe = page.workshopVisibleRecipes and page.workshopVisibleRecipes[rowIndex]
            if recipe then
                page.selectedWorkshopRecipe = recipe.key
                GC.UI:RefreshWorkshop()
            end
        end)
        row:SetPoint("TOPLEFT", listCard, "TOPLEFT", 18, -48 - ((index - 1) * 34))
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row, "LEFT", 37, 0)
        row.label:SetPoint("RIGHT", row, "RIGHT", -112, 0)
        row.label:SetJustifyH("LEFT")
        row.professionIcon = row:CreateTexture(nil, "ARTWORK")
        row.professionIcon:SetSize(21, 21)
        row.professionIcon:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.meta = CreateLabel(row, "", { muted = true, align = "RIGHT", width = 78, height = 31 })
        row.meta:SetPoint("RIGHT", row, "RIGHT", -9, 0)
        row.favoriteIcon = row:CreateTexture(nil, "ARTWORK")
        row.favoriteIcon:SetSize(15, 15)
        row.favoriteIcon:SetPoint("RIGHT", row.meta, "LEFT", -6, 0)
        SetRaidMarkerIcon(row.favoriteIcon, 1)
        row.favoriteIcon:Hide()
        page.workshopRows[index] = row
    end
    page.workshopPrevious = CreateButton(listCard, "<", 38, 28, function()
        page.workshopPage = math.max(1, (page.workshopPage or 1) - 1)
        GC.UI:RefreshWorkshop()
    end)
    page.workshopPrevious:SetPoint("BOTTOMLEFT", listCard, "BOTTOMLEFT", 18, 12)
    page.workshopPageLabel = CreateLabel(listCard, "Seite 1/1", { muted = true, align = "CENTER", width = 120 })
    page.workshopPageLabel:SetPoint("LEFT", page.workshopPrevious, "RIGHT", 8, 0)
    page.workshopNext = CreateButton(listCard, ">", 38, 28, function()
        page.workshopPage = (page.workshopPage or 1) + 1
        GC.UI:RefreshWorkshop()
    end)
    page.workshopNext:SetPoint("LEFT", page.workshopPageLabel, "RIGHT", 8, 0)

    local detailCard = CreateCard(page, "Rezeptdetails")
    detailCard:SetSize(346, 342)
    detailCard:SetPoint("TOPRIGHT", searchCard, "BOTTOMRIGHT", 0, -12)
    -- Breite 170 statt 200: Rechts stehen inzwischen zwei Knöpfe übereinander
    -- ("Merken" und "In Auftrag geben", ab x 192); ein längerer Rezeptname
    -- muss vor ihnen umbrechen statt darunter zu verschwinden.
    page.workshopRecipeTitle = CreateLabel(detailCard, "Kein Rezept ausgewählt", {
        title = true,
        width = 170,
        height = 45,
        vertical = "TOP",
    })
    page.workshopRecipeTitle:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -49)
    page.workshopFavorite = CreateButton(detailCard, "Merken", 104, 30, function()
        local recipeKey = page.selectedWorkshopRecipe
        if recipeKey then
            GC.Workshop:SetFavorite(recipeKey, not GC.Workshop:IsFavorite(recipeKey))
            GC.UI:RefreshWorkshop()
        end
    end)
    page.workshopFavorite:SetPoint("TOPRIGHT", detailCard, "TOPRIGHT", -14, -12)
    -- Der Einstieg in einen Gildenauftrag sitzt direkt an der Rezeptkarte:
    -- die bestehende Suche ist die Rezeptauswahl, es gibt keinen zweiten Weg.
    page.workshopOrderButton = CreateButton(detailCard, "In Auftrag geben", 140, 30, function()
        if page.selectedWorkshopRecipe then
            GC.UI:OpenOrderCreateDialog(page.selectedWorkshopRecipe)
        end
    end, "PRIMARY")
    page.workshopOrderButton:SetPoint("TOPRIGHT", detailCard, "TOPRIGHT", -14, -46)
    page.workshopOrderButton:Hide()
    page.workshopFavorite.favoriteIcon = page.workshopFavorite:CreateTexture(nil, "ARTWORK")
    page.workshopFavorite.favoriteIcon:SetSize(17, 17)
    page.workshopFavorite.favoriteIcon:SetPoint("LEFT", page.workshopFavorite, "LEFT", 8, 0)
    SetRaidMarkerIcon(page.workshopFavorite.favoriteIcon, 1)
    page.workshopFavorite.label:ClearAllPoints()
    page.workshopFavorite.label:SetPoint("LEFT", page.workshopFavorite, "LEFT", 29, 0)
    page.workshopFavorite.label:SetPoint("RIGHT", page.workshopFavorite, "RIGHT", -7, 0)
    page.workshopFavorite.label:SetJustifyH("LEFT")
    local detailBody = CreatePanel(detailCard, THEME.input)
    detailBody:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -98)
    detailBody:SetPoint("BOTTOMRIGHT", detailCard, "BOTTOMRIGHT", -18, 16)
    page.workshopDetailScroll = CreateModernScrollFrame(detailBody)
    page.workshopDetailScroll:SetPoint("TOPLEFT", detailBody, "TOPLEFT", 8, -8)
    page.workshopDetailScroll:SetPoint("BOTTOMRIGHT", detailBody, "BOTTOMRIGHT", -12, 8)
    page.workshopDetailContent = CreateFrame("Frame", nil, page.workshopDetailScroll)
    page.workshopDetailContent:SetWidth(292)
    page.workshopDetailContent:SetHeight(220)
    page.workshopDetailScroll:SetScrollChild(page.workshopDetailContent)
    page.workshopDetails = CreateLabel(page.workshopDetailContent, "", { width = 274, height = 220, vertical = "TOP" })
    page.workshopDetails:SetPoint("TOPLEFT", page.workshopDetailContent, "TOPLEFT", 0, 0)

    -- Materialien als echte Zeilen mit festen Spalten. Ein Textblock kann das
    -- nicht: die Spielschrift ist proportional, Leerzeichen ergeben also keine
    -- Spalte, sondern nur ausgefranste Zahlen.
    page.workshopMaterialHeader = CreateLabel(page.workshopDetailContent, "Materialien",
        { muted = true, width = 176, height = 15 })
    page.workshopMaterialOwnHeader = CreateLabel(page.workshopDetailContent, "Du",
        { muted = true, width = 42, height = 15, align = "RIGHT" })
    page.workshopMaterialBankHeader = CreateLabel(page.workshopDetailContent, "GBank",
        { muted = true, width = 48, height = 15, align = "RIGHT" })
    page.workshopMaterialRows = {}
    for index = 1, 14 do
        local row = CreateFrame("Frame", nil, page.workshopDetailContent)
        row:SetSize(274, 15)
        row.name = CreateLabel(row, "", { width = 176, height = 15 })
        row.name:SetPoint("LEFT", row, "LEFT", 0, 0)
        row.own = CreateLabel(row, "", { width = 42, height = 15, align = "RIGHT" })
        row.own:SetPoint("LEFT", row, "LEFT", 178, 0)
        row.bank = CreateLabel(row, "", { width = 48, height = 15, align = "RIGHT" })
        row.bank:SetPoint("LEFT", row, "LEFT", 226, 0)
        row:Hide()
        page.workshopMaterialRows[index] = row
    end
    page.workshopMaterialSummary = CreateLabel(page.workshopDetailContent, "",
        { width = 274, height = 60, vertical = "TOP" })
    page.workshopMaterialFooter = CreateLabel(page.workshopDetailContent, "",
        { muted = true, width = 274, height = 30, vertical = "TOP" })

    page.workshopStatus = CreateLabel(page,
        "Öffne deine Berufe einmal, damit Guild Copilot die bekannten Rezepte einliest.",
        { muted = true, width = 776 })
    page.workshopStatus:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 0)

    -- Alles, was zum Katalog gehört, damit der Reiterwechsel es gemeinsam
    -- ein- und ausblenden kann.
    page.workshopCatalogFrames = {
        page.metricCards.RECIPES, page.metricCards.CRAFTERS, page.metricCards.PROFESSIONS,
        searchCard, listCard, detailCard, page.workshopStatus,
    }

    self:BuildOrdersView(page)
end

function GC.UI:RefreshWorkshop()
    local page = self.pages.WORKSHOP
    if not page then
        return
    end

    -- Reiterzustand und "du bist dran"-Zähler zuerst: beides gilt für beide
    -- Ansichten. Im Auftragsboard endet der Aufbau danach - die Katalogkarten
    -- sind dort ausgeblendet, ihre Auffrischung wäre reine Verschwendung.
    if page.workshopTabOrders then
        local actionable = GC.Orders and GC.Orders:GetActionableCount() or 0
        page.workshopTabOrders:SetText(actionable > 0
            and ("Gildenaufträge (" .. actionable .. ")")
            or "Gildenaufträge")
        page.workshopTabOrders:SetActive(page.workshopView == "ORDERS")
        page.workshopTabCatalog:SetActive(page.workshopView ~= "ORDERS")
    end
    if page.workshopView == "ORDERS" then
        self:RefreshOrdersBoard()
        return
    end

    local summary = GC.Workshop:GetSummary()
    page.metricCards.RECIPES.value:SetText(summary.recipes)
    page.metricCards.CRAFTERS.value:SetText(summary.crafters)
    page.metricCards.PROFESSIONS.value:SetText(summary.professions)

    local query = GC.Util.Trim(page.workshopSearch:GetText())
    local professionFilter = page.workshopProfession.value or ""
    local hasScope = query ~= "" or professionFilter ~= "" or page.workshopFavoritesOnly
    local entries = hasScope
        and GC.Workshop:GetCatalog(query, professionFilter, page.workshopFavoritesOnly)
        or {}
    page.workshopFavorites:SetActive(page.workshopFavoritesOnly == true)
    page.workshopFavorites:SetText("Favoriten")
    if page.workshopFavoritesOnly then
        page.workshopListTitle:SetText("Favorisierte Rezepte")
    elseif professionFilter ~= "" then
        page.workshopListTitle:SetText("Rezepte  •  " .. professionFilter)
    elseif query ~= "" then
        page.workshopListTitle:SetText("Suchergebnisse")
    else
        page.workshopListTitle:SetText("Gezielte Rezeptsuche")
    end
    local pageSize = #page.workshopRows
    local pageCount = math.max(1, math.ceil(#entries / pageSize))
    page.workshopPage = math.max(1, math.min(page.workshopPage or 1, pageCount))
    page.workshopPageLabel:SetText("Seite " .. page.workshopPage .. "/" .. pageCount)
    local showPagination = hasScope and #entries > pageSize
    page.workshopPrevious:SetShown(showPagination)
    page.workshopPageLabel:SetShown(showPagination)
    page.workshopNext:SetShown(showPagination)
    if page.workshopPage <= 1 then
        page.workshopPrevious:Disable()
    else
        page.workshopPrevious:Enable()
    end
    if page.workshopPage >= pageCount then
        page.workshopNext:Disable()
    else
        page.workshopNext:Enable()
    end

    local selected
    for _, recipe in ipairs(entries) do
        if recipe.key == page.selectedWorkshopRecipe then
            selected = recipe
            break
        end
    end
    if not selected and entries[1] then
        selected = entries[1]
        page.selectedWorkshopRecipe = selected.key
    end

    page.workshopVisibleRecipes = {}
    local startIndex = ((page.workshopPage - 1) * pageSize) + 1
    for rowIndex, row in ipairs(page.workshopRows) do
        local recipe = entries[startIndex + rowIndex - 1]
        page.workshopVisibleRecipes[rowIndex] = recipe
        row:SetShown(recipe ~= nil)
        if recipe then
            row:SetText(recipe.name)
            row.professionIcon:SetTexture(GC.ProfessionIcons[recipe.profession] or GC.ProfessionIcons[""])
            -- Bei aktivem Berufsfilter steht der Beruf schon in der
            -- Kartenueberschrift; die Wiederholung kostet nur Platz, den der
            -- Rezeptname besser braucht.
            row.meta:SetText(professionFilter ~= ""
                and tostring(#recipe.crafters)
                or (#recipe.crafters .. "  •  " .. recipe.profession))
            row.favoriteIcon:SetShown(GC.Workshop:IsFavorite(recipe.key))
            row:SetActive(page.selectedWorkshopRecipe == recipe.key)
        end
    end

    if not selected then
        page.workshopFavorite:Hide()
        page.workshopOrderButton:Hide()
        if not hasScope then
            page.workshopRecipeTitle:SetText("Wonach suchst du?")
            page.workshopDetails:SetText(
                "Gib einen Rezept- oder Spielernamen ein, wähle einen Beruf oder öffne deine Favoriten.\n\n"
                .. "So bleibt die Werkstatt auch mit tausenden bekannten Rezepten übersichtlich.")
        elseif page.workshopFavoritesOnly then
            page.workshopRecipeTitle:SetText("Keine Favoriten gefunden")
            page.workshopDetails:SetText(
                "Markiere häufig benötigte Rezepte mit dem Stern in den Rezeptdetails.")
        else
            page.workshopRecipeTitle:SetText("Keine Treffer")
            if professionFilter ~= "" then
                page.workshopDetails:SetText("Für " .. professionFilter
                    .. " wurden noch keine passenden Rezepte erfasst. Öffne das Berufsfenster oder frage Gildendaten an.")
            else
                page.workshopDetails:SetText("Prüfe den Suchbegriff oder frage aktuelle Gildendaten an.")
            end
        end
        -- Ohne Auswahl duerfen keine Materialzeilen von vorhin stehen bleiben.
        page.workshopDetails:SetHeight(220)
        page.workshopMaterialHeader:Hide()
        page.workshopMaterialOwnHeader:Hide()
        page.workshopMaterialBankHeader:Hide()
        for _, row in ipairs(page.workshopMaterialRows) do
            row:Hide()
        end
        page.workshopMaterialSummary:SetText("")
        page.workshopMaterialFooter:SetText("")
        page.workshopScrollAnchor = nil
        page.workshopDetailContent:SetHeight(220)
    else
        page.workshopFavorite:Show()
        page.workshopFavorite:SetText(GC.Workshop:IsFavorite(selected.key) and "Gemerkt" or "Merken")
        page.workshopFavorite:SetActive(GC.Workshop:IsFavorite(selected.key))
        -- Ohne bekannten Hersteller gibt es nichts zu beauftragen.
        page.workshopOrderButton:SetShown(#selected.crafters > 0)
        page.workshopRecipeTitle:SetText(selected.name)
        local lines = {
            "|cff91a3b8Beruf|r  " .. selected.profession,
            "",
            "|cff91a3b8Hersteller|r",
        }
        for _, crafter in ipairs(selected.crafters) do
            lines[#lines + 1] = "• " .. crafter
        end
        page.workshopDetails:SetText(table.concat(lines, "\n"))
        local infoHeight = math.max(15, WrappedTextHeight(
            page.workshopDetails, table.concat(lines, "\n"), 274)) + 6
        page.workshopDetails:SetHeight(infoHeight)

        -- Materialien stehen in echten Zeilen mit festen Spalten darunter.
        local status = #selected.reagents > 0
            and GC.Inventory:GetReagentStatus(selected.reagents)
            or nil
        local cursor = infoHeight + 8
        local headerShown = status ~= nil
        page.workshopMaterialHeader:SetShown(true)
        page.workshopMaterialHeader:ClearAllPoints()
        page.workshopMaterialHeader:SetPoint("TOPLEFT", page.workshopDetailContent, "TOPLEFT", 0, -cursor)
        page.workshopMaterialOwnHeader:SetShown(headerShown)
        page.workshopMaterialBankHeader:SetShown(headerShown)
        if headerShown then
            page.workshopMaterialOwnHeader:ClearAllPoints()
            page.workshopMaterialOwnHeader:SetPoint("TOPLEFT", page.workshopDetailContent, "TOPLEFT", 178, -cursor)
            page.workshopMaterialBankHeader:ClearAllPoints()
            page.workshopMaterialBankHeader:SetPoint("TOPLEFT", page.workshopDetailContent, "TOPLEFT", 226, -cursor)
        end
        cursor = cursor + 18

        for index, row in ipairs(page.workshopMaterialRows) do
            local entry = status and status.rows[index]
            row:SetShown(entry ~= nil)
            if entry then
                -- Nur die Zahlen tragen Farbe. Waeren auch die Namen rot,
                -- entstuende bei einem fehlenden Rezept eine Wand aus Rot, in
                -- der nichts mehr heraussticht.
                local label = entry.name or ("Item #" .. (entry.itemID or "?"))
                if #label > 28 then
                    label = label:sub(1, 27) .. "…"
                end
                row.name:SetText(entry.needed .. "× " .. label)
                SetTextColor(row.name, THEME.text)
                row.own:SetText(tostring(entry.own.total))
                SetTextColor(row.own,
                    entry.own.total >= entry.needed and THEME.success or THEME.danger)
                row.bank:SetText(entry.guildBank and tostring(entry.guildBank) or "–")
                if not entry.guildBank then
                    SetTextColor(row.bank, THEME.muted)
                elseif entry.status == "GUILD" then
                    SetTextColor(row.bank, THEME.warning)
                elseif entry.guildBank >= entry.shortfall and entry.shortfall > 0 then
                    SetTextColor(row.bank, THEME.warning)
                else
                    SetTextColor(row.bank, THEME.muted)
                end
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", page.workshopDetailContent, "TOPLEFT", 0, -cursor)
                cursor = cursor + 15
            end
        end

        if not status then
            page.workshopMaterialSummary:SetText("Keine Reagenzien erfasst.")
            SetTextColor(page.workshopMaterialSummary, THEME.muted)
        elseif #status.missing > 0 then
            local parts, fromBank = {}, 0
            for _, entry in ipairs(status.missing) do
                parts[#parts + 1] = entry.amount .. "× "
                    .. (entry.name or ("Item #" .. (entry.itemID or "?")))
                fromBank = fromBank + (entry.fromGuildBank or 0)
            end
            page.workshopMaterialSummary:SetText("|cffff6266Dir fehlt:|r "
                .. table.concat(parts, ", ")
                .. (fromBank > 0
                    and ("\n|cffe8b84b" .. fromBank .. " davon in der Gildenbank.|r")
                    or ""))
            SetTextColor(page.workshopMaterialSummary, THEME.text)
        else
            page.workshopMaterialSummary:SetText("|cff59e695Alle Materialien vorhanden.|r")
            SetTextColor(page.workshopMaterialSummary, THEME.text)
        end
        cursor = cursor + 8
        page.workshopMaterialSummary:ClearAllPoints()
        page.workshopMaterialSummary:SetPoint("TOPLEFT", page.workshopDetailContent, "TOPLEFT", 0, -cursor)
        local summaryHeight = math.max(15, WrappedTextHeight(
            page.workshopMaterialSummary,
            page.workshopMaterialSummary:GetText(), 274))
        page.workshopMaterialSummary:SetHeight(summaryHeight)
        cursor = cursor + summaryHeight + 8

        -- Herkunft und Alter der Bestaende, bewusst gedaempft: es ist Beiwerk,
        -- keine Kernaussage.
        local footer = {}
        if status then
            local guildBankAt, guildBankBy = nil, nil
            local ownBankAt = nil
            for _, row in ipairs(status.rows) do
                if row.guildBankAt and (not guildBankAt or row.guildBankAt > guildBankAt) then
                    guildBankAt = row.guildBankAt
                    guildBankBy = row.guildBankBy
                end
                if row.own.oldestBankAt and (not ownBankAt or row.own.oldestBankAt < ownBankAt) then
                    ownBankAt = row.own.oldestBankAt
                end
            end
            if not status.guildBankKnown then
                footer[#footer + 1] = "Gildenbank noch nicht eingelesen – einmal am Bankfach öffnen genügt."
            elseif guildBankAt and guildBankAt > 0 and date then
                footer[#footer + 1] = "Gildenbank: " .. date("%d.%m. %H:%M", guildBankAt)
                    .. (guildBankBy and guildBankBy ~= "" and (" · " .. guildBankBy) or "")
            end
            if ownBankAt and ownBankAt > 0 and date then
                footer[#footer + 1] = "Eigene Bank: " .. date("%d.%m. %H:%M", ownBankAt)
            end
        end
        page.workshopMaterialFooter:SetText(table.concat(footer, "\n"))
        page.workshopMaterialFooter:ClearAllPoints()
        page.workshopMaterialFooter:SetPoint("TOPLEFT", page.workshopDetailContent, "TOPLEFT", 0, -cursor)
        local footerHeight = #footer > 0
            and math.max(15, WrappedTextHeight(
                page.workshopMaterialFooter, table.concat(footer, "\n"), 274))
            or 0
        page.workshopMaterialFooter:SetHeight(math.max(1, footerHeight))
        cursor = cursor + footerHeight

        page.workshopDetailContent:SetHeight(math.max(220, cursor + 6))
        if page.workshopScrollAnchor ~= selected.key then
            page.workshopScrollAnchor = selected.key
            page.workshopDetailScroll:SetVerticalScroll(0)
        end
        page.workshopDetailScroll:UpdateModernThumb()
    end

    local missingProfessions = GC.Workshop:GetMissingOwnProfessions()
    local syncStats = GC.Workshop.syncStats or {}
    local pendingPackets = GC.Workshop:GetPendingPacketCount()
    if pendingPackets > 0 then
        page.workshopStatus:SetText("|cff2ed9e6Synchronisierung läuft:|r "
            .. pendingPackets .. " Pakete verbleiben. Das Fenster kann geschlossen werden.")
        SetTextColor(page.workshopStatus, THEME.accent)
    elseif (syncStats.failed or 0) > 0 then
        page.workshopStatus:SetText("|cffff6266Übertragung unvollständig:|r "
            .. syncStats.failed .. " Pakete konnten auch nach Wiederholungen nicht gesendet werden.")
        SetTextColor(page.workshopStatus, THEME.danger)
    elseif (syncStats.receivedProfessions or 0) > 0 then
        -- Der Zaehler zaehlt PAKETE, nicht Berufe: Derselbe Beruf desselben
        -- Herstellers kommt bei jedem Abgleich erneut. "110 Berufe" neben der
        -- 13-Berufe-Karte sah nach Doppelzaehlung aus - war es auch, nur im
        -- Text falsch beschriftet.
        page.workshopStatus:SetText("Abgleich: " .. syncStats.receivedProfessions
            .. " Berufspakete empfangen"
            .. (syncStats.lastSender ~= "" and ("  •  zuletzt " .. syncStats.lastSender) or "") .. ".")
        SetTextColor(page.workshopStatus, THEME.success)
    elseif #missingProfessions > 0 then
        page.workshopStatus:SetText("|cffffb84dNoch nicht eingelesen:|r "
            .. table.concat(missingProfessions, ", ") .. ". Das jeweilige Berufsfenster einmal geöffnet lassen.")
        SetTextColor(page.workshopStatus, THEME.warning)
    elseif GC.Workshop.lastScan then
        page.workshopStatus:SetText("Zuletzt erkannt: " .. GC.Workshop.lastScan.name
            .. "  •  " .. GC.Workshop.lastScan.recipes .. " Rezepte.")
        SetTextColor(page.workshopStatus, THEME.success)
    else
        page.workshopStatus:SetText("Öffne deine Berufe einmal, damit Guild Copilot die bekannten Rezepte einliest.")
        SetTextColor(page.workshopStatus, THEME.muted)
    end
end

-- === Gildenaufträge: Board, Dialoge, Ansicht ================================
-- Konzept: docs/KONZEPT-werkstatt-gildenauftraege.md. Das Board ersetzt bei
-- aktivem Reiter die Katalogkarten; die Logik liegt vollständig in Orders.lua,
-- hier wird nur gezeichnet und geklickt.

function GC.UI:SetWorkshopView(view)
    local page = self.pages.WORKSHOP
    if not page then
        return
    end
    page.workshopView = view == "ORDERS" and "ORDERS" or "CATALOG"
    local catalog = page.workshopView == "CATALOG"
    for _, frame in ipairs(page.workshopCatalogFrames or {}) do
        frame:SetShown(catalog)
    end
    if page.ordersView then
        page.ordersView:SetShown(not catalog)
    end
    self:RefreshWorkshop()
end

-- Die Handlungsaufforderung als Knopf: je Auftrag und Rolle genau eine
-- Primäraktion. Liefert Beschriftung und Ausführung oder nil.
local function OrderPrimaryAction(order)
    local orders = GC.Orders
    local ownName = GC:GetPlayerFullName()
    local isCreator = orders:IsCreatorCharacter(order, ownName)
    local isAcceptor = GC.Util.Trim(order.acceptedByTag) ~= ""
        and order.acceptedByTag == GC.DB:GetAccountTag()

    if isAcceptor then
        if order.status == "ACCEPTED" then
            return "Material vollständig", function(id)
                return orders:MarkMaterialsComplete(id)
            end
        elseif order.status == "WORKING" then
            return "Gefertigt", function(id)
                local target = orders:GetOrder(id)
                if target and (target.materialModel == "C" or (target.quantity or 1) > 1) then
                    GC.UI:OpenOrderCostDialog(id)
                    return true, ""
                end
                return orders:MarkCrafted(id)
            end
        elseif order.status == "CRAFTED" and order.delivery == "MAIL" then
            return "Versandt", function(id)
                return orders:MarkShipped(id)
            end
        elseif order.status == "CRAFTED" and order.delivery == "TRADE" then
            -- Übergabe vereinbaren: das Chatfenster mit dem richtigen
            -- Empfänger vorbelegen (Stufe 2).
            return "Anflüstern", function(id)
                return GC.UI:WhisperOrderCounterpart(id)
            end
        elseif order.status == "RECEIVED" and (order.reimbursedAt or 0) > 0 then
            return "Erstattung erhalten", function(id)
                return orders:ConfirmReimbursed(id)
            end
        end
    end
    if isCreator then
        if order.status == "CRAFTED" or order.status == "SHIPPED" then
            return "Erhalten", function(id)
                return orders:MarkReceived(id)
            end
        elseif order.status == "RECEIVED" and (order.reimbursedAt or 0) == 0 then
            return "Erstattet", function(id)
                GC.UI:OpenOrderPayDialog(id)
                return true, ""
            end
        elseif (order.status == "ACCEPTED" or order.status == "WORKING")
            and orders:IsStale(order) then
            return "Zurücklegen", function(id)
                return orders:Return(id, "Rückfall durch den Auftraggeber",
                    orders:HasAcceptorLeftGuild(orders:GetOrder(id)))
            end
        end
    end
    return nil
end

-- Farbkennzeichnung der Status: gelb wartet, türkis läuft, grün fertig,
-- rot abgebrochen. Die Hexwerte entsprechen THEME.warning/accent/success/
-- danger, wie sie das Addon auch sonst in Textform verwendet.
local ORDER_STATUS_COLORS = {
    OPEN = "|cffe8b84b",
    ACCEPTED = "|cff2ed9e6",
    WORKING = "|cff2ed9e6",
    CRAFTED = "|cff2ed9e6",
    SHIPPED = "|cff2ed9e6",
    RECEIVED = "|cffe8b84b",
    DONE = "|cff59e695",
    CANCELLED = "|cffff6266",
}

local function ColoredOrderStatus(order)
    return (ORDER_STATUS_COLORS[order.status] or "")
        .. (GC.OrderStatusLabels[order.status] or order.status) .. "|r"
end

local function OrderRowTitle(order)
    local ownName = GC:GetPlayerFullName()
    local isCreator = GC.Orders:IsCreatorCharacter(order, ownName)
    local counterpart
    if isCreator then
        counterpart = GC.Util.Trim(order.crafter) ~= ""
            and ("Hersteller: " .. GC.Util.PlayerShortName(order.crafter))
            or "noch ohne Hersteller"
    else
        counterpart = "von " .. GC.Util.PlayerShortName(order.createdBy or "?")
    end
    return (order.recipeName or order.recipeKey or "?")
        .. " ×" .. (order.quantity or 1)
        .. "  ·  " .. counterpart
        .. "  ·  " .. ColoredOrderStatus(order)
end

local function OrderOfferLine(order)
    local parts = { GC.OrderModelLabels[order.materialModel] or "?" }
    parts[#parts + 1] = GC.OrderDeliveryLabels[order.delivery] or "?"
    if (order.costLimit or 0) > 0 then
        parts[#parts + 1] = "bis " .. GC.Orders.FormatMoney(order.costLimit)
    end
    if (order.tip or 0) > 0 then
        parts[#parts + 1] = "Trinkgeld " .. GC.Orders.FormatMoney(order.tip)
    end
    if GC.Util.Trim(order.note) ~= "" then
        parts[#parts + 1] = "„" .. order.note .. "“"
    end
    return table.concat(parts, "  ·  ")
end

local function BuildOrderRow(parent, height, withPrimary)
    local row = CreatePanel(parent, THEME.card)
    row:SetSize(776, height)
    row.title = CreateLabel(row, "", { width = 470, height = 16 })
    row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 14, -7)
    row.detail = CreateLabel(row, "", { muted = true, width = 470, height = 15 })
    row.detail:SetPoint("TOPLEFT", row, "TOPLEFT", 14, -25)
    row.logButton = CreateButton(row, "Verlauf", 74, 28, function()
        if row.orderID then
            GC.UI:OpenOrderLogDialog(row.orderID)
        end
    end)
    row.logButton:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    row.cancelButton = CreateButton(row, "×", 28, 28, function()
        if row.orderID then
            local ok, message = GC.Orders:Cancel(row.orderID)
            GC.UI:SetOrdersStatus(message, ok)
        end
    end)
    row.cancelButton:SetPoint("RIGHT", row.logButton, "LEFT", -6, 0)
    if withPrimary then
        row.primary = CreateButton(row, "", 168, 28, function()
            if row.orderID and row.primaryHandler then
                local ok, message = row.primaryHandler(row.orderID)
                GC.UI:SetOrdersStatus(message, ok)
            end
        end, "PRIMARY")
        row.primary:SetPoint("RIGHT", row.cancelButton, "LEFT", -6, 0)
    end
    row:Hide()
    return row
end

function GC.UI:BuildOrdersView(page)
    local view = CreateFrame("Frame", nil, page)
    view:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)
    view:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)
    view:Hide()
    page.ordersView = view

    view.mineHeader = CreateLabel(view, "DU BIST DRAN", { muted = true, width = 500, height = 15 })
    view.mineHeader:SetPoint("TOPLEFT", view, "TOPLEFT", 0, 0)
    view.mineRows = {}
    for index = 1, 3 do
        local row = BuildOrderRow(view, 44, true)
        row:SetPoint("TOPLEFT", view, "TOPLEFT", 0, -19 - ((index - 1) * 48))
        view.mineRows[index] = row
    end

    view.openHeader = CreateLabel(view, "OFFENE AUFTRÄGE DER GILDE",
        { muted = true, width = 500, height = 15 })
    view.openHeader:SetPoint("TOPLEFT", view, "TOPLEFT", 0, -168)
    view.openFilter = CreateButton(view, "nur machbare", 128, 24, function()
        page.ordersShowAll = not page.ordersShowAll
        GC.UI:RefreshOrdersBoard()
    end)
    view.openFilter:SetPoint("TOPRIGHT", view, "TOPRIGHT", 0, -164)
    view.openRows = {}
    for index = 1, 3 do
        local row = BuildOrderRow(view, 44, true)
        row:SetPoint("TOPLEFT", view, "TOPLEFT", 0, -191 - ((index - 1) * 48))
        view.openRows[index] = row
    end

    view.closedHeader = CreateLabel(view, "ABGESCHLOSSEN", { muted = true, width = 500, height = 15 })
    view.closedHeader:SetPoint("TOPLEFT", view, "TOPLEFT", 0, -340)
    view.closedRows = {}
    for index = 1, 3 do
        local row = CreateLabel(view, "", { muted = true, width = 700, height = 15 })
        row:SetPoint("TOPLEFT", view, "TOPLEFT", 14, -359 - ((index - 1) * 17))
        view.closedRows[index] = row
    end

    view.trackerToggle = CreateButton(view, "Tracker", 96, 24, function()
        GC.UI:ToggleOrderTracker()
    end)
    view.trackerToggle:SetPoint("BOTTOMRIGHT", view, "BOTTOMRIGHT", 0, 0)

    view.status = CreateLabel(view, "", { muted = true, width = 640, height = 30, vertical = "TOP" })
    view.status:SetPoint("BOTTOMLEFT", view, "BOTTOMLEFT", 0, 0)

    view.statsButton = CreateButton(view, "Statistik", 96, 24, function()
        GC.UI:OpenOrderStatsDialog()
    end)
    view.statsButton:SetPoint("RIGHT", view.trackerToggle, "LEFT", -8, 0)

    self:BuildOrderCreateDialog(page)
    self:BuildOrderLogDialog(page)
    self:BuildOrderCostDialog(page)
    self:BuildOrderPayDialog(page)
    self:BuildOrderAcceptDialog(page)
    self:BuildOrderStatsDialog(page)
end

function GC.UI:SetOrdersStatus(message, success)
    local page = self.pages.WORKSHOP
    if not page or not page.ordersView then
        return
    end
    page.ordersView.status:SetText(message or "")
    SetTextColor(page.ordersView.status, success and THEME.success or THEME.danger)
end

local function FillOrderRow(row, boardRow, isOpenSection)
    local order = boardRow.order
    row.orderID = order.id
    row.title:SetText(OrderRowTitle(order))
    if isOpenSection then
        row.detail:SetText(OrderOfferLine(order))
        row.primaryHandler = function(id)
            return GC.UI:AcceptOrder(id)
        end
        row.primary:SetText("Annehmen")
        row.primary:SetShown(boardRow.canAccept == true)
        if boardRow.reserved then
            row.detail:SetText("|cffe8b84bReserviert für "
                .. GC.Util.PlayerShortName(order.preferredCrafter or "?")
                .. "|r  ·  " .. OrderOfferLine(order))
        elseif not boardRow.canAccept then
            row.detail:SetText("Kein Charakter deines Accounts kann dieses Rezept  ·  "
                .. OrderOfferLine(order))
        end
    else
        row.detail:SetText(boardRow.yourTurn and boardRow.action or OrderOfferLine(order))
        local label, handler = OrderPrimaryAction(order)
        row.primaryHandler = handler
        if row.primary then
            row.primary:SetText(label or "")
            row.primary:SetShown(label ~= nil)
        end
    end
    local ownName = GC:GetPlayerFullName()
    row.cancelButton:SetShown(order.status ~= "DONE" and order.status ~= "CANCELLED"
        and (GC.Orders:IsCreatorCharacter(order, ownName) or GC.Orders:CanAdministrate(ownName)))

    -- Farbkennzeichnung am Rahmen: türkis heißt "du bist dran", grün heißt
    -- "für dich machbar", sonst die neutrale Kartenlinie. Dazu springt die
    -- Aufgabenzeile in Warnfarbe, statt grau unterzugehen.
    if boardRow.yourTurn then
        row:SetBackdropBorderColor(THEME.accent[1], THEME.accent[2], THEME.accent[3], 1)
        SetTextColor(row.detail, THEME.warning)
    elseif isOpenSection and boardRow.canAccept then
        row:SetBackdropBorderColor(THEME.success[1], THEME.success[2], THEME.success[3], 1)
        SetTextColor(row.detail, THEME.muted)
    else
        row:SetBackdropBorderColor(THEME.border[1], THEME.border[2], THEME.border[3], 1)
        SetTextColor(row.detail, THEME.muted)
    end
    row:Show()
end

function GC.UI:RefreshOrdersBoard()
    local page = self.pages.WORKSHOP
    local view = page and page.ordersView
    if not view then
        return
    end
    local board = GC.Orders:GetBoard()

    view.mineHeader:SetText("DU BIST DRAN  ·  MEINE AUFTRÄGE (" .. #board.mine .. ")")
    for index, row in ipairs(view.mineRows) do
        local boardRow = board.mine[index]
        if boardRow then
            FillOrderRow(row, boardRow, false)
        else
            row:Hide()
        end
    end

    local open = {}
    for _, boardRow in ipairs(board.open) do
        if page.ordersShowAll or boardRow.canAccept then
            open[#open + 1] = boardRow
        end
    end
    view.openFilter:SetActive(not page.ordersShowAll)
    view.openHeader:SetText("OFFENE AUFTRÄGE DER GILDE (" .. #open .. ")")
    for index, row in ipairs(view.openRows) do
        local boardRow = open[index]
        if boardRow then
            FillOrderRow(row, boardRow, true)
        else
            row:Hide()
        end
    end

    view.closedHeader:SetText("ABGESCHLOSSEN (" .. #board.closed .. ")")
    for index, label in ipairs(view.closedRows) do
        local boardRow = board.closed[index]
        if boardRow then
            local order = boardRow.order
            label:SetText((order.recipeName or "?") .. " ×" .. (order.quantity or 1)
                .. "  ·  " .. ColoredOrderStatus(order)
                .. "  ·  " .. GC.Util.PlayerShortName(order.createdBy or "?"))
            label:Show()
        else
            label:Hide()
        end
    end

    local settings = GC.DB:GetSettings().orderTracker
    view.trackerToggle:SetText(settings.hidden and "Tracker einblenden" or "Tracker ausblenden")
    view.trackerToggle:SetActive(not settings.hidden)
end

-- Annehmen mit Twink-Wahl: Ein Charakter nimmt direkt an, bei mehreren
-- fragt ein kleiner Dialog, wer fertigt (Konzept, Owner-Abnahme).
function GC.UI:AcceptOrder(orderID)
    local order = GC.Orders:GetOrder(orderID)
    if not order then
        return false, "Der Auftrag ist nicht mehr bekannt."
    end
    local candidates = GC.Orders:GetOwnCrafters(order.recipeKey)
    if #candidates > 1 then
        self:OpenOrderAcceptDialog(orderID, candidates)
        return true, ""
    end
    local ok, message = GC.Orders:Accept(orderID, candidates[1])
    self:SetOrdersStatus(message, ok)
    return ok, message
end

local function BuildOrderDialogFrame(page, width, height, titleText)
    -- Wie die Dropdown-Menüs hängen die Dialoge NICHT unter der Seite: Die
    -- Seiten liegen in einem ScrollFrame, dessen Kinder beschnitten werden und
    -- deren Ebenen sich mit den Seitenkarten mischen - dahinterliegende Knöpfe
    -- schimmerten durch. Als Kind des Hauptfensters mit eigener hoher Ebene
    -- und voll deckendem Hintergrund liegt der Dialog sauber über allem.
    local host = GC.UI.frame or UIParent
    local dialog = CreatePanel(host, THEME.window, THEME.accent)
    dialog:SetSize(width, height)
    dialog:SetPoint("CENTER", host, "CENTER", 0, 0)
    local hostLevel = host.GetFrameLevel and host:GetFrameLevel() or 1
    dialog:SetFrameLevel((hostLevel or 1) + 80)
    dialog:SetBackdropColor(THEME.window[1], THEME.window[2], THEME.window[3], 1)
    dialog:EnableMouse(true)
    dialog.title = CreateLabel(dialog, titleText, { title = true, width = width - 60 })
    dialog.title:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -12)
    dialog.close = CreateButton(dialog, "×", 24, 24, function()
        dialog:Hide()
    end)
    dialog.close:SetPoint("TOPRIGHT", dialog, "TOPRIGHT", -8, -8)
    dialog:Hide()
    -- Wechselt die Seite oder schließt das Fenster, geht der Dialog mit zu.
    page:HookScript("OnHide", function()
        dialog:Hide()
    end)
    return dialog
end

function GC.UI:BuildOrderCreateDialog(page)
    local dialog = BuildOrderDialogFrame(page, 452, 428, "Gildenauftrag erstellen")
    page.orderCreateDialog = dialog

    local function RadioRow(labelText, y, options, field)
        local caption = CreateLabel(dialog, labelText, { muted = true, width = 120, height = 15 })
        caption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, y)
        local buttons = {}
        -- Die x-Position läuft mit der Summe der bisherigen Breiten mit;
        -- vorher stand der dritte, breitere Knopf außerhalb des Dialogs.
        local cursor = 16
        for index, option in ipairs(options) do
            local button = CreateButton(dialog, option.label, option.width, 24, function()
                dialog[field] = option.value
                for _, sibling in ipairs(buttons) do
                    sibling:SetActive(dialog[field] == sibling.optionValue)
                end
                dialog.costCaption:SetShown(dialog.materialModel == "C")
                dialog.costEdit.container:SetShown(dialog.materialModel == "C")
            end)
            button.optionValue = option.value
            button:SetPoint("TOPLEFT", dialog, "TOPLEFT", cursor, y - 17)
            cursor = cursor + option.width + 6
            buttons[index] = button
        end
        dialog[field .. "Buttons"] = buttons
    end

    RadioRow("Materialien", -40, {
        { value = "A", label = "Ich liefere", width = 100 },
        { value = "B", label = "Gildenbank", width = 100 },
        { value = "C", label = "Wird besorgt, ich erstatte", width = 190 },
    }, "materialModel")

    RadioRow("Übergabe", -94, {
        { value = "TRADE", label = "Persönlich", width = 100 },
        { value = "MAIL", label = "Per Post", width = 100 },
    }, "delivery")

    dialog.quantityCaption = CreateLabel(dialog, "Menge", { muted = true, width = 90, height = 15 })
    dialog.quantityCaption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -148)
    dialog.quantityEdit = CreateEdit(dialog, 66, 26)
    dialog.quantityEdit.container:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -165)

    dialog.costCaption = CreateLabel(dialog, "Kostenrahmen (Gold)", { muted = true, width = 150, height = 15 })
    dialog.costCaption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 100, -148)
    dialog.costEdit = CreateEdit(dialog, 90, 26)
    dialog.costEdit.container:SetPoint("TOPLEFT", dialog, "TOPLEFT", 100, -165)

    dialog.tipCaption = CreateLabel(dialog, "Trinkgeld (Gold)", { muted = true, width = 120, height = 15 })
    dialog.tipCaption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 268, -148)
    dialog.tipEdit = CreateEdit(dialog, 90, 26)
    dialog.tipEdit.container:SetPoint("TOPLEFT", dialog, "TOPLEFT", 268, -165)

    dialog.noteCaption = CreateLabel(dialog, "Notiz (optional)", { muted = true, width = 200, height = 15 })
    dialog.noteCaption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -206)
    dialog.noteEdit = CreateEdit(dialog, 398, 26)
    dialog.noteEdit.container:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -223)

    -- Gerichteter Auftrag: 24 Stunden nur für diesen Hersteller, danach
    -- offen für alle. Die Auswahl ist eine Liste der bekannten Hersteller
    -- des Rezepts (Owner-Wunsch: kein Freitext).
    dialog.preferredCaption = CreateLabel(dialog, "Wunsch-Hersteller (optional, 24 h reserviert)",
        { muted = true, width = 300, height = 15 })
    dialog.preferredCaption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -258)
    dialog.preferredValue = ""
    dialog.preferredButton = CreateButton(dialog, "(keiner)", 180, 26, function()
        GC.UI:ToggleOrderCrafterList(dialog)
    end)
    dialog.preferredButton:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -275)

    -- Die Aufklappliste: ein Zeilenvorrat, je Öffnen mit den Herstellern des
    -- Rezepts gefüllt - "(keiner)" steht immer zuoberst.
    dialog.crafterList = CreatePanel(dialog, THEME.input, THEME.accent)
    dialog.crafterList:SetSize(180, 10)
    dialog.crafterList:SetPoint("TOPLEFT", dialog.preferredButton, "BOTTOMLEFT", 0, -2)
    dialog.crafterList:SetFrameLevel((dialog:GetFrameLevel() or 1) + 10)
    dialog.crafterList.rows = {}
    for index = 1, 9 do
        local rowButton = CreateButton(dialog.crafterList, "", 172, 22, function()
            local chosen = dialog.crafterList.rows[index].crafterName or ""
            dialog.preferredValue = chosen
            dialog.preferredButton:SetText(chosen ~= ""
                and GC.Util.PlayerShortName(chosen) or "(keiner)")
            dialog.crafterList:Hide()
        end)
        rowButton:SetPoint("TOPLEFT", dialog.crafterList, "TOPLEFT", 4, -4 - ((index - 1) * 24))
        rowButton:Hide()
        dialog.crafterList.rows[index] = rowButton
    end
    dialog.crafterList:Hide()
    dialog.templateButton = CreateButton(dialog, "Als Vorlage merken", 160, 26, function()
        local saved = GC.Orders:SaveTemplate(dialog.recipeKey, {
            quantity = tonumber(GC.Util.Trim(dialog.quantityEdit:GetText())) or 1,
            materialModel = dialog.materialModel,
            delivery = dialog.delivery,
            costLimit = math.floor((tonumber(GC.Util.Trim(dialog.costEdit:GetText())) or 0) * 10000),
            tip = math.floor((tonumber(GC.Util.Trim(dialog.tipEdit:GetText())) or 0) * 10000),
            note = dialog.noteEdit:GetText(),
            preferredCrafter = dialog.preferredValue,
        })
        dialog.status:SetText(saved and "Vorlage gemerkt – sie füllt diesen Dialog beim nächsten Mal vor."
            or "Vorlage konnte nicht gemerkt werden.")
        SetTextColor(dialog.status, saved and THEME.success or THEME.danger)
    end)
    dialog.templateButton:SetPoint("TOPLEFT", dialog, "TOPLEFT", 252, -273)

    dialog.status = CreateLabel(dialog, "", { muted = true, width = 398, height = 46, vertical = "TOP" })
    dialog.status:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -312)

    dialog.submit = CreateButton(dialog, "Erstellen", 150, 32, function()
        local gold = tonumber(GC.Util.Trim(dialog.costEdit:GetText())) or 0
        local tip = tonumber(GC.Util.Trim(dialog.tipEdit:GetText())) or 0
        local ok, message = GC.Orders:Create(dialog.recipeKey, {
            quantity = tonumber(GC.Util.Trim(dialog.quantityEdit:GetText())) or 1,
            materialModel = dialog.materialModel,
            delivery = dialog.delivery,
            costLimit = math.floor(gold * 10000),
            tip = math.floor(tip * 10000),
            note = dialog.noteEdit:GetText(),
            preferredCrafter = dialog.preferredValue,
        })
        if ok then
            dialog:Hide()
            GC.UI:SetWorkshopView("ORDERS")
            if GC.Orders:GetOnlineAddonUserCount() == 0 then
                GC.UI:SetOrdersStatus((message or "")
                    .. " |cffe8b84bGerade ist niemand mit Guild Copilot online - "
                    .. "verteilt wird beim nächsten gemeinsamen Login.|r", true)
            else
                GC.UI:SetOrdersStatus(message, true)
            end
        else
            dialog.status:SetText(message or "")
            SetTextColor(dialog.status, THEME.danger)
        end
    end, "PRIMARY")
    dialog.submit:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 16, 14)
    dialog.cancel = CreateButton(dialog, "Abbrechen", 110, 32, function()
        dialog:Hide()
    end)
    dialog.cancel:SetPoint("LEFT", dialog.submit, "RIGHT", 10, 0)
end

function GC.UI:OpenOrderCreateDialog(recipeKey)
    local page = self.pages.WORKSHOP
    local dialog = page and page.orderCreateDialog
    if not dialog then
        return
    end
    local entry
    for _, candidate in ipairs(GC.Workshop:GetCatalog()) do
        if candidate.key == recipeKey then
            entry = candidate
            break
        end
    end
    dialog.recipeKey = recipeKey
    dialog.title:SetText("Gildenauftrag: " .. ((entry and entry.name) or recipeKey))
    -- Vorlage des Rezepts, falls gemerkt - sonst die Grundeinstellung.
    local template = GC.Orders:GetTemplate(recipeKey)
    dialog.materialModel = template and template.materialModel or "A"
    dialog.delivery = template and template.delivery or "TRADE"
    for _, button in ipairs(dialog.materialModelButtons or {}) do
        button:SetActive(button.optionValue == dialog.materialModel)
    end
    for _, button in ipairs(dialog.deliveryButtons or {}) do
        button:SetActive(button.optionValue == dialog.delivery)
    end
    dialog.quantityEdit:SetText(tostring(template and template.quantity or 1))
    dialog.costEdit:SetText(template and template.costLimit and template.costLimit > 0
        and tostring(math.floor(template.costLimit / 10000)) or "")
    dialog.tipEdit:SetText(template and template.tip and template.tip > 0
        and tostring(math.floor(template.tip / 10000)) or "")
    dialog.noteEdit:SetText(template and template.note or "")
    dialog.preferredValue = template and template.preferredCrafter or ""
    dialog.preferredButton:SetText(dialog.preferredValue ~= ""
        and GC.Util.PlayerShortName(dialog.preferredValue) or "(keiner)")
    dialog.recipeCrafters = (entry and entry.crafters) or {}
    dialog.crafterList:Hide()
    dialog.costCaption:SetShown(dialog.materialModel == "C")
    dialog.costEdit.container:SetShown(dialog.materialModel == "C")
    -- Ohne Gegenstelle kein Sync: Die Aufträge reisen nur von Client zu
    -- Client. Wer allein online ist, soll das VOR dem Erstellen wissen -
    -- der Auftrag geht nicht verloren, aber er erreicht die Gilde erst
    -- beim nächsten gemeinsamen Online-Moment.
    if GC.Orders:GetOnlineAddonUserCount() == 0 then
        dialog.status:SetText("|cffe8b84bHinweis:|r Gerade ist niemand mit Guild Copilot online. "
            .. "Der Auftrag wird gespeichert und verteilt sich, sobald du gemeinsam "
            .. "mit anderen Addon-Nutzern online bist.")
        SetTextColor(dialog.status, THEME.text)
    else
        dialog.status:SetText("")
    end
    dialog:Show()
end

function GC.UI:BuildOrderLogDialog(page)
    local dialog = BuildOrderDialogFrame(page, 470, 360, "Verlauf")
    page.orderLogDialog = dialog
    dialog.body = CreateLabel(dialog, "", { width = 434, height = 220, vertical = "TOP" })
    dialog.body:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -42)
    dialog.noteEdit = CreateEdit(dialog, 212, 26)
    dialog.noteEdit.container:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 16, 14)
    dialog.noteSend = CreateButton(dialog, "Notiz senden", 118, 26, function()
        local ok, message = GC.Orders:AddNote(dialog.orderID, dialog.noteEdit:GetText())
        if ok then
            dialog.noteEdit:SetText("")
            GC.UI:RefreshOrderLogDialog()
        end
        GC.UI:SetOrdersStatus(message, ok)
    end, "PRIMARY")
    dialog.noteSend:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -16, 14)
    dialog.whisper = CreateButton(dialog, "Anflüstern", 96, 26, function()
        GC.UI:WhisperOrderCounterpart(dialog.orderID)
    end)
    dialog.whisper:SetPoint("RIGHT", dialog.noteSend, "LEFT", -6, 0)
end

function GC.UI:RefreshOrderLogDialog()
    local page = self.pages.WORKSHOP
    local dialog = page and page.orderLogDialog
    if not dialog or not dialog:IsShown() then
        return
    end
    local order = GC.Orders:GetOrder(dialog.orderID)
    if not order then
        dialog:Hide()
        return
    end
    dialog.title:SetText("Verlauf: " .. (order.recipeName or "?"))
    local lines = {}
    for index = #order.log, 1, -1 do
        local entry = order.log[index]
        local stamp = date and date("%d.%m. %H:%M", entry.at) or tostring(entry.at)
        lines[#lines + 1] = "|cff91a3b8" .. stamp .. "|r  "
            .. GC.Util.PlayerShortName(entry.by or "?") .. ": "
            .. (GC.OrderEventLabels[entry.event] or entry.event)
            .. (GC.Util.Trim(entry.note or "") ~= "" and ("  –  " .. entry.note) or "")
    end
    if (order.actualCost or 0) > 0 then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Gemeldete Kosten: " .. GC.Orders.FormatMoney(order.actualCost)
            .. ((order.costLimit or 0) > 0 and order.actualCost > order.costLimit
                and "  |cffff6266(über dem Kostenrahmen)|r" or "")
    end
    dialog.body:SetText(table.concat(lines, "\n"))
end

function GC.UI:OpenOrderLogDialog(orderID)
    local page = self.pages.WORKSHOP
    local dialog = page and page.orderLogDialog
    if not dialog then
        return
    end
    dialog.orderID = orderID
    dialog.noteEdit:SetText("")
    dialog:Show()
    self:RefreshOrderLogDialog()
end

function GC.UI:BuildOrderCostDialog(page)
    local dialog = BuildOrderDialogFrame(page, 360, 210, "Gefertigt melden")
    page.orderCostDialog = dialog
    dialog.caption = CreateLabel(dialog,
        "Tatsächliche Materialkosten in Gold (0, wenn nichts anfiel):",
        { muted = true, width = 324, height = 30, vertical = "TOP" })
    dialog.caption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -42)
    dialog.costEdit = CreateEdit(dialog, 100, 26)
    dialog.costEdit.container:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -80)
    -- Teilfertigung: Bei Stückzahlen > 1 fragt der Dialog den Gesamtstand ab;
    -- unter der vollen Menge bleibt der Auftrag in Arbeit.
    dialog.countCaption = CreateLabel(dialog, "Stück insgesamt fertig:",
        { muted = true, width = 180, height = 15 })
    dialog.countCaption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -114)
    dialog.countEdit = CreateEdit(dialog, 70, 26)
    dialog.countEdit.container:SetPoint("TOPLEFT", dialog, "TOPLEFT", 200, -110)
    dialog.submit = CreateButton(dialog, "Melden", 150, 30, function()
        local gold = tonumber(GC.Util.Trim(dialog.costEdit:GetText())) or 0
        local ok, message = GC.Orders:MarkCrafted(dialog.orderID,
            math.floor(gold * 10000), nil,
            tonumber(GC.Util.Trim(dialog.countEdit:GetText())))
        GC.UI:SetOrdersStatus(message, ok)
        if ok then
            dialog:Hide()
        end
    end, "PRIMARY")
    dialog.submit:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 16, 14)
end

function GC.UI:OpenOrderCostDialog(orderID)
    local page = self.pages.WORKSHOP
    local dialog = page and page.orderCostDialog
    if not dialog then
        return
    end
    local order = GC.Orders:GetOrder(orderID)
    dialog.orderID = orderID
    dialog.costEdit:SetText("")
    local isC = order and order.materialModel == "C"
    dialog.caption:SetShown(isC == true)
    dialog.costEdit.container:SetShown(isC == true)
    local multi = order and (order.quantity or 1) > 1
    dialog.countCaption:SetShown(multi == true)
    dialog.countEdit.container:SetShown(multi == true)
    if multi then
        dialog.countCaption:SetText("Stück insgesamt fertig (von " .. order.quantity .. "):")
        dialog.countEdit:SetText(tostring(order.quantity))
    end
    dialog:Show()
end

-- Teilzahlungs-Dialog des Auftraggebers: vorgefüllt mit dem offenen Rest.
function GC.UI:BuildOrderPayDialog(page)
    local dialog = BuildOrderDialogFrame(page, 360, 170, "Erstattung überweisen")
    page.orderPayDialog = dialog
    dialog.caption = CreateLabel(dialog, "", { muted = true, width = 324, height = 30, vertical = "TOP" })
    dialog.caption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -42)
    dialog.amountEdit = CreateEdit(dialog, 100, 26)
    dialog.amountEdit.container:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -80)
    dialog.submit = CreateButton(dialog, "Gezahlt melden", 150, 30, function()
        local gold = tonumber(GC.Util.Trim(dialog.amountEdit:GetText())) or 0
        local ok, message = GC.Orders:MarkReimbursed(dialog.orderID, math.floor(gold * 10000))
        GC.UI:SetOrdersStatus(message, ok)
        if ok then
            dialog:Hide()
        end
    end, "PRIMARY")
    dialog.submit:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 16, 14)
end

function GC.UI:OpenOrderPayDialog(orderID)
    local page = self.pages.WORKSHOP
    local dialog = page and page.orderPayDialog
    if not dialog then
        return
    end
    local order = GC.Orders:GetOrder(orderID)
    if not order then
        return
    end
    local rest = math.max(0, (order.actualCost or 0) - (order.reimbursedPaid or 0))
    dialog.orderID = orderID
    dialog.caption:SetText("Offen sind " .. GC.Orders.FormatMoney(rest)
        .. ". Betrag in Gold (Teilzahlungen sind erlaubt):")
    dialog.amountEdit:SetText(tostring(math.floor(rest / 10000)))
    dialog:Show()
end

-- Die Wunsch-Hersteller-Liste im Erstellen-Dialog: "(keiner)" plus die
-- bekannten Hersteller des Rezepts aus dem Katalog.
function GC.UI:ToggleOrderCrafterList(dialog)
    local list = dialog.crafterList
    if list:IsShown() then
        list:Hide()
        return
    end
    local names = { "" }
    for _, crafterName in ipairs(dialog.recipeCrafters or {}) do
        names[#names + 1] = crafterName
    end
    local visible = math.min(#names, #list.rows)
    for index, rowButton in ipairs(list.rows) do
        local name = names[index]
        rowButton.crafterName = name
        rowButton:SetText(name and (name ~= "" and GC.Util.PlayerShortName(name) or "(keiner)") or "")
        rowButton:SetShown(index <= visible)
    end
    list:SetHeight(8 + (visible * 24))
    list:Show()
end

-- Der vorbelegte Übergabetext: {name} wird zum Empfänger, {rezept} zum
-- Rezept. Anpassbar in den Einstellungen; gesendet wird erst mit Enter.
function GC.UI:BuildOrderWhisper(order)
    if not order then
        return nil, nil
    end
    local target = GC.Orders:GetCounterpartCharacter(order)
    if not target then
        return nil, nil
    end
    local text = GC.DB:GetSettings().orderWhisperText or ""
    text = text:gsub("{name}", GC.Util.PlayerShortName(target))
        :gsub("{rezept}", order.recipeName or "?")
    return target, text
end

-- Das Chatfenster mit der Gegenseite und dem Übergabetext vorbelegen
-- (Stufe 2). Ohne Chat-API (Tests) bleibt es beim Hinweis mit dem Namen.
function GC.UI:WhisperOrderCounterpart(orderID)
    local order = GC.Orders:GetOrder(orderID)
    local target, text = self:BuildOrderWhisper(order)
    if not target then
        self:SetOrdersStatus("Kein Charakter der Gegenseite bekannt.", false)
        return false, ""
    end
    if ChatFrame_OpenChat then
        ChatFrame_OpenChat("/w " .. target .. " " .. (text or ""), DEFAULT_CHAT_FRAME)
        return true, ""
    end
    self:SetOrdersStatus("Gegenseite: " .. GC.Util.PlayerShortName(target), true)
    return true, ""
end

-- Auftragsstatistik: erledigte Aufträge je Hersteller, erstellte je
-- Auftraggeber. Auf Owner-Wunsch trotz des Konzept-Vorbehalts (sozialer
-- Druck) eingebaut.
function GC.UI:BuildOrderStatsDialog(page)
    local dialog = BuildOrderDialogFrame(page, 400, 360, "Auftragsstatistik")
    page.orderStatsDialog = dialog
    dialog.body = CreateLabel(dialog, "", { width = 364, height = 290, vertical = "TOP" })
    dialog.body:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -42)
end

function GC.UI:OpenOrderStatsDialog()
    local page = self.pages.WORKSHOP
    local dialog = page and page.orderStatsDialog
    if not dialog then
        return
    end
    local stats = GC.Orders:GetStats()
    local names = {}
    local merged = {}
    local function Bucket(map, field)
        for name, count in pairs(map or {}) do
            if not merged[name] then
                merged[name] = { fulfilled = 0, created = 0 }
                names[#names + 1] = name
            end
            merged[name][field] = count
        end
    end
    Bucket(stats.byCrafter, "fulfilled")
    Bucket(stats.byCreator, "created")
    table.sort(names, function(left, right)
        if merged[left].fulfilled ~= merged[right].fulfilled then
            return merged[left].fulfilled > merged[right].fulfilled
        end
        return left < right
    end)
    local lines = {}
    for index = 1, math.min(#names, 16) do
        local name = names[index]
        lines[#lines + 1] = name .. "  –  |cff59e695" .. merged[name].fulfilled
            .. " erledigt|r · " .. merged[name].created .. " erstellt"
    end
    dialog.body:SetText(#lines > 0 and table.concat(lines, "\n")
        or "Noch keine abgeschlossenen Aufträge gezählt.")
    dialog:Show()
end

function GC.UI:BuildOrderAcceptDialog(page)
    local dialog = BuildOrderDialogFrame(page, 360, 216, "Wer fertigt?")
    page.orderAcceptDialog = dialog
    dialog.caption = CreateLabel(dialog,
        "Mehrere deiner Charaktere beherrschen das Rezept.",
        { muted = true, width = 324, height = 16 })
    dialog.caption:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -42)
    dialog.candidateButtons = {}
    for index = 1, 4 do
        local button = CreateButton(dialog, "", 200, 24, function()
            local chosen = dialog.candidateButtons[index].crafterName
            if chosen then
                dialog.selectedCrafter = chosen
                for _, sibling in ipairs(dialog.candidateButtons) do
                    sibling:SetActive(sibling.crafterName == chosen)
                end
            end
        end)
        button:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -64 - ((index - 1) * 26))
        button:Hide()
        dialog.candidateButtons[index] = button
    end
    dialog.submit = CreateButton(dialog, "Annehmen", 120, 30, function()
        local ok, message = GC.Orders:Accept(dialog.orderID, dialog.selectedCrafter)
        GC.UI:SetOrdersStatus(message, ok)
        if ok then
            dialog:Hide()
        end
    end, "PRIMARY")
    dialog.submit:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 16, 14)
end

function GC.UI:OpenOrderAcceptDialog(orderID, candidates)
    local page = self.pages.WORKSHOP
    local dialog = page and page.orderAcceptDialog
    if not dialog then
        return
    end
    dialog.orderID = orderID
    dialog.selectedCrafter = candidates[1]
    for index, button in ipairs(dialog.candidateButtons) do
        local name = candidates[index]
        button.crafterName = name
        button:SetText(name and GC.Util.PlayerShortName(name) or "")
        button:SetShown(name ~= nil)
        button:SetActive(name == dialog.selectedCrafter)
    end
    dialog:Show()
end

-- === Kompakt-Tracker ========================================================
-- Frei verschiebbarer Mini-Rahmen nach dem Muster des Werbebalkens: bis zu
-- drei "du bist dran"-Zeilen, Klick öffnet die Werkstatt am Auftragsboard.
-- Er zeigt sich nur, wenn es etwas zu tun gibt (Owner-Entscheidung: Stufe 1).

function GC.UI:CreateOrderTracker()
    if self.orderTracker then
        return self.orderTracker
    end
    local tracker = CreatePanel(UIParent, THEME.window, THEME.accent, "GuildCopilotOrderTracker")
    tracker:SetSize(344, 118)
    local settings = GC.DB:GetSettings().orderTracker
    tracker:SetPoint("CENTER", UIParent, "CENTER", tonumber(settings.x) or 0, tonumber(settings.y) or -300)
    tracker:SetClampedToScreen(true)
    tracker:SetMovable(true)
    tracker:EnableMouse(true)
    tracker:RegisterForDrag("LeftButton")
    tracker:SetScript("OnDragStart", tracker.StartMoving)
    tracker:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, _, x, y = frame:GetPoint()
        if point then
            GC.DB:GetSettings().orderTracker.x = math.floor(tonumber(x) or 0)
            GC.DB:GetSettings().orderTracker.y = math.floor(tonumber(y) or 0)
        end
    end)
    tracker:SetFrameStrata("MEDIUM")
    tracker:Hide()

    tracker.title = CreateLabel(tracker, "Gildenaufträge – du bist dran",
        { font = "GameFontNormalSmall" })
    tracker.title:SetPoint("TOPLEFT", tracker, "TOPLEFT", 12, -9)
    tracker.close = CreateButton(tracker, "×", 20, 20, function()
        GC.DB:GetSettings().orderTracker.hidden = true
        GC.UI:RefreshOrderTracker()
    end)
    tracker.close:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -8, -7)

    -- Zwei Zeilen je Auftrag: Rezept oben, Aufgabe gedämpft darunter. In
    -- einer Zeile wurde die Aufgabe abgeschnitten ("Materialien an … li…").
    tracker.rows = {}
    for index = 1, 3 do
        local row = CreateButton(tracker, "", 320, 40, function()
            GC.UI:CreateMainFrame()
            GC.UI.frame:Show()
            GC.UI:ShowPage("WORKSHOP")
            GC.UI:SetWorkshopView("ORDERS")
        end)
        row:SetPoint("TOPLEFT", tracker, "TOPLEFT", 12, -28 - ((index - 1) * 44))
        row.label:ClearAllPoints()
        row.label:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -5)
        row.label:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        row.label:SetJustifyH("LEFT")
        if row.label.SetWordWrap then
            row.label:SetWordWrap(false)
        end
        if row.label.SetMaxLines then
            row.label:SetMaxLines(1)
        end
        row.action = CreateLabel(row, "", {
            muted = true,
            font = "GameFontNormalSmall",
            width = 304,
            height = 14,
        })
        row.action:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -22)
        if row.action.SetWordWrap then
            row.action:SetWordWrap(false)
        end
        if row.action.SetMaxLines then
            row.action:SetMaxLines(1)
        end
        row:Hide()
        tracker.rows[index] = row
    end

    self.orderTracker = tracker
    return tracker
end

function GC.UI:RefreshOrderTracker()
    local settings = GC.DB:GetSettings().orderTracker
    local rows = {}
    if GC.Orders then
        for _, boardRow in ipairs(GC.Orders:GetBoard().mine) do
            if boardRow.yourTurn then
                rows[#rows + 1] = boardRow
            end
        end
    end
    if settings.hidden or #rows == 0 then
        if self.orderTracker then
            self.orderTracker:Hide()
        end
        return
    end

    local tracker = self:CreateOrderTracker()
    local visible = 0
    for index, row in ipairs(tracker.rows) do
        local boardRow = rows[index]
        if boardRow then
            local order = boardRow.order
            row:SetText((order.recipeName or "?") .. " ×" .. (order.quantity or 1))
            row.action:SetText(boardRow.action or "")
            row:Show()
            visible = visible + 1
        else
            row:Hide()
        end
    end
    if #rows > #tracker.rows then
        tracker.title:SetText("Gildenaufträge – du bist dran (" .. #rows .. ")")
    else
        tracker.title:SetText("Gildenaufträge – du bist dran")
    end
    -- Der Rahmen ist so hoch wie sein Inhalt: Titelzeile plus die sichtbaren
    -- Zeilen. Drei leere Plätze vorzuhalten sah nach kaputtem Fenster aus.
    tracker:SetHeight(34 + (visible * 44) + 4)
    tracker:Show()
end

function GC.UI:ToggleOrderTracker()
    local settings = GC.DB:GetSettings().orderTracker
    settings.hidden = not settings.hidden
    self:RefreshOrderTracker()
    self:RefreshOrdersBoard()
end

-- === Bildschirmmeldung ======================================================
-- Eine eigene, gut lesbare Raidwarnung für neue machbare Gildenaufträge -
-- ohne Hintergrundkasten, mit dicker Kontur und Schatten für den Kontrast.
-- Sie steht drei Sekunden und verblasst dann; kommen mehrere Meldungen,
-- rückt Älteres wie beim Scrolling Combat Text nach oben und verblasst dort.
-- Der Kasten erscheint nur im Positionier-Modus ("Meldung testen" in den
-- Einstellungen), damit sich der Anker mit der Maus greifen lässt.
local BANNER_FADE_SECONDS = 1.5
local BANNER_LINES = 3
local BANNER_LINE_HEIGHT = 34

-- Die Standdauer kommt aus den Einstellungen (1 bis 30 Sekunden). Gelesen
-- wird sie je Tick - ein Tabellenzugriff, und Änderungen greifen sofort.
local function BannerHoldSeconds()
    local value = tonumber(GC.DB:GetSettings().orderBanner.holdSeconds) or 3
    return math.max(1, math.min(30, value))
end

function GC.UI:CreateOrderBanner()
    if self.orderBanner then
        return self.orderBanner
    end
    local settings = GC.DB:GetSettings().orderBanner
    local banner = CreatePanel(UIParent, THEME.window, THEME.accent, "GuildCopilotOrderBanner")
    banner:SetSize(640, BANNER_LINES * BANNER_LINE_HEIGHT)
    banner:SetPoint("CENTER", UIParent, "CENTER",
        tonumber(settings.x) or 0, tonumber(settings.y) or 200)
    banner:SetFrameStrata("HIGH")
    banner:SetClampedToScreen(true)
    banner:SetMovable(true)
    banner:RegisterForDrag("LeftButton")
    banner:SetScript("OnDragStart", banner.StartMoving)
    banner:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, _, x, y = frame:GetPoint()
        if point then
            GC.DB:GetSettings().orderBanner.x = math.floor(tonumber(x) or 0)
            GC.DB:GetSettings().orderBanner.y = math.floor(tonumber(y) or 0)
        end
    end)

    function banner:SetPositioning(active)
        self.positioning = active == true
        self:EnableMouse(self.positioning)
        if self.positioning then
            self:SetBackdropColor(THEME.window[1], THEME.window[2], THEME.window[3], 0.85)
            self:SetBackdropBorderColor(THEME.accent[1], THEME.accent[2], THEME.accent[3], 1)
        else
            self:SetBackdropColor(0, 0, 0, 0)
            self:SetBackdropBorderColor(0, 0, 0, 0)
        end
    end
    banner:SetPositioning(false)

    banner.lines = {}
    for index = 1, BANNER_LINES do
        local line = CreateLabel(banner, "", {
            font = "GameFontNormalHuge",
            align = "CENTER",
            width = 640,
            height = BANNER_LINE_HEIGHT,
        })
        -- Neues erscheint unten am Anker, Älteres rückt nach oben.
        line:SetPoint("BOTTOM", banner, "BOTTOM", 0, (index - 1) * BANNER_LINE_HEIGHT)
        SetTextColor(line, THEME.accent)
        if line.GetFont and line.SetFont then
            local fontPath, fontSize = line:GetFont()
            if fontPath then
                line:SetFont(fontPath, fontSize or 20, "THICKOUTLINE")
            end
        end
        if line.SetShadowOffset then
            line:SetShadowOffset(2, -2)
        end
        if line.SetShadowColor then
            line:SetShadowColor(0, 0, 0, 0.9)
        end
        line.age = nil
        line:Hide()
        banner.lines[index] = line
    end

    -- Die dünnen Linien über und unter der Meldung - die klassische
    -- Raidwarnungs-Optik, nur ohne Kasten. Sie verblassen mit der Meldung.
    banner.rules = {}
    for index, offset in ipairs({ 0, BANNER_LINE_HEIGHT }) do
        local rule = banner:CreateTexture(nil, "ARTWORK")
        rule:SetHeight(1)
        rule:SetPoint("BOTTOMLEFT", banner, "BOTTOMLEFT", 40, offset)
        rule:SetPoint("BOTTOMRIGHT", banner, "BOTTOMRIGHT", -40, offset)
        if rule.SetColorTexture then
            rule:SetColorTexture(THEME.accent[1], THEME.accent[2], THEME.accent[3], 0.9)
        end
        rule:Hide()
        banner.rules[index] = rule
    end

    banner:SetScript("OnUpdate", function(frame, elapsed)
        elapsed = tonumber(elapsed) or 0
        local hold = BannerHoldSeconds()
        local anyActive = false
        for _, line in ipairs(frame.lines) do
            if line.age then
                line.age = line.age + elapsed
                if line.age >= hold + BANNER_FADE_SECONDS then
                    line.age = nil
                    line:Hide()
                elseif line.age > hold then
                    if line.SetAlpha then
                        line:SetAlpha(math.max(0,
                            1 - ((line.age - hold) / BANNER_FADE_SECONDS)))
                    end
                    anyActive = true
                else
                    if line.SetAlpha then
                        line:SetAlpha(1)
                    end
                    anyActive = true
                end
            end
        end
        -- Die Linien folgen der jüngsten Zeile: Sie ist immer die letzte, die
        -- verblasst, also tragen die Linien schlicht deren Deckkraft.
        local newest = frame.lines[1]
        local ruleAlpha = 0
        if newest.age then
            ruleAlpha = newest.age <= hold and 1
                or math.max(0, 1 - ((newest.age - hold) / BANNER_FADE_SECONDS))
        end
        for _, rule in ipairs(frame.rules) do
            rule:SetShown(ruleAlpha > 0)
            if rule.SetAlpha then
                rule:SetAlpha(ruleAlpha)
            end
        end
        if not anyActive then
            frame:SetPositioning(false)
            frame:Hide()
        end
    end)

    banner:Hide()
    self.orderBanner = banner
    return banner
end

function GC.UI:ShowOrderBanner(text, positioning)
    if GC.DB:GetSettings().orderBanner.enabled == false and not positioning then
        return
    end
    local banner = self:CreateOrderBanner()
    local lines = banner.lines
    text = text or ""

    -- Gleiche Meldung, solange die alte noch steht: hochzählen statt
    -- stapeln. "Neuer Gildenauftrag ×3" sagt mehr als drei identische Zeilen.
    if lines[1].age and lines[1].baseText == text then
        lines[1].repeatCount = (lines[1].repeatCount or 1) + 1
        lines[1]:SetText(text .. "  ×" .. lines[1].repeatCount)
        lines[1].age = 0
        if lines[1].SetAlpha then
            lines[1]:SetAlpha(1)
        end
        banner:Show()
        return
    end

    -- Ältere Zeilen eine Position nach oben schieben, die neue kommt unten an.
    for index = #lines, 2, -1 do
        local line = lines[index]
        local below = lines[index - 1]
        line:SetText(below:GetText() or "")
        line.age = below.age
        line.baseText = below.baseText
        line.repeatCount = below.repeatCount
        line:SetShown(line.age ~= nil)
    end
    lines[1]:SetText(text)
    lines[1].baseText = text
    lines[1].repeatCount = 1
    lines[1].age = 0
    if lines[1].SetAlpha then
        lines[1]:SetAlpha(1)
    end
    lines[1]:Show()
    if positioning then
        banner:SetPositioning(true)
    end
    banner:Show()
end

function GC.UI:BuildRecruitmentPage()
    local page = self.pages.RECRUITMENT
    CreatePageTitle(page, "Klassen & Specs", "Klassen öffnen, Bedarf auswählen und die Reihenfolge rechts nach Priorität sortieren.")

    local listCard = CreateCard(page)
    listCard:SetSize(486, 490)
    listCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)

    local scroll = CreateModernScrollFrame(listCard)
    scroll:SetPoint("TOPLEFT", listCard, "TOPLEFT", 12, -12)
    scroll:SetPoint("BOTTOMRIGHT", listCard, "BOTTOMRIGHT", -18, 12)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(432)
    content:SetHeight(456)
    scroll:SetScrollChild(content)
    page.classContent = content
    page.classRows = {}

    for _, classFile in ipairs(GC.ClassOrder) do
        local currentClass = classFile
        local classInfo = GC.Classes[classFile]
        local row = CreateFrame("Frame", nil, content)
        row:SetWidth(428)
        row.header = CreateButton(row, "", 428, 42, function()
            if page.expandedClass == currentClass then
                page.expandedClass = nil
            else
                page.expandedClass = currentClass
            end
            GC.UI:RefreshRecruitment()
        end)
        row.header:SetPoint("TOPLEFT")
        row.header.label:ClearAllPoints()
        row.header.label:SetPoint("LEFT", row.header, "LEFT", 52, 0)
        row.header.label:SetJustifyH("LEFT")
        row.header.icon = row.header:CreateTexture(nil, "ARTWORK")
        row.header.icon:SetSize(28, 28)
        row.header.icon:SetPoint("LEFT", row.header, "LEFT", 12, 0)
        SetClassIcon(row.header.icon, classFile)
        row.header.arrow = CreateLabel(row.header, "+", { title = true, align = "CENTER" })
        row.header.arrow:SetPoint("RIGHT", row.header, "RIGHT", -14, 1)
        row.header.count = CreateLabel(row.header, "", { muted = true, align = "RIGHT", width = 150 })
        row.header.count:SetPoint("RIGHT", row.header, "RIGHT", -42, 0)

        row.details = CreatePanel(row, THEME.input)
        row.details:SetPoint("TOPLEFT", row.header, "BOTTOMLEFT", 0, -4)
        row.details:SetSize(428, 88)

        row.classChoice = CreateButton(row.details, "Ganze Klasse", 116, 30, function()
            GC.Recruitment:SetClass(currentClass, not GC.Recruitment:IsClassSelected(currentClass))
            GC.UI:RefreshRecruitment()
        end)
        row.classChoice:SetPoint("TOPLEFT", row.details, "TOPLEFT", 12, -12)

        row.specButtons = {}
        for index, spec in ipairs(classInfo.specs) do
            local specKey = spec.key
            local button = CreateButton(row.details, spec.name, 126, 30, function()
                GC.Recruitment:SetSpec(specKey, not GC.Recruitment:IsSpecSelected(specKey))
                GC.UI:RefreshRecruitment()
            end)
            button:SetPoint("BOTTOMLEFT", row.details, "BOTTOMLEFT", 12 + ((index - 1) * 134), 10)
            row.specButtons[spec.key] = button
        end
        page.classRows[classFile] = row
    end

    local summaryCard = CreateCard(page, "Deine Suche")
    summaryCard:SetSize(270, 490)
    summaryCard:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, -66)
    page.selectionCount = CreateLabel(summaryCard, "0 AUSGEWÄHLT", { muted = true })
    page.selectionCount:SetPoint("TOPLEFT", summaryCard, "TOPLEFT", 18, -49)
    page.priorityRows = {}
    for index = 1, 9 do
        local rowIndex = index
        local priorityRow = CreatePanel(summaryCard, THEME.input)
        priorityRow:SetSize(234, 31)
        priorityRow:SetPoint("TOPLEFT", summaryCard, "TOPLEFT", 18, -72 - ((index - 1) * 34))
        priorityRow.name = CreateLabel(priorityRow, "", { width = 112 })
        priorityRow.name:SetPoint("LEFT", priorityRow, "LEFT", 8, 0)
        priorityRow.priority = CreateButton(priorityRow, "Prio", 48, 25, function()
            local classFile = page.priorityRows[rowIndex].classFile
            if classFile then
                GC.Recruitment:SetPriority(classFile, not GC.Recruitment:IsHighPriority(classFile))
                GC.UI:RefreshRecruitment()
            end
        end)
        priorityRow.priority:SetPoint("LEFT", priorityRow, "LEFT", 116, 0)
        priorityRow.up = CreateButton(priorityRow, "^", 27, 25, function()
            local classFile = page.priorityRows[rowIndex].classFile
            if classFile then
                GC.Recruitment:MoveSelectedClass(classFile, -1)
                GC.UI:RefreshRecruitment()
            end
        end)
        priorityRow.up:SetPoint("LEFT", priorityRow.priority, "RIGHT", 4, 0)
        priorityRow.down = CreateButton(priorityRow, "v", 27, 25, function()
            local classFile = page.priorityRows[rowIndex].classFile
            if classFile then
                GC.Recruitment:MoveSelectedClass(classFile, 1)
                GC.UI:RefreshRecruitment()
            end
        end)
        priorityRow.down:SetPoint("LEFT", priorityRow.up, "RIGHT", 4, 0)
        page.priorityRows[index] = priorityRow
    end

    page.emptySelectionText = CreateLabel(summaryCard,
        "Noch nichts gewählt.\n\nLinks eine Klasse öffnen und ganze Klasse oder Specs auswählen.",
        { muted = true, width = 234, height = 110, vertical = "TOP" })
    page.emptySelectionText:SetPoint("TOPLEFT", summaryCard, "TOPLEFT", 18, -77)

    local clear = CreateButton(summaryCard, "Auswahl leeren", 234, 34, function()
        GC.Recruitment:Clear()
        GC.UI:RefreshRecruitment()
    end)
    clear:SetPoint("BOTTOMLEFT", summaryCard, "BOTTOMLEFT", 18, 64)

    local continue = CreateButton(summaryCard, "Werbetext erstellen  >", 234, 38, function()
        local guildData = GC.DB:GetGuild()
        guildData.recruitment.adText = GC.Recruitment:GenerateAdvertisement()
        GC.UI:ShowPage("POST")
    end, "PRIMARY")
    continue:SetPoint("BOTTOMLEFT", summaryCard, "BOTTOMLEFT", 18, 16)
end

function GC.UI:RefreshRecruitment()
    local page = self.pages.RECRUITMENT
    if not page then
        return
    end

    local y = 0
    for _, classFile in ipairs(GC.ClassOrder) do
        local row = page.classRows[classFile]
        local classInfo = GC.Classes[classFile]
        local expanded = page.expandedClass == classFile
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", page.classContent, "TOPLEFT", 0, -y)
        row:SetHeight(expanded and 136 or 46)
        row.details:SetShown(expanded)
        row.header:SetText(classInfo.plural)
        row.header:SetActive(expanded)
        row.header.arrow:SetText(expanded and "-" or "+")
        row.classChoice:SetActive(GC.Recruitment:IsClassSelected(classFile))
        local selectedSpecs = 0
        for _, spec in ipairs(classInfo.specs) do
            local selected = GC.Recruitment:IsSpecSelected(spec.key)
            row.specButtons[spec.key]:SetActive(selected)
            if selected then
                selectedSpecs = selectedSpecs + 1
            end
        end
        if GC.Recruitment:IsClassSelected(classFile) then
            row.header.count:SetText("ganze Klasse")
        elseif selectedSpecs > 0 then
            row.header.count:SetText(selectedSpecs .. " Specs")
        else
            row.header.count:SetText("")
        end
        local red, green, blue = ClassColor(classFile)
        row.header.label:SetTextColor(red, green, blue)
        y = y + (expanded and 142 or 48)
    end
    page.classContent:SetHeight(math.max(456, y))

    local orderedClasses = GC.Recruitment:GetClassOrder()
    local selectedClasses = {}
    local selectedClassCount = 0
    for _, classFile in ipairs(orderedClasses) do
        local label = GC.Recruitment:GetClassSelectionLabel(classFile, true)
        if label then
            selectedClassCount = selectedClassCount + 1
            selectedClasses[#selectedClasses + 1] = classFile
        end
    end
    page.selectionCount:SetText(selectedClassCount .. " KLASSEN AUSGEWÄHLT")
    page.emptySelectionText:SetShown(selectedClassCount == 0)
    for index, priorityRow in ipairs(page.priorityRows) do
        local classFile = selectedClasses[index]
        priorityRow:SetShown(classFile ~= nil)
        priorityRow.classFile = classFile
        if classFile then
            local classInfo = GC.Classes[classFile]
            local red, green, blue = ClassColor(classFile)
            priorityRow.name:SetText(classInfo.plural)
            priorityRow.name:SetTextColor(red, green, blue)
            local highPriority = GC.Recruitment:IsHighPriority(classFile)
            priorityRow.priority:SetText(highPriority and "HOCH" or "Prio")
            priorityRow.priority:SetActive(highPriority)
            if index == 1 then
                priorityRow.up:Disable()
            else
                priorityRow.up:Enable()
            end
            if index == selectedClassCount then
                priorityRow.down:Disable()
            else
                priorityRow.down:Enable()
            end
        end
    end
end

function GC.UI:BuildPostPage()
    local page = self.pages.POST
    CreatePageTitle(page, "Werbung posten", "Text prüfen, bestätigen und anschließend mit einem echten Klick in die ausgewählten Kanäle senden.")

    local editorCard = CreateCard(page, "Werbetext")
    editorCard:SetSize(776, 246)
    editorCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)
    page.adEdit = CreateTextArea(editorCard, 740, 132, 500)
    page.adEdit.container:SetPoint("TOPLEFT", editorCard, "TOPLEFT", 18, -48)
    page.adEdit:SetScript("OnTextChanged", function(edit)
        GC.DB:GetGuild().recruitment.adText = edit:GetText()
        if page.searchButton then
            page.searchButton:Disable()
        end
        GC.UI:RefreshPostCounter()
    end)

    local markerLabel = CreateLabel(editorCard, "Raid-Symbol", { muted = true })
    markerLabel:SetPoint("TOPLEFT", editorCard, "TOPLEFT", 386, -19)
    page.raidMarkerButtons = {}
    for markerIndex = 1, 8 do
        local selectedMarker = markerIndex
        local markerButton = CreateRaidMarkerButton(editorCard, markerIndex, function()
            local recruitment = GC.DB:GetGuild().recruitment
            recruitment.raidMarker = selectedMarker
            recruitment.adText = GC.Recruitment:GenerateAdvertisement()
            recruitment.confirmedText = nil
            page.adEdit:SetText(recruitment.adText)
            page.postResult:SetText("Raid-Symbol geändert. Bitte den Text erneut bestätigen.")
            SetTextColor(page.postResult, THEME.warning)
            GC.UI:RefreshPost()
        end)
        markerButton:SetPoint("TOPLEFT", editorCard, "TOPLEFT", 475 + ((markerIndex - 1) * 34), -13)
        page.raidMarkerButtons[markerIndex] = markerButton
    end
    page.byteCounter = CreateLabel(editorCard, "", { muted = true, align = "RIGHT", width = 150 })
    page.byteCounter:SetPoint("BOTTOMRIGHT", editorCard, "BOTTOMRIGHT", -18, 14)

    local regenerate = CreateButton(editorCard, "Neu generieren", 142, 32, function()
        page.adEdit:SetText(GC.Recruitment:GenerateAdvertisement())
    end)
    regenerate:SetPoint("BOTTOMLEFT", editorCard, "BOTTOMLEFT", 18, 12)
    page.confirmAdButton = CreateButton(editorCard, "Text bestätigen", 152, 32, function()
        local text = GC.Util.SafeChatText(page.adEdit:GetText())
        page.adEdit:SetText(text)
        if text == "" then
            GC.DB:GetGuild().recruitment.confirmedText = nil
            page.postResult:SetText("Ein leerer Werbetext kann nicht bestätigt werden.")
            SetTextColor(page.postResult, THEME.danger)
            GC.UI:RefreshPost()
            return
        end
        GC.DB:GetGuild().recruitment.confirmedText = text
        page.postResult:SetText("Werbetext bestätigt und bereit.")
        SetTextColor(page.postResult, THEME.success)
        GC.UI:RefreshPost()
    end, "PRIMARY")
    page.confirmAdButton:SetPoint("LEFT", regenerate, "RIGHT", 8, 0)

    local channelCard = CreateCard(page, "Kanäle")
    channelCard:SetSize(776, 155)
    channelCard:SetPoint("TOPLEFT", editorCard, "BOTTOMLEFT", 0, -12)
    page.channelChecks = {}
    for index, kind in ipairs({ "RECRUITMENT", "LFG", "TRADE", "GENERAL" }) do
        local channelKind = kind
        local toggle = CreateToggle(channelCard, GC.ChannelKinds[kind].label, function(enabled)
            GC.DB:GetSettings().channels[channelKind] = enabled
            GC.UI:RefreshPostStatus()
        end)
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        toggle:SetPoint("TOPLEFT", channelCard, "TOPLEFT", 18 + (column * 270), -49 - (row * 38))
        page.channelChecks[kind] = toggle
    end
    page.channelStatus = CreateLabel(channelCard, "", { muted = true, width = 220, height = 82, vertical = "TOP" })
    page.channelStatus:SetPoint("TOPRIGHT", channelCard, "TOPRIGHT", -18, -49)

    page.searchButton = CreateButton(page, "Suche starten", 210, 44, function()
        local success, message = GC.Chat:StartSearch(page.adEdit:GetText())
        page.postResult:SetText(message or "")
        SetTextColor(page.postResult, success and THEME.success or THEME.danger)
        GC.UI:RefreshPost()
    end, "PRIMARY")
    -- Die Rueckmeldung stand rechts neben dem Werbebalken-Knopf und wurde
    -- uebersehen - wer ohne bestaetigten Text auf "Suche starten" klickte,
    -- bekam scheinbar keinen Hinweis. Jetzt steht sie in voller Breite direkt
    -- unter dem Knopf, auf den man gerade geklickt hat.
    page.searchButton:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 26)
    page.postBarToggle = CreateButton(page, "Werbebalken", 150, 44, function()
        GC.UI:TogglePostBar()
        GC.UI:RefreshPost()
    end)
    page.postBarToggle:SetPoint("LEFT", page.searchButton, "RIGHT", 12, 0)

    page.postResult = CreateLabel(page, "", { width = 776 })
    page.postResult:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 4)

    page:SetScript("OnUpdate", function(_, elapsed)
        page.elapsed = (page.elapsed or 0) + elapsed
        if page.elapsed >= 0.5 then
            page.elapsed = 0
            GC.UI:RefreshPostStatus()
        end
    end)
end

function GC.UI:RefreshPostCounter()
    local page = self.pages.POST
    if not page then
        return
    end
    local bytes = #(page.adEdit:GetText() or "")
    page.byteCounter:SetText(bytes .. "/" .. GC.Constants.MAX_CHAT_BYTES .. " Bytes")
    SetTextColor(page.byteCounter, bytes > GC.Constants.MAX_CHAT_BYTES and THEME.danger or THEME.muted)
end

function GC.UI:RefreshPostStatus()
    local page = self.pages.POST
    if not page or not page:IsShown() then
        return
    end
    local statuses = {}
    for _, kind in ipairs({ "RECRUITMENT", "LFG", "TRADE", "GENERAL" }) do
        if GC.DB:GetSettings().channels[kind] then
            local channelID = GC.Chat:FindChannel(kind)
            local status = channelID and "bereit" or "nicht beigetreten"
            local remaining = GC.Chat:GetRemainingCooldown(kind)
            if remaining > 0 then
                status = math.ceil(remaining) .. "s Cooldown"
            end
            statuses[#statuses + 1] = GC.ChannelKinds[kind].label .. ": " .. status
        end
    end
    page.channelStatus:SetText(#statuses > 0 and table.concat(statuses, "\n") or "Keine Kanäle ausgewählt.")
end

function GC.UI:RefreshPost()
    local page = self.pages.POST
    if not page then
        return
    end
    if page.postBarToggle then
        local visible = GC.DB:GetSettings().postBar.hidden == false
        page.postBarToggle:SetActive(visible)
        page.postBarToggle:SetText(visible and "Balken aus" or "Werbebalken")
    end
    local recruitment = GC.DB:GetGuild().recruitment
    if not recruitment.adText or recruitment.adText == "" then
        recruitment.adText = GC.Recruitment:GenerateAdvertisement()
    end
    if not page.adEdit:HasFocus() and page.adEdit:GetText() ~= recruitment.adText then
        page.adEdit:SetText(recruitment.adText)
    end
    for kind, toggle in pairs(page.channelChecks) do
        SetToggle(toggle, GC.DB:GetSettings().channels[kind])
    end
    local marker = math.floor(tonumber(recruitment.raidMarker) or 8)
    for markerIndex, markerButton in ipairs(page.raidMarkerButtons) do
        markerButton:SetActive(markerIndex == marker)
    end
    local isConfirmed = recruitment.confirmedText == page.adEdit:GetText()
        and GC.Util.Trim(recruitment.confirmedText or "") ~= ""
    if isConfirmed then
        page.searchButton:Enable()
    else
        page.searchButton:Disable()
    end
    page.searchButton:SetActive(isConfirmed)
    self:RefreshPostCounter()
    self:RefreshPostStatus()
end

function GC.UI:BuildInboxPage()
    local page = self.pages.INBOX
    CreatePageTitle(page, "Postfach", "Whispers und erkannte „Suche Gilde“-Nachrichten werden hier gesammelt.")

    local scroll = CreateModernScrollFrame(page)
    scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -58)
    scroll:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -4, 0)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(752)
    content:SetHeight(1030)
    scroll:SetScrollChild(content)
    page.inboxScroll = scroll

    local leadCard = CreateCard(content, "Interessenten")
    leadCard:SetSize(224, 554)
    leadCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    page.leadButtons = {}
    page.leadDeleteButtons = {}
    for index = 1, 9 do
        local leadIndex = index
        local button = CreateButton(leadCard, "", 148, 38, function()
            GC.UI.selectedLead = leadIndex
            GC.UI:RefreshInbox()
        end)
        button:SetPoint("TOPLEFT", leadCard, "TOPLEFT", 18, -48 - ((index - 1) * 43))
        button.label:SetJustifyH("LEFT")
        button.label:ClearAllPoints()
        button.label:SetPoint("LEFT", button, "LEFT", 12, 0)
        page.leadButtons[index] = button
        local remove = CreateButton(leadCard, "×", 34, 38, function()
            local wasSelected = GC.UI.selectedLead == leadIndex
            if GC.Chat:RemoveLead(leadIndex) then
                local inbox = GC.DB:GetGuild().inbox
                if GC.UI.selectedLead > leadIndex then
                    GC.UI.selectedLead = GC.UI.selectedLead - 1
                elseif wasSelected then
                    GC.UI.selectedLead = math.max(1, math.min(leadIndex, #inbox))
                    page.replyEdit:SetText("")
                end
                GC.UI:RefreshInbox()
            end
        end)
        remove:SetPoint("LEFT", button, "RIGHT", 6, 0)
        remove.label:SetTextColor(THEME.danger[1], THEME.danger[2], THEME.danger[3], 1)
        page.leadDeleteButtons[index] = remove
    end
    page.clearInboxButton = CreateButton(leadCard, "Alle löschen", 188, 30, function()
        if not page.confirmClearInbox then
            page.confirmClearInbox = true
            page.clearInboxButton:SetText("Löschen bestätigen")
            return
        end
        if GC.Chat:ClearInbox() then
            GC.UI.selectedLead = 1
            page.replyEdit:SetText("")
            page.replyResult:SetText("Postfach vollständig geleert.")
            SetTextColor(page.replyResult, THEME.muted)
        end
        page.confirmClearInbox = false
        page.clearInboxButton:SetText("Alle löschen")
        GC.UI:RefreshInbox()
    end)
    page.clearInboxButton:SetPoint("BOTTOMLEFT", leadCard, "BOTTOMLEFT", 18, 14)

    local detailCard = CreateCard(content, "Unterhaltung")
    detailCard:SetSize(528, 554)
    detailCard:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    page.leadTitle = CreateLabel(detailCard, "Kein Bewerber ausgewählt", { title = true })
    page.leadTitle:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -51)
    page.lastMessage = CreateLabel(detailCard, "", { width = 504, height = 52, vertical = "TOP" })
    page.lastMessage:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -86)

    -- Zwei fertige Profil-Links zum Nachschlagen des Interessenten. WoW kann
    -- keinen Browser oeffnen und nichts in die Zwischenablage legen, deshalb
    -- sind es Textfelder: hineinklicken markiert den ganzen Link, Strg+C
    -- kopiert ihn. Tippen stellt den Link wieder her, damit niemand versehentlich
    -- einen halben Link kopiert.
    page.leadLinkEdits = {}
    local linkDefinitions = {
        { key = "armory", label = "Armory", y = -142 },
        { key = "logs", label = "Logs", y = -170 },
    }
    for _, definition in ipairs(linkDefinitions) do
        local label = CreateLabel(detailCard, definition.label, { muted = true, width = 62 })
        label:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, definition.y)
        local edit = CreateEdit(detailCard, 424, 24)
        edit.container:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 86, definition.y + 2)
        edit:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)
        edit:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                self:SetText(self.linkValue or "")
                self:HighlightText()
            end
        end)
        edit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)
        page.leadLinkEdits[definition.key] = edit
    end
    page.leadLinkNotice = CreateLabel(detailCard, "", { muted = true, width = 492, height = 14 })
    page.leadLinkNotice:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -196)

    local previewLabel = CreateLabel(detailCard, "Antwortvorschau  •  editierbar", { muted = true })
    previewLabel:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -209)

    local markerLabel = CreateLabel(detailCard, "Symbole", { muted = true })
    markerLabel:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -238)
    page.replyMarkerOff = CreateButton(detailCard, "Aus", 45, 26, function()
        local recruitment = GC.DB:GetGuild().recruitment
        recruitment.replyMarker = 0
        page.replyEdit:SetText(GC.Recruitment:DecorateReply(page.replyEdit:GetText(), 0))
        GC.UI:RefreshInbox()
    end)
    page.replyMarkerOff:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 92, -229)
    page.replyMarkerButtons = {}
    for markerIndex = 1, 8 do
        local selectedMarker = markerIndex
        local markerButton = CreateRaidMarkerButton(detailCard, markerIndex, function()
            local recruitment = GC.DB:GetGuild().recruitment
            recruitment.replyMarker = selectedMarker
            page.replyEdit:SetText(GC.Recruitment:DecorateReply(page.replyEdit:GetText(), selectedMarker))
            GC.UI:RefreshInbox()
        end)
        markerButton:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 146 + ((markerIndex - 1) * 30), -229)
        page.replyMarkerButtons[markerIndex] = markerButton
    end

    page.replyEdit = CreateTextArea(detailCard, 504, 104, 500)
    page.replyEdit.container:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -263)
    page.replyByteCounter = CreateLabel(detailCard, "0/255 Bytes", { muted = true, align = "RIGHT", width = 110 })
    page.replyByteCounter:SetPoint("TOPRIGHT", detailCard, "TOPRIGHT", -18, -374)
    page.replyEdit:SetScript("OnTextChanged", function(edit)
        local bytes = #(edit:GetText() or "")
        page.replyByteCounter:SetText(bytes .. "/" .. GC.Constants.MAX_CHAT_BYTES .. " Bytes")
        SetTextColor(page.replyByteCounter, bytes > GC.Constants.MAX_CHAT_BYTES and THEME.danger or THEME.muted)
    end)

    local thanks = CreateButton(detailCard, "Danke", 105, 30, function()
        local lead = GC.DB:GetGuild().inbox[GC.UI.selectedLead]
        if lead then
            page.replyEdit:SetText(GC.Recruitment:GenerateReply("THANKS", lead.name))
        end
    end)
    thanks:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -386)
    local info = CreateButton(detailCard, "Gildeninfos", 115, 30, function()
        local lead = GC.DB:GetGuild().inbox[GC.UI.selectedLead]
        if lead then
            page.replyEdit:SetText(GC.Recruitment:GenerateReply("INFO", lead.name))
        end
    end)
    info:SetPoint("LEFT", thanks, "RIGHT", 8, 0)
    local discord = CreateButton(detailCard, "Discord", 105, 30, function()
        local lead = GC.DB:GetGuild().inbox[GC.UI.selectedLead]
        if lead then
            page.replyEdit:SetText(GC.Recruitment:GenerateReply("DISCORD", lead.name))
        end
    end)
    discord:SetPoint("LEFT", info, "RIGHT", 8, 0)

    page.replyButton = CreateButton(detailCard, "Antworten", 248, 38, function()
        local lead = GC.DB:GetGuild().inbox[GC.UI.selectedLead]
        if lead and GC.Chat:SendReply(lead.name, page.replyEdit:GetText()) then
            page.replyResult:SetText("Antwort an " .. lead.name .. " gesendet.")
            SetTextColor(page.replyResult, THEME.success)
        else
            page.replyResult:SetText("Bitte Interessent und Antwort auswählen.")
            SetTextColor(page.replyResult, THEME.danger)
        end
        GC.UI:RefreshInbox()
    end, "PRIMARY")
    page.replyButton:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -430)

    page.inviteButton = CreateButton(detailCard, "In Gilde einladen", 248, 38, function()
        local lead = GC.DB:GetGuild().inbox[GC.UI.selectedLead]
        if lead then
            GC.Chat:Invite(lead.name)
            page.replyResult:SetText("Einladung an " .. lead.name .. " ausgelöst.")
        end
    end)
    page.inviteButton:SetPoint("LEFT", page.replyButton, "RIGHT", 8, 0)
    page.replyResult = CreateLabel(detailCard, "", { width = 492, height = 20, vertical = "TOP" })
    page.replyResult:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -476)

    -- Wer immer wieder schreibt, ohne dass etwas daraus wird, laesst sich
    -- ausblenden. Befristet oder dauerhaft; zuruecknehmen geht in der Liste
    -- unter den Vorlagen.
    local function FilterSelectedLead(days)
        local lead = GC.DB:GetGuild().inbox[GC.UI.selectedLead]
        if not lead then
            page.replyResult:SetText("Kein Interessent ausgewählt.")
            SetTextColor(page.replyResult, THEME.danger)
            return
        end
        local ok, message = GC.Chat:SetInboxFilter(lead.name, days)
        page.replyResult:SetText(message or "")
        SetTextColor(page.replyResult, ok and THEME.success or THEME.danger)
        GC.UI.selectedLead = 1
        page.replyEdit:SetText("")
        GC.UI:RefreshInbox()
    end

    page.hideTempButton = CreateButton(detailCard, "7 Tage ausblenden", 248, 34, function()
        FilterSelectedLead(7)
    end)
    page.hideTempButton:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -502)

    page.hideForeverButton = CreateButton(detailCard, "Dauerhaft ignorieren", 248, 34, function()
        FilterSelectedLead(0)
    end)
    page.hideForeverButton:SetPoint("LEFT", page.hideTempButton, "RIGHT", 8, 0)

    -- Die Vorlagen hinter den drei Knoepfen werden dort gepflegt, wo sie
    -- benutzt werden, nicht in den Einstellungen.
    local templateCard = CreateCard(content, "Vorlagen für Danke, Gildeninfos und Discord")
    templateCard:SetSize(752, 244)
    templateCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -566)
    local templateHelp = CreateLabel(templateCard,
        "Diese Texte füllen die drei Knöpfe oben. Sie gelten gildenweit. Platzhalter: {name}, {gilde}, {beschreibung}, {raidzeiten}, {progress}, {loot}, {discord}, {kontakt}.",
        { muted = true, width = 716, height = 30, vertical = "TOP" })
    templateHelp:SetPoint("TOPLEFT", templateCard, "TOPLEFT", 18, -44)

    page.templateEdits = {}
    local templateDefinitions = {
        { key = "THANKS", label = "Danke", y = -82 },
        { key = "INFO", label = "Gildeninfos", y = -124 },
        { key = "DISCORD", label = "Discord", y = -166 },
    }
    for _, definition in ipairs(templateDefinitions) do
        local label = CreateLabel(templateCard, definition.label, { muted = true, width = 100 })
        label:SetPoint("TOPLEFT", templateCard, "TOPLEFT", 18, definition.y)
        local edit = CreateEdit(templateCard, 590, 32)
        edit.container:SetPoint("TOPLEFT", templateCard, "TOPLEFT", 134, definition.y + 6)
        page.templateEdits[definition.key] = edit
    end

    page.saveTemplates = CreateButton(templateCard, "Vorlagen speichern", 180, 32, function()
        if not GC.Roster:CanEditGuildProfile() then
            page.templateStatus:SetText("Dein Gildenrang darf die gildenweiten Vorlagen nicht bearbeiten.")
            SetTextColor(page.templateStatus, THEME.danger)
            return
        end
        local guildData = GC.DB:GetGuild()
        for key, edit in pairs(page.templateEdits) do
            guildData.replyTemplates[key] = GC.Util.Trim(edit:GetText())
        end
        guildData.profile.updatedAt = GC.Util.Now()
        GC.Sync:QueueGuildProfile()
        GC:FireCallback("GUILD_PROFILE_UPDATED")
        page.templateStatus:SetText("Vorlagen gespeichert und für die Gilde synchronisiert.")
        SetTextColor(page.templateStatus, THEME.success)
    end, "PRIMARY")
    page.saveTemplates:SetPoint("BOTTOMLEFT", templateCard, "BOTTOMLEFT", 134, 14)
    page.templateStatus = CreateLabel(templateCard, "", { width = 420 })
    page.templateStatus:SetPoint("LEFT", page.saveTemplates, "RIGHT", 14, 0)

    local filterCard = CreateCard(content, "Ausgeblendete Spieler")
    filterCard:SetSize(752, 196)
    filterCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -822)
    local filterHelp = CreateLabel(filterCard,
        "Von diesen Spielern landet nichts mehr im Postfach. Befristete Einträge verschwinden"
        .. " von selbst, sobald das Datum erreicht ist. Die Liste gilt nur für dich.",
        { muted = true, width = 716, height = 30, vertical = "TOP" })
    filterHelp:SetPoint("TOPLEFT", filterCard, "TOPLEFT", 18, -44)

    page.filterRows = {}
    for index = 1, 4 do
        local rowIndex = index
        local row = CreatePanel(filterCard, index % 2 == 0 and THEME.input or THEME.cardHover)
        row:SetSize(716, 26)
        row:SetPoint("TOPLEFT", filterCard, "TOPLEFT", 18, -82 - ((index - 1) * 28))
        row.name = CreateLabel(row, "", { width = 200, height = 26 })
        row.name:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.until_ = CreateLabel(row, "", { muted = true, width = 340, height = 26 })
        row.until_:SetPoint("LEFT", row, "LEFT", 217, 0)
        row.clear = CreateButton(row, "Wieder zulassen", 150, 22, function()
            local entry = page.filterEntries and page.filterEntries[rowIndex]
            if entry and GC.Chat:ClearInboxFilter(entry.key) then
                GC.UI:RefreshInbox()
            end
        end)
        row.clear:SetPoint("RIGHT", row, "RIGHT", -9, 0)
        page.filterRows[index] = row
    end
    page.filterNotice = CreateLabel(filterCard, "", { muted = true, width = 716, height = 20 })
    page.filterNotice:SetPoint("BOTTOMLEFT", filterCard, "BOTTOMLEFT", 18, 12)
end

function GC.UI:RefreshInbox()
    local page = self.pages.INBOX
    if not page then
        return
    end

    local canEditTemplates = GC.Roster:CanEditGuildProfile()
    local templates = GC.DB:GetGuild().replyTemplates
    for key, edit in pairs(page.templateEdits) do
        if not edit:HasFocus() then
            edit:SetText(templates[key] or "")
        end
        if canEditTemplates then
            edit:Enable()
        else
            edit:Disable()
        end
    end
    SetButtonEnabled(page.saveTemplates, canEditTemplates)
    if not canEditTemplates and page.templateStatus:GetText() == "" then
        page.templateStatus:SetText("Die Vorlagen sind für deinen Rang schreibgeschützt.")
        SetTextColor(page.templateStatus, THEME.warning)
    end

    local inbox = GC.DB:GetGuild().inbox
    if #inbox > 0 then
        page.clearInboxButton:Enable()
    else
        page.clearInboxButton:Disable()
    end
    if #inbox == 0 then
        page.confirmClearInbox = false
        page.clearInboxButton:SetText("Alle löschen")
    end
    local replyMarker = math.floor(tonumber(GC.DB:GetGuild().recruitment.replyMarker) or 0)
    page.replyMarkerOff:SetActive(replyMarker == 0)
    for markerIndex, markerButton in ipairs(page.replyMarkerButtons) do
        markerButton:SetActive(markerIndex == replyMarker)
    end
    if self.selectedLead > #inbox then
        self.selectedLead = math.max(1, #inbox)
    end
    for index, button in ipairs(page.leadButtons) do
        local lead = inbox[index]
        button:SetShown(lead ~= nil)
        page.leadDeleteButtons[index]:SetShown(lead ~= nil)
        if lead then
            -- Mehrfaches Anschreiben landet bereits in einem Eintrag. Die Zahl
            -- macht sichtbar, dass dahinter mehr als eine Nachricht steckt.
            local count = #(lead.messages or {})
            -- Die Klasse steckt in der gespeicherten GUID. Der Aufruf hier holt
            -- sie auch fuer Altbestaende nach, sobald der Namens-Cache des
            -- Clients sie kennt.
            GC.Chat:ResolveLeadClass(lead)
            local level = tonumber(lead.level)
            button:SetText((lead.unread and "•  " or "")
                .. ClassColoredName(GC.Util.PlayerShortName(lead.name), lead.classFile)
                .. (level and ("  |cff8b98a5" .. level .. "|r") or "")
                .. (count > 1 and ("  |cff8b98a5(" .. count .. ")|r") or ""))
            button:SetActive(self.selectedLead == index)
        end
    end

    local filters = GC.Chat:GetInboxFilterList()
    page.filterEntries = filters
    for index, row in ipairs(page.filterRows) do
        local entry = filters[index]
        row:SetShown(entry ~= nil)
        if entry then
            row.name:SetText(entry.name)
            if entry.until_ ~= "" then
                local days = GC.Util.DaysBetweenISO(GC.Util.TodayISO(), entry.until_)
                row.until_:SetText("ausgeblendet bis " .. entry.until_
                    .. (days and ("  •  noch " .. days .. (days == 1 and " Tag" or " Tage")) or ""))
            else
                row.until_:SetText("dauerhaft ignoriert")
            end
        end
    end
    if #filters == 0 then
        page.filterNotice:SetText("Niemand ausgeblendet.")
    elseif #filters > #page.filterRows then
        page.filterNotice:SetText("Weitere " .. (#filters - #page.filterRows)
            .. " ausgeblendete Spieler sind vorhanden.")
    else
        page.filterNotice:SetText("")
    end

    SetButtonEnabled(page.hideTempButton, inbox[self.selectedLead] ~= nil)
    SetButtonEnabled(page.hideForeverButton, inbox[self.selectedLead] ~= nil)

    local lead = inbox[self.selectedLead]
    if not lead then
        page.leadTitle:SetText("Noch keine Interessenten")
        page.lastMessage:SetText("Starte eine Suche. Eingehende Flüsternachrichten erscheinen automatisch hier.")
        if not page.replyEdit:HasFocus() then
            page.replyEdit:SetText("")
        end
        self:SetLeadProfileLinks(nil)
        page.replyButton:Disable()
        page.inviteButton:Disable()
        return
    end

    GC.Chat:ResolveLeadClass(lead)
    local classInfo = GC.Classes[lead.classFile or ""]
    local level = tonumber(lead.level)
    page.leadTitle:SetText(ClassColoredName(GC.Util.PlayerShortName(lead.name), lead.classFile)
        .. (classInfo and ("  |cff8b98a5" .. (level and (level .. "  ") or "")
            .. classInfo.name .. "|r") or (level and ("  |cff8b98a5" .. level .. "|r") or "")))
    local latest = lead.messages[#lead.messages]
    local source = latest and latest.source and latest.source ~= "WHISPER" and ("  •  " .. latest.source) or ""
    -- Wann geschrieben wurde, entscheidet mit darueber, ob sich eine Antwort
    -- noch lohnt. Die Zeit stand bisher nur in den Daten, nicht am Eintrag.
    local stamp = latest and FormatInboxTime(latest.receivedAt) or ""
    if stamp ~= "" then
        stamp = "  •  " .. stamp
    end
    page.lastMessage:SetText(latest
        and ("Letzte Nachricht" .. source .. stamp .. "\n\"" .. latest.text .. "\"")
        or "")
    self:SetLeadProfileLinks(lead)
    page.replyButton:Enable()
    page.inviteButton:Enable()
end

-- Die Linkfelder sind bewusst nur zum Kopieren da: WoW-Addons koennen weder
-- einen Browser oeffnen noch in die Zwischenablage schreiben.
function GC.UI:SetLeadProfileLinks(lead)
    local page = self.pages.INBOX
    if not page or not page.leadLinkEdits then
        return
    end
    local links = lead and GC.WarcraftLogs:BuildCharacterLinks(lead.name) or {}
    local missing = false
    for key, edit in pairs(page.leadLinkEdits) do
        local link = links[key] or ""
        edit.linkValue = link
        if not edit:HasFocus() then
            edit:SetText(link)
        end
        if lead and link == "" then
            missing = true
        end
    end
    if missing then
        page.leadLinkNotice:SetText("Für Links zuerst unter Warcraft Logs die Gildenquelle speichern.")
    else
        page.leadLinkNotice:SetText("")
    end
end

function GC.UI:BuildGuildPage()
    local page = self.pages.GUILD
    CreatePageTitle(page, "Gildenprofil", "Diese Angaben werden gildenweit synchronisiert und fließen in Werbe- und Antworttexte ein.")

    local card = CreateCard(page, "Texte & Eckdaten")
    card:SetSize(776, 490)
    card:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)
    page.guildFields = {}
    local fields = {
        { key = "description", label = "Kurzbeschreibung", y = -52, multiline = true, height = 78 },
        { key = "raidTimes", label = "Raidzeiten", y = -150 },
        { key = "progress", label = "Content / Progress", y = -202 },
        { key = "lootSystem", label = "Lootsystem", y = -254 },
        { key = "discord", label = "Discord", y = -306 },
        { key = "contact", label = "Kontaktperson", y = -358 },
    }
    for _, definition in ipairs(fields) do
        local label = CreateLabel(card, definition.label, { muted = true, width = 150 })
        label:SetPoint("TOPLEFT", card, "TOPLEFT", 18, definition.y)
        local edit
        if definition.multiline then
            edit = CreateTextArea(card, 558, definition.height, 800)
        else
            edit = CreateEdit(card, 558, 34)
        end
        edit.container:SetPoint("TOPLEFT", card, "TOPLEFT", 194, definition.y + 8)
        page.guildFields[definition.key] = edit
    end

    page.guildSaveButton = CreateButton(card, "Speichern & weiter", 200, 38, function()
        if not GC.Roster:CanEditGuildProfile() then
            page.saveResult:SetText("Dein Gildenrang darf das Gildenprofil nicht bearbeiten.")
            SetTextColor(page.saveResult, THEME.danger)
            return
        end
        local profile = GC.DB:GetGuild().profile
        for key, edit in pairs(page.guildFields) do
            profile[key] = GC.Util.Trim(edit:GetText())
        end
        profile.updatedAt = GC.Util.Now()
        GC.DB:GetGuild().recruitment.adText = GC.Recruitment:GenerateAdvertisement()
        if GC.Sync and GC.Sync.QueueGuildProfile then
            GC.Sync:QueueGuildProfile()
        end
        GC:FireCallback("GUILD_PROFILE_UPDATED")
        page.saveResult:SetText("Gespeichert und zur Gildensynchronisierung vorgemerkt.")
        SetTextColor(page.saveResult, THEME.success)
        GC.UI:ShowPage("SUGGESTIONS")
    end, "PRIMARY")
    page.guildSaveButton:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 194, 18)
    page.saveResult = CreateLabel(card, "", { width = 330 })
    page.saveResult:SetPoint("LEFT", page.guildSaveButton, "RIGHT", 14, 0)
end

function GC.UI:RefreshGuild()
    local page = self.pages.GUILD
    if not page then
        return
    end
    local info = GC.DB:GetGuild().profile
    local canEdit = GC.Roster:CanEditGuildProfile()
    for key, edit in pairs(page.guildFields) do
        if not edit:HasFocus() then
            edit:SetText(info[key] or "")
        end
        if canEdit then
            edit:Enable()
        else
            edit:Disable()
        end
    end
    if canEdit then
        page.guildSaveButton:Enable()
        if page.saveResult:GetText() == "" then
            page.saveResult:SetText("Dein Rang darf dieses gildenweite Profil bearbeiten.")
            SetTextColor(page.saveResult, THEME.muted)
        end
    else
        page.guildSaveButton:Disable()
        page.saveResult:SetText("Nur in Einstellungen freigegebene Gildenränge dürfen Änderungen speichern.")
        SetTextColor(page.saveResult, THEME.warning)
    end
end

function GC.UI:BuildWarcraftLogsPage()
    local page = self.pages.WCL
    CreatePageTitle(page, "Warcraft Logs",
        "Profile manuell eingeben oder öffentliche Reports mit dem mitgelieferten Windows-Helfer auslesen.")

    local sourceCard = CreateCard(page, "Gildenquelle")
    sourceCard:SetSize(776, 186)
    sourceCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)
    -- Die häufige Frage lautet: warum die URL hier eintragen, wenn der Import
    -- ohnehin von Hand kommt? Weil ein WoW-Addon selbst nichts aus dem Netz
    -- laden darf. Die Antwort gehört sichtbar an die Stelle, an der die Frage
    -- entsteht.
    local sourceHelp = CreateLabel(sourceCard,
        "Ein WoW-Addon darf selbst nichts aus dem Internet laden – deshalb übernimmt der Windows-Helfer den Abruf."
        .. " Die hier gespeicherte Gilde erspart dir dort die Eingabe, liefert Region und Realm für die Profil-Links"
        .. " im Postfach und wird an alle Gildenmitglieder synchronisiert.",
        { muted = true, width = 740, height = 44, vertical = "TOP" })
    sourceHelp:SetPoint("TOPLEFT", sourceCard, "TOPLEFT", 18, -44)
    page.wclURL = CreateEdit(sourceCard, 740, 38)
    page.wclURL.container:SetPoint("TOPLEFT", sourceCard, "TOPLEFT", 18, -85)

    local detect = CreateButton(sourceCard, "Aus Gilde erkennen", 170, 34, function()
        page.wclURL:SetText(GC.WarcraftLogs:GetSuggestedURL())
        page.wclResult:SetText("Link aus Region, Realm und Gildenname vorbereitet.")
        SetTextColor(page.wclResult, THEME.muted)
    end)
    detect:SetPoint("TOPLEFT", sourceCard, "TOPLEFT", 18, -138)
    local save = CreateButton(sourceCard, "Quelle speichern", 160, 34, function()
        local success, message = GC.WarcraftLogs:SaveSource(page.wclURL:GetText())
        page.wclResult:SetText(message or "")
        SetTextColor(page.wclResult, success and THEME.success or THEME.danger)
        GC.UI:RefreshWarcraftLogs()
    end, "PRIMARY")
    save:SetPoint("LEFT", detect, "RIGHT", 8, 0)
    page.wclResult = CreateLabel(sourceCard, "", { width = 385 })
    page.wclResult:SetPoint("LEFT", save, "RIGHT", 14, 0)

    local importCard = CreateCard(page, "Import – manuell oder Installer")
    importCard:SetSize(776, 238)
    importCard:SetPoint("TOPLEFT", sourceCard, "BOTTOMLEFT", 0, -10)
    local importHelp = CreateLabel(importCard,
        "Ohne API: Name;Klasse;Primär-Spec;Dual-Spec – z. B. Nexarius;Magier;Arkan;Frost.\nAutomatisch: Im Guild-Copilot-Installer „Import erzeugen“; die Companion-CMD bleibt als Rückfall. Danach hier mit Strg+V einfügen.",
        { muted = true, width = 740, height = 44, vertical = "TOP" })
    importHelp:SetPoint("TOPLEFT", importCard, "TOPLEFT", 18, -46)
    -- Ein Companion-Export mit mehreren Reports ist schnell größer als das
    -- alte Limit von 12000 Zeichen; darüber schneidet WoW beim Einfügen
    -- stillschweigend ab und der Import scheitert ohne erkennbaren Grund.
    page.wclImport = CreateTextArea(importCard, 740, 82, 60000)
    page.wclImport.container:SetPoint("TOPLEFT", importCard, "TOPLEFT", 18, -92)
    page.wclImport:SetText("")

    -- Der Import ersetzt die gespeicherten Profile vollständig. Solange die
    -- Meldung nach einem Klick genauso aussehen kann wie vorher, weiß niemand,
    -- ob überhaupt etwas passiert ist. Deshalb: erster Klick benennt die
    -- Folgen, zweiter Klick führt aus - dasselbe Muster wie beim
    -- Gildenausschluss. Jede Rückmeldung trägt die Uhrzeit, damit auch ein
    -- gleichlautendes Ergebnis sichtbar neu ist.
    local import
    local function DisarmImport()
        page.wclImportArmed = false
        if import then
            import:SetText("Daten importieren")
        end
    end

    local function ShowImportResult(message, success)
        page.wclImportResult:SetText((message or "") .. "  (" .. date("%H:%M:%S") .. ")")
        SetTextColor(page.wclImportResult, success and THEME.success or THEME.danger)
    end

    import = CreateButton(importCard, "Daten importieren", 170, 36, function()
        local text = page.wclImport:GetText()
        if GC.Util.Trim(text) == "" then
            DisarmImport()
            ShowImportResult("Das Importfeld ist leer.", false)
            return
        end

        local stored = GC.WarcraftLogs:GetImportedCount()
        if stored > 0 and not page.wclImportArmed then
            page.wclImportArmed = true
            import:SetText("Wirklich ersetzen")
            ShowImportResult(stored .. " gespeicherte Profile werden ersetzt. "
                .. "Zum Bestätigen erneut klicken.", false)
            return
        end

        DisarmImport()
        local success, message = GC.WarcraftLogs:Import(text)
        ShowImportResult(message, success)
        GC.UI:RefreshWarcraftLogs()
    end, "PRIMARY")
    import:SetPoint("BOTTOMLEFT", importCard, "BOTTOMLEFT", 18, 14)
    page.wclImportButton = import
    page.wclImportDisarm = DisarmImport

    -- Neuer Text heißt neue Absicht: alte Meldung weg, Bestätigung zurück.
    page.wclImport:SetScript("OnTextChanged", function(_, userInput)
        if not userInput then
            return
        end
        DisarmImport()
        page.wclImportResult:SetText("")
    end)
    page.wclImportResult = CreateLabel(importCard, "", { width = 535 })
    page.wclImportResult:SetPoint("LEFT", import, "RIGHT", 14, 0)

    local statusCard = CreateCard(page, "Status")
    statusCard:SetSize(776, 90)
    statusCard:SetPoint("TOPLEFT", importCard, "BOTTOMLEFT", 0, -10)
    page.wclStatus = CreateLabel(statusCard, "", { width = 740, height = 40, vertical = "TOP" })
    page.wclStatus:SetPoint("TOPLEFT", statusCard, "TOPLEFT", 18, -42)
end

function GC.UI:RefreshWarcraftLogs()
    local page = self.pages.WCL
    if not page then
        return
    end
    local data = GC.DB:GetGuild().warcraftLogs
    if not page.wclURL:HasFocus() then
        page.wclURL:SetText(data.url ~= "" and data.url or GC.WarcraftLogs:GetSuggestedURL())
    end
    -- Eine scharfgeschaltete Bestätigung darf einen Seitenwechsel nicht
    -- überleben; sonst löst der nächste Klick unerwartet aus.
    if page.wclImportDisarm then
        page.wclImportDisarm()
    end
    local imported = GC.WarcraftLogs:GetImportedCount()
    if imported > 0 then
        -- Die Zahl der Nachanalysen gehört sichtbar daneben: sonst sieht ein
        -- reiner Profilimport genauso aus wie einer mit Raidauswertungen.
        local sessions = data.sessionCount or 0
        -- Stand und Herkunft machen sichtbar, dass Profile auch von anderen
        -- Gildenmitgliedern hereinkommen und nicht jeder selbst importieren muss.
        local stand = ""
        local importedAt = tonumber(data.importedAt) or 0
        if importedAt > 0 and date then
            stand = "  •  Stand " .. date("%d.%m.%Y %H:%M", importedAt)
        end
        local from = GC.Util.Trim(data.lastSyncFrom) ~= ""
            and ("  •  zuletzt von " .. data.lastSyncFrom)
            or ""
        page.wclStatus:SetText("|cff59e695" .. imported .. " Spielerprofile verfügbar|r"
            .. (data.reportCount > 0 and ("  •  " .. data.reportCount .. " Reports") or "")
            .. (sessions > 0
                and ("  •  |cff59e695" .. sessions .. " Raidauswertungen|r")
                or "  •  |cffe8b84bkeine Raidauswertung|r")
            .. stand .. from
            .. "\nDiese Specs ergänzen jetzt automatisch die Roster- und Copilot-Auswertung."
            .. " Profile werden automatisch in der Gilde geteilt; vollständige Kampfauswertungen bleiben lokal.")
    else
        page.wclStatus:SetText("|cff91a3b8Noch keine Log-Daten importiert.|r"
            .. "\nDie gespeicherte URL ist für den Companion vorbereitet."
            .. " Importiert ein anderes Gildenmitglied, erscheinen die Profile auch hier von selbst.")
    end
end

local function FormatDuration(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if hours > 0 then
        return hours .. "h " .. minutes .. "m"
    end
    return minutes .. "m"
end

local function FormatSessionDate(summary)
    if date and summary.startedAt and summary.startedAt > 0 then
        local ok, formatted = pcall(date, "%d.%m. %H:%M", summary.startedAt)
        if ok and formatted then
            return formatted
        end
    end
    return "unbekannt"
end

function GC.UI:BuildStatisticsPage()
    local page = self.pages.STATISTICS
    CreatePageTitle(page, "Raidauswertung",
        "Sitzungen laufen ausdrücklich durch Raidleiter, Assistenten oder berechtigte Gildenränge."
        .. " Es werden nur Zusammenfassungen gespeichert, keine Rohdaten."
        .. " TIME ist die Anwesenheit, INT sind Unterbrechungen, DISP entfernte Effekte."
        .. " Klick auf einen Spaltenkopf sortiert; die Maus über einer Zeile zeigt alles im Detail.")

    local controlCard = CreateCard(page)
    controlCard:SetSize(776, 96)
    controlCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)
    page.sessionStatus = CreateLabel(controlCard, "", { width = 470, height = 46, vertical = "TOP" })
    page.sessionStatus:SetPoint("TOPLEFT", controlCard, "TOPLEFT", 18, -14)

    -- Kurze Rückmeldungen stehen im Fenster und zusätzlich im Chat, damit sie
    -- auch bei geschlossenem Addonfenster ankommen. Die Auswertung selbst
    -- bleibt vollständig in der Oberfläche.
    page.actionStatus = CreateLabel(controlCard, "", { width = 560, height = 26, vertical = "TOP" })
    page.actionStatus:SetPoint("TOPLEFT", controlCard, "TOPLEFT", 18, -64)

    function page:SetActionStatus(message, ok)
        message = GC.Util.Trim(message)
        self.actionStatus:SetText(message)
        SetTextColor(self.actionStatus, ok == false and THEME.danger or THEME.success)
        if message ~= "" then
            GC:Print(message)
        end
    end

    page.sessionButton = CreateButton(controlCard, "Sitzung starten", 150, 30, function()
        local monitor = GC.RaidMonitor
        local ok, message
        if monitor.session then
            ok, message = monitor:EndSession()
        else
            ok, message = monitor:BeginSession()
        end
        page:SetActionStatus(message, ok)
        GC.UI:RefreshStatistics()
    end, "PRIMARY")
    page.sessionButton:SetPoint("TOPRIGHT", controlCard, "TOPRIGHT", -18, -14)

    page.requestButton = CreateButton(controlCard, "Auswertung anfordern", 150, 30, function()
        local ok, message = GC.RaidMonitor:RequestSummaries()
        page:SetActionStatus(message, ok)
    end)
    page.requestButton:SetPoint("TOPRIGHT", page.sessionButton, "BOTTOMRIGHT", 0, -4)

    page.reviewButton = CreateButton(controlCard, "Detailfenster", 130, 30, function()
        GC.UI:ShowSessionReview()
    end)
    page.reviewButton:SetPoint("RIGHT", page.requestButton, "LEFT", -8, 0)

    local listCard = CreateCard(page, "Sitzungen")
    listCard:SetSize(238, 358)
    listCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -172)
    page.sessionRows = {}
    for index = 1, 12 do
        local row = CreateButton(listCard, "", 206, 23, function()
            -- Ein Eintrag ist ein Abend, nicht eine Quelle. Gewaehlt wird die
            -- vollstaendigste Auswertung; auf die anderen Quellen fuehren die
            -- Knoepfe neben der Kopfzeile.
            local evening = GC.RaidMonitor:GetEvenings()[index]
            if evening then
                GC.RaidMonitor.selectedSessionID = evening.summary.id
                GC.UI:RefreshStatistics()
            end
        end)
        row:SetPoint("TOPLEFT", listCard, "TOPLEFT", 16, -50 - ((index - 1) * 25))
        row.label:SetJustifyH("LEFT")
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.label:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        page.sessionRows[index] = row
    end
    page.sessionEmpty = CreateLabel(listCard, "Noch keine Auswertung vorhanden.", { muted = true, width = 200, height = 40, vertical = "TOP" })
    page.sessionEmpty:SetPoint("TOPLEFT", listCard, "TOPLEFT", 16, -52)

    local detailCard = CreateCard(page, "Teilnehmer")
    detailCard:SetSize(526, 358)
    detailCard:SetPoint("TOPLEFT", page, "TOPLEFT", 250, -172)
    page.sessionHeadline = CreateLabel(detailCard, "", { muted = true, width = 486, height = 18 })
    page.sessionHeadline:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -44)

    -- Liegt derselbe Abend aus mehreren Quellen vor, steht er einmal in der
    -- Liste. Verborgen bleiben darf dabei nichts: Diese Knoepfe wechseln die
    -- Quelle. Sie stehen in der Kopfzeile der Karte, weil darunter die
    -- Tabellenkoepfe beginnen und dazwischen kein Platz ist.
    page.sessionSourceButtons = {}
    for index = 1, 3 do
        local button = CreateButton(detailCard, "", 118, 20, function()
            local target = GC.UI.pages.STATISTICS.sessionSourceButtons[index].summaryID
            if target then
                GC.RaidMonitor.selectedSessionID = target
                GC.UI:RefreshStatistics()
            end
        end)
        button:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 146 + ((index - 1) * 122), -14)
        button:Hide()
        page.sessionSourceButtons[index] = button
    end

    -- Elixiere haben eine eigene Spalte. Sie mit Flaeschchen zusammenzufassen
    -- war ein Fehler: In einem Raid, in dem niemand Flaeschchen nimmt, stand
    -- jede Elixierzahl unter der Ueberschrift "Flasche" - und war damit
    -- praktisch unauffindbar. Nur Runen laufen weiter bei den Traenken mit,
    -- Oele und Steine stehen im Tooltip.
    -- Englische Koepfe: kuerzer als die deutschen und in Raid-Werkzeugen
    -- gebraeuchlich. Der gewonnene Platz geht an die Namensspalte, die vorher
    -- laengere Namen abschnitt. Was die Kuerzel bedeuten, steht im Seitentext
    -- und ausgeschrieben im Tooltip der Zeile.
    local detailHeaders = {
        { text = "NAME",   key = "name",       x = 18,  width = 96 },
        { text = "TIME",   key = "presence",   x = 117, width = 44 },
        { text = "DEATH",  key = "deaths",     x = 164, width = 42 },
        { text = "INT",    key = "interrupts", x = 209, width = 32 },
        { text = "DISP",   key = "dispels",    x = 244, width = 38 },
        { text = "POT",    key = "potions",    x = 285, width = 36 },
        { text = "FLASK",  key = "flasks",     x = 324, width = 44 },
        { text = "ELIXIR", key = "elixirs",    x = 371, width = 48 },
        { text = "FOOD",   key = "food",       x = 422, width = 40 },
        { text = "DRUM",   key = "drums",      x = 465, width = 38 },
    }

    -- Die Kopfzeile sortiert. Erster Klick absteigend, zweiter aufsteigend -
    -- "wer hat keine Flaeschchen" ist damit ein Klick statt einer Suche.
    page.sortHeaders = {}
    for _, headerDefinition in ipairs(detailHeaders) do
        local sortKey = headerDefinition.key
        local header = CreateButton(detailCard, headerDefinition.text,
            headerDefinition.width, 18, function()
                if page.sortKey == sortKey then
                    page.sortDescending = not page.sortDescending
                else
                    page.sortKey = sortKey
                    -- Namen von A nach Z, Zahlen von viel nach wenig.
                    page.sortDescending = sortKey ~= "name"
                end
                GC.UI:RefreshStatistics()
            end)
        header:SetPoint("TOPLEFT", detailCard, "TOPLEFT", headerDefinition.x, -66)
        header.background:Hide()
        header.border:Hide()
        header.label:SetFontObject("GameFontNormalSmall")
        header.label:ClearAllPoints()
        header.label:SetPoint("LEFT", header, "LEFT", 0, 0)
        header.label:SetJustifyH("LEFT")
        header.baseText = headerDefinition.text
        header.sortKey = sortKey
        page.sortHeaders[#page.sortHeaders + 1] = header
    end

    local scroll = CreateModernScrollFrame(detailCard)
    scroll:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 14, -86)
    scroll:SetPoint("BOTTOMRIGHT", detailCard, "BOTTOMRIGHT", -16, 14)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(492)
    content:SetHeight(1100)
    scroll:SetScrollChild(content)

    -- Zeilen lassen sich mit der Maus umsortieren (Owner-Wunsch): Das Ziehen
    -- übernimmt die gerade angezeigte Reihenfolge als Handsortierung dieser
    -- Auswertung und schaltet die Spaltensortierung ab. Ein Klick auf einen
    -- Spaltenkopf sortiert wieder nach Spalte; die Handordnung bleibt
    -- gemerkt, bis erneut gezogen wird.
    CreateLabel(detailCard, "Zeilen ziehen ordnet von Hand", {
        muted = true,
        font = "GameFontNormalSmall",
        align = "RIGHT",
        width = 220,
    }):SetPoint("TOPRIGHT", detailCard, "TOPRIGHT", -16, -20)

    page.participantRows = {}
    for index = 1, 40 do
        local row = CreatePanel(content, index % 2 == 0 and THEME.input or THEME.card)
        row:SetSize(490, 25)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * 27))
        row.rowIndex = index
        row:RegisterForDrag("LeftButton")
        row:SetScript("OnDragStart", function(self)
            if self.participant then
                page.dragFromIndex = self.rowIndex
                if self.SetAlpha then
                    self:SetAlpha(0.55)
                end
            end
        end)
        row:SetScript("OnDragStop", function(self)
            if self.SetAlpha then
                self:SetAlpha(1)
            end
            local fromIndex = page.dragFromIndex
            page.dragFromIndex = nil
            if not fromIndex or not GetCursorPosition then
                return
            end
            local scale = (UIParent and UIParent.GetEffectiveScale
                and UIParent:GetEffectiveScale()) or 1
            local _, cursorY = GetCursorPosition()
            if not cursorY then
                return
            end
            cursorY = cursorY / scale
            for targetIndex, candidate in ipairs(page.participantRows) do
                if candidate:IsShown() then
                    local top, bottom = candidate:GetTop(), candidate:GetBottom()
                    if top and bottom and cursorY <= top and cursorY >= bottom then
                        if targetIndex ~= fromIndex then
                            GC.UI:MoveParticipantRow(fromIndex, targetIndex)
                        end
                        return
                    end
                end
            end
        end)
        local columns = {
            { key = "name", x = 5, width = 96 },
            { key = "presence", x = 104, width = 44 },
            { key = "deaths", x = 151, width = 42 },
            { key = "interrupts", x = 196, width = 32 },
            { key = "dispels", x = 231, width = 38 },
            { key = "potions", x = 272, width = 36 },
            { key = "flasks", x = 311, width = 44 },
            { key = "elixirs", x = 358, width = 48 },
            { key = "food", x = 409, width = 40 },
            { key = "drums", x = 452, width = 38 },
        }
        for _, column in ipairs(columns) do
            row[column.key] = CreateLabel(row, "", { width = column.width, height = 25 })
            row[column.key]:SetPoint("LEFT", row, "LEFT", column.x, 0)
        end

        -- Die Spaltenkoepfe muessen kurz sein. Was sie bedeuten und was in den
        -- zusammengefassten Spalten steckt, steht hier vollstaendig.
        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self)
            local participant = self.participant
            if not participant or not GameTooltip then
                return
            end
            local consumables = participant.consumables or {}
            AnchorRowTooltip(self)
            GameTooltip:SetText(participant.name or "")
            local presence = "Dabei: " .. FormatDuration(participant.seconds)
            if (self.sessionSeconds or 0) > 0 then
                presence = presence .. "  von  " .. FormatDuration(self.sessionSeconds)
                    .. "   (" .. math.floor(((participant.seconds or 0) / self.sessionSeconds) * 100 + 0.5) .. " %)"
            end
            GameTooltip:AddLine(presence, 1, 1, 1)
            GameTooltip:AddLine("Tode: " .. (participant.deaths or 0)
                .. "   Wiederbelebungen: " .. (participant.resurrects or 0), 1, 1, 1)
            GameTooltip:AddLine("Unterbrechungen: " .. (participant.interrupts or 0)
                .. "   Bannen: " .. (participant.dispels or 0), 1, 1, 1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Verbrauchsgegenstände", 0.31, 0.79, 1)
            for _, category in ipairs(GC.ConsumableCategories) do
                local count = consumables[category.key] or 0
                local red, green, blue = 0.57, 0.64, 0.72
                if count > 0 then
                    red, green, blue = 1, 1, 1
                end
                GameTooltip:AddDoubleLine(category.label, tostring(count), red, green, blue, red, green, blue)
            end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        page.participantRows[index] = row
    end
    page.participantEmpty = CreateLabel(detailCard, "Wähle links eine Sitzung aus.", { muted = true, width = 400, height = 40, vertical = "TOP" })
    page.participantEmpty:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -88)
end

function GC.UI:RefreshStatistics()
    local page = self.pages.STATISTICS
    if not page then
        return
    end

    local monitor = GC.RaidMonitor
    local canControl = monitor:CanControlSession()
    local session = monitor.session
    if session then
        local participantCount = 0
        for _ in pairs(session.participants) do
            participantCount = participantCount + 1
        end
        -- Wie in BuildSummary zählen nur erkannte Bosskämpfe; so zeigt auch
        -- eine unter älterer Version gestartete Sitzung keine Trashzahlen.
        local pullCount = 0
        for _, pull in ipairs(session.pulls) do
            if pull.boss then
                pullCount = pullCount + 1
            end
        end
        page.sessionStatus:SetText("|cff59e695Sitzung läuft|r  •  " .. participantCount .. " Teilnehmer  •  "
            .. pullCount .. " Versuche\nGestartet von " .. (session.startedBy ~= "" and session.startedBy or "unbekannt")
            .. (session.zone ~= "" and ("  •  " .. session.zone) or ""))
        page.sessionButton:SetText("Sitzung beenden")
    else
        page.sessionStatus:SetText("|cff91a3b8Keine laufende Sitzung.|r\n"
            .. (canControl and "Du darfst eine Sitzung starten und beenden."
                or "Nur Raidleiter, Assistenten und berechtigte Gildenränge dürfen Sitzungen steuern."))
        page.sessionButton:SetText("Sitzung starten")
    end
    SetButtonEnabled(page.sessionButton, canControl)
    SetButtonEnabled(page.requestButton, canControl)

    -- Je Zeile ein Abend, nicht eine Quelle. Wer denselben Abend live
    -- mitgeschnitten, aus Warcraft Logs geholt und aus der Logdatei importiert
    -- hat, soll ihn einmal in der Liste finden.
    local evenings = monitor:GetEvenings()
    page.sessionEmpty:SetShown(#evenings == 0)
    local selectedID = monitor.selectedSessionID
    if not monitor:GetSummary(selectedID) then
        selectedID = evenings[1] and evenings[1].summary.id
        monitor.selectedSessionID = selectedID
    end

    for index, row in ipairs(page.sessionRows) do
        local evening = evenings[index]
        row:SetShown(evening ~= nil)
        if evening then
            local summary = evening.summary
            local zone = summary.zone ~= "" and summary.zone or "Raid"
            local marks = {}
            for _, candidate in ipairs(evening.sources) do
                marks[#marks + 1] = SESSION_SOURCE_MARK[candidate.source or "LIVE"] or "?"
            end
            row:SetText(FormatSessionDate(summary) .. "  " .. zone
                .. (#marks > 1 and ("  [" .. table.concat(marks, "+") .. "]") or ""))
            local active = false
            for _, candidate in ipairs(evening.sources) do
                active = active or candidate.id == selectedID
            end
            row:SetActive(active)
        end
    end

    local selected = monitor:GetSummary(selectedID)
    page.participantEmpty:SetShown(selected == nil)
    if selected then
        page.sessionHeadline:SetText(FormatSessionDate(selected)
            .. "  •  " .. FormatDuration((selected.endedAt or 0) - (selected.startedAt or 0))
            .. "  •  " .. (selected.pulls or 0) .. " Versuche, " .. (selected.kills or 0) .. " Siege, "
            .. (selected.wipes or 0) .. " Wipes  •  Quelle: "
            .. (SESSION_SOURCE_LABEL[selected.source or "LIVE"] or tostring(selected.source or "Unbekannt")))
    else
        page.sessionHeadline:SetText("")
    end

    -- Die Quellenknöpfe erscheinen nur, wenn es wirklich mehr als eine gibt.
    local evening = selected and monitor:GetEveningOf(selectedID)
    for index, button in ipairs(page.sessionSourceButtons) do
        local candidate = evening and #evening.sources > 1 and evening.sources[index] or nil
        button.summaryID = candidate and candidate.id or nil
        button:SetShown(candidate ~= nil)
        if candidate then
            button:SetText((SESSION_SOURCE_LABEL[candidate.source or "LIVE"] or "?")
                .. " (" .. #(candidate.participants or {}) .. ")")
            SetButtonEnabled(button, candidate.id ~= selectedID)
        end
    end

    local sessionSeconds = selected
        and math.max(0, (selected.endedAt or 0) - (selected.startedAt or 0))
        or 0
    if selected and ENCOUNTER_TIME_SOURCES[selected.source or ""] then
        -- Bei Logs ist die Anwesenheit reine Encounter-Zeit, Beginn/Ende
        -- beschreiben dagegen den ganzen Report inklusive Pausen und Trash.
        -- Der Prozentwert muss deshalb gegen die längste Encounter-Anwesenheit
        -- laufen, nicht gegen die deutlich längere Reportdauer.
        sessionSeconds = 0
        for _, participant in ipairs(selected.participants or {}) do
            sessionSeconds = math.max(sessionSeconds, tonumber(participant.seconds) or 0)
        end
    end

    -- Sortiert wird eine Kopie: Die gespeicherte Reihenfolge der Sitzung
    -- bleibt unangetastet, sonst wuerde ein Klick auf die Kopfzeile die
    -- Auswertung dauerhaft umbauen.
    local participants = {}
    for index, participant in ipairs(selected and selected.participants or {}) do
        participants[index] = participant
    end

    local SORT_VALUES = {
        name = function(p) return tostring(p.name or ""):lower() end,
        presence = function(p) return p.seconds or 0 end,
        deaths = function(p) return p.deaths or 0 end,
        interrupts = function(p) return p.interrupts or 0 end,
        dispels = function(p) return p.dispels or 0 end,
        potions = function(p) return ((p.consumables or {}).POTION or 0) + ((p.consumables or {}).RUNE or 0) end,
        flasks = function(p) return (p.consumables or {}).FLASK or 0 end,
        elixirs = function(p) return (p.consumables or {}).ELIXIR or 0 end,
        food = function(p) return (p.consumables or {}).FOOD or 0 end,
        drums = function(p) return (p.consumables or {}).DRUM or 0 end,
    }

    local valueOf = page.sortKey and SORT_VALUES[page.sortKey]
    if valueOf then
        local descending = page.sortDescending
        table.sort(participants, function(left, right)
            local leftValue, rightValue = valueOf(left), valueOf(right)
            if leftValue == rightValue then
                -- Gleichstand nach Namen, damit die Reihenfolge stabil bleibt
                -- und nicht bei jedem Neuzeichnen springt.
                return tostring(left.name or "") < tostring(right.name or "")
            end
            if descending then
                return leftValue > rightValue
            end
            return leftValue < rightValue
        end)
    elseif selected then
        -- Ohne aktive Spaltensortierung gilt die Handordnung der Auswertung.
        participants = GC.UI.ArrangeParticipants(participants, selected.manualOrder)
    end
    page.displayedParticipants = participants
    page.selectedSummary = selected

    for _, header in ipairs(page.sortHeaders or {}) do
        if page.sortKey == header.sortKey then
            header:SetText(header.baseText .. (page.sortDescending and " v" or " ^"))
            SetTextColor(header.label, THEME.accent)
        else
            header:SetText(header.baseText)
            SetTextColor(header.label, THEME.muted)
        end
    end
    if selected and #participants == 0 then
        page.participantEmpty:SetText("Für diese Sitzung wurden keine Teilnehmer erfasst.")
        page.participantEmpty:SetShown(true)
    elseif selected then
        page.participantEmpty:SetText("Wähle links eine Sitzung aus.")
    end
    for index, row in ipairs(page.participantRows) do
        local participant = participants[index]
        row:SetShown(participant ~= nil)
        if participant then
            local consumables = participant.consumables or {}
            row.participant = participant
            row.sessionSeconds = sessionSeconds
            row.name:SetText(participant.name)
            row.name:SetTextColor(ClassColor(participant.classFile))

            -- Eine nackte Dauer sagt wenig: "36m" ist nur im Verhaeltnis zur
            -- Sitzung zu lesen. Wer deutlich kuerzer da war, faellt deshalb
            -- farblich auf - genau das macht die Spalte brauchbar.
            row.presence:SetText(FormatDuration(participant.seconds))
            if sessionSeconds > 0 then
                local share = (participant.seconds or 0) / sessionSeconds
                if share < 0.5 then
                    SetTextColor(row.presence, THEME.danger)
                elseif share < 0.85 then
                    SetTextColor(row.presence, THEME.warning)
                else
                    SetTextColor(row.presence, THEME.text)
                end
            else
                SetTextColor(row.presence, THEME.text)
            end
            row.deaths:SetText(participant.deaths or 0)
            row.interrupts:SetText(participant.interrupts or 0)
            row.dispels:SetText(participant.dispels or 0)
            -- Runen laufen bei den Traenken mit, Elixiere haben eine eigene
            -- Spalte. Oele und Steine stehen im Tooltip.
            row.potions:SetText((consumables.POTION or 0) + (consumables.RUNE or 0))
            row.flasks:SetText(consumables.FLASK or 0)
            row.elixirs:SetText(consumables.ELIXIR or 0)
            row.food:SetText(consumables.FOOD or 0)
            row.drums:SetText(consumables.DRUM or 0)
        else
            row.participant = nil
        end
    end
end

local GEAR_VERDICT_STYLE = {
    OPTIMAL = { label = "Optimal", color = THEME.success },
    SOLID = { label = "Solide", color = THEME.accent },
    IMPROVABLE = { label = "Verbesserbar", color = THEME.warning },
    MISSING = { label = "Fehlt", color = THEME.danger },
    UNKNOWN = { label = "Unbekannt", color = THEME.muted },
    EMPTY = { label = "Leer", color = THEME.muted },
}

local GEAR_SEVERITY_COLOR = {
    PROBLEM = "ffff6166",
    WARNING = "ffffb840",
    OK = "ff59e695",
    INFO = "ff91a3b8",
}

-- Funde als eingefaerbte Zeilen, damit dieselbe Aufbereitung auf der
-- Ausruestungsseite und im persoenlichen Profil erscheint.
function GC.UI:FormatGearFindings(audit, maximumLines)
    local findings = GC.GearAudit:GetFindings(audit)
    local lines = {}
    for index, finding in ipairs(findings) do
        if maximumLines and index > maximumLines then
            break
        end
        lines[#lines + 1] = "|c" .. (GEAR_SEVERITY_COLOR[finding.severity] or GEAR_SEVERITY_COLOR.INFO)
            .. finding.text .. "|r"
    end
    return table.concat(lines, "\n")
end

function GC.UI:BuildGearPage()
    local page = self.pages.GEAR
    CreatePageTitle(page, "Ausrüstung",
        "Fehlende Verzauberungen, leere Pflichtslots und Sockel je Slot. Addon-Nutzer liefern aktuelle Eigendaten; Inspect bleibt der Rückfall für erreichbare Gruppenmitglieder. Es gibt bewusst keine Gesamtnote.")

    local controlCard = CreateCard(page)
    controlCard:SetSize(776, 96)
    controlCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)
    page.gearStatus = CreateLabel(controlCard, "", { width = 560, height = 46, vertical = "TOP" })
    page.gearStatus:SetPoint("TOPLEFT", controlCard, "TOPLEFT", 18, -14)
    page.gearAction = CreateLabel(controlCard, "", { width = 560, height = 26, vertical = "TOP" })
    page.gearAction:SetPoint("TOPLEFT", controlCard, "TOPLEFT", 18, -64)

    function page:SetGearStatus(message, ok)
        message = GC.Util.Trim(message)
        self.gearAction:SetText(message)
        SetTextColor(self.gearAction, ok == false and THEME.danger or THEME.success)
        if message ~= "" then
            GC:Print(message)
        end
    end

    page.scanButton = CreateButton(controlCard, "Gruppe prüfen", 150, 30, function()
        -- Öffnet die fokussierte Gruppenübersicht im eigenen Fenster
        -- (Owner-Wunsch) und stößt die Prüfung an; die Seite mit der
        -- Dauerliste bleibt unangetastet daneben bestehen.
        local ok, message = GC.GearAudit:StartRaidScan()
        page:SetGearStatus(message, ok)
        GC.UI:ShowGroupGearCheck()
        local frame = GC.UI.groupGearCheck
        if frame then
            frame.status:SetText(message or "")
            SetTextColor(frame.status, ok and THEME.success or THEME.danger)
        end
        GC.UI:RefreshGear()
    end, "PRIMARY")
    page.scanButton:SetPoint("TOPRIGHT", controlCard, "TOPRIGHT", -18, -14)

    page.selfButton = CreateButton(controlCard, "Eigene Ausrüstung", 150, 30, function()
        local ok, message = GC.GearAudit:AuditSelf()
        page:SetGearStatus(message, ok)
        GC.UI:RefreshGear()
    end)
    page.selfButton:SetPoint("TOPRIGHT", page.scanButton, "BOTTOMRIGHT", 0, -4)

    local listCard = CreateCard(page, "Geprüfte Spieler")
    listCard:SetSize(238, 358)
    listCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -172)

    -- Aufräumen auf Knopfdruck: Die Dauerliste sammelt sonst jeden je
    -- gesehenen Charakter, bis niemand mehr das Wesentliche findet.
    page.gearClearButton = CreateButton(listCard, "Leeren", 70, 22, function()
        local ok, message = GC.GearAudit:ClearAudits()
        page:SetGearStatus(message, ok)
        GC.UI:RefreshGear()
    end)
    page.gearClearButton:SetPoint("TOPRIGHT", listCard, "TOPRIGHT", -12, -10)

    -- Rangfilter mit echter Auswahl: Der Knopf klappt eine Häkchenliste aller
    -- Gildenränge auf (Owner-Wunsch). Eine "bis Rang X"-Schwelle taugte
    -- nicht - die Rangreihenfolge einer Gilde ist keine Wertigkeit.
    page.gearRankButton = CreateButton(listCard, "Ränge: alle", 214, 26, function()
        page:ToggleGearRankFlyout()
    end)
    page.gearRankButton:SetPoint("TOPLEFT", listCard, "TOPLEFT", 12, -42)

    function page:RefreshGearRankFlyout()
        local panel = page.gearRankFlyout
        if not panel then
            return
        end
        local ranks = GC.Roster:GetRankDefinitions()
        for index, toggle in ipairs(panel.rows) do
            local rank = ranks[index]
            toggle:SetShown(rank ~= nil)
            toggle.rankIndex = rank and rank.index or nil
            if rank then
                toggle.text:SetText(rank.name)
                toggle:SetChecked(GC.GearAudit:IsRankShown(rank.index))
                toggle:RefreshVisual()
            end
        end
        panel.title:SetText(#ranks > 0 and "Nur diese Ränge zeigen:"
            or "Noch keine Rangdaten - das Gildenroster lädt.")
        panel:SetSize(214, 46 + #ranks * 24 + 36)
    end

    function page:ToggleGearRankFlyout()
        local host = GC.UI.frame
        if not page.gearRankFlyout then
            -- Wie die Dropdown-Popups: ans Hauptfenster gehängt, sonst
            -- schneidet der Seiten-Scroller das Panel ab.
            local panel = CreatePanel(host, THEME.window, THEME.accent, "GuildCopilotGearRankFlyout")
            panel:SetFrameStrata("DIALOG")
            panel:SetToplevel(true)
            panel.title = CreateLabel(panel, "", { muted = true, width = 186, height = 26,
                font = "GameFontNormalSmall", vertical = "TOP" })
            panel.title:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -10)
            panel.rows = {}
            for index = 1, 10 do
                local rowIndex = index
                local toggle = CreateToggle(panel, "", function(checked)
                    local rankIndex = panel.rows[rowIndex].rankIndex
                    if rankIndex ~= nil then
                        GC.GearAudit:SetRankShown(rankIndex, checked)
                        GC.UI:RefreshGear()
                        page:RefreshGearRankFlyout()
                    end
                end)
                toggle:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -40 - ((rowIndex - 1) * 24))
                toggle:Hide()
                panel.rows[rowIndex] = toggle
            end
            panel.reset = CreateButton(panel, "Alle anzeigen", 120, 24, function()
                GC.GearAudit:ResetRankView()
                GC.UI:RefreshGear()
                page:RefreshGearRankFlyout()
            end)
            panel.reset:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 12, 8)
            panel:Hide()
            page.gearRankFlyout = panel
            page:HookScript("OnHide", function()
                panel:Hide()
            end)
        end
        local panel = page.gearRankFlyout
        if panel:IsShown() then
            panel:Hide()
            return
        end
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", page.gearRankButton, "BOTTOMLEFT", 0, -2)
        local hostLevel = host.GetFrameLevel and host:GetFrameLevel() or 1
        panel:SetFrameLevel((hostLevel or 1) + 40)
        page:RefreshGearRankFlyout()
        panel:Show()
        if panel.Raise then
            panel:Raise()
        end
    end

    local playerScroll = CreateModernScrollFrame(listCard)
    playerScroll:SetPoint("TOPLEFT", listCard, "TOPLEFT", 12, -76)
    playerScroll:SetPoint("BOTTOMRIGHT", listCard, "BOTTOMRIGHT", -12, 12)
    local playerContent = CreateFrame("Frame", nil, playerScroll)
    playerContent:SetWidth(202)
    playerContent:SetHeight(1)
    playerScroll:SetScrollChild(playerContent)
    page.gearPlayerScroll = playerScroll
    page.gearPlayerContent = playerContent
    page.gearRows = {}

    -- Beim frischen Aufschlagen der Seite steht die Spielerliste oben
    -- (Owner-Wunsch) - sie merkte sich sonst die alte Scrollposition.
    -- Bewusst nur beim Anzeigen, nicht bei jeder Datenauffrischung, sonst
    -- springt die Liste beim Stöbern unter der Hand weg.
    page:HookScript("OnShow", function()
        playerScroll.targetScroll = nil
        playerScroll:SetVerticalScroll(0)
        playerScroll:UpdateModernThumb()
    end)

    function page:EnsureGearPlayerRow(index)
        if self.gearRows[index] then
            return self.gearRows[index]
        end
        local row = CreateButton(playerContent, "", 198, 23, function()
            -- Die Zeile zeigt die GEFILTERTE Liste; der Klick muss dieselbe
            -- Liste lesen, sonst wählt er bei aktivem Rangfilter den
            -- falschen Spieler.
            local audit = (page.gearAuditList or {})[index]
            if audit then
                GC.GearAudit.selectedName = audit.name
                -- Beim Spielerwechsel oben anfangen, sonst haengt die Liste
                -- an der Scrollposition des vorherigen Spielers fest.
                if page.gearSlotScroll then
                    page.gearSlotScroll:SetVerticalScroll(0)
                    page.gearSlotScroll:UpdateModernThumb()
                end
                GC.UI:RefreshGear()
            end
        end)
        row:SetPoint("TOPLEFT", playerContent, "TOPLEFT", 0, -((index - 1) * 25))
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.label:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        row.label:SetJustifyH("LEFT")
        self.gearRows[index] = row
        return row
    end
    page.gearEmpty = CreateLabel(listCard, "Noch niemand geprüft.", { muted = true, width = 200, height = 40, vertical = "TOP" })
    page.gearEmpty:SetPoint("TOPLEFT", listCard, "TOPLEFT", 16, -84)

    local detailCard = CreateCard(page, "Slots")
    detailCard:SetSize(526, 358)
    detailCard:SetPoint("TOPLEFT", page, "TOPLEFT", 250, -172)
    page.gearHeadline = CreateLabel(detailCard, "", { muted = true, width = 480, height = 18 })
    page.gearHeadline:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -44)
    page.gearFindings = CreateLabel(detailCard, "", { width = 488, height = 52, vertical = "TOP" })
    page.gearFindings:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -64)

    local gearHeaders = {
        { text = "SLOT", x = 18, width = 112 },
        { text = "BEWERTUNG", x = 134, width = 96 },
        { text = "SOCKEL", x = 234, width = 58 },
        { text = "HINWEIS", x = 296, width = 214 },
    }
    for _, headerDefinition in ipairs(gearHeaders) do
        local headerLabel = CreateLabel(detailCard, headerDefinition.text, {
            muted = true,
            font = "GameFontNormalSmall",
            width = headerDefinition.width,
        })
        headerLabel:SetPoint("TOPLEFT", detailCard, "TOPLEFT", headerDefinition.x, -122)
    end

    local scroll = CreateModernScrollFrame(detailCard)
    scroll:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 14, -142)
    scroll:SetPoint("BOTTOMRIGHT", detailCard, "BOTTOMRIGHT", -16, 14)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(492)
    -- Genau so hoch wie die Zeilen brauchen. Vorher standen 560 fest im Code,
    -- also rund hundert Pixel Leerraum, in den man hineinscrollen konnte.
    content:SetHeight(#GC.GearSlots * 27)
    scroll:SetScrollChild(content)
    page.gearSlotScroll = scroll

    page.gearSlotRows = {}
    for index = 1, #GC.GearSlots do
        local row = CreateButton(content, "", 490, 25, function(_, mouseButton)
            local entry = page.gearSlotEntries and page.gearSlotEntries[index]
            if not entry then
                return
            end

            -- Rechtsklick nimmt den Slot aus der Wertung: Farmgear,
            -- Widerstandsteil, Encounter-Set. Das geht nur fuer die eigene
            -- Ausruestung - ueber fremde Slots entscheidet jeder selbst.
            if mouseButton == "RightButton" then
                local ownName = GC.Util.PlayerShortName(GC:GetPlayerFullName())
                if GC.Util.NormalizeName(GC.GearAudit.selectedName or "")
                    ~= GC.Util.NormalizeName(ownName) then
                    page:SetGearStatus(
                        "Ausnahmen setzt jeder für seine eigene Ausrüstung.", false)
                    return
                end
                local exempted, exemptMessage = GC.GearAudit:CycleSlotException(entry.key)
                page:SetGearStatus(exemptMessage, exempted)
                GC.UI:RefreshGear()
                return
            end

            -- Bewertet wird fuer die Spec des gerade gewaehlten Spielers.
            -- Ohne bekannte Spec faellt es auf die allgemeine Regel zurueck.
            local audit = GC.GearAudit:GetAudit(GC.GearAudit.selectedName)
            local ok, message = GC.GearAudit:CycleEnchantRule(
                entry.enchantID, entry.enchantName, audit and audit.specKey)
            page:SetGearStatus(message, ok)
            GC.UI:RefreshGear()
        end)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        SetTextureColor(row.background, index % 2 == 0 and THEME.input or THEME.card)
        row.border:Hide()
        row.label:Hide()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * 27))
        row.slot = CreateLabel(row, "", { width = 112, height = 25 })
        row.slot:SetPoint("LEFT", row, "LEFT", 5, 0)
        row.verdict = CreateLabel(row, "", { width = 96, height = 25 })
        row.verdict:SetPoint("LEFT", row, "LEFT", 121, 0)
        row.sockets = CreateLabel(row, "", { width = 58, height = 25 })
        row.sockets:SetPoint("LEFT", row, "LEFT", 221, 0)
        row.reason = CreateLabel(row, "", { width = 214, height = 25, muted = true })
        row.reason:SetPoint("LEFT", row, "LEFT", 283, 0)

        -- Der Hinweis passt selten in 214 Pixel. Abgeschnitten wird nur die
        -- Anzeige, im Tooltip steht er vollstaendig.
        row:HookScript("OnEnter", function(self)
            local entry = page.gearSlotEntries and page.gearSlotEntries[index]
            if not entry or not GameTooltip then
                return
            end
            AnchorRowTooltip(self)
            GameTooltip:SetText(entry.label or "")
            if entry.reason and entry.reason ~= "" then
                GameTooltip:AddLine(entry.reason, 1, 1, 1, true)
            end
            if (entry.emptySockets or 0) > 0 then
                GameTooltip:AddLine(entry.emptySockets .. " leere Sockel", 1, 0.38, 0.4, true)
            end
            GameTooltip:Show()
        end)
        row:HookScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        page.gearSlotRows[index] = row
    end
    page.gearRatingHint = CreateLabel(detailCard,
        -- Kein Pfeilzeichen: Die WoW-Schriftart kennt es nicht und zeichnet
        -- statt dessen leere Kaesten.
        "Linksklick bewertet: Optimal, Solide, Verbesserbar, keine Bewertung. "
            .. "Rechtsklick nimmt den eigenen Slot aus der Wertung.",
        { muted = true, font = "GameFontNormalSmall", width = 488, height = 16 })
    page.gearRatingHint:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -104)

    page.gearSlotEmpty = CreateLabel(detailCard, "Wähle links einen Spieler aus.", { muted = true, width = 400, height = 40, vertical = "TOP" })
    page.gearSlotEmpty:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -66)
end

function GC.UI:RefreshGear()
    local page = self.pages.GEAR
    if not page then
        return
    end

    local audits = GC.GearAudit:GetAudits()
    -- Zwei getrennte Quellen: die mitgelieferte Regelliste und die Regeln, die
    -- die Gilde selbst gepflegt hat. Die Statuszeile hat frueher nur die erste
    -- gezaehlt und deshalb auch dann "leer" gemeldet, wenn laengst gildeneigene
    -- Bewertungen vorlagen.
    local shippedRules = 0
    for _ in pairs(GC.EnchantRuleSet.rules) do
        shippedRules = shippedRules + 1
    end
    local guildRules = 0
    for _ in pairs(GC.DB:GetGuild().enchantRules or {}) do
        guildRules = guildRules + 1
    end
    local overview = GC.GearAudit:GetOverview()
    local statusText = GC.GearAudit.status
    if statusText == "" then
        statusText = overview.players > 0 and "Bereit." or "Noch keine Prüfung gelaufen."
    end
    if overview.players > 0 then
        statusText = statusText .. "  •  " .. overview.players .. " geprüft"
            .. ", davon " .. overview.clean .. " ohne Funde"
        if overview.missingEnchants > 0 then
            statusText = statusText .. "  •  |cffff6166" .. overview.missingEnchants
                .. " fehlende Verzauberungen|r"
        end
        if overview.emptySockets > 0 then
            statusText = statusText .. "  •  |cffff6166" .. overview.emptySockets .. " leere Sockel|r"
        end
        if overview.emptySlots > 0 then
            statusText = statusText .. "  •  |cffffb840" .. overview.emptySlots .. " leere Pflichtslots|r"
        end
        if overview.unreadableSlots > 0 then
            statusText = statusText .. "  •  |cffffb840" .. overview.unreadableSlots
                .. " noch nicht lesbare Slots|r"
        end
    end
    local ruleParts = {}
    if shippedRules > 0 then
        ruleParts[#ruleParts + 1] = "Regelsatz v" .. GC.EnchantRuleSet.version
            .. " mit " .. shippedRules .. " Verzauberungen"
    end
    if guildRules > 0 then
        ruleParts[#ruleParts + 1] = guildRules .. " gildeneigene "
            .. (guildRules == 1 and "Bewertung" or "Bewertungen")
    end

    local ruleLine
    if #ruleParts > 0 then
        ruleLine = GC.Util.JoinGerman(ruleParts) .. "."
        if GC.GearAudit:AcceptsUnratedEnchants() then
            ruleLine = ruleLine .. " Alles Übrige gilt automatisch als in Ordnung."
        end
    elseif GC.GearAudit:AcceptsUnratedEnchants() then
        ruleLine = "|cff7ac943Automatik aktiv:|r keine Bewertungen hinterlegt, deshalb gilt jede vorhandene"
            .. " Verzauberung als in Ordnung. Gemeldet werden fehlende Verzauberungen und leere Sockel."
    else
        ruleLine = "|cffffb840Der Regelsatz ist noch leer: fehlende Verzauberungen und leere Sockel werden"
            .. " exakt erkannt, vorhandene Verzauberungen bleiben \"Unbekannt\".|r"
    end
    page.gearStatus:SetText(statusText .. "\n" .. ruleLine)

    -- Rangfilter: Nur Mitglieder der angehakten Ränge bleiben in der Liste;
    -- der eigene Charakter steht immer drin. Wer nicht (mehr) im Roster
    -- auftaucht, fällt bei aktivem Filter heraus.
    local rankView = GC.GearAudit:GetRankView()
    if rankView.configured then
        local ownKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(GC:GetPlayerFullName()))
        local filtered = {}
        for _, audit in ipairs(audits) do
            local member = GC.Roster:GetMember(audit.name)
            local rankIndex = member and tonumber(member.rankIndex)
            if (rankIndex ~= nil and GC.GearAudit:IsRankShown(rankIndex))
                or GC.Util.NormalizeName(GC.Util.PlayerShortName(audit.name or "")) == ownKey then
                filtered[#filtered + 1] = audit
            end
        end
        audits = filtered
    end
    page.gearAuditList = audits

    local rankLabel = "Ränge: alle"
    if rankView.configured then
        local ranks = GC.Roster:GetRankDefinitions()
        local shownCount = 0
        for _, rank in ipairs(ranks) do
            if GC.GearAudit:IsRankShown(rank.index) then
                shownCount = shownCount + 1
            end
        end
        rankLabel = "Ränge: " .. shownCount .. " von " .. #ranks
    end
    page.gearRankButton:SetText(rankLabel)

    page.gearEmpty:SetShown(#audits == 0)
    local selectedName = GC.GearAudit.selectedName
    local selectedVisible = false
    for _, audit in ipairs(audits) do
        if audit.name == selectedName then
            selectedVisible = true
        end
    end
    if not selectedVisible then
        selectedName = audits[1] and audits[1].name
        GC.GearAudit.selectedName = selectedName
    end

    for index = 1, #audits do
        page:EnsureGearPlayerRow(index)
    end
    page.gearPlayerContent:SetHeight(math.max(1, #audits * 25))
    -- Kein automatisches Mitscrollen mehr: Wer einen Spieler anklickt, hat
    -- ihn bereits vor Augen - der Sprung riss die Liste nur unter der Hand
    -- weg (Owner-Rückmeldung).
    page.gearPlayerScroll:UpdateModernThumb()

    for index, row in ipairs(page.gearRows) do
        local audit = audits[index]
        row:SetShown(audit ~= nil)
        if audit then
            local issues = GC.GearAudit:GetIssueCount(audit)
            row:SetText(audit.name .. (issues > 0
            and ("  •  " .. issues .. (issues == 1 and " Fund" or " Funde"))
            or "  •  ok"))
            row:SetActive(audit.name == selectedName)
        end
    end

    local selected = GC.GearAudit:GetAudit(selectedName)
    page.gearSlotEmpty:SetShown(selected == nil)
    if selected then
        local ageMinutes = math.max(0, math.floor((GC.Util.Now() - (selected.inspectedAt or 0)) / 60))
        local sourceLabel = selected.source == "SELF" and "Eigene Ausrüstung"
            or selected.source == "SYNC" and "Addon-Abgleich"
            or "Inspect"
        page.gearHeadline:SetText(sourceLabel
            .. "  •  vor " .. ageMinutes .. " Min.  •  "
            .. (selected.specKey and GC.GearAudit:DescribeSpec(selected.specKey)
                or "|cffffb840Spec unbekannt|r"))
        page.gearFindings:SetText(self:FormatGearFindings(selected, 3))
    else
        page.gearHeadline:SetText("")
        page.gearFindings:SetText("")
    end

    local slots = selected and selected.slots or {}
    page.gearSlotEntries = slots
    page.gearRatingHint:SetShown(selected ~= nil and GC.GearAudit:CanEditEnchantRules())
    if selected and GC.GearAudit:CanEditEnchantRules() then
        page.gearRatingHint:SetText(selected.specKey
            and ("Klick auf eine Zeile bewertet für |cff4ec9ff"
                .. GC.GearAudit:DescribeSpec(selected.specKey)
                .. "|r: Optimal, Solide, Verbesserbar, keine Bewertung.")
            or "Spec unbekannt – ein Klick bewertet für alle Specs.")
    end
    for index, row in ipairs(page.gearSlotRows) do
        local entry = slots[index]
        row:SetShown(entry ~= nil)
        if entry then
            local style = GEAR_VERDICT_STYLE[entry.verdict] or GEAR_VERDICT_STYLE.UNKNOWN
            row.slot:SetText(entry.label)
            row.verdict:SetText(style.label)
            SetTextColor(row.verdict, style.color)
            local emptySockets = entry.emptySockets or 0
            row.sockets:SetText(emptySockets > 0 and ("|cffff6166" .. emptySockets .. " leer|r") or "–")
            row.reason:SetText(entry.reason or "")
        end
    end
end

-- Zustand des Gildenabgleichs in einem Satz neben der Version.
function GC.UI:RefreshSyncBadge()
    local badge = self.syncBadge
    if not badge then
        return
    end

    -- Dieselbe Zahl wie die Kachel "Mit Addon" in der Uebersicht: Sie zaehlt
    -- den eigenen Charakter mit. Zwei verschiedene Zahlen fuer dieselbe Sache
    -- auf einem Bildschirm sind schlimmer als eine unscharfe.
    local stats = GC.Sync:GetAddonUserStats()
    local known = stats.known or 1
    -- Gezaehlt werden Spieler, nicht Charaktere: drei Twinks desselben Spielers
    -- sind ein Nutzer. Die Charakterzahl steht nur daneben, wenn sie abweicht.
    local players = stats.players or known
    local differing = (stats.outdated or 0) + (stats.ahead or 0)
    local characterNote = known > players and (" (" .. known .. " Chars)") or ""

    if players <= 1 then
        badge:SetText("|cff8b98a5• kein anderer Nutzer erkannt|r")
    elseif differing > 0 then
        badge:SetText("|cffffb840• " .. players .. " Nutzer" .. characterNote .. ", "
            .. differing .. " mit anderer Version|r")
    else
        badge:SetText("|cff59e695• " .. players .. " Nutzer" .. characterNote
            .. ", alle synchron|r")
    end
end

-- === Seiten nur zeichnen, wenn sie jemand sieht ==========================
--
-- Bis 0.9.41 baute jeder Aufruf alle dreizehn Seiten neu auf - bei jedem Ein-
-- und Ausloggen eines Gildenmitglieds, bei jedem eingehenden Profil, und auch
-- bei geschlossenem Fenster. Genau daraus entstanden die gemeldeten Ruckler
-- zur Prime Time; mit der Synchronisation selbst hatte das nichts zu tun.
--
-- Gezeichnet wird jetzt nur die sichtbare Seite. Die uebrigen merken sich, dass
-- sie veraltet sind, und holen es beim Aufschlagen nach. Die Daten liegen
-- ohnehin in der Datenbank - verloren geht nichts, nur der Neuaufbau wartet.
local PAGE_REFRESH = {
    OVERVIEW = "RefreshDashboard",
    SETTINGS = "RefreshSettings",
    ROSTER = "RefreshRoster",
    MEMBERCARE = "RefreshMemberCare",
    WORKSHOP = "RefreshWorkshop",
    SUGGESTIONS = "RefreshSuggestions",
    RECRUITMENT = "RefreshRecruitment",
    POST = "RefreshPost",
    INBOX = "RefreshInbox",
    GUILD = "RefreshGuild",
    WCL = "RefreshWarcraftLogs",
    STATISTICS = "RefreshStatistics",
    GEAR = "RefreshGear",
}

function GC.UI:IsVisible()
    return self.frame ~= nil and self.frame:IsShown() == true
end

function GC.UI:RefreshPage(pageKey)
    local method = PAGE_REFRESH[pageKey]
    if not method or not self.frame then
        return
    end
    self.stalePages = self.stalePages or {}
    self.stalePages[pageKey] = nil
    GC.Perf:Measure("Seite " .. pageKey, self[method], self)
end

-- Eine Seite gilt als veraltet. Ist sie gerade zu sehen, wird sie kurz darauf
-- neu gezeichnet, sonst beim naechsten Aufschlagen.
--
-- "Kurz darauf" statt sofort: Invalidate wird ausschliesslich von
-- Datenaenderungen gerufen, nie von Klicks - und Daten kommen in Schueben.
-- Ein Gildenabgleich zur Prime Time liefert mehrere Pakete pro Sekunde, und
-- jedes zeichnete die offene Seite komplett neu. Jetzt sammelt ein kurzer
-- Timer den Schub ein und zeichnet einmal. Klicks gehen weiter ueber
-- ShowPage/RefreshPage und bleiben unmittelbar.
local REPAINT_DELAY = 0.25

function GC.UI:Invalidate(...)
    if not self.frame then
        return
    end
    self.stalePages = self.stalePages or {}
    local repaint = false
    for index = 1, select("#", ...) do
        local pageKey = select(index, ...)
        if PAGE_REFRESH[pageKey] then
            self.stalePages[pageKey] = true
            if pageKey == self.activePage and self:IsVisible() then
                repaint = true
            end
        end
    end
    if not repaint or self.repaintPending then
        return
    end
    if not C_Timer or type(C_Timer.After) ~= "function" then
        self:RefreshPage(self.activePage)
        return
    end
    self.repaintPending = true
    C_Timer.After(REPAINT_DELAY, function()
        GC.UI.repaintPending = false
        -- Inzwischen kann die Seite gewechselt oder das Fenster zu sein.
        -- RefreshPage raeumt den Veraltet-Merker der gezeichneten Seite ab;
        -- eine nicht mehr aktive Seite behaelt ihren und wird beim naechsten
        -- Aufschlagen nachgeholt.
        local active = GC.UI.activePage
        if GC.UI:IsVisible() and GC.UI.stalePages and GC.UI.stalePages[active] then
            GC.UI:RefreshPage(active)
        end
    end)
end

function GC.UI:Refresh()
    if not self.frame then
        return
    end
    self.stalePages = self.stalePages or {}
    for pageKey in pairs(PAGE_REFRESH) do
        self.stalePages[pageKey] = true
    end
    if not self:IsVisible() then
        -- Bei geschlossenem Fenster gibt es nichts zu zeichnen. Der
        -- Werbebalken haengt nicht daran, er frischt sich selbst auf.
        return
    end
    self:RefreshSyncBadge()
    self:RefreshNavigationAccess()
    self:RefreshPage(self.activePage)
end

-- === Werbebalken ===========================================================
--
-- Kleines, verschiebbares Fenster nur fuer das Posten: bestaetigter Text,
-- Countdown je Kanal und ein Knopf. Gesendet wird ausschliesslich durch einen
-- echten Klick - der Countdown schaltet den Knopf nur frei, er loest nie
-- selbst aus.

function GC.UI:CreatePostBar()
    if self.postBar then
        return self.postBar
    end

    local bar = CreatePanel(UIParent, THEME.window, THEME.accent, "GuildCopilotPostBar")
    -- Hoch genug fuer den vollstaendigen Werbetext: 255 Bytes brauchen bei
    -- 306 Pixel Breite bis zu fuenf Zeilen. Darunter Statuszeile und Knopf,
    -- die sich frueher ueberlappt haben.
    bar:SetSize(330, 162)
    local settings = GC.DB:GetSettings().postBar
    bar:SetPoint("CENTER", UIParent, "CENTER", tonumber(settings.x) or 0, tonumber(settings.y) or -220)
    bar:SetClampedToScreen(true)
    bar:SetMovable(true)
    bar:EnableMouse(true)
    bar:RegisterForDrag("LeftButton")
    bar:SetScript("OnDragStart", bar.StartMoving)
    bar:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        if point then
            GC.DB:GetSettings().postBar.x = math.floor(tonumber(x) or 0)
            GC.DB:GetSettings().postBar.y = math.floor(tonumber(y) or 0)
        end
    end)
    bar:SetFrameStrata("MEDIUM")
    bar:Hide()

    local title = CreateLabel(bar, "Gildenwerbung", { font = "GameFontNormalSmall" })
    title:SetPoint("TOPLEFT", bar, "TOPLEFT", 12, -9)

    local close = CreateButton(bar, "×", 20, 20, function()
        GC.UI:SetPostBarShown(false)
    end)
    close:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -8, -7)

    bar.text = CreateLabel(bar, "", { muted = true, width = 306, height = 70, vertical = "TOP" })
    bar.text:SetPoint("TOPLEFT", bar, "TOPLEFT", 12, -28)

    bar.status = CreateLabel(bar, "", { font = "GameFontNormalSmall", width = 306, height = 14 })
    bar.status:SetPoint("TOPLEFT", bar, "TOPLEFT", 12, -102)

    bar.sendButton = CreateButton(bar, "Suche starten", 306, 26, function()
        local recruitment = GC.DB:GetGuild().recruitment
        local success, message = GC.Chat:StartSearch(recruitment.confirmedText or "")
        bar.status:SetText(message or "")
        SetTextColor(bar.status, success and THEME.success or THEME.danger)
        GC.UI:RefreshPostBar()
        GC.UI:RefreshPost()
    end, "PRIMARY")
    bar.sendButton:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 12, 10)

    bar:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.5 then
            self.elapsed = 0
            GC.UI:RefreshPostBar()
        end
    end)

    self.postBar = bar
    self:RefreshPostBar()
    return bar
end

function GC.UI:SetPostBarShown(shown)
    GC.DB:GetSettings().postBar.hidden = not shown
    self:CreatePostBar()
    self.postBar:SetShown(shown == true)
    if shown then
        self:RefreshPostBar()
    end
    self:RefreshPost()
end

function GC.UI:TogglePostBar()
    self:SetPostBarShown(GC.DB:GetSettings().postBar.hidden ~= false)
end

function GC.UI:RefreshPostBar()
    local bar = self.postBar
    if not bar or not bar:IsShown() then
        return
    end

    local recruitment = GC.DB:GetGuild().recruitment
    local confirmed = recruitment.confirmedText or ""
    if confirmed == "" then
        bar.text:SetText("|cffffb840Kein bestätigter Text. Unter „Werbung posten“ bestätigen.|r")
    else
        -- Voller Text statt 110 Bytes: Was hier steht, geht so in den Chat.
        bar.text:SetText(GC.Util.SafeChatText(confirmed, GC.Constants.MAX_CHAT_BYTES))
    end

    -- Ein Kanal ist bereit, wenn er ausgewählt, beigetreten und ohne Cooldown
    -- ist. Der laengste Cooldown steht als Countdown im Knopf.
    local ready = 0
    local waiting = 0
    local longest = 0
    for _, kind in ipairs({ "RECRUITMENT", "LFG", "TRADE", "GENERAL" }) do
        if GC.DB:GetSettings().channels[kind] then
            local remaining = GC.Chat:GetRemainingCooldown(kind)
            if remaining > 0 then
                waiting = waiting + 1
                longest = math.max(longest, remaining)
            elseif GC.Chat:FindChannel(kind) then
                ready = ready + 1
            end
        end
    end

    local canSend = confirmed ~= "" and ready > 0
    SetButtonEnabled(bar.sendButton, canSend)
    if longest > 0 and ready == 0 then
        bar.sendButton:SetText(math.ceil(longest) .. "s Cooldown")
    else
        bar.sendButton:SetText("Suche starten")
    end
    if bar.status:GetText() == "" or waiting > 0 or ready > 0 then
        bar.status:SetText(ready .. " Kanäle bereit"
            .. (waiting > 0 and ("  •  " .. waiting .. " im Cooldown") or ""))
        SetTextColor(bar.status, ready > 0 and THEME.muted or THEME.warning)
    end
end

local function MinimapAngle(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    elseif x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + math.pi
    elseif x < 0 then
        return math.atan(y / x) - math.pi
    elseif y > 0 then
        return math.pi / 2
    elseif y < 0 then
        return -math.pi / 2
    end
    return 0
end

-- Ab diesem Abstand zur Minimapmitte loest sich das Symbol vom Ring und steht
-- frei. Der Ring selbst liegt bei 78; der Abstand ist bewusst deutlich groesser,
-- damit ein Verrutschen beim Ziehen am Ring es nicht versehentlich abloest.
local MINIMAP_FREE_DISTANCE = 130

-- Alles in UIParent-Einheiten rechnen. GetCursorPosition liefert
-- Bildschirmpixel, GetCenter dagegen Koordinaten im Massstab des jeweiligen
-- Rahmens - und Minimap und UIParent koennen verschieden skaliert sein. Wer
-- beides ungerechnet vergleicht, misst Unsinn.
local function UIScale()
    return (UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale()) or 1
end

local function CursorInUISpace()
    if type(GetCursorPosition) ~= "function" then
        return nil, nil
    end
    local cursorX, cursorY = GetCursorPosition()
    if not cursorX or not cursorY then
        return nil, nil
    end
    local scale = UIScale()
    return cursorX / scale, cursorY / scale
end

local function MinimapCenterInUISpace()
    if not Minimap or type(Minimap.GetCenter) ~= "function" then
        return nil, nil
    end
    local centerX, centerY = Minimap:GetCenter()
    if not centerX or not centerY then
        return nil, nil
    end
    local minimapScale = (Minimap.GetEffectiveScale and Minimap:GetEffectiveScale()) or 1
    local scale = UIScale()
    return centerX * minimapScale / scale, centerY * minimapScale / scale
end

-- Ring und dunkler Untergrund gehoeren zur Minimap-Optik. Frei platziert sah
-- der offene Goldring wie ein grosses "C" aus (Owner-Screenshot); dort zeigt
-- der Knopf nur noch das Wappen, etwas groesser und mittig.
local function ApplyMinimapButtonChrome(button, free)
    button.border:SetShown(not free)
    button.background:SetShown(not free)
    button.icon:ClearAllPoints()
    if free then
        button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.icon:SetSize(28, 28)
    else
        button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -6)
        button.icon:SetSize(17, 17)
    end
end

function GC.UI:PositionMinimapButton()
    local button = self.minimapButton
    if not button then
        return
    end
    local settings = GC.DB:GetSettings().minimap
    button:ClearAllPoints()
    ApplyMinimapButtonChrome(button, settings.free == true)

    -- Frei gesetzt haengt das Symbol an UIParent, nicht mehr an der Minimap:
    -- Sonst gelten die gespeicherten Koordinaten im Massstab der Minimap und
    -- das Symbol landet bei abweichender Skalierung woanders.
    if settings.free and UIParent then
        if button:GetParent() ~= UIParent then
            button:SetParent(UIParent)
            button:SetFrameStrata("MEDIUM")
        end
        button:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
            tonumber(settings.x) or 0, tonumber(settings.y) or 0)
        return
    end

    if not Minimap then
        return
    end
    if button:GetParent() ~= Minimap then
        button:SetParent(Minimap)
        button:SetFrameStrata("MEDIUM")
    end
    local angle = math.rad(tonumber(settings.angle) or 225)
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * 78, math.sin(angle) * 78)
end

-- Rueckweg, falls das Symbol irgendwo landet, wo es nicht mehr zu greifen ist.
function GC.UI:ResetMinimapButton()
    local settings = GC.DB:GetSettings().minimap
    settings.free = false
    settings.angle = 225
    settings.x = 0
    settings.y = 0
    self:PositionMinimapButton()
end

function GC.UI:RefreshMinimapButton()
    if not self.minimapButton then
        return
    end
    self:PositionMinimapButton()
    self.minimapButton:SetShown(not GC.DB:GetSettings().minimap.hidden)
end

function GC.UI:AddMinimapButton()
    if self.minimapButton or not Minimap then
        return
    end

    local button = CreateFrame("Button", "GuildCopilotMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    button.background = background

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -6)
    icon:SetTexture("Interface\\AddOns\\GuildCopilot\\Media\\GuildCopilotLogo")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border = border
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Solange die Einrichtung offen ist, sitzt ein Punkt am Symbol. Er ist das
    -- einzige Zeichen bei geschlossenem Fenster - ohne ihn merkt niemand, dass
    -- noch etwas aussteht, sobald das Willkommensfenster einmal weg ist. Er
    -- verschwindet von selbst und wiederholt sich nie im Chat.
    local pending = button:CreateTexture(nil, "OVERLAY", nil, 7)
    pending:SetSize(9, 9)
    pending:SetPoint("TOPRIGHT", button, "TOPRIGHT", -6, -4)
    pending:SetTexture(WHITE_TEXTURE)
    SetTextureColor(pending, THEME.accent)
    pending:Hide()
    button.pending = pending

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            GC.UI:CreateMainFrame()
            GC.UI.frame:Show()
            GC.UI:ShowPage("SETTINGS")
        else
            GC.UI:Toggle()
        end
    end)
    button:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Guild Copilot")
        local nextStep = GC.Onboarding:GetNextStep()
        if nextStep then
            GameTooltip:AddLine("Einrichtung offen: " .. nextStep, 0.18, 0.78, 0.86, true)
            GameTooltip:AddLine(" ")
        end
        GameTooltip:AddLine("Linksklick: öffnen/schließen", 1, 1, 1)
        GameTooltip:AddLine("Rechtsklick: Einstellungen", 1, 1, 1)
        GameTooltip:AddLine("Ziehen: am Ring entlang, weiter weg frei platzieren", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    -- Ziehen: Nah an der Minimap faehrt das Symbol wie gewohnt auf dem Ring,
    -- weit genug weggezogen loest es sich und steht frei auf dem Bildschirm.
    -- So braucht es keinen Schalter - die Bewegung selbst sagt, was gemeint ist.
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local cursorX, cursorY = CursorInUISpace()
            if not cursorX or not cursorY then
                return
            end
            local settings = GC.DB:GetSettings().minimap
            local centerX, centerY = MinimapCenterInUISpace()
            if centerX and centerY then
                local offsetX = cursorX - centerX
                local offsetY = cursorY - centerY
                if math.sqrt((offsetX * offsetX) + (offsetY * offsetY)) <= MINIMAP_FREE_DISTANCE then
                    settings.free = false
                    settings.angle = math.deg(MinimapAngle(offsetY, offsetX))
                    GC.UI:PositionMinimapButton()
                    return
                end
            end
            settings.free = true
            settings.x = math.floor(cursorX)
            settings.y = math.floor(cursorY)
            GC.UI:PositionMinimapButton()
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    self.minimapButton = button
    self:RefreshMinimapButton()
    self:RefreshMinimapMarker()
end

-- Die Slash-Befehle an genau einer Stelle. Daraus entstehen die Ausgabe von
-- "/gcp help" und die Liste auf der Addon-Optionsseite: Zwei getrennte
-- Aufzaehlungen laufen auseinander, sobald ein Befehl dazukommt - und die
-- Liste, die niemand pflegt, ist dann die falsche.
-- === Sitzungsfrage beim Instanzbeitritt =====================================
-- Wer eine Raidinstanz betritt und Sitzungen steuern darf, wird gefragt, ob
-- die Auswertung mitlaufen soll (Owner-Wunsch). Ein kleines Fenster, keine
-- Automatik: Gestartet wird nur per Klick.

function GC.UI:ShowSessionPrompt(zoneName)
    if not self.sessionPrompt then
        local prompt = CreatePanel(UIParent, THEME.window, THEME.accent, "GuildCopilotSessionPrompt")
        prompt:SetSize(420, 124)
        prompt:SetPoint("TOP", UIParent, "TOP", 0, -180)
        prompt:SetFrameStrata("DIALOG")
        prompt:SetClampedToScreen(true)
        prompt:SetMovable(true)
        prompt:EnableMouse(true)
        prompt:RegisterForDrag("LeftButton")
        prompt:SetScript("OnDragStart", prompt.StartMoving)
        prompt:SetScript("OnDragStop", prompt.StopMovingOrSizing)
        prompt.title = CreateLabel(prompt, "Raidinstanz betreten", { title = true, width = 320 })
        prompt.title:SetPoint("TOPLEFT", prompt, "TOPLEFT", 16, -12)
        prompt.closeX = CreateButton(prompt, "×", 22, 22, function()
            prompt:Hide()
        end)
        prompt.closeX:SetPoint("TOPRIGHT", prompt, "TOPRIGHT", -8, -8)
        prompt.text = CreateLabel(prompt, "", { muted = true, width = 388, height = 30, vertical = "TOP" })
        prompt.text:SetPoint("TOPLEFT", prompt, "TOPLEFT", 16, -38)
        prompt.startButton = CreateButton(prompt, "Sitzung starten", 150, 30, function()
            local ok, message = GC.RaidMonitor:BeginSession()
            GC:Print(message)
            prompt:Hide()
            if ok then
                GC.UI:Invalidate("STATISTICS")
            end
        end, "PRIMARY")
        prompt.startButton:SetPoint("BOTTOMLEFT", prompt, "BOTTOMLEFT", 16, 12)
        prompt.gearButton = CreateButton(prompt, "Gruppe prüfen", 140, 30, function()
            local ok, message = GC.GearAudit:StartRaidScan()
            GC.UI:ShowGroupGearCheck()
            local frame = GC.UI.groupGearCheck
            if frame then
                frame.status:SetText(message or "")
                SetTextColor(frame.status, ok and THEME.success or THEME.danger)
            end
        end)
        prompt.gearButton:SetPoint("LEFT", prompt.startButton, "RIGHT", 8, 0)
        prompt.dismissButton = CreateButton(prompt, "Nicht jetzt", 100, 30, function()
            prompt:Hide()
        end)
        prompt.dismissButton:SetPoint("BOTTOMRIGHT", prompt, "BOTTOMRIGHT", -16, 12)
        prompt:Hide()
        self.sessionPrompt = prompt
    end
    self.sessionPrompt.text:SetText(GC.Util.Trim(zoneName or "") ~= ""
        and ("Du bist in „" .. zoneName .. "“. Auswertung mitschreiben? Ausrüstung checken?")
        or "Du hast eine Raidinstanz betreten. Auswertung mitschreiben? Ausrüstung checken?")
    self.sessionPrompt:Show()
end

GC:RegisterCallback("RAID_SESSION_PROMPT", GC.UI, function(self, zoneName)
    self:ShowSessionPrompt(zoneName)
end)

-- Startet jemand anderes die Sitzung, ist die Frage beantwortet.
GC:RegisterCallback("RAID_SESSION_UPDATED", GC.UI, function(self)
    if self.sessionPrompt and self.sessionPrompt:IsShown() and GC.RaidMonitor.session then
        self.sessionPrompt:Hide()
    end
end)

-- === Gruppenprüfung Ausrüstung ==============================================
-- "Gruppe prüfen" zeigt die AKTUELLE Gruppe in einem eigenen Fenster
-- (Owner-Wunsch): nur die Leute von jetzt, je Zeile der Befund - statt der
-- großen Dauerliste aller je geprüften Spieler auf der Seite.

local GEAR_SOURCE_LABELS = { INSPECT = "Inspect", SYNC = "Addon", SELF = "Eigene Daten" }

function GC.UI:CreateGroupGearFrame()
    if self.groupGearCheck then
        return self.groupGearCheck
    end
    local frame = CreatePanel(UIParent, THEME.window, THEME.accent, "GuildCopilotGroupGearCheck")
    frame:SetSize(520, 458)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    -- Wie das Hauptfenster: Der letzte Klick holt das Fenster nach vorn.
    -- Ohne dieses Flag läge es nach einem Klick ins Addon dauerhaft dahinter.
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.title = CreateLabel(frame, "Gruppenprüfung – Ausrüstung", { title = true, width = 340 })
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -14)
    frame.subtitle = CreateLabel(frame, "", { muted = true, width = 470, height = 26, vertical = "TOP" })
    frame.subtitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -36)
    frame.closeX = CreateButton(frame, "×", 24, 24, function()
        frame:Hide()
    end)
    frame.closeX:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)

    frame.headName = CreateLabel(frame, "NAME", { muted = true, font = "GameFontNormalSmall", width = 120, height = 14 })
    frame.headName:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -68)
    frame.headStand = CreateLabel(frame, "STAND", { muted = true, font = "GameFontNormalSmall", width = 90, height = 14 })
    frame.headStand:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, -68)
    frame.headBefund = CreateLabel(frame, "BEFUND", { muted = true, font = "GameFontNormalSmall", width = 240, height = 14 })
    frame.headBefund:SetPoint("TOPLEFT", frame, "TOPLEFT", 252, -68)

    local body = CreatePanel(frame, THEME.input)
    body:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -86)
    body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 78)
    frame.scroll = CreateModernScrollFrame(body)
    frame.scroll:SetPoint("TOPLEFT", body, "TOPLEFT", 6, -6)
    frame.scroll:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -10, 6)
    frame.content = CreateFrame("Frame", nil, frame.scroll)
    frame.content:SetWidth(470)
    frame.content:SetHeight(280)
    frame.scroll:SetScrollChild(frame.content)

    frame.rows = {}
    for index = 1, 40 do
        local row = CreateFrame("Frame", nil, frame.content)
        row:SetSize(470, 24)
        row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -((index - 1) * 26))
        row.name = CreateLabel(row, "", { width = 126, height = 24 })
        row.name:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.stand = CreateLabel(row, "", { muted = true, width = 96, height = 24 })
        row.stand:SetPoint("LEFT", row, "LEFT", 134, 0)
        row.befund = CreateLabel(row, "", { width = 230, height = 24 })
        row.befund:SetPoint("LEFT", row, "LEFT", 236, 0)
        -- In der Gruppenliste öffnet ein Klick die Verzauberungs-Details des
        -- Spielers; in der Detailansicht sind die Zeilen nur Anzeige.
        row:EnableMouse(true)
        row:SetScript("OnMouseUp", function()
            if row.auditName then
                GC.UI:SelectGroupGearPlayer(row.auditName)
            end
        end)
        row:Hide()
        frame.rows[index] = row
    end

    frame.counts = CreateLabel(frame, "", { width = 490, height = 18 })
    frame.counts:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 52)
    frame.rescan = CreateButton(frame, "Erneut prüfen", 130, 30, function()
        local ok, message = GC.GearAudit:StartRaidScan()
        frame.status:SetText(message or "")
        SetTextColor(frame.status, ok and THEME.success or THEME.danger)
        GC.UI:RefreshGroupGearCheck()
    end, "PRIMARY")
    frame.rescan:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 14, 12)
    -- Kein Pfeilzeichen: "←" fehlt in der WoW-Schrift und wird als Kästchen
    -- gezeichnet.
    frame.back = CreateButton(frame, "Zur Gruppe", 130, 30, function()
        frame.detailName = nil
        GC.UI:RefreshGroupGearCheck()
    end)
    frame.back:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 14, 12)
    frame.back:Hide()
    frame.status = CreateLabel(frame, "", { muted = true, width = 230, height = 30, vertical = "TOP" })
    frame.status:SetPoint("LEFT", frame.rescan, "RIGHT", 10, 0)
    frame.closeButton = CreateButton(frame, "Schließen", 110, 30, function()
        frame:Hide()
    end)
    frame.closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 12)

    frame:Hide()
    self.groupGearCheck = frame
    return frame
end

function GC.UI:ShowGroupGearCheck()
    local frame = self:CreateGroupGearFrame()
    frame.detailName = nil
    frame:Show()
    -- Vor das Addonfenster legen: gleiche Ebene, aber zuletzt gezeigt.
    if frame.Raise then
        frame:Raise()
    end
    self:RefreshGroupGearCheck()
end

-- Klick auf einen Spieler in der Gruppenliste: Detailansicht mit allen
-- Slots, Verzauberungen und Sockeln dieses Spielers.
function GC.UI:SelectGroupGearPlayer(name)
    local frame = self.groupGearCheck
    if not frame or not GC.GearAudit:GetAudit(name) then
        return
    end
    frame.detailName = name
    self:RefreshGroupGearCheck()
end

function GC.UI:RefreshGroupGearCheck()
    local frame = self.groupGearCheck
    if not frame or not frame:IsShown() then
        return
    end
    local now = GC.Util.Now()

    -- Detailansicht: alle Slots eines Spielers mit Bewertung, Verzauberung
    -- und Sockeln - dieselben Daten wie auf der Ausrüstungsseite, nur direkt
    -- im Gruppenfenster.
    local detail = frame.detailName and GC.GearAudit:GetAudit(frame.detailName)
    frame.back:SetShown(detail ~= nil)
    frame.rescan:SetShown(detail == nil)
    if detail then
        frame.subtitle:SetText("„Zur Gruppe“ führt zurück zur Übersicht.")
        frame.headName:SetText("SLOT")
        frame.headStand:SetText("BEWERTUNG")
        frame.headBefund:SetText("VERZAUBERUNG & SOCKEL")
        local slots = detail.slots or {}
        for index, row in ipairs(frame.rows) do
            local entry = slots[index]
            row:SetShown(entry ~= nil)
            row.auditName = nil
            if entry then
                row.name:SetText(entry.label or entry.key or "?")
                row.name:SetTextColor(THEME.text[1], THEME.text[2], THEME.text[3], 1)
                local style = entry.verdict == "EXEMPT"
                    and { label = "Ausnahme", color = THEME.muted }
                    or GEAR_VERDICT_STYLE[entry.verdict] or GEAR_VERDICT_STYLE.UNKNOWN
                row.stand:SetText(style.label)
                SetTextColor(row.stand, style.color)
                local text = GC.Util.Trim(entry.enchantName or "")
                if text == "" then
                    text = GC.Util.Trim(entry.reason or "")
                end
                if (entry.emptySockets or 0) > 0 then
                    text = text .. " |cffff6166· " .. entry.emptySockets .. " Sockel leer|r"
                end
                if GC.Util.Trim(text) == "" then
                    text = "–"
                end
                row.befund:SetText(text)
                if entry.verdict == "MISSING" then
                    SetTextColor(row.befund, THEME.danger)
                elseif entry.verdict == "OPTIMAL" then
                    SetTextColor(row.befund, THEME.success)
                else
                    SetTextColor(row.befund, THEME.text)
                end
            end
        end
        local age = math.max(0, math.floor((now - (detail.inspectedAt or now)) / 60))
        -- Kurzform, sonst schneidet die Fußzeile ab: "keine Funde" statt des
        -- ganzen Satzes aus DescribeFindings.
        local findingsText = GC.GearAudit:GetIssueCount(detail) > 0
            and GC.GearAudit:DescribeFindings(detail) or "keine Funde"
        frame.counts:SetText("|cff4ec9ff" .. GC.Util.PlayerShortName(detail.name or "")
            .. "|r · " .. (GEAR_SOURCE_LABELS[detail.source] or "Daten")
            .. " vor " .. age .. " Min. · " .. findingsText)
        frame.content:SetHeight(math.max(280, #slots * 26))
        frame.scroll:UpdateModernThumb()
        return
    end

    frame.subtitle:SetText("Nur die aktuelle Gruppe. Addon-Nutzer liefern selbst, der Rest per "
        .. "Inspect in Reichweite. Klick auf eine Zeile zeigt die Verzauberungen.")
    frame.headName:SetText("NAME")
    frame.headStand:SetText("STAND")
    frame.headBefund:SetText("BEFUND")
    local ok, findings, missing = 0, 0, 0
    local entries = {}
    -- Dieselbe Gruppenliste wie der Versionsprüfer; solo steht man allein drin.
    local targets = self:GetVersionCheckTargets("GROUP")
    if #targets == 0 then
        targets = { { name = GC:GetPlayerFullName() } }
    end
    for _, target in ipairs(targets) do
        local audit = GC.GearAudit:GetAudit(target.name)
        local entry = { name = target.name, classFile = target.classFile }
        if audit then
            local age = math.max(0, math.floor((now - (audit.inspectedAt or now)) / 60))
            entry.stand = (GEAR_SOURCE_LABELS[audit.source] or "Daten")
                .. " · vor " .. age .. " Min."
            local issues = GC.GearAudit:GetIssueCount(audit)
            if issues > 0 then
                entry.befund = GC.GearAudit:DescribeFindings(audit)
                entry.state = "FINDINGS"
                findings = findings + 1
            else
                entry.befund = "ok"
                entry.state = "OK"
                ok = ok + 1
            end
        else
            entry.stand = "–"
            entry.befund = "keine Daten (kein Addon / außer Reichweite)"
            entry.state = "NONE"
            missing = missing + 1
        end
        entries[#entries + 1] = entry
    end
    local ORDER = { FINDINGS = 1, NONE = 2, OK = 3 }
    table.sort(entries, function(left, right)
        if ORDER[left.state] ~= ORDER[right.state] then
            return ORDER[left.state] < ORDER[right.state]
        end
        return tostring(left.name) < tostring(right.name)
    end)
    for index, row in ipairs(frame.rows) do
        local entry = entries[index]
        row:SetShown(entry ~= nil)
        row.auditName = nil
        if entry then
            row.name:SetText(GC.Util.PlayerShortName(entry.name))
            row.name:SetTextColor(ClassColor(entry.classFile))
            row.stand:SetText(entry.stand)
            row.befund:SetText(entry.befund)
            if entry.state ~= "NONE" then
                row.auditName = entry.name
            end
            if entry.state == "OK" then
                SetTextColor(row.befund, THEME.success)
            elseif entry.state == "FINDINGS" then
                SetTextColor(row.befund, THEME.danger)
            else
                SetTextColor(row.befund, THEME.muted)
            end
        end
    end
    frame.counts:SetText("|cff59e695" .. ok .. " ok|r · |cffff6266" .. findings
        .. " mit Funden|r · " .. missing .. " ohne Daten")
    frame.content:SetHeight(math.max(280, #entries * 26))
    frame.scroll:UpdateModernThumb()
end

-- === Auswertungsfenster =====================================================
-- Ein Raidabend im eigenen Fenster: jede Quelle (Live, Warcraft Logs,
-- Combat Log) einzeln ansehen oder zwei Quellen direkt gegenüberstellen.
-- Der Vergleich zeigt je Spieler zwei Zeilen - oben die erste Quelle, unten
-- die zweite - und färbt Werte gelb, wo die Quellen sich widersprechen.

local REVIEW_COLS = {
    { key = "time",  head = "TIME",  x = 166, w = 56 },
    { key = "death", head = "DEATH", x = 226, w = 48 },
    { key = "res",   head = "RES",   x = 278, w = 40 },
    { key = "int",   head = "INT",   x = 322, w = 40 },
    { key = "disp",  head = "DISP",  x = 366, w = 44 },
    { key = "pot",   head = "POT",   x = 414, w = 40 },
    { key = "flask", head = "FLASK", x = 458, w = 48 },
    { key = "elix",  head = "ELIX",  x = 510, w = 44 },
    { key = "food",  head = "FOOD",  x = 558, w = 44 },
    { key = "drum",  head = "DRUM",  x = 606, w = 46 },
}

-- Rohwerte eines Teilnehmers je Spalte. TIME vergleicht auf Minutenbasis,
-- sonst gälte jede Sekunde Abweichung als Widerspruch.
local function ReviewValues(participant)
    local consumables = (participant and participant.consumables) or {}
    return {
        time = math.floor(((participant and participant.seconds) or 0) / 60),
        death = (participant and participant.deaths) or 0,
        res = (participant and participant.resurrects) or 0,
        int = (participant and participant.interrupts) or 0,
        disp = (participant and participant.dispels) or 0,
        pot = (consumables.POTION or 0) + (consumables.RUNE or 0),
        flask = consumables.FLASK or 0,
        elix = consumables.ELIXIR or 0,
        food = consumables.FOOD or 0,
        drum = consumables.DRUM or 0,
    }
end

local function ReviewCellText(key, values)
    if key == "time" then
        return values.time .. "m"
    end
    return tostring(values[key] or 0)
end

function GC.UI:CreateSessionReviewFrame()
    if self.sessionReview then
        return self.sessionReview
    end
    local frame = CreatePanel(UIParent, THEME.window, THEME.accent, "GuildCopilotSessionReview")
    frame:SetSize(720, 540)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.title = CreateLabel(frame, "Raidauswertung – Detail", { title = true, width = 400 })
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -14)
    frame.closeX = CreateButton(frame, "×", 24, 24, function()
        frame:Hide()
    end)
    frame.closeX:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    frame.headline = CreateLabel(frame, "", { muted = true, width = 688, height = 16 })
    frame.headline:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -40)

    frame.sourceButtons = {}
    for index = 1, 3 do
        local button = CreateButton(frame, "", 150, 24, function()
            local target = frame.sourceButtons[index].summaryID
            if target then
                frame.selectedID = target
                frame.compare = false
                GC.UI:RefreshSessionReview()
            end
        end)
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", 14 + ((index - 1) * 156), -62)
        button:Hide()
        frame.sourceButtons[index] = button
    end
    frame.compareButton = CreateButton(frame, "Vergleich", 150, 24, function()
        frame.compare = not frame.compare
        GC.UI:RefreshSessionReview()
    end)
    frame.compareButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 14 + (3 * 156), -62)
    frame.compareButton:Hide()

    CreateLabel(frame, "NAME", { muted = true, font = "GameFontNormalSmall", width = 140, height = 14 })
        :SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -98)
    for _, col in ipairs(REVIEW_COLS) do
        CreateLabel(frame, col.head, { muted = true, font = "GameFontNormalSmall", width = col.w, height = 14 })
            :SetPoint("TOPLEFT", frame, "TOPLEFT", 14 + col.x, -98)
    end

    local body = CreatePanel(frame, THEME.input)
    body:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -114)
    body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 46)
    frame.scroll = CreateModernScrollFrame(body)
    frame.scroll:SetPoint("TOPLEFT", body, "TOPLEFT", 6, -6)
    frame.scroll:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -10, 6)
    frame.content = CreateFrame("Frame", nil, frame.scroll)
    frame.content:SetWidth(660)
    frame.content:SetHeight(360)
    frame.scroll:SetScrollChild(frame.content)

    frame.rows = {}
    for index = 1, 64 do
        local row = CreateFrame("Frame", nil, frame.content)
        row:SetSize(660, 18)
        row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -((index - 1) * 20))
        row.name = CreateLabel(row, "", { width = 152, height = 18 })
        row.name:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.cells = {}
        for _, col in ipairs(REVIEW_COLS) do
            local cell = CreateLabel(row, "", { width = col.w, height = 18 })
            cell:SetPoint("LEFT", row, "LEFT", col.x, 0)
            row.cells[col.key] = cell
        end
        row:Hide()
        frame.rows[index] = row
    end

    frame.note = CreateLabel(frame, "", { muted = true, width = 540, height = 26, vertical = "TOP" })
    frame.note:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 10)
    frame.closeButton = CreateButton(frame, "Schließen", 110, 30, function()
        frame:Hide()
    end)
    frame.closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 8)

    frame:Hide()
    self.sessionReview = frame
    return frame
end

function GC.UI:ShowSessionReview()
    local frame = self:CreateSessionReviewFrame()
    frame.anchorID = GC.RaidMonitor.selectedSessionID
    frame.selectedID = frame.anchorID
    frame.compare = false
    frame:Show()
    if frame.Raise then
        frame:Raise()
    end
    self:RefreshSessionReview()
end

-- Zwei Quellen für den Vergleich: Live zuerst, dann Warcraft Logs, dann die
-- Logdatei - genauere Quellen stehen oben.
local REVIEW_SOURCE_PRIORITY = { LIVE = 1, WCL = 2, LOG = 3, SYNC = 4 }

local function PickCompareSources(sources)
    local sorted = {}
    for index, source in ipairs(sources) do
        sorted[index] = source
    end
    table.sort(sorted, function(left, right)
        return (REVIEW_SOURCE_PRIORITY[left.source or "LIVE"] or 9)
            < (REVIEW_SOURCE_PRIORITY[right.source or "LIVE"] or 9)
    end)
    return sorted[1], sorted[2]
end

function GC.UI:RefreshSessionReview()
    local frame = self.sessionReview
    if not frame or not frame:IsShown() then
        return
    end
    local monitor = GC.RaidMonitor

    local evening = monitor:GetEveningOf(frame.anchorID)
    if not evening then
        -- Der Anker kann verschwinden (Livesitzung beendet und neu abgelegt):
        -- dann übernimmt die aktuelle Auswahl der Seite.
        frame.anchorID = monitor.selectedSessionID
        evening = monitor:GetEveningOf(frame.anchorID)
    end
    if not evening then
        frame.headline:SetText("Keine Auswertung vorhanden. Auf der Seite Raidauswertung einen Abend wählen.")
        for _, row in ipairs(frame.rows) do
            row:Hide()
        end
        for _, button in ipairs(frame.sourceButtons) do
            button:Hide()
        end
        frame.compareButton:Hide()
        frame.note:SetText("")
        return
    end

    local sources = evening.sources
    local selectedValid = false
    for _, candidate in ipairs(sources) do
        if candidate.id == frame.selectedID then
            selectedValid = true
        end
    end
    if not selectedValid then
        frame.selectedID = evening.summary.id
    end
    if frame.compare and #sources < 2 then
        frame.compare = false
    end

    for index, button in ipairs(frame.sourceButtons) do
        local candidate = sources[index]
        button.summaryID = candidate and candidate.id or nil
        button:SetShown(candidate ~= nil)
        if candidate then
            button:SetText((SESSION_SOURCE_LABEL[candidate.source or "LIVE"] or "?")
                .. " (" .. #(candidate.participants or {}) .. ")")
            button:SetActive(not frame.compare and candidate.id == frame.selectedID)
        end
    end
    frame.compareButton:SetShown(#sources > 1)
    if #sources > 1 then
        frame.compareButton:SetActive(frame.compare == true)
    end

    local shownRows = 0
    if not frame.compare then
        local summary = monitor:GetSummary(frame.selectedID) or evening.summary
        local zone = summary.zone ~= "" and summary.zone or "Raid"
        frame.headline:SetText(FormatSessionDate(summary) .. "  •  " .. zone
            .. "  •  " .. FormatDuration((summary.endedAt or 0) - (summary.startedAt or 0))
            .. "  •  " .. (summary.pulls or 0) .. " Versuche, " .. (summary.kills or 0)
            .. " Siege, " .. (summary.wipes or 0) .. " Wipes  •  Quelle: "
            .. (SESSION_SOURCE_LABEL[summary.source or "LIVE"] or "?"))

        local sessionSeconds = math.max(0, (summary.endedAt or 0) - (summary.startedAt or 0))
        if ENCOUNTER_TIME_SOURCES[summary.source or ""] then
            sessionSeconds = 0
            for _, participant in ipairs(summary.participants or {}) do
                sessionSeconds = math.max(sessionSeconds, tonumber(participant.seconds) or 0)
            end
        end

        local participants = {}
        for index, participant in ipairs(summary.participants or {}) do
            participants[index] = participant
        end
        table.sort(participants, function(left, right)
            if (left.seconds or 0) ~= (right.seconds or 0) then
                return (left.seconds or 0) > (right.seconds or 0)
            end
            return tostring(left.name or "") < tostring(right.name or "")
        end)

        for index, row in ipairs(frame.rows) do
            local participant = participants[index]
            row:SetShown(participant ~= nil)
            if participant then
                shownRows = index
                row.name:SetText(participant.name)
                row.name:SetTextColor(ClassColor(participant.classFile))
                local values = ReviewValues(participant)
                for _, col in ipairs(REVIEW_COLS) do
                    local cell = row.cells[col.key]
                    cell:SetText(ReviewCellText(col.key, values))
                    if col.key == "time" and sessionSeconds > 0 then
                        local share = (participant.seconds or 0) / sessionSeconds
                        if share < 0.5 then
                            SetTextColor(cell, THEME.danger)
                        elseif share < 0.85 then
                            SetTextColor(cell, THEME.warning)
                        else
                            SetTextColor(cell, THEME.text)
                        end
                    else
                        SetTextColor(cell, THEME.text)
                    end
                end
            end
        end
        frame.note:SetText(#participants .. " Teilnehmer  •  TIME färbt sich unter 85 % bzw. 50 % Anwesenheit.")
    else
        local first, second = PickCompareSources(sources)
        local zone = evening.summary.zone ~= "" and evening.summary.zone or "Raid"
        local firstLabel = SESSION_SOURCE_LABEL[first.source or "LIVE"] or "?"
        local secondLabel = SESSION_SOURCE_LABEL[second.source or "LIVE"] or "?"
        -- "gegen" statt eines Pfeilsymbols: Sonderzeichen wie "↔" fehlen in
        -- der WoW-Schrift.
        frame.headline:SetText(FormatSessionDate(evening.summary) .. "  •  " .. zone
            .. "  •  Vergleich: " .. firstLabel .. " gegen " .. secondLabel)

        -- Beide Teilnehmerlisten über den Kurznamen vereinigen; wer nur in
        -- einer Quelle steht, bekommt auf der anderen Seite Striche.
        local index = {}
        local merged = {}
        for _, participant in ipairs(first.participants or {}) do
            local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(participant.name or ""))
            local entry = { name = participant.name, classFile = participant.classFile, first = participant }
            index[key] = entry
            merged[#merged + 1] = entry
        end
        for _, participant in ipairs(second.participants or {}) do
            local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(participant.name or ""))
            local entry = index[key]
            if entry then
                entry.second = participant
                entry.classFile = entry.classFile or participant.classFile
            else
                entry = { name = participant.name, classFile = participant.classFile, second = participant }
                index[key] = entry
                merged[#merged + 1] = entry
            end
        end
        table.sort(merged, function(left, right)
            local leftSeconds = ((left.first or left.second) or {}).seconds or 0
            local rightSeconds = ((right.first or right.second) or {}).seconds or 0
            if leftSeconds ~= rightSeconds then
                return leftSeconds > rightSeconds
            end
            return tostring(left.name or "") < tostring(right.name or "")
        end)

        for _, entry in ipairs(merged) do
            local firstRow = frame.rows[shownRows + 1]
            local secondRow = frame.rows[shownRows + 2]
            if not firstRow or not secondRow then
                break
            end
            shownRows = shownRows + 2
            local firstValues = entry.first and ReviewValues(entry.first)
            local secondValues = entry.second and ReviewValues(entry.second)

            firstRow:Show()
            firstRow.name:SetText(entry.name)
            firstRow.name:SetTextColor(ClassColor(entry.classFile))
            secondRow:Show()
            secondRow.name:SetText("   > " .. (entry.second and secondLabel or (secondLabel .. ": fehlt")))
            SetTextColor(secondRow.name, THEME.muted)

            for _, col in ipairs(REVIEW_COLS) do
                local firstCell = firstRow.cells[col.key]
                local secondCell = secondRow.cells[col.key]
                firstCell:SetText(firstValues and ReviewCellText(col.key, firstValues) or "–")
                secondCell:SetText(secondValues and ReviewCellText(col.key, secondValues) or "–")
                local differs = firstValues and secondValues
                    and firstValues[col.key] ~= secondValues[col.key]
                if differs then
                    SetTextColor(firstCell, THEME.warning)
                    SetTextColor(secondCell, THEME.warning)
                else
                    SetTextColor(firstCell, THEME.text)
                    SetTextColor(secondCell, THEME.muted)
                end
            end
        end
        for index = shownRows + 1, #frame.rows do
            frame.rows[index]:Hide()
        end
        frame.note:SetText("Obere Zeile " .. firstLabel .. ", untere " .. secondLabel
            .. ".  Gelb: Die Quellen widersprechen sich (TIME auf Minutenbasis).")
    end

    if not frame.compare then
        for index = shownRows + 1, #frame.rows do
            frame.rows[index]:Hide()
        end
    end
    frame.content:SetHeight(math.max(360, shownRows * 20))
    frame.scroll:UpdateModernThumb()
end

GC:RegisterCallback("RAID_SESSION_UPDATED", GC.UI, function(self)
    self:RefreshSessionReview()
end)
GC:RegisterCallback("WCL_UPDATED", GC.UI, function(self)
    self:RefreshSessionReview()
end)

-- === Versionsprüfer =========================================================
-- /gcp ver: Wer in Gruppe oder Gilde hat Guild Copilot, und in welcher
-- Version? Grün ist der eigene Stand, rot ist älter, gelb wartet noch,
-- "Nicht installiert" hat nach acht Sekunden nicht geantwortet.

function GC.UI:CreateVersionCheckFrame()
    if self.versionCheck then
        return self.versionCheck
    end
    local frame = CreatePanel(UIParent, THEME.window, THEME.accent, "GuildCopilotVersionCheck")
    frame:SetSize(470, 458)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.title = CreateLabel(frame, "Versionsprüfer", { title = true, width = 280 })
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -14)
    frame.ownVersion = CreateLabel(frame, "Deine Version: " .. GC.Constants.VERSION,
        { muted = true, width = 280, height = 15 })
    frame.ownVersion:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -38)
    frame.closeX = CreateButton(frame, "×", 24, 24, function()
        frame:Hide()
    end)
    frame.closeX:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)

    CreateLabel(frame, "NAME", { muted = true, font = "GameFontNormalSmall", width = 140, height = 14 })
        :SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -62)
    CreateLabel(frame, "RANG", { muted = true, font = "GameFontNormalSmall", width = 120, height = 14 })
        :SetPoint("TOPLEFT", frame, "TOPLEFT", 190, -62)
    CreateLabel(frame, "VERSION", { muted = true, font = "GameFontNormalSmall",
        align = "RIGHT", width = 130, height = 14 })
        :SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -62)

    local body = CreatePanel(frame, THEME.input)
    body:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -80)
    body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 78)
    frame.scroll = CreateModernScrollFrame(body)
    frame.scroll:SetPoint("TOPLEFT", body, "TOPLEFT", 6, -6)
    frame.scroll:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -10, 6)
    frame.content = CreateFrame("Frame", nil, frame.scroll)
    frame.content:SetWidth(420)
    frame.content:SetHeight(280)
    frame.scroll:SetScrollChild(frame.content)

    frame.rows = {}
    for index = 1, 40 do
        local row = CreateFrame("Frame", nil, frame.content)
        row:SetSize(420, 24)
        row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -((index - 1) * 26))
        row.name = CreateLabel(row, "", { width = 160, height = 24 })
        row.name:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.rank = CreateLabel(row, "", { muted = true, width = 120, height = 24 })
        row.rank:SetPoint("LEFT", row, "LEFT", 172, 0)
        row.version = CreateLabel(row, "", { align = "RIGHT", width = 124, height = 24 })
        row.version:SetPoint("RIGHT", row, "RIGHT", -2, 0)
        row:Hide()
        frame.rows[index] = row
    end

    -- Die Zusammenfassung hat ihre eigene Zeile über den Knöpfen - zwischen
    -- den Knöpfen wurde sie zerquetscht und "ohne Addon" abgeschnitten.
    frame.counts = CreateLabel(frame, "", { width = 440, height = 18 })
    frame.counts:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 52)
    frame.modeGuild = CreateButton(frame, "Gilde", 110, 30, function()
        GC.UI:SetVersionCheckMode("GUILD")
    end)
    frame.modeGuild:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 14, 12)
    frame.modeGroup = CreateButton(frame, "Gruppe", 110, 30, function()
        GC.UI:SetVersionCheckMode("GROUP")
    end)
    frame.modeGroup:SetPoint("LEFT", frame.modeGuild, "RIGHT", 8, 0)
    frame.closeButton = CreateButton(frame, "Schließen", 110, 30, function()
        frame:Hide()
    end)
    frame.closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 12)

    frame:Hide()
    self.versionCheck = frame
    return frame
end

function GC.UI:ShowVersionCheck(mode)
    local frame = self:CreateVersionCheckFrame()
    frame:Show()
    self:SetVersionCheckMode(mode
        or ((IsInGroup and IsInGroup()) and "GROUP" or "GUILD"))
end

function GC.UI:SetVersionCheckMode(mode)
    local frame = self:CreateVersionCheckFrame()
    frame.mode = mode == "GROUP" and "GROUP" or "GUILD"
    frame.requestedAt = GC.Util.Now()
    frame.settled = false
    GC.Sync:RequestVersionCheck(frame.mode)
    if C_Timer and type(C_Timer.After) == "function" then
        local requestedAt = frame.requestedAt
        C_Timer.After(8, function()
            local current = GC.UI.versionCheck
            if current and current.requestedAt == requestedAt then
                current.settled = true
                GC.UI:RefreshVersionCheck()
            end
        end)
    else
        frame.settled = true
    end
    self:RefreshVersionCheck()
end

function GC.UI:GetVersionCheckTargets(mode)
    local targets = {}
    if mode == "GROUP" and IsInGroup and IsInGroup() then
        if IsInRaid and IsInRaid() then
            for index = 1, (GetNumGroupMembers and GetNumGroupMembers() or 0) do
                local name, _, _, _, _, classFile = GetRaidRosterInfo(index)
                if name then
                    targets[#targets + 1] = { name = name, classFile = classFile }
                end
            end
        else
            local _, ownClass = UnitClass("player")
            targets[#targets + 1] = { name = GC:GetPlayerFullName(), classFile = ownClass }
            for index = 1, math.max(0, (GetNumGroupMembers and GetNumGroupMembers() or 1) - 1) do
                local unit = "party" .. index
                if UnitExists and UnitExists(unit) then
                    local _, classFile = UnitClass(unit)
                    targets[#targets + 1] = { name = UnitName(unit), classFile = classFile }
                end
            end
        end
    else
        for _, member in ipairs(GC.Roster.members) do
            if member.online then
                targets[#targets + 1] = {
                    name = member.name,
                    classFile = member.classFile,
                    rank = member.rank,
                }
            end
        end
    end
    for _, target in ipairs(targets) do
        if not target.rank then
            local member = GC.Roster:GetMember(target.name)
            target.rank = (member and member.rank) or "–"
        end
    end
    return targets
end

local VERSION_STATE_ORDER = { OLD = 1, NONE = 2, WAITING = 3, CURRENT = 4 }

function GC.UI:RefreshVersionCheck()
    local frame = self.versionCheck
    if not frame or not frame:IsShown() then
        return
    end
    frame.modeGuild:SetActive(frame.mode ~= "GROUP")
    frame.modeGroup:SetActive(frame.mode == "GROUP")

    local ownKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(GC:GetPlayerFullName()))
    local ownVersion = GC.Constants.VERSION
    local current, outdated, missing = 0, 0, 0
    local entries = {}
    for _, target in ipairs(self:GetVersionCheckTargets(frame.mode)) do
        local entry = { name = target.name, classFile = target.classFile, rank = target.rank }
        if GC.Util.NormalizeName(GC.Util.PlayerShortName(target.name)) == ownKey then
            entry.version = ownVersion
            entry.state = "CURRENT"
        else
            local version, fresh = GC.Sync:GetKnownVersion(target.name, frame.requestedAt)
            if fresh or (frame.settled and version) then
                entry.version = version
                entry.state = version == ownVersion and "CURRENT" or "OLD"
            elseif frame.settled then
                entry.state = "NONE"
            else
                entry.state = "WAITING"
            end
        end
        if entry.state == "CURRENT" then
            current = current + 1
        elseif entry.state == "OLD" then
            outdated = outdated + 1
        elseif entry.state == "NONE" then
            missing = missing + 1
        end
        entries[#entries + 1] = entry
    end

    -- Rot zuerst: Wer prüft, sucht die Veralteten.
    table.sort(entries, function(left, right)
        if VERSION_STATE_ORDER[left.state] ~= VERSION_STATE_ORDER[right.state] then
            return VERSION_STATE_ORDER[left.state] < VERSION_STATE_ORDER[right.state]
        end
        return tostring(left.name) < tostring(right.name)
    end)

    for index, row in ipairs(frame.rows) do
        local entry = entries[index]
        row:SetShown(entry ~= nil)
        if entry then
            row.name:SetText(GC.Util.PlayerShortName(entry.name))
            row.name:SetTextColor(ClassColor(entry.classFile))
            row.rank:SetText(entry.rank or "–")
            if entry.state == "CURRENT" then
                row.version:SetText(entry.version)
                SetTextColor(row.version, THEME.success)
            elseif entry.state == "OLD" then
                row.version:SetText(entry.version or "?")
                SetTextColor(row.version, THEME.danger)
            elseif entry.state == "WAITING" then
                row.version:SetText("Warte auf Antwort …")
                SetTextColor(row.version, THEME.warning)
            else
                row.version:SetText("Nicht installiert")
                SetTextColor(row.version, THEME.muted)
            end
        end
    end

    frame.counts:SetText("|cff59e695" .. current .. " aktuell|r · |cffff6266"
        .. outdated .. " veraltet|r · " .. missing .. " ohne Addon")
    frame.content:SetHeight(math.max(280, #entries * 26))
    frame.scroll:UpdateModernThumb()
end

-- Die Befehlstabelle steht oben in der Datei, damit auch die
-- Einstellungsseite sie lesen kann.
function GC.UI:PrintSlashHelp()
    GC:Print("Verfügbare Befehle:")
    for _, entry in ipairs(SLASH_COMMANDS) do
        GC:Print("  |cffffffff" .. entry.command .. "|r – " .. entry.description)
    end
    GC:Print("  |cff91a3b8/guildcopilot|r tut überall dasselbe wie |cff91a3b8/gcp|r.")
end

function GC.UI:RegisterInterfaceOptions()
    if self.optionsPanel then
        return
    end

    local panel = CreateFrame("Frame")
    panel.name = "Guild Copilot"

    local wordmark = panel:CreateTexture(nil, "ARTWORK")
    wordmark:SetSize(300, 300)
    wordmark:SetPoint("TOP", panel, "TOP", 0, -22)
    wordmark:SetTexture("Interface\\AddOns\\GuildCopilot\\Media\\GuildCopilotWordmark")
    panel.wordmark = wordmark

    local commandLabel = CreateLabel(panel, "Chat-Befehle", {
        muted = true,
        align = "CENTER",
        width = 300,
    })
    commandLabel:SetPoint("TOP", wordmark, "BOTTOM", 0, -8)
    local command = CreateLabel(panel, "/gcp", {
        title = true,
        align = "CENTER",
        width = 300,
    })
    command:SetPoint("TOP", commandLabel, "BOTTOM", 0, -8)

    -- Die Befehle stehen hier, weil man diese Seite genau dann aufschlaegt,
    -- wenn man nicht mehr weiss, wie das Addon hiess - dort nach dem Chatbefehl
    -- zu suchen ist der naheliegende Weg.
    panel.commandRows = {}
    local previous = command
    for index, entry in ipairs(SLASH_COMMANDS) do
        local row = CreateLabel(panel, entry.command .. "  –  " .. entry.description, {
            muted = true,
            font = "GameFontNormalSmall",
            align = "CENTER",
            width = 560,
            height = 16,
        })
        row:SetPoint("TOP", previous, "BOTTOM", 0, index == 1 and -14 or -3)
        panel.commandRows[index] = row
        previous = row
    end

    panel.openButton = CreateButton(panel, "Guild Copilot öffnen", 220, 40, function()
        if InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then
            if HideUIPanel then
                HideUIPanel(InterfaceOptionsFrame)
            else
                InterfaceOptionsFrame:Hide()
            end
        elseif SettingsPanel and SettingsPanel:IsShown() then
            if HideUIPanel then
                HideUIPanel(SettingsPanel)
            else
                SettingsPanel:Hide()
            end
        end
        C_Timer.After(0, function()
            GC.UI:CreateMainFrame()
            GC.UI.frame:Show()
            GC.UI:ShowPage("ROSTER")
        end)
    end, "PRIMARY")
    panel.openButton:SetPoint("TOP", previous, "BOTTOM", 0, -20)

    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    elseif Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        panel.category = category
    else
        return
    end

    self.optionsPanel = panel
end

SLASH_GUILDCOPILOT1 = "/gcp"
SLASH_GUILDCOPILOT2 = "/guildcopilot"
SlashCmdList.GUILDCOPILOT = function(input)
    local command = GC.Util.Trim(tostring(input or "")):lower()
    if command == "help" or command == "hilfe" or command == "?" then
        GC.UI:PrintSlashHelp()
        return
    end

    -- "werbung" und "balken" bleiben, damit sich niemand umgewoehnen muss;
    -- "recruit" faengt den naheliegenden Vertipper von "recruite" mit ab.
    if command == "recruite" or command == "recruit"
        or command == "werbung" or command == "balken" then
        GC.UI:CreateMainFrame()
        GC.UI:TogglePostBar()
        return
    end

    if command == "welcome" or command == "willkommen" then
        GC.UI:ShowWelcome()
        return
    end

    -- Ob ein Ruckler vom Addon kommt, laesst sich nur messen. Standardmaessig
    -- ist die Messung aus; wer sie einschaltet, spielt eine Weile und ruft
    -- "/gcp debug" erneut auf, bekommt die schlimmsten Einzelmessungen.
    if command == "debug" then
        if GC.Perf.enabled then
            for _, line in ipairs(GC.Perf:Report()) do
                GC:Print(line)
            end
            GC.Perf.enabled = false
            GC:Print("Messung beendet. Erneut einschalten mit /gcp debug.")
        else
            GC.Perf:Reset()
            GC.Perf.enabled = true
            GC:Print("Messung läuft. Spiel eine Weile weiter und ruf /gcp debug erneut auf.")
        end
        return
    end

    -- Der Versionsprüfer: Wer in Gruppe oder Gilde hat das Addon, und in
    -- welcher Version? ("/gcp phase" ist auf Owner-Wunsch entfallen; die
    -- Content-Phase läuft intern mit ihrer Voreinstellung und dem
    -- Gildenabgleich weiter.)
    if command == "ver" or command == "version" then
        GC.UI:ShowVersionCheck()
        return
    end

    GC.UI:Toggle()
end

GC:RegisterCallback("PLAYER_LOGIN", GC.UI, function(self)
    self:CreateMainFrame()
    if GC.DB:GetSettings().postBar.hidden == false then
        self:SetPostBarShown(true)
    end
    self:AddMinimapButton()
    self:RegisterInterfaceOptions()
    self:RefreshOrderTracker()
end)

GC:RegisterCallback("ORDERS_UPDATED", GC.UI, function(self)
    self:Invalidate("WORKSHOP")
    self:RefreshMinimapMarker()
    self:RefreshOrderTracker()
    if self.pages.WORKSHOP and self.pages.WORKSHOP.orderLogDialog then
        self:RefreshOrderLogDialog()
    end
end)

GC:RegisterCallback("ORDERS_BANNER", GC.UI, function(self, text)
    self:ShowOrderBanner(text)
end)

-- Eintreffende Versionsantworten füllen den offenen Versionsprüfer live.
GC:RegisterCallback("VERSION_REPLIES_UPDATED", GC.UI, function(self)
    self:RefreshVersionCheck()
end)

GC:RegisterCallback("ROSTER_UPDATED", GC.UI, function(self)
    self:Refresh()
end)

-- Alle folgenden Rueckmeldungen kommen aus der Gildensynchronisierung und
-- treffen zur Prime Time im Sekundentakt ein. Sie merken die betroffenen
-- Seiten deshalb nur noch vor; gezeichnet wird, was gerade zu sehen ist.
GC:RegisterCallback("PROFILE_UPDATED", GC.UI, function(self)
    self:Invalidate("OVERVIEW", "ROSTER", "MEMBERCARE", "SUGGESTIONS")
    -- Der Marker am Minimap-Symbol haengt nicht am Zeichnen der Seite: Er muss
    -- auch stimmen, wenn das Fenster zu ist.
    self:RefreshMinimapMarker()
end)

GC:RegisterCallback("SETTINGS_UPDATED", GC.UI, function(self)
    self:Invalidate("SETTINGS", "GUILD")
    if self:IsVisible() then
        self:RefreshNavigationAccess()
    end
end)

GC:RegisterCallback("GUILD_PROFILE_UPDATED", GC.UI, function(self)
    self:Invalidate("GUILD", "SETTINGS", "MEMBERCARE", "SUGGESTIONS", "POST", "INBOX")
    if self:IsVisible() then
        self:RefreshNavigationAccess()
    end
end)

-- Neue Bestandszahlen aendern die Ampel in den Rezeptdetails.
GC:RegisterCallback("INVENTORY_UPDATED", GC.UI, function(self)
    self:Invalidate("WORKSHOP")
end)

GC:RegisterCallback("WORKSHOP_UPDATED", GC.UI, function(self)
    -- Ein eingelesener Beruf erledigt den zweiten Schritt der Checkliste, und
    -- die steht auf der Profilseite.
    self:Invalidate("WORKSHOP", "ROSTER")
    self:RefreshMinimapMarker()
end)

GC:RegisterCallback("PROFILE_CONFIRMATION_CHANGED", GC.UI, function(self)
    self:Invalidate("ROSTER")
    self:RefreshMinimapMarker()
end)

GC:RegisterCallback("RECRUITMENT_UPDATED", GC.UI, function(self)
    self:Invalidate("RECRUITMENT")
end)

GC:RegisterCallback("INBOX_UPDATED", GC.UI, function(self)
    self:Invalidate("INBOX")
end)

GC:RegisterCallback("WCL_UPDATED", GC.UI, function(self)
    -- Region und Realm der Gildenquelle stehen in den Profil-Links des
    -- Postfachs. Ohne dessen Auffrischung zeigen sie bis zum Seitenwechsel den
    -- alten Stand.
    self:Invalidate("WCL", "SUGGESTIONS", "INBOX")
end)

GC:RegisterCallback("ROSTER_FILTER_UPDATED", GC.UI, function(self)
    self:Invalidate("OVERVIEW", "SETTINGS")
end)

GC:RegisterCallback("MEMBERCARE_UPDATED", GC.UI, function(self)
    self:Invalidate("MEMBERCARE")
end)

GC:RegisterCallback("ADDON_USERS_UPDATED", GC.UI, function(self)
    self:Invalidate("OVERVIEW")
    if self:IsVisible() then
        self:RefreshSyncBadge()
    end
end)

GC:RegisterCallback("RAID_SESSION_UPDATED", GC.UI, function(self)
    self:Invalidate("STATISTICS")
end)

GC:RegisterCallback("GEAR_AUDIT_UPDATED", GC.UI, function(self)
    -- Die eigene Ausruestung steht auch auf der Profilseite.
    self:Invalidate("GEAR", "ROSTER")
    self:RefreshMinimapMarker()
    -- Eintreffende Inspects und Addon-Daten füllen die offene
    -- Gruppenübersicht live.
    self:RefreshGroupGearCheck()
end)
