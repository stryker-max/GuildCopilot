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
    local wanted = GC.Util.NormalizeName(GC.Util.PlayerShortName(playerName))
    for index = 1, (GetNumGroupMembers() or 0) do
        local name, rank = GetRaidRosterInfo(index)
        if name and GC.Util.NormalizeName(GC.Util.PlayerShortName(name)) == wanted then
            return tonumber(rank) or 0
        end
    end
    return nil
end

-- Auswerten und steuern dürfen Raidleiter, Assistenten und die Gildenränge,
-- die auch die Mitgliederpflege öffnen dürfen.
function GC.RaidMonitor:CanControlSession(playerName)
    playerName = playerName or GC:GetPlayerFullName()
    local raidRank = self:GetRaidRank(playerName)
    if raidRank and raidRank >= 1 then
        return true
    end
    return GC.Roster:CanAccessMemberCare(playerName)
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
            seenConsumables = {},
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

    local function MarkPresent(name, classFile)
        local participant = name and self:GetParticipant(session, name, classFile)
        if participant then
            present[participant] = true
            participant.presentSince = participant.presentSince or now
        end
    end

    -- Wer die Sitzung mitschreibt, ist immer dabei. Ohne diese Zeile bliebe
    -- eine Sitzung ausserhalb eines Raids ganz ohne Teilnehmer.
    local _, ownClassFile = UnitClass("player")
    MarkPresent(GC:GetPlayerFullName(), ownClassFile)

    if self:IsInRaidGroup() and GetNumGroupMembers and GetRaidRosterInfo then
        for index = 1, (GetNumGroupMembers() or 0) do
            local name, _, _, _, _, classFile = GetRaidRosterInfo(index)
            MarkPresent(name, classFile)
        end
    elseif self:IsInAnyGroup() and GetNumGroupMembers then
        -- In einer Gruppe gibt es kein Raidroster; dort zaehlen die
        -- party-Einheiten. GetNumGroupMembers zaehlt den Spieler mit.
        for index = 1, math.max(0, (GetNumGroupMembers() or 0) - 1) do
            local unit = "party" .. index
            if UnitExists and UnitExists(unit) then
                local _, classFile = UnitClass(unit)
                MarkPresent(UnitName(unit), classFile)
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
    GC:FireCallback("RAID_SESSION_UPDATED")
    return self.session
end

function GC.RaidMonitor:BeginSession()
    if self.session then
        return false, "Es läuft bereits eine Sitzung."
    end
    if not self:CanControlSession() then
        return false, "Nur Raidleiter, Assistenten und berechtigte Gildenränge dürfen eine Sitzung starten."
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
        return false, "Nur Raidleiter, Assistenten und berechtigte Gildenränge dürfen eine Sitzung beenden."
    end

    local summary = self:FinishSession(GC.Util.Now())
    if summary then
        GC.Sync:AnnounceSessionEnd(summary)
        GC.Sync:DistributeSummary(summary, "RAID")
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
    local now = endedAt
    for _, participant in pairs(session.participants) do
        if participant.presentSince then
            participant.seconds = participant.seconds + (now - participant.presentSince)
            participant.presentSince = nil
        end
    end

    local summary = self:BuildSummary(session, endedAt)
    self.session = nil
    self:SetCombatLogTracking(false)
    self:StoreSummary(summary)
    GC:FireCallback("RAID_SESSION_UPDATED")
    return summary
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
        if stored.id == summary.id then
            -- Live-, Sync- und WCL-Daten bleiben getrennt und werden nie
            -- ineinander verrechnet.
            if stored.source ~= summary.source then
                return false
            end
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
function GC.RaidMonitor:DeleteEvening(sessionID)
    if not GC.Roster:CanAccessMemberCare() then
        return false, "Nur die in den Einstellungen freigegebenen Ränge dürfen Auswertungen löschen."
    end
    local evening = self:GetEveningOf(sessionID)
    if not evening then
        return false, "Keine Auswertung gewählt."
    end
    local drop = {}
    local dropped = 0
    for _, summary in ipairs(evening.sources) do
        drop[summary.id] = true
        dropped = dropped + 1
    end
    local sessions = GC.DB:GetGuild().raidSessions
    for index = #sessions, 1, -1 do
        if drop[sessions[index].id] then
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

function GC.RaidMonitor:GetSummary(sessionID)
    for _, summary in ipairs(self:GetSummaries()) do
        if summary.id == sessionID then
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

function GC.RaidMonitor:GetEveningOf(sessionID)
    for _, evening in ipairs(self:GetEvenings()) do
        for _, summary in ipairs(evening.sources) do
            if summary.id == sessionID then
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
    elseif segment.lastNPCDeath then
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

-- Essen laesst sich nicht ueber Zauber-IDs erfassen: Jedes Gericht hat eine
-- eigene, und es gibt Dutzende. Gemeinsam ist ihnen der Name der Aura, die sie
-- setzen. Ueber den wird erkannt, was keine Liste je vollstaendig abbilden
-- wuerde.
local WELL_FED_AURAS = {
    ["sattgegessen"] = true,
    ["well fed"] = true,
}

local function ResolveConsumable(spellID, spellName, isAura)
    local consumable = GC.Consumables[tonumber(spellID) or 0]
    if consumable then
        return consumable.category
    end
    -- Die Sattgegessen-Aura ist immer eine Aura, nie ein gewirkter Zauber.
    -- Cast-Ereignisse sparen sich damit das Kleinschreiben des Namens - im
    -- Raid ist der unbekannte Cast der haeufigste Fall dieser Funktion.
    if isAura and WELL_FED_AURAS[tostring(spellName or ""):lower()] then
        return "FOOD"
    end
    return nil
end

local function CountConsumable(monitor, session, playerName, spellID, spellName, isAura)
    local categoryKey = ResolveConsumable(spellID, spellName, isAura)
    if not categoryKey then
        return
    end
    local participant = monitor:FindParticipant(session, playerName)
    if not participant then
        return
    end

    local category = GC.ConsumableCategoryByKey[categoryKey]
    if not category then
        return
    end
    if not category.repeatable then
        -- Ohne ID - also bei ueber den Namen erkanntem Essen - haelt der
        -- Kategorieschluessel den Platz, sonst zaehlte jede Aktualisierung
        -- der Aura erneut.
        local seenKey = tonumber(spellID) or categoryKey
        if participant.seenConsumables[seenKey] then
            return
        end
        participant.seenConsumables[seenKey] = true
    end
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
    local consumable = GC.Consumables[tonumber(spellID) or 0]
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
            session.segment.lastNPCDeath = SanitizedText(destName, 36)
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
        -- Auswertung nicht an einem einzelnen Client hängt.
        if not self.session and distribution ~= "WHISPER" then
            self:StartSession(fields[3], sender, tonumber(fields[4]), fields[5])
            -- Sichtbar wie ein Gildenauftrag (Owner-Wunsch): Die Meldung
            -- nutzt denselben Banner samt Ein/Aus-Schalter und Position.
            GC:FireCallback("ORDERS_BANNER",
                "Raidsitzung gestartet von " .. GC.Util.PlayerShortName(sender))
        end
        return true
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

raidEvents:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Der Rahmen und die dauerhaften Ereignisse stehen oben in der Datei, damit
-- StartSession und FinishSession das Combat-Log-Abo umschalten koennen.
raidEvents:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        GC.RaidMonitor:OnZoneEntered()
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
