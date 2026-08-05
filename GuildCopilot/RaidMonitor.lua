local _, GC = ...

GC.RaidMonitor = {
    session = nil,
    incoming = {},
    lastAnswerAt = 0,
    selectedSessionID = nil,
    combatLogTracking = false,
}

-- Ein Abend kann bis zu drei Quellen belegen (Live, Warcraft Logs, Logdatei);
-- mit 12 Plätzen waren das nur vier Abende. 24 hält acht volle Abende.
local MAX_STORED_SESSIONS = 24
local MIN_SEGMENT_SECONDS = 15
local WIPE_RATIO = 0.5
local MAX_PAYLOAD_BYTES = 165
local MIN_ANSWER_INTERVAL = 30
local INCOMING_TTL = 5 * 60

-- Wie lange eine unterbrochene Sitzung fortgesetzt werden darf. Danach ist sie
-- kein laufender Abend mehr, sondern ein liegengebliebener - sie wird beim
-- naechsten Login ausgewertet und abgelegt, nicht weggeworfen.
local MAX_RESUME_AGE = 8 * 60 * 60

-- Der Herzschlag haelt die Sitzung im Raid zusammen: Nachzuegler und
-- Wiedereinsteiger erfahren davon, ohne dass jemand etwas anstossen muss.
-- Gesendet wird hoechstens alle SESSION_HEARTBEAT_INTERVAL Sekunden und immer
-- nur von einem: Wer einen fremden Herzschlag hoert, schweigt bis zum
-- naechsten Takt. Die Pruefung selbst laeuft im SESSION_HEARTBEAT_CHECK-Takt
-- und kostet einen Vergleich.
local SESSION_HEARTBEAT_INTERVAL = 60
local SESSION_HEARTBEAT_CHECK = 20

-- Der Rahmen, dessen OnUpdate den Herzschlag antreibt - dieselbe Bauweise wie
-- die Bulk-Warteschlange in Sync.lua: Ein verstecktes Frame bekommt kein
-- OnUpdate, ausserhalb einer Sitzung kostet der Herzschlag damit keinen
-- einzigen Handleraufruf pro Bild. Verdrahtet wird das Skript unten bei den
-- uebrigen Ereignisrahmen.
local heartbeatFrame = CreateFrame("Frame")
heartbeatFrame:Hide()
local heartbeatElapsed = 0

-- COMBAT_LOG_EVENT_UNFILTERED ist das haeufigste Ereignis im Spiel; im Raid
-- feuert es tausende Male pro Sekunde. Schon die Zustellung an einen Handler,
-- der sofort wieder aussteigt, kostet bei jedem einzelnen Ereignis Zeit.
-- Abonniert wird es deshalb nur, solange eine Sitzung wirklich mitschreibt.
-- Die uebrigen Ereignisse sind selten und bleiben dauerhaft registriert.
local raidEvents = CreateFrame("Frame")
raidEvents:RegisterEvent("GROUP_ROSTER_UPDATE")
raidEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
raidEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
-- pcall, weil ein Client-Build ohne diese Ereignisse beim Registrieren
-- unbekannter Namen einen Fehler wirft - dann bleibt es bei der Heuristik.
pcall(raidEvents.RegisterEvent, raidEvents, "ENCOUNTER_START")
pcall(raidEvents.RegisterEvent, raidEvents, "ENCOUNTER_END")

function GC.RaidMonitor:SetCombatLogTracking(enabled)
    enabled = enabled and true or false
    if self.combatLogTracking == enabled then
        return
    end
    self.combatLogTracking = enabled
    if enabled then
        raidEvents:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        raidEvents:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

local function SanitizedText(value, maximumBytes)
    value = GC.Util.Trim(value)
    value = value:gsub("[,;|]", " ")
    return GC.Util.SafeChatText(value, maximumBytes or 40)
end

local function NewCounters()
    local counters = {}
    for _, category in ipairs(GC.ConsumableCategories) do
        counters[category.key] = 0
    end
    return counters
end

-- Haelt alle laufenden Anwesenheitsuhren an und schreibt die bis dahin
-- gesammelte Zeit gut. Ohne Zeitpunkt wird nur angehalten - dann ist gar nicht
-- bekannt, bis wann jemand da war, und geschaetzte Zeit waere schlechter als
-- keine.
local function ClosePresence(session, at)
    for _, participant in pairs(session.participants) do
        if participant.presentSince then
            if at then
                participant.seconds = participant.seconds + math.max(0, at - participant.presentSince)
            end
            participant.presentSince = nil
        end
    end
end

function GC.RaidMonitor:IsInRaidGroup()
    return IsInRaid and IsInRaid() == true
end

function GC.RaidMonitor:IsInAnyGroup()
    if self:IsInRaidGroup() then
        return true
    end
    return IsInGroup and IsInGroup() == true
end

-- 2 = Raidleiter, 1 = Assistent, 0 = Mitglied, nil = nicht in der Gruppe.
function GC.RaidMonitor:GetRaidRank(playerName)
    if not self:IsInRaidGroup() or not GetNumGroupMembers or not GetRaidRosterInfo then
        return nil
    end
    local wanted = GC.Util.NormalizeName(GC.Util.PlayerShortName(playerName or GC:GetPlayerFullName()))
    for index = 1, (GetNumGroupMembers() or 0) do
        local name, rank = GetRaidRosterInfo(index)
        if name and GC.Util.NormalizeName(GC.Util.PlayerShortName(name)) == wanted then
            return tonumber(rank) or 0
        end
    end
    return nil
end

-- Eine Sitzung starten, beenden und einstellen darf nur ein Offizier: die
-- Gildenränge mit Zugriff auf die Mitgliederpflege (Vorgabe Rang 0 und 1, in
-- den Einstellungen änderbar und gildenweit abgeglichen).
--
-- Bis 0.9.82 genügte zusätzlich der Raidrang. Das war zu weit gefasst: Ein
-- Assistent ist im Pull-Chaos schnell ernannt, und ein versehentliches
-- „Sitzung beenden" schneidet den Abend mittendrin ab. Dieselbe Prüfung
-- entscheidet auch über eingehende Sitzungspakete – dort ist der Gildenrang
-- ohnehin die belastbarere Angabe, weil der Raidrang eines Fremden gar nicht
-- feststeht.
function GC.RaidMonitor:CanControlSession(playerName)
    return GC.Roster:CanAccessMemberCare(playerName or GC:GetPlayerFullName())
end

