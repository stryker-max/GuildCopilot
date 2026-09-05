-- === Das reduzierte CurseForge-Paket ======================================
--
-- Geprueft wird hier NICHT das Repository, sondern das Staging-Verzeichnis,
-- das tools/curseforge-package.mjs gebaut hat - also genau die Dateien, die
-- spaeter im Archiv liegen. Der Unterschied ist der ganze Punkt: Die
-- vollstaendige Fassung hat WarcraftLogs.lua und den Companion, das Paket
-- nicht.
--
-- Die Frage, die dieser Test beantwortet: Startet das Addon ohne diese Datei
-- fehlerfrei, und bleibt von Warcraft Logs im Spiel wirklich nichts sichtbar
-- oder aufrufbar uebrig? Ein Navigationspunkt, der auf eine Seite zeigt, die
-- es nicht gibt, waere schlimmer als gar keiner.

dofile("tests/wow-stubs.lua")

local STAGE = ... or "build/stage/GuildCopilot"

-- === Startet es ueberhaupt? ===============================================
--
-- LoadAddonFrom liest die TOC des Staging-Verzeichnisses. Nennt sie eine
-- Datei, die dort nicht liegt, scheitert schon das Laden - genau der Fehler,
-- den ein Spieler sonst als erstes saehe.
local addon, files = LoadAddonFrom(STAGE)

for _, file in ipairs(files) do
    assert(file ~= "WarcraftLogs.lua",
        "Die reduzierte TOC laedt weiterhin WarcraftLogs.lua")
