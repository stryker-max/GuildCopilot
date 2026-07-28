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
    return label
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
        self:UpdateModernThumb()
    end)
    scroll:SetScript("OnVerticalScroll", function(self)
        self:UpdateModernThumb()
    end)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local newValue = self:GetVerticalScroll() - (delta * 24)
        self:SetVerticalScroll(math.max(0, math.min(newValue, self:GetVerticalScrollRange())))
        self:UpdateModernThumb()
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
        dropdown.popup:SetShown(not dropdown.popup:IsShown())
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

    local popup = CreatePanel(parent, THEME.input, THEME.accent)
    popup:SetSize(width, (#options * 25) + 8)
    if openBelow then
        popup:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -5)
    else
        popup:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 5)
    end
    local parentLevel = parent.GetFrameLevel and parent:GetFrameLevel() or 1
    popup:SetFrameLevel((parentLevel or 1) + 20)
    popup:Hide()
    dropdown.popup = popup

    for index, option in ipairs(options) do
        local selectedOption = option
        local optionButton = CreateButton(popup, option ~= "" and option or (emptyLabel or "Nicht gesetzt"), width - 8, 23, function()
            dropdown:SetValue(selectedOption)
            popup:Hide()
            onSelected(selectedOption)
        end)
        optionButton:SetPoint("TOPLEFT", popup, "TOPLEFT", 4, -4 - ((index - 1) * 25))
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

    local close = CreateButton(header, "×", 34, 34, function()
        frame:Hide()
    end)
    close:SetPoint("RIGHT", header, "RIGHT", -13, 0)
    close.label:SetFontObject("GameFontNormalLarge")

    local sidebar = CreatePanel(frame, THEME.sidebar, THEME.sidebar)
    sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -59)
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
    sidebar:SetWidth(190)
    frame.sidebar = sidebar

    local navigationY = -10
    local currentSection
    for _, definition in ipairs(TAB_DEFINITIONS) do
        if definition.section ~= currentSection then
            if currentSection then
                navigationY = navigationY - 4
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
            navigationY = navigationY - 24
        end
        local pageKey = definition.key
        local tab = CreateButton(sidebar, definition.label, 160, 35, function()
            self:ShowPage(pageKey)
        end)
        tab:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 14, navigationY)
        navigationY = navigationY - 38
        tab.key = pageKey
        tab.label:ClearAllPoints()
        tab.label:SetPoint("LEFT", tab, "LEFT", 43, 0)
        tab.label:SetPoint("RIGHT", tab, "RIGHT", -8, 0)
        tab.label:SetJustifyH("LEFT")
        tab.icon = tab:CreateTexture(nil, "ARTWORK")
        tab.icon:SetSize(22, 22)
        tab.icon:SetPoint("LEFT", tab, "LEFT", 13, 0)
        tab.icon:SetTexture(definition.icon)
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
        GC:Print("Mitgliederpflege ist für deinen Gildenrang nicht freigeschaltet.")
    end
    self.activePage = pageKey
    for key, page in pairs(self.pages) do
        page:SetShown(key == pageKey)
    end
    for _, tab in ipairs(self.tabs) do
        tab:SetActive(tab.key == pageKey)
    end
    self:Refresh()
end

