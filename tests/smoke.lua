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
local optionsCategory
function InterfaceOptions_AddCategory(panel)
    optionsCategory = panel
end
chatMessages = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, message)
    chatMessages[#chatMessages + 1] = tostring(message)
end }

function CreateFrame(_, name)
    local frame = setmetatable({ shown = false, scripts = {} }, Dummy)
    if name then
        _G[name] = frame
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

function ExpandTradeSkillSubClass()
end

function GetNumTradeSkills()
    return 3
end

function GetTradeSkillInfo(index)
    if index == 1 then
        return "Taschen", "header"
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
    return #raidRoster > 0
end

function GetNumGroupMembers()
    return #raidRoster
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

function GetInventoryItemLink(unit, slotID)
    return (inspectGear[unit] or {})[slotID]
end

function GetItemStats(link)
    local sockets = tonumber(tostring(link or ""):match("SOCKETS(%d)"))
    if not sockets then
        return {}
    end
    return { EMPTY_SOCKET_RED = sockets }
end

function UnitExists(unit)
    return (inspectGear[unit] ~= nil) or unit == "player"
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

local addon = {}
local files = {
    "Constants.lua",
    "Core.lua",
    "Database.lua",
    "Profile.lua",
    "WarcraftLogs.lua",
    "Roster.lua",
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
local ownWorkshop = addon.Workshop:GetOwnData()
assert(ownWorkshop.professions.schneiderei ~= nil, "Beruf wurde nicht in der Werkstatt gespeichert")
assert(ownWorkshop.professions.schneiderei.recipes.I14155 ~= nil, "Rezept wurde nicht gespeichert")
assert(#ownWorkshop.professions.schneiderei.recipes.I14155.reagents == 2, "Reagenzien wurden nicht gespeichert")
local workshopMessages = addon.Workshop:BuildProfessionMessages(ownWorkshop.professions.schneiderei)
assert(#workshopMessages > 0, "Werkstatt-Synchronisierung wurde nicht erzeugt")
for _, workshopMessage in ipairs(workshopMessages) do
    assert(#workshopMessage <= 255, "Werkstatt-Nachricht überschreitet das Addon-Limit")
    addon.Workshop:ReceiveSync(addon.Util.SplitFields(workshopMessage), "Crafter-Realm")
end
assert(addon.DB:GetGuild().workshop.crafters["crafter-realm"] ~= nil, "Remote-Crafter wurde nicht gespeichert")
addonSendFailures = 1
local sentBeforeRetry = #sentAddon
addon.Workshop:QueueProfessionSync(ownWorkshop.professions.schneiderei)
assert(#sentAddon > sentBeforeRetry, "Werkstattpaket wurde nach einem Sendefehler nicht wiederholt")
assert(#addon.Workshop.syncQueue == 0, "Werkstatt-Warteschlange wurde nach erfolgreicher Wiederholung nicht geleert")
assert(addon.Workshop.syncStats.failed == 0, "Ein einmalig fehlgeschlagenes Paket wurde endgültig verworfen")
local workshopCatalog = addon.Workshop:GetCatalog("Mondstoff")
assert(#workshopCatalog >= 1, "Werkstattsuche findet das Rezept nicht")
assert(#workshopCatalog[1].crafters == 2, "Lokaler und synchronisierter Crafter wurden nicht zusammengeführt")
local tailoringCatalog = addon.Workshop:GetCatalog("", "Schneiderei")
assert(#tailoringCatalog >= 1, "Berufsfilter findet Schneiderei nicht")
assert(#addon.Workshop:GetCatalog("", "Verzauberkunst") == 0, "Berufsfilter zeigt den falschen Beruf")

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

addon.Profile:Confirm("HUNTER:2", "HUNTER:3", "MAIN", true)
assert(addon.Profile:Get().secondarySpecKey == "HUNTER:3", "Dual-Spec wurde nicht gespeichert")
assert(addon.Sync:BuildProfileMessage():find("HUNTER:3", 1, true), "Dual-Spec fehlt in der Gildensynchronisierung")
assert(addon.Sync:BuildProfileMessage():find("Ingenieurskunst", 1, true), "Beruf fehlt in der Gildensynchronisierung")

local sourceSaved = addon.WarcraftLogs:SaveSource("https://de.fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath")
assert(sourceSaved == true, "Warcraft-Logs-Link wurde nicht erkannt")
local imported = addon.WarcraftLogs:Import(
    "GCPWCL1|2\n"
    .. "Heiler-Realm;PRIEST;PRIEST:2;PRIEST:3\n"
    .. "Krieger-Realm;WARRIOR;WARRIOR:2;\n"
)
assert(imported == true, "Warcraft-Logs-Import ist fehlgeschlagen")
assert(addon.WarcraftLogs:GetImportedCount() == 2, "Importierte WCL-Spielerzahl ist falsch")
assert(addon.Roster:GetProfile("Heiler-Realm").secondarySpecKey == "PRIEST:3", "Importierter Dual-Spec fehlt")
local manuallyImported = addon.WarcraftLogs:Import(
    "Nexarius;Magier;Arkan;Frost\n"
    .. "Druide-Realm;Druide;Wiederherstellung;\n"
)
assert(manuallyImported == true, "Manueller Import ohne API ist fehlgeschlagen")
assert(addon.WarcraftLogs:GetImportedCount() == 2, "Manuelle Profilanzahl ist falsch")
assert(addon.Roster:GetProfile("Nexarius").secondarySpecKey == "MAGE:3", "Manueller Dual-Spec wurde nicht erkannt")
assert(addon.Roster:GetProfile("Druide-Realm").raidSpecKey == "DRUID:3", "Deutscher Specname wurde nicht erkannt")

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
local guildProfileMessages = addon.Sync:BuildGuildProfileMessages()
assert(#guildProfileMessages > 0, "Gildenprofil-Synchronisierung wurde nicht erzeugt")
for _, guildProfileMessage in ipairs(guildProfileMessages) do
    assert(#guildProfileMessage <= 255, "Gildenprofil-Nachricht überschreitet das Addon-Limit")
end
addon.DB:GetSettings().successSoundKey = "GROUP_FINDER"
assert(addon.Chat:PlaySuccessSound() == true, "Ausgewählter Erfolgssound konnte nicht abgespielt werden")
assert(playedSoundID == 3081, "Gruppensuche-Sound verwendet keinen TBC-kompatiblen Fallback")

addon.Chat:CaptureLead("Suche Gilde für TBC-Raids", "Interessent-Realm", "Player-4", "SucheNachGruppe")
assert(#addon.DB:GetGuild().inbox == 2, "Chat-Trigger wurde nicht im Postfach gespeichert")
addon.Chat:CaptureLead("Noch eine Nachricht", "Interessent", nil, "Handel")
assert(#addon.DB:GetGuild().inbox == 2, "Spieler mit und ohne Realmnamen wurde doppelt angelegt")
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
assert(announcement:find("0.7.0", 1, true), "Die Addon-Version fehlt im Handshake")
assert(announcement:find("workshop", 1, true), "Die Fähigkeiten fehlen im Handshake")
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
assert(#sentAddon == sentBeforeRequest + 1, "Auf eine Handshake-Anfrage wurde nicht geantwortet")
assert(LastAddonMessage():sub(-2) == "|0",
    "Die Handshake-Antwort fordert selbst wieder eine Antwort an")

-- Auf eine Antwort darf nie geantwortet werden, sonst schaukelt sich der
-- Handshake zwischen allen Gildenmitgliedern auf.
currentTime = currentTime + 60
local sentBeforeReply = #sentAddon
addon.Sync:OnMessage("GuildCopilot", "V|7|0.4.6|profile|0", "GUILD", "Heiler-Realm")
assert(#sentAddon == sentBeforeReply, "Auf eine Handshake-Antwort wurde erneut geantwortet")

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

inspectGear.player = { [1] = ENCHANTED_HEAD, [5] = SOCKETED_CHEST }
local selfAudited, selfMessage = addon.GearAudit:AuditSelf()
assert(selfAudited == true, "Die eigene Ausrüstung wurde nicht geprüft")
local ownAudit = addon.GearAudit:GetAudit("Tester")
assert(ownAudit ~= nil, "Die eigene Prüfung wurde nicht gespeichert")
assert(ownAudit.source == "SELF", "Die eigene Prüfung ist nicht als solche gekennzeichnet")
assert(ownAudit.missingEnchants == 1, "Die fehlende Verzauberung auf der Brust wurde nicht erkannt")
assert(ownAudit.emptySockets == 2, "Die leeren Sockel fehlen in der Zusammenfassung")
assert(ownAudit.unknownEnchants == 1, "Die unbewertete Verzauberung wurde nicht als unbekannt geführt")
assert(ownAudit.emptySlots == 7, "Leere Pflichtslots wurden falsch gezählt")
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
assert(headEntry.verdict == "UNKNOWN", "Eine unbewertete Verzauberung wurde nicht als unbekannt gemeldet")
assert(chestEntry.verdict == "MISSING", "Die fehlende Verzauberung wurde nicht gemeldet")
assert(neckEntry.verdict == "EMPTY", "Ein leerer Slot wurde nicht als leer gemeldet")

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
for _, finding in ipairs(ownFindings) do
    assert(finding.severity ~= "INFO" or not finding.text:find("nicht bewertet", 1, true),
        "Bei leerer Regelliste wird über unbewertete Verzauberungen berichtet")
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

-- Die Prüfung erscheint in der Oberfläche, sortiert nach Anzahl der Funde.
addon.UI:ShowPage("GEAR")
local gearPage = addon.UI.pages.GEAR
assert(gearPage.gearRows[1].shown == true, "Der geprüfte Spieler fehlt in der Liste")
assert(gearPage.gearRows[3].shown == false, "Es werden mehr Spieler angezeigt als geprüft")
assert(gearPage.gearSlotRows[1].shown == true, "Die Slot-Tabelle ist leer")
addon.GearAudit.selectedName = "Tester"
addon.UI:RefreshGear()
assert(gearPage.gearSlotRows[1].slot.value == "Kopf", "Die Slot-Tabelle zeigt den falschen Slot")
assert(gearPage.gearSlotRows[1].verdict.value == "Unbekannt",
    "Die Bewertung wird nicht angezeigt")

GuildCopilotDB.settings.editorRecoveryAvailable = false
GuildCopilotDB.guilds["Altgilde@Realm"] = {}
addon.DB:Initialize()
assert(GuildCopilotDB.guilds["Altgilde@Realm"].editorRecoveryAvailable == false,
    "Bereits verbrauchte Wiederherstellung wurde bei der Migration nicht übernommen")
assert(GuildCopilotDB.settings.editorRecoveryAvailable == nil,
    "Das alte kontoweite Wiederherstellungsfeld wurde nicht entfernt")
assert(addon.DB:GetGuild().editorRecoveryAvailable == false,
    "Die eigene Gilde hat ihre verbrauchte Wiederherstellung verloren")

print("OK: simulierter Addonstart und Kernablauf erfolgreich.")
