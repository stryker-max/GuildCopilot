-- Dieselben Postfachregressionen laufen im Entwicklungs- und CurseForge-Addon.
return function(addon)
    local guild, settings, page = addon.DB:GetGuild(), addon.DB:GetSettings(), addon.UI.pages.INBOX
    local savedInbox, savedFilters = guild.inbox, settings.inboxFilters
    local savedDrafts, savedKey = page.replyDrafts, addon.UI.selectedLeadKey
    local savedTime, savedGUID = currentTime, GetPlayerInfoByGUID
    local savedRealm, savedNormalized, savedRegion = GetRealmName, GetNormalizedRealmName, GetCurrentRegion
    guild.inbox, settings.inboxFilters, page.replyDrafts = {}, {}, {}
    addon.UI.selectedLeadKey, page.replyDraftKey = nil, nil

    local levels = {
        { "Level 20 Magier sucht Gilde", 20 }, { "20 Magier sucht Gilde", 20 },
        { "Magier 20 sucht Gilde", 20 }, { "lvl: 69 Magier", 69 },
        { "70er JÄGER sucht Gilde", 70 }, { "Stufe 1 Schurke", 1 },
        { "level 700 Magier" }, { "170er Magier" }, { "Itemlevel 70" },
        { "Magier sucht Gilde mit 70 Mitgliedern" }, { "Magier hat 70 Parses" },
        { "Magier sucht Gilde ab 18 Uhr" }, { "Level 20, auf 70 wird geraidet", 20 },
        { "Level 20 oder Level 70" }, { "Suche Gilde https://example.org/70" },
        { "Suche Gilde |cffaabbcc|Hitem:70|h[Magier 70]|h|r" },
    }
    for _, case in ipairs(levels) do
        assert(addon.Chat:ReadLevelFromText(case[1]) == case[2], "Falsche Stufe: " .. case[1])
    end
    for class, aliases in pairs(addon.LeadClassAliases) do
        for _, alias in ipairs(aliases) do
            assert(addon.Chat:ReadClassFromText(alias .. " sucht Gilde") == class,
                "Klassenkuerzel nicht erkannt: " .. alias)
        end
    end
    assert(addon.Chat:ReadClassFromText("JÄGER sucht Gilde") == "HUNTER", "Grosses Umlautwort fehlt")
    assert(addon.Chat:ReadClassFromText("Magier und Priester suchen Gilde") == nil, "Mehrere Klassen geraten")
    assert(addon.Chat:ReadClassFromText("Suche Gilde, öle meine Waffe") == nil, "UTF-8-Wortgrenze falsch")

    -- Ein spaeter gefuellter GUID-Cache ersetzt die fruehere Textvermutung.
    GetPlayerInfoByGUID = function() return nil end
    local savedSendLead, sentDetails = addon.Chat.SendLead, 0
    addon.Chat.SendLead = function() sentDetails = sentDetails + 1 end
    addon.Chat:CaptureLead("Level 20 Magier sucht Gilde", "Pruefling-Realm", "Player-InboxTest", "WHISPER")
    local lead = guild.inbox[1]
    assert(lead.level == 20 and lead.classFile == "MAGE", "Ersterfassung falsch")
    GetPlayerInfoByGUID = function() return "Priester", "PRIEST" end
    settings.inboxFilters = { classFile = "PRIEST" }
    addon.UI:RefreshInbox()
    assert(#page.visibleLeads == 1 and lead.classFile == "PRIEST", "GUID wird erst nach dem Filter aufgeloest")
    currentTime = currentTime + 10
    addon.Chat:CaptureLead("Jetzt Level 70, Magier gesucht", lead.name, lead.guid, "WHISPER")
    assert(lead.level == 70 and lead.classFile == "PRIEST", "Neue Stufe fehlt oder GUID-Klasse ueberschrieben")
    assert(sentDetails == 2, "Die neue Stufe wird nicht an die Gilde verteilt")
    addon.Chat:CaptureLead("Jetzt Level 70, Magier gesucht", lead.name, lead.guid, "WHISPER")
    assert(sentDetails == 2, "Unveraenderte Wiederholung erzeugt neuen Sync")
    addon.Chat.SendLead = savedSendLead
    local syncMessages = addon.Chat:BuildInboxMessages(lead)
    local original = lead.messages[1].text
    guild.inbox = {}
    for _, packet in ipairs(syncMessages) do addon.Chat:ReceiveSync(packet, "Synkos-Realm", "GUILD") end
    assert(#guild.inbox == 1 and guild.inbox[1].level == 70, "Sync behaelt die alte Stufe 20")
    assert(guild.inbox[1].messages[1].text == original, "Sync veraendert die Ursprungsbewerbung")
    currentTime = currentTime + 10
    addon.Chat:CaptureLead("Korrektur: Level 60", lead.name, lead.guid, "WHISPER")
    for _, packet in ipairs(syncMessages) do addon.Chat:ReceiveSync(packet, "Synkos-Realm", "GUILD") end
    assert(guild.inbox[1].level == 60, "Alte Sync-Kopie ueberschreibt neuere Angabe")
    guild.inbox = {}
    GetPlayerInfoByGUID = function() return nil end
    addon.Chat:CaptureLead("Level 20 Magier", "Klassenprobe-Realm", nil, "WHISPER")
    local firstClass = addon.Chat:BuildInboxMessages(guild.inbox[1])
    currentTime = currentTime + 10
    addon.Chat:CaptureLead("Korrektur: Level 20 Schurke", "Klassenprobe-Realm", nil, "WHISPER")
    local newClass = addon.Chat:BuildInboxMessages(guild.inbox[1])
    guild.inbox = {}
    for _, packet in ipairs(firstClass) do addon.Chat:ReceiveSync(packet, "Synkos-Realm", "GUILD") end
    for _, packet in ipairs(newClass) do addon.Chat:ReceiveSync(packet, "Synkos-Realm", "GUILD") end
    assert(guild.inbox[1].classFile == "ROGUE", "Sync behaelt die alte Klassenvermutung")
    for _, packet in ipairs(firstClass) do addon.Chat:ReceiveSync(packet, "Synkos-Realm", "GUILD") end
    assert(guild.inbox[1].classFile == "ROGUE", "Alte Sync-Kopie setzt neue Klasse zurueck")
    GetPlayerInfoByGUID = savedGUID

    -- Filtergrenzen, unbekannte Daten, Kombinationen und richtige Detailauswahl.
    guild.inbox = {}
    settings.inboxFilters = {}
    for index, level in ipairs({ 20, 49, 50, 59, 60, 69, 70, 0 }) do
        guild.inbox[index] = { name = "Filterprobe" .. index .. "-Realm", detailsVersion = 1,
            classFile = index % 2 == 1 and "MAGE" or "PRIEST", level = level > 0 and level or nil,
            messages = { { text = "Hallo", receivedAt = index } } }
    end
    guild.inbox[9] = { name = "Unbekanntprobe-Realm", detailsVersion = 1, messages = {} }
    for _, case in ipairs({ { 0, 9 }, { 50, 5 }, { 60, 3 }, { 70, 1 } }) do
        settings.inboxFilters = { minLevel = case[1] }
        addon.UI:RefreshInbox()
        assert(#page.visibleLeads == case[2], "Falsche Trefferanzahl ab " .. case[1])
        local selected = addon.UI:GetSelectedLead()
        assert(selected and addon.UI:LeadMatchesInboxFilter(selected), "Ausgefilterte Detailauswahl")
    end
    settings.inboxFilters = {}
    addon.UI:SelectLead(1)
    page.replyEdit:SetText("Nur fuer Lowlevel")
    settings.inboxFilters = { classFile = "MAGE", minLevel = 70 }
    addon.UI:RefreshInbox()
    assert(#page.visibleLeads == 1 and addon.UI:GetSelectedLead() == guild.inbox[7], "Kombinierter Filter falsch")
    assert(page.replyEdit:GetText() == "", "Entwurf wandert zum gefilterten Nachfolger")
    page.replyEdit:SetText("Nur fuer Level 70")
    settings.inboxFilters.classFile = "ROGUE"
    addon.UI:RefreshInbox()
    assert(addon.UI:GetSelectedLead() == nil and #page.visibleLeads == 0, "Leerer Filter zeigt trotzdem Charakter")
    assert(page.replyButton.disabled and page.inviteButton.disabled, "Leerer Filter erlaubt Antworten/Einladen")
    assert(page.leadLinkEdits.armory:GetText() == "", "Leerer Filter zeigt fremden Armory-Link")
    settings.inboxFilters = {}
    addon.UI:SelectLead(1)
    assert(page.replyEdit:GetText() == "Nur fuer Lowlevel", "Lowlevel-Entwurf verloren")
    addon.UI:SelectLead(7)
    assert(page.replyEdit:GetText() == "Nur fuer Level 70", "70er-Entwurf verloren")
    assert(#guild.inbox == 9, "Filtern loescht Bewerber")
    settings.inboxFilters = { classFile = "INVALID", minLevel = 42 }
    addon.UI:RefreshInbox()
    assert(#page.visibleLeads == 9 and addon.UI:GetInboxFilters().minLevel == 0,
        "Ungueltige gespeicherte Filter verstecken Eintraege hinter Alle Stufen")
    local savedInvite = addon.Chat.Invite
    addon.Chat.Invite = function() return false end
    page.inviteButton.scripts.OnClick()
    assert(page.replyResult:GetText() == addon.L("Einladung konnte nicht ausgelöst werden."),
        "Fehlgeschlagene Einladung wird als Erfolg angezeigt")
    addon.Chat.Invite = savedInvite
    -- Aenderung vor dem naechsten Refresh: kein Versand an den Nachfolger.
    settings.inboxFilters = {}
    addon.UI:SelectLead(1)
    page.replyEdit:SetText("Darf nicht an den Nachfolger gehen")
    local savedSendReply, replyCalls = addon.Chat.SendReply, 0
    addon.Chat.SendReply = function() replyCalls = replyCalls + 1; return true end
    settings.inboxFilters = { minLevel = 70 }
    page.replyButton.scripts.OnClick()
    assert(replyCalls == 0, "Geaenderte Auswahl verschickt den alten Entwurf an den Nachfolger")
    addon.Chat.SendReply = savedSendReply
    -- Neue Bewerbung verschiebt echte Indizes vor dem Neuzeichnen der Liste.
    settings.inboxFilters = {}
    page.leadPage = 1
    addon.UI:RefreshInbox()
    local displayed = guild.inbox[addon.UI:GetLeadIndexForSlot(1)]
    local arriving = { name = "NeuVorKlick-Realm", messages = {}, detailsVersion = 1 }
    table.insert(guild.inbox, 1, arriving)
    page.leadDeleteButtons[1].scripts.OnClick()
    for _, candidate in ipairs(guild.inbox) do assert(candidate ~= displayed, "Klick loescht falsche Listenposition") end
    assert(guild.inbox[1] == arriving, "Neue Bewerbung wurde statt der angezeigten geloescht")

    -- Ein gespeicherter Fehlbefund aus dem alten Zahlenscanner wird repariert.
    guild.inbox = { { name = "Altprobe-Realm", level = 70,
        messages = { { text = "Magier sucht Gilde mit 70 Mitgliedern", receivedAt = currentTime } } } }
    settings.inboxFilters = { minLevel = 70 }
    addon.UI:RefreshInbox()
    assert(#page.visibleLeads == 0 and guild.inbox[1].level == nil, "Alte geratene Stufe bleibt aktiv")

    -- Namen muessen nach URL-Dekodierung bytegleich bleiben (auch Nicht-Latein).
    GetCurrentRegion = function() return 3 end
    GetRealmName = function() return "Pyrewood Village" end
    GetNormalizedRealmName = function() return "PyrewoodVillage" end
    for _, name in ipairs({ "Frostäxte", "Ümbrä", "Ölfaß", "Navî", "Pæchh", "Жрец", "A%2FB" }) do
        local links = addon.Chat:BuildLeadProfileLinks(name)
        for _, link in pairs(links) do
            local encoded = link:match("/([^/]+)$")
            local decoded = encoded:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
            assert(decoded == name, "URL veraendert den Namen: " .. name)
            assert(link:find("/eu/", 1, true) and link:find("/pyrewood-village/", 1, true), "Realm/Region falsch")
        end
        if addon.WarcraftLogs then
            assert(addon.WarcraftLogs:BuildCharacterLinks(name .. "-Thunderstrike").logs
                :find(addon.Util.EncodeURLPath(name), 1, true), "Importmodul verliert Sonderzeichen")
        end
    end
    local foreign = addon.Chat:BuildLeadProfileLinks("Ümbrä-Thunderstrike")
    assert(foreign.logs == "https://de.fresh.warcraftlogs.com/character/eu/thunderstrike/%C3%9Cmbr%C3%A4",
        "Fremdrealm-Link falsch: " .. foreign.logs)
    addon.UI:SetLeadProfileLinks({ name = "Frostäxte-Thunderstrike" })
    page.leadLinkEdits.armory:SetFocus()
    addon.UI:SetLeadProfileLinks({ name = "Ümbrä-Thunderstrike" })
    assert(page.leadLinkEdits.armory:GetText() == foreign.armory, "Fokussiertes Linkfeld behaelt vorigen Charakter")

    guild.inbox, settings.inboxFilters = savedInbox, savedFilters
    page.replyDrafts, addon.UI.selectedLeadKey = savedDrafts, savedKey
    currentTime, GetPlayerInfoByGUID = savedTime, savedGUID
    GetRealmName, GetNormalizedRealmName, GetCurrentRegion = savedRealm, savedNormalized, savedRegion
    addon.UI:LoadLeadDraft()
    addon.UI:RefreshInbox()
    print("OK: Postfachfilter, Auswahl, Entwuerfe, Klassen, Stufen-Sync und UTF-8-Links.")
end