function GC.UI:RefreshNavigationAccess()
    local canAccessMemberCare = GC.Roster:CanAccessMemberCare()
    for _, tab in ipairs(self.tabs) do
        if tab.key == "MEMBERCARE" then
            tab:SetShown(canAccessMemberCare)
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
        card:SetSize(185, 76)
        card:SetPoint("TOPLEFT", page, "TOPLEFT", (index - 1) * 197, -66)
        card.value = CreateLabel(card, "0", { title = true })
        card.value:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -13)
        card.caption = CreateLabel(card, metric.label, { muted = true })
        card.caption:SetPoint("TOPLEFT", card.value, "BOTTOMLEFT", 0, -5)
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
        GameTooltip:AddLine(stats.known .. " erkannte Nutzer, davon " .. stats.compatible
            .. " mit passender Datenversion", 1, 1, 1)
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
    local headers = {
        { text = "SPIELER", x = 18, width = 132 },
        { text = "SPEC", x = 158, width = 168 },
        { text = "STATUS", x = 334, width = 74 },
        { text = "BERUFE", x = 416, width = 226 },
        { text = "AKTIV", x = 650, width = 100 },
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
    content:SetHeight(700)
    scroll:SetScrollChild(content)
    page.raiderRows = {}
    for index = 1, 25 do
        local row = CreatePanel(content, index % 2 == 0 and THEME.input or THEME.card)
        row:SetSize(740, 25)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * 27))
        row.name = CreateLabel(row, "", { width = 132 })
        row.name:SetPoint("LEFT", row, "LEFT", 5, 0)
        row.spec = CreateLabel(row, "", { width = 168 })
        row.spec:SetPoint("LEFT", row, "LEFT", 145, 0)
        row.status = CreateLabel(row, "", { width = 74 })
        row.status:SetPoint("LEFT", row, "LEFT", 321, 0)
        row.professions = CreateLabel(row, "", { width = 226 })
        row.professions:SetPoint("LEFT", row, "LEFT", 403, 0)
        row.activity = CreateLabel(row, "", { width = 100 })
        row.activity:SetPoint("LEFT", row, "LEFT", 637, 0)
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
    addonCard.value:SetText(addonStats.known)
    local incompatible = addonStats.outdated + addonStats.ahead
    if incompatible > 0 then
        addonCard.caption:SetText("MIT ADDON  •  " .. incompatible .. " ABWEICHEND")
        SetTextColor(addonCard.caption, THEME.warning)
    else
        addonCard.caption:SetText("MIT ADDON")
        SetTextColor(addonCard.caption, THEME.muted)
    end

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
            local statusText = "nicht bestätigt"
            if profile then
                if profile.source == "WARCRAFT_LOGS" then
                    statusText = "Logs"
                elseif profile.source == "MANUAL" then
                    statusText = "Manuell"
                else
                    statusText = profile.mainStatus == "ALT" and "Alt" or "Main"
                end
                if not profile.confirmed and profile.source ~= "WARCRAFT_LOGS" then
                    statusText = statusText .. " ?"
                end
            end
            row.name:SetText(GC.Util.PlayerShortName(member.name))
            row.name:SetTextColor(ClassColor(member.classFile))
            row.spec:SetText(specText)
            row.status:SetText(statusText)
            row.professions:SetText(ProfessionSummary(profile))
            row.activity:SetText(LastOnlineLabel(member))
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
    content:SetHeight(940)
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
    notificationCard:SetSize(752, 190)
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

    local templateCard = CreateCard(content, "Standardtexte im Postfach")
    templateCard:SetSize(752, 294)
    templateCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -646)
    local templateHelp = CreateLabel(templateCard,
        "Die Vorlagen sind vorausgefüllt und frei änderbar. Platzhalter: {name}, {gilde}, {beschreibung}, {raidzeiten}, {progress}, {loot}, {discord}, {kontakt}.",
        { muted = true, width = 716, height = 30, vertical = "TOP" })
    templateHelp:SetPoint("TOPLEFT", templateCard, "TOPLEFT", 18, -47)
    page.templateEdits = {}
    local templateDefinitions = {
        { key = "THANKS", label = "Danke", y = -82 },
        { key = "INFO", label = "Gildeninfos", y = -132 },
        { key = "DISCORD", label = "Discord", y = -182 },
    }
    for _, definition in ipairs(templateDefinitions) do
        local label = CreateLabel(templateCard, definition.label, { muted = true, width = 100 })
        label:SetPoint("TOPLEFT", templateCard, "TOPLEFT", 18, definition.y)
        local edit = CreateEdit(templateCard, 600, 36)
        edit.container:SetPoint("TOPLEFT", templateCard, "TOPLEFT", 134, definition.y + 8)
        page.templateEdits[definition.key] = edit
    end
    page.saveTemplates = CreateButton(templateCard, "Vorlagen speichern", 180, 36, function()
        if not GC.Roster:CanEditGuildProfile() then
            page.settingsStatus:SetText("Dein Gildenrang darf die gildenweiten Vorlagen nicht bearbeiten.")
            SetTextColor(page.settingsStatus, THEME.danger)
            return
        end
        local guildData = GC.DB:GetGuild()
        for key, edit in pairs(page.templateEdits) do
            guildData.replyTemplates[key] = GC.Util.Trim(edit:GetText())
        end
        guildData.profile.updatedAt = GC.Util.Now()
        GC.Sync:QueueGuildProfile()
        GC:FireCallback("GUILD_PROFILE_UPDATED")
        page.settingsStatus:SetText("Antwortvorlagen gespeichert und für die Gilde synchronisiert.")
        SetTextColor(page.settingsStatus, THEME.success)
    end, "PRIMARY")
    page.saveTemplates:SetPoint("BOTTOMLEFT", templateCard, "BOTTOMLEFT", 134, 18)
    page.settingsStatus = CreateLabel(templateCard, "", { width = 410 })
    page.settingsStatus:SetPoint("LEFT", page.saveTemplates, "RIGHT", 14, 0)
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
        activeToggle:SetShown(rank ~= nil)
        editorToggle:SetShown(rank ~= nil)
        memberCareAccessToggle:SetShown(rank ~= nil)
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
        end
    end

    local settings = GC.DB:GetSettings()
    SetToggle(page.successSoundToggle, settings.successSound)
    SetToggle(page.captureDuringSearchToggle, settings.captureOnlyDuringSearch)
    SetToggle(page.watchChannelToggle, settings.watchRecruitmentTriggers)
    SetToggle(page.minimapToggle, not settings.minimap.hidden)
    local selectedSoundName = GC.SuccessSoundOptions[1].name
    for _, sound in ipairs(GC.SuccessSoundOptions) do
        if sound.key == settings.successSoundKey then
            selectedSoundName = sound.name
            break
        end
    end
    page.successSoundDropdown:SetValue(selectedSoundName)

    local templates = GC.DB:GetGuild().replyTemplates
    for key, edit in pairs(page.templateEdits) do
        if not edit:HasFocus() then
            edit:SetText(templates[key] or "")
        end
        if canEditGuildProfile then
            edit:Enable()
        else
            edit:Disable()
        end
    end
    if canEditGuildProfile then
        page.saveTemplates:Enable()
        if page.settingsStatus:GetText() == "" then
            page.settingsStatus:SetText("Gildenweite Änderungen sind für deinen Rang freigegeben.")
            SetTextColor(page.settingsStatus, THEME.muted)
        end
    else
        page.saveTemplates:Disable()
        page.settingsStatus:SetText("Gildenweite Einstellungen sind für deinen Rang schreibgeschützt; lokale Optionen bleiben änderbar.")
        SetTextColor(page.settingsStatus, THEME.warning)
    end
    page.settingsScroll:UpdateModernThumb()
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
    content:SetHeight(786)
    scroll:SetScrollChild(content)
    page.profileScroll = scroll

    local profileCard = CreateCard(content, "Dein Raidprofil")
    profileCard:SetSize(374, 408)
    profileCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
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

    page.mainCheck = CreateToggle(profileCard, "Main", function(enabled)
        if enabled then
            page.selectedMainStatus = "MAIN"
            SetToggle(page.altCheck, false)
        else
            SetToggle(page.mainCheck, true)
        end
    end)
    page.mainCheck:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -251)

    page.altCheck = CreateToggle(profileCard, "Alt", function(enabled)
        if enabled then
            page.selectedMainStatus = "ALT"
            SetToggle(page.mainCheck, false)
        else
            SetToggle(page.altCheck, true)
        end
    end)
    page.altCheck:SetPoint("LEFT", page.mainCheck, "RIGHT", 92, 0)

    page.flexCheck = CreateToggle(profileCard, "Flexibel einsetzbar", function(enabled)
        page.selectedFlex = enabled
    end)
    page.flexCheck:SetPoint("TOPLEFT", profileCard, "TOPLEFT", 18, -292)

    local confirm = CreateButton(profileCard, "Bestätigen", 190, 38, function()
        GC.Profile:Confirm(
            page.selectedProfileSpec,
            page.selectedSecondarySpec,
            page.selectedMainStatus,
            page.selectedFlex
        )
        GC.UI:RefreshRoster()
    end, "PRIMARY")
    confirm:SetPoint("BOTTOMLEFT", profileCard, "BOTTOMLEFT", 18, 18)

    local professions = CreateCard(content, "Deine Berufe")
    professions:SetSize(388, 408)
    professions:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    local professionHelp = CreateLabel(professions,
        "Wähle zwei Berufe manuell oder übernimm sie direkt aus deinem WoW-Berufsfenster. Die Angaben werden im Gildenroster synchronisiert.",
        { muted = true, width = 352, height = 64, vertical = "TOP" })
    professionHelp:SetPoint("TOPLEFT", professions, "TOPLEFT", 18, -54)

    page.professionDropdowns = {}
    for slot = 1, 2 do
        local professionSlot = slot
        local dropdown = CreateChoiceDropdown(professions, 170, GC.ProfessionOptions, function(value)
            GC.Profile:SetProfession(professionSlot, value)
            GC.UI:RefreshRoster()
        end)
        dropdown:SetPoint("TOPLEFT", professions, "TOPLEFT", 18 + ((slot - 1) * 182), -130)
        page.professionDropdowns[slot] = dropdown
    end
    page.professionSync = CreateButton(professions, "Aus WoW-Berufen übernehmen", 230, 34, function()
        GC.Profile:EnableProfessionSync()
        GC.UI:RefreshRoster()
    end, "PRIMARY")
    page.professionSync:SetPoint("TOPLEFT", professions, "TOPLEFT", 18, -181)
    page.professionStatus = CreateLabel(professions, "", { muted = true, width = 352, height = 42, vertical = "TOP" })
    page.professionStatus:SetPoint("TOPLEFT", professions, "TOPLEFT", 18, -230)
    local workshopButton = CreateButton(professions, "Zur Gildenwerkstatt", 210, 36, function()
        GC.UI:ShowPage("WORKSHOP")
    end)
    workshopButton:SetPoint("BOTTOMLEFT", professions, "BOTTOMLEFT", 18, 18)

    local absenceCard = CreateCard(content, "Deine Abmeldung")
    absenceCard:SetSize(752, 180)
    absenceCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -420)
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
    page.absenceStatus = CreateLabel(absenceCard, "", { width = 402, height = 32 })
    page.absenceStatus:SetPoint("LEFT", page.clearAbsence, "RIGHT", 12, 0)

    local gearCard = CreateCard(content, "Deine Ausrüstung")
    gearCard:SetSize(752, 162)
    gearCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -612)
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