function GC.RaidMonitor:GetParticipant(session, name, classFile)
    if not session or not name or name == "" then
        return nil
    end
    local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    if key == "" then
        return nil
    end
    local participant = session.participants[key]
    if not participant then
        participant = {
            name = GC.Util.PlayerShortName(name),
            classFile = classFile,
            seconds = 0,
            presentSince = nil,
            deaths = 0,
            resurrects = 0,
            interrupts = 0,
            dispels = 0,
            consumables = NewCounters(),
        }
        session.participants[key] = participant
        session.participantOrder[#session.participantOrder + 1] = key
        -- Ein neuer Teilnehmer macht gemerkte Fehltreffer ungueltig: Wer bis
        -- eben unbekannt war, koennte jetzt genau dieser Neue sein.
        session.nameLookup = nil
    end
    if classFile and not participant.classFile then
        participant.classFile = classFile
    end
    return participant
end

-- Der Combat Log nennt Namen roh ("Schurke" oder "Schurke-Realm"), die
-- Teilnehmer sind normalisiert abgelegt. Statt bei jedem der vielen tausend
-- Kampfereignisse zwei Stringfunktionen zu durchlaufen, merkt sich die Sitzung
-- das Ergebnis je roher Schreibweise - Fehltreffer (NPCs, Fremde) als false,
-- denn gerade sie sind der haeufigste Fall.
function GC.RaidMonitor:FindParticipant(session, name)
    if not session or not name then
        return nil
    end
    local lookup = session.nameLookup
    if lookup then
        local cached = lookup[name]
        if cached ~= nil then
            return cached or nil
        end
    end
    local participant = session.participants[GC.Util.NormalizeName(GC.Util.PlayerShortName(name))]
    lookup = lookup or {}
    session.nameLookup = lookup
    lookup[name] = participant or false
    return participant
end

function GC.RaidMonitor:SyncParticipants()
    local session = self.session
    if not session then
        return
    end

    local now = GC.Util.Now()
    local present = {}

    -- Die Einheit wird mitgereicht, weil daran haengt, was jemand beim
    -- Eintreten schon an Fläschchen, Elixieren und Essen traegt. Das laesst
    -- sich nur am lebenden Spieler ablesen, nicht im Kampfprotokoll.
    local function MarkPresent(name, classFile, unit)
        local participant = name and self:GetParticipant(session, name, classFile)
        if not participant then
            return
        end
        -- Wer die Verbindung verloren hat, bleibt Teilnehmer der Sitzung -
        -- aber seine Anwesenheitsuhr steht. Vorher zaehlte die blosse
        -- Raidmitgliedschaft: Wer nach zwanzig Minuten rausflog und nicht
        -- wiederkam, stand am Ende mit der vollen Abenddauer da, solange ihn
        -- niemand aus dem Raid nahm. Beim Wiedereinloggen laeuft die Uhr
        -- einfach weiter; die bis dahin gesammelte Zeit bleibt erhalten.
        if unit and UnitIsConnected and UnitIsConnected(unit) == false then
            return
        end
        present[participant] = true
        participant.presentSince = participant.presentSince or now
        self:ScanCarriedConsumables(unit, participant)
    end

    -- Wer die Sitzung mitschreibt, ist immer dabei. Ohne diese Zeile bliebe
    -- eine Sitzung ausserhalb eines Raids ganz ohne Teilnehmer.
    local _, ownClassFile = UnitClass("player")
    MarkPresent(GC:GetPlayerFullName(), ownClassFile, "player")

    if self:IsInRaidGroup() and GetNumGroupMembers and GetRaidRosterInfo then
        for index = 1, (GetNumGroupMembers() or 0) do
            local name, _, _, _, _, classFile = GetRaidRosterInfo(index)
            MarkPresent(name, classFile, "raid" .. index)
        end
    elseif self:IsInAnyGroup() and GetNumGroupMembers then
        -- In einer Gruppe gibt es kein Raidroster; dort zaehlen die
        -- party-Einheiten. GetNumGroupMembers zaehlt den Spieler mit.
        for index = 1, math.max(0, (GetNumGroupMembers() or 0) - 1) do
            local unit = "party" .. index
            if UnitExists and UnitExists(unit) then
                local _, classFile = UnitClass(unit)
                MarkPresent(UnitName(unit), classFile, unit)
            end
        end
    end

    for _, participant in pairs(session.participants) do
        if not present[participant] and participant.presentSince then
            participant.seconds = participant.seconds + (now - participant.presentSince)
            participant.presentSince = nil
        end
    end
end

function GC.RaidMonitor:StartSession(sessionID, startedBy, startedAt, zone)
    self.session = {
        id = sessionID,
        startedBy = GC.Util.PlayerShortName(startedBy or ""),
        startedAt = tonumber(startedAt) or GC.Util.Now(),
        zone = SanitizedText(zone or (GetRealZoneText and GetRealZoneText()) or ""),
        participants = {},
        participantOrder = {},
        pulls = {},
        segment = nil,
    }
    self:SetCombatLogTracking(true)
    self:SyncParticipants()
    self:BeginSessionUpkeep()
    GC:FireCallback("RAID_SESSION_UPDATED")
    return self.session
end

-- === Zwei Sitzungen zur selben Zeit ========================================
--
-- Druecken zwei Offiziere gleichzeitig auf "Sitzung starten", entstehen zwei
-- Sitzungen mit zwei Kennungen. Bis 0.9.86 behielt jeder seine eigene und
-- verwarf die fremde stillschweigend: Der Abend wurde zweimal mitgeschrieben,
-- landete in zwei Auswertungen mit je einem Teil der Teilnehmer, und die
-- unterlegene Sitzung lief weiter, bis ihr Starter sie von Hand beendete - ein
-- "Sitzung beenden" schloss immer nur eine der beiden.
--
-- Aufgeloest wird das ohne Rueckfrage und ohne Wortmeldung, ueber eine Regel,
-- die auf JEDEM Client dasselbe Ergebnis liefert: Die frueher gestartete
-- Sitzung gewinnt, bei gleicher Sekunde die kleinere Kennung. Die Startzeit
-- kommt aus der Serverzeit und ist damit fuer alle auf dem Realm dieselbe; die
-- Kennung traegt einen Zufallsanteil und entscheidet den Gleichstand eindeutig.
function GC.RaidMonitor:IsPreferredSession(candidateAt, candidateID, currentAt, currentID)
    candidateAt = tonumber(candidateAt)
    if not candidateAt or type(candidateID) ~= "string" or candidateID == "" then
        return false
    end
    currentAt = tonumber(currentAt) or 0
    if candidateAt ~= currentAt then
        return candidateAt < currentAt
    end
    return candidateID < tostring(currentID or "")
end

-- Wie lange nach dem eigenen Start eine fremde Sitzung die eigene noch
-- verdraengen darf. Danach steckt in der eigenen ein mitgeschriebener Abend,
-- und der wiegt schwerer als eine aufgeraeumte Kennung: Dann laufen lieber zwei
-- Auswertungen nebeneinander, als dass eine stillschweigend geloescht wird.
local SESSION_MERGE_GRACE = 120

-- Die laufende Sitzung wegwerfen, ohne sie auszuwerten. Ausdruecklich NICHT
-- FinishSession: Es gibt hier nichts abzulegen - die Sitzung ist Sekunden alt
-- und war von Anfang an dieselbe wie die, die jetzt uebernommen wird.
function GC.RaidMonitor:DiscardSession()
    if not self.session then
        return false
    end
    self.session = nil
    self:EndSessionUpkeep()
    self:SetCombatLogTracking(false)
    return true
end

-- Eine fremde Sitzungsmeldung gegen die eigene halten. Rueckgabe: ob die
-- eigene Sitzung danach die fremde ist.
function GC.RaidMonitor:AdoptForeignSession(sessionID, startedBy, startedAt, zone, sender)
    if type(sessionID) ~= "string" or sessionID == "" then
        return false
    end
    local session = self.session
    if not session then
        self:StartSession(sessionID, startedBy, startedAt, zone)
        GC:FireCallback("ORDERS_BANNER",
            "Raidsitzung gestartet von " .. GC.Util.PlayerShortName(sender or startedBy or ""))
        return true
    end
    if session.id == sessionID then
        return true
    end
    if not self:IsPreferredSession(startedAt, sessionID, session.startedAt, session.id) then
        return false
    end
    -- Die eigene Sitzung verliert. Nur wenn sie noch frisch ist, wird sie
    -- verworfen - sonst haengt daran schon ein halber Abend.
    if (GC.Util.Now() - (tonumber(session.startedAt) or 0)) > SESSION_MERGE_GRACE then
        if not self.parallelSessionWarned then
            self.parallelSessionWarned = true
            GC:Print("|cffffb840Es laufen zwei Raidsitzungen parallel|r – deine von "
                .. GC.Util.PlayerShortName(session.startedBy or "") .. " und eine von "
                .. GC.Util.PlayerShortName(startedBy or sender or "") .. ". "
                .. "Deine bleibt bestehen; beide werden getrennt ausgewertet.")
        end
        return false
    end
    self:DiscardSession()
    self:StartSession(sessionID, startedBy, startedAt, zone)
    GC:Print("Die Raidsitzung wurde bereits von "
        .. GC.Util.PlayerShortName(startedBy or sender or "") .. " gestartet – "
        .. "deine wurde damit zusammengeführt.")
    GC:FireCallback("ORDERS_BANNER",
        "Raidsitzung gestartet von " .. GC.Util.PlayerShortName(startedBy or sender or ""))
    return true
end

function GC.RaidMonitor:BeginSession()
    if self.session then
        -- Wer die Sitzung gestartet hat, gehoert in die Absage: Sonst steht da
        -- "laeuft bereits" und niemand weiss, ob das die eigene von vorhin ist
        -- oder gerade jemand anderes schneller war.
        local startedBy = GC.Util.PlayerShortName(self.session.startedBy or "")
        if startedBy ~= "" then
            return false, "Die Raidsitzung läuft bereits – gestartet von " .. startedBy .. "."
        end
        return false, "Es läuft bereits eine Sitzung."
    end
    if not self:CanControlSession() then
        return false, "Nur die in den Einstellungen freigegebenen Gildenränge dürfen eine Sitzung starten."
    end

    local sessionID = tostring(GC.Util.Now()) .. tostring(math.random(1000, 9999))
    local session = self:StartSession(sessionID, GC:GetPlayerFullName(), GC.Util.Now(), nil)
    GC.Sync:AnnounceSessionStart(session)
    return true, "Raidsitzung gestartet. Anwesenheit und Auswertung laufen mit."
end

function GC.RaidMonitor:EndSession()
    if not self.session then
        return false, "Es läuft keine Sitzung."
    end
    if not self:CanControlSession() then
        return false, "Nur die in den Einstellungen freigegebenen Gildenränge dürfen eine Sitzung beenden."
    end

    local summary = self:FinishSession(GC.Util.Now())
    if summary then
        GC.Sync:AnnounceSessionEnd(summary)
        -- Ohne festen Kanal: DistributeSummary waehlt RAID oder PARTY danach,
        -- in welcher Gruppe die Sitzung tatsaechlich lief.
        GC.Sync:DistributeSummary(summary)
    end
    local participantCount = summary and #summary.participants or 0
    return true, "Raidsitzung beendet. " .. participantCount
        .. " Teilnehmer ausgewertet – die Auswertung steht unten in der Liste."
end

-- Beendet die Sitzung, verdichtet sie zur Zusammenfassung und verwirft die
-- laufenden Rohdaten. Gespeichert wird ausschließlich die Zusammenfassung.
function GC.RaidMonitor:FinishSession(endedAt)
    local session = self.session
    if not session then
        return nil
    end

    endedAt = tonumber(endedAt) or GC.Util.Now()
    self:CloseSegment(endedAt)
    ClosePresence(session, endedAt)

    local summary = self:BuildSummary(session, endedAt)
    self.session = nil
    self:EndSessionUpkeep()
    self:SetCombatLogTracking(false)
    self:StoreSummary(summary)
    GC:FireCallback("RAID_SESSION_UPDATED")
    return summary
end

-- === Die laufende Sitzung überlebt den Verbindungsabbruch ================
--
-- Sie lag bisher ausschließlich im Arbeitsspeicher. Ein Disconnect, ein
-- Absturz oder auch nur ein `/reload` warf damit den halben Abend weg – und
-- zwar genau bei dem, der ihn führt.
--
-- Gespeichert wird deshalb in die SavedVariables, und zwar **dieselbe
-- Tabelle, keine Kopie**: Während des Raids kostet das exakt nichts, weil
-- nichts umgerechnet oder umkopiert wird. Geschrieben wird die Datei ohnehin
-- erst beim Ausloggen, und dort steht sie dann fertig. Zwei Dinge müssen vor
-- dem Schreiben noch geradegezogen werden – ein offener Kampfabschnitt und
-- die laufende Anwesenheitsuhr –, sonst zählt die fortgesetzte Sitzung die
-- Zeit über die Auszeit hinweg weiter.
function GC.RaidMonitor:PersistSession()
    if not GC.DB or not GC.DB.data then
        return false
    end
    GC.DB:GetCharacter().liveSession = self.session
    return true
end

function GC.RaidMonitor:ClearPersistedSession()
    if not GC.DB or not GC.DB.data then
        return
    end
    GC.DB:GetCharacter().liveSession = nil
end

-- Beim Ausloggen: offenen Abschnitt schließen, Anwesenheitsuhren anhalten und
-- den Zeitpunkt festhalten. Die Namenszuordnung des Kampflogs fliegt raus –
-- sie ist ein reiner Zwischenspeicher und kann tausende Rohschreibweisen
-- enthalten, die niemand wieder braucht.
function GC.RaidMonitor:SaveSessionForResume(at)
    local session = self.session
    if not session then
        self:ClearPersistedSession()
        return nil
    end
    at = tonumber(at) or GC.Util.Now()
    self:CloseSegment(at)
    ClosePresence(session, at)
    session.nameLookup = nil
    session.savedAt = at
    self:PersistSession()
    return session
end

-- Beim Login: fortsetzen, wenn die Unterbrechung kurz war. Ein liegen
-- gebliebener Abend wird nicht weggeworfen, sondern mit seinem letzten
-- bekannten Stand ausgewertet und abgelegt – lieber eine unvollständige
-- Auswertung als gar keine.
function GC.RaidMonitor:ResumeSession()
    if self.session or not GC.DB or not GC.DB.data then
        return nil
    end
    local session = GC.DB:GetCharacter().liveSession
    if type(session) ~= "table" or type(session.id) ~= "string" or session.id == "" then
        self:ClearPersistedSession()
        return nil
    end

    -- Von Hand bearbeitete oder unter einer älteren Version geschriebene
    -- SavedVariables dürfen den Mitschnitt nicht in einen Lua-Fehler laufen
    -- lassen; fehlende Zweige werden ersetzt, nicht vorausgesetzt.
    session.participants = type(session.participants) == "table" and session.participants or {}
    session.participantOrder = type(session.participantOrder) == "table" and session.participantOrder or {}
    session.pulls = type(session.pulls) == "table" and session.pulls or {}
    session.nameLookup = nil
    session.startedAt = tonumber(session.startedAt) or GC.Util.Now()
    -- Ohne savedAt kam die Datei aus einem Absturz statt aus einem sauberen
    -- Ausloggen. Dann ist unbekannt, wie lange danach noch gespielt wurde;
    -- die offenen Uhren werden ohne Gutschrift angehalten. Lieber ein paar
    -- Minuten zu wenig als eine über Nacht weiterlaufende Anwesenheit.
    local savedAt = tonumber(session.savedAt)
    ClosePresence(session, savedAt)

    self.session = session
    if (GC.Util.Now() - (savedAt or session.startedAt)) > MAX_RESUME_AGE then
        local summary = self:FinishSession(savedAt or session.startedAt)
        return nil, summary
    end

    self:SetCombatLogTracking(true)
    self:SyncParticipants()
    self:BeginSessionUpkeep()
    GC:FireCallback("RAID_SESSION_UPDATED")
    return session
end

-- === Herzschlag: dieselbe Sitzung auf allen Clients ======================
--
-- Alle Addon-Nutzer im Raid schreiben denselben Abend mit. Wer erst später
-- dazustößt oder nach einem Verbindungsabbruch zurückkommt, hat den
-- Startruf aber verpasst und schriebe den Rest des Abends gar nicht mit.
--
-- Der Herzschlag schließt diese Lücke, ohne dabei den Kanal zu belasten:
-- Gesendet wird höchstens einmal je SESSION_HEARTBEAT_INTERVAL, und immer nur
-- von einem – wer einen fremden Herzschlag hört, schweigt bis zum nächsten
-- Takt. Wer zuerst spricht, spricht für alle; fällt der aus, übernimmt beim
-- nächsten Takt der Nächste, ganz ohne Absprache. Damit nicht alle gleichzeitig
-- losreden, wartet der Raidleiter am kürzesten, dann die Assistenten, dann der
-- Rest, jeder noch mit einem zufälligen Aufschlag gegen Gleichstand.
function GC.RaidMonitor:HeartbeatDelay()
    local raidRank = self:GetRaidRank() or 0
    local rankDelay = 10
    if raidRank >= 2 then
        rankDelay = 0
    elseif raidRank >= 1 then
        rankDelay = 5
    end
    return SESSION_HEARTBEAT_INTERVAL + rankDelay + (self.heartbeatJitter or 0)
end

function GC.RaidMonitor:NoteHeartbeat(at)
    local session = self.session
    if session then
        session.heartbeatAt = tonumber(at) or GC.Util.Now()
    end
end

function GC.RaidMonitor:PumpHeartbeat()
    local session = self.session
    if not session or not self:CanControlSession() or not self:IsInAnyGroup() then
        return false
    end
    local last = tonumber(session.heartbeatAt) or 0
    if (GC.Util.Now() - last) < self:HeartbeatDelay() then
        return false
    end
    -- Auch ein fehlgeschlagener Sendeversuch gilt als Takt: Sonst versucht es
    -- ein Client ohne Gruppe im Sekundentakt immer wieder.
    self:NoteHeartbeat()
    return GC.Sync:AnnounceSessionHeartbeat(session) == true
end

function GC.RaidMonitor:BeginSessionUpkeep()
    self:PersistSession()
    self.heartbeatJitter = math.random() * 4
    self:NoteHeartbeat()
    heartbeatElapsed = 0
    heartbeatFrame:Show()
end

function GC.RaidMonitor:EndSessionUpkeep()
    self:ClearPersistedSession()
    heartbeatFrame:Hide()
end

function GC.RaidMonitor:BuildSummary(session, endedAt)
    local summary = {
        id = session.id,
        startedAt = session.startedAt,
        endedAt = tonumber(endedAt) or GC.Util.Now(),
        startedBy = session.startedBy,
        zone = session.zone,
        pulls = 0,
        kills = 0,
        wipes = 0,
        participants = {},
        source = "LIVE",
        receivedAt = GC.Util.Now(),
    }

    -- Der boss-Filter räumt auch Sitzungen älterer Versionen auf, die noch
    -- Trashkämpfe als Versuche gespeichert haben.
    for _, pull in ipairs(session.pulls) do
        if pull.boss then
            summary.pulls = summary.pulls + 1
            if pull.result == "KILL" then
                summary.kills = summary.kills + 1
            elseif pull.result == "WIPE" then
                summary.wipes = summary.wipes + 1
            end
        end
    end

    for _, key in ipairs(session.participantOrder) do
        local participant = session.participants[key]
        if participant then
            local entry = {
                name = participant.name,
                classFile = participant.classFile,
                seconds = math.max(0, math.floor(participant.seconds)),
                deaths = participant.deaths,
                resurrects = participant.resurrects,
                interrupts = participant.interrupts,
                dispels = participant.dispels,
                consumables = {},
            }
            for _, category in ipairs(GC.ConsumableCategories) do
                entry.consumables[category.key] = participant.consumables[category.key] or 0
            end
            -- Das Verbrauchsprotokoll wandert gekappt in die Aufbewahrung:
            -- die letzten 40 Einträge je Teilnehmer. Es bleibt lokal - die
            -- Zusammenfassung wird ohne dieses Feld gesendet.
            local log = participant.consumableLog
            if log and #log > 0 then
                local kept = {}
                local start = math.max(1, #log - 39)
                for index = start, #log do
                    kept[#kept + 1] = log[index]
                end
                entry.consumableLog = kept
                entry.consumableLogDropped = (participant.consumableLogDropped or 0)
                    + (start - 1)
            end
            summary.participants[#summary.participants + 1] = entry
        end
    end
    return summary
end

function GC.RaidMonitor:StoreSummary(summary)
    if not summary or not summary.id then
        return false
    end

    local sessions = GC.DB:GetGuild().raidSessions
    for index, stored in ipairs(sessions) do
        -- Live-, Sync- und WCL-Daten bleiben getrennt und werden nie ineinander
        -- verrechnet - deshalb identifiziert erst Kennung UND Quelle zusammen
        -- eine Auswertung. Vorher zaehlte allein die Kennung: Jeder Teilnehmer
        -- speicherte beim Sitzungsende seine eigene LIVE-Fassung, und die
        -- vollstaendigere SYNC-Fassung des Raidleiters wurde danach mit
        -- derselben Kennung als "andere Quelle" verworfen, statt neben der
        -- eigenen zu stehen. Der Quellenvergleich hatte damit nie zwei Seiten.
        if stored.id == summary.id and stored.source == summary.source then
            -- Die vollständigere Auswertung gewinnt, bei Gleichstand die neuere.
            local storedSize = #(stored.participants or {})
            local incomingSize = #(summary.participants or {})
            if incomingSize > storedSize
                or (incomingSize == storedSize and (summary.endedAt or 0) >= (stored.endedAt or 0)) then
                sessions[index] = summary
                GC:FireCallback("RAID_SESSION_UPDATED")
                return true
            end
            return false
        end
    end

    table.insert(sessions, 1, summary)
    table.sort(sessions, function(left, right)
        return (left.endedAt or 0) > (right.endedAt or 0)
    end)
    -- Beim Aufräumen fliegen zuerst Abende OHNE Bosskampf (in der Stadt
    -- gestartete Probe-Sitzungen). Vorher galt reine Aktualität - zwölf
    -- Orgrimmar-Minis verdrängten den frisch importierten Raidabend, und der
    -- Import meldete Erfolg, während die Auswertung sofort wieder verschwand.
    while #sessions > MAX_STORED_SESSIONS do
        local worstIndex
        for index = #sessions, 1, -1 do
            local candidate = sessions[index]
            local pulls = tonumber(candidate.pulls) or 0
            if pulls <= 0 then
                worstIndex = index
                break
            end
        end
        table.remove(sessions, worstIndex or #sessions)
    end
    GC:FireCallback("RAID_SESSION_UPDATED")
    return true
end

-- Löscht einen ganzen Abend mit allen Quellen (Live, Logs, Datei) aus dem
-- lokalen Bestand. Nur lokal: Andere Clients behalten ihre Kopien, und
-- "Auswertung anfordern" kann Gelöschtes bewusst zurückholen.
--
-- Löschen dürfen nur die Ränge, die auch die Mitgliederpflege öffnen
-- (Standard: Offiziere oder höher). Der Kreis ist in den Einstellungen
-- einstellbar und wird gildenweit synchronisiert.
function GC.RaidMonitor:DeleteEvening(summaryKey)
    if not GC.Roster:CanAccessMemberCare() then
        return false, "Nur die in den Einstellungen freigegebenen Ränge dürfen Auswertungen löschen."
    end
    local evening = self:GetEveningOf(summaryKey)
    if not evening then
        return false, "Keine Auswertung gewählt."
    end
    local drop = {}
    local dropped = 0
    for _, summary in ipairs(evening.sources) do
        drop[self:SummaryKey(summary)] = true
        dropped = dropped + 1
    end
    local sessions = GC.DB:GetGuild().raidSessions
    for index = #sessions, 1, -1 do
        if drop[self:SummaryKey(sessions[index])] then
            table.remove(sessions, index)
        end
    end
    if self.selectedSessionID and drop[self.selectedSessionID] then
        self.selectedSessionID = nil
    end
    GC:FireCallback("RAID_SESSION_UPDATED")
    return true, dropped > 1
        and ("Abend gelöscht (" .. dropped .. " Quellen).")
        or "Auswertung gelöscht."
end

function GC.RaidMonitor:GetSummaries()
    return GC.DB:GetGuild().raidSessions or {}
end

-- Eine gespeicherte Auswertung wird durch Kennung UND Quelle identifiziert:
-- Derselbe Abend liegt als LIVE-Mitschrift und als SYNC-Fassung des
-- Raidleiters mit derselben Kennung nebeneinander. Wo frueher die Kennung
-- allein als Auswahl diente, traf sie damit immer nur die erste von beiden -
-- die zweite Quelle liess sich gar nicht anzeigen.
function GC.RaidMonitor:SummaryKey(summary)
    if not summary then
        return nil
    end
    return tostring(summary.id or "") .. "#" .. tostring(summary.source or "LIVE")
end

function GC.RaidMonitor:GetSummaryByKey(summaryKey)
    if not summaryKey then
        return nil
    end
    for _, summary in ipairs(self:GetSummaries()) do
        if self:SummaryKey(summary) == summaryKey then
            return summary
        end
    end
    return nil
end

-- Bestand einer Quelle: Gibt es zu dieser Kennung schon eine Auswertung
-- GENAU dieser Herkunft? Der Import fragt so, ob ein Report schon da ist.
function GC.RaidMonitor:GetSummary(sessionID, source)
    for _, summary in ipairs(self:GetSummaries()) do
        if summary.id == sessionID
            and (source == nil or (summary.source or "LIVE") == source) then
            return summary
        end
    end
    return nil
end

-- === Derselbe Abend aus mehreren Quellen =================================
--
-- Ein Raidabend kann dreifach vorliegen: als Livesitzung, als
-- Warcraft-Logs-Report und als Offline-Import aus der Logdatei. Ihre Zahlen
-- werden nie miteinander verrechnet, die Quellen sind unterschiedlich genau.
-- In der Liste soll der Abend aber einmal stehen und nicht dreimal.
--
-- Als Fingerabdruck taugt kein Hash aus den Teilnehmern: Jede Quelle zieht die
-- Liste anders (Warcraft Logs nach friendlyPlayers, die Logdatei nach
-- Anwesenheit im Encounter, die Livesitzung nach dem Raidroster). Ein exakter
-- Vergleich schlüge also genau dann fehl, wenn er gebraucht wird. Entschieden
-- wird deshalb über beides zusammen: überschneidende Zeiträume und eine
-- Teilnehmerdeckung von mindestens der Hälfte der kleineren Liste.

local SAME_EVENING_COVERAGE = 0.5

local function ParticipantNameSet(summary)
    local names = {}
    local count = 0
    for _, participant in ipairs(summary.participants or {}) do
        local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(participant.name or ""))
        if key ~= "" and not names[key] then
            names[key] = true
            count = count + 1
        end
    end
    return names, count
end

function GC.RaidMonitor:IsSameEvening(left, right)
    if not left or not right then
        return false
    end
    local leftStart, leftEnd = tonumber(left.startedAt) or 0, tonumber(left.endedAt) or 0
    local rightStart, rightEnd = tonumber(right.startedAt) or 0, tonumber(right.endedAt) or 0
    if leftStart > rightEnd or rightStart > leftEnd then
        return false
    end

    local leftNames, leftCount = ParticipantNameSet(left)
    local rightNames, rightCount = ParticipantNameSet(right)
    if leftCount == 0 or rightCount == 0 then
        return false
    end
    local shared = 0
    for name in pairs(leftNames) do
        if rightNames[name] then
            shared = shared + 1
        end
    end
    return shared >= math.ceil(math.min(leftCount, rightCount) * SAME_EVENING_COVERAGE)
end

-- Je Abend ein Eintrag. Angezeigt wird die vollständigste Auswertung; die
-- übrigen Quellen bleiben gespeichert und werden mitgeliefert, damit die
-- Oberfläche sie anbieten kann.
function GC.RaidMonitor:GetEvenings()
    local evenings = {}
    for _, summary in ipairs(self:GetSummaries()) do
        local evening
        for _, candidate in ipairs(evenings) do
            if self:IsSameEvening(candidate.summary, summary) then
                evening = candidate
                break
            end
        end
        if not evening then
            evening = { summary = summary, sources = {} }
            evenings[#evenings + 1] = evening
        end
        evening.sources[#evening.sources + 1] = summary
        -- Die vollständigere Auswertung führt den Abend an; bei Gleichstand
        -- die zuerst gespeicherte, denn die Liste ist schon nach Ende sortiert.
        if #(summary.participants or {}) > #(evening.summary.participants or {}) then
            evening.summary = summary
        end
    end
    return evenings
end

function GC.RaidMonitor:GetEveningOf(summaryKey)
    for _, evening in ipairs(self:GetEvenings()) do
        for _, summary in ipairs(evening.sources) do
            if self:SummaryKey(summary) == summaryKey then
                return evening
            end
        end
    end
    return nil
end

-- Erkannte und ausgeschlossene Gegnernamen. Der Combat Log nennt im Raid
-- dieselben Namen tausendfach; ohne diesen Zwischenspeicher liefe fuer jedes
-- Schadensereignis die ganze Bossliste durch.
local bossLookupCache = {}

-- Erkannt wird ueber den Eigennamen als Teilzeichenkette: "Prinz Malchezaar"
-- und "Prince Malchezaar" enthalten beide "Malchezaar". Damit braucht es
-- keine belegte Uebersetzung je Client-Sprache.
function GC.RaidMonitor:ResolveBoss(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    local cached = bossLookupCache[name]
    if cached ~= nil then
        return cached or nil
    end

    local lowered = name:lower()
    for _, boss in ipairs(GC.RaidBosses) do
        for _, needle in ipairs(boss.names) do
            if lowered:find(needle:lower(), 1, true) then
                bossLookupCache[name] = boss
                return boss
            end
        end
    end
    bossLookupCache[name] = false
    return nil
end

-- Nur pruefen, solange der Boss des Abschnitts noch nicht feststeht: Ist er
-- einmal erkannt, kostet der Rest des Kampfes gar nichts mehr.
function GC.RaidMonitor:NoteBossParticipant(segment, guid, name)
    if not segment or segment.bossName then
        return
    end
    if not tostring(guid or ""):find("Creature", 1, true) then
        return
    end
    local boss = self:ResolveBoss(name)
    if boss then
        segment.bossName = SanitizedText(name, 36)
        segment.bossInstance = boss.instance
    end
end

function GC.RaidMonitor:BeginSegment(startedAt)
    local session = self.session
    if not session or session.segment then
        return
    end
    session.segment = {
        startedAt = tonumber(startedAt) or GC.Util.Now(),
        playerDeaths = 0,
        lastNPCDeath = nil,
        bossDied = false,
        bossName = nil,
        bossInstance = nil,
    }
end

-- Als Versuch zählt nur ein erkannter Bosskampf: entweder meldet ihn der
-- Client über ENCOUNTER_START, oder die Namensheuristik findet einen Boss im
-- Combat Log. Reine Trashkämpfe werden verworfen - sonst stünden nach dem
-- ersten Boss längst "8 Versuche" auf der Uhr. Sterben mindestens WIPE_RATIO
-- der Anwesenden, zählt der Abschnitt als Wipe.
function GC.RaidMonitor:CloseSegment(endedAt)
    local session = self.session
    local segment = session and session.segment
    if not segment then
        return
    end
    session.segment = nil

    if not segment.bossName then
        return
    end

    endedAt = tonumber(endedAt) or GC.Util.Now()
    local duration = endedAt - segment.startedAt
    -- Ein vom Client bestätigter Encounter zählt auch, wenn er kürzer war -
    -- eine überlegene Gruppe legt Attumen in unter 15 Sekunden.
    if not segment.encounterResult and duration < MIN_SEGMENT_SECONDS then
        return
    end

    local presentCount = 0
    for _, participant in pairs(session.participants) do
        if participant.presentSince then
            presentCount = presentCount + 1
        end
    end

    -- Mindestens zwei Tote, damit ein einzelner Ausfall in kleinen Gruppen
    -- nicht sofort als Wipe gilt.
    local wipeThreshold = math.max(2, math.ceil(presentCount * WIPE_RATIO))
    local result = "RESET"
    if segment.encounterResult then
        result = segment.encounterResult
    elseif presentCount > 0 and segment.playerDeaths >= wipeThreshold then
        result = "WIPE"
    elseif segment.bossDied then
        result = "KILL"
    end

    -- Der erkannte Boss hat Vorrang vor dem zuletzt gestorbenen Gegner. Genau
    -- bei einem Wipe stirbt der Boss ja nicht, und dann stand hier bisher der
    -- Name irgendeines Adds - oder gar nichts.
    session.pulls[#session.pulls + 1] = {
        name = segment.bossName or segment.lastNPCDeath or "Kampf",
        instance = segment.bossInstance,
        boss = segment.bossName ~= nil,
        startedAt = segment.startedAt,
        endedAt = endedAt,
        result = result,
    }
    GC:FireCallback("RAID_SESSION_UPDATED")
end

-- Der Anniversary-Client meldet Bosskämpfe selbst: ENCOUNTER_START nennt den
-- Boss beim Namen, ENCOUNTER_END den Ausgang. Das schlägt jede Heuristik und
-- deckt auch Bosse ab, die in der eigenen Liste fehlen.
function GC.RaidMonitor:OnEncounterStart(_, encounterName)
    local session = self.session
    if not session then
        return
    end
    if not session.segment then
        self:BeginSegment(GC.Util.Now())
    end
    local segment = session.segment
    if not segment or segment.bossName then
        return
    end
    local name = SanitizedText(encounterName, 36)
    if name ~= "" then
        segment.bossName = name
        local boss = self:ResolveBoss(name)
        segment.bossInstance = (boss and boss.instance)
            or (GetRealZoneText and GetRealZoneText()) or nil
    end
end

function GC.RaidMonitor:OnEncounterEnd(_, encounterName, _, _, success)
    local session = self.session
    local segment = session and session.segment
    if not segment then
        return
    end
    if not segment.bossName then
        local name = SanitizedText(encounterName, 36)
        if name ~= "" then
            segment.bossName = name
        end
    end
    segment.encounterResult = (tonumber(success) == 1) and "KILL" or "WIPE"
    self:CloseSegment(GC.Util.Now())
end

-- Ein Verbrauchsgegenstand wird gezaehlt, WENN er verbraucht wird - und zwar
-- jedes Mal. Entscheidend ist, welches Ereignis dafuer der Beleg ist; das
-- steht je Kategorie in GC.ConsumableCategories:
--
--   CAST  Nur das Wirkereignis beim Benutzer. Der Buff, der daraus wird,
--         zaehlt ausdruecklich NICHT. Genau daran hing die groesste
--         Verfaelschung: Trommeln buffen die ganze Gruppe, also bekam jedes
--         Gruppenmitglied jede geworfene Trommel gutgeschrieben. Im
--         Vergleichslog vom 02.08.2026 haben fuenf Spieler Trommeln geworfen -
--         angezeigt wurden sie bei acht, einer davon mit 68 statt 28.
--         Traenke mit Buff (Hast, Zerstoerung) zaehlten aus demselben Grund
--         doppelt: einmal als Zauber, einmal als eigene Aura.
--   AURA  Nur die Aura beim Beschenkten. Das gilt allein fuer Essen: Ein
--         Wirkereignis gibt es dafuer nie, der Sattgegessen-Buff erscheint
--         Sekunden nach dem Essen von selbst.
--
-- Der frueher zusaetzlich gepruefte Auraname ("Sattgegessen"/"Well Fed") ist
-- entfallen. Er hat auf dem deutschen Client ohnehin nie getroffen - dort
-- heisst die Aura schlicht "Satt", und genau so heisst auch der
-- Kampfrausch-Debuff. Ein Namensvergleich haette also entweder nichts oder
-- das Falsche gefunden; die Spell-IDs stehen in GC.Consumables.
local function ResolveConsumable(spellID)
    local consumable = GC.Consumables[tonumber(spellID) or 0]
    if not consumable then
        return nil, nil
    end
    return GC.ConsumableCategoryByKey[consumable.category], consumable
end

local function RecordConsumable(participant, category, consumable, spellID, spellName)
    participant.consumables[category.key] = (participant.consumables[category.key] or 0) + 1

    -- Zusaetzlich zum Zaehler ein Protokoll: WAS wurde WANN eingeworfen.
    -- Bleibt rein lokal (wird nie gesendet) und zeigt sich beim Klick auf
    -- den Teilnehmer. Die Kappe schuetzt vor Trommel-Spam; Verworfenes wird
    -- gezaehlt statt verschwiegen.
    local log = participant.consumableLog
    if not log then
        log = {}
        participant.consumableLog = log
    end
    log[#log + 1] = {
        t = GC.Util.Now(),
        n = (consumable and consumable.name)
            or (spellName and tostring(spellName))
            or ("Zauber " .. tostring(spellID or "?")),
        c = category.key,
    }
    if #log > 100 then
        table.remove(log, 1)
        participant.consumableLogDropped = (participant.consumableLogDropped or 0) + 1
    end
end

local function CountConsumable(monitor, session, playerName, spellID, spellName, isAura)
    local category, consumable = ResolveConsumable(spellID)
    if not category then
        return
    end
    -- Die eine Bedingung, die Trommelinflation und Doppelzaehlung erledigt.
    if category.track == "AURA" then
        if not isAura then
            return
        end
    elseif isAura then
        return
    end
    local participant = monitor:FindParticipant(session, playerName)
    if not participant then
        return
    end
    RecordConsumable(participant, category, consumable, spellID, spellName)
end

-- Buffs eines Raidmitglieds ablesen. Der Client bietet dafuer je nach
-- Spielfassung eine andere Schnittstelle an; welche vorhanden ist, entscheidet
-- sich zur Laufzeit. Faellt beides aus, wird nichts abgelesen - das ergibt
-- unvollstaendige Zahlen, aber keine falschen.
local function ForEachBuff(unit, callback)
    if C_UnitAuras and C_UnitAuras.GetBuffDataByIndex then
        for index = 1, 40 do
            local data = C_UnitAuras.GetBuffDataByIndex(unit, index)
            if not data then
                return true
            end
            callback(data.spellId, data.name)
        end
        return true
    end
    if UnitBuff then
        for index = 1, 40 do
            local name, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, index)
            if not name then
                return true
            end
            callback(spellID, name)
        end
        return true
    end
    return false
end

-- Fläschchen, Elixiere und Essen kommen vor dem Raid auf den Charakter - oft
-- lange vor dem ersten Pull und damit lange vor dem Sitzungsbeginn. Aus dem
-- Kampfprotokoll ist davon nichts zu holen; ein vollstaendig gebuffter Raid
-- stand deshalb mit lauter Nullen da (im Vergleichslog vom 02.08.2026: 23 von
-- 25 Teilnehmern ohne Fläschchen).
--
-- Einmal je Teilnehmer wird deshalb abgelesen, was er beim Eintreten schon
-- traegt. Nur einmal - sonst zaehlte jeder Durchlauf des Anwesenheitsabgleichs
-- denselben Buff erneut. Wer spaeter nachlegt, wird ganz normal ueber das
-- Kampfprotokoll erfasst.
function GC.RaidMonitor:ScanCarriedConsumables(unit, participant)
    if not participant or participant.auraScanDone or not unit then
        return
    end
    -- Erst ablesen, wenn der Spieler wirklich sichtbar ist: In einer anderen
    -- Zone liefert die Abfrage nichts, und ein leeres Ergebnis darf nicht als
    -- "hat nichts dabei" durchgehen.
    if UnitExists and not UnitExists(unit) then
        return
    end
    if UnitIsVisible and not UnitIsVisible(unit) then
        return
    end
    participant.auraScanDone = true
    ForEachBuff(unit, function(spellID, spellName)
        local category, consumable = ResolveConsumable(spellID)
        if category and category.scan then
            RecordConsumable(participant, category, consumable, spellID, spellName)
        end
    end)
end

-- Der Combat Log liefert im Raid tausende Schadensereignisse pro Kampf. Sie
-- werden mit einem einzigen Tabellenzugriff abgewiesen, bevor irgendetwas
-- anderes passiert.
local TRACKED_SUBEVENTS = {
    UNIT_DIED = true,
    SPELL_RESURRECT = true,
    SPELL_INTERRUPT = true,
    SPELL_DISPEL = true,
    SPELL_STOLEN = true,
    SPELL_CAST_SUCCESS = true,
    SPELL_AURA_APPLIED = true,
    SPELL_AURA_REFRESH = true,
}

function GC.RaidMonitor:HandleCombatLogEvent(subevent, sourceGUID, sourceName, destGUID, destName, spellID, spellName)
    local session = self.session
    if not session or not TRACKED_SUBEVENTS[subevent] then
        return
    end

    -- Wer im Abschnitt mitmischt, verraet, gegen wen gekaempft wird. Der Boss
    -- wirkt Zauber, lange bevor er stirbt - deshalb steht sein Name auch dann
    -- fest, wenn der Versuch im Wipe endet.
    if session.segment and not session.segment.bossName then
        self:NoteBossParticipant(session.segment, sourceGUID, sourceName)
        self:NoteBossParticipant(session.segment, destGUID, destName)
    end

    if subevent == "UNIT_DIED" then
        local participant = self:FindParticipant(session, destName)
        if participant then
            participant.deaths = participant.deaths + 1
            if session.segment then
                session.segment.playerDeaths = session.segment.playerDeaths + 1
            end
        elseif session.segment and tostring(destGUID or ""):find("Creature", 1, true) then
            local npcName = SanitizedText(destName, 36)
            session.segment.lastNPCDeath = npcName
            -- Ein Sieg ist der Tod des BOSSES. Vorher genuegte irgendein toter
            -- Gegner: Fehlte ENCOUNTER_END, machte der erste gestorbene Add
            -- aus einem abgebrochenen Versuch einen "Kill".
            if self:ResolveBoss(destName)
                or (session.segment.bossName and npcName == session.segment.bossName) then
                session.segment.bossDied = true
            end
        end
        return
    end

    if subevent == "SPELL_RESURRECT" then
        local participant = self:FindParticipant(session, sourceName)
        if participant then
            participant.resurrects = participant.resurrects + 1
        end
        return
    end

    if subevent == "SPELL_INTERRUPT" then
        local participant = self:FindParticipant(session, sourceName)
        if participant then
            participant.interrupts = participant.interrupts + 1
        end
        return
    end

    if subevent == "SPELL_DISPEL" or subevent == "SPELL_STOLEN" then
        local participant = self:FindParticipant(session, sourceName)
        if participant then
            participant.dispels = participant.dispels + 1
        end
        return
    end

    -- Tränke, Runen und Trommeln werden gewirkt, dauerhafte Buffs erscheinen
    -- als Aura auf dem Ziel.
    if subevent == "SPELL_CAST_SUCCESS" then
        CountConsumable(self, session, sourceName, spellID, spellName, false)
    elseif subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
        CountConsumable(self, session, destName, spellID, spellName, true)
    end
end

function GC.RaidMonitor:OnCombatLogEvent()
    if not self.session or not CombatLogGetCurrentEventInfo then
        return
    end
    -- Der Zaubername steht an dreizehnter Stelle. Er wurde bisher nicht
    -- ausgelesen, weshalb Essen nie erkannt werden konnte.
    local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName =
        CombatLogGetCurrentEventInfo()
    self:HandleCombatLogEvent(subevent, sourceGUID, sourceName, destGUID, destName, spellID, spellName)
end

function GC.RaidMonitor:EncodeSummary(summary)
    local records = {
        table.concat({
            "S",
            summary.id or "",
            tostring(summary.startedAt or 0),
            tostring(summary.endedAt or 0),
            SanitizedText(summary.zone or "", 40),
            SanitizedText(summary.startedBy or "", 20),
            tostring(summary.pulls or 0),
            tostring(summary.kills or 0),
            tostring(summary.wipes or 0),
        }, ","),
    }

    for _, participant in ipairs(summary.participants or {}) do
        local fields = {
            "P",
            SanitizedText(participant.name or "", 20),
            participant.classFile or "",
            tostring(participant.seconds or 0),
            tostring(participant.deaths or 0),
            tostring(participant.resurrects or 0),
            tostring(participant.interrupts or 0),
            tostring(participant.dispels or 0),
        }
        for _, category in ipairs(GC.ConsumableCategories) do
            fields[#fields + 1] = tostring((participant.consumables or {})[category.key] or 0)
        end
        records[#records + 1] = table.concat(fields, ",")
    end
    return table.concat(records, ";")
end

function GC.RaidMonitor:DecodeSummary(payload)
    local summary
    for record in tostring(payload or ""):gmatch("[^;]+") do
        local fields = {}
        for field in (record .. ","):gmatch("(.-),") do
            fields[#fields + 1] = field
        end

        if fields[1] == "S" then
            summary = {
                id = fields[2],
                startedAt = tonumber(fields[3]) or 0,
                endedAt = tonumber(fields[4]) or 0,
                zone = fields[5] or "",
                startedBy = fields[6] or "",
                pulls = tonumber(fields[7]) or 0,
                kills = tonumber(fields[8]) or 0,
                wipes = tonumber(fields[9]) or 0,
                participants = {},
                source = "SYNC",
                receivedAt = GC.Util.Now(),
            }
        elseif fields[1] == "P" and summary then
            local participant = {
                name = fields[2] or "",
                classFile = fields[3] ~= "" and fields[3] or nil,
                seconds = tonumber(fields[4]) or 0,
                deaths = tonumber(fields[5]) or 0,
                resurrects = tonumber(fields[6]) or 0,
                interrupts = tonumber(fields[7]) or 0,
                dispels = tonumber(fields[8]) or 0,
                consumables = {},
            }
            for index, category in ipairs(GC.ConsumableCategories) do
                participant.consumables[category.key] = tonumber(fields[8 + index]) or 0
            end
            if participant.name ~= "" then
                summary.participants[#summary.participants + 1] = participant
            end
        end
    end

    if not summary or not summary.id or summary.id == "" then
        return nil
    end
    return summary
end

function GC.RaidMonitor:BuildSummaryMessages(summary, token)
    local payload = self:EncodeSummary(summary)
    local chunks = {}
    for offset = 1, #payload, MAX_PAYLOAD_BYTES do
        chunks[#chunks + 1] = payload:sub(offset, offset + MAX_PAYLOAD_BYTES - 1)
    end

    token = token or (tostring(GC.Util.Now()) .. tostring(math.random(100, 999)))
    local messages = {}
    for index, chunk in ipairs(chunks) do
        messages[index] = table.concat({
            "RD",
            tostring(GC.Constants.SCHEMA_VERSION),
            token,
            tostring(index),
            tostring(#chunks),
            chunk,
        }, "|")
    end
    return messages
end

function GC.RaidMonitor:ReceiveSummaryChunk(message, sender)
    if not self:CanControlSession(sender) then
        return false
    end

    local schemaText, token, indexText, totalText, chunk =
        message:match("^RD|([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.*)$")
    local schemaVersion = tonumber(schemaText)
    local index = tonumber(indexText)
    local total = tonumber(totalText)
    if schemaVersion ~= GC.Constants.SCHEMA_VERSION
        or not index or not total or index < 1 or index > total or total > 40
        or #token > 40 or #chunk > MAX_PAYLOAD_BYTES then
        return false
    end

    local cutoff = GC.Util.Now() - INCOMING_TTL
    for key, transfer in pairs(self.incoming) do
        if (tonumber(transfer.receivedAt) or 0) < cutoff then
            self.incoming[key] = nil
        end
    end
    local incomingKey = GC.Util.NormalizeName(sender) .. "|" .. token
    local incoming = self.incoming[incomingKey]
    if not incoming or incoming.total ~= total then
        incoming = { total = total, chunks = {}, receivedAt = GC.Util.Now() }
        self.incoming[incomingKey] = incoming
    end
    incoming.chunks[index] = chunk

    local parts = {}
    for chunkIndex = 1, total do
        if incoming.chunks[chunkIndex] == nil then
            return false
        end
        parts[chunkIndex] = incoming.chunks[chunkIndex]
    end
    self.incoming[incomingKey] = nil

    local summary = self:DecodeSummary(table.concat(parts))
    if not summary then
        return false
    end
    local stored = self:StoreSummary(summary)
    -- Antwortzähler für "Auswertung anfordern": auch eine Antwort, die
    -- nichts Neues bringt, ist eine sichtbare Antwort.
    local stats = self.requestStats
    if stats and (GC.Util.Now() - (stats.at or 0)) < 180 then
        stats.answers = stats.answers + 1
        if stored then
            stats.new = stats.new + 1
        end
        GC:FireCallback("RAID_SUMMARY_ANSWERS")
    end
    return stored
end

function GC.RaidMonitor:OnMessage(message, sender, distribution)
    local messageType = message:match("^(%u+)|")
    if messageType == "RD" then
        return self:ReceiveSummaryChunk(message, sender)
    end

    local fields = GC.Util.SplitFields(message)
    if tonumber(fields[2]) ~= GC.Constants.SCHEMA_VERSION then
        return false
    end
    if not self:CanControlSession(sender) then
        return false
    end

    if fields[1] == "RS" then
        -- Alle Addon-Nutzer im Raid zeichnen dieselbe Sitzung mit, damit die
        -- Auswertung nicht an einem einzelnen Client hängt. Läuft hier schon
        -- eine andere, entscheidet die Regel oben, welche gilt - der Banner
        -- steckt in AdoptForeignSession.
        if distribution == "WHISPER" then
            return false
        end
        local adopted = self:AdoptForeignSession(
            fields[3], sender, tonumber(fields[4]), fields[5], sender)
        -- Nur der Ruf zur EIGENEN Sitzung zählt als „es redet schon jemand".
        -- Vorher stempelte jede fremde Meldung den eigenen Herzschlag und
        -- brachte die unterlegene Sitzung zusätzlich zum Schweigen.
        if adopted then
            self:NoteHeartbeat()
        end
        return true
    elseif fields[1] == "RH" then
        -- Der Herzschlag einer laufenden Sitzung. Für alle, die den Startruf
        -- verpasst haben, ist er zugleich der Startruf: Nachzügler und
        -- Wiedereinsteiger schreiben ab hier denselben Abend mit.
        if distribution == "WHISPER" then
            return false
        end
        local sessionID = fields[3]
        if type(sessionID) ~= "string" or sessionID == "" then
            return false
        end
        if not self.session then
            self:StartSession(sessionID, fields[6] ~= "" and fields[6] or sender,
                tonumber(fields[4]), fields[5])
            GC:FireCallback("ORDERS_BANNER",
                "Laufende Raidsitzung übernommen von " .. GC.Util.PlayerShortName(sender))
            self:NoteHeartbeat()
            return true
        end
        if self.session.id == sessionID then
            self:NoteHeartbeat()
            return true
        end
        -- Eine fremde Sitzung verdrängt die eigene nur, wenn sie nach derselben
        -- Regel gewinnt und die eigene noch frisch ist. Der Herzschlag heilt
        -- damit auch eine Spaltung, die dem Startruf entgangen ist - etwa weil
        -- jemand beim Drücken gerade im Ladebildschirm war.
        if self:AdoptForeignSession(sessionID, fields[6] ~= "" and fields[6] or sender,
            tonumber(fields[4]), fields[5], sender) then
            self:NoteHeartbeat()
            return true
        end
        return false
    elseif fields[1] == "RE" then
        local session = self.session
        if session and session.id == fields[3] then
            local summary = self:FinishSession(tonumber(fields[4]))
            return summary ~= nil
        end
        return false
    elseif fields[1] == "RQ" then
        return self:AnswerSummaryRequest(sender)
    end
    return false
end

-- Offiziere außerhalb des Raids fragen die Auswertung gezielt an; geantwortet
-- wird per Flüsterkanal, damit nichts über den offenen Gildenkanal geht.
function GC.RaidMonitor:RequestSummaries()
    if not self:CanControlSession() then
        return false, "Für deinen Rang ist die Raidauswertung nicht freigeschaltet."
    end
    if not GC.Sync:Send("RQ|" .. tostring(GC.Constants.SCHEMA_VERSION), "GUILD") then
        return false, "Die Anfrage konnte nicht gesendet werden."
    end
    -- Ab jetzt zählen eintreffende Antworten mit, damit der Knopf sichtbar
    -- etwas tut - vorher kam entweder still etwas an oder still nichts.
    self.requestStats = { at = GC.Util.Now(), answers = 0, new = 0 }
    GC:FireCallback("RAID_SUMMARY_ANSWERS")
    return true, "Auswertung angefragt. Berechtigte Mitglieder antworten gleich."
end

function GC.RaidMonitor:AnswerSummaryRequest(requester)
    -- Beantwortet wird mit bis zu fünf Abenden, Bossabende zuerst - nur die
    -- allerneueste Zusammenfassung zu schicken war sinnlos: Die hatte der
    -- Anfragende fast immer selbst, die Speicherung lehnte ab, und der Knopf
    -- wirkte völlig wirkungslos.
    local candidates = {}
    for _, summary in ipairs(self:GetSummaries()) do
        candidates[#candidates + 1] = summary
    end
    table.sort(candidates, function(left, right)
        local leftBoss = (tonumber(left.pulls) or 0) > 0 and 1 or 0
        local rightBoss = (tonumber(right.pulls) or 0) > 0 and 1 or 0
        if leftBoss ~= rightBoss then
            return leftBoss > rightBoss
        end
        return (left.endedAt or 0) > (right.endedAt or 0)
    end)
    if #candidates == 0 then
        return false
    end
    local now = GC.Util.Now()
    if (now - (self.lastAnswerAt or 0)) < MIN_ANSWER_INTERVAL then
        return false
    end
    self.lastAnswerAt = now

    for index = 1, math.min(5, #candidates) do
        local summary = candidates[index]
        -- Gestaffelt, damit sich die Antworten mehrerer Mitglieder nicht
        -- gegenseitig in den Kanal drängen.
        C_Timer.After(index + math.random() * 4, function()
            GC.Sync:DistributeSummary(summary, "WHISPER", requester)
        end)
    end
    return true
end

-- Beim Betreten einer Raidinstanz fragt das Addon, ob eine Sitzung starten
-- soll - aber nur bei denen, die das auch duerfen (CanControlSession), nur
-- im Schlachtzug, nur ohne laufende Sitzung und nur einmal je Besuch.
function GC.RaidMonitor:OnZoneEntered()
    if not C_Timer or type(C_Timer.After) ~= "function" then
        return
    end
    -- Kurz warten: Direkt nach dem Ladebildschirm sind Instanz- und
    -- Gruppendaten noch nicht verlaesslich.
    C_Timer.After(3, function()
        local monitor = GC.RaidMonitor
        local instanceType
        if IsInInstance then
            local _, kind = IsInInstance()
            instanceType = kind
        end
        if instanceType ~= "raid" then
            -- Draussen: Der naechste Instanzbesuch darf wieder fragen.
            monitor.sessionPromptShown = nil
            return
        end
        if monitor.session or monitor.sessionPromptShown then
            return
        end
        if not monitor:IsInRaidGroup() or not monitor:CanControlSession() then
            return
        end
        monitor.sessionPromptShown = true
        GC:FireCallback("RAID_SESSION_PROMPT",
            (GetRealZoneText and GetRealZoneText()) or "")
    end)
end

-- Der Rahmen steht oben bei den Herzschlag-Konstanten; er ist nur sichtbar,
-- solange eine Sitzung laeuft.
heartbeatFrame:SetScript("OnUpdate", function(_, elapsed)
    heartbeatElapsed = heartbeatElapsed + elapsed
    if heartbeatElapsed < SESSION_HEARTBEAT_CHECK then
        return
    end
    heartbeatElapsed = 0
    GC.RaidMonitor:PumpHeartbeat()
end)

raidEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
-- Der letzte Moment, in dem der Mitschnitt noch geradegezogen werden kann:
-- Danach schreibt WoW die SavedVariables, und was dort steht, ist der Stand,
-- mit dem die Sitzung nach dem Wiedereinloggen weiterläuft.
raidEvents:RegisterEvent("PLAYER_LOGOUT")

-- Der Rahmen und die dauerhaften Ereignisse stehen oben in der Datei, damit
-- StartSession und FinishSession das Combat-Log-Abo umschalten koennen.
raidEvents:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        GC.RaidMonitor:OnZoneEntered()
        return
    elseif event == "PLAYER_LOGOUT" then
        GC.RaidMonitor:SaveSessionForResume()
        return
    end
    if not GC.RaidMonitor.session then
        return
    end
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        GC.RaidMonitor:OnCombatLogEvent()
    elseif event == "GROUP_ROSTER_UPDATE" then
        GC.RaidMonitor:SyncParticipants()
    elseif event == "PLAYER_REGEN_DISABLED" then
        GC.RaidMonitor:BeginSegment(GC.Util.Now())
    elseif event == "PLAYER_REGEN_ENABLED" then
        GC.RaidMonitor:CloseSegment(GC.Util.Now())
    elseif event == "ENCOUNTER_START" then
        GC.RaidMonitor:OnEncounterStart(...)
    elseif event == "ENCOUNTER_END" then
        GC.RaidMonitor:OnEncounterEnd(...)
    end
end)

-- Nach dem Login steht die Sitzung wieder da, wo sie beim Ausloggen aufgehört
-- hat. Kurz gewartet wird trotzdem: Gruppen- und Zonendaten sind direkt nach
-- dem Ladebildschirm noch nicht verlässlich, und ohne Gruppe fände der
-- Herzschlag ohnehin keinen Kanal.
GC:RegisterCallback("PLAYER_LOGIN", GC.RaidMonitor, function(self)
    local function Resume()
        local session, closed = self:ResumeSession()
        if session then
            GC:Print("Die unterbrochene Raidsitzung läuft weiter ("
                .. #session.participantOrder .. " Teilnehmer).")
        elseif closed then
            GC:Print("Eine liegengebliebene Raidsitzung wurde ausgewertet und abgelegt.")
        end
    end
    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(5, Resume)
    else
        Resume()
    end
end)
