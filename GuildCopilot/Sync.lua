local _, GC = ...

GC.Sync = {
    registered = false,
    sendPending = false,
    guildProfileSendPending = false,
    guildProfileForceSend = false,
    guildProfileIncoming = {},
    lastAnnounceAt = 0,
}

-- Der Handshake läuft bewusst ohne Dauerbroadcast: gesendet wird nur beim
-- Login, beim Betreten einer Gruppe und als Antwort auf eine Anfrage. Beide
-- Mindestabstände verhindern, dass mehrere gleichzeitige Logins den
-- Addon-Kanal fluten.
local MIN_ANNOUNCE_INTERVAL = 60
local MIN_REPLY_INTERVAL = 15
local MIN_PROFILE_REPLY_INTERVAL = 30

local function BoolField(value)
    return value and "1" or "0"
end

local function SortedEnabledRanks(values)
    local ranks = {}
    for rankIndex, enabled in pairs(values or {}) do
        if enabled then
            ranks[#ranks + 1] = tonumber(rankIndex) or rankIndex
        end
    end
    table.sort(ranks, function(left, right)
        return tonumber(left) < tonumber(right)
    end)
    for index, rank in ipairs(ranks) do
        ranks[index] = tostring(rank)
    end
    return ranks
end

-- Entscheidungen als "name:status:datum", getrennt durch Komma. Das Feld hängt
-- am Ende der Gildenprofil-Nutzlast, damit ältere Clients es schlicht
-- ignorieren; fehlt es beim Empfang, bleiben die eigenen Einträge stehen.
local function EncodeMemberCareDecisions(decisions)
    local records = {}
    for _, decision in pairs(decisions or {}) do
        local name = GC.Util.Trim(decision.name):gsub("[,:|]", "")
        if name ~= "" and GC.MemberCareDecisions[decision.status] then
            records[#records + 1] = table.concat({
                name,
                decision.status,
                decision.until_ or "",
            }, ":")
        end
    end
    table.sort(records)
    while #records > GC.MemberCareMaxDecisions do
        table.remove(records)
    end
    return table.concat(records, ",")
end

local function DecodeMemberCareDecisions(payload)
    local decisions = {}
    for record in tostring(payload or ""):gmatch("[^,]+") do
        local name, status, untilDate = record:match("^([^:]+):([^:]+):?([^:]*)$")
        if name and GC.MemberCareDecisions[status] then
            decisions[GC.Util.NormalizeName(name)] = {
                name = name,
                status = status,
                until_ = untilDate or "",
                at = GC.Util.Now(),
            }
        end
    end
    return decisions
end

-- Nur ID und Stufe wandern durch die Gilde; den Namen loest jeder Client in
-- seiner eigenen Sprache aus dem Tooltip auf.
local VERDICT_CODES = { OPTIMAL = "O", SOLID = "S", IMPROVABLE = "V" }
local VERDICT_BY_CODE = { O = "OPTIMAL", S = "SOLID", V = "IMPROVABLE" }