function GC.UI:RefreshRoster()
    local page = self.pages.ROSTER
    if not page then
        return
    end
    self:RefreshProfileGear()

    local profile = GC.Profile:Get()
    local detected = GC.SpecByKey[profile.detectedSpecKey or ""]
    page.detectedText:SetText("Erkannt: " .. (detected and detected.name or "noch nicht ermittelbar")
        .. "  •  Talente " .. (profile.talentSignature or "0/0/0"))
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
    page.professionStatus:SetText(profile.professionAuto
        and "Automatische Synchronisierung aktiv."
        or "Manuell gewählt. Mit dem Button wieder aus WoW übernehmen.")

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
        row.priority = CreateLabel(row, "", { width = 64, font = "GameFontNormalSmall" })
        row.priority:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.name = CreateLabel(row, "", { width = 190 })
        row.name:SetPoint("LEFT", row, "LEFT", 78, 0)
        row.reason = CreateLabel(row, "", { muted = true, width = 450 })
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
    absencesCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -242)
    page.guildAbsencesTitle = absencesCard.title
    page.guildAbsenceRows = {}
    for index = 1, 5 do
        local row = CreatePanel(absencesCard, index % 2 == 0 and THEME.input or THEME.cardHover)
        row:SetSize(716, 26)
        row:SetPoint("TOPLEFT", absencesCard, "TOPLEFT", 18, -48 - ((index - 1) * 29))
        row.name = CreateLabel(row, "", { width = 140 })
        row.name:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.range = CreateLabel(row, "", { muted = true, width = 190 })
        row.range:SetPoint("LEFT", row, "LEFT", 154, 0)
        row.reason = CreateLabel(row, "", { muted = true, width = 284 })
        row.reason:SetPoint("LEFT", row, "LEFT", 350, 0)
        row.state = CreateLabel(row, "", { align = "RIGHT", width = 70 })
        row.state:SetPoint("RIGHT", row, "RIGHT", -9, 0)
        page.guildAbsenceRows[index] = row
    end
    page.guildAbsenceNotice = CreateLabel(absencesCard, "", { muted = true, width = 716 })
    page.guildAbsenceNotice:SetPoint("BOTTOMLEFT", absencesCard, "BOTTOMLEFT", 18, 10)

    local suggestionsCard = CreateCard(content, "Pflegevorschläge")
    suggestionsCard:SetSize(752, 368)
    suggestionsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -464)
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
        row.name = CreateLabel(row, "", { width = 116 })
        row.name:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.status = CreateLabel(row, "", { width = 76 })
        row.status:SetPoint("LEFT", row, "LEFT", 129, 0)
        row.reason = CreateLabel(row, "", { muted = true, width = 196 })
        row.reason:SetPoint("LEFT", row, "LEFT", 209, 0)

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
    decisionsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -844)
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
        row.name = CreateLabel(row, "", { width = 150 })
        row.name:SetPoint("LEFT", row, "LEFT", 9, 0)
        row.status = CreateLabel(row, "", { width = 130 })
        row.status:SetPoint("LEFT", row, "LEFT", 165, 0)
        row.detail = CreateLabel(row, "", { muted = true, width = 300 })
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
    CreatePageTitle(page, "Gildenwerkstatt",
        "Rezepte werden automatisch erfasst, sobald ein Spieler sein WoW-Berufsfenster öffnet.")

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
    page.workshopSearch:SetScript("OnTextChanged", function()
        page.workshopPage = 1
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
    listCard:SetSize(478, 342)
    listCard:SetPoint("TOPLEFT", searchCard, "BOTTOMLEFT", 0, -12)
    page.workshopListTitle = listCard.title
    page.workshopRows = {}
    for index = 1, 7 do
        local rowIndex = index
        local row = CreateButton(listCard, "", 442, 31, function()
            local recipe = page.workshopVisibleRecipes and page.workshopVisibleRecipes[rowIndex]
            if recipe then
                page.selectedWorkshopRecipe = recipe.key
                GC.UI:RefreshWorkshop()
            end
        end)
        row:SetPoint("TOPLEFT", listCard, "TOPLEFT", 18, -48 - ((index - 1) * 34))
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row, "LEFT", 37, 0)
        row.label:SetPoint("RIGHT", row, "RIGHT", -133, 0)
        row.label:SetJustifyH("LEFT")
        row.professionIcon = row:CreateTexture(nil, "ARTWORK")
        row.professionIcon:SetSize(21, 21)
        row.professionIcon:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.meta = CreateLabel(row, "", { muted = true, align = "RIGHT", width = 96 })
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
    detailCard:SetSize(286, 342)
    detailCard:SetPoint("TOPRIGHT", searchCard, "BOTTOMRIGHT", 0, -12)
    page.workshopRecipeTitle = CreateLabel(detailCard, "Kein Rezept ausgewählt", {
        title = true,
        width = 250,
        height = 45,
        vertical = "TOP",
    })
    page.workshopRecipeTitle:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -49)
    page.workshopFavorite = CreateButton(detailCard, "Merken", 90, 30, function()
        local recipeKey = page.selectedWorkshopRecipe
        if recipeKey then
            GC.Workshop:SetFavorite(recipeKey, not GC.Workshop:IsFavorite(recipeKey))
            GC.UI:RefreshWorkshop()
        end
    end)
    page.workshopFavorite:SetPoint("TOPRIGHT", detailCard, "TOPRIGHT", -14, -12)
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
    page.workshopDetailContent:SetWidth(232)
    page.workshopDetailContent:SetHeight(220)
    page.workshopDetailScroll:SetScrollChild(page.workshopDetailContent)
    page.workshopDetails = CreateLabel(page.workshopDetailContent, "", { width = 232, height = 220, vertical = "TOP" })
    page.workshopDetails:SetPoint("TOPLEFT", page.workshopDetailContent, "TOPLEFT", 0, 0)

    page.workshopStatus = CreateLabel(page,
        "Öffne deine Berufe einmal, damit Guild Copilot die bekannten Rezepte einliest.",
        { muted = true, width = 776 })
    page.workshopStatus:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 0)
