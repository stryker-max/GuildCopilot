local _, GC = ...

GC.RaidMonitor = {
    session = nil,
    incoming = {},
    lastAnswerAt = 0,
    selectedSessionID = nil,
}

local MAX_STORED_SESSIONS = 12
local MIN_SEGMENT_SECONDS = 15
local WIPE_RATIO = 0.5
local MAX_PAYLOAD_BYTES = 165
local SEND_INTERVAL = 0.5
local MIN_ANSWER_INTERVAL = 30

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
    if IsInRaid then
        return IsInRaid() == true
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
    end
    if classFile and not participant.classFile then
        participant.classFile = classFile
    end
    return participant
end

function GC.RaidMonitor:FindParticipant(session, name)
    if not session or not name then
        return nil
    end
    return session.participants[GC.Util.NormalizeName(GC.Util.PlayerShortName(name))]
end

function GC.RaidMonitor:SyncParticipants()
    local session = self.session
    if not session then
        return
    end

    local now = GC.Util.Now()
    local present = {}
    if self:IsInRaidGroup() and GetNumGroupMembers and GetRaidRosterInfo then
        for index = 1, (GetNumGroupMembers() or 0) do
            local name, _, _, _, _, classFile = GetRaidRosterInfo(index)
            if name then
                local participant = self:GetParticipant(session, name, classFile)
                if participant then
                    present[participant] = true
                    participant.presentSince = participant.presentSince or now
                end
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
    GC:Print("Raidsitzung gestartet. Anwesenheit und Auswertung laufen mit.")
    return true, "Raidsitzung gestartet."
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
    GC:Print("Raidsitzung beendet und ausgewertet.")
    return true, "Raidsitzung beendet."
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

    for _, pull in ipairs(session.pulls) do
        summary.pulls = summary.pulls + 1
        if pull.result == "KILL" then
            summary.kills = summary.kills + 1
        elseif pull.result == "WIPE" then
            summary.wipes = summary.wipes + 1
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
    while #sessions > MAX_STORED_SESSIONS do
        table.remove(sessions)
    end
    GC:FireCallback("RAID_SESSION_UPDATED")
    return true
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

function GC.RaidMonitor:BeginSegment(startedAt)
    local session = self.session
    if not session or session.segment then
        return
    end
    session.segment = {
        startedAt = tonumber(startedAt) or GC.Util.Now(),
        playerDeaths = 0,
        lastNPCDeath = nil,
    }
end

-- Ohne Encounter-API in TBC wird ein Bosskampf heuristisch erkannt: ein
-- Kampfabschnitt ab MIN_SEGMENT_SECONDS gilt als Versuch, benannt nach dem
-- zuletzt gestorbenen Gegner. Sterben mindestens WIPE_RATIO der Anwesenden,
-- zählt der Abschnitt als Wipe.
function GC.RaidMonitor:CloseSegment(endedAt)
    local session = self.session
    local segment = session and session.segment
    if not segment then
        return
    end
    session.segment = nil

    endedAt = tonumber(endedAt) or GC.Util.Now()
    local duration = endedAt - segment.startedAt
    if duration < MIN_SEGMENT_SECONDS then
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
    if presentCount > 0 and segment.playerDeaths >= wipeThreshold then
        result = "WIPE"
    elseif segment.lastNPCDeath then
        result = "KILL"
    end

    session.pulls[#session.pulls + 1] = {
        name = segment.lastNPCDeath or "Kampf",
        startedAt = segment.startedAt,
        endedAt = endedAt,
        result = result,
    }
    GC:FireCallback("RAID_SESSION_UPDATED")
end

local function CountConsumable(monitor, session, playerName, spellID)
    local consumable = GC.Consumables[tonumber(spellID) or 0]
    if not consumable then
        return
    end
    local participant = monitor:FindParticipant(session, playerName)
    if not participant then
        return
    end

    local category = GC.ConsumableCategoryByKey[consumable.category]
    if not category then
        return
    end
    if not category.repeatable then
        if participant.seenConsumables[spellID] then
            return
        end
        participant.seenConsumables[spellID] = true
    end
    participant.consumables[category.key] = (participant.consumables[category.key] or 0) + 1
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

function GC.RaidMonitor:HandleCombatLogEvent(subevent, sourceGUID, sourceName, destGUID, destName, spellID)
    local session = self.session
    if not session or not TRACKED_SUBEVENTS[subevent] then
        return
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
        CountConsumable(self, session, sourceName, spellID)
    elseif subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
        CountConsumable(self, session, destName, spellID)
    end
end

function GC.RaidMonitor:OnCombatLogEvent()
    if not self.session or not CombatLogGetCurrentEventInfo then
        return
    end
    local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID =
        CombatLogGetCurrentEventInfo()
    self:HandleCombatLogEvent(subevent, sourceGUID, sourceName, destGUID, destName, spellID)
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
        or not index or not total or index < 1 or index > total or total > 40 then
        return false
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
    return self:StoreSummary(summary)
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
    return true, "Auswertung angefragt. Berechtigte Mitglieder antworten gleich."
end

function GC.RaidMonitor:AnswerSummaryRequest(requester)
    local summary = self:GetSummaries()[1]
    if not summary then
        return false
    end
    local now = GC.Util.Now()
    if (now - (self.lastAnswerAt or 0)) < MIN_ANSWER_INTERVAL then
        return false
    end
    self.lastAnswerAt = now

    C_Timer.After(1 + math.random() * 4, function()
        GC.Sync:DistributeSummary(summary, "WHISPER", requester)
    end)
    return true
end

local raidEvents = CreateFrame("Frame")
raidEvents:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
raidEvents:RegisterEvent("GROUP_ROSTER_UPDATE")
raidEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
raidEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
raidEvents:SetScript("OnEvent", function(_, event)
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
    end
end)
