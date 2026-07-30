local Dummy = {}
-- WoW-Widgetmethoden beginnen mit einem Großbuchstaben, vom Addon gesetzte
-- Datenfelder (scripts, choiceIcon, label, ...) mit einem Kleinbuchstaben.
-- Nur Methoden dürfen ersatzweise als Funktion zurückkommen; unbelegte
-- Datenfelder müssen wie in WoW nil bleiben, damit Prüfungen der Form
-- "if widget.choiceIcon then" nicht fälschlich zutreffen.
Dummy.__index = function(self, key)
    if key == "GetText" then
        return function(frame)
            return frame.value or ""
        end
    elseif key == "SetText" then
        return function(frame, value)
            frame.value = tostring(value or "")
            if frame.scripts and frame.scripts.OnTextChanged then
                frame.scripts.OnTextChanged(frame)
            end
        end
    elseif key == "GetChecked" then
        return function(frame)
            return frame.checked == true
        end
    elseif key == "SetChecked" then
        return function(frame, value)
            frame.checked = value == true
        end
    elseif key == "IsShown" then
        return function(frame)
            return frame.shown == true
        end
    elseif key == "SetVerticalScroll" then
        return function(frame, value)
            frame.verticalScroll = tonumber(value) or 0
        end
    elseif key == "GetVerticalScroll" then
        return function(frame)
            return frame.verticalScroll or 0
        end
    elseif key == "SetHeight" then
        -- Fuer Layouttests: die gesetzte Hoehe bleibt ablesbar.
        return function(frame, value)
            frame.height = tonumber(value)
        end
    elseif key == "GetHeight" then
        return function(frame)
            return frame.height
        end
    elseif key == "SetShown" then
        return function(frame, value)
            frame.shown = value == true
        end
    elseif key == "Show" then
        return function(frame)
            frame.shown = true
        end
    elseif key == "Hide" then
        return function(frame)
            frame.shown = false
        end
    elseif key == "HasFocus" then
        return function()
            return false
        end
    elseif key == "SetScript" then
        return function(frame, event, callback)
            frame.scripts = frame.scripts or {}
            frame.scripts[event] = callback
        end
    elseif key == "CreateFontString" then
        return function()
            return setmetatable({}, Dummy)
        end
    elseif key == "CreateTexture" then
        return function()
            return setmetatable({}, Dummy)
        end
    end
    if type(key) ~= "string" or not key:match("^%u") then
        return nil
    end
    return function()
    end
end

UIParent = setmetatable({}, Dummy)
GuildFrame = setmetatable({}, Dummy)
Minimap = setmetatable({}, Dummy)
function Minimap:GetCenter()
    return 0, 0
end
function Minimap:GetEffectiveScale()
    return 1
end
function GetCursorPosition()
    return 0, 0
end
UISpecialFrames = {}
SlashCmdList = {}
SOUNDKIT = { READY_CHECK = 8960 }
EMPTY_SOCKET_RED = "Roter Sockel"
EMPTY_SOCKET_YELLOW = "Gelber Sockel"
EMPTY_SOCKET_BLUE = "Blauer Sockel"
local optionsCategory
function InterfaceOptions_AddCategory(panel)
    optionsCategory = panel
end
chatMessages = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, message)
    chatMessages[#chatMessages + 1] = tostring(message)
end }

-- Tooltipzeilen je Item-Link, damit die Verzauberungsaufloesung pruefbar ist.
tooltipLines = {}

function CreateFrame(_, name)
    local frame = setmetatable({ shown = false, scripts = {} }, Dummy)
    if name then
        _G[name] = frame
    end
    if name == "GuildCopilotScanTooltip" then
        frame.lines = {}
        function frame:ClearLines()
            self.lines = {}
        end
        function frame:SetHyperlink(link)
            self.lines = tooltipLines[link] or {}
            for index = 1, 12 do
                local text = self.lines[index]
                _G[name .. "TextLeft" .. index] = text and {
                    GetText = function()
                        return text
                    end,
                } or nil
            end
        end
        function frame:NumLines()
            return #self.lines
        end
    end
    return frame
end

function UnitFullName()
    return "Tester", "Realm"
end

unitNames = { player = "Tester" }
function UnitName(unit)
    return unitNames[unit] or "Tester"
end

unitClasses = { player = "HUNTER" }
function UnitClass(unit)
    return "Jäger", unitClasses[unit] or "HUNTER", 3
end

function UnitLevel()
    return 70
end

function UnitSex()
    return 2
end

function GetNormalizedRealmName()
    return "Realm"
end

function GetGuildInfo()
    return "Testgilde"
end

function IsInGuild()
    return true
end

function GetTalentTabInfo(index)
    local points = ({ 10, 41, 0 })[index]
    return index, "Baum " .. index, "", 0, points, ""
end

function GetNumGuildMembers()
    return 2
end

-- Der Client loest Klassen ueber die GUID auf. Direkt nach dem Login ist der
-- Cache leer, deshalb kann der Aufruf auch nichts liefern.
playerInfoByGUID = {
    ["Player-4"] = { "Paladin", "PALADIN" },
}
function GetPlayerInfoByGUID(guid)
    local entry = playerInfoByGUID[guid or ""]
    if not entry then
        return nil
    end
    return entry[1], entry[2], "Mensch", "Human", "male", "Interessent", "Realm"
end

function GetGuildRosterInfo(index)
    if index == 1 then
        return "Tester-Realm", "Offizier", 1, 70, "Jäger", "Shattrath", "", "", true, 0, "HUNTER", 0, 0, false, false, 0, "Player-1"
    end
    return "Heiler-Realm", "Mitglied", 5, 70, "Priester", "Shattrath", "", "", false, 0, "PRIEST", 0, 0, false, false, 0, "Player-2"
end

function GetGuildRosterLastOnline(index)
    if index == 2 then
        return 0, 0, 10, 0
    end
    return 0, 0, 0, 0
end

function GetProfessions()
    return 1, 2
end

function GetProfessionInfo(index)
    if index == 1 then
        return "Ingenieurskunst", "", 375, 375, 0, 0, 202
    elseif index == 2 then
        return "Bergbau", "", 360, 375, 0, 0, 186
    end
end

function GetTradeSkillLine()
    return "Schneiderei", 375, 375
end

local tradeSkillExpanded = false
local tradeSkillFilterResets = 0

function ExpandTradeSkillSubClass(index)
    if index == 1 then
        tradeSkillExpanded = true
    end
end

function SetTradeSkillInvSlotFilter()
    tradeSkillFilterResets = tradeSkillFilterResets + 1
end

function SetTradeSkillSubClassFilter()
    tradeSkillFilterResets = tradeSkillFilterResets + 1
end

function SetTradeSkillItemNameFilter()
    tradeSkillFilterResets = tradeSkillFilterResets + 1
end

function SetTradeSkillItemLevelFilter()
    tradeSkillFilterResets = tradeSkillFilterResets + 1
end

function TradeSkillOnlyShowSkillUps()
    tradeSkillFilterResets = tradeSkillFilterResets + 1
end

function TradeSkillOnlyShowMakeable()
    tradeSkillFilterResets = tradeSkillFilterResets + 1
end

function GetNumTradeSkills()
    return tradeSkillExpanded and 3 or 1
end

function GetTradeSkillInfo(index)
    if index == 1 then
        return "Taschen", "header", nil, tradeSkillExpanded
    elseif index == 2 then
        return "Mondstofftasche", "optimal"
    elseif index == 3 then
        return "Runenstoffballen", "trivial"
    end
end

function GetTradeSkillItemLink(index)
    if index == 2 then
        return "|cffffffff|Hitem:14155:0:0:0:0:0:0:0|h[Mondstofftasche]|h|r"
    elseif index == 3 then
        return "|cffffffff|Hitem:14048:0:0:0:0:0:0:0|h[Runenstoffballen]|h|r"
    end
end

function GetTradeSkillRecipeLink(index)
    return index == 2 and "|Henchant:18445|h[Mondstofftasche]|h" or "|Henchant:18401|h[Runenstoffballen]|h"
end

function GetTradeSkillNumReagents(index)
    return index == 2 and 2 or 1
end

function GetTradeSkillReagentInfo(index, reagentIndex)
    if index == 2 and reagentIndex == 1 then
        return "Runenstoffballen", "", 4, 20
    elseif index == 2 and reagentIndex == 2 then
        return "Mondstoff", "", 2, 4
    end
    return "Runenstoff", "", 5, 40
end

function GetTradeSkillReagentItemLink(index, reagentIndex)
    if index == 2 and reagentIndex == 1 then
        return "|Hitem:14048|h[Runenstoffballen]|h"
    elseif index == 2 and reagentIndex == 2 then
        return "|Hitem:14342|h[Mondstoff]|h"
    end
    return "|Hitem:14047|h[Runenstoff]|h"
end

function GetCraftSkillLine()
    return "Verzauberkunst", 375, 375
end

function GetCraftDisplaySkillLine()
    return "Verzauberkunst"
end

function GetNumCrafts()
    return 2
end

function GetCraftInfo(index)
    if index == 1 then
        return "Ringverzauberungen", "", "header"
    end
    return "Ring - Heilkraft", "", "optimal"
end

function GetCraftItemLink(index)
    if index == 2 then
        return "|Henchant:27926|h[Ring - Heilkraft]|h"
    end
end

function GetCraftNumReagents(index)
    return index == 2 and 1 or 0
end

function GetCraftReagentInfo(index, reagentIndex)
    if index == 2 and reagentIndex == 1 then
        return "Großer prismatischer Splitter", "", 2, 8
    end
end

function GetCraftReagentItemLink(index, reagentIndex)
    if index == 2 and reagentIndex == 1 then
        return "|Hitem:22449|h[Großer prismatischer Splitter]|h"
    end
end

function GetItemInfo(itemID)
    local names = {
        [14047] = "Runenstoff",
        [14048] = "Runenstoffballen",
        [14155] = "Mondstofftasche",
        [14342] = "Mondstoff",
        [22449] = "Großer prismatischer Splitter",
    }
    return names[tonumber(itemID)]
end

raidRoster = {}

function IsInRaid()
    return #raidRoster > 0
end

function IsInGroup()
    return #raidRoster > 0 or #partyRoster > 0
end

partyRoster = {}

function GetNumGroupMembers()
    if #raidRoster > 0 then
        return #raidRoster
    end
    return #partyRoster
end

-- name, rank, subgroup, level, class, fileName
function GetRaidRosterInfo(index)
    local member = raidRoster[index]
    if not member then
        return nil
    end
    return member[1], member[2], 1, 70, "", member[3]
end

function GetRealZoneText()
    return "Karazhan"
end

local combatLogEvent = {}
function CombatLogGetCurrentEventInfo()
    return unpack(combatLogEvent)
end

-- Baut ein Combat-Log-Ereignis in der Reihenfolge des echten Clients auf.
function FireCombatLog(subevent, sourceName, destName, spellID, destGUID)
    combatLogEvent = {
        1000, subevent, false,
        "Player-" .. tostring(sourceName), sourceName, 0, 0,
        destGUID or ("Player-" .. tostring(destName)), destName, 0, 0,
        spellID,
    }
    GuildCopilot.RaidMonitor:OnCombatLogEvent()
end

-- Ausrüstung je Slot-ID und Einheit für den Gear Audit.
inspectGear = {}
inspectGearItemIDs = {}

function GetInventoryItemLink(unit, slotID)
    return (inspectGear[unit] or {})[slotID]
end

function GetInventoryItemID(unit, slotID)
    local explicit = (inspectGearItemIDs[unit] or {})[slotID]
    if explicit then
        return explicit
    end
    return tonumber(tostring(GetInventoryItemLink(unit, slotID) or ""):match("item:(%d+)"))
end

function GetItemStats(link)
    local sockets = tonumber(tostring(link or ""):match("SOCKETS(%d)"))
    if not sockets then
        return {}
    end
    return { EMPTY_SOCKET_RED = sockets }
end

function UnitExists(unit)
    return (inspectGear[unit] ~= nil) or (unitNames[unit] ~= nil) or unit == "player"
end

function UnitIsUnit(left, right)
    return left == right
end

function UnitGUID(unit)
    return "GUID-" .. tostring(unit)
end

inspectableUnits = {}
function CanInspect(unit)
    return inspectableUnits[unit] ~= false
end

function NotifyInspect()
end

canRemoveFromGuild = true
function CanGuildRemove()
    return canRemoveFromGuild
end