end

function GC.UI:RefreshWorkshop()
    local page = self.pages.WORKSHOP
    if not page then
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
            row.meta:SetText(#recipe.crafters .. "  •  " .. recipe.profession)
            row.favoriteIcon:SetShown(GC.Workshop:IsFavorite(recipe.key))
            row:SetActive(page.selectedWorkshopRecipe == recipe.key)
        end
    end

    if not selected then
        page.workshopFavorite:Hide()
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
        page.workshopDetailContent:SetHeight(220)
    else
        page.workshopFavorite:Show()
        page.workshopFavorite:SetText(GC.Workshop:IsFavorite(selected.key) and "Gemerkt" or "Merken")
        page.workshopFavorite:SetActive(GC.Workshop:IsFavorite(selected.key))
        page.workshopRecipeTitle:SetText(selected.name)
        local lines = {
            "|cff91a3b8Beruf|r\n" .. selected.profession,
            "",
            "|cff91a3b8Hersteller|r",
        }
        for _, crafter in ipairs(selected.crafters) do
            lines[#lines + 1] = "• " .. crafter
        end
        lines[#lines + 1] = ""
        lines[#lines + 1] = "|cff91a3b8Materialien|r"
        if #selected.reagents == 0 then
            lines[#lines + 1] = "Keine Reagenzien erfasst."
        else
            for _, reagent in ipairs(selected.reagents) do
                lines[#lines + 1] = (reagent.count or 1) .. "× " .. (reagent.name or ("Item #" .. (reagent.itemID or "?")))
            end
        end
        page.workshopDetails:SetText(table.concat(lines, "\n"))
        local detailHeight = math.max(220, (#lines * 18) + 12)
        page.workshopDetails:SetHeight(detailHeight)
        page.workshopDetailContent:SetHeight(detailHeight)
        page.workshopDetailScroll:SetVerticalScroll(0)
        page.workshopDetailScroll:UpdateModernThumb()
    end

    local missingProfessions = GC.Workshop:GetMissingOwnProfessions()
    local syncStats = GC.Workshop.syncStats or {}
    if #(GC.Workshop.syncQueue or {}) > 0 then
        page.workshopStatus:SetText("|cff2ed9e6Synchronisierung läuft:|r "
            .. #GC.Workshop.syncQueue .. " Pakete verbleiben. Das Fenster kann geschlossen werden.")
        SetTextColor(page.workshopStatus, THEME.accent)
    elseif (syncStats.failed or 0) > 0 then
        page.workshopStatus:SetText("|cffff6266Übertragung unvollständig:|r "
            .. syncStats.failed .. " Pakete konnten auch nach Wiederholungen nicht gesendet werden.")
        SetTextColor(page.workshopStatus, THEME.danger)
    elseif (syncStats.receivedProfessions or 0) > 0 then
        page.workshopStatus:SetText("Empfangen: " .. syncStats.receivedProfessions .. " Berufe mit "
            .. syncStats.receivedRecipes .. " Rezepten"
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
    page.searchButton:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 0)
    page.postResult = CreateLabel(page, "", { width = 535 })
    page.postResult:SetPoint("LEFT", page.searchButton, "RIGHT", 16, 0)

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

    local leadCard = CreateCard(page, "Interessenten")
    leadCard:SetSize(224, 490)
    leadCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)
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

    local detailCard = CreateCard(page, "Unterhaltung")
    detailCard:SetSize(540, 490)
    detailCard:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, -66)
    page.leadTitle = CreateLabel(detailCard, "Kein Bewerber ausgewählt", { title = true })
    page.leadTitle:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -51)
    page.lastMessage = CreateLabel(detailCard, "", { width = 504, height = 52, vertical = "TOP" })
    page.lastMessage:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -86)

    local previewLabel = CreateLabel(detailCard, "Antwortvorschau  •  editierbar", { muted = true })
    previewLabel:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -145)

    local markerLabel = CreateLabel(detailCard, "Symbole", { muted = true })
    markerLabel:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -174)
    page.replyMarkerOff = CreateButton(detailCard, "Aus", 45, 26, function()
        local recruitment = GC.DB:GetGuild().recruitment
        recruitment.replyMarker = 0
        page.replyEdit:SetText(GC.Recruitment:DecorateReply(page.replyEdit:GetText(), 0))
        GC.UI:RefreshInbox()
    end)
    page.replyMarkerOff:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 92, -165)
    page.replyMarkerButtons = {}
    for markerIndex = 1, 8 do
        local selectedMarker = markerIndex
        local markerButton = CreateRaidMarkerButton(detailCard, markerIndex, function()
            local recruitment = GC.DB:GetGuild().recruitment
            recruitment.replyMarker = selectedMarker
            page.replyEdit:SetText(GC.Recruitment:DecorateReply(page.replyEdit:GetText(), selectedMarker))
            GC.UI:RefreshInbox()
        end)
        markerButton:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 146 + ((markerIndex - 1) * 30), -165)
        page.replyMarkerButtons[markerIndex] = markerButton
    end

    page.replyEdit = CreateTextArea(detailCard, 504, 104, 500)
    page.replyEdit.container:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -199)
    page.replyByteCounter = CreateLabel(detailCard, "0/255 Bytes", { muted = true, align = "RIGHT", width = 110 })
    page.replyByteCounter:SetPoint("TOPRIGHT", detailCard, "TOPRIGHT", -18, -310)
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
    thanks:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -322)
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
    page.replyButton:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -366)

    page.inviteButton = CreateButton(detailCard, "In Gilde einladen", 248, 38, function()
        local lead = GC.DB:GetGuild().inbox[GC.UI.selectedLead]
        if lead then
            GC.Chat:Invite(lead.name)
            page.replyResult:SetText("Einladung an " .. lead.name .. " ausgelöst.")
        end
    end)
    page.inviteButton:SetPoint("LEFT", page.replyButton, "RIGHT", 8, 0)
    page.replyResult = CreateLabel(detailCard, "", { width = 504, height = 40, vertical = "TOP" })
    page.replyResult:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -419)
