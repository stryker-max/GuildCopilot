local _, GC = ...

GC.WarcraftLogs = {}

local REGION_SLUGS = {
    [1] = "us",
    [2] = "kr",
    [3] = "eu",
    [4] = "tw",
    [5] = "cn",
}

local function DecodePath(value)
    value = tostring(value or ""):gsub("%+", " ")
    return (value:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

local function EncodePath(value)
    value = GC.Util.Trim(value):lower()
    value = value:gsub("ä", "a"):gsub("ö", "o"):gsub("ü", "u"):gsub("ß", "ss")
    value = value:gsub("%s+", "-")
    return (value:gsub("[^%w%-]", function(character)
        return string.format("%%%02X", string.byte(character))
    end))
end

local function PutImportedProfile(members, name, profile)
    local fullKey = GC.Util.NormalizeName(name)
    local shortKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    members[fullKey] = profile
    members[shortKey] = profile
end

local function NormalizeLabel(value)
    value = GC.Util.Trim(value):lower()
    value = value:gsub("ä", "a"):gsub("ö", "o"):gsub("ü", "u"):gsub("ß", "ss")
    return (value:gsub("[^%w]", ""))
end

local function ResolveClass(value)
    local direct = GC.Util.Trim(value):upper()
    if GC.Classes[direct] then
        return direct
    end
    local normalized = NormalizeLabel(value)
    for classFile, classInfo in pairs(GC.Classes) do
        if normalized == NormalizeLabel(classFile)
            or normalized == NormalizeLabel(classInfo.name)
            or normalized == NormalizeLabel(classInfo.plural) then
            return classFile
        end
    end
end

local function ResolveSpec(classFile, value)
    value = GC.Util.Trim(value)
    local direct = value:upper()
    if GC.SpecByKey[direct] and GC.SpecByKey[direct].classFile == classFile then
        return direct
    end
    local normalized = NormalizeLabel(value)
    local classInfo = GC.Classes[classFile]
    for _, spec in ipairs(classInfo and classInfo.specs or {}) do
        if normalized == NormalizeLabel(spec.name) or normalized == NormalizeLabel(spec.recruitLabel) then
            return spec.key
        end
    end
end

function GC.WarcraftLogs:ParseGuildURL(url)
    url = GC.Util.Trim(url)
    local region, serverSlug, guildSlug = url:match("^https?://[^/]*warcraftlogs%.com/guild/([^/]+)/([^/]+)/([^?#]+)")
    if not region then
        region, serverSlug, guildSlug = url:match("^([^/]+)/([^/]+)/(.+)$")
    end
    if not region or not serverSlug or not guildSlug then
        return nil, "Bitte einen gültigen Warcraft-Logs-Gildenlink einfügen."
    end

    region = region:lower()
    serverSlug = serverSlug:lower()
    guildSlug = DecodePath(guildSlug:gsub("/$", ""))
    if region ~= "eu" and region ~= "us" and region ~= "kr" and region ~= "tw" and region ~= "cn" then
        return nil, "Die Region im Warcraft-Logs-Link wird nicht unterstützt."
    end
    return {
        url = "https://fresh.warcraftlogs.com/guild/" .. region .. "/" .. serverSlug .. "/" .. EncodePath(guildSlug),
        region = region,
        serverSlug = serverSlug,
        guildSlug = guildSlug,
    }
end

function GC.WarcraftLogs:GetSuggestedURL()
    local regionID = GetCurrentRegion and GetCurrentRegion() or 3
    local region = REGION_SLUGS[regionID] or "eu"
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName and GetRealmName() or ""
    local guildName = GC:GetGuildName()
    if guildName == "" or realm == "" then
        return ""
    end
    return "https://fresh.warcraftlogs.com/guild/" .. region .. "/" .. EncodePath(realm) .. "/" .. EncodePath(guildName)
end

function GC.WarcraftLogs:SaveSource(url)
    local source, errorMessage = self:ParseGuildURL(url)
    if not source then
        return false, errorMessage
    end
    local data = GC.DB:GetGuild().warcraftLogs
    data.url = source.url
    data.region = source.region
    data.serverSlug = source.serverSlug
    data.guildSlug = source.guildSlug
    GC:FireCallback("WCL_UPDATED")
    return true, "Warcraft-Logs-Gilde gespeichert."
end

-- Der Companion liefert Verbrauchsgegenstände als "Spell-ID:Anzahl". Welche
-- Kategorie dahintersteckt, entscheidet allein GC.Consumables im Addon;
-- unbekannte IDs werden ignoriert und erzeugen so nie falsche Zahlen.
local function DecodeConsumables(payload)
    local counters = {}
    for _, category in ipairs(GC.ConsumableCategories) do
        counters[category.key] = 0
    end

    for token in tostring(payload or ""):gmatch("[^,]+") do
        local spellID, count = token:match("^(%d+):(%d+)$")
        local consumable = spellID and GC.Consumables[tonumber(spellID)]
        local category = consumable and GC.ConsumableCategoryByKey[consumable.category]
        if category then
            count = tonumber(count) or 0
            if category.repeatable then
                counters[category.key] = counters[category.key] + count
            elseif count > 0 then
                -- Dauerhafte Buffs zählen wie in der Livesitzung einmal je Spieler.
                counters[category.key] = 1
            end
        end
    end
    return counters
end

local function ParseSessionLine(line)
    local code, startedAt, endedAt, zone, pulls, kills, wipes =
        line:match("^S|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)$")
    if not code or code == "" then
        return nil
    end
    return {
        id = "WCL:" .. code,
        reportCode = code,
        startedAt = tonumber(startedAt) or 0,
        endedAt = tonumber(endedAt) or 0,
        zone = GC.Util.Trim(zone),
        startedBy = "",
        pulls = tonumber(pulls) or 0,
        kills = tonumber(kills) or 0,
        wipes = tonumber(wipes) or 0,
        participants = {},
        source = "WCL",
        receivedAt = GC.Util.Now(),
    }
end

local function ParseParticipantLine(line)
    local name, classFile, seconds, deaths, interrupts, dispels, consumables =
        line:match("^P|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|?([^|]*)$")
    name = GC.Util.Trim(name)
    if name == "" then
        return nil
    end
    classFile = ResolveClass(classFile)
    return {
        name = name,
        classFile = classFile,
        seconds = math.max(0, tonumber(seconds) or 0),
        deaths = tonumber(deaths) or 0,
        resurrects = 0,
        interrupts = tonumber(interrupts) or 0,
        dispels = tonumber(dispels) or 0,
        consumables = DecodeConsumables(consumables),
    }
end

function GC.WarcraftLogs:Import(text)
    text = tostring(text or ""):gsub("\r", "")
    local headerSeen = false
    local importSource = "MANUAL"
    local imported = {}
    local uniqueCount = 0
    local reportCount = 0

    local sessions = {}
    local currentSession

    for line in (text .. "\n"):gmatch("(.-)\n") do
        line = GC.Util.Trim(line)
        if line ~= "" then
            local marker, reports = line:match("^(GCPWCL[12])|?(%d*)$")
            if marker then
                headerSeen = true
                importSource = "WARCRAFT_LOGS"
                reportCount = tonumber(reports) or 0
            elseif line:sub(1, 2) == "S|" then
                currentSession = ParseSessionLine(line)
                if currentSession then
                    sessions[#sessions + 1] = currentSession
                end
            elseif line:sub(1, 2) == "P|" then
                local participant = currentSession and ParseParticipantLine(line)
                if participant then
                    currentSession.participants[#currentSession.participants + 1] = participant
                end
            else
                local name, classFile, primarySpecKey, secondarySpecKey = line:match("^([^;]+);([^;]+);([^;]*);?([^;]*)$")
                name = GC.Util.Trim(name)
                classFile = ResolveClass(classFile)
                primarySpecKey = ResolveSpec(classFile, primarySpecKey)
                secondarySpecKey = ResolveSpec(classFile, secondarySpecKey)
                if name ~= "" and GC.Classes[classFile]
                    and GC.SpecByKey[primarySpecKey]
                    and GC.SpecByKey[primarySpecKey].classFile == classFile then
                    if not GC.SpecByKey[secondarySpecKey]
                        or GC.SpecByKey[secondarySpecKey].classFile ~= classFile
                        or secondarySpecKey == primarySpecKey then
                        secondarySpecKey = nil
                    end
                    local profile = {
                        fullName = name,
                        classFile = classFile,
                        raidSpecKey = primarySpecKey,
                        secondarySpecKey = secondarySpecKey,
                        confirmed = false,
                        source = importSource,
                        updatedAt = GC.Util.Now(),
                        receivedAt = GC.Util.Now(),
                    }
                    PutImportedProfile(imported, name, profile)
                    uniqueCount = uniqueCount + 1
                end
            end
        end
    end

    if uniqueCount == 0 and #sessions == 0 then
        return false, "Keine gültigen Profile gefunden. Format: Name;Klasse;Primär-Spec;Dual-Spec"
    end

    local data = GC.DB:GetGuild().warcraftLogs
    if uniqueCount > 0 then
        data.members = imported
    end
    data.importedAt = GC.Util.Now()
    data.reportCount = headerSeen and reportCount or 0

    -- Nachanalysen werden als eigene Auswertungen abgelegt und niemals mit
    -- einer Livesitzung verrechnet.
    local storedSessions = 0
    for _, session in ipairs(sessions) do
        if #session.participants > 0 and GC.RaidMonitor:StoreSummary(session) then
            storedSessions = storedSessions + 1
        end
    end
    data.sessionCount = storedSessions

    GC:FireCallback("WCL_UPDATED")
    GC:FireCallback("ROSTER_UPDATED")

    local parts = {}
    if uniqueCount > 0 then
        parts[#parts + 1] = uniqueCount .. (headerSeen and " Warcraft-Logs-Profile" or " Profile")
    end
    if storedSessions > 0 then
        parts[#parts + 1] = storedSessions .. " Raidauswertungen"
    end
    return true, GC.Util.JoinGerman(parts) .. " importiert."
end

function GC.WarcraftLogs:GetImportedCount()
    local data = GC.DB:GetGuild().warcraftLogs
    local seen = {}
    local count = 0
    for _, profile in pairs(data.members or {}) do
        if not seen[profile] then
            seen[profile] = true
            count = count + 1
        end
    end
    return count
end