uninvitedPlayers = {}
function GuildUninvite(name)
    uninvitedPlayers[#uninvitedPlayers + 1] = name
end

function ClearInspectPlayer()
end

function GetChannelList()
    return 1, "Allgemein", false, 2, "Handel", false, 4, "SucheNachGruppe", false, 5, "Gildenrekrutierung", false
end

local playedSoundID
function PlaySound(soundID)
    playedSoundID = soundID
end

-- Stellbare Uhr, damit Mindestabstände und Cooldowns prüfbar sind.
currentTime = 1000
function time()
    return currentTime
end

function date()
    return "2026-07-27"
end

-- Zeitgeber laufen sofort. Wer eine echte Verzoegerung braucht, setzt
-- timerDelayThreshold: alles darueber wandert in pendingTimers statt zu feuern.
timerDelayThreshold = math.huge
pendingTimers = {}
C_Timer = {
    After = function(delay, callback)
        if (tonumber(delay) or 0) > timerDelayThreshold then
            pendingTimers[#pendingTimers + 1] = callback
            return
        end
        callback()
    end,
}

local sentChat = {}
local sentAddon = {}
local addonSendFailures = 0
C_ChatInfo = {
    RegisterAddonMessagePrefix = function()
        return true
    end,
    SendAddonMessage = function(prefix, message, distribution, target)
        if addonSendFailures > 0 then
            addonSendFailures = addonSendFailures - 1
            return false
        end
        sentAddon[#sentAddon + 1] = { prefix, message, distribution, target }
        return true
    end,
    SendChatMessage = function(message, chatType, language, target)
        sentChat[#sentChat + 1] = { message, chatType, language, target }
    end,
}

C_GuildInfo = {
    GuildRoster = function()
    end,
    Invite = function()
    end,
}

-- Taschen, eigene Bank und Gildenbank. Der Anniversary-Client bietet nur die
-- klassischen Globalen, deshalb wird genau dieser Pfad nachgebildet.
bagContents = {
    [0] = { { itemID = 22445, count = 20 }, { itemID = 22446, count = 5 } },
}
bankContents = {
    [-1] = { { itemID = 22446, count = 9 } },
}
guildBankContents = {
    [1] = { { itemID = 22446, count = 32 }, { itemID = 22447, count = 4 } },
}
guildBankTabCount = 1
guildBankTabViewable = true
function GetContainerNumSlots(container)
    local source = bagContents[container] or bankContents[container]
    return source and #source or 0
end
function GetContainerItemLink(container, slot)
    local source = bagContents[container] or bankContents[container]
    local entry = source and source[slot]
    return entry and ("|cffffffff|Hitem:" .. entry.itemID .. "::::::::70|h[Material]|h|r") or nil
end
function GetContainerItemInfo(container, slot)
    local source = bagContents[container] or bankContents[container]
    local entry = source and source[slot]
    if not entry then
        return nil
    end
    return "texture", entry.count
end
function GetNumGuildBankTabs()
    return guildBankTabCount
end
function GetGuildBankTabInfo(tabIndex)
    return "Mats " .. tabIndex, "icon", guildBankTabViewable, true
end
function QueryGuildBankTab()
end
function GetCurrentGuildBankTab()
    return 1
end
function GetGuildBankItemLink(tabIndex, slot)
    local entry = (guildBankContents[tabIndex] or {})[slot]
    return entry and ("|cffffffff|Hitem:" .. entry.itemID .. "::::::::70|h[Material]|h|r") or nil
end
function GetGuildBankItemInfo(tabIndex, slot)
    local entry = (guildBankContents[tabIndex] or {})[slot]
    if not entry then
        return nil
    end
    return "texture", entry.count
end

local addon = {}
local files = {
    "Constants.lua",
    "Core.lua",
    "Database.lua",
    "Profile.lua",
    "WarcraftLogs.lua",
    "Roster.lua",
    "Inventory.lua",
    "Workshop.lua",
    "RaidMonitor.lua",
    "GearAudit.lua",
    "Sync.lua",
    "Recruitment.lua",
    "Chat.lua",
    "UI.lua",
}

for _, file in ipairs(files) do
    local chunk = assert(loadfile("GuildCopilot/" .. file))
    chunk("GuildCopilot", addon)
end

addon:FireCallback("ADDON_LOADED")
addon:FireCallback("PLAYER_LOGIN")

local repairedDefaults = addon.Util.MergeDefaults({
    settings = "beschädigt",
}, {
    settings = {
        enabled = true,
    },
})
assert(type(repairedDefaults.settings) == "table" and repairedDefaults.settings.enabled == true,
    "Ein beschädigter SavedVariables-Zweig wurde nicht durch seine Standardwerte repariert")

local utf8Clipped = addon.Util.SafeChatText("123äXYZQ", 8)
assert(utf8Clipped == "123ä...", "Ein vollständiges UTF-8-Zeichen wurde beim Kürzen entfernt")
assert(#utf8Clipped == 8, "Die UTF-8-Kürzung hält das Byte-Limit nicht ein")

assert(addon.Profile:Get().detectedSpecKey == "HUNTER:2", "Talentbaum wurde nicht erkannt")
assert(addon.Profile:Get().professions[1].name == "Ingenieurskunst", "Erster Beruf wurde nicht erkannt")
assert(addon.Profile:Get().professions[2].name == "Bergbau", "Zweiter Beruf wurde nicht erkannt")
assert(addon.Roster:GetSummary().total == 2, "Roster wurde nicht eingelesen")
assert(#addon.Roster:GetActiveRaiders(25) == 2, "Aktive Level-70-Spieler wurden nicht aufgelistet")
addon.Roster:SetRankActive(1, false)
assert(#addon.Roster:GetActiveRaiders(25) == 1, "Abgewählter Gildenrang erscheint noch als aktiver Raider")
assert(addon.Roster:GetActiveRaiders(25)[1].name == "Heiler-Realm", "Rangfilter zeigt den falschen Raider")
addon.Roster:SetAllRanksActive(true)
assert(#addon.Roster:GetActiveRaiders(25) == 2, "Alle Gildenränge wurden nicht wieder aktiviert")
assert(addon.UI.frame ~= nil, "Hauptfenster wurde nicht erstellt")
assert(optionsCategory == addon.UI.optionsPanel, "Guild Copilot wurde nicht in den Addon-Optionen registriert")
assert(optionsCategory.scripts.OnShow == nil, "Addon-Option darf das Hauptfenster nicht automatisch öffnen")
optionsCategory.openButton.scripts.OnClick()
assert(addon.UI.frame.shown == true, "Options-Button öffnet das Guild-Copilot-Fenster nicht")
addon.UI.frame.scripts.OnKeyDown(addon.UI.frame, "ESCAPE")
assert(addon.UI.frame.shown == false, "Escape schließt das Guild-Copilot-Fenster nicht")
addon.UI.frame:Show()
assert(addon.UI.minimapButton ~= nil, "Minimap-Symbol wurde nicht erstellt")
assert(addon.UI.minimapButton.shown == true, "Minimap-Symbol ist trotz aktiver Einstellung verborgen")
addon.UI.pages.SETTINGS.minimapToggle:SetChecked(false)
addon.UI.pages.SETTINGS.minimapToggle.scripts.OnClick(addon.UI.pages.SETTINGS.minimapToggle)
assert(addon.DB:GetSettings().minimap.hidden == true, "Minimap-Einstellung wurde nicht gespeichert")
assert(addon.UI.minimapButton.shown == false, "Minimap-Symbol wurde nicht ausgeblendet")
addon.UI.pages.SETTINGS.minimapToggle:SetChecked(true)
addon.UI.pages.SETTINGS.minimapToggle.scripts.OnClick(addon.UI.pages.SETTINGS.minimapToggle)
assert(addon.UI.minimapButton.shown == true, "Minimap-Symbol wurde nicht wieder eingeblendet")
local warriorHeader = addon.UI.pages.RECRUITMENT.classRows.WARRIOR.header
warriorHeader.scripts.OnClick()
assert(addon.UI.pages.RECRUITMENT.expandedClass == "WARRIOR", "Klassenkarte wurde nicht geöffnet")
warriorHeader.scripts.OnClick()
assert(addon.UI.pages.RECRUITMENT.expandedClass == nil, "Klassenkarte wurde beim zweiten Klick nicht geschlossen")
assert(addon.UI.pages.POST.channelChecks.RECRUITMENT.mark.shown == true, "Aktiver Chatkanal hat kein sichtbares Häkchen")
local scannedProfession = addon.Workshop:ScanOpenProfession()
assert(scannedProfession == true, "Geöffnetes Berufsfenster wurde nicht gescannt")
assert(tradeSkillExpanded == true, "Eingeklappte Berufskategorie wurde nicht automatisch geöffnet")
assert(tradeSkillFilterResets > 0, "Einschränkende Berufsfilter wurden nicht zurückgesetzt")
local filterResetsAfterFirstScan = tradeSkillFilterResets
addon.Workshop:ScanOpenProfession()
assert(tradeSkillFilterResets == filterResetsAfterFirstScan,
    "Berufsfilter wurden bei jedem Update erneut gesetzt und können eine Ereignisschleife auslösen")
local ownWorkshop = addon.Workshop:GetOwnData()
assert(ownWorkshop.professions.schneiderei ~= nil, "Beruf wurde nicht in der Werkstatt gespeichert")
assert(ownWorkshop.professions.schneiderei.recipes.I14155 ~= nil, "Rezept wurde nicht gespeichert")
assert(#ownWorkshop.professions.schneiderei.recipes.I14155.reagents == 2, "Reagenzien wurden nicht gespeichert")
addon.Workshop:StoreProfession("Schneiderei", 375, 375, {
    I14155 = addon.Util.DeepCopy(ownWorkshop.professions.schneiderei.recipes.I14155),
}, 1)
assert(ownWorkshop.professions.schneiderei.recipes.I14048 ~= nil,
    "Ein gefiltertes Teilresultat hat bereits bekannte Rezepte gelöscht")
local workshopMessages = addon.Workshop:BuildProfessionMessages(ownWorkshop.professions.schneiderei)
assert(#workshopMessages > 0, "Werkstatt-Synchronisierung wurde nicht erzeugt")
for _, workshopMessage in ipairs(workshopMessages) do
    assert(#workshopMessage <= 255, "Werkstatt-Nachricht überschreitet das Addon-Limit")
    assert(addon.Util.SplitFields(workshopMessage)[3] == "C",
        "Aktuelle Clients verwenden nicht das kompakte Werkstattformat")
    addon.Workshop:ReceiveSync(addon.Util.SplitFields(workshopMessage), "Crafter-Realm")
end
assert(addon.DB:GetGuild().workshop.crafters["crafter-realm"] ~= nil, "Remote-Crafter wurde nicht gespeichert")
local legacyWorkshopMessages = addon.Workshop:BuildProfessionMessages(ownWorkshop.professions.schneiderei, false)
for _, workshopMessage in ipairs(legacyWorkshopMessages) do
    local legacyFields = addon.Util.SplitFields(workshopMessage)
    assert(legacyFields[3] == "D",
        "Das kompatible Werkstattformat für ältere Clients fehlt")
    assert(#(legacyFields[9] or "") <= 170,
        "Ein kompatibles Werkstattpaket überschreitet das Limit älterer Clients")
    addon.Workshop:ReceiveSync(legacyFields, "Crafter-Realm")
end

local burstProfession = {
    key = "schneiderei",
    name = "Schneiderei",
    recipes = {},
}
for recipeIndex = 1, 80 do
    local itemID = 15000 + recipeIndex
    burstProfession.recipes["I" .. itemID] = {
        key = "I" .. itemID,
        itemID = itemID,
        name = "Testrezept " .. recipeIndex,
        reagents = { { itemID = 14047, count = 5 } },
    }
end
local burstMessages = addon.Workshop:BuildProfessionMessages(burstProfession)
assert(#burstMessages > 1, "Der Werkstatt-Bursttest erzeugt nicht mehrere Pakete")
local sentBeforeBurst = #sentAddon
local pendingBeforeBurst = #pendingTimers
addon.Workshop:QueueProfessionSync(burstProfession)
assert(#sentAddon - sentBeforeBurst == #burstMessages,
    "Werkstattpakete wurden nicht vollständig im direkten Burst gesendet")
assert(#pendingTimers == pendingBeforeBurst, "Der erfolgreiche Werkstatt-Burst wartet noch auf einen Timer")
assert(#addon.Workshop.syncQueue == 0, "Werkstatt-Warteschlange blieb nach dem Burst gefüllt")

addonSendFailures = 1
local sentBeforeRetry = #sentAddon
addon.Workshop:QueueProfessionSync(ownWorkshop.professions.schneiderei)
-- Der abgelehnte Sendeversuch wartet jetzt eine echte Kanalpause ab; nach dem
-- Vorspulen der Zeit läuft die Wiederholung.
addon.Sync:PumpBulk(2)
assert(#sentAddon > sentBeforeRetry, "Werkstattpaket wurde nach einem Sendefehler nicht wiederholt")
assert(#addon.Workshop.syncQueue == 0, "Werkstatt-Warteschlange wurde nach erfolgreicher Wiederholung nicht geleert")
assert(addon.Workshop.syncStats.failed == 0, "Ein einmalig fehlgeschlagenes Paket wurde endgültig verworfen")
local workshopCatalog = addon.Workshop:GetCatalog("Mondstoff")
assert(#workshopCatalog >= 1, "Werkstattsuche findet das Rezept nicht")
assert(#workshopCatalog[1].crafters == 2, "Lokaler und synchronisierter Crafter wurden nicht zusammengeführt")
local tailoringCatalog = addon.Workshop:GetCatalog("", "Schneiderei")
assert(#tailoringCatalog >= 1, "Berufsfilter findet Schneiderei nicht")
assert(#addon.Workshop:GetCatalog("", "Verzauberkunst") == 0, "Berufsfilter zeigt den falschen Beruf")
ownWorkshop.professions.alchimie = {
    key = "alchimie",
    name = "Alchimie",
    updatedAt = currentTime,
    recipes = {
        I99991 = {
            key = "I99991",
            itemID = 99991,
            name = "Testelixier",
            profession = "Alchimie",
            reagents = {},
        },
    },
}
assert(#addon.Workshop:GetCatalog("", "Alchemie") == 1,
    "Die alte Schreibweise Alchemie findet die TBC-Berufsbezeichnung Alchimie nicht")
assert(#addon.Workshop:GetCatalog("", "Alchimie") == 1,
    "Der TBC-Berufsfilter Alchimie findet den eingelesenen Beruf nicht")
ownWorkshop.professions.alchimie = nil

local regularTradeSkillLine = GetTradeSkillLine
GetTradeSkillLine = function()
    return "UNKNOWN", 0, 0
end
local scannedEnchanting = addon.Workshop:ScanOpenProfession()
GetTradeSkillLine = regularTradeSkillLine
assert(scannedEnchanting == true, "Verzauberkunst wurde nicht über die Craft-API gescannt")
assert(ownWorkshop.professions.verzauberkunst ~= nil, "Verzauberkunst fehlt in der Gildenwerkstatt")
assert(ownWorkshop.professions.verzauberkunst.recipes.E27926 ~= nil, "Verzauberungsrezept wurde nicht gespeichert")
assert(#addon.Workshop:GetCatalog("", "Verzauberkunst") == 1, "Berufsfilter findet Verzauberkunst nicht")
assert(addon.ProfessionIcons["Verzauberkunst"] ~= nil, "Berufssymbol für Verzauberkunst fehlt")
assert(addon.UI.pages.WORKSHOP.workshopRows[1].shown == false, "Werkstatt zeigt ohne Suchumfang den gesamten Katalog")
addon.UI.pages.WORKSHOP.workshopSearch:SetText("Ring - Heilkraft")
assert(addon.UI.pages.WORKSHOP.workshopRows[1].shown == true, "Gezielte Werkstattsuche zeigt keinen Treffer")
addon.UI.pages.WORKSHOP.workshopFavorite.scripts.OnClick()
assert(addon.Workshop:IsFavorite("E27926") == true, "Rezeptfavorit wurde nicht gespeichert")
addon.UI.pages.WORKSHOP.workshopFavorites.scripts.OnClick()
addon.UI.pages.WORKSHOP.workshopSearch:SetText("")
assert(addon.UI.pages.WORKSHOP.workshopRows[1].shown == true, "Favoritenfilter zeigt das gespeicherte Rezept nicht")

-- Berufe anderer eigener Charaktere desselben Accounts erscheinen lokal im
-- Katalog, ohne auf eine Netzwerksynchronisierung zu warten - das Addon kennt
-- die Daten ja bereits aus der gemeinsamen SavedVariables.
twinkCharacter = addon.DB:GetCharacter("Zwergenschmied-Realm")
twinkCharacter.fullName = "Zwergenschmied-Realm"
twinkCharacter.workshop = {
    professions = {
        schmiedekunst = {
            key = "schmiedekunst",
            name = "Schmiedekunst",
            updatedAt = 100,
            recipes = {
                I88001 = {
                    key = "I88001",
                    itemID = 88001,
                    name = "Twink-Klinge",
                    profession = "Schmiedekunst",
                    reagents = {},
                },
            },
        },
    },
}
twinkCatalog = addon.Workshop:GetCatalog("", "Schmiedekunst")
assert(#twinkCatalog == 1,
    "Der Beruf eines eigenen Twinks erscheint nicht im Werkstattkatalog")
twinkCrafterFound = false
for _, twinkCrafter in ipairs(twinkCatalog[1].crafters) do
    if twinkCrafter == "Zwergenschmied" then
        twinkCrafterFound = true
    end
end
assert(twinkCrafterFound, "Der eigene Twink wird nicht als Hersteller geführt")

assert(addon.Util.IsValidISODate("2026-02-28") == true, "Gültiges Abmeldedatum wurde abgelehnt")
assert(addon.Util.IsValidISODate("2026-02-30") == false, "Ungültiges Abmeldedatum wurde akzeptiert")
local absenceSaved = addon.Profile:SetAbsence("2026-07-26", "2026-08-03", "Urlaub")
assert(absenceSaved == true, "Eigene Abmeldung wurde nicht gespeichert")
assert(addon.Profile:GetAbsenceState() == "ACTIVE", "Aktive Abmeldung wurde nicht erkannt")
local absenceProfileMessage = addon.Sync:BuildProfileMessage()
assert(absenceProfileMessage:find("2026%-07%-26"), "Abmeldung fehlt in der Profilsynchronisierung")
assert(#absenceProfileMessage <= 255, "Profilnachricht mit Abmeldung überschreitet das Addon-Limit")
assert(#addon.Roster:GetGuildAbsences() == 1, "Aktive Gildenabmeldung wird nicht aufgelistet")
healerMember = addon.Roster:GetMember("Heiler-Realm")
healerMember.lastOnlineHours = 100 * 24
local careCandidates = addon.Roster:GetMemberCareCandidates()
assert(#careCandidates == 1, "Inaktives Mitglied wurde nicht zur Prüfung vorgeschlagen")
assert(careCandidates[1].status == "PRÜFEN", "Unbekannter Main/Twink-Status wurde nicht vorsichtig markiert")
assert(addon.Roster:SetMemberCareRankProtected(5, true) == true, "Rangschutz konnte nicht gesetzt werden")
assert(#addon.Roster:GetMemberCareCandidates() == 0, "Geschützter Rang erscheint noch als Pflegevorschlag")
assert(addon.Roster:SetMemberCareRankProtected(5, false) == true, "Rangschutz konnte nicht aufgehoben werden")
addon.Profile:ClearAbsence()
assert(addon.Profile:GetAbsenceState() == "NONE", "Abmeldung wurde nicht gelöscht")

local raidSpecBeforeInvalidConfirm = addon.Profile:Get().raidSpecKey
local invalidProfile, invalidProfileMessage = addon.Profile:Confirm("MAGE:1", nil, "MAIN", false)
assert(invalidProfile == nil and invalidProfileMessage:find("Primär%-Spec"),
    "Eine Primär-Spec der falschen Klasse wurde bestätigt")
assert(addon.Profile:Get().raidSpecKey == raidSpecBeforeInvalidConfirm,
    "Eine ungültige Bestätigung hat die bisherige Primär-Spec überschrieben")

addon.Profile:Confirm("HUNTER:2", "HUNTER:3", "MAIN", true)
assert(addon.Profile:Get().secondarySpecKey == "HUNTER:3", "Dual-Spec wurde nicht gespeichert")
assert(addon.Sync:BuildProfileMessage():find("HUNTER:3", 1, true), "Dual-Spec fehlt in der Gildensynchronisierung")
assert(addon.Sync:BuildProfileMessage():find("Ingenieurskunst", 1, true), "Beruf fehlt in der Gildensynchronisierung")

local sourceSaved = addon.WarcraftLogs:SaveSource("https://de.fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath")
assert(sourceSaved == true, "Warcraft-Logs-Link wurde nicht erkannt")
-- Der eingegebene Host bleibt erhalten. Zuvor wurde jede Eingabe auf
-- "fresh.warcraftlogs.com" normalisiert und die Sprachvariante ging verloren.
assert(addon.DB:GetGuild().warcraftLogs.host == "de.fresh.warcraftlogs.com",
    "Der eingegebene Warcraft-Logs-Host wurde nicht gespeichert")
assert(addon.DB:GetGuild().warcraftLogs.url
    == "https://de.fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath",
    "Die gespeicherte Gildenquelle verlor ihre Sprachvariante")
-- Charakter-Links entstehen aus der gespeicherten Quelle; ohne Realm gibt es
-- bewusst keine halben Links.
wclLinks = addon.WarcraftLogs:BuildCharacterLinks("Dotlordd")
assert(wclLinks.logs == "https://de.fresh.warcraftlogs.com/character/eu/thunderstrike/dotlordd",
    "Der Warcraft-Logs-Charakterlink ist falsch: " .. tostring(wclLinks.logs))
assert(wclLinks.armory == "https://classic-armory.org/character/eu/tbc-anniversary/thunderstrike/dotlordd",
    "Der Armory-Charakterlink ist falsch: " .. tostring(wclLinks.armory))
-- Ein Realm am Namen gewinnt gegen den Realm der Gildenquelle.
assert(addon.WarcraftLogs:BuildCharacterLinks("Dotlordd-Pyrewood Village").logs
    == "https://de.fresh.warcraftlogs.com/character/eu/pyrewood-village/dotlordd",
    "Der Realm aus dem Spielernamen wurde nicht verwendet")
-- Umlaute werden wie bei der Gildenquelle vereinfacht.
assert(addon.WarcraftLogs:BuildCharacterLinks("Frostäxte").logs:find("frostaxte", 1, true) ~= nil,
    "Ein Name mit Umlaut wurde nicht für die URL vereinfacht")
assert(addon.WarcraftLogs:BuildCharacterLinks("").logs == "",
    "Ohne Spielernamen wurde ein Link erzeugt")

assert(addon.WarcraftLogs:SaveSource("HTTPS://fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath") == true,
    "Ein Warcraft-Logs-Link mit großgeschriebenem Schema wurde nicht erkannt")
assert(addon.WarcraftLogs:SaveSource("https://evilwarcraftlogs.com/guild/eu/x/y") == false,
    "Eine fremde Domain mit passendem Namensende wurde als Warcraft Logs akzeptiert")
assert(addon.WarcraftLogs:SaveSource(
    "https://fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath/extra") == false,
    "Ein Gildenlink mit zusätzlichem Pfad wurde akzeptiert")

local imported, importedMessage = addon.WarcraftLogs:Import(
    "GCPWCL1|3\n"
    .. "Heiler-Realm;PRIEST;PRIEST:2;PRIEST:3\n"
    .. "Heiler-Realm;PRIEST;PRIEST:2;PRIEST:3\n"
    .. "Krieger-Realm;WARRIOR;WARRIOR:2;\n"
)
assert(imported == true, "Warcraft-Logs-Import ist fehlgeschlagen")
assert(addon.WarcraftLogs:GetImportedCount() == 2, "Importierte WCL-Spielerzahl ist falsch")
assert(importedMessage:find("2 Warcraft%-Logs%-Profile"),
    "Doppelte Profilzeilen wurden in der Importmeldung mehrfach gezählt")
assert(addon.Roster:GetProfile("Heiler-Realm").secondarySpecKey == "PRIEST:3", "Importierter Dual-Spec fehlt")
local manuallyImported = addon.WarcraftLogs:Import(
    "Nexarius;Magier;Arkan;Frost\n"
    .. "Druide-Realm;Druide;Wiederherstellung;\n"
)
assert(manuallyImported == true, "Manueller Import ohne API ist fehlgeschlagen")
assert(addon.WarcraftLogs:GetImportedCount() == 2, "Manuelle Profilanzahl ist falsch")
assert(addon.Roster:GetProfile("Nexarius").secondarySpecKey == "MAGE:3", "Manueller Dual-Spec wurde nicht erkannt")
assert(addon.Roster:GetProfile("Druide-Realm").raidSpecKey == "DRUID:3", "Deutscher Specname wurde nicht erkannt")

-- Logprofile und bereits bekannte Addon-Profile bilden gemeinsam die
-- Datengrundlage der Copilot-Vorschläge und müssen auf einem zweiten Client
-- vollständig wiederherstellbar sein.
addon.DB:GetGuild().remoteProfiles["archiv-realm"] = {
    fullName = "Archiv-Realm",
    classFile = "SHAMAN",
    raidSpecKey = "SHAMAN:2",
    mainStatus = "MAIN",
    confirmed = true,
    updatedAt = currentTime,
    receivedAt = currentTime,
}
recruitmentMessages = addon.WarcraftLogs:BuildRecruitmentSyncMessages()
assert(#recruitmentMessages > 0, "Der gildenweite Rekrutierungs-Datensatz wurde nicht erzeugt")
for _, recruitmentMessage in ipairs(recruitmentMessages) do
    assert(#recruitmentMessage <= 255, "Ein Rekrutierungs-Datenpaket überschreitet das Addon-Limit")
end
addon.DB:GetGuild().warcraftLogs.members = {}
addon.DB:GetGuild().warcraftLogs.importedAt = 0
addon.DB:GetGuild().remoteProfiles = {}
for _, recruitmentMessage in ipairs(recruitmentMessages) do
    addon.WarcraftLogs:ReceiveSync(
        addon.Util.SplitFields(recruitmentMessage),
        "Heiler-Realm",
        "WHISPER"
    )
end
assert(addon.WarcraftLogs:GetImportedCount() == 2,
    "Die Logprofile wurden auf dem simulierten zweiten Client nicht wiederhergestellt")
assert(addon.DB:GetGuild().remoteProfiles["archiv-realm"] ~= nil,
    "Ein bekanntes Addon-Profil fehlt im gildenweiten Rekrutierungs-Datensatz")
assert(addon.Roster:GetProfile("Archiv-Realm").raidSpecKey == "SHAMAN:2",
    "Der synchronisierte Profilcache liefert nicht dieselbe Vorschlagsgrundlage")

addon.Recruitment:SetClass("SHAMAN", true)
addon.Recruitment:SetSpec("HUNTER:3", true)
addon.Recruitment:SetPriority("SHAMAN", true)
local originalOrder = addon.Recruitment:GetClassOrder()
local originalShamanIndex
for index, classFile in ipairs(originalOrder) do
    if classFile == "SHAMAN" then
        originalShamanIndex = index
    end
end
addon.Recruitment:MoveClass("SHAMAN", -1)
local movedOrder = addon.Recruitment:GetClassOrder()
assert(movedOrder[originalShamanIndex - 1] == "SHAMAN", "Klassenreihenfolge wurde nicht geändert")
addon.DB:GetGuild().recruitment.raidMarker = 3
addon.DB:GetGuild().profile.contact = "Tester"
local advertisement = addon.Recruitment:GenerateAdvertisement()
assert(#advertisement <= 255, "Werbetext überschreitet das Chatlimit")
assert(advertisement:find("{rt3}", 1, true), "Gewähltes Raid-Symbol fehlt im Werbetext")
assert(advertisement:sub(1, 5) == "{rt3}", "Raid-Symbol fehlt am Textanfang")
assert(advertisement:sub(-5) == "{rt3}", "Raid-Symbol fehlt am Textende")
assert(advertisement:find("Schamanen", 1, true), "Klassenauswahl fehlt im Werbetext")
assert(advertisement:find("Überlebens-Jäger", 1, true), "Spec-Auswahl fehlt im Werbetext")
assert(advertisement:find("dringend", 1, true), "Hohe Priorität ist im Werbetext nicht sichtbar")
assert(advertisement:find("Schamanen", 1, true) < advertisement:find("Überlebens-Jäger", 1, true), "Priorisierte Klasse steht nicht zuerst")
assert(advertisement:find("für den aktuellen Content", 1, true), "Content-Formulierung fehlt")
assert(advertisement:find("/w für mehr Infos", 1, true), "Kontakttext verwendet nicht die gewünschte /w-Form")
assert(not advertisement:find("Content: SSC/TK", 1, true), "Konkreter Contentname steht noch in der Werbung")
addon.DB:GetGuild().recruitment.adText = advertisement
addon.Recruitment:SetPriority("HUNTER", true)
assert(addon.DB:GetGuild().recruitment.adText == "", "Prioritätsänderung hat den alten Werbetext nicht verworfen")

addon.DB:GetGuild().recruitment.confirmedText = advertisement
addon.DB:GetSettings().channels.LFG = true
addon.DB:GetSettings().channels.TRADE = true
addon.DB:GetSettings().channels.GENERAL = true
local posted, message = addon.Chat:StartSearch(advertisement)
assert(posted == true, message)
assert(#sentChat == 4, "Nicht alle vier ausgewählten Kanäle wurden bedient")

-- === Werbebalken ===========================================================
-- Kleines Fenster fuer das Posten ohne die grosse Oberflaeche. Gesendet wird
-- nur durch einen echten Klick.
assert(addon.DB:GetSettings().postBar.hidden == true, "Der Werbebalken ist ungefragt an")
addon.UI:SetPostBarShown(true)
local postBar = addon.UI.postBar
assert(postBar ~= nil and postBar.shown == true, "Der Werbebalken wurde nicht eingeblendet")
assert(addon.DB:GetSettings().postBar.hidden == false, "Der Zustand wurde nicht gespeichert")

addon.DB:GetGuild().recruitment.confirmedText = advertisement
addon.DB:GetGuild().lastPosts = {}
addon.UI:RefreshPostBar()
assert(postBar.sendButton.label.value == "Suche starten", "Der Knopf ist ohne Cooldown nicht bereit")

local barSentBefore = #sentChat
postBar.sendButton.scripts.OnClick()
assert(#sentChat > barSentBefore, "Der Werbebalken hat nichts gepostet")

-- Direkt danach greift der Cooldown und der Knopf zeigt ihn als Countdown.
addon.UI:RefreshPostBar()
assert(postBar.sendButton.label.value:find("s Cooldown", 1, true),
    "Der Cooldown erscheint nicht als Countdown im Knopf")

-- Ohne bestaetigten Text darf gar nicht gesendet werden.
addon.DB:GetGuild().lastPosts = {}
addon.DB:GetGuild().recruitment.confirmedText = ""
addon.UI:RefreshPostBar()
local blockedBefore = #sentChat
postBar.sendButton.scripts.OnClick()
assert(#sentChat == blockedBefore, "Ohne bestätigten Text wurde trotzdem gepostet")
assert(postBar.text.value:find("Kein bestätigter Text", 1, true),
    "Der fehlende Bestätigungstext wird nicht erklärt")

-- Die eigentliche Sperre: ein geaenderter, nicht neu bestaetigter Text darf
-- nicht rausgehen - egal ueber welchen Weg.
addon.DB:GetGuild().recruitment.confirmedText = advertisement
addon.DB:GetGuild().lastPosts = {}
local unconfirmedBefore = #sentChat
local unconfirmed, unconfirmedMessage = addon.Chat:StartSearch(advertisement .. " nachtraeglich geaendert")
assert(unconfirmed == false and unconfirmedMessage:find("bestätigen", 1, true),
    "Ein geänderter, nicht bestätigter Werbetext wurde gepostet")
assert(#sentChat == unconfirmedBefore, "Trotz Ablehnung wurde in den Chat geschrieben")

addon.UI:SetPostBarShown(false)
assert(postBar.shown == false, "Der Werbebalken ließ sich nicht schließen")
assert(addon.DB:GetSettings().postBar.hidden == true, "Der ausgeblendete Zustand wurde nicht gespeichert")
addon.DB:GetGuild().recruitment.confirmedText = advertisement
addon.DB:GetGuild().lastPosts = {}

addon.DB:GetGuild().inbox = {
    { name = "Alt-Realm", messages = "beschädigt", lastSeenAt = 200 },
    {
        name = "Alt-Realm",
        messages = {
            { receivedAt = 150, text = "Hallo", source = "WHISPER" },
            { receivedAt = "beschädigt", text = "Noch da", source = "WHISPER" },
        },
        firstSeenAt = 150,
        lastSeenAt = 150,
    },
}
addon.Chat:MergeDuplicateLeads()
assert(#addon.DB:GetGuild().inbox == 1, "Alte doppelte Postfacheinträge wurden nicht zusammengeführt")
assert(addon.DB:GetGuild().inbox[1].firstSeenAt == 150,
    "Ein fehlender alter Zeitstempel wurde als unendlicher Wert gespeichert")
assert(#addon.DB:GetGuild().inbox[1].messages == 2,
    "Ein beschädigtes Nachrichtenfeld hat die gültige Unterhaltung zerstört")
addon.Chat:ClearInbox()

addon.Recruitment:Clear()
for _, classFile in ipairs(addon.ClassOrder) do
    addon.Recruitment:SetClass(classFile, true)
end
addon.DB:GetGuild().profile.description = string.rep("Sehr ausführliche Gildenbeschreibung ", 12)
local allClassesAdvertisement = addon.Recruitment:GenerateAdvertisement()
assert(allClassesAdvertisement:find("alle Klassen", 1, true), "Vollständige Auswahl wurde nicht verdichtet")
assert(#allClassesAdvertisement <= 255, "Verdichteter Werbetext überschreitet das Chatlimit")
assert(allClassesAdvertisement:sub(-5) == "{rt3}", "Endsymbol ging bei der Kürzung verloren")

addon.Chat:CaptureWhisper("Kannst du mich nach UC porten?", "Portaluser-Realm", "Player-Portal")
assert(#addon.DB:GetGuild().inbox == 0, "Unpassendes Whisper wurde als Interessent gespeichert")
addon.Chat:CaptureWhisper("Hallo, ich suche eine Gilde.", "Bewerber-Realm", "Player-3")
assert(#addon.DB:GetGuild().inbox == 1, "Whisper wurde nicht im Postfach gespeichert")
addon.Chat:CaptureWhisper("Welche Raidzeiten habt ihr?", "Bewerber-Realm", "Player-3")
assert(#addon.DB:GetGuild().inbox[1].messages == 2, "Folgeunterhaltung eines Interessenten wurde nicht gespeichert")
addon.DB:GetGuild().recruitment.replyMarker = 6
local reply = addon.Recruitment:GenerateReply("THANKS", "Bewerber-Realm")
assert(reply:sub(1, 5) == "{rt6}", "Antwortsymbol fehlt am Textanfang")
assert(reply:sub(-5) == "{rt6}", "Antwortsymbol fehlt am Textende")
assert(#reply <= 255, "Antwort überschreitet das Chatlimit")
addon.DB:GetGuild().replyTemplates.THANKS = "Danke {name}! {gilde} meldet sich bei dir."
local customReply = addon.Recruitment:GenerateReply("THANKS", "Bewerber-Realm")
assert(customReply:find("Danke Bewerber!", 1, true), "Eigene Danke-Vorlage ersetzt den Namen nicht")
assert(customReply:find("Testgilde", 1, true), "Eigene Danke-Vorlage ersetzt den Gildennamen nicht")
addon.DB:GetGuild().replyTemplates.THANKS = ""
local editedReply = addon.Recruitment:DecorateReply("{rt6} Eigener Text {rt6}", 2)
assert(editedReply == "{rt2} Eigener Text {rt2}", "Editierter Antworttext wurde nicht sauber neu dekoriert")

-- Die Vorlagen fuer die drei Antwortknoepfe werden dort gepflegt, wo die
-- Knoepfe sind: im Postfach, nicht in den Einstellungen.
addon.UI:ShowPage("INBOX")
local inboxPage = addon.UI.pages.INBOX
assert(inboxPage.templateEdits ~= nil, "Die Vorlagen fehlen im Postfach")
assert(inboxPage.templateEdits.THANKS ~= nil, "Die Danke-Vorlage fehlt im Postfach")
assert(addon.UI.pages.SETTINGS.templateEdits == nil,
    "Die Vorlagen stehen weiterhin in den Einstellungen")

inboxPage.templateEdits.THANKS:SetText("Servus {name}, willkommen!")
inboxPage.saveTemplates.scripts.OnClick()
assert(addon.DB:GetGuild().replyTemplates.THANKS == "Servus {name}, willkommen!",
    "Die im Postfach bearbeitete Vorlage wurde nicht gespeichert")
assert(inboxPage.templateStatus.value:find("gespeichert", 1, true),
    "Das Speichern wird im Postfach nicht bestätigt")
assert(addon.Recruitment:GenerateReply("THANKS", "Bewerber-Realm"):find("Servus Bewerber", 1, true),
    "Die neue Vorlage wirkt sich nicht auf die Antwort aus")
addon.DB:GetGuild().replyTemplates.THANKS = ""

assert(addon.Roster:CanEditGuildProfile("Tester-Realm") == true, "Offiziersrang darf das Gildenprofil nicht bearbeiten")
assert(addon.Roster:CanEditGuildProfile("Heiler-Realm") == false, "Nicht freigegebener Rang darf das Gildenprofil bearbeiten")
local selfRemovalAllowed, selfRemovalReason = addon.Roster:SetGuildProfileRankActive(1, false)
assert(selfRemovalAllowed == false and selfRemovalReason == "OWN_RANK",
    "Der eigene Editor-Rang konnte abgewählt werden")
local profilePermissions = addon.DB:GetGuild().profilePermissions
profilePermissions.configured = true
profilePermissions.editorRanks = { ["0"] = true }
addon.DB:GetGuild().editorRecoveryAvailable = true
assert(addon.Roster:CanEditGuildProfile("Tester-Realm") == false,
    "Simulierter Editor-Lockout wurde nicht hergestellt")
assert(addon.Roster:CanUseEditorRecovery(1) == true,
    "Einmalige Wiederherstellung des eigenen Offiziersrangs ist nicht verfügbar")
local recovered, recoveryReason = addon.Roster:SetGuildProfileRankActive(1, true)
assert(recovered == true and recoveryReason == "RECOVERED",
    "Eigener Offiziersrang konnte nach dem Lockout nicht wiederhergestellt werden")
assert(addon.DB:GetGuild().editorRecoveryAvailable == false,
    "Einmalige Wiederherstellung blieb nach Verwendung aktiv")
assert(addon.DB:GetSettings().editorRecoveryAvailable == nil,
    "Die Wiederherstellung wird noch kontoweit statt pro Gilde verbucht")
assert(addon.Roster:CanEditGuildProfile("Tester-Realm") == true,
    "Wiederhergestellter Rang besitzt keine Einstellungsrechte")
local topRemovalAllowed, topRemovalReason = addon.Roster:SetGuildProfileRankActive(0, false)
assert(topRemovalAllowed == false and topRemovalReason == "HIGHER_RANK_REQUIRED",
    "Ein niedrigerer Rang konnte den höchsten Gildenrang abwählen")
assert(addon.Roster:CanAccessMemberCare("Tester-Realm") == true, "Offiziersrang sieht die Mitgliederpflege nicht")
assert(addon.Roster:CanAccessMemberCare("Heiler-Realm") == false, "Nicht freigegebener Rang sieht die Mitgliederpflege")
assert(addon.Roster:SetMemberCareAccessRank(5, true) == true, "Mitgliederpflege-Rang konnte nicht freigegeben werden")
assert(addon.Roster:CanAccessMemberCare("Heiler-Realm") == true, "Gildenweite Mitgliederpflege-Freigabe greift nicht")
local savedEditorRanks = addon.DB:GetGuild().profilePermissions.editorRanks
addon.DB:GetGuild().profilePermissions.editorRanks = {
    ["1"] = true,
    ["1.5"] = true,
    ["10"] = true,
    ["beschädigt"] = true,
}
local guildProfileMessages = addon.Sync:BuildGuildProfileMessages()
assert(#guildProfileMessages > 0, "Gildenprofil-Synchronisierung wurde nicht erzeugt")
for _, guildProfileMessage in ipairs(guildProfileMessages) do
    assert(#guildProfileMessage <= 255, "Gildenprofil-Nachricht überschreitet das Addon-Limit")
end
local rankPayload = ""
for _, guildProfileMessage in ipairs(guildProfileMessages) do
    rankPayload = rankPayload .. guildProfileMessage:match("^G|[^|]+|[^|]+|[^|]+|[^|]+|(.*)$")
end
assert(addon.Util.SplitFields(rankPayload)[10] == "1",
    "Beschädigte oder ungültige Rangwerte wurden in die Gildensynchronisierung übernommen")
addon.DB:GetGuild().profilePermissions.editorRanks = savedEditorRanks
addon.DB:GetSettings().successSoundKey = "GROUP_FINDER"
assert(addon.Chat:PlaySuccessSound() == true, "Ausgewählter Erfolgssound konnte nicht abgespielt werden")
assert(playedSoundID == 3081, "Gruppensuche-Sound verwendet keinen TBC-kompatiblen Fallback")

addon.Chat:CaptureLead("Suche Gilde für TBC-Raids", "Interessent-Realm", "Player-4", "SucheNachGruppe")
assert(#addon.DB:GetGuild().inbox == 2, "Chat-Trigger wurde nicht im Postfach gespeichert")
-- Die Klasse kommt aus der ohnehin erfassten GUID; es braucht keine eigene
-- Abfrage.
interessentLead = nil
for _, candidate in ipairs(addon.DB:GetGuild().inbox) do
    if candidate.guid == "Player-4" then
        interessentLead = candidate
    end
end
assert(interessentLead ~= nil, "Der Interessent mit GUID fehlt im Postfach")
assert(interessentLead.classFile == "PALADIN",
    "Die Klasse wurde nicht aus der GUID des Interessenten aufgelöst")
addon.Chat:CaptureLead("Noch eine Nachricht", "Interessent", nil, "Handel")
assert(#addon.DB:GetGuild().inbox == 2, "Spieler mit und ohne Realmnamen wurde doppelt angelegt")

-- Ein Interessent ohne bekannte GUID bleibt ohne Klasse, statt zu scheitern
-- oder falsch gefärbt zu werden.
addon.Chat:CaptureLead("Auch ich suche", "Namenlos-Realm", nil, "SucheNachGruppe")
namelessLead = addon.DB:GetGuild().inbox[1]
assert(namelessLead.classFile == nil,
    "Ohne auflösbare GUID wurde eine Klasse erfunden")
-- Ein Altbestand ohne classFile wird beim Anzeigen nachgetragen, sobald der
-- Client-Cache die GUID kennt.
namelessLead.guid = "Player-4"
assert(addon.Chat:ResolveLeadClass(namelessLead) == "PALADIN",
    "Die Klasse eines Altbestands wurde nicht nachgetragen")
addon.UI:ShowPage("INBOX")
addon.UI.selectedLead = 1
addon.UI:RefreshInbox()
assert(addon.UI.pages.INBOX.leadButtons[1].label.value:find("|cfff58cba", 1, true) ~= nil,
    "Der Interessent wird nicht in seiner Klassenfarbe angezeigt: "
    .. tostring(addon.UI.pages.INBOX.leadButtons[1].label.value))
assert(addon.UI.pages.INBOX.leadTitle.value:find("|cfff58cba", 1, true) ~= nil,
    "Der Kopf der Unterhaltung zeigt den Namen nicht in Klassenfarbe")
-- Für den ausgewählten Interessenten stehen beide Profil-Links bereit.
assert(addon.UI.pages.INBOX.leadLinkEdits.logs.linkValue
    == "https://fresh.warcraftlogs.com/character/eu/realm/namenlos",
    "Der Warcraft-Logs-Link des Interessenten fehlt im Postfach: "
    .. tostring(addon.UI.pages.INBOX.leadLinkEdits.logs.linkValue))
assert(addon.UI.pages.INBOX.leadLinkEdits.armory.linkValue
    == "https://classic-armory.org/character/eu/tbc-anniversary/realm/namenlos",
    "Der Armory-Link des Interessenten fehlt im Postfach")
-- Tippen in ein Linkfeld stellt den vollständigen Link wieder her, damit
-- niemand einen halben Link kopiert.
addon.UI.pages.INBOX.leadLinkEdits.logs:SetText("kaputt")
addon.UI.pages.INBOX.leadLinkEdits.logs.scripts.OnTextChanged(
    addon.UI.pages.INBOX.leadLinkEdits.logs, true)
assert(addon.UI.pages.INBOX.leadLinkEdits.logs.value
    == "https://fresh.warcraftlogs.com/character/eu/realm/namenlos",
    "Ein überschriebenes Linkfeld wurde nicht wiederhergestellt")
assert(addon.Chat:RemoveLead(1) == true, "Der Testinteressent ließ sich nicht entfernen")
assert(addon.Chat:RemoveLead(1) == true, "Einzelner Interessent konnte nicht gelöscht werden")
assert(#addon.DB:GetGuild().inbox == 1, "Einzellöschung hat nicht genau einen Interessenten entfernt")
assert(addon.Chat:ClearInbox() == true, "Postfach konnte nicht vollständig geleert werden")
assert(#addon.DB:GetGuild().inbox == 0, "Postfach enthält nach dem Leeren noch Interessenten")

local function LastAddonMessage()
    local entry = sentAddon[#sentAddon]
    return entry and entry[2] or ""
end

-- === Raidauswertung =========================================================
raidRoster = {
    { "Tester", 2, "HUNTER" },
    { "Heiler", 1, "PRIEST" },
    { "Schurke", 0, "ROGUE" },
}

assert(addon.RaidMonitor:GetRaidRank("Tester") == 2, "Der Raidleiter wurde nicht erkannt")
assert(addon.RaidMonitor:GetRaidRank("Heiler") == 1, "Der Assistent wurde nicht erkannt")
assert(addon.RaidMonitor:GetRaidRank("Schurke") == 0, "Ein einfaches Raidmitglied wurde falsch eingestuft")
assert(addon.RaidMonitor:CanControlSession("Heiler") == true,
    "Ein Assistent darf die Auswertung nicht steuern")
assert(addon.RaidMonitor:CanControlSession("Schurke") == false,
    "Ein einfaches Raidmitglied darf die Auswertung steuern")

local sessionStarted = addon.RaidMonitor:BeginSession()
assert(sessionStarted == true, "Die Raidsitzung wurde nicht gestartet")
assert(addon.RaidMonitor.session ~= nil, "Es läuft keine Sitzung")
assert(LastAddonMessage():sub(1, 3) == "RS|", "Der Sitzungsstart wurde nicht angekündigt")
assert(sentAddon[#sentAddon][3] == "RAID", "Die Sitzung wurde nicht über den Raidkanal angekündigt")
local liveSession = addon.RaidMonitor.session
assert(liveSession.participants.schurke ~= nil, "Raidmitglieder wurden nicht übernommen")

addon.RaidMonitor:BeginSegment(currentTime)
FireCombatLog("SPELL_CAST_SUCCESS", "Schurke", "Schurke", 28495)
FireCombatLog("SPELL_CAST_SUCCESS", "Schurke", "Schurke", 28495)
FireCombatLog("SPELL_AURA_APPLIED", "Heiler", "Heiler", 28518)
FireCombatLog("SPELL_AURA_APPLIED", "Heiler", "Heiler", 28518)
FireCombatLog("SPELL_INTERRUPT", "Schurke", "Prinz", nil, "Creature-1")
FireCombatLog("SPELL_DISPEL", "Heiler", "Tester", nil)
FireCombatLog("UNIT_DIED", "", "Tester", nil)
FireCombatLog("UNIT_DIED", "", "Prinz Malchezaar", nil, "Creature-1234")

local rogue = liveSession.participants.schurke
local healer = liveSession.participants.heiler
assert(rogue.consumables.POTION == 2, "Wiederholbare Tränke wurden nicht mehrfach gezählt")
assert(healer.consumables.FLASK == 1, "Ein dauerhaftes Fläschchen wurde doppelt gezählt")
assert(rogue.interrupts == 1, "Der Interrupt wurde nicht gezählt")
assert(healer.dispels == 1, "Der Dispel wurde nicht gezählt")
assert(liveSession.participants.tester.deaths == 1, "Der Spielertod wurde nicht gezählt")
assert(liveSession.segment.lastNPCDeath == "Prinz Malchezaar", "Der gestorbene Gegner wurde nicht erfasst")

currentTime = currentTime + 120
addon.RaidMonitor:CloseSegment(currentTime)
assert(#liveSession.pulls == 1, "Der Kampfabschnitt wurde nicht als Versuch gewertet")
assert(liveSession.pulls[1].result == "KILL", "Ein Kampf mit totem Boss wurde nicht als Sieg gewertet")
assert(liveSession.pulls[1].name == "Prinz Malchezaar", "Der Versuch wurde nicht nach dem Gegner benannt")

currentTime = currentTime + 60
local sessionEnded = addon.RaidMonitor:EndSession()
assert(sessionEnded == true, "Die Raidsitzung wurde nicht beendet")
assert(addon.RaidMonitor.session == nil, "Die Sitzung läuft nach dem Beenden weiter")

local storedSummary = addon.RaidMonitor:GetSummaries()[1]
assert(storedSummary ~= nil, "Die Auswertung wurde nicht gespeichert")
assert(storedSummary.kills == 1, "Der Sieg fehlt in der Auswertung")
assert(#storedSummary.participants == 3, "Nicht alle Teilnehmer stehen in der Auswertung")
assert(storedSummary.source == "LIVE", "Die eigene Auswertung ist nicht als Live-Daten gekennzeichnet")
local storedRogue
for _, participant in ipairs(storedSummary.participants) do
    if participant.name == "Schurke" then
        storedRogue = participant
    end
end
assert(storedRogue.seconds >= 180, "Die Anwesenheitszeit wurde nicht mitgeschrieben")
assert(storedRogue.consumables.POTION == 2, "Die Tränke fehlen in der Auswertung")

-- Die Zusammenfassung überlebt Serialisierung und Zerlegung in Chatpakete.
local summaryMessages = addon.RaidMonitor:BuildSummaryMessages(storedSummary, "token1")
assert(#summaryMessages > 0, "Die Auswertung wurde nicht in Pakete zerlegt")
for _, summaryMessage in ipairs(summaryMessages) do
    assert(#summaryMessage <= 255, "Ein Auswertungspaket überschreitet das Addon-Limit")
end
local decoded = addon.RaidMonitor:DecodeSummary(addon.RaidMonitor:EncodeSummary(storedSummary))
assert(decoded ~= nil, "Die Auswertung ließ sich nicht zurücklesen")
assert(decoded.id == storedSummary.id, "Die Sitzungskennung ging verloren")
assert(#decoded.participants == 3, "Teilnehmer gingen beim Übertragen verloren")
assert(decoded.kills == 1, "Die Siege gingen beim Übertragen verloren")

-- Ein Assistent verteilt eine fremde Auswertung; sie darf angenommen werden.
addon.DB:GetGuild().raidSessions = {}
for _, summaryMessage in ipairs(summaryMessages) do
    addon.Sync:OnMessage("GuildCopilot", summaryMessage, "RAID", "Heiler-Realm")
end
local receivedSummary = addon.RaidMonitor:GetSummaries()[1]
assert(receivedSummary ~= nil, "Die verteilte Auswertung wurde nicht übernommen")
assert(receivedSummary.source == "SYNC", "Übernommene Daten sind nicht als Sync gekennzeichnet")
assert(#receivedSummary.participants == 3, "Die übernommene Auswertung ist unvollständig")

-- Ein einfaches Raidmitglied darf keine Auswertung setzen.
addon.DB:GetGuild().raidSessions = {}
for _, summaryMessage in ipairs(summaryMessages) do
    addon.Sync:OnMessage("GuildCopilot", summaryMessage, "RAID", "Schurke-Realm")
end
assert(#addon.RaidMonitor:GetSummaries() == 0,
    "Ein einfaches Raidmitglied konnte eine Auswertung einspielen")

-- Offiziere außerhalb des Raids fragen an; geantwortet wird per Flüstern,
-- nicht über den offenen Gildenkanal.
addon.RaidMonitor:StoreSummary(decoded)
addon.RaidMonitor.lastAnswerAt = 0
currentTime = currentTime + 60
local answerCountBefore = #sentAddon
addon.Sync:OnMessage("GuildCopilot", "RQ|7", "GUILD", "Heiler-Realm")
assert(#sentAddon > answerCountBefore, "Auf die Auswertungsanfrage wurde nicht geantwortet")
assert(sentAddon[#sentAddon][3] == "WHISPER", "Die Auswertung ging nicht über den Flüsterkanal")
assert(sentAddon[#sentAddon][4] == "Heiler-Realm", "Die Auswertung ging an den falschen Empfänger")
local ignoredRequestBefore = #sentAddon
addon.Sync:OnMessage("GuildCopilot", "RQ|7", "GUILD", "Schurke-Realm")
assert(#sentAddon == ignoredRequestBefore,
    "Einem unberechtigten Anfrager wurde die Auswertung geschickt")

-- Die Auswertung erscheint auch in der Oberfläche.
addon.UI:ShowPage("STATISTICS")
local statisticsPage = addon.UI.pages.STATISTICS
assert(statisticsPage.sessionRows[1].shown == true, "Die Sitzung fehlt in der Auswertungsliste")
assert(statisticsPage.participantRows[1].shown == true, "Die Teilnehmerzeile fehlt in der Auswertung")
assert(statisticsPage.participantRows[1].name.value == "Tester",
    "Die Auswertung zeigt den falschen Spieler")
assert(statisticsPage.participantRows[4].shown == false,
    "Es werden mehr Teilnehmerzeilen angezeigt als vorhanden")

-- Rückmeldungen stehen im Fenster und zusätzlich im Chat.
local chatCountBefore = #chatMessages
statisticsPage.sessionButton.scripts.OnClick()
assert(statisticsPage.actionStatus.value:find("gestartet", 1, true),
    "Der Sitzungsstart wird nicht in der Oberfläche gemeldet")
assert(#chatMessages > chatCountBefore,
    "Der Sitzungsstart wurde nicht zusätzlich im Chat gemeldet")
assert(chatMessages[#chatMessages]:find("gestartet", 1, true),
    "Die Chatmeldung nennt den Sitzungsstart nicht")

currentTime = currentTime + 60
chatCountBefore = #chatMessages
statisticsPage.sessionButton.scripts.OnClick()
assert(statisticsPage.actionStatus.value:find("ausgewertet", 1, true),
    "Das Sitzungsende wird nicht in der Oberfläche gemeldet")
assert(chatMessages[#chatMessages]:find("ausgewertet", 1, true),
    "Das Sitzungsende wurde nicht zusätzlich im Chat gemeldet")

-- Auch eine abgelehnte Aktion meldet sich in beiden Kanälen.
raidRoster = {}
addon.DB:GetGuild().memberCare.accessRanks = {}
chatCountBefore = #chatMessages
statisticsPage.sessionButton.scripts.OnClick()
assert(statisticsPage.actionStatus.value:find("Nur Raidleiter", 1, true),
    "Die Ablehnung wird nicht in der Oberfläche gemeldet")
assert(chatMessages[#chatMessages]:find("Nur Raidleiter", 1, true),
    "Die Ablehnung wurde nicht zusätzlich im Chat gemeldet")

-- Die Teilnehmertabelle selbst bleibt in der Oberfläche und wird nicht
-- zeilenweise in den Chat geschrieben.
for _, chatMessage in ipairs(chatMessages) do
    assert(not chatMessage:find("Interrupts", 1, true) and not chatMessage:find("Dispels", 1, true),
        "Die Auswertungstabelle wurde in den Chat geschrieben")
end

assert(addon.Sync:GetAddonUserStats().known == 1,
    "Ohne Handshake wird mehr als der eigene Client als Addon-Nutzer gezählt")
local announced = addon.Sync:AnnounceVersion(true)
assert(announced == true, "Der Handshake wurde beim Login nicht gesendet")
local announcement = LastAddonMessage()
assert(announcement:sub(1, 2) == "V|", "Die Handshake-Nachricht hat den falschen Typ")
assert(#announcement <= 255, "Die Handshake-Nachricht überschreitet das Addon-Limit")
assert(announcement:find(addon.Constants.VERSION, 1, true), "Die Addon-Version fehlt im Handshake")
assert(announcement:find("workshop", 1, true), "Die Fähigkeiten fehlen im Handshake")
assert(announcement:find("workshop2", 1, true), "Das kompakte Werkstattformat fehlt im Handshake")
assert(announcement:find("workshop3", 1, true), "Der bestätigte Werkstatttransfer fehlt im Handshake")
assert(announcement:find("recruitmentsync", 1, true),
    "Der gildenweite Rekrutierungs-Datensatz fehlt im Handshake")
assert(announcement:find("gearsync", 1, true), "Der automatische Ausrüstungsabgleich fehlt im Handshake")
assert(addon.Sync:AnnounceVersion(false, 60) == false,
    "Der Mindestabstand zwischen zwei Handshakes greift nicht")

-- Ein alter Client kennt den Handshake nicht, verrät seine Datenversion aber
-- über ein gewöhnliches Profilpaket.
addon.Sync:OnMessage("GuildCopilot", "P|5|PRIEST|PRIEST:2|0/41/10|PRIEST:2||MAIN|0|1||||1000",
    "GUILD", "Heiler-Realm")
local legacyStats = addon.Sync:GetAddonUserStats()
assert(legacyStats.known == 2, "Ein Client ohne Handshake wurde nicht erkannt")
assert(legacyStats.outdated == 1, "Die ältere Datenversion wurde nicht als abweichend gemeldet")
assert(legacyStats.compatible == 1, "Ein alter Client wurde als kompatibel gezählt")
assert(legacyStats.outdatedNames[1] == "Heiler", "Der abweichende Client wird nicht benannt")
assert(addon.Sync:GetAddonUser("Heiler-Realm").handshake == nil,
    "Ein reines Profilpaket wurde als Handshake verbucht")

-- Nach dem Update meldet sich derselbe Spieler per Handshake und wird
-- aktualisiert statt doppelt gezählt.
addon.Sync:OnMessage("GuildCopilot", "V|7|0.4.6|profile,workshop|0", "GUILD", "Heiler-Realm")
local handshakeStats = addon.Sync:GetAddonUserStats()
assert(handshakeStats.known == 2, "Der aktualisierte Client wurde doppelt gezählt")
assert(handshakeStats.compatible == 2, "Gleiche Datenversion wurde als unpassend gewertet")
assert(handshakeStats.outdated == 0, "Passende Datenversion wurde als veraltet gewertet")
assert(addon.Sync:GetAddonUser("Heiler-Realm").version == "0.4.6",
    "Die gemeldete Version wurde nicht gespeichert")
assert(addon.Sync:GetAddonUser("Heiler").capabilities:find("workshop", 1, true),
    "Die gemeldeten Fähigkeiten wurden nicht gespeichert")

-- Auf eine ausdrückliche Anfrage wird geantwortet, sobald der Mindestabstand
-- verstrichen ist.
currentTime = currentTime + 60
local sentBeforeRequest = #sentAddon
addon.Sync:OnMessage("GuildCopilot", "V|7|0.4.6|profile|1", "GUILD", "Heiler-Realm")
local handshakeReply
local profileReply
for messageIndex = sentBeforeRequest + 1, #sentAddon do
    local reply = sentAddon[messageIndex][2]
    if reply:sub(1, 2) == "V|" then
        handshakeReply = reply
    elseif reply:sub(1, 2) == "P|" then
        profileReply = reply
    end
end
assert(handshakeReply, "Auf eine Handshake-Anfrage wurde nicht geantwortet")
-- Feld 5 ist das Antwortverlangen. Geprueft wird das Feld, nicht das
-- Nachrichtenende: dahinter steht inzwischen das Account-Kennzeichen.
assert(addon.Util.SplitFields(handshakeReply)[5] == "0",
    "Die Handshake-Antwort fordert selbst wieder eine Antwort an")
assert(#addon.Util.SplitFields(handshakeReply)[6] == 10,
    "Im Handshake fehlt das Account-Kennzeichen")
assert(profileReply, "Auf eine Handshake-Anfrage wurde das eigene Profil nicht mitgesendet")

-- Auf eine Antwort darf nie geantwortet werden, sonst schaukelt sich der
-- Handshake zwischen allen Gildenmitgliedern auf.
currentTime = currentTime + 60
local sentBeforeReply = #sentAddon
addon.Sync:OnMessage("GuildCopilot", "V|7|0.4.6|profile|0", "GUILD", "Heiler-Realm")
assert(#sentAddon == sentBeforeReply, "Auf eine Handshake-Antwort wurde erneut geantwortet")

-- Grosse Direkttransfers senden nur ein kleines Fenster gleichzeitig weiter.
-- Erst die Bestätigung des Empfängers öffnet den nächsten Platz; dadurch ist
-- der Ablauf schnell, erkennt aber verlorene Pakete zuverlässig.
reliableMessages, reliableToken = addon.Workshop:BuildProfessionMessages(burstProfession)
reliableComplete = false
timerDelayThreshold = 1
addon.Sync.bulkAllowance = 4000
addon.Sync.bulkQueue = {}
reliableSentBefore = #sentAddon
assert(addon.Sync:QueueReliable(
    reliableMessages,
    "Heiler-Realm",
    "W",
    reliableToken,
    function()
        reliableComplete = true
    end
) == true, "Der bestätigte Werkstatttransfer ließ sich nicht starten")
reliableCursor = reliableSentBefore + 1
reliableGuard = 0
while addon.Sync.reliableActive and reliableGuard < (#reliableMessages * 3) do
    reliableGuard = reliableGuard + 1
    outgoing = sentAddon[reliableCursor]
    reliableCursor = reliableCursor + 1
    assert(outgoing ~= nil, "Der bestätigte Transfer blieb ohne weiteres Datenpaket stehen")
    if outgoing[2]:sub(1, 2) == "W|" and outgoing[3] == "WHISPER" then
        outgoingFields = addon.Util.SplitFields(outgoing[2])
        addon.Sync:OnMessage(
            "GuildCopilot",
            table.concat({ "A", "7", "W", reliableToken, outgoingFields[5] }, "|"),
            "WHISPER",
            "Heiler-Realm"
        )
    end
end
timerDelayThreshold = math.huge
assert(reliableComplete == true and addon.Sync.reliableActive == nil,
    "Der bestätigte Werkstatttransfer wurde trotz aller Paketbestätigungen nicht abgeschlossen")

-- Bleibt eine Bestätigung aus, wird genau dieses Teilpaket erneut gesendet.
retryMessages, retryToken = addon.Workshop:BuildProfessionMessages(
    ownWorkshop.professions.verzauberkunst)
retryTimerStart = #pendingTimers
retrySentStart = #sentAddon
timerDelayThreshold = 1
addon.Sync.bulkAllowance = 4000
assert(addon.Sync:QueueReliable(retryMessages, "Heiler-Realm", "W", retryToken) == true,
    "Der Wiederholungstest ließ sich nicht starten")
assert(#pendingTimers > retryTimerStart, "Für ein unbestätigtes Paket wurde keine Wiederholung geplant")
pendingTimers[retryTimerStart + 1]()
assert(#sentAddon > retrySentStart + 1, "Ein unbestätigtes Werkstattpaket wurde nicht erneut gesendet")
retryFields = addon.Util.SplitFields(sentAddon[#sentAddon][2])
addon.Sync:OnMessage(
    "GuildCopilot",
    table.concat({ "A", "7", "W", retryToken, retryFields[5] }, "|"),
    "WHISPER",
    "Heiler-Realm"
)
timerDelayThreshold = math.huge
assert(addon.Sync.reliableActive == nil,
    "Der wiederholte Transfer wurde nach der Bestätigung nicht abgeschlossen")

-- Ein einzelnes dauerhaft verlorenes Teilpaket darf nicht den ganzen Beruf
-- scheitern lassen: die bestätigten Pakete bleiben erhalten, gezählt wird nur
-- der echte Verlust, und der Transfer läuft trotzdem sauber aus.
partialToken = "partial12345"
partialMessages = {}
for partIndex = 1, 3 do
    partialMessages[partIndex] = table.concat({
        "W", "7", "C", partialToken, partIndex, 3, "schneiderei", "Schneiderei", "I1,,", "0", "1",
    }, "|")
end
partialComplete = false
partialFailedCount = nil
timerDelayThreshold = 1
addon.Sync.bulkAllowance = 4000
addon.Sync.bulkQueue = {}
addon.Sync.reliableActive = nil
addon.Sync.reliableQueue = {}
partialPendingStart = #pendingTimers
assert(addon.Sync:QueueReliable(
    partialMessages,
    "Heiler-Realm",
    "W",
    partialToken,
    function()
        partialComplete = true
    end,
    function(entry)
        partialFailedCount = entry.failedCount
    end
) == true, "Der Transfer mit Teilverlust ließ sich nicht starten")
-- Teil 1 und 3 bestätigen, Teil 2 bewusst nie.
for _, ackedPart in ipairs({ 1, 3 }) do
    addon.Sync:OnMessage(
        "GuildCopilot",
        table.concat({ "A", "7", "W", partialToken, ackedPart }, "|"),
        "WHISPER",
        "Heiler-Realm"
    )
end
partialGuard = 0
partialCursor = partialPendingStart + 1
while addon.Sync.reliableActive and partialGuard < 200 do
    partialGuard = partialGuard + 1
    partialTimer = pendingTimers[partialCursor]
    if not partialTimer then
        break
    end
    partialCursor = partialCursor + 1
    partialTimer()
end
timerDelayThreshold = math.huge
assert(addon.Sync.reliableActive == nil,
    "Ein Transfer mit einem verlorenen Paket blieb hängen statt auszulaufen")
assert(partialComplete == false,
    "Ein Transfer mit verlorenem Paket meldete fälschlich vollständigen Erfolg")
assert(partialFailedCount == 1,
    "Es wurde nicht genau ein verlorenes Teilpaket gezählt")

-- Scheitert der Flüstertransfer vollständig (Addon-Flüster erreichen den
-- Empfänger in manchen Umgebungen nicht), wird der Beruf über den bewährten
-- Gildenkanal nachgereicht, damit der Anfragende die Daten trotzdem bekommt.
addon.Sync.reliableActive = nil
addon.Sync.reliableQueue = {}
addon.Sync.bulkQueue = {}
addon.Sync.bulkAllowance = 4000
addon.Workshop.syncQueue = {}
timerDelayThreshold = 1
fallbackSentStart = #sentAddon
fallbackPendingStart = #pendingTimers
assert(addon.Workshop:QueueProfessionSync(
    ownWorkshop.professions.schneiderei, true, "Heiler-Realm", true) ~= false,
    "Der bestätigte Transfer für den Gilden-Fallback ließ sich nicht starten")
fallbackGuard = 0
fallbackCursor = fallbackPendingStart + 1
while addon.Sync.reliableActive and fallbackGuard < 500 do
    fallbackGuard = fallbackGuard + 1
    fallbackTimer = pendingTimers[fallbackCursor]
    if not fallbackTimer then
        break
    end
    fallbackCursor = fallbackCursor + 1
    fallbackTimer()
end
timerDelayThreshold = math.huge
addon.Sync:PumpBulk(10)
guildFallbackFound = false
for fallbackIndex = fallbackSentStart + 1, #sentAddon do
    fallbackEntry = sentAddon[fallbackIndex]
    if fallbackEntry[3] == "GUILD" and fallbackEntry[2]:sub(1, 2) == "W|" then
        fallbackFields = addon.Util.SplitFields(fallbackEntry[2])
        if fallbackFields[3] == "C" and fallbackFields[7] == "schneiderei" then
            guildFallbackFound = true
            break
        end
    end
end
assert(guildFallbackFound,
    "Nach einem gescheiterten Flüstertransfer wurde der Beruf nicht über den Gildenkanal nachgereicht")

for _, reliableMessage in ipairs(reliableMessages) do
    addon.Sync:OnMessage("GuildCopilot", reliableMessage, "WHISPER", "Heiler-Realm")
end
whisperedCrafter = addon.DB:GetGuild().workshop.crafters["heiler-realm"]
assert(whisperedCrafter and whisperedCrafter.professions.schneiderei,
    "Werkstattdaten aus dem Flüsterkanal wurden fälschlich nur an die Raidauswertung geleitet")
whisperedRecipeCount = 0
for _ in pairs(whisperedCrafter.professions.schneiderei.recipeKeys) do
    whisperedRecipeCount = whisperedRecipeCount + 1
end
assert(whisperedRecipeCount == 80,
    "Der bestätigte Flüstertransfer hat nicht alle Werkstattrezepte gespeichert")

-- Berufe eines eigenen Twinks werden über den Gildenkanal mit angehängtem
-- Herstellernamen geteilt und dem richtigen Charakter zugeordnet - nicht dem
-- absendenden Charakter. So bekommt die Gilde auch die Berufe eines Twinks,
-- ohne dass man auf ihm eingeloggt sein muss.
twinkShareMessages = addon.Workshop:BuildProfessionMessages(
    ownWorkshop.professions.schneiderei, true, "Twinkschneider-Realm")
for _, twinkShareMessage in ipairs(twinkShareMessages) do
    addon.Sync:OnMessage("GuildCopilot", twinkShareMessage, "GUILD", "Mainchar-Realm")
end
assert(addon.DB:GetGuild().workshop.crafters["twinkschneider-realm"] ~= nil,
    "Ein über den Gildenkanal geteilter Twink-Beruf wurde nicht dem Twink zugeordnet")
assert(addon.DB:GetGuild().workshop.crafters["twinkschneider-realm"].professions.schneiderei ~= nil,
    "Der geteilte Twink-Beruf fehlt beim Twink")
assert(addon.DB:GetGuild().workshop.crafters["mainchar-realm"] == nil,
    "Ein geteilter Twink-Beruf wurde fälschlich dem absendenden Charakter zugeordnet")

-- === Katalog und Herstellerindex ===========================================
-- Rezeptdaten sind für alle identisch, also reicht es, sie einmal zu
-- übertragen. Danach genügt die Schlüsselliste: "wer kann was".
keyRoundtrip = addon.Workshop:EncodeRecipeKeys({ "I15003", "I15001", "E27926", "Nmondstoff", "I15002" })
assert(keyRoundtrip:find("I=15001.1.1", 1, true) ~= nil,
    "Aufeinanderfolgende Item-IDs wurden nicht als Differenzen kodiert: " .. keyRoundtrip)
decodedKeys = {}
for _, decodedKey in ipairs(addon.Workshop:DecodeRecipeKeys(keyRoundtrip)) do
    decodedKeys[decodedKey] = true
end
for _, expectedKey in ipairs({ "I15001", "I15002", "I15003", "E27926", "Nmondstoff" }) do
    assert(decodedKeys[expectedKey], "Schlüssel " .. expectedKey .. " ging beim Kodieren verloren")
end

-- Eine Schlüsselliste ist ein Bruchteil eines vollen Transfers.
keyListMessages = addon.Workshop:BuildKeyListMessages(burstProfession, "Schlüsselschmied-Realm")
fullMessages = addon.Workshop:BuildProfessionMessages(burstProfession, true, "Schlüsselschmied-Realm")
assert(#keyListMessages < #fullMessages,
    "Die Schlüsselliste ist nicht kürzer als der volle Transfer")
for _, keyListMessage in ipairs(keyListMessages) do
    assert(#keyListMessage <= 255, "Ein Schlüssellisten-Paket überschreitet das Chatlimit")
end

-- Der Empfänger kennt die Rezepte aus dem Katalog schon: der Hersteller wird
-- eingetragen, ohne dass ein einziges Rezept erneut übertragen wurde.
for _, fullMessage in ipairs(fullMessages) do
    addon.Sync:OnMessage("GuildCopilot", fullMessage, "GUILD", "Katalogfüller-Realm")
end
catalogSize = 0
for _ in pairs(addon.DB:GetGuild().workshop.catalog) do
    catalogSize = catalogSize + 1
end
assert(catalogSize >= 80, "Der Rezeptkatalog wurde nicht gefüllt: " .. catalogSize)
for _, keyListMessage in ipairs(keyListMessages) do
    addon.Sync:OnMessage("GuildCopilot", keyListMessage, "GUILD", "Schlüsselschmied-Realm")
end
keyOnlyCrafter = addon.DB:GetGuild().workshop.crafters["schlusselschmied-realm"]
    or addon.DB:GetGuild().workshop.crafters["schlüsselschmied-realm"]
assert(keyOnlyCrafter ~= nil, "Der Hersteller aus der Schlüsselliste fehlt")
keyOnlyCount = 0
for _ in pairs(keyOnlyCrafter.professions.schneiderei.recipeKeys) do
    keyOnlyCount = keyOnlyCount + 1
end
assert(keyOnlyCount == 80,
    "Die Schlüsselliste hat nicht alle Rezepte zugeordnet: " .. keyOnlyCount)
-- Beide Hersteller stehen am selben Rezept, das nur einmal im Katalog liegt.
keySharedEntry = nil
-- Bei Gegenstandsrezepten wandert der Name nicht durch die Gilde; ihn löst
-- jeder Client aus der Item-ID selbst auf. Gesucht wird deshalb über die ID.
for _, entry in ipairs(addon.Workshop:GetCatalog("15005")) do
    if entry.key == "I15005" then
        keySharedEntry = entry
    end
end
assert(keySharedEntry ~= nil, "Das geteilte Rezept fehlt im Katalog")
assert(#keySharedEntry.crafters == 2,
    "Nicht beide Hersteller wurden am geteilten Rezept geführt: " .. #keySharedEntry.crafters)
assert(#keySharedEntry.reagents > 0,
    "Die Reagenzien aus dem Katalog fehlen am Eintrag der Schlüsselliste")

-- Ein Rezept, das der Katalog nicht kennt, wird beim Hersteller nachgefordert.
missingKeyMessages = addon.Workshop:BuildKeyListMessages({
    key = "schneiderei",
    name = "Schneiderei",
    updatedAt = 4242,
    recipes = { I19999 = { key = "I19999", itemID = 19999, name = "Unbekanntes Rezept", reagents = {} } },
}, "Unbekanntling-Realm")
addon.Workshop.suppressedRequests = {}
-- Die Nachforderung läuft mit Streuung; unterhalb der Schwelle würde der
-- Test-Timer sofort feuern statt in die Warteliste zu wandern.
timerDelayThreshold = 0.5
missingRequestBefore = #pendingTimers
for _, missingKeyMessage in ipairs(missingKeyMessages) do
    addon.Sync:OnMessage("GuildCopilot", missingKeyMessage, "GUILD", "Unbekanntling-Realm")
end
assert(#pendingTimers > missingRequestBefore,
    "Für ein unbekanntes Rezept wurde keine Nachforderung geplant")
missingSentBefore = #sentAddon
pendingTimers[missingRequestBefore + 1]()
addon.Sync:PumpBulk(10)
missingRequestFound = false
for missingIndex = missingSentBefore + 1, #sentAddon do
    if sentAddon[missingIndex][2]:find("|N|", 1, true) then
        missingRequestFound = true
        assert(sentAddon[missingIndex][2]:find("Unbekanntling", 1, true) ~= nil,
            "Die Nachforderung nennt den falschen Hersteller")
    end
end
assert(missingRequestFound, "Die Nachforderung wurde nicht gesendet")
timerDelayThreshold = math.huge
-- Dasselbe Rezept wird nicht ein zweites Mal nachgefordert.
assert(addon.Workshop:SendMissingRecipeRequest("Unbekanntling-Realm", { "I19999" }) == false,
    "Ein bereits angefragtes Rezept wurde erneut nachgefordert")

-- Ausgetretene Mitglieder verschwinden mit ihren Rezepten; Twinks nicht.
addon.Workshop:ClaimRecipes({
    crafter = "Ausgetreten-Realm",
    sharedBy = "Ausgetreten-Realm",
    professionKey = "schneiderei",
    professionName = "Schneiderei",
    recipeKeys = { "I15001" },
})
addon.Workshop:ClaimRecipes({
    crafter = "Fremdtwink-Realm",
    sharedBy = "Heiler-Realm",
    professionKey = "schneiderei",
    professionName = "Schneiderei",
    recipeKeys = { "I15002" },
})
assert(addon.DB:GetGuild().workshop.crafters["ausgetreten-realm"] ~= nil,
    "Der Testeintrag für den Ausgetretenen fehlt")
addon.Workshop:PruneDepartedCrafters()
assert(addon.DB:GetGuild().workshop.crafters["ausgetreten-realm"] == nil,
    "Ein ausgetretenes Gildenmitglied blieb mit seinen Rezepten in der Werkstatt")
assert(addon.DB:GetGuild().workshop.crafters["fremdtwink-realm"] ~= nil,
    "Der Twink eines Gildenmitglieds wurde fälschlich als ausgetreten entfernt")

-- === Spieler statt Charaktere ===============================================
-- WoW verrät nie, welche Charaktere zu einem Account gehören. Der Client sagt
-- es deshalb selbst über ein anonymes Kennzeichen im Handshake; gleiche
-- Kennzeichen sind derselbe Spieler.
addon.DB:GetGuild().addonUsers = {}
assert(#addon.DB:GetAccountTag() == 10, "Für diesen Account fehlt ein Kennzeichen")
-- Die Statistik blendet Nichtmitglieder aus, sobald der Roster gelesen ist. Für
-- diesen Test steht er bewusst noch aus, damit die Testnamen zählen.
accountRosterBackup = addon.Roster.members
addon.Roster.members = {}
addon.Sync:OnMessage("GuildCopilot",
    "V|7|" .. addon.Constants.VERSION .. "|profile,workshop4|0|aaaaaaaaaa",
    "GUILD", "Zwillingsmain-Realm")
addon.Sync:OnMessage("GuildCopilot",
    "V|7|" .. addon.Constants.VERSION .. "|profile,workshop4|0|aaaaaaaaaa",
    "GUILD", "Zwillingstwink-Realm")
addon.Sync:OnMessage("GuildCopilot",
    "V|7|" .. addon.Constants.VERSION .. "|profile,workshop4|0|bbbbbbbbbb",
    "GUILD", "Eigenstaendig-Realm")
accountStats = addon.Sync:GetAddonUserStats()
assert(accountStats.known == 4,
    "Die Charakterzahl stimmt nicht: " .. accountStats.known)
assert(accountStats.players == 3,
    "Zwei Charaktere eines Accounts wurden nicht zusammengefasst: "
    .. accountStats.players)
assert(addon.Sync:GetAddonUser("Zwillingstwink-Realm").accountTag == "aaaaaaaaaa",
    "Das Account-Kennzeichen wurde nicht gespeichert")

-- Ein Charakter ohne gemeldetes Kennzeichen zählt einzeln: lieber eine Zahl zu
-- hoch als fremde Spieler fälschlich zusammenlegen.
addon.Sync:OnMessage("GuildCopilot", "V|7|0.9.29|profile,workshop3|0",
    "GUILD", "Ohnekennzeichen-Realm")
accountStats = addon.Sync:GetAddonUserStats()
assert(accountStats.players == 4,
    "Ein Charakter ohne Kennzeichen wurde fälschlich zusammengelegt: "
    .. accountStats.players)

-- Die Übersicht nennt Spieler als Hauptzahl und die Charakterzahl daneben.
addon.UI:ShowPage("OVERVIEW")
addon.UI:RefreshDashboard()
assert(addon.UI.pages.OVERVIEW.metricCards.ADDON.value.value == "4",
    "Die Kachel zeigt nicht die Spielerzahl: "
    .. tostring(addon.UI.pages.OVERVIEW.metricCards.ADDON.value.value))
assert(addon.UI.pages.OVERVIEW.metricCards.ADDON.caption.value:find("5 CHARAKTERE", 1, true) ~= nil,
    "Die Kachel nennt die Charakterzahl nicht: "
    .. tostring(addon.UI.pages.OVERVIEW.metricCards.ADDON.caption.value))
addon.Roster.members = accountRosterBackup
addon.DB:GetGuild().addonUsers = {}

-- === Materialbestand und Gildenbank =========================================
-- Eigene Taschen und Bank werden gezählt; sie verlassen den Account nie.
addon.Inventory:ScanBags()
addon.Inventory:ScanBank()
ownMats = addon.Inventory:GetOwnCounts(22446)
assert(ownMats.bags == 5, "Taschenbestand falsch gezählt: " .. ownMats.bags)
assert(ownMats.bank == 9, "Bankbestand falsch gezählt: " .. ownMats.bank)
assert(ownMats.total == 14, "Gesamtbestand falsch: " .. ownMats.total)

-- Bestände eines eigenen Twinks zählen mit, ohne Netzwerkweg.
twinkInventory = addon.DB:GetCharacter("Materialtwink-Realm")
twinkInventory.fullName = "Materialtwink-Realm"
twinkInventory.inventory = {
    bags = { counts = { [22446] = 100 }, updatedAt = 500 },
    bank = { counts = {}, updatedAt = 0 },
}
ownMats = addon.Inventory:GetOwnCounts(22446)
assert(ownMats.alts == 100, "Twink-Bestand fehlt: " .. ownMats.alts)
assert(ownMats.total == 114, "Gesamtbestand mit Twink falsch: " .. ownMats.total)

-- Die Gildenbank wird je Tab eingelesen.
assert(addon.Inventory:ScanGuildBankTab(1) == true, "Gildenbank-Tab wurde nicht gelesen")
guildBankTotal, guildBankAt, guildBankBy = addon.Inventory:GetGuildBankCount(22446)
assert(guildBankTotal == 32, "Gildenbankbestand falsch: " .. tostring(guildBankTotal))
assert(guildBankBy == "Tester", "Der Einleser der Gildenbank fehlt: " .. tostring(guildBankBy))
assert(addon.Inventory:GetGuildBankCount(99999) == 0,
    "Ein unbekanntes Item hat einen Gildenbankbestand")

-- Ampellogik: selbst gedeckt, erst mit Gildenbank gedeckt, gar nicht gedeckt.
matStatus = addon.Inventory:GetReagentStatus({
    { itemID = 22446, count = 10, name = "Gedeckt" },
    { itemID = 22447, count = 4, name = "Nur Gildenbank" },
    { itemID = 22445, count = 999, name = "Fehlt" },
})
assert(matStatus.rows[1].status == "OWN", "Eigener Bestand wurde nicht als gedeckt erkannt")
assert(matStatus.rows[2].status == "GUILD",
    "Deckung über die Gildenbank wurde nicht erkannt: " .. matStatus.rows[2].status)
assert(matStatus.rows[3].status == "MISSING", "Fehlendes Material wurde nicht erkannt")
assert(#matStatus.missing == 2, "Die Fehlliste ist falsch: " .. #matStatus.missing)
assert(matStatus.missing[1].fromGuildBank == 4,
    "Die Gildenbank-Deckung der Fehlmenge ist falsch")

-- Die Materialanzeige benutzt echte Zeilen mit festen Spalten: ein Textblock
-- kann in der proportionalen Spielschrift keine Spalten ausrichten.
addon.UI:ShowPage("WORKSHOP")
addon.UI.pages.WORKSHOP.workshopFavoritesOnly = false
materialEntry = nil
for _, entry in ipairs(addon.Workshop:GetCatalog("", "Schneiderei")) do
    if #entry.reagents > 0 then
        materialEntry = entry
        break
    end
end
assert(materialEntry ~= nil, "Kein Schneiderei-Rezept mit Reagenzien für den Anzeigetest")
addon.UI.pages.WORKSHOP.workshopProfession.value = "Schneiderei"
addon.UI.pages.WORKSHOP.workshopSearch:SetText("")
addon.UI.pages.WORKSHOP.selectedWorkshopRecipe = materialEntry.key
addon.UI:RefreshWorkshop()
materialRow = addon.UI.pages.WORKSHOP.workshopMaterialRows[1]
assert(materialRow.shown == true, "Die erste Materialzeile wird nicht angezeigt")
assert(materialRow.name.value:find("×", 1, true) ~= nil,
    "Die Materialzeile nennt keine Bedarfsmenge: " .. tostring(materialRow.name.value))
assert(materialRow.own.value ~= nil and materialRow.own.value ~= "",
    "Die Spalte für den eigenen Bestand ist leer")
assert(materialRow.bank.value ~= nil and materialRow.bank.value ~= "",
    "Die Spalte für die Gildenbank ist leer")
-- Der Textblock enthält jetzt nur noch Beruf und Hersteller, keine Spalten mehr.
assert(addon.UI.pages.WORKSHOP.workshopDetails.value:find("GBank", 1, true) == nil,
    "Die Materialspalten stecken noch im Textblock statt in eigenen Zeilen")
assert(addon.UI.pages.WORKSHOP.workshopMaterialSummary.value ~= "",
    "Die Zusammenfassung unter den Materialien fehlt")
-- Ein langer Fehlt-Text darf nicht abgeschnitten werden: die Zeilenhöhe wird
-- aus der Zeichenzahl mitgerechnet, weil GetStringHeight im Spiel nur die
-- Höhe einer Zeile liefern kann.
summaryPlain = addon.UI.pages.WORKSHOP.workshopMaterialSummary.value
    :gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
summaryHeightSet = addon.UI.pages.WORKSHOP.workshopMaterialSummary.height or 0
assert(summaryHeightSet >= 15,
    "Für die Zusammenfassung wurde keine Höhe gesetzt: " .. summaryHeightSet)
if #summaryPlain > 50 then
    assert(summaryHeightSet > 15,
        "Ein langer Fehlt-Text bekam nur eine Zeile Höhe und würde abschneiden: "
        .. summaryHeightSet .. " für " .. #summaryPlain .. " Zeichen")
end
assert((addon.UI.pages.WORKSHOP.workshopDetailContent.height or 0) >= 220,
    "Der Detailbereich hat keine gültige Höhe erhalten")

-- Der Scrollstand darf nur beim Rezeptwechsel zurückspringen. Während der
-- Synchronisierung feuert pro Paket ein Refresh; setzte der den Stand zurück,
-- hüpfte die Ansicht beim Lesen dauernd nach oben.
addon.UI.pages.WORKSHOP.workshopDetailScroll:SetVerticalScroll(50)
addon.UI:RefreshWorkshop()
assert(addon.UI.pages.WORKSHOP.workshopDetailScroll.verticalScroll == 50,
    "Ein Refresh ohne Rezeptwechsel hat den Scrollstand zurückgesetzt")
scrollSwitchEntry = nil
for _, entry in ipairs(addon.Workshop:GetCatalog("", "Schneiderei")) do
    if entry.key ~= addon.UI.pages.WORKSHOP.selectedWorkshopRecipe then
        scrollSwitchEntry = entry
        break
    end
end
if scrollSwitchEntry then
    addon.UI.pages.WORKSHOP.selectedWorkshopRecipe = scrollSwitchEntry.key
    addon.UI:RefreshWorkshop()
    assert(addon.UI.pages.WORKSHOP.workshopDetailScroll.verticalScroll == 0,
        "Beim Wechsel auf ein anderes Rezept blieb der alte Scrollstand stehen")
end
-- Ohne Suchumfang bleiben keine alten Materialzeilen stehen.
addon.UI.pages.WORKSHOP.selectedWorkshopRecipe = nil
addon.UI.pages.WORKSHOP.workshopProfession.value = ""
addon.UI.pages.WORKSHOP.workshopSearch:SetText("")
addon.UI:RefreshWorkshop()
assert(addon.UI.pages.WORKSHOP.workshopMaterialRows[1].shown == false,
    "Eine Materialzeile blieb ohne ausgewähltes Rezept sichtbar")

-- Zählstände werden als Differenzen kodiert und kommen unverändert zurück.
countRoundtrip = addon.Inventory:EncodeCounts({ [22445] = 20, [22446] = 5, [22447] = 4 })
decodedCounts = addon.Inventory:DecodeCounts(countRoundtrip)
assert(decodedCounts[22445] == 20 and decodedCounts[22446] == 5 and decodedCounts[22447] == 4,
    "Zählstände gingen beim Kodieren verloren: " .. countRoundtrip)

-- Gildenbank-Abgleich: Manifest zuerst, Tabdaten nur auf Anforderung.
manifestMessage = addon.Inventory:BuildManifestMessage()
assert(manifestMessage ~= nil and #manifestMessage <= 255,
    "Das Gildenbank-Manifest ist unbrauchbar")
tabMessages = addon.Inventory:BuildTabMessages(1)
assert(#tabMessages >= 1, "Die Tabdaten wurden nicht erzeugt")
for _, tabMessage in ipairs(tabMessages) do
    assert(#tabMessage <= 255, "Ein Gildenbank-Paket überschreitet das Chatlimit")
end

-- Ein neuerer Stand gewinnt, ein älterer verliert - rangunabhängig.
addon.DB:GetGuild().guildBank.tabs = {}
for _, tabMessage in ipairs(tabMessages) do
    addon.Sync:OnMessage("GuildCopilot", tabMessage, "GUILD", "Synkos-Realm")
end
assert(addon.Inventory:GetGuildBankCount(22446) == 32,
    "Ein empfangener Gildenbank-Tab wurde nicht übernommen")
staleTab = addon.DB:GetGuild().guildBank.tabs[1]
staleTab.updatedAt = staleTab.updatedAt + 1000
staleTab.counts = { [22446] = 777 }
newerMessages = addon.Inventory:BuildTabMessages(1)
staleTab.counts = { [22446] = 1 }
staleTab.updatedAt = staleTab.updatedAt + 5000
for _, newerMessage in ipairs(newerMessages) do
    addon.Sync:OnMessage("GuildCopilot", newerMessage, "GUILD", "Synkos-Realm")
end
assert(addon.Inventory:GetGuildBankCount(22446) == 1,
    "Ein älterer Gildenbank-Stand hat den neueren überschrieben")

-- Ein Manifest, das einen Tab nicht nennt, darf ihn nicht löschen: der Absender
-- darf ihn vielleicht nicht sehen.
addon.Sync:OnMessage("GuildCopilot", "B|7|BM|2,999,123", "GUILD", "Synkos-Realm")
assert(addon.DB:GetGuild().guildBank.tabs[1] ~= nil,
    "Ein Manifest ohne den Tab hat den gespeicherten Tab gelöscht")

-- Private Bestände dürfen in keinem gesendeten Paket auftauchen.
privateLeakBefore = #sentAddon
addon.Inventory:SendManifest()
addon.Inventory:SendTab(1)
addon.Sync:PumpBulk(10)
for leakIndex = 1, #sentAddon do
    leakMessage = sentAddon[leakIndex][2]
    if leakMessage:sub(1, 2) == "B|" then
        assert(leakMessage:find("114", 1, true) == nil,
            "Ein privater Gesamtbestand steckt in einem gesendeten Paket: " .. leakMessage)
    end
end

-- Werkstatt-Login: Manifest statt voller Schlüssellisten. Ein unveränderter
-- Bestand kostet damit ein Paket statt vierzehn.
addon.DB:GetGuild().addonUsers = {}
addon.Sync:NoteAddonUser("Heiler-Realm", {
    schemaVersion = 7,
    version = addon.Constants.VERSION,
    capabilities = table.concat(addon.Capabilities, ","),
    source = "HANDSHAKE",
})
-- Ein Login oder /reload schickt nur das Manifest. Frueher entschied eine
-- gildenweite Vermutung ueber Vollversand: ein einziger Eintrag mit veralteten
-- Faehigkeiten liess jedes /reload achtzig Pakete senden.
addon.Workshop.syncQueue = {}
addon.Sync.bulkQueue = {}
addon.Sync.bulkAllowance = 4000
reloadSentBefore = #sentAddon
addon.Workshop:SendKeyManifest()
addon.Sync:PumpBulk(10)
reloadPackets = #sentAddon - reloadSentBefore
assert(reloadPackets > 0 and reloadPackets <= 3,
    "Ein Login sollte hoechstens drei Manifest-Pakete kosten, waren aber " .. reloadPackets)
-- Ein Fragender ohne Manifest-Verstaendnis bekommt weiterhin den vollen Bestand.
addon.DB:GetGuild().addonUsers = {}
addon.Sync:NoteAddonUser("Altclient-Realm", {
    schemaVersion = 7,
    version = "0.9.25",
    capabilities = "profile,workshop,workshop2,workshop3",
    source = "HANDSHAKE",
})
addon.Workshop.requestReplies = {}
addon.Workshop.syncQueue = {}
legacySentBefore = #sentAddon
addon.Sync:OnMessage("GuildCopilot", "W|7|Q|3", "GUILD", "Altclient-Realm")
addon.Sync:PumpBulk(60)
assert(#sentAddon - legacySentBefore > 3,
    "Ein alter Client bekam keinen vollen Bestand")
-- Ein aktueller Fragender bekommt nur das Manifest.
addon.Sync:NoteAddonUser("Neuclient-Realm", {
    schemaVersion = 7,
    version = addon.Constants.VERSION,
    capabilities = table.concat(addon.Capabilities, ","),
    source = "HANDSHAKE",
})
addon.Workshop.requestReplies = {}
addon.Workshop.syncQueue = {}
addon.Sync.bulkQueue = {}
addon.Sync.bulkAllowance = 4000
modernSentBefore = #sentAddon
addon.Sync:OnMessage("GuildCopilot", "W|7|Q|3", "GUILD", "Neuclient-Realm")
addon.Sync:PumpBulk(10)
assert(#sentAddon - modernSentBefore <= 3,
    "Ein aktueller Client bekam mehr als das Manifest: "
    .. (#sentAddon - modernSentBefore) .. " Pakete")
keyManifestMessages = addon.Workshop:BuildKeyManifestMessages()
assert(#keyManifestMessages >= 1, "Das Berufs-Manifest wurde nicht erzeugt")
for _, keyManifestMessage in ipairs(keyManifestMessages) do
    assert(#keyManifestMessage <= 255, "Ein Berufs-Manifest-Paket ist zu lang")
end
assert(#keyManifestMessages < 14,
    "Das Manifest ist nicht kürzer als der bisherige Login-Broadcast")

-- Wer das Manifest kennt, fordert nichts nach; wer es nicht kennt, schon.
addon.Workshop.suppressedKeyRequests = {}
timerDelayThreshold = 0.5
knownManifestBefore = #pendingTimers
for _, keyManifestMessage in ipairs(keyManifestMessages) do
    addon.Sync:OnMessage("GuildCopilot", keyManifestMessage, "GUILD", "Heiler-Realm")
end
assert(#pendingTimers > knownManifestBefore,
    "Für einen unbekannten fremden Beruf wurde keine Schlüsselliste angefordert")
keyRequestSentBefore = #sentAddon
pendingTimers[knownManifestBefore + 1]()
addon.Sync:PumpBulk(10)
keyRequestFound = false
for keyRequestIndex = keyRequestSentBefore + 1, #sentAddon do
    if sentAddon[keyRequestIndex][2]:find("|KR|", 1, true) then
        keyRequestFound = true
    end
end
assert(keyRequestFound, "Die Anforderung der Schlüsselliste wurde nicht gesendet")
timerDelayThreshold = math.huge

-- Lange Berufs- und Herstellernamen dürfen das 255-Byte-Chatlimit nie
-- sprengen: das Nutzlast-Budget richtet sich nach der echten Kopfzeile.
-- Zuvor wurden zu lange Pakete vor dem Senden kommentarlos verworfen und der
-- Transfer blieb beim Empfänger für immer unvollständig.
longProfession = {
    key = "ingenieurskunst",
    name = "Ingenieurskunst",
    updatedAt = 1767225600,
    recipes = {},
}
for recipeIndex = 1, 80 do
    longProfession.recipes["I" .. (23700 + recipeIndex)] = {
        key = "I" .. (23700 + recipeIndex),
        itemID = 23700 + recipeIndex,
        name = "Ingenieursrezept " .. recipeIndex,
        reagents = {
            { itemID = 23445, count = 3 },
            { itemID = 23446, count = 2 },
            { itemID = 23447, count = 4 },
        },
    }
end
longMessages = addon.Workshop:BuildProfessionMessages(longProfession, true, "Twinkschneider-Realm")
assert(#longMessages > 1, "Der Langnamen-Test erzeugt nicht mehrere Pakete")
for _, longMessage in ipairs(longMessages) do
    assert(#longMessage <= 255,
        "Ein Werkstattpaket mit langem Berufs- und Herstellernamen überschreitet das Chatlimit")
end
for _, longMessage in ipairs(longMessages) do
    addon.Sync:OnMessage("GuildCopilot", longMessage, "GUILD", "Mainchar-Realm")
end
longReceived = addon.DB:GetGuild().workshop.crafters["twinkschneider-realm"].professions.ingenieurskunst
assert(longReceived ~= nil, "Der Beruf mit langem Namen wurde nicht gespeichert")
longReceivedCount = 0
for _ in pairs(longReceived.recipeKeys) do
    longReceivedCount = longReceivedCount + 1
end
assert(longReceivedCount == 80,
    "Der Beruf mit langem Namen kam nicht vollständig an")

-- Der Anniversary-Client meldet Sendeerfolge als Enum: 0 ist Erfolg, 3 und 8
-- sind Drosselungen. Wer nur auf "~= false" prüft, verliert gedrosselte
-- Pakete lautlos.
originalSendAddonMessage = C_ChatInfo.SendAddonMessage
C_ChatInfo.SendAddonMessage = function()
    return 3
end
assert(addon.Sync:Send("W|7|Q|3") == false,
    "Ein vom Client gedrosseltes Paket (Enum 3) galt fälschlich als gesendet")
C_ChatInfo.SendAddonMessage = function()
    return 0
end
assert(addon.Sync:Send("W|7|Q|3") == true,
    "Ein erfolgreich gesendetes Paket (Enum 0) galt fälschlich als fehlgeschlagen")
C_ChatInfo.SendAddonMessage = originalSendAddonMessage

ackBeforeRecruitmentWhisper = #sentAddon
addon.Sync:OnMessage("GuildCopilot", recruitmentMessages[1], "WHISPER", "Heiler-Realm")
assert(#sentAddon == ackBeforeRecruitmentWhisper + 1
    and sentAddon[#sentAddon][2]:sub(1, 6) == "A|7|L|",
    "Der Rekrutierungs-Datensatz wurde im Flüsterkanal nicht bestätigt")

-- Eine Sitzung ohne Gruppe muss den Spieler selbst erfassen.
raidRoster = {}
partyRoster = {}
addon.DB:GetGuild().raidSessions = {}
addon.DB:GetGuild().memberCare.accessRanksConfigured = true
addon.DB:GetGuild().memberCare.accessRanks = { ["1"] = true, ["5"] = true }
assert(addon.RaidMonitor:BeginSession() == true, "Solo-Sitzung ließ sich nicht starten")
assert(addon.RaidMonitor.session.participants.tester ~= nil,
    "Der Spieler selbst fehlt in einer Sitzung ohne Gruppe")
currentTime = currentTime + 30
local soloEnded, soloMessage = addon.RaidMonitor:EndSession()
assert(soloEnded == true, "Solo-Sitzung ließ sich nicht beenden")
assert(soloMessage:find("1 Teilnehmer", 1, true),
    "Eine Sitzung ohne Gruppe meldet immer noch 0 Teilnehmer")
local soloSummary = addon.RaidMonitor:GetSummaries()[1]
assert(#soloSummary.participants == 1, "Die Solo-Auswertung enthält keinen Teilnehmer")
assert(soloSummary.participants[1].seconds >= 30, "Die eigene Anwesenheitszeit fehlt")

-- In einer 5er-Gruppe gibt es kein Raidroster; die Teilnehmer kommen aus den
-- party-Einheiten.
partyRoster = { "party1", "party2" }
unitNames.party1 = "Grupppler"
unitNames.party2 = "Zweiter"
unitClasses.party1 = "MAGE"
addon.DB:GetGuild().raidSessions = {}
assert(addon.RaidMonitor:BeginSession() == true, "Gruppensitzung ließ sich nicht starten")
local partySession = addon.RaidMonitor.session
assert(partySession.participants.tester ~= nil, "Der Spieler fehlt in der Gruppensitzung")
assert(partySession.participants.grupppler ~= nil, "Ein Gruppenmitglied wurde nicht erfasst")
assert(partySession.participants.grupppler.classFile == "MAGE",
    "Die Klasse des Gruppenmitglieds fehlt")
currentTime = currentTime + 10
addon.RaidMonitor:EndSession()
assert(#addon.RaidMonitor:GetSummaries()[1].participants == 2,
    "Die Gruppensitzung hat nicht alle Teilnehmer")
partyRoster = {}
unitNames.party1 = nil
unitNames.party2 = nil
addon.DB:GetGuild().raidSessions = {}

-- === Warcraft-Logs-Nachanalyse =============================================
addon.DB:GetGuild().raidSessions = {}
local liveSummary = {
    id = "live-1",
    startedAt = 100,
    endedAt = 200,
    zone = "Karazhan",
    pulls = 2,
    kills = 2,
    wipes = 0,
    source = "LIVE",
    participants = { { name = "Tester", seconds = 100, consumables = {} } },
}
addon.RaidMonitor:StoreSummary(liveSummary)

local wclImported, wclMessage = addon.WarcraftLogs:Import(
    "GCPWCL2|1\n"
    .. "Heiler-Realm;PRIEST;PRIEST:2;PRIEST:3\n"
    .. "S|abc123|1000|8200|Gruuls Lager|5|4|1\n"
    .. "P|Tester|HUNTER|7200|1|3|0|28495:2,28518:3,99999:5\n"
    .. "P|Heiler|PRIEST|7000|0|0|4|28499:1\n"
)
assert(wclImported == true, wclMessage or "Der Nachanalyse-Import schlug fehl")
assert(wclMessage:find("Raidauswertungen", 1, true), "Die Rückmeldung nennt die Auswertungen nicht")

local wclSummary = addon.RaidMonitor:GetSummary("WCL:abc123")
assert(wclSummary ~= nil, "Die Nachanalyse wurde nicht gespeichert")
assert(wclSummary.source == "WCL", "Die Nachanalyse ist nicht als Logs-Quelle gekennzeichnet")
assert(wclSummary.kills == 4 and wclSummary.wipes == 1, "Siege und Wipes wurden nicht übernommen")
assert(wclSummary.zone == "Gruuls Lager", "Die Instanz wurde nicht übernommen")
assert(#wclSummary.participants == 2, "Nicht alle Teilnehmer wurden übernommen")

local wclTester = wclSummary.participants[1]
assert(wclTester.name == "Tester", "Die Teilnehmerreihenfolge stimmt nicht")
assert(wclTester.seconds == 7200, "Die Anwesenheitszeit wurde nicht übernommen")
assert(wclTester.interrupts == 3, "Die Interrupts wurden nicht übernommen")
assert(wclTester.consumables.POTION == 2, "Wiederholbare Tränke wurden nicht gezählt")
assert(wclTester.consumables.FLASK == 1,
    "Ein dauerhaftes Fläschchen wurde mehrfach statt einmal gezählt")
assert(wclTester.consumables.ELIXIR == 0, "Eine unbekannte Spell-ID wurde einer Kategorie zugeordnet")

-- Live- und Logs-Daten bleiben getrennt und überschreiben sich nicht.
assert(addon.RaidMonitor:GetSummary("live-1") ~= nil, "Die Livesitzung ging verloren")
assert(addon.RaidMonitor:GetSummary("live-1").source == "LIVE",
    "Die Livesitzung wurde von den Logs-Daten überschrieben")
assert(#addon.RaidMonitor:GetSummaries() == 2, "Live und Logs wurden zusammengeworfen")

local collidingSummary = {
    id = "live-1",
    startedAt = 100,
    endedAt = 300,
    zone = "Logs",
    source = "WCL",
    participants = { { name = "Tester", seconds = 1, consumables = {} } },
}
assert(addon.RaidMonitor:StoreSummary(collidingSummary) == false,
    "Eine Logs-Auswertung konnte eine Livesitzung überschreiben")
assert(addon.RaidMonitor:GetSummary("live-1").zone == "Karazhan",
    "Die Livesitzung wurde doch verändert")

-- GCPWCL3 hängt die Wiederbelebungen als neuntes Feld an. Ältere Zeilen ohne
-- dieses Feld müssen weiterhin durchgehen, sonst bricht jeder Import, sobald
-- Addon und Companion unterschiedlich alt sind.
local wcl3Imported, wcl3Message = addon.WarcraftLogs:Import(
    "GCPWCL3|1\n"
    .. "S|def456|2000|9000|Karazhan|3|2|1\n"
    .. "P|Neuling|MAGE|5400|2|1|0|28499:3|4\n"
    .. "P|Altbestand|WARRIOR|5000|1|0|0|\n"
)
assert(wcl3Imported == true, wcl3Message or "Der GCPWCL3-Import schlug fehl")
local wcl3Summary = addon.RaidMonitor:GetSummary("WCL:def456")
assert(wcl3Summary ~= nil, "Die GCPWCL3-Auswertung wurde nicht gespeichert")
assert(#wcl3Summary.participants == 2, "Nicht alle GCPWCL3-Teilnehmer wurden übernommen")
assert(wcl3Summary.participants[1].resurrects == 4,
    "Die Wiederbelebungen aus dem Companion fehlen")
assert(wcl3Summary.participants[1].consumables.POTION == 3,
    "Die Verbrauchsgegenstände im neuen Format wurden nicht gezählt")
assert(wcl3Summary.participants[2].resurrects == 0,
    "Eine Zeile ohne Wiederbelebungsfeld wurde nicht mit 0 ergänzt")
assert(wcl3Summary.participants[2].seconds == 5000,
    "Eine Zeile ohne Wiederbelebungsfeld wurde falsch zerlegt")

-- Eine Kopfzeile ohne Datenzeilen ist der typische Abschneidefehler beim
-- Einfügen und muss als solcher gemeldet werden.
local truncated, truncatedMessage = addon.WarcraftLogs:Import("GCPWCL3|3\n")
assert(truncated == false, "Ein leerer Companion-Export wurde als Erfolg gewertet")
assert(truncatedMessage:find("Datenzeilen", 1, true),
    "Der abgeschnittene Import nennt die Ursache nicht")

-- Genau der Fall aus dem Spiel: Beim Einfügen ging der Anfang verloren, es
-- kamen nur Teilnehmerzeilen an. Vorher wurden sie stillschweigend verworfen
-- und die Rückmeldung sah aus wie ein gewöhnlicher Profilimport.
local orphan, orphanMessage = addon.WarcraftLogs:Import(
    "P|Neuling|MAGE|5400|2|1|0|28499:3|4\n"
    .. "P|Altbestand|WARRIOR|5000|1|0|0|\n"
)
assert(orphan == false, "Teilnehmerzeilen ohne Sitzungszeile wurden als Erfolg gewertet")
assert(orphanMessage:find("Sitzungszeile", 1, true),
    "Die Meldung nennt die fehlende Sitzungszeile nicht")

-- Der echte Fall aus dem Spiel: Beim Einfügen fielen zwei Zeilenumbrüche weg.
-- Die Kopfzeile klebte am ersten Profil, die Sitzungszeile am letzten. Beide
-- Datensätze gingen dadurch verloren, obwohl der Text vollständig war.
addon.DB:GetGuild().raidSessions = {}
local glued, gluedMessage = addon.WarcraftLogs:Import(
    "GCPWCL3|1Klebstoff-Realm;WARRIOR;WARRIOR:2;\n"
    .. "Zweiter-Realm;MAGE;MAGE:3;S|geklebt|1000|8200|Karazhan|5|4|1\n"
    .. "P|Tester|HUNTER|7200|1|3|0|28495:2|0\n"
)
assert(glued == true, gluedMessage or "Der geklebte Import schlug fehl")
assert(gluedMessage:find("Raidauswertung", 1, true),
    "Die geklebte Sitzungszeile wurde nicht wiederhergestellt: " .. tostring(gluedMessage))
local gluedSummary = addon.RaidMonitor:GetSummary("WCL:geklebt")
assert(gluedSummary ~= nil, "Die Sitzung hinter der Profilzeile wurde nicht erkannt")
assert(#gluedSummary.participants == 1, "Der Teilnehmer der geklebten Sitzung fehlt")
assert(addon.Roster:GetProfile("Klebstoff-Realm") ~= nil,
    "Das Profil hinter der Kopfzeile wurde nicht erkannt")
assert(addon.Roster:GetProfile("Zweiter-Realm") ~= nil,
    "Das Profil vor der Sitzungszeile ging verloren")
addon.DB:GetGuild().raidSessions = {}

-- Zwei aneinandergeklebte Teilnehmerzeilen müssen ebenfalls auseinandergehen.
local gluedPair = addon.WarcraftLogs:Import(
    "GCPWCL3|1\n"
    .. "S|paar|1000|8200|Karazhan|2|2|0\n"
    .. "P|Erster|MAGE|100|0|0|0||0P|Zweiter|ROGUE|200|1|0|0||0\n"
)
assert(gluedPair == true, "Der Import mit geklebten Teilnehmerzeilen schlug fehl")
assert(#addon.RaidMonitor:GetSummary("WCL:paar").participants == 2,
    "Zwei aneinandergeklebte Teilnehmerzeilen wurden nicht getrennt")
addon.DB:GetGuild().raidSessions = {}

local emptyImport, emptyMessage = addon.WarcraftLogs:Import("   \n\n")
assert(emptyImport == false, "Ein leeres Importfeld wurde als Erfolg gewertet")
assert(emptyMessage:find("leer", 1, true), "Das leere Importfeld wird nicht benannt")

-- Ein Profilexport ohne Kopfzeile ist gültig, muss aber als unvollständig
-- gekennzeichnet werden - sonst bleibt unklar, wo die Raidauswertung blieb.
local plain, plainMessage = addon.WarcraftLogs:Import("Kopflos-Realm;WARRIOR;WARRIOR:2;\n")
assert(plain == true, plainMessage or "Der Profilimport ohne Kopfzeile schlug fehl")
assert(plainMessage:find("Kopfzeile", 1, true),
    "Die fehlende Companion-Kopfzeile wird nicht gemeldet")

-- Der alte Profilimport funktioniert unverändert weiter.
local legacyImported = addon.WarcraftLogs:Import(
    "GCPWCL1|2\nKrieger-Realm;WARRIOR;WARRIOR:2;\n"
)
assert(legacyImported == true, "Der alte Profilimport schlägt fehl")
assert(addon.Roster:GetProfile("Krieger-Realm").raidSpecKey == "WARRIOR:2",
    "Das alte Format importiert keine Profile mehr")

addon.DB:GetGuild().raidSessions = {}

-- === Mitgliederpflege: Entscheidungen und Ausschluss ========================
addon.DB:GetGuild().memberCare.decisions = {}
addon.DB:GetGuild().memberCare.accessRanksConfigured = true
addon.DB:GetGuild().memberCare.accessRanks = { ["1"] = true, ["5"] = true }
healerMember = addon.Roster:GetMember("Heiler-Realm")
healerMember.lastOnlineHours = 100 * 24
assert(addon.Roster:CanAccessMemberCare() == true, "Der Testcharakter darf die Mitgliederpflege nicht")
assert(#addon.Roster:GetMemberCareCandidates() == 1, "Der Pflegevorschlag fehlt für den Test")

local postponed, postponeMessage = addon.Roster:SetMemberCareDecision("Heiler-Realm", "POSTPONED")
assert(postponed == true, postponeMessage or "Der Vorschlag ließ sich nicht zurückstellen")
assert(#addon.Roster:GetMemberCareCandidates() == 0, "Ein zurückgestellter Vorschlag erscheint weiter")
assert(addon.Roster:GetMemberCareDecision("Heiler").status == "POSTPONED",
    "Die Entscheidung wurde nicht gespeichert")

-- Nach Ablauf des Datums taucht der Fall wieder auf.
addon.DB:GetGuild().memberCare.decisions[addon.Util.NormalizeName("Heiler")].until_ = "2020-01-01"
assert(#addon.Roster:GetMemberCareCandidates() == 1,
    "Ein abgelaufenes Zurückstellen blendet den Vorschlag weiter aus")
assert(#addon.Roster:GetMemberCareDecisions() == 0,
    "Ein abgelaufenes Zurückstellen bleibt in der Entscheidungsliste und belegt dauerhaft Platz")

assert(addon.Roster:SetMemberCareDecision("Heiler-Realm", "IGNORED") == true,
    "Die Ausnahme ließ sich nicht setzen")
assert(#addon.Roster:GetMemberCareCandidates() == 0, "Eine Ausnahme blendet den Vorschlag nicht aus")
assert(#addon.Roster:GetMemberCareDecisions() == 1, "Die Ausnahmeliste ist leer")
assert(addon.Roster:ClearMemberCareDecision("Heiler") == true, "Der Eintrag ließ sich nicht zurückholen")
assert(#addon.Roster:GetMemberCareCandidates() == 1, "Nach dem Zurückholen fehlt der Vorschlag")

-- Entscheidungen werden gildenweit synchronisiert, ohne alte Absender zu
-- ueberschreiben.
addon.Roster:SetMemberCareDecision("Heiler-Realm", "IGNORED")
local careMessages = addon.Sync:BuildGuildProfileMessages()
local carePayload = ""
for _, careMessage in ipairs(careMessages) do
    assert(#careMessage <= 255, "Ein Gildenprofil-Paket mit Entscheidungen ist zu lang")
    carePayload = carePayload .. careMessage:match("^G|[^|]+|[^|]+|[^|]+|[^|]+|(.*)$")
end
assert(carePayload:find("Heiler:IGNORED", 1, true), "Die Entscheidung fehlt in der Synchronisierung")

local careFields = addon.Util.SplitFields(carePayload)
assert(careFields[21] ~= nil, "Das Entscheidungsfeld fehlt in der Nutzlast")
addon.DB:GetGuild().memberCare.decisions = {}
addon.DB:GetGuild().profile.updatedAt = 0
addon.Sync:ReceiveGuildProfileChunk(careMessages[1], "Tester-Realm")
if #careMessages > 1 then
    for index = 2, #careMessages do
        addon.Sync:ReceiveGuildProfileChunk(careMessages[index], "Tester-Realm")
    end
end
assert(addon.Roster:GetMemberCareDecision("Heiler") ~= nil,
    "Die empfangene Entscheidung wurde nicht übernommen")

-- Ein älterer Absender kennt das Entscheidungsfeld nicht. Sein Paket darf die
-- vorhandenen Einträge nicht löschen.
local legacyPayload = table.concat({
    "GP", "9999999999", "", "", "", "", "", "",
    "1", "0,1",
    "", "", "",
    "60", "1", "0,1",
    "1", "1,5",
    "1", "0,1,5",
}, "|")
assert(#addon.Util.SplitFields(legacyPayload) == 20, "Das Alt-Paket hat die falsche Feldzahl")
addon.Sync:ReceiveGuildProfileChunk("G|7|legacy1|1|1|" .. legacyPayload, "Tester-Realm")
assert(addon.Roster:GetMemberCareDecision("Heiler") ~= nil,
    "Ein Paket ohne Entscheidungsfeld hat die Einträge gelöscht")

-- Die Warcraft-Logs-Gildenquelle reist im Gildenprofil mit, damit sie nur
-- einer pflegen muss. Ein Alt-Paket ohne das Feld darf sie nicht löschen.
addon.WarcraftLogs:SaveSource("https://de.fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath")
sourceMessages = addon.Sync:BuildGuildProfileMessages()
sourcePayload = ""
for _, sourceMessage in ipairs(sourceMessages) do
    assert(#sourceMessage <= 255, "Ein Gildenprofil-Paket mit Gildenquelle ist zu lang")
    sourcePayload = sourcePayload .. sourceMessage:match("^G|[^|]+|[^|]+|[^|]+|[^|]+|(.*)$")
end
sourceFields = addon.Util.SplitFields(sourcePayload)
assert(sourceFields[24] == "de.fresh.warcraftlogs.com,eu,thunderstrike,aftermath",
    "Die Gildenquelle fehlt in der Gildenprofil-Nutzlast: " .. tostring(sourceFields[24]))
-- Empfang: eine fremde Quelle wird übernommen.
addon.DB:GetGuild().warcraftLogs.host = ""
addon.DB:GetGuild().warcraftLogs.region = ""
addon.DB:GetGuild().warcraftLogs.serverSlug = ""
addon.DB:GetGuild().warcraftLogs.guildSlug = ""
addon.DB:GetGuild().warcraftLogs.url = ""
addon.DB:GetGuild().profile.updatedAt = 0
for _, sourceMessage in ipairs(sourceMessages) do
    addon.Sync:ReceiveGuildProfileChunk(sourceMessage, "Tester-Realm")
end
assert(addon.DB:GetGuild().warcraftLogs.serverSlug == "thunderstrike",
    "Eine empfangene Gildenquelle wurde nicht übernommen")
assert(addon.DB:GetGuild().warcraftLogs.host == "de.fresh.warcraftlogs.com",
    "Der Host der empfangenen Gildenquelle fehlt")
assert(addon.DB:GetGuild().warcraftLogs.url
    == "https://de.fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath",
    "Die URL der empfangenen Gildenquelle ist falsch: "
    .. tostring(addon.DB:GetGuild().warcraftLogs.url))
-- Ein Alt-Paket ohne Feld 24 lässt die vorhandene Quelle stehen.
addon.Sync:ReceiveGuildProfileChunk("G|7|legacy2|1|1|" .. legacyPayload, "Tester-Realm")
assert(addon.DB:GetGuild().warcraftLogs.serverSlug == "thunderstrike",
    "Ein Gildenprofil ohne Quellenfeld hat die gespeicherte Gildenquelle gelöscht")

-- Rangunabhängiger Abgleich: das Gildenprofil darf auch von einem einfachen
-- Mitglied kommen, damit ein Offizier auf einem frischen Rechner nachgereicht
-- bekommt, was ein Mitglied zwischengespeichert hat. Der neuere Stand gewinnt.
assert(addon.Roster:CanEditGuildProfile("Heiler-Realm") == false,
    "Testannahme falsch: Heiler-Realm darf das Profil bearbeiten")
addon.DB:GetGuild().profile.description = "Von einem Mitglied gepflegt"
addon.DB:GetGuild().profile.updatedAt = 5000
relayMessages = addon.Sync:BuildGuildProfileMessages()
addon.DB:GetGuild().profile.description = ""
addon.DB:GetGuild().profile.updatedAt = 0
for _, relayMessage in ipairs(relayMessages) do
    addon.Sync:ReceiveGuildProfileChunk(relayMessage, "Heiler-Realm")
end
assert(addon.DB:GetGuild().profile.description == "Von einem Mitglied gepflegt",
    "Ein Gildenprofil von einem einfachen Mitglied wurde nicht übernommen")
assert(addon.DB:GetGuild().profile.updatedAt == 5000,
    "Der Zeitstempel des übernommenen Mitglieds-Gildenprofils stimmt nicht")

-- Der Zeitstempel schützt weiterhin: ein älterer Stand darf den neueren nicht
-- überschreiben, egal von welchem Rang er kommt.
addon.DB:GetGuild().profile.description = "Alter Stand"
addon.DB:GetGuild().profile.updatedAt = 2000
staleMessages = addon.Sync:BuildGuildProfileMessages()
addon.DB:GetGuild().profile.description = "Neuer Stand"
addon.DB:GetGuild().profile.updatedAt = 8000
for _, staleMessage in ipairs(staleMessages) do
    addon.Sync:ReceiveGuildProfileChunk(staleMessage, "Heiler-Realm")
end
assert(addon.DB:GetGuild().profile.description == "Neuer Stand",
    "Ein älterer Gildenprofil-Stand hat den neueren überschrieben")

-- Von jemandem, der nachweislich kein Gildenmitglied ist, wird nichts
-- übernommen - auch nicht mit neuerem Zeitstempel.
addon.DB:GetGuild().profile.description = "Von einem Fremden"
addon.DB:GetGuild().profile.updatedAt = 999999
strangerMessages = addon.Sync:BuildGuildProfileMessages()
addon.DB:GetGuild().profile.description = "Neuer Stand"
addon.DB:GetGuild().profile.updatedAt = 8000
for _, strangerMessage in ipairs(strangerMessages) do
    addon.Sync:ReceiveGuildProfileChunk(strangerMessage, "Fremder-Realm")
end
assert(addon.DB:GetGuild().profile.description == "Neuer Stand",
    "Ein Gildenprofil von einem Nicht-Gildenmitglied wurde übernommen")

-- Ausschluss: jede einzelne Sperre muss halten.
canRemoveFromGuild = false
local blockedByBlizzard, blockedReason = addon.Roster:CanRemoveMember("Heiler-Realm")
assert(blockedByBlizzard == false and blockedReason:find("WoW erlaubt", 1, true),
    "Ohne echte WoW-Berechtigung wurde das Entfernen erlaubt")

canRemoveFromGuild = true
local selfRemoval, selfReason = addon.Roster:CanRemoveMember("Tester-Realm")
assert(selfRemoval == false and selfReason:find("selbst", 1, true),
    "Der eigene Charakter ließ sich entfernen")

assert(addon.Roster:SetMemberCareRankProtected(5, true) == true, "Rangschutz ließ sich nicht setzen")
local protectedRemoval, protectedReason = addon.Roster:CanRemoveMember("Heiler-Realm")
assert(protectedRemoval == false and protectedReason:find("geschützt", 1, true),
    "Ein geschützter Rang ließ sich entfernen")
addon.Roster:SetMemberCareRankProtected(5, false)

local allowedRemoval = addon.Roster:CanRemoveMember("Heiler-Realm")
assert(allowedRemoval == true, "Ein zulässiger Ausschluss wurde abgelehnt")
local removed, removeMessage = addon.Roster:RemoveMember("Heiler-Realm")
assert(removed == true, removeMessage or "Der Ausschluss schlug fehl")
assert(uninvitedPlayers[1] == "Heiler-Realm", "Es wurde der falsche Spieler entfernt")
assert(#uninvitedPlayers == 1, "Es wurde mehr als ein Spieler entfernt")
assert(addon.Roster:GetMemberCareDecision("Heiler").status == "DONE",
    "Der Ausschluss wurde nicht als erledigt vermerkt")

-- Ein Rang ohne Mitgliederpflege darf gar nichts davon.
addon.DB:GetGuild().memberCare.accessRanks = { ["9"] = true }
addon.DB:GetGuild().memberCare.accessRanksConfigured = true
assert(addon.Roster:SetMemberCareDecision("Heiler-Realm", "IGNORED") == false,
    "Ein unberechtigter Rang konnte eine Ausnahme setzen")
assert(addon.Roster:CanRemoveMember("Heiler-Realm") == false,
    "Ein unberechtigter Rang durfte entfernen")
addon.DB:GetGuild().memberCare.accessRanks = { ["1"] = true, ["5"] = true }
addon.DB:GetGuild().memberCare.decisions = {}
healerMember.lastOnlineHours = 0

-- === Gear Audit ============================================================
local ENCHANTED_HEAD = "|cffa335ee|Hitem:1000:2564:0:0:0:0:0:0:70|h[Kopf]|h|r"
local SOCKETED_CHEST = "|cffa335ee|Hitem:1001:0:3000:0:0:0:0:0:70|h[SOCKETS3]|h|r"

local parsedHead = addon.GearAudit:ParseItemLink(ENCHANTED_HEAD)
assert(parsedHead.itemID == 1000, "Die Gegenstands-ID wurde nicht gelesen")
assert(parsedHead.enchantID == 2564, "Die Verzauberungs-ID wurde nicht gelesen")
assert(parsedHead.filledGems == 0, "Ein leerer Sockel wurde als besetzt gelesen")
local parsedChest = addon.GearAudit:ParseItemLink(SOCKETED_CHEST)
assert(parsedChest.filledGems == 1, "Der eingesetzte Edelstein wurde nicht erkannt")
assert(addon.GearAudit:ParseItemLink("kein Link") == nil, "Ein ungültiger Link wurde angenommen")
assert(addon.GearAudit:CountEmptySockets(SOCKETED_CHEST, 1) == 2,
    "Die leeren Sockel wurden falsch gezählt")

-- GetItemStats gilt in Classic als veraltet. Liefert der Tooltip die
-- uebersetzten Sockelzeilen, zaehlen die - unabhaengig von der Sprache.
local TOOLTIP_SOCKETS = "|cffa335ee|Hitem:1234:0:0:0:0:0:0:0:70|h[Sockelteil]|h|r"
tooltipLines[TOOLTIP_SOCKETS] = {
    "Sockelteil",
    "Rüstung 200",
    "Roter Sockel",
    "Blauer Sockel",
    "Sockelbonus: +4 Ausdauer",
}
assert(addon.GearAudit:CountEmptySockets(TOOLTIP_SOCKETS, 0) == 2,
    "Leere Sockel werden nicht aus dem Tooltip gelesen")
tooltipLines[TOOLTIP_SOCKETS] = { "Sockelteil", "Rüstung 200" }
assert(addon.GearAudit:CountEmptySockets(TOOLTIP_SOCKETS, 0) == 0,
    "Ein Gegenstand ohne Sockel meldet trotzdem leere Sockel")

local unreadableAudit = addon.GearAudit:BuildAudit("Tester", "HUNTER", function()
    return nil
end, "SELF", function(slotID)
    return slotID == 15 and 9999 or nil
end)
assert(unreadableAudit.unreadableSlots == 1,
    "Ein angelegter, aber noch nicht geladener Rücken-Slot gilt fälschlich als leer")
assert(#addon.GearAudit:BuildEquipmentMessages(unreadableAudit) == 0,
    "Ein unvollständig gelesener Ausrüstungsstand wurde an die Gilde übertragen")

inspectGear.player = { [1] = ENCHANTED_HEAD, [5] = SOCKETED_CHEST }
local sentBeforeOwnGear = #sentAddon
local selfAudited, selfMessage = addon.GearAudit:AuditSelf()
assert(selfAudited == true, "Die eigene Ausrüstung wurde nicht geprüft")
local ownEquipmentMessages = {}
for messageIndex = sentBeforeOwnGear + 1, #sentAddon do
    local message = sentAddon[messageIndex][2]
    if message:sub(1, 2) == "E|" then
        ownEquipmentMessages[#ownEquipmentMessages + 1] = message
        assert(#message <= 255, "Ein Ausrüstungspaket überschreitet das Addon-Nachrichtenlimit")
    end
end
assert(#ownEquipmentMessages > 0,
    "Die automatisch geprüfte eigene Ausrüstung wurde nicht im Hintergrund bereitgestellt")
local sentAfterOwnGear = #sentAddon
addon.GearAudit:AuditSelf()
assert(#sentAddon == sentAfterOwnGear,
    "Ein unveränderter Ausrüstungsstand wurde ohne Anlass erneut übertragen")
assert(addon.GearAudit:ReplyWithEquipmentSnapshot() == true and #sentAddon > sentAfterOwnGear,
    "Eine automatische Handshake-Antwort stellt den aktuellen Ausrüstungsstand nicht bereit")
local sentAfterEquipmentReply = #sentAddon
assert(addon.GearAudit:ReplyWithEquipmentSnapshot() == false
    and #sentAddon == sentAfterEquipmentReply,
    "Ausrüstungsantworten auf Handshakes werden nicht gedrosselt")
assert(addon.GearAudit.status ~= "", "Nach der Eigenprüfung steht der Status weiter auf leer")
local ownAudit = addon.GearAudit:GetAudit("Tester")
assert(ownAudit ~= nil, "Die eigene Prüfung wurde nicht gespeichert")
assert(ownAudit.source == "SELF", "Die eigene Prüfung ist nicht als solche gekennzeichnet")
assert(ownAudit.missingEnchants == 1, "Die fehlende Verzauberung auf der Brust wurde nicht erkannt")
assert(ownAudit.emptySockets == 2, "Die leeren Sockel fehlen in der Zusammenfassung")
assert(ownAudit.unknownEnchants == 0,
    "Die standardmäßig anerkannte vorhandene Verzauberung wurde als unbekannt geführt")
assert(ownAudit.emptySlots == 7, "Leere Pflichtslots wurden falsch gezählt")
assert(addon.GearAudit:GetIssueCount(ownAudit) == 10,
    "Leere Pflichtslots werden in der Fundzahl des Spielers nicht berücksichtigt")
assert(selfMessage:find("leere Sockel", 1, true), "Die Rückmeldung nennt die leeren Sockel nicht")

local headEntry, chestEntry, neckEntry
for _, entry in ipairs(ownAudit.slots) do
    if entry.key == "HEAD" then
        headEntry = entry
    elseif entry.key == "CHEST" then
        chestEntry = entry
    elseif entry.key == "NECK" then
        neckEntry = entry
    end
end
assert(headEntry.verdict == "SOLID",
    "Eine vorhandene unbewertete Verzauberung wurde nicht standardmäßig anerkannt")
assert(chestEntry.verdict == "MISSING", "Die fehlende Verzauberung wurde nicht gemeldet")
assert(neckEntry.verdict == "EMPTY", "Ein leerer Slot wurde nicht als leer gemeldet")

-- Wer die lokale Automatik abschaltet, sieht unbewertete Verzauberungen
-- ausdrücklich als unbekannt. Das ist die alternative, in den Einstellungen
-- angebotene Sicht.
addon.DB:GetSettings().gearAudit.acceptUnratedEnchants = false
addon.GearAudit:AuditSelf()
local strictAudit = addon.GearAudit:GetAudit("Tester")
local strictHead
for _, entry in ipairs(strictAudit.slots) do
    if entry.key == "HEAD" then
        strictHead = entry
    end
end
assert(strictAudit.unknownEnchants == 1 and strictHead.verdict == "UNKNOWN",
    "Die abgeschaltete Anerkennung lässt eine unbewertete Verzauberung nicht als unbekannt erscheinen")

-- Ein gepflegter Regelsatz bewertet dieselbe Verzauberung.
addon.EnchantRuleSet.rules[2564] = {
    verdict = "OPTIMAL",
    name = "Beispielverzauberung",
    slots = { "HEAD" },
    source = "Testregel",
}
addon.GearAudit:AuditSelf()
local ratedAudit = addon.GearAudit:GetAudit("Tester")
local ratedHead
for _, entry in ipairs(ratedAudit.slots) do
    if entry.key == "HEAD" then
        ratedHead = entry
    end
end
assert(ratedHead.verdict == "OPTIMAL", "Die Regel wurde nicht angewendet")
assert(ratedHead.reason:find("Testregel", 1, true), "Die Regelquelle fehlt in der Begründung")
assert(ratedAudit.unknownEnchants == 0, "Die bewertete Verzauberung gilt weiter als unbekannt")
addon.EnchantRuleSet.rules[2564] = nil
addon.GearAudit:AuditSelf()
assert(addon.GearAudit:GetAudit("Tester").unknownEnchants == 1,
    "Ohne Regel gilt die Verzauberung nicht wieder als unbekannt")
addon.DB:GetSettings().gearAudit.acceptUnratedEnchants = true
addon.GearAudit:ReapplyEnchantRules()

-- Inspect-Durchlauf: erreichbare Spieler werden geprüft, andere übersprungen.
raidRoster = { { "Tester", 2, "HUNTER" }, { "Heiler", 1, "PRIEST" } }
unitNames.raid1 = "Heiler"
unitNames.raid2 = "Schurke"
unitClasses.raid1 = "PRIEST"
inspectGear.raid1 = { [5] = SOCKETED_CHEST }
inspectGear.raid2 = { [5] = SOCKETED_CHEST }
inspectableUnits.raid2 = false

timerDelayThreshold = 3
local scanStarted, scanMessage = addon.GearAudit:StartRaidScan()
assert(scanStarted == true, scanMessage or "Die Ausrüstungsprüfung startete nicht")
assert(addon.GearAudit.active ~= nil, "Es wird niemand inspiziert")
assert(addon.GearAudit.active.unit == "raid1", "Der falsche Spieler wird inspiziert")
assert(addon.GearAudit:OnInspectReady("GUID-raid1") == true, "Die Inspektion wurde nicht ausgewertet")
assert(addon.GearAudit.scanning == false, "Die Prüfung läuft nach dem letzten Spieler weiter")
assert(addon.GearAudit.completed == 1, "Der geprüfte Spieler wurde nicht gezählt")
assert(addon.GearAudit.skipped == 1, "Der nicht erreichbare Spieler wurde nicht übersprungen")
assert(addon.GearAudit.status:find("nicht in Reichweite", 1, true),
    "Die Statusmeldung nennt die übersprungenen Spieler nicht")
local healerAudit = addon.GearAudit:GetAudit("Heiler")
assert(healerAudit ~= nil, "Die Inspektion wurde nicht gespeichert")
assert(healerAudit.source == "INSPECT", "Die Inspektion ist nicht als solche gekennzeichnet")
assert(healerAudit.missingEnchants == 1, "Die fehlende Verzauberung des Geprüften fehlt")
assert(addon.GearAudit:GetAudit("Schurke") == nil,
    "Ein nicht erreichbarer Spieler wurde trotzdem gespeichert")
timerDelayThreshold = math.huge

-- Ein Addon-Nutzer liefert seine eigenen Messwerte automatisch. Der Empfänger
-- bewertet sie lokal und ein späterer Gruppenlauf inspectet ihn nicht erneut.
currentTime = currentTime + 1
local remoteSnapshot = addon.Util.DeepCopy(addon.GearAudit:GetAudit("Tester"))
remoteSnapshot.name = "Heiler"
remoteSnapshot.classFile = "PRIEST"
remoteSnapshot.specKey = "PRIEST:2"
remoteSnapshot.inspectedAt = currentTime
for _, entry in ipairs(remoteSnapshot.slots) do
    if entry.key == "BACK" then
        entry.itemID = 9999
        entry.enchantID = 0
        entry.emptySockets = 0
    end
end
local remoteMessages = addon.GearAudit:BuildEquipmentMessages(remoteSnapshot)
assert(#remoteMessages > 0, "Der kompakte Ausrüstungs-Snapshot wurde nicht erzeugt")
local remotePayloadParts = {}
for _, message in ipairs(remoteMessages) do
    assert(#message <= 255, "Ein empfangbares Ausrüstungspaket ist zu lang")
    remotePayloadParts[#remotePayloadParts + 1] =
        message:match("^E|[^|]+|[^|]+|[^|]+|[^|]+|(.*)$")
    addon.Sync:OnMessage("GuildCopilot", message, "GUILD", "Heiler-Realm")
end
local syncedHealer = addon.GearAudit:GetAudit("Heiler")
assert(syncedHealer and syncedHealer.source == "SYNC",
    "Der automatisch bereitgestellte Ausrüstungs-Snapshot wurde nicht gespeichert")
assert(syncedHealer.specKey == "PRIEST:2",
    "Die Spec des bereitgestellten Ausrüstungs-Snapshots fehlt")
assert(syncedHealer.slots[1].itemID == 1000 and syncedHealer.slots[1].enchantID == 2564,
    "Die kompakten Slot-Messwerte wurden beim Empfang verändert")
local syncedBack
for _, entry in ipairs(syncedHealer.slots) do
    if entry.key == "BACK" then
        syncedBack = entry
    end
end
assert(syncedBack and syncedBack.verdict == "MISSING",
    "Ein selbst bereitgestellter, unverzauberter Rücken wird nicht als Fund erkannt")

local syncedAt = syncedHealer.inspectedAt
local malformedAccepted = addon.GearAudit:ReceiveEquipmentChunk(
    "E|7|kaputt|1|1|ES|PRIEST|PRIEST:2|" .. currentTime .. "|1:0:99:0",
    "Heiler-Realm")
assert(malformedAccepted == false and addon.GearAudit:GetAudit("Heiler").inspectedAt == syncedAt,
    "Ein unvollständiger oder widersprüchlicher Ausrüstungs-Snapshot wurde übernommen")
local extraFieldAudit = addon.GearAudit:DecodeEquipmentPayload(
    table.concat(remotePayloadParts) .. "|unerwartet", "Heiler-Realm")
assert(extraFieldAudit == nil and addon.GearAudit:GetAudit("Heiler").inspectedAt == syncedAt,
    "Ein Ausrüstungspaket mit unerwarteten Feldern wurde übernommen")

raidRoster = { { "Tester", 2, "HUNTER" }, { "Heiler", 1, "PRIEST" } }
unitNames.raid1 = "Heiler"
unitNames.raid2 = "Schurke"
inspectableUnits.raid2 = false
local fallbackStarted = addon.GearAudit:StartRaidScan()
assert(fallbackStarted == true, "Der Inspect-Rückfall ließ sich nicht starten")
assert(addon.GearAudit.shared == 1 and addon.GearAudit.completed == 0 and addon.GearAudit.skipped == 1,
    "Frische Addon-Daten wurden im Gruppenlauf nicht statt eines Inspect verwendet")
assert(addon.GearAudit.selectedName == "Heiler",
    "Der per Addon-Daten geprüfte Gruppenspieler wird nicht automatisch ausgewählt")
assert(addon.GearAudit.status:find("über Addon%-Daten"),
    "Die Oberfläche nennt die automatisch verwendeten Ausrüstungsdaten nicht")

-- Die Verzauberung wird aus dem Tooltip gelesen, nicht aus einer eigenen
-- Datenbank: die Zeile, die ohne Verzauberung fehlt, ist der Name.
local PLAIN_HEAD = "|cffa335ee|Hitem:1000:0:0:0:0:0:0:0:70|h[Kopf]|h|r"
tooltipLines[ENCHANTED_HEAD] = {
    "Kopf des Testens",
    "Rüstung 100",
    "Außergewöhnliche Gesundheit",
    "Haltbarkeit 60 / 60",
}
tooltipLines[PLAIN_HEAD] = {
    "Kopf des Testens",
    "Rüstung 100",
    "Haltbarkeit 60 / 60",
}
assert(addon.GearAudit:ResolveEnchantName(ENCHANTED_HEAD, 2564) == "Außergewöhnliche Gesundheit",
    "Die Verzauberung wurde nicht aus dem Tooltip gelesen")
assert(addon.GearAudit:ResolveEnchantName(PLAIN_HEAD, 0) == nil,
    "Ohne Verzauberung wurde trotzdem ein Name gemeldet")
assert(addon.GearAudit:ResolveEnchantName("|cff|Hitem:4242:9:0:0:0:0:0:0:70|h[Unbekannt]|h|r", 9) == nil,
    "Ohne Tooltipdaten wurde ein Name erfunden")

-- Faellt nur die Vergleichsfassung aus, waere jede Zeile "neu". Dann darf
-- nichts gemeldet werden, sonst gilt der Gegenstandsname als Verzauberung.
local LONELY = "|cff|Hitem:5555:1234:0:0:0:0:0:0:70|h[Einsam]|h|r"
tooltipLines[LONELY] = { "Einsamer Helm", "Rüstung 5", "Irgendeine Verzauberung" }
assert(addon.GearAudit:ResolveEnchantName(LONELY, 1234) == nil,
    "Ohne Vergleichs-Tooltip wurde der Gegenstandsname als Verzauberung gemeldet")

inspectGear.player = { [1] = ENCHANTED_HEAD, [5] = SOCKETED_CHEST }
addon.DB:GetSettings().gearAudit.acceptUnratedEnchants = false
addon.GearAudit:AuditSelf()
local namedHead
for _, entry in ipairs(addon.GearAudit:GetAudit("Tester").slots) do
    if entry.key == "HEAD" then
        namedHead = entry
    end
end
assert(namedHead.enchantName == "Außergewöhnliche Gesundheit",
    "Der Verzauberungsname fehlt im Audit")
assert(namedHead.reason == "Verzaubert: Außergewöhnliche Gesundheit",
    "Der Hinweis zeigt weiter die nackte Verzauberungs-ID")
assert(namedHead.verdict == "UNKNOWN",
    "Ein gelesener Name darf noch keine Qualitätsbewertung bedeuten")
addon.DB:GetSettings().gearAudit.acceptUnratedEnchants = true
addon.GearAudit:ReapplyEnchantRules()

-- Die Gilde bewertet eine erkannte Verzauberung selbst; die ID kommt aus dem
-- Item-Link, den Namen liefert der Tooltip.
addon.DB:GetGuild().enchantRules = {}
local rated, ratedMessage = addon.GearAudit:CycleEnchantRule(2564, "Außergewöhnliche Gesundheit")
assert(rated == true, ratedMessage or "Die Bewertung ließ sich nicht setzen")
assert(ratedMessage:find("Optimal", 1, true), "Die erste Stufe ist nicht Optimal")
assert(addon.GearAudit:GetGuildEnchantRule(2564).verdict == "OPTIMAL",
    "Die Gildenregel wurde nicht gespeichert")

local ratedHead
for _, entry in ipairs(addon.GearAudit:GetAudit("Tester").slots) do
    if entry.key == "HEAD" then
        ratedHead = entry
    end
end
assert(ratedHead.verdict == "OPTIMAL",
    "Bereits gespeicherte Prüfungen wurden nicht neu bewertet")
assert(ratedHead.reason:find("Regel für alle Specs", 1, true),
    "Der Geltungsbereich der Bewertung fehlt")

addon.GearAudit:CycleEnchantRule(2564, "Außergewöhnliche Gesundheit")
assert(addon.GearAudit:GetGuildEnchantRule(2564).verdict == "SOLID", "Zweite Stufe ist nicht Solide")
addon.GearAudit:CycleEnchantRule(2564, "Außergewöhnliche Gesundheit")
assert(addon.GearAudit:GetGuildEnchantRule(2564).verdict == "IMPROVABLE",
    "Dritte Stufe ist nicht Verbesserbar")
addon.GearAudit:CycleEnchantRule(2564, "Außergewöhnliche Gesundheit")
assert(addon.GearAudit:GetGuildEnchantRule(2564) == nil,
    "Nach der letzten Stufe wurde die Bewertung nicht entfernt")

-- Der Regelsatz wandert als ID und Stufe durch die Gilde, ohne Namen.
addon.GearAudit:CycleEnchantRule(2564, "Außergewöhnliche Gesundheit")
local rulePayload = ""
for _, ruleMessage in ipairs(addon.Sync:BuildGuildProfileMessages()) do
    assert(#ruleMessage <= 255, "Ein Gildenprofil-Paket mit Regelsatz ist zu lang")
    rulePayload = rulePayload .. ruleMessage:match("^G|[^|]+|[^|]+|[^|]+|[^|]+|(.*)$")
end
assert(rulePayload:find("2564:O", 1, true), "Die Regel fehlt in der Synchronisierung")
assert(not rulePayload:find("Außergewöhnliche", 1, true),
    "Der übersetzte Name wird unnötig mitgeschickt")
local ruleFields = addon.Util.SplitFields(rulePayload)
assert(ruleFields[22] ~= nil, "Das Regelfeld fehlt in der Nutzlast")

-- Empfangen darf niemals ein Senden ausloesen, sonst schaukeln sich zwei
-- Clients gegenseitig auf, und der Zeitstempel darf nicht neu gesetzt werden.
addon.DB:GetGuild().enchantRules = {}
addon.DB:GetGuild().profile.updatedAt = 0
local incomingRules = addon.Sync:BuildGuildProfileMessages()
addon.DB:GetGuild().profile.updatedAt = 0
local sentBeforeReceive = #sentAddon
for _, ruleMessage in ipairs(incomingRules) do
    addon.Sync:ReceiveGuildProfileChunk(ruleMessage, "Tester-Realm")
end
assert(#sentAddon == sentBeforeReceive,
    "Der Empfang eines Gildenprofils hat ein erneutes Senden ausgelöst")
assert(addon.DB:GetGuild().profile.updatedAt == 0,
    "Der Empfang hat den Zeitstempel auf jetzt gesetzt und damit die Reihenfolge zerstört")

-- Ein Rang ohne Einstellungsrecht darf nichts bewerten.
local editorRanks = addon.DB:GetGuild().profilePermissions.editorRanks
addon.DB:GetGuild().profilePermissions.editorRanks = { ["9"] = true }
local denied, deniedMessage = addon.GearAudit:CycleEnchantRule(7777, "Testverzauberung")
assert(denied == false and deniedMessage:find("Regelsatz nicht ändern", 1, true),
    "Ein unberechtigter Rang konnte den Regelsatz ändern")
addon.DB:GetGuild().profilePermissions.editorRanks = editorRanks
addon.DB:GetGuild().enchantRules = {}
addon.GearAudit:AuditSelf()

-- Funde werden in ganzen Sätzen aufbereitet.
local ownFindings = addon.GearAudit:GetFindings(addon.GearAudit:GetAudit("Tester"))
local findingTexts = {}
for _, finding in ipairs(ownFindings) do
    findingTexts[#findingTexts + 1] = finding.text
end
local findingBlock = table.concat(findingTexts, "\n")
assert(findingBlock:find("1 fehlende Verzauberung: Brust", 1, true),
    "Eine einzelne fehlende Verzauberung wird nicht mit Slotnamen benannt")
assert(findingBlock:find("2 leere Sockel: Brust", 1, true),
    "Die leeren Sockel werden nicht mit Slotnamen benannt")
assert(findingBlock:find("leere Ausrüstungsplätze", 1, true),
    "Leere Pflichtslots werden nicht gemeldet")
-- Ohne unbewertete Verzauberung darf auch kein Hinweis darauf erscheinen.
for _, finding in ipairs(ownFindings) do
    assert(finding.severity ~= "INFO" or not finding.text:find("nicht bewertet", 1, true),
        "Es wird über unbewertete Verzauberungen berichtet, obwohl keine offen ist")
end

-- Mehrere fehlende Verzauberungen werden zusammengefasst aufgezählt.
inspectGear.player = { [1] = "|Hitem:1:0:0:0:0:0:0:0:70|h[K]|h", [3] = "|Hitem:2:0:0:0:0:0:0:0:70|h[S]|h" }
addon.GearAudit:AuditSelf()
local multiBlock = ""
for _, finding in ipairs(addon.GearAudit:GetFindings(addon.GearAudit:GetAudit("Tester"))) do
    multiBlock = multiBlock .. finding.text .. "\n"
end
assert(multiBlock:find("2 fehlende Verzauberungen: Kopf, Schulter", 1, true),
    "Mehrere fehlende Verzauberungen werden nicht aufgezählt")

-- Saubere Ausrüstung meldet das ausdrücklich.
addon.EnchantRuleSet.rules[7777] = { verdict = "SOLID", name = "Testverzauberung" }
inspectGear.player = {}
for _, slot in ipairs(addon.GearSlots) do
    if slot.enchantRequired then
        inspectGear.player[slot.id] = "|Hitem:9:7777:0:0:0:0:0:0:70|h[X]|h"
    end
end
addon.GearAudit:AuditSelf()
local cleanFindings = addon.GearAudit:GetFindings(addon.GearAudit:GetAudit("Tester"))
assert(cleanFindings[1].severity == "OK", "Saubere Ausrüstung wird nicht als in Ordnung gemeldet")
assert(cleanFindings[1].text:find("Alles verzaubert", 1, true), "Die Erfolgsmeldung fehlt")
addon.EnchantRuleSet.rules[7777] = nil

-- Der eigene Audit erscheint im persönlichen Profil.
addon.UI:ShowPage("ROSTER")
local profilePage = addon.UI.pages.ROSTER
assert(profilePage.profileGearFindings.value:find("Alles verzaubert", 1, true),
    "Die eigene Ausrüstung wird im Profil nicht aufbereitet angezeigt")
assert(profilePage.profileGearAge.value:find("Zuletzt geprüft", 1, true),
    "Das Profil zeigt kein Datenalter")
profilePage.profileGearButton.scripts.OnClick()
assert(profilePage.profileGearFindings.value ~= "", "Der Prüfknopf im Profil bleibt wirkungslos")

-- Eine Gesamtübersicht über alle geprüften Spieler.
inspectGear.player = { [1] = ENCHANTED_HEAD, [5] = SOCKETED_CHEST }
addon.GearAudit:AuditSelf()
local gearOverview = addon.GearAudit:GetOverview()
assert(gearOverview.players >= 1, "Die Übersicht zählt keine geprüften Spieler")
assert(gearOverview.emptySockets >= 2, "Die Übersicht summiert die leeren Sockel nicht")
assert(gearOverview.missingEnchants >= 1, "Die Übersicht summiert die fehlenden Verzauberungen nicht")

local listTemplate = addon.Util.DeepCopy(addon.GearAudit:GetAudit("Tester"))
for listIndex = 1, 14 do
    local listAudit = addon.Util.DeepCopy(listTemplate)
    listAudit.name = "Listenmitglied" .. listIndex
    addon.GearAudit:StoreAudit(listAudit)
end

-- Die Prüfung erscheint in der Oberfläche, sortiert nach Anzahl der Funde.
addon.UI:ShowPage("GEAR")
local gearPage = addon.UI.pages.GEAR
assert(gearPage.gearRows[1].shown == true, "Der geprüfte Spieler fehlt in der Liste")
assert(gearPage.gearPlayerScroll ~= nil, "Die Spielerliste besitzt keinen Scrollbereich")
assert(gearPage.gearRows[13] and gearPage.gearRows[13].shown == true,
    "Mehr als zwölf geprüfte Spieler bleiben weiterhin unsichtbar")
assert(gearPage.gearSlotRows[1].shown == true, "Die Slot-Tabelle ist leer")
addon.GearAudit.selectedName = "Tester"
addon.UI:RefreshGear()
assert(gearPage.gearSlotRows[1].slot.value == "Kopf", "Die Slot-Tabelle zeigt den falschen Slot")
assert(gearPage.gearSlotRows[1].verdict.value == "Solide",
    "Die Bewertung wird nicht angezeigt")

GuildCopilotDB.settings.editorRecoveryAvailable = false
GuildCopilotDB.guilds["Altgilde@Realm"] = {}
addon.DB:Initialize()
assert(addon.DB:GetSettings().gearAudit.auditSelf == nil
    and addon.GearAudit:AuditsSelfAutomatically() == true,
    "Eine alte lokale Einstellung kann den festen Hintergrundabgleich noch abschalten")
assert(GuildCopilotDB.guilds["Altgilde@Realm"].editorRecoveryAvailable == false,
    "Bereits verbrauchte Wiederherstellung wurde bei der Migration nicht übernommen")
assert(GuildCopilotDB.settings.editorRecoveryAvailable == nil,
    "Das alte kontoweite Wiederherstellungsfeld wurde nicht entfernt")
assert(addon.DB:GetGuild().editorRecoveryAvailable == false,
    "Die eigene Gilde hat ihre verbrauchte Wiederherstellung verloren")

-- === Ausgelieferter Verzauberungs-Regelsatz ================================
--
-- Der Regelsatz wird mit belegten Enchant-IDs ausgeliefert. Er darf nur dort
-- greifen, wo er wirklich etwas aussagt: am passenden Slot, beim passenden
-- Archetyp und in einer Phase, die es schon gibt.
--
-- Eigener Block: Lua erlaubt nur 200 lokale Variablen je Funktion, und dieses
-- Testskript ist eine einzige.
do
local HANDS_SLOT = { key = "HANDS", enchantRequired = true }
local BACK_SLOT = { key = "BACK", enchantRequired = true }

assert(next(addon.EnchantRuleSet.rules) ~= nil,
    "Der ausgelieferte Verzauberungs-Regelsatz ist leer")
assert(addon.EnchantRuleSet.rules[2937].verdict == "OPTIMAL",
    "Die belegte Handschuh-Zaubermacht fehlt im Regelsatz")

-- Ein Magier mit Major Spellpower auf den Handschuhen: passt.
local casterVerdict, casterReason = addon.GearAudit:EvaluateEnchant(
    HANDS_SLOT, 2937, "DAMAGER", "Große Zaubermacht", "MAGE:1")
assert(casterVerdict == "OPTIMAL",
    "Die empfohlene Verzauberung des Zauber-Archetyps wird nicht als optimal gewertet")
assert(casterReason:find("Quelle:", 1, true),
    "Die Bewertung nennt ihre Quelle nicht")

-- Derselbe Wert bei einem Heiler: darüber sagt die Regel nichts. Er darf
-- deshalb nicht als optimal gelten - aber auch nicht als Fund.
local healerVerdict = addon.GearAudit:EvaluateEnchant(
    HANDS_SLOT, 2937, "HEALER", "Große Zaubermacht", "PRIEST:2")
assert(healerVerdict ~= "OPTIMAL",
    "Eine Regel des Zauber-Archetyps wird fälschlich auf einen Heiler angewendet")
assert(healerVerdict ~= "MISSING" and healerVerdict ~= "IMPROVABLE",
    "Eine nicht zutreffende Regel erzeugt beim Heiler einen Fund")

-- Handschuhregel auf dem Rücken: gilt nicht.
local wrongSlotVerdict = addon.GearAudit:EvaluateEnchant(
    BACK_SLOT, 2937, "DAMAGER", "Große Zaubermacht", "MAGE:1")
assert(wrongSlotVerdict ~= "OPTIMAL",
    "Eine Handschuhregel wird auch auf dem Rücken angewendet")

-- Ohne bestätigte Spec lässt sich der Archetyp nicht bestimmen; dann greift
-- eine archetypgebundene Regel bewusst nicht.
local noSpecVerdict = addon.GearAudit:EvaluateEnchant(
    HANDS_SLOT, 2937, nil, "Große Zaubermacht", nil)
assert(noSpecVerdict ~= "OPTIMAL",
    "Ohne bekannte Spec wird eine archetypgebundene Regel trotzdem angewendet")

-- Eine Regel aus einer späteren Phase gilt noch nicht.
addon.EnchantRuleSet.rules[7778] = {
    verdict = "OPTIMAL", name = "Zukunftsverzauberung",
    slots = { "HANDS" }, phase = "T6.5",
}
addon.DB:GetGuild().profile.contentPhase = "T5"
assert(addon.GearAudit:GetContentPhase() == "T5", "Die eingestellte Phase wird nicht gelesen")
local futureVerdict = addon.GearAudit:EvaluateEnchant(
    HANDS_SLOT, 7778, "DAMAGER", "Zukunftsverzauberung", "MAGE:1")
assert(futureVerdict ~= "OPTIMAL",
    "Eine Verzauberung aus einer späteren Phase wird schon jetzt empfohlen")

-- Ist die Gilde so weit, greift dieselbe Regel.
addon.DB:GetGuild().profile.contentPhase = "T6.5"
assert(addon.GearAudit:EvaluateEnchant(
    HANDS_SLOT, 7778, "DAMAGER", "Zukunftsverzauberung", "MAGE:1") == "OPTIMAL",
    "In der passenden Phase greift die Regel nicht")
addon.EnchantRuleSet.rules[7778] = nil
addon.DB:GetGuild().profile.contentPhase = nil

-- Eine gildeneigene Bewertung sticht den ausgelieferten Regelsatz.
addon.DB:GetGuild().enchantRules["2937"] = { verdict = "IMPROVABLE", name = "Eigene Regel", by = "Chef" }
assert(addon.GearAudit:EvaluateEnchant(
    HANDS_SLOT, 2937, "DAMAGER", "Große Zaubermacht", "MAGE:1") == "IMPROVABLE",
    "Die gildeneigene Bewertung wird vom ausgelieferten Regelsatz überstimmt")
addon.DB:GetGuild().enchantRules["2937"] = nil
end

-- === Ausnahmen für Farmgear und Widerstandssets ============================
--
-- Ein ausgenommener Slot bleibt sichtbar, zählt aber nicht als Fund.
do
inspectGear.player = {}
for _, slot in ipairs(addon.GearSlots) do
    if slot.enchantRequired then
        -- Überall ein unverzaubertes Teil: ohne Ausnahme lauter Funde.
        inspectGear.player[slot.id] = "|Hitem:4242:0:0:0:0:0:0:0:70|h[Farmteil]|h"
    end
end
addon.GearAudit:AuditSelf(true, true)
local beforeExemption = addon.GearAudit:GetAudit("Tester")
local missingBefore = beforeExemption.missingEnchants
assert(missingBefore >= 2, "Der Ausnahmetest braucht mehrere fehlende Verzauberungen")

local exemptSet, exemptMessage = addon.GearAudit:SetSlotException("HEAD", "RESIST")
assert(exemptSet == true and exemptMessage:find("Widerstandsset", 1, true),
    "Die Ausnahme für ein Widerstandsteil ließ sich nicht setzen")
local afterExemption = addon.GearAudit:GetAudit("Tester")
assert(afterExemption.missingEnchants == missingBefore - 1,
    "Ein ausgenommener Slot zählt weiter als fehlende Verzauberung")
assert(afterExemption.exemptSlots == 1, "Der ausgenommene Slot wird nicht gezählt")
local headEntry
for _, entry in ipairs(afterExemption.slots) do
    if entry.key == "HEAD" then
        headEntry = entry
    end
end
assert(headEntry and headEntry.verdict == "EXEMPT" and headEntry.exempt == "RESIST",
    "Der ausgenommene Slot wird nicht als Ausnahme ausgewiesen")
assert(headEntry.reason:find("Widerstandsset", 1, true),
    "Die Ausnahme nennt ihren Grund nicht")

-- Die Ausnahme wandert mit dem Snapshot zu den anderen Clients.
local exemptMessages = addon.GearAudit:BuildEquipmentMessages(afterExemption)
assert(#exemptMessages > 0, "Ein Snapshot mit Ausnahme wurde nicht erzeugt")
local exemptPayload = ""
for _, message in ipairs(exemptMessages) do
    exemptPayload = exemptPayload .. message:match("^E|[^|]+|[^|]+|[^|]+|[^|]+|(.*)$")
end
assert(exemptPayload:find("HEAD:RESIST", 1, true),
    "Die Ausnahme wird nicht mit dem Ausrüstungs-Snapshot geteilt")

-- Ein Paket mit unlesbarem Ausnahmefeld wird abgelehnt, nicht halb übernommen.
assert(addon.GearAudit:DecodeEquipmentPayload(exemptPayload .. ",MUELL", "Tester-Realm") == nil,
    "Ein beschädigtes Ausnahmefeld wurde übernommen")

-- Ohne Ausnahmen bleibt das Paket bei fünf Feldern, damit ältere Clients es
-- weiterhin lesen können.
addon.GearAudit:SetSlotException("HEAD", nil)
local plainAudit = addon.GearAudit:GetAudit("Tester")
assert(plainAudit.exemptSlots == 0, "Die Ausnahme wurde nicht aufgehoben")
local plainMessages = addon.GearAudit:BuildEquipmentMessages(plainAudit)
local plainPayload = ""
for _, message in ipairs(plainMessages) do
    plainPayload = plainPayload .. message:match("^E|[^|]+|[^|]+|[^|]+|[^|]+|(.*)$")
end
assert(#addon.Util.SplitFields(plainPayload) == 5,
    "Ohne Ausnahmen wird ein Zusatzfeld gesendet, das ältere Clients verwerfen")
end

print("OK: simulierter Addonstart und Kernablauf erfolgreich.")