end

function GC.UI:RefreshInbox()
    local page = self.pages.INBOX
    if not page then
        return
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
            button:SetText((lead.unread and "•  " or "") .. GC.Util.PlayerShortName(lead.name))
            button:SetActive(self.selectedLead == index)
        end
    end

    local lead = inbox[self.selectedLead]
    if not lead then
        page.leadTitle:SetText("Noch keine Interessenten")
        page.lastMessage:SetText("Starte eine Suche. Eingehende Flüsternachrichten erscheinen automatisch hier.")
        if not page.replyEdit:HasFocus() then
            page.replyEdit:SetText("")
        end
        page.replyButton:Disable()
        page.inviteButton:Disable()
        return
    end

    page.leadTitle:SetText(GC.Util.PlayerShortName(lead.name))
    local latest = lead.messages[#lead.messages]
    local source = latest and latest.source and latest.source ~= "WHISPER" and ("  •  " .. latest.source) or ""
    page.lastMessage:SetText(latest and ("Letzte Nachricht" .. source .. "\n\"" .. latest.text .. "\"") or "")
    page.replyButton:Enable()
    page.inviteButton:Enable()
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
    sourceCard:SetSize(776, 150)
    sourceCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -66)
    page.wclURL = CreateEdit(sourceCard, 740, 38)
    page.wclURL.container:SetPoint("TOPLEFT", sourceCard, "TOPLEFT", 18, -49)

    local detect = CreateButton(sourceCard, "Aus Gilde erkennen", 170, 34, function()
        page.wclURL:SetText(GC.WarcraftLogs:GetSuggestedURL())
        page.wclResult:SetText("Link aus Region, Realm und Gildenname vorbereitet.")
        SetTextColor(page.wclResult, THEME.muted)
    end)
    detect:SetPoint("TOPLEFT", sourceCard, "TOPLEFT", 18, -102)
    local save = CreateButton(sourceCard, "Quelle speichern", 160, 34, function()
        local success, message = GC.WarcraftLogs:SaveSource(page.wclURL:GetText())
        page.wclResult:SetText(message or "")
        SetTextColor(page.wclResult, success and THEME.success or THEME.danger)
        GC.UI:RefreshWarcraftLogs()
    end, "PRIMARY")
    save:SetPoint("LEFT", detect, "RIGHT", 8, 0)
    page.wclResult = CreateLabel(sourceCard, "", { width = 385 })
    page.wclResult:SetPoint("LEFT", save, "RIGHT", 14, 0)

    local importCard = CreateCard(page, "Import – manuell oder Companion")
    importCard:SetSize(776, 238)
    importCard:SetPoint("TOPLEFT", sourceCard, "BOTTOMLEFT", 0, -10)
    local importHelp = CreateLabel(importCard,
        "Ohne API: Name;Klasse;Primär-Spec;Dual-Spec – z. B. Nexarius;Magier;Arkan;Frost.\nAutomatisch: Außerhalb von WoW Companion\\Start-WCL-Import.cmd doppelklicken; danach hier mit Strg+V einfügen.",
        { muted = true, width = 740, height = 44, vertical = "TOP" })
    importHelp:SetPoint("TOPLEFT", importCard, "TOPLEFT", 18, -46)
    page.wclImport = CreateTextArea(importCard, 740, 82, 12000)
    page.wclImport.container:SetPoint("TOPLEFT", importCard, "TOPLEFT", 18, -92)
    page.wclImport:SetText("")
    local import = CreateButton(importCard, "Daten importieren", 170, 36, function()
        local success, message = GC.WarcraftLogs:Import(page.wclImport:GetText())
        page.wclImportResult:SetText(message or "")
        SetTextColor(page.wclImportResult, success and THEME.success or THEME.danger)
        GC.UI:RefreshWarcraftLogs()
    end, "PRIMARY")
    import:SetPoint("BOTTOMLEFT", importCard, "BOTTOMLEFT", 18, 14)
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
    local imported = GC.WarcraftLogs:GetImportedCount()
    if imported > 0 then
        page.wclStatus:SetText("|cff59e695" .. imported .. " Spielerprofile verfügbar|r"
            .. (data.reportCount > 0 and ("  •  " .. data.reportCount .. " Reports") or "")
            .. "\nDiese Specs ergänzen jetzt automatisch die Roster- und Copilot-Auswertung.")
    else
        page.wclStatus:SetText("|cff91a3b8Noch keine Log-Daten importiert.|r\nDie gespeicherte URL ist für den Companion vorbereitet.")
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
        "Sitzungen laufen ausdrücklich durch Raidleiter, Assistenten oder berechtigte Gildenränge. Es werden nur Zusammenfassungen gespeichert, keine Rohdaten.")

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

    local listCard = CreateCard(page, "Sitzungen")
    listCard:SetSize(238, 358)
    listCard:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -172)
    page.sessionRows = {}
    for index = 1, 12 do
        local row = CreateButton(listCard, "", 206, 23, function()
            local summary = GC.RaidMonitor:GetSummaries()[index]
            if summary then
                GC.RaidMonitor.selectedSessionID = summary.id
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
    page.sessionHeadline = CreateLabel(detailCard, "", { muted = true, width = 380, height = 18 })
    page.sessionHeadline:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -44)

    local detailHeaders = {
        { text = "SPIELER", x = 18, width = 104 },
        { text = "DABEI", x = 126, width = 52 },
        { text = "TODE", x = 182, width = 42 },
        { text = "INT", x = 226, width = 36 },
        { text = "DISP", x = 264, width = 40 },
        { text = "TRÄNKE", x = 306, width = 58 },
        { text = "FLASK", x = 366, width = 48 },
        { text = "ESSEN", x = 416, width = 50 },
        { text = "TROMM", x = 468, width = 54 },
    }
    for _, headerDefinition in ipairs(detailHeaders) do
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
    content:SetHeight(1100)
    scroll:SetScrollChild(content)

    page.participantRows = {}
    for index = 1, 40 do
        local row = CreatePanel(content, index % 2 == 0 and THEME.input or THEME.card)
        row:SetSize(490, 25)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * 27))
        local columns = {
            { key = "name", x = 5, width = 104 },
            { key = "presence", x = 113, width = 52 },
            { key = "deaths", x = 169, width = 42 },
            { key = "interrupts", x = 213, width = 36 },
            { key = "dispels", x = 251, width = 40 },
            { key = "potions", x = 293, width = 58 },
            { key = "flasks", x = 353, width = 48 },
            { key = "food", x = 403, width = 50 },
            { key = "drums", x = 455, width = 54 },
        }
        for _, column in ipairs(columns) do
            row[column.key] = CreateLabel(row, "", { width = column.width })
            row[column.key]:SetPoint("LEFT", row, "LEFT", column.x, 0)
        end
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
        page.sessionStatus:SetText("|cff59e695Sitzung läuft|r  •  " .. participantCount .. " Teilnehmer  •  "
            .. #session.pulls .. " Versuche\nGestartet von " .. (session.startedBy ~= "" and session.startedBy or "unbekannt")
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

    local summaries = monitor:GetSummaries()
    page.sessionEmpty:SetShown(#summaries == 0)
    local selectedID = monitor.selectedSessionID
    if not monitor:GetSummary(selectedID) then
        selectedID = summaries[1] and summaries[1].id
        monitor.selectedSessionID = selectedID
    end

    for index, row in ipairs(page.sessionRows) do
        local summary = summaries[index]
        row:SetShown(summary ~= nil)
        if summary then
            local zone = summary.zone ~= "" and summary.zone or "Raid"
            if summary.source == "WCL" then
                zone = "[Logs] " .. zone
            end
            row:SetText(FormatSessionDate(summary) .. "  " .. zone)
            row:SetActive(summary.id == selectedID)
        end
    end

    local selected = monitor:GetSummary(selectedID)
    page.participantEmpty:SetShown(selected == nil)
    if selected then
        page.sessionHeadline:SetText(FormatSessionDate(selected)
            .. "  •  " .. FormatDuration((selected.endedAt or 0) - (selected.startedAt or 0))
            .. "  •  " .. (selected.pulls or 0) .. " Versuche, " .. (selected.kills or 0) .. " Siege, "
            .. (selected.wipes or 0) .. " Wipes  •  Quelle: "
            .. SESSION_SOURCE_LABEL[selected.source or "LIVE"])
    else
        page.sessionHeadline:SetText("")
    end

    local participants = selected and selected.participants or {}
    for index, row in ipairs(page.participantRows) do
        local participant = participants[index]
        row:SetShown(participant ~= nil)
        if participant then
            local consumables = participant.consumables or {}
            row.name:SetText(participant.name)
            row.name:SetTextColor(ClassColor(participant.classFile))
            row.presence:SetText(FormatDuration(participant.seconds))
            row.deaths:SetText(participant.deaths or 0)
            row.interrupts:SetText(participant.interrupts or 0)
            row.dispels:SetText(participant.dispels or 0)
            row.potions:SetText(consumables.POTION or 0)
            row.flasks:SetText(consumables.FLASK or 0)
            row.food:SetText(consumables.FOOD or 0)
            row.drums:SetText(consumables.DRUM or 0)
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
        "Fehlende Verzauberungen und leere Sockel je Slot. Geprüft wird per Inspect, also nur wer in Reichweite und erreichbar ist. Es gibt bewusst keine Gesamtnote.")

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
        local ok, message = GC.GearAudit:StartRaidScan()
        page:SetGearStatus(message, ok)
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
    page.gearRows = {}
    for index = 1, 12 do
        local row = CreateButton(listCard, "", 206, 23, function()
            local audit = GC.GearAudit:GetAudits()[index]
            if audit then
                GC.GearAudit.selectedName = audit.name
                GC.UI:RefreshGear()
            end
        end)
        row:SetPoint("TOPLEFT", listCard, "TOPLEFT", 16, -50 - ((index - 1) * 25))
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.label:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        row.label:SetJustifyH("LEFT")
        page.gearRows[index] = row
    end
    page.gearEmpty = CreateLabel(listCard, "Noch niemand geprüft.", { muted = true, width = 200, height = 40, vertical = "TOP" })
    page.gearEmpty:SetPoint("TOPLEFT", listCard, "TOPLEFT", 16, -52)

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
        headerLabel:SetPoint("TOPLEFT", detailCard, "TOPLEFT", headerDefinition.x, -66)
    end

    local scroll = CreateModernScrollFrame(detailCard)
    scroll:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 14, -86)
    scroll:SetPoint("BOTTOMRIGHT", detailCard, "BOTTOMRIGHT", -16, 14)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(492)
    content:SetHeight(560)
    scroll:SetScrollChild(content)

    page.gearSlotRows = {}
    for index = 1, #GC.GearSlots do
        local row = CreatePanel(content, index % 2 == 0 and THEME.input or THEME.card)
        row:SetSize(490, 25)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * 27))
        row.slot = CreateLabel(row, "", { width = 112 })
        row.slot:SetPoint("LEFT", row, "LEFT", 5, 0)
        row.verdict = CreateLabel(row, "", { width = 96 })
        row.verdict:SetPoint("LEFT", row, "LEFT", 121, 0)
        row.sockets = CreateLabel(row, "", { width = 58 })
        row.sockets:SetPoint("LEFT", row, "LEFT", 221, 0)
        row.reason = CreateLabel(row, "", { width = 214, muted = true })
        row.reason:SetPoint("LEFT", row, "LEFT", 283, 0)
        page.gearSlotRows[index] = row
    end
    page.gearSlotEmpty = CreateLabel(detailCard, "Wähle links einen Spieler aus.", { muted = true, width = 400, height = 40, vertical = "TOP" })
    page.gearSlotEmpty:SetPoint("TOPLEFT", detailCard, "TOPLEFT", 18, -66)
