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
DEFAULT_CHAT_FRAME = { AddMessage = function()
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

function UnitName()
    return "Tester"
end

function UnitClass()
    return "Jäger", "HUNTER", 3
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

function GetChannelList()
    return 1, "Allgemein", false, 2, "Handel", false, 4, "SucheNachGruppe", false, 5, "Gildenrekrutierung", false
end

local playedSoundID
function PlaySound(soundID)
    playedSoundID = soundID
end

function time()
    return 1000
end

function date()
    return "2026-07-27"
end

C_Timer = {
    After = function(_, callback)
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
    SendAddonMessage = function(prefix, message, distribution)
        if addonSendFailures > 0 then
            addonSendFailures = addonSendFailures - 1
            return false
        end
        sentAddon[#sentAddon + 1] = { prefix, message, distribution }
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
local healerMember = addon.Roster:GetMember("Heiler-Realm")
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