local function EncodeEnchantRules(rules)
    local records = {}
    for enchantID, rule in pairs(rules or {}) do
        local code = VERDICT_CODES[rule.verdict]
        if code and tonumber(enchantID) then
            records[#records + 1] = tostring(tonumber(enchantID)) .. ":" .. code
        end
    end
    table.sort(records)
    while #records > 80 do
        table.remove(records)
    end
    return table.concat(records, ",")
end

local function DecodeEnchantRules(payload)
    local rules = {}
    for record in tostring(payload or ""):gmatch("[^,]+") do
        local enchantID, code = record:match("^(%d+):(%a)$")
        if enchantID and VERDICT_BY_CODE[code] then
            rules[enchantID] = {
                verdict = VERDICT_BY_CODE[code],
                name = "",
                by = "",
                at = GC.Util.Now(),
            }
        end
    end
    return rules
end

function GC.Sync:RegisterPrefix()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        self.registered = C_ChatInfo.RegisterAddonMessagePrefix(GC.Constants.COMM_PREFIX) == true
    elseif RegisterAddonMessagePrefix then
        self.registered = RegisterAddonMessagePrefix(GC.Constants.COMM_PREFIX) == true
    end
end

function GC.Sync:Send(payload, distribution, target)
    distribution = distribution or "GUILD"
    if not payload or #payload > GC.Constants.MAX_CHAT_BYTES then
        return false
    end
    if distribution == "GUILD" and (not IsInGuild or not IsInGuild()) then
        return false
    end
    if distribution == "WHISPER" and GC.Util.Trim(target) == "" then
        return false
    end

    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        local success, result = pcall(
            C_ChatInfo.SendAddonMessage,
            GC.Constants.COMM_PREFIX,
            payload,
            distribution,
            target
        )
        return success and result ~= false
    elseif SendAddonMessage then
        local success, result = pcall(
            SendAddonMessage,
            GC.Constants.COMM_PREFIX,
            payload,
            distribution,
            target
        )
        return success and result ~= false
    end
    return false
end

function GC.Sync:BuildProfileMessage()
    local profile = GC.Profile:Get()
    local professions = profile.professions or {}
    local profession1 = professions[1] or {}
    local profession2 = professions[2] or {}
    local absence = profile.absence or {}
    local fields = {
        "P",
        tostring(GC.Constants.SCHEMA_VERSION),
        profile.classFile or "",
        profile.detectedSpecKey or "",
        profile.talentSignature or "",
        profile.raidSpecKey or "",
        profile.secondarySpecKey or "",
        profile.mainStatus or "MAIN",
        BoolField(profile.flex),
        BoolField(profile.confirmed),
        profession1.name or "",
        profession1.skillLevel and (profession1.skillLevel .. "/" .. (profession1.maxSkillLevel or 0)) or "",
        profession2.name or "",
        profession2.skillLevel and (profession2.skillLevel .. "/" .. (profession2.maxSkillLevel or 0)) or "",
        tostring(profile.updatedAt or GC.Util.Now()),
        absence.from or "",
        absence.to or "",
        absence.reason or "",
    }
    for index, value in ipairs(fields) do
        fields[index] = GC.Util.EscapeField(value)
    end
    return table.concat(fields, "|")
end

function GC.Sync:SendProfile()
    self.sendPending = false
    self:Send(self:BuildProfileMessage())
end

function GC.Sync:QueueProfile()
    if self.sendPending then
        return
    end
    self.sendPending = true
    C_Timer.After(1, function()
        self:SendProfile()
    end)
end

-- Antwort auf eine Anfrage. Gedrosselt, damit mehrere Logins kurz
-- hintereinander nicht jedes Mal das ganze Profil erneut durch die Gilde
-- schicken; wer neu dazukommt, hat es dann vom letzten Mal noch nicht, deshalb
-- ist das Fenster bewusst kurz gehalten.
function GC.Sync:ReplyWithProfile()
    local now = GC.Util.Now()
    if (now - (self.lastProfileReplyAt or 0)) < MIN_PROFILE_REPLY_INTERVAL then
        return false
    end
    self.lastProfileReplyAt = now
    self:QueueProfile()
    return true
end

function GC.Sync:BuildGuildProfileMessages()
    local guildData = GC.DB:GetGuild()
    local profile = guildData.profile
    local permissions = guildData.profilePermissions
    local templates = guildData.replyTemplates
    local memberCare = guildData.memberCare
    local roster = guildData.roster
    local fields = {
        "GP",
        tostring(profile.updatedAt or 0),
        profile.description or "",
        profile.raidTimes or "",
        profile.progress or "",
        profile.lootSystem or "",
        profile.discord or "",
        profile.contact or "",
        BoolField(permissions.configured),
        table.concat(SortedEnabledRanks(permissions.editorRanks), ","),
        templates.THANKS or "",
        templates.INFO or "",
        templates.DISCORD or "",
        tostring(memberCare.inactivityDays or 60),
        BoolField(memberCare.protectedRanksConfigured),
        table.concat(SortedEnabledRanks(memberCare.protectedRanks), ","),
        BoolField(memberCare.accessRanksConfigured),
        table.concat(SortedEnabledRanks(memberCare.accessRanks), ","),
        BoolField(roster.rankFilterConfigured),
        table.concat(SortedEnabledRanks(roster.activeRaiderRanks), ","),
        EncodeMemberCareDecisions(memberCare.decisions),
        EncodeEnchantRules(guildData.enchantRules),
    }
    for index, value in ipairs(fields) do
        fields[index] = GC.Util.EscapeField(value)
    end
    local payload = table.concat(fields, "|")
    local chunks = {}
    local chunkSize = 175
    for offset = 1, #payload, chunkSize do
        chunks[#chunks + 1] = payload:sub(offset, offset + chunkSize - 1)
    end
    local token = tostring(GC.Util.Now()) .. tostring(math.random(1000, 9999))
    local messages = {}
    for index, chunk in ipairs(chunks) do
        messages[index] = table.concat({
            "G",
            tostring(GC.Constants.SCHEMA_VERSION),
            token,
            tostring(index),
            tostring(#chunks),
            chunk,
        }, "|")
    end
    return messages
end

function GC.Sync:SendGuildProfile(force)
    self.guildProfileSendPending = false
    force = force == true or self.guildProfileForceSend
    self.guildProfileForceSend = false
    if not force and not GC.Roster:CanEditGuildProfile() then
        return false
    end
    local messages = self:BuildGuildProfileMessages()
    local index = 1
    local retries = 0
    local function SendNext()
        local message = messages[index]
        if not message then
            return
        end
        local sent = self:Send(message)
        if sent then
            index = index + 1
            retries = 0
        else
            retries = retries + 1
            if retries >= 5 then
                return
            end
        end
        if messages[index] then
            C_Timer.After(sent and 0.45 or 1.25, SendNext)
        end
    end
    SendNext()
    return true
end

function GC.Sync:QueueGuildProfile(force)
    self.guildProfileForceSend = self.guildProfileForceSend or force == true
    if self.guildProfileSendPending then
        return
    end
    self.guildProfileSendPending = true
    C_Timer.After(0.6, function()
        self:SendGuildProfile()
    end)
end

function GC.Sync:ReceiveGuildProfileChunk(message, sender)
    if not GC.Roster:CanEditGuildProfile(sender) then
        return
    end
    local schemaText, token, indexText, totalText, chunk =
        message:match("^G|([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.*)$")
    local schemaVersion = tonumber(schemaText)
    local index = tonumber(indexText)
    local total = tonumber(totalText)
    if schemaVersion ~= GC.Constants.SCHEMA_VERSION
        or not index or not total or index < 1 or index > total or total > 30 then
        return
    end

    local incomingKey = GC.Util.NormalizeName(sender) .. "|" .. token
    local incoming = self.guildProfileIncoming[incomingKey]
    if not incoming or incoming.total ~= total then
        incoming = {
            total = total,
            chunks = {},
            receivedAt = GC.Util.Now(),
        }
        self.guildProfileIncoming[incomingKey] = incoming
    end
    incoming.chunks[index] = chunk

    local payloadParts = {}
    for chunkIndex = 1, total do
        if incoming.chunks[chunkIndex] == nil then
            return
        end
        payloadParts[chunkIndex] = incoming.chunks[chunkIndex]
    end
    self.guildProfileIncoming[incomingKey] = nil

    local fields = GC.Util.SplitFields(table.concat(payloadParts))
    if fields[1] ~= "GP" then
        return
    end
    local updatedAt = tonumber(fields[2]) or 0
    local guildData = GC.DB:GetGuild()
    if updatedAt < (tonumber(guildData.profile.updatedAt) or 0) then
        return
    end

    guildData.profile.description = fields[3] or ""
    guildData.profile.raidTimes = fields[4] or ""
    guildData.profile.progress = fields[5] or ""
    guildData.profile.lootSystem = fields[6] or ""
    guildData.profile.discord = fields[7] or ""
    guildData.profile.contact = fields[8] or ""
    guildData.profile.updatedAt = updatedAt
    guildData.profilePermissions.configured = fields[9] == "1"
    guildData.profilePermissions.editorRanks = {}
    for rankIndex in tostring(fields[10] or ""):gmatch("[^,]+") do
        guildData.profilePermissions.editorRanks[tostring(tonumber(rankIndex) or rankIndex)] = true
    end
    guildData.replyTemplates.THANKS = fields[11] or ""
    guildData.replyTemplates.INFO = fields[12] or ""
    guildData.replyTemplates.DISCORD = fields[13] or ""
    guildData.memberCare.inactivityDays = math.max(7, math.min(365, tonumber(fields[14]) or 60))
    guildData.memberCare.protectedRanksConfigured = fields[15] == "1"
    guildData.memberCare.protectedRanks = {}
    for rankIndex in tostring(fields[16] or ""):gmatch("[^,]+") do
        guildData.memberCare.protectedRanks[tostring(tonumber(rankIndex) or rankIndex)] = true
    end
    guildData.memberCare.accessRanksConfigured = fields[17] == "1"
    guildData.memberCare.accessRanks = {}
    for rankIndex in tostring(fields[18] or ""):gmatch("[^,]+") do
        guildData.memberCare.accessRanks[tostring(tonumber(rankIndex) or rankIndex)] = true
    end
    guildData.roster.rankFilterConfigured = fields[19] == "1"
    guildData.roster.activeRaiderRanks = {}
    for rankIndex in tostring(fields[20] or ""):gmatch("[^,]+") do
        guildData.roster.activeRaiderRanks[tostring(tonumber(rankIndex) or rankIndex)] = true
    end
    -- Ältere Absender senden das Feld nicht; dann bleiben die eigenen
    -- Entscheidungen unangetastet statt gelöscht zu werden.
    if fields[21] ~= nil then
        guildData.memberCare.decisions = DecodeMemberCareDecisions(fields[21])
    end
    if fields[22] ~= nil then
        guildData.enchantRules = DecodeEnchantRules(fields[22])
        if GC.GearAudit then
            GC.GearAudit:ReapplyEnchantRules()
        end
    end
    GC:FireCallback("GUILD_PROFILE_UPDATED", sender)
    GC:FireCallback("SETTINGS_UPDATED")
end

function GC.Sync:RequestGuildProfile()
    self:Send("GQ|" .. tostring(GC.Constants.SCHEMA_VERSION))
end

function GC.Sync:ReceiveProfile(fields, sender)
    local schemaVersion = tonumber(fields[2]) or 0
    local classFile = fields[3]
    local detectedSpecKey = fields[4] ~= "" and fields[4] or nil
    local raidSpecKey = fields[6] ~= "" and fields[6] or nil
    local secondarySpecKey
    local statusIndex = 7
    if schemaVersion >= 3 then
        secondarySpecKey = fields[7] ~= "" and fields[7] or nil
        statusIndex = 8
    end
    if not GC.Classes[classFile] then
        return
    end
    if detectedSpecKey and (not GC.SpecByKey[detectedSpecKey] or GC.SpecByKey[detectedSpecKey].classFile ~= classFile) then
        return
    end
    if raidSpecKey and (not GC.SpecByKey[raidSpecKey] or GC.SpecByKey[raidSpecKey].classFile ~= classFile) then
        return
    end
    if secondarySpecKey and (not GC.SpecByKey[secondarySpecKey] or GC.SpecByKey[secondarySpecKey].classFile ~= classFile) then
        return
    end
    if secondarySpecKey == raidSpecKey then
        secondarySpecKey = nil
    end

    local updatedAtIndex = statusIndex + 3
    local professions = {}
    if schemaVersion >= 4 then
        local function ReadSyncedProfession(name, skillText)
            if name == "" then
                return nil
            end
            local skillLevel, maxSkillLevel = tostring(skillText or ""):match("^(%d+)/(%d+)$")
            return {
                name = name,
                skillLevel = tonumber(skillLevel) or 0,
                maxSkillLevel = tonumber(maxSkillLevel) or 0,
            }
        end
        professions[1] = ReadSyncedProfession(fields[statusIndex + 3], fields[statusIndex + 4])
        professions[2] = ReadSyncedProfession(fields[statusIndex + 5], fields[statusIndex + 6])
        updatedAtIndex = statusIndex + 7
    end

    local profile = {
        fullName = sender,
        classFile = classFile,
        detectedSpecKey = detectedSpecKey,
        talentSignature = fields[5],
        raidSpecKey = raidSpecKey,
        secondarySpecKey = secondarySpecKey,
        mainStatus = fields[statusIndex] == "ALT" and "ALT" or "MAIN",
        flex = fields[statusIndex + 1] == "1",
        confirmed = fields[statusIndex + 2] == "1",
        professions = professions,
        updatedAt = tonumber(fields[updatedAtIndex]) or GC.Util.Now(),
        receivedAt = GC.Util.Now(),
    }
    if schemaVersion >= 6 then
        profile.absence = {
            from = fields[updatedAtIndex + 1] or "",
            to = fields[updatedAtIndex + 2] or "",
            reason = fields[updatedAtIndex + 3] or "",
        }
    else
        profile.absence = {
            from = "",
            to = "",
            reason = "",
        }
    end
    local key = GC.Util.NormalizeName(sender)
    local shortKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(sender))
    local profiles = GC.DB:GetGuild().remoteProfiles
    profiles[key] = profile
    profiles[shortKey] = profile
    GC:FireCallback("ROSTER_UPDATED")
end

function GC.Sync:BuildVersionMessage(requestReply)
    local fields = {
        "V",
        tostring(GC.Constants.SCHEMA_VERSION),
        GC.Constants.VERSION,
        table.concat(GC.Capabilities, ","),
        BoolField(requestReply),
    }
    for index, value in ipairs(fields) do
        fields[index] = GC.Util.EscapeField(value)
    end
    return table.concat(fields, "|")
end

function GC.Sync:AnnounceVersion(requestReply, minimumInterval)
    minimumInterval = tonumber(minimumInterval) or 0
    local now = GC.Util.Now()
    if minimumInterval > 0 and (now - (self.lastAnnounceAt or 0)) < minimumInterval then
        return false
    end
    if not self:Send(self:BuildVersionMessage(requestReply)) then
        return false
    end
    self.lastAnnounceAt = now
    return true
end

function GC.Sync:NoteAddonUser(sender, info)
    if GC.Util.Trim(sender) == "" then
        return false
    end
    info = info or {}

    local guildData = GC.DB:GetGuild()
    local key = GC.Util.NormalizeName(sender)
    local shortKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(sender))
    local entry = guildData.addonUsers[key] or guildData.addonUsers[shortKey]
    local changed = entry == nil
    entry = entry or {}

    local schemaVersion = tonumber(info.schemaVersion)
    if schemaVersion and entry.schemaVersion ~= schemaVersion then
        entry.schemaVersion = schemaVersion
        changed = true
    end
    local version = GC.Util.Trim(info.version)
    if version ~= "" and entry.version ~= version then
        entry.version = version
        changed = true
    end
    local capabilities = GC.Util.Trim(info.capabilities)
    if capabilities ~= "" and entry.capabilities ~= capabilities then
        entry.capabilities = capabilities
        changed = true
    end
    if info.source == "HANDSHAKE" and not entry.handshake then
        entry.handshake = true
        changed = true
    end

    entry.name = sender
    entry.seenAt = GC.Util.Now()
    guildData.addonUsers[key] = entry
    guildData.addonUsers[shortKey] = entry
    if changed then
        GC:FireCallback("ADDON_USERS_UPDATED")
    end
    return changed
end

function GC.Sync:ReceiveVersion(fields, sender)
    local schemaVersion = tonumber(fields[2])
    if not schemaVersion then
        return
    end
    self:NoteAddonUser(sender, {
        schemaVersion = schemaVersion,
        version = fields[3],
        capabilities = fields[4],
        source = "HANDSHAKE",
    })

    -- Nur auf ausdrückliche Anfragen antworten, niemals auf eine Antwort.
    if fields[5] == "1" then
        C_Timer.After(0.5 + math.random() * 4, function()
            self:AnnounceVersion(false, MIN_REPLY_INTERVAL)
        end)
        -- Das eigene Profil gleich mitschicken. Ohne diese Antwort erfaehrt ein
        -- Client nur von denen etwas, die sich nach ihm einloggen oder ihr
        -- Profil aendern: Wer zuerst da war, hat laengst in einen leeren Raum
        -- gesendet. Eigenes Fenster mit breiterer Streuung, damit bei vielen
        -- gleichzeitig Antwortenden der Addon-Kanal nicht zulaeuft.
        C_Timer.After(1 + math.random() * 9, function()
            self:ReplyWithProfile()
        end)
    end
end

function GC.Sync:GetAddonUser(name)
    local addonUsers = GC.DB:GetGuild().addonUsers
    return addonUsers[GC.Util.NormalizeName(name)]
        or addonUsers[GC.Util.NormalizeName(GC.Util.PlayerShortName(name))]
end

function GC.Sync:GetAddonUserStats()
    local stats = {
        known = 1,
        compatible = 1,
        outdated = 0,
        ahead = 0,
        outdatedNames = {},
    }

    -- Ausgetretene Mitglieder erst ausblenden, wenn das Roster gelesen ist;
    -- direkt nach dem Login ist es noch leer.
    local rosterReady = #GC.Roster.members > 0
    local seen = {}
    for _, entry in pairs(GC.DB:GetGuild().addonUsers or {}) do
        if not seen[entry] and (not rosterReady or GC.Roster:IsGuildMember(entry.name)) then
            seen[entry] = true
            stats.known = stats.known + 1
            local schemaVersion = tonumber(entry.schemaVersion) or 0
            if schemaVersion == GC.Constants.SCHEMA_VERSION then
                stats.compatible = stats.compatible + 1
            elseif schemaVersion > GC.Constants.SCHEMA_VERSION then
                stats.ahead = stats.ahead + 1
                stats.outdatedNames[#stats.outdatedNames + 1] = GC.Util.PlayerShortName(entry.name)
            else
                stats.outdated = stats.outdated + 1
                stats.outdatedNames[#stats.outdatedNames + 1] = GC.Util.PlayerShortName(entry.name)
            end
        end
    end
    table.sort(stats.outdatedNames)
    return stats
end

function GC.Sync:AnnounceSessionStart(session)
    return self:Send(table.concat({
        "RS",
        tostring(GC.Constants.SCHEMA_VERSION),
        session.id,
        tostring(session.startedAt),
        GC.Util.EscapeField(session.zone or ""),
    }, "|"), "RAID")
end

function GC.Sync:AnnounceSessionEnd(summary)
    return self:Send(table.concat({
        "RE",
        tostring(GC.Constants.SCHEMA_VERSION),
        summary.id,
        tostring(summary.endedAt),
    }, "|"), "RAID")
end

-- Die Zusammenfassung geht gedrosselt und in Teilen raus; fehlgeschlagene
-- Pakete werden begrenzt wiederholt, damit keine Lücke entsteht.
function GC.Sync:DistributeSummary(summary, distribution, target)
    local messages = GC.RaidMonitor:BuildSummaryMessages(summary)
    local index = 1
    local retries = 0
    local function SendNext()
        local message = messages[index]
        if not message then
            return
        end
        local sent = self:Send(message, distribution or "RAID", target)
        if sent then
            index = index + 1
            retries = 0
        else
            retries = retries + 1
            if retries >= 5 then
                return
            end
        end
        if messages[index] then
            C_Timer.After(sent and 0.5 or 1.5, SendNext)
        end
    end
    SendNext()
    return #messages
end

function GC.Sync:OnMessage(prefix, message, distribution, sender)
    if prefix ~= GC.Constants.COMM_PREFIX then
        return
    end
    if GC.Util.NormalizeName(sender) == GC.Util.NormalizeName(GC:GetPlayerFullName()) then
        return
    end

    -- Raidauswertungen laufen über den Raid- und den Flüsterkanal, damit sie
    -- nicht über den offenen Gildenkanal gehen.
    if distribution == "RAID" or distribution == "PARTY" or distribution == "WHISPER" then
        if GC.RaidMonitor then
            GC.RaidMonitor:OnMessage(message, sender, distribution)
        end
        return
    end
    if distribution ~= "GUILD" then
        return
    end

    -- Ältere Clients kennen den Handshake nicht. Ihre Schemaversion steht aber
    -- in jedem P-, W-, G- und GQ-Paket, sodass sie trotzdem als Addon-Nutzer
    -- mit abweichender Version sichtbar werden.
    local messageType, messageSchema = message:match("^(%a+)|(%d+)")
    if messageType == "P" or messageType == "W" or messageType == "G" or messageType == "GQ" then
        self:NoteAddonUser(sender, { schemaVersion = messageSchema, source = "TRAFFIC" })
    end

    if message:sub(1, 2) == "G|" then
        self:ReceiveGuildProfileChunk(message, sender)
        return
    elseif message == ("RQ|" .. tostring(GC.Constants.SCHEMA_VERSION)) then
        if GC.RaidMonitor then
            GC.RaidMonitor:OnMessage(message, sender, distribution)
        end
        return
    elseif message == ("GQ|" .. tostring(GC.Constants.SCHEMA_VERSION)) then
        if GC.Roster:CanEditGuildProfile() then
            C_Timer.After(0.5 + math.random(), function()
                self:SendGuildProfile()
            end)
        end
        return
    end

    local fields = GC.Util.SplitFields(message)
    local schemaVersion = tonumber(fields[2])
    if fields[1] == "P"
        and (schemaVersion == 2 or schemaVersion == 3 or schemaVersion == 4
            or schemaVersion == 5 or schemaVersion == 6
            or schemaVersion == GC.Constants.SCHEMA_VERSION) then
        self:ReceiveProfile(fields, sender)
    elseif fields[1] == "W" and schemaVersion == GC.Constants.SCHEMA_VERSION and GC.Workshop then
        GC.Workshop:ReceiveSync(fields, sender)
    elseif fields[1] == "V" then
        -- Bewusst ohne Schemaprüfung: gerade abweichende Versionen sollen
        -- erkannt werden.
        self:ReceiveVersion(fields, sender)
    end
end

local syncEvents = CreateFrame("Frame")
syncEvents:RegisterEvent("CHAT_MSG_ADDON")
syncEvents:RegisterEvent("GROUP_ROSTER_UPDATE")
syncEvents:SetScript("OnEvent", function(_, event, prefix, message, distribution, sender)
    if event == "GROUP_ROSTER_UPDATE" then
        local inGroup = IsInGroup and IsInGroup() == true
        if inGroup and not GC.Sync.wasInGroup then
            GC.Sync:AnnounceVersion(false, MIN_ANNOUNCE_INTERVAL)
        end
        GC.Sync.wasInGroup = inGroup
        return
    end
    GC.Sync:OnMessage(prefix, message, distribution, sender)
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.Sync, function(self)
    self:RegisterPrefix()
    C_Timer.After(3, function()
        self:QueueProfile()
    end)
    C_Timer.After(5, function()
        if GC.Roster:CanEditGuildProfile() then
            self:QueueGuildProfile()
        else
            self:RequestGuildProfile()
        end
    end)
    C_Timer.After(7, function()
        self.wasInGroup = IsInGroup and IsInGroup() == true
        self:AnnounceVersion(true)
    end)
end)

GC:RegisterCallback("PROFILE_UPDATED", GC.Sync, function(self)
    self:QueueProfile()
end)