end

function GC.UI:RefreshGear()
    local page = self.pages.GEAR
    if not page then
        return
    end

    local audits = GC.GearAudit:GetAudits()
    local ruleCount = 0
    for _ in pairs(GC.EnchantRuleSet.rules) do
        ruleCount = ruleCount + 1
    end
    local overview = GC.GearAudit:GetOverview()
    local statusText = GC.GearAudit.status
    if statusText == "" then
        statusText = "Noch keine Prüfung gelaufen."
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
    end
    page.gearStatus:SetText(statusText .. "\n"
        .. (ruleCount > 0
            and ("Regelsatz v" .. GC.EnchantRuleSet.version .. " mit " .. ruleCount .. " bewerteten Verzauberungen.")
            or "|cffffb840Der Regelsatz ist noch leer: fehlende Verzauberungen und leere Sockel werden exakt erkannt, vorhandene Verzauberungen bleiben \"Unbekannt\".|r"))

    page.gearEmpty:SetShown(#audits == 0)
    local selectedName = GC.GearAudit.selectedName
    if not GC.GearAudit:GetAudit(selectedName) then
        selectedName = audits[1] and audits[1].name
        GC.GearAudit.selectedName = selectedName
    end

    for index, row in ipairs(page.gearRows) do
        local audit = audits[index]
        row:SetShown(audit ~= nil)
        if audit then
            local issues = (audit.missingEnchants or 0) + (audit.emptySockets or 0)
            row:SetText(audit.name .. (issues > 0 and ("  •  " .. issues .. " Funde") or "  •  ok"))
            row:SetActive(audit.name == selectedName)
        end
    end

    local selected = GC.GearAudit:GetAudit(selectedName)
    page.gearSlotEmpty:SetShown(selected == nil)
    if selected then
        local ageMinutes = math.max(0, math.floor((GC.Util.Now() - (selected.inspectedAt or 0)) / 60))
        page.gearHeadline:SetText((selected.source == "SELF" and "Eigene Ausrüstung" or "Inspect")
            .. "  •  vor " .. ageMinutes .. " Min.  •  Regelsatz v" .. (selected.ruleVersion or 0)
            .. "  •  " .. GC.GearAudit:DescribeFindings(selected))
        page.gearFindings:SetText(self:FormatGearFindings(selected, 3))
    else
        page.gearHeadline:SetText("")
        page.gearFindings:SetText("")
    end

    local slots = selected and selected.slots or {}
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

function GC.UI:Refresh()
    if not self.frame then
        return
    end
    self:RefreshNavigationAccess()
    self:RefreshDashboard()
    self:RefreshSettings()
    self:RefreshRoster()
    self:RefreshMemberCare()
    self:RefreshWorkshop()
    self:RefreshSuggestions()
    self:RefreshRecruitment()
    self:RefreshPost()
    self:RefreshInbox()
    self:RefreshGuild()
    self:RefreshWarcraftLogs()
    self:RefreshStatistics()
    self:RefreshGear()
end

function GC.UI:AddGuildWindowButton()
    if self.guildButton or not GuildFrame then
        return
    end
    local button = CreateButton(GuildFrame, "Guild Copilot", 124, 24, function()
        self:Toggle()
    end, "PRIMARY")
    button:SetPoint("TOPRIGHT", GuildFrame, "TOPRIGHT", -32, -30)
    button:SetFrameStrata("HIGH")
    self.guildButton = button
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

function GC.UI:PositionMinimapButton()
    local button = self.minimapButton
    if not button or not Minimap then
        return
    end
    local settings = GC.DB:GetSettings().minimap
    local angle = math.rad(tonumber(settings.angle) or 225)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * 78, math.sin(angle) * 78)
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
        GameTooltip:AddLine("Linksklick: öffnen/schließen", 1, 1, 1)
        GameTooltip:AddLine("Rechtsklick: Einstellungen", 1, 1, 1)
        GameTooltip:AddLine("Ziehen: Position ändern", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local minimapX, minimapY = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale() or 1
            local cursorX, cursorY = GetCursorPosition()
            if not minimapX or not minimapY or not cursorX or not cursorY then
                return
            end
            cursorX = cursorX / scale
            cursorY = cursorY / scale
            GC.DB:GetSettings().minimap.angle = math.deg(MinimapAngle(cursorY - minimapY, cursorX - minimapX))
            GC.UI:PositionMinimapButton()
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    self.minimapButton = button
    self:RefreshMinimapButton()
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

    local commandLabel = CreateLabel(panel, "Chat-Befehl", {
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
    panel.openButton:SetPoint("TOP", command, "BOTTOM", 0, -24)

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
SlashCmdList.GUILDCOPILOT = function()
    GC.UI:Toggle()
end

local uiEvents = CreateFrame("Frame")
uiEvents:RegisterEvent("ADDON_LOADED")
uiEvents:SetScript("OnEvent", function()
    GC.UI:AddGuildWindowButton()
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.UI, function(self)
    self:CreateMainFrame()
    self:AddGuildWindowButton()
    self:AddMinimapButton()
    self:RegisterInterfaceOptions()
end)

GC:RegisterCallback("ROSTER_UPDATED", GC.UI, function(self)
    self:Refresh()
end)

GC:RegisterCallback("PROFILE_UPDATED", GC.UI, function(self)
    self:RefreshDashboard()
    self:RefreshRoster()
    self:RefreshMemberCare()
    self:RefreshSuggestions()
end)

GC:RegisterCallback("SETTINGS_UPDATED", GC.UI, function(self)
    self:RefreshSettings()
    self:RefreshGuild()
    self:RefreshNavigationAccess()
end)

GC:RegisterCallback("GUILD_PROFILE_UPDATED", GC.UI, function(self)
    self:RefreshGuild()
    self:RefreshSettings()
    self:RefreshMemberCare()
    self:RefreshNavigationAccess()
    self:RefreshSuggestions()
    self:RefreshPost()
    self:RefreshInbox()
end)

GC:RegisterCallback("WORKSHOP_UPDATED", GC.UI, function(self)
    self:RefreshWorkshop()
end)

GC:RegisterCallback("RECRUITMENT_UPDATED", GC.UI, function(self)
    self:RefreshRecruitment()
end)

GC:RegisterCallback("INBOX_UPDATED", GC.UI, function(self)
    self:RefreshInbox()
end)

GC:RegisterCallback("WCL_UPDATED", GC.UI, function(self)
    self:RefreshWarcraftLogs()
    self:RefreshSuggestions()
end)

GC:RegisterCallback("ROSTER_FILTER_UPDATED", GC.UI, function(self)
    self:RefreshDashboard()
    self:RefreshSettings()
end)

GC:RegisterCallback("MEMBERCARE_UPDATED", GC.UI, function(self)
    self:RefreshMemberCare()
end)

GC:RegisterCallback("ADDON_USERS_UPDATED", GC.UI, function(self)
    self:RefreshDashboard()
end)

GC:RegisterCallback("RAID_SESSION_UPDATED", GC.UI, function(self)
    self:RefreshStatistics()
end)

GC:RegisterCallback("GEAR_AUDIT_UPDATED", GC.UI, function(self)
    self:RefreshGear()
    self:RefreshProfileGear()
end)
