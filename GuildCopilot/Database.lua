local _, GC = ...

local DEFAULTS = {
    schemaVersion = GC.Constants.SCHEMA_VERSION,
    settings = {
        successSound = true,
        successSoundKey = "READY_CHECK",
        captureOnlyDuringSearch = true,
        watchRecruitmentTriggers = true,
        minimap = {
            hidden = false,
            angle = 225,
        },
        workshopFavorites = {},
        postCooldown = GC.Constants.DEFAULT_POST_COOLDOWN,
        lfgCooldown = GC.Constants.DEFAULT_LFG_COOLDOWN,
        channels = {
            RECRUITMENT = true,
            LFG = false,
            TRADE = false,
            GENERAL = false,
        },
    },
    characters = {},
    guilds = {},
}

local GUILD_DEFAULTS = {
    editorRecoveryAvailable = true,
    profile = {
        description = "",
        raidTimes = "",
        progress = "SSC/TK",
        lootSystem = "",
        discord = "",
        contact = "",
        updatedAt = 0,
    },
    profilePermissions = {
        configured = false,
        editorRanks = {},
    },
    replyTemplates = {
        THANKS = "Hallo {name}, danke für dein Interesse an unserer Gilde! Was spielst du, und wonach suchst du?",
        INFO = "{beschreibung} Raidzeiten: {raidzeiten}. Lootsystem: {loot}. Progress: {progress}.",
        DISCORD = "Wenn du magst, lernen wir uns kurz im Discord kennen: {discord}",
    },
    remoteProfiles = {},
    addonUsers = {},
    recruitment = {
        selections = {},
        raidMarker = 8,
        replyMarker = 0,
        classOrder = {},
        priorities = {},
    },
    inbox = {},
    postHistory = {},
    lastPosts = {},
    warcraftLogs = {
        url = "",
        region = "",
        serverSlug = "",
        guildSlug = "",
        importedAt = 0,
        members = {},
        reportCount = 0,
    },
    workshop = {
        crafters = {},
    },
    raidSessions = {},
    gearAudits = {},
    memberCare = {
        inactivityDays = 60,
        protectedRanksConfigured = false,
        protectedRanks = {},
        accessRanksConfigured = false,
        accessRanks = {},
        decisions = {},
    },
    roster = {
        rankFilterConfigured = false,
        activeRaiderRanks = {},
    },
}

GC.DB = {}

function GC.DB:Initialize()
    local previousSchema = type(GuildCopilotDB) == "table" and tonumber(GuildCopilotDB.schemaVersion) or 0
    GuildCopilotDB = GC.Util.MergeDefaults(GuildCopilotDB, DEFAULTS)
    if GuildCopilotDB.settings.successSoundKey == "UI_GROUP_FINDER_RECEIVE_APPLICATION" then
        GuildCopilotDB.settings.successSoundKey = "GROUP_FINDER"
    end

    if previousSchema < 2 then
        GuildCopilotDB.settings.channels.RECRUITMENT = true
        GuildCopilotDB.settings.channels.LFG = false
        GuildCopilotDB.settings.channels.TRADE = false
        GuildCopilotDB.settings.channels.GENERAL = false
        GuildCopilotDB.settings.postCooldown = GC.Constants.DEFAULT_POST_COOLDOWN
        GuildCopilotDB.settings.lfgCooldown = GC.Constants.DEFAULT_LFG_COOLDOWN
    end

    local legacyEditorRecovery = GuildCopilotDB.settings.editorRecoveryAvailable
    if legacyEditorRecovery ~= nil then
        for _, guildData in pairs(GuildCopilotDB.guilds or {}) do
            if guildData.editorRecoveryAvailable == nil then
                guildData.editorRecoveryAvailable = legacyEditorRecovery
            end
        end
        GuildCopilotDB.settings.editorRecoveryAvailable = nil
    end

    if previousSchema < 3 then
        for _, profile in pairs(GuildCopilotDB.characters or {}) do
            if profile.secondarySpecKey == profile.raidSpecKey then
                profile.secondarySpecKey = nil
            end
        end
    end

    if previousSchema < 4 then
        for _, profile in pairs(GuildCopilotDB.characters or {}) do
            profile.professions = profile.professions or {}
            if profile.professionAuto == nil then
                profile.professionAuto = true
            end
        end
    end

    if previousSchema < 5 then
        for _, profile in pairs(GuildCopilotDB.characters or {}) do
            profile.workshop = profile.workshop or { professions = {} }
            profile.workshop.professions = profile.workshop.professions or {}
        end
    end

    GuildCopilotDB.schemaVersion = GC.Constants.SCHEMA_VERSION
    self.data = GuildCopilotDB
end

function GC.DB:Get()
    return self.data
end

function GC.DB:GetSettings()
    return self.data.settings
end

function GC.DB:GetCharacter(characterKey)
    characterKey = characterKey or GC:GetPlayerFullName()
    self.data.characters[characterKey] = self.data.characters[characterKey] or {}
    return self.data.characters[characterKey]
end

function GC.DB:GetGuild()
    local guildKey = GC:GetGuildKey()
    self.data.guilds[guildKey] = GC.Util.MergeDefaults(self.data.guilds[guildKey], GUILD_DEFAULTS)
    return self.data.guilds[guildKey]
end

function GC.DB:Prune()
    local guildData = self:GetGuild()
    local cutoff = GC.Util.Now() - (180 * 24 * 60 * 60)
    for name, profile in pairs(guildData.remoteProfiles) do
        if (profile.receivedAt or 0) < cutoff then
            guildData.remoteProfiles[name] = nil
        end
    end
    local addonUserCutoff = GC.Util.Now() - GC.Constants.ADDON_USER_TTL
    for name, addonUser in pairs(guildData.addonUsers or {}) do
        if (addonUser.seenAt or 0) < addonUserCutoff then
            guildData.addonUsers[name] = nil
        end
    end
    for name, crafter in pairs(guildData.workshop.crafters or {}) do
        if (crafter.updatedAt or 0) < cutoff then
            guildData.workshop.crafters[name] = nil
        end
    end

    local sessionCutoff = GC.Util.Now() - (30 * 24 * 60 * 60)
    for index = #guildData.raidSessions, 1, -1 do
        if (guildData.raidSessions[index].endedAt or 0) < sessionCutoff then
            table.remove(guildData.raidSessions, index)
        end
    end

    while #guildData.inbox > 100 do
        table.remove(guildData.inbox)
    end
    while #guildData.postHistory > 50 do
        table.remove(guildData.postHistory)
    end
end

GC:RegisterCallback("ADDON_LOADED", GC.DB, function(self)
    self:Initialize()
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.DB, function(self)
    self:Prune()
end)
