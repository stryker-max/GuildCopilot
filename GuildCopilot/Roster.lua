local _, GC = ...

GC.Roster = {
    members = {},
    membersByName = {},
    lastUpdate = 0,
}

local function PutNameIndex(index, name, member)
    if not name or name == "" then
        return
    end
    index[GC.Util.NormalizeName(name)] = member
    index[GC.Util.NormalizeName(GC.Util.PlayerShortName(name))] = member
end

function GC.Roster:Request()
    if not IsInGuild or not IsInGuild() then
        self.members = {}
        self.membersByName = {}
        GC:FireCallback("ROSTER_UPDATED")
        return
    end

    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif GuildRoster then
        GuildRoster()
    end
end

function GC.Roster:Refresh()
    self:Request()
    if C_Timer and C_Timer.After then
        C_Timer.After(1, function()
            self:Scan()
        end)
    else
        self:Scan()
    end
end

function GC.Roster:Scan()
    local members = {}
    local index = {}
    local memberCount = GetNumGuildMembers and GetNumGuildMembers() or 0

    for rosterIndex = 1, memberCount do
        local name, rank, rankIndex, level, className, zone, note, officerNote, online, status, classFile, achievementPoints, achievementRank, isMobile, canSoR, reputation, guid = GetGuildRosterInfo(rosterIndex)
        if name then
            local member = {
                name = name,
                rank = rank,
                rankIndex = rankIndex,
                level = level,
                className = className,
                classFile = classFile,
                zone = zone,
                online = online == true,
                status = status,
                guid = guid,
            }
            if not online and GetGuildRosterLastOnline then
                local ok, years, months, days, hours = pcall(GetGuildRosterLastOnline, rosterIndex)
                if ok and (years or months or days or hours) then
                    member.lastOnlineHours = ((tonumber(years) or 0) * 8760)
                        + ((tonumber(months) or 0) * 730)
                        + ((tonumber(days) or 0) * 24)
                        + (tonumber(hours) or 0)
                end
            elseif online then
                member.lastOnlineHours = 0
            end
            members[#members + 1] = member
            PutNameIndex(index, name, member)
        end
    end

    self.members = members
    self.membersByName = index
    self.lastUpdate = GC.Util.Now()
    GC:FireCallback("ROSTER_UPDATED")
end

function GC.Roster:GetActiveRaiders(limit)
    local raiders = {}
    local rosterSettings = GC.DB:GetGuild().roster
    for _, member in ipairs(self.members) do
        local rankAllowed = not rosterSettings.rankFilterConfigured
            or rosterSettings.activeRaiderRanks[tostring(member.rankIndex)] == true
        if (tonumber(member.level) or 0) >= 70 and rankAllowed then
            raiders[#raiders + 1] = member
        end
    end
    table.sort(raiders, function(left, right)
        if left.online ~= right.online then
            return left.online == true
        end
        local leftHours = left.lastOnlineHours or math.huge
        local rightHours = right.lastOnlineHours or math.huge
        if leftHours ~= rightHours then
            return leftHours < rightHours
        end
        return tostring(left.name or "") < tostring(right.name or "")
    end)

    local result = {}
    for index = 1, math.min(tonumber(limit) or 25, #raiders) do
        result[index] = raiders[index]
    end
    return result
end

function GC.Roster:GetRankDefinitions()
    local byIndex = {}
    for _, member in ipairs(self.members) do
        local rankIndex = tonumber(member.rankIndex)
        if rankIndex ~= nil and not byIndex[rankIndex] then
            byIndex[rankIndex] = {
                index = rankIndex,
                name = member.rank or ("Rang " .. (rankIndex + 1)),
            }
        end
    end

    local ranks = {}
    for _, definition in pairs(byIndex) do
        ranks[#ranks + 1] = definition
    end
    table.sort(ranks, function(left, right)
        return left.index < right.index
    end)
    return ranks
end

function GC.Roster:GetMember(name)
    return self.membersByName[GC.Util.NormalizeName(name)]
        or self.membersByName[GC.Util.NormalizeName(GC.Util.PlayerShortName(name))]
end

function GC.Roster:IsRankActive(rankIndex)
    local settings = GC.DB:GetGuild().roster
    if not settings.rankFilterConfigured then
        return true
    end
    return settings.activeRaiderRanks[tostring(rankIndex)] == true
end

function GC.Roster:SetRankActive(rankIndex, active)
    if not self:CanEditGuildSettings() then
        return false
    end
    local settings = GC.DB:GetGuild().roster
    if not settings.rankFilterConfigured then
        for _, rank in ipairs(self:GetRankDefinitions()) do
            settings.activeRaiderRanks[tostring(rank.index)] = true
        end
    end
    settings.rankFilterConfigured = true
    settings.activeRaiderRanks[tostring(rankIndex)] = active == true
    GC:FireCallback("ROSTER_FILTER_UPDATED")
    GC.DB:GetGuild().profile.updatedAt = GC.Util.Now()
    if GC.Sync and GC.Sync.QueueGuildProfile then
        GC.Sync:QueueGuildProfile(true)
    end
    return true
end

function GC.Roster:SetAllRanksActive(active)
    if not self:CanEditGuildSettings() then
        return false
    end
    local settings = GC.DB:GetGuild().roster
    settings.rankFilterConfigured = true
    settings.activeRaiderRanks = {}
    if active then
        for _, rank in ipairs(self:GetRankDefinitions()) do
            settings.activeRaiderRanks[tostring(rank.index)] = true
        end
    end
    GC:FireCallback("ROSTER_FILTER_UPDATED")
    GC.DB:GetGuild().profile.updatedAt = GC.Util.Now()
    if GC.Sync and GC.Sync.QueueGuildProfile then
        GC.Sync:QueueGuildProfile(true)
    end
    return true
end

function GC.Roster:IsGuildProfileEditorRank(rankIndex)
    local permissions = GC.DB:GetGuild().profilePermissions
    if not permissions.configured then
        return tonumber(rankIndex) ~= nil and tonumber(rankIndex) <= 1
    end
    return permissions.editorRanks[tostring(rankIndex)] == true
end

function GC.Roster:CanEditGuildProfile(playerName)
    local member = self:GetMember(playerName or GC:GetPlayerFullName())
    return member ~= nil and self:IsGuildProfileEditorRank(member.rankIndex)
end

function GC.Roster:CanEditGuildSettings(playerName)
    return self:CanEditGuildProfile(playerName)
end

local function InitializeDefaultEditorRanks()
    local permissions = GC.DB:GetGuild().profilePermissions
    if permissions.configured then
        return permissions
    end
    for _, rank in ipairs(GC.Roster:GetRankDefinitions()) do
        permissions.editorRanks[tostring(rank.index)] = rank.index <= 1
    end
    permissions.configured = true
    return permissions
end

local function GuildProfilePermissionsChanged()
    GC.DB:GetGuild().profile.updatedAt = GC.Util.Now()
    GC:FireCallback("SETTINGS_UPDATED")
    GC:FireCallback("GUILD_PROFILE_UPDATED")
    if GC.Sync and GC.Sync.QueueGuildProfile then
        GC.Sync:QueueGuildProfile(true)
    end
end

function GC.Roster:SetGuildProfileRankActive(rankIndex, active)
    if not self:CanEditGuildProfile() then
        return false
    end
    local permissions = InitializeDefaultEditorRanks()
    if not active then
        local otherEditorExists = false
        for storedRankIndex, enabled in pairs(permissions.editorRanks) do
            if enabled and tostring(storedRankIndex) ~= tostring(rankIndex) then
                otherEditorExists = true
                break
            end
        end
        if not otherEditorExists then
            return false
        end
    end
    permissions.editorRanks[tostring(rankIndex)] = active == true
    GuildProfilePermissionsChanged()
    return true
end

function GC.Roster:SetAllGuildProfileRanksActive(active)
    if not self:CanEditGuildProfile() then
        return false
    end
    if not active then
        return false
    end
    local permissions = InitializeDefaultEditorRanks()
    permissions.editorRanks = {}
    if active then
        for _, rank in ipairs(self:GetRankDefinitions()) do
            permissions.editorRanks[tostring(rank.index)] = true
        end
    end
    GuildProfilePermissionsChanged()
    return true
end

local function InitializeDefaultProtectedRanks()
    local settings = GC.DB:GetGuild().memberCare
    if settings.protectedRanksConfigured then
        return settings
    end
    for _, rank in ipairs(GC.Roster:GetRankDefinitions()) do
        settings.protectedRanks[tostring(rank.index)] = rank.index <= 1
    end
    settings.protectedRanksConfigured = true
    return settings
end

local function InitializeDefaultMemberCareAccessRanks()
    local settings = GC.DB:GetGuild().memberCare
    if settings.accessRanksConfigured then
        return settings
    end
    for _, rank in ipairs(GC.Roster:GetRankDefinitions()) do
        settings.accessRanks[tostring(rank.index)] = rank.index <= 1
    end
    settings.accessRanksConfigured = true
    return settings
end

local function MemberCareSettingsChanged()
    GC.DB:GetGuild().profile.updatedAt = GC.Util.Now()
    GC:FireCallback("MEMBERCARE_UPDATED")
    if GC.Sync and GC.Sync.QueueGuildProfile then
        GC.Sync:QueueGuildProfile(true)
    end
end

function GC.Roster:IsMemberCareRankProtected(rankIndex)
    local settings = GC.DB:GetGuild().memberCare
    if not settings.protectedRanksConfigured then
        return tonumber(rankIndex) ~= nil and tonumber(rankIndex) <= 1
    end
    return settings.protectedRanks[tostring(rankIndex)] == true
end

function GC.Roster:IsMemberCareAccessRank(rankIndex)
    local settings = GC.DB:GetGuild().memberCare
    if not settings.accessRanksConfigured then
        return tonumber(rankIndex) ~= nil and tonumber(rankIndex) <= 1
    end
    return settings.accessRanks[tostring(rankIndex)] == true
end

function GC.Roster:CanAccessMemberCare(playerName)
    local member = self:GetMember(playerName or GC:GetPlayerFullName())
    return member ~= nil and self:IsMemberCareAccessRank(member.rankIndex)
end

function GC.Roster:SetMemberCareAccessRank(rankIndex, active)
    if not self:CanEditGuildSettings() then
        return false
    end
    local settings = InitializeDefaultMemberCareAccessRanks()
    if not active then
        local otherAccessRankExists = false
        for storedRankIndex, enabled in pairs(settings.accessRanks) do
            if enabled and tostring(storedRankIndex) ~= tostring(rankIndex) then
                otherAccessRankExists = true
                break
            end
        end
        if not otherAccessRankExists then
            return false
        end
    end
    settings.accessRanks[tostring(rankIndex)] = active == true
    MemberCareSettingsChanged()
    GC:FireCallback("SETTINGS_UPDATED")
    return true
end

function GC.Roster:SetMemberCareRankProtected(rankIndex, protected)
    if not self:CanEditGuildProfile() then
        return false
    end
    local settings = InitializeDefaultProtectedRanks()
    settings.protectedRanks[tostring(rankIndex)] = protected == true
    MemberCareSettingsChanged()
    return true
end

function GC.Roster:SetMemberCareInactivityDays(days)
    if not self:CanEditGuildProfile() then
        return false
    end
    days = math.max(7, math.min(365, tonumber(days) or 60))
    GC.DB:GetGuild().memberCare.inactivityDays = math.floor(days)
    MemberCareSettingsChanged()
    return true
end

function GC.Roster:GetGuildAbsences()
    local absences = {}
    local today = GC.Util.TodayISO()
    for _, member in ipairs(self.members) do
        local profile = self:GetProfile(member.name)
        local state = profile and GC.Profile:GetAbsenceState(profile, today) or "NONE"
        if state == "ACTIVE" or state == "UPCOMING" then
            absences[#absences + 1] = {
                member = member,
                profile = profile,
                absence = profile.absence,
                state = state,
            }
        end
    end
    table.sort(absences, function(left, right)
        if left.state ~= right.state then
            return left.state == "ACTIVE"
        end
        if left.absence.from ~= right.absence.from then
            return left.absence.from < right.absence.from
        end
        return tostring(left.member.name) < tostring(right.member.name)
    end)
    return absences
end

function GC.Roster:GetMemberCareCandidates()
    local settings = GC.DB:GetGuild().memberCare
    local thresholdDays = tonumber(settings.inactivityDays) or 60
    local today = GC.Util.TodayISO()
    local candidates = {}
    for _, member in ipairs(self.members) do
        local offlineDays = member.lastOnlineHours and math.floor(member.lastOnlineHours / 24)
        local profile = self:GetProfile(member.name)
        local isAlt = profile and profile.mainStatus == "ALT"
        local absenceState = profile and GC.Profile:GetAbsenceState(profile, today) or "NONE"
        local rankProtected = self:IsMemberCareRankProtected(member.rankIndex)
        if not member.online
            and offlineDays
            and offlineDays >= thresholdDays
            and not isAlt
            and absenceState ~= "ACTIVE"
            and not rankProtected then
            local knownMain = profile and profile.confirmed and profile.mainStatus == "MAIN"
            local reasons = {
                offlineDays .. " Tage offline",
                knownMain and "Main bestätigt" or "Main/Twink prüfen",
                "nicht abgemeldet",
            }
            candidates[#candidates + 1] = {
                member = member,
                profile = profile,
                offlineDays = offlineDays,
                status = knownMain and "VORSCHLAG" or "PRÜFEN",
                reason = table.concat(reasons, "  •  "),
            }
        end
    end
    table.sort(candidates, function(left, right)
        if left.offlineDays ~= right.offlineDays then
            return left.offlineDays > right.offlineDays
        end
        return tostring(left.member.name) < tostring(right.member.name)
    end)
    return candidates
end

function GC.Roster:IsGuildMember(name)
    return self.membersByName[GC.Util.NormalizeName(name)] ~= nil
end

function GC.Roster:GetProfile(name)
    local normalized = GC.Util.NormalizeName(name)
    local ownName = GC.Util.NormalizeName(GC:GetPlayerFullName())
    local ownShortName = GC.Util.NormalizeName(GC.Util.PlayerShortName(GC:GetPlayerFullName()))
    if normalized == ownName or normalized == ownShortName then
        return GC.Profile:Get()
    end

    local guildData = GC.DB:GetGuild()
    local shortName = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    local remote = guildData.remoteProfiles[normalized] or guildData.remoteProfiles[shortName]
    if remote then
        return remote
    end

    local imported = guildData.warcraftLogs and guildData.warcraftLogs.members or {}
    return imported[normalized] or imported[shortName]
end

function GC.Roster:GetSummary()
    local summary = {
        total = #self.members,
        online = 0,
        knownProfiles = 0,
        confirmedProfiles = 0,
        classCounts = {},
        specCounts = {},
        secondarySpecCounts = {},
        coverageSpecCounts = {},
        importedProfiles = 0,
    }

    for _, member in ipairs(self.members) do
        if member.online then
            summary.online = summary.online + 1
        end
        if member.classFile then
            summary.classCounts[member.classFile] = (summary.classCounts[member.classFile] or 0) + 1
        end

        local profile = self:GetProfile(member.name)
        if profile then
            local specKey = profile.raidSpecKey or profile.detectedSpecKey
            if specKey and GC.SpecByKey[specKey] then
                summary.knownProfiles = summary.knownProfiles + 1
                summary.specCounts[specKey] = (summary.specCounts[specKey] or 0) + 1
                summary.coverageSpecCounts[specKey] = (summary.coverageSpecCounts[specKey] or 0) + 1
            end
            local secondarySpecKey = profile.secondarySpecKey
            if secondarySpecKey and GC.SpecByKey[secondarySpecKey] then
                summary.secondarySpecCounts[secondarySpecKey] = (summary.secondarySpecCounts[secondarySpecKey] or 0) + 1
                summary.coverageSpecCounts[secondarySpecKey] = (summary.coverageSpecCounts[secondarySpecKey] or 0) + 1
            end
            if profile.confirmed then
                summary.confirmedProfiles = summary.confirmedProfiles + 1
            end
            if profile.source == "WARCRAFT_LOGS" then
                summary.importedProfiles = summary.importedProfiles + 1
            end
        end
    end
    return summary
end

local rosterEvents = CreateFrame("Frame")
rosterEvents:RegisterEvent("GUILD_ROSTER_UPDATE")
rosterEvents:RegisterEvent("PLAYER_GUILD_UPDATE")
rosterEvents:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_GUILD_UPDATE" then
        GC.Roster:Request()
    else
        GC.Roster:Scan()
    end
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.Roster, function(self)
    self:Request()
    C_Timer.After(2, function()
        self:Scan()
    end)
end)
