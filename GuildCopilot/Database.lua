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
        postBar = {
            hidden = true,
            x = 0,
            y = -220,
        },
        postCooldown = GC.Constants.DEFAULT_POST_COOLDOWN,
        lfgCooldown = GC.Constants.DEFAULT_LFG_COOLDOWN,
        -- Lokale Automatik des Gear Audits. Bewusst nicht gildenweit: Beides
        -- aendert nur, wann geprueft und wie eine unbewertete Verzauberung
        -- angezeigt wird, nie was tatsaechlich in der Ausruestung steckt.
        gearAudit = {
            acceptUnratedEnchants = true,
        },
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
    -- Wer hier steht, erzeugt keinen Postfacheintrag mehr. Leeres "until_"
    -- bedeutet dauerhaft, sonst gilt der Eintrag bis zu diesem Datum.
    inboxFilters = {},
    postHistory = {},
    lastPosts = {},
    warcraftLogs = {
        url = "",
        -- Host der Gildenquelle, damit eine Sprachvariante wie
        -- "de.fresh.warcraftlogs.com" erhalten bleibt.
        host = "",
        region = "",
        serverSlug = "",
        guildSlug = "",
        importedAt = 0,
        members = {},
        reportCount = 0,
        sessionCount = 0,
        -- Wer den zuletzt uebernommenen Rekrutierungsdatensatz geschickt hat.
        lastSyncFrom = "",
    },
    workshop = {
        -- Jedes Rezept steht genau einmal im Katalog; die Crafter halten nur
        -- noch die Schluessel dessen, was sie koennen.
        catalog = {},
        crafters = {},
    },
    -- Die Gildenbank gehoert allen und wird deshalb geteilt - je Tab, weil die
    -- Sichtbarkeit eines Tabs am Gildenrang haengt. Eigene Taschen- und
    -- Bankbestaende bleiben dagegen im Charakterzweig und werden nie gesendet.
    guildBank = {
        tabs = {},
    },
    raidSessions = {},
    gearAudits = {},
    -- Bewertungen ohne Spec-Bezug. Sie gelten fuer alle und sind der
    -- Rueckfall, wenn fuer eine Spec nichts hinterlegt ist.
    enchantRules = {},
    -- Bewertungen je Spec: enchantSpecRules["WARRIOR:1"]["2748"]. Dieselbe
    -- Verzauberung kann fuer Waffen optimal und fuer Schutz verbesserbar sein.
    enchantSpecRules = {},
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
    -- Die Selbstprüfung und ihr Gildenabgleich sind seit 0.9.19 fester
    -- Hintergrunddienst. Ein alter lokaler Schalter darf sie nicht abschalten.
    GuildCopilotDB.settings.gearAudit.auditSelf = nil
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

    -- Ein zufaelliges, anonymes Kennzeichen fuer diesen Account. WoW verraet
    -- Addons nie, welche Charaktere zusammengehoeren; die SavedVariables liegen
    -- aber pro Account, also kann der Client es selbst sagen. Damit zaehlt die
    -- Gildenuebersicht Spieler statt Charaktere. Der Wert traegt keine
    -- Account-Daten, er ist nur eine Zufallsfolge.
    if type(GuildCopilotDB.accountTag) ~= "string" or #GuildCopilotDB.accountTag ~= 10 then
        local alphabet = "0123456789abcdef"
        local tag = {}
        for _ = 1, 10 do
            local index = math.random(#alphabet)
            tag[#tag + 1] = alphabet:sub(index, index)
        end
        GuildCopilotDB.accountTag = table.concat(tag)
    end

    GuildCopilotDB.schemaVersion = GC.Constants.SCHEMA_VERSION
    self.data = GuildCopilotDB
end

function GC.DB:GetAccountTag()
    return type(self.data) == "table" and self.data.accountTag or ""
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
