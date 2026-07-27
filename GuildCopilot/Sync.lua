local _, GC = ...

GC.Sync = {
    registered = false,
    sendPending = false,
    guildProfileSendPending = false,
    guildProfileForceSend = false,
    guildProfileIncoming = {},
}

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

function GC.Sync:RegisterPrefix()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        self.registered = C_ChatInfo.RegisterAddonMessagePrefix(GC.Constants.COMM_PREFIX) == true
    elseif RegisterAddonMessagePrefix then
        self.registered = RegisterAddonMessagePrefix(GC.Constants.COMM_PREFIX) == true
    end
end

function GC.Sync:Send(payload)
    if not IsInGuild or not IsInGuild() or not payload or #payload > GC.Constants.MAX_CHAT_BYTES then
        return false
    end

    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(GC.Constants.COMM_PREFIX, payload, "GUILD")
        return true
    elseif SendAddonMessage then
        SendAddonMessage(GC.Constants.COMM_PREFIX, payload, "GUILD")
        return true
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

function GC.Sync:BuildGuildProfileMessages()
    local guildData = GC.DB:GetGuild()
    local profile = guildData.profile
    local permissions = guildData.profilePermissions
    local templates = guildData.replyTemplates
    local memberCare = guildData.memberCare
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
    local function SendNext()
        local message = messages[index]
        if not message then
            return
        end
        self:Send(message)
        index = index + 1
        if messages[index] then
            C_Timer.After(0.12, SendNext)
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

function GC.Sync:OnMessage(prefix, message, distribution, sender)
    if prefix ~= GC.Constants.COMM_PREFIX or distribution ~= "GUILD" then
        return
    end
    if GC.Util.NormalizeName(sender) == GC.Util.NormalizeName(GC:GetPlayerFullName()) then
        return
    end

    if message:sub(1, 2) == "G|" then
        self:ReceiveGuildProfileChunk(message, sender)
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
            or schemaVersion == 5 or schemaVersion == GC.Constants.SCHEMA_VERSION) then
        self:ReceiveProfile(fields, sender)
    elseif fields[1] == "W" and schemaVersion == GC.Constants.SCHEMA_VERSION and GC.Workshop then
        GC.Workshop:ReceiveSync(fields, sender)
    end
end

local syncEvents = CreateFrame("Frame")
syncEvents:RegisterEvent("CHAT_MSG_ADDON")
syncEvents:SetScript("OnEvent", function(_, _, prefix, message, distribution, sender)
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
end)

GC:RegisterCallback("PROFILE_UPDATED", GC.Sync, function(self)
    self:QueueProfile()
end)