end
assert(#files >= 15, "Die reduzierte TOC laedt nur " .. #files .. " Dateien")

addon:FireCallback("ADDON_LOADED")
addon:FireCallback("PLAYER_LOGIN")

-- === Das Modul ist weg, und zwar ganz ====================================
assert(addon.WarcraftLogs == nil,
    "GC.WarcraftLogs existiert in der reduzierten Fassung")

-- === Die Oberflaeche baut sich trotzdem auf ===============================
addon.UI:CreateMainFrame()
addon.UI.frame:Show()
addon.UI:Refresh()

assert(addon.UI.pages.WCL == nil,
    "Die reduzierte Fassung hat trotzdem eine Warcraft-Logs-Seite")
for _, tab in ipairs(addon.UI.tabs) do
    assert(tab.key ~= "WCL",
        "In der Navigation steht weiterhin ein Warcraft-Logs-Punkt")
end

-- Und die uebrigen Punkte sind vollstaendig da: Ein Filter, der zu viel
-- wegnimmt, faellt sonst nicht auf.
do
    local present = {}
    for _, tab in ipairs(addon.UI.tabs) do
        present[tab.key] = true
    end
    for _, key in ipairs({ "ROSTER", "OVERVIEW", "GUILD", "SUGGESTIONS", "RECRUITMENT",
        "POST", "INBOX", "MEMBERCARE", "WORKSHOP", "STATISTICS", "GEAR", "SETTINGS" }) do
        assert(present[key], "Der Navigationspunkt " .. key .. " fehlt in der reduzierten Fassung")
    end
end

-- === Kein Weg fuehrt trotzdem dorthin =====================================
--
-- Ohne den Rueckfall in ShowPage wuerde die Seitenschleife alles verstecken
-- und nichts zeigen: ein leeres Fenster, ohne Fehlermeldung.
addon.UI:ShowPage("WCL")
assert(addon.UI.activePage ~= "WCL",
    "ShowPage hat die nicht vorhandene Warcraft-Logs-Seite aufgeschlagen")
assert(addon.UI.pages[addon.UI.activePage] ~= nil
    and addon.UI.pages[addon.UI.activePage].shown == true,
    "Nach dem Ausweichen ist gar keine Seite sichtbar")

-- Auch die Auffrischungen muessen ins Leere laufen duerfen.
addon.UI:RefreshWarcraftLogs()
addon.UI:Invalidate("WCL", "SUGGESTIONS", "INBOX")
addon.UI:Refresh()

-- Jede Seite einmal aufschlagen: Eine ungeschuetzte GC.WarcraftLogs-Stelle
-- faellt genau hier auf, nicht beim Laden.
for _, tab in ipairs(addon.UI.tabs) do
    addon.UI:ShowPage(tab.key)
end
addon.UI:ShowPage("ROSTER")

-- Das Postfach greift fuer die Profil-Links auf die Gildenquelle zu. Ohne das
-- Modul gibt es keine - die Felder bleiben leer, statt einen Fehler zu werfen.
addon.UI:SetLeadProfileLinks({ name = "Bewerber-Realm" })
addon.UI:SetLeadProfileLinks(nil)

-- === Der Sync bleibt ein Sync =============================================
--
-- Das Schneeballprinzip haengt daran: Ein Client ohne das Modul muss Pakete
-- von einem MIT Modul weiterhin annehmen, weiterreichen und selbst senden.
-- Die Gildenquelle von Warcraft Logs faehrt in der Gildenprofil-Nutzlast mit;
-- sie wird hier durchgereicht, obwohl dieser Client nichts damit anfangen kann.
do
    addon.Roster:ScanNow()
    local profileMessages = addon.Sync:BuildGuildProfileMessages()
    assert(profileMessages ~= nil and #profileMessages > 0,
        "Die reduzierte Fassung sendet kein Gildenprofil mehr")

    -- Ein Paket eines Clients MIT dem Modul: Das WCL-Feld ist besetzt.
    local before = addon.DB:GetGuild().warcraftLogs.url
    for _, message in ipairs(profileMessages) do
        addon.Sync:OnMessage("GuildCopilot", message, "GUILD", "Synkos-Realm")
    end
    assert(addon.DB:GetGuild().warcraftLogs.url == before,
        "Der Empfang hat die gespeicherte Warcraft-Logs-Quelle veraendert")

    -- Und ein reines Warcraft-Logs-Paket ("L|") darf nur ignoriert werden,
    -- nicht in einen Lua-Fehler laufen.
    addon.Sync:OnMessage("GuildCopilot",
        "L|" .. addon.Constants.SCHEMA_VERSION .. "|RQ", "GUILD", "Synkos-Realm")
end

-- === Alte SavedVariables bleiben unangetastet =============================
--
-- Wer vorher die vollstaendige Fassung hatte, hat einen warcraftLogs-Zweig in
-- seiner Datenbank. Er darf still liegen bleiben; ihn zu loeschen waere ein
-- Datenverlust fuer jeden, der spaeter zurueckwechselt.
do
    local guild = addon.DB:GetGuild()
    guild.warcraftLogs.url = "https://de.fresh.warcraftlogs.com/guild/eu/x/y"
    guild.warcraftLogs.importedAt = 1700000000
    addon.UI:Refresh()
    addon.DB:Prune()
    assert(guild.warcraftLogs.url == "https://de.fresh.warcraftlogs.com/guild/eu/x/y",
        "Die reduzierte Fassung hat gespeicherte Warcraft-Logs-Daten geloescht")
    assert(guild.warcraftLogs.importedAt == 1700000000,
        "Die reduzierte Fassung hat den Importzeitpunkt geloescht")
end

-- === Und der Rest arbeitet weiter =========================================
do
    addon.Profile:Confirm("HUNTER:2", nil, "MAIN", true)
    assert(addon.Profile:Get().confirmed == true,
        "Das Raidprofil laesst sich in der reduzierten Fassung nicht bestaetigen")
    assert(addon.Roster:GetMember("Tester-Realm") ~= nil, "Der Gildenroster ist leer")
    assert(#addon.Roster:GetActiveRaiders(50) > 0, "Es werden keine aktiven Raider mehr gelistet")
    assert(addon.Roster:GetMemberCareCandidates() ~= nil,
        "Die Mitgliederpflege liefert keine Vorschlagsliste")
    addon.Inventory:ScanBags()
    assert(addon.Inventory:GetOwnCounts(22446).bags > 0,
        "Der Materialbestand wird nicht mehr gezaehlt")
end

dofile("tests/inbox-cases.lua")(addon)
print("OK: reduzierte CurseForge-Fassung startet und zeigt kein Warcraft Logs.")
