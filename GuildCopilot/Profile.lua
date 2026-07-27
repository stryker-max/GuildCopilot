local _, GC = ...

GC.Profile = {}

local function ReadProfession(professionIndex)
    if not professionIndex or not GetProfessionInfo then
        return nil
    end
    local name, _, skillLevel, maxSkillLevel, _, _, skillLine = GetProfessionInfo(professionIndex)
    if not name then
        return nil
    end
    return {
        name = name,
        skillLevel = tonumber(skillLevel) or 0,
        maxSkillLevel = tonumber(maxSkillLevel) or 0,
        skillLine = tonumber(skillLine),
    }
end

local function ProfessionChanged(left, right)
    left = left or {}
    right = right or {}
    return left.name ~= right.name
        or left.skillLevel ~= right.skillLevel
        or left.maxSkillLevel ~= right.maxSkillLevel
        or left.skillLine ~= right.skillLine
end

local function ReadTalentPoints(tabIndex)
    if C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo then
        local results = { pcall(C_SpecializationInfo.GetSpecializationInfo, tabIndex) }
        if results[1] and type(results[8]) == "number" then
            return results[8]
        end
    end

    if GetTalentTabInfo then
        local results = { pcall(GetTalentTabInfo, tabIndex, false, false, 1) }
        if results[1] then
            local pointsSpent = results[6]
            if type(pointsSpent) == "number" then
                return pointsSpent
            end
        end
    end

    return 0
end

function GC.Profile:DetectTalentSpec()
    local _, classFile, classID = UnitClass("player")
    local classInfo = classFile and GC.Classes[classFile]
    if not classInfo then
        return nil, "0/0/0"
    end

    local points = {}
    local bestIndex
    local bestPoints = -1
    for tabIndex = 1, #classInfo.specs do
        points[tabIndex] = ReadTalentPoints(tabIndex)
        if points[tabIndex] > bestPoints then
            bestIndex = tabIndex
            bestPoints = points[tabIndex]
        end
    end

    local signature = table.concat(points, "/")
    if bestPoints <= 0 then
        return nil, signature, classFile, classID
    end
    return classFile .. ":" .. bestIndex, signature, classFile, classID
end

function GC.Profile:Get()
    local profile = GC.DB:GetCharacter()
    local _, classFile, classID = UnitClass("player")
    profile.fullName = GC:GetPlayerFullName()
    profile.classFile = classFile
    profile.classID = classID
    profile.level = UnitLevel("player")
    profile.mainStatus = profile.mainStatus or "MAIN"
    profile.flex = profile.flex == true
    profile.confirmed = profile.confirmed == true
    profile.professions = profile.professions or {}
    profile.professionAuto = profile.professionAuto ~= false
    profile.workshop = profile.workshop or { professions = {} }
    profile.workshop.professions = profile.workshop.professions or {}
    profile.absence = profile.absence or {
        from = "",
        to = "",
        reason = "",
    }
    if profile.secondarySpecKey == profile.raidSpecKey then
        profile.secondarySpecKey = nil
    end
    return profile
end

function GC.Profile:GetAbsenceState(profile, today)
    profile = profile or self:Get()
    local absence = profile.absence or {}
    local rangeFrom = absence.from or ""
    local rangeTo = absence.to or ""
    if not GC.Util.IsValidISODate(rangeFrom) or not GC.Util.IsValidISODate(rangeTo) then
        return "NONE"
    end
    today = today or GC.Util.TodayISO()
    if today < rangeFrom then
        return "UPCOMING"
    elseif today > rangeTo then
        return "EXPIRED"
    end
    return "ACTIVE"
end

function GC.Profile:SetAbsence(rangeFrom, rangeTo, reason)
    rangeFrom = GC.Util.Trim(rangeFrom)
    rangeTo = GC.Util.Trim(rangeTo)
    reason = GC.Util.Trim(reason):gsub("[|%%\r\n]", " ")
    if not GC.Util.IsValidISODate(rangeFrom) or not GC.Util.IsValidISODate(rangeTo) then
        return false, "Bitte beide Daten als JJJJ-MM-TT eingeben."
    end
    if rangeFrom > rangeTo then
        return false, "Das Bis-Datum darf nicht vor dem Von-Datum liegen."
    end
    local profile = self:Get()
    profile.absence = {
        from = rangeFrom,
        to = rangeTo,
        reason = reason:sub(1, 80),
    }
    profile.updatedAt = GC.Util.Now()
    GC:FireCallback("PROFILE_UPDATED", profile, true)
    return true, "Abmeldung gespeichert und mit der Gilde synchronisiert."
end

function GC.Profile:ClearAbsence()
    local profile = self:Get()
    profile.absence = {
        from = "",
        to = "",
        reason = "",
    }
    profile.updatedAt = GC.Util.Now()
    GC:FireCallback("PROFILE_UPDATED", profile, true)
    return true
end

function GC.Profile:RefreshProfessions(profile)
    profile = profile or self:Get()
    if not profile.professionAuto or not GetProfessions then
        return false
    end

    local profession1, profession2 = GetProfessions()
    local detected = {
        ReadProfession(profession1),
        ReadProfession(profession2),
    }
    if not detected[1] and not detected[2] then
        return false
    end

    local changed = ProfessionChanged(profile.professions[1], detected[1])
        or ProfessionChanged(profile.professions[2], detected[2])
    profile.professions = detected
    return changed
end

function GC.Profile:SetProfession(slot, professionName)
    slot = tonumber(slot)
    if slot ~= 1 and slot ~= 2 then
        return
    end
    local profile = self:Get()
    profile.professionAuto = false
    professionName = GC.Util.Trim(professionName)
    profile.professions[slot] = professionName ~= "" and {
        name = professionName,
        skillLevel = 0,
        maxSkillLevel = 0,
    } or nil
    profile.updatedAt = GC.Util.Now()
    GC:FireCallback("PROFILE_UPDATED", profile, true)
end

function GC.Profile:EnableProfessionSync()
    local profile = self:Get()
    profile.professionAuto = true
    self:RefreshProfessions(profile)
    profile.updatedAt = GC.Util.Now()
    GC:FireCallback("PROFILE_UPDATED", profile, true)
end

function GC.Profile:Refresh()
    local profile = self:Get()
    local detectedSpecKey, signature, classFile, classID = self:DetectTalentSpec()
    local changed = profile.detectedSpecKey ~= detectedSpecKey
        or profile.talentSignature ~= signature
        or profile.classFile ~= classFile
        or profile.classID ~= classID
        or profile.level ~= UnitLevel("player")
    changed = self:RefreshProfessions(profile) or changed

    profile.detectedSpecKey = detectedSpecKey
    profile.talentSignature = signature
    profile.classFile = classFile
    profile.classID = classID
    profile.level = UnitLevel("player")
    profile.updatedAt = GC.Util.Now()

    if not profile.raidSpecKey and detectedSpecKey then
        profile.raidSpecKey = detectedSpecKey
    end
    if changed then
        GC:FireCallback("PROFILE_UPDATED", profile, true)
    end
    return profile
end

function GC.Profile:Confirm(raidSpecKey, secondarySpecKey, mainStatus, flex)
    if secondarySpecKey == "MAIN" or secondarySpecKey == "ALT" then
        flex = mainStatus
        mainStatus = secondarySpecKey
        secondarySpecKey = nil
    end

    local profile = self:Refresh()
    if raidSpecKey and GC.SpecByKey[raidSpecKey] and GC.SpecByKey[raidSpecKey].classFile == profile.classFile then
        profile.raidSpecKey = raidSpecKey
    end
    if secondarySpecKey
        and secondarySpecKey ~= profile.raidSpecKey
        and GC.SpecByKey[secondarySpecKey]
        and GC.SpecByKey[secondarySpecKey].classFile == profile.classFile then
        profile.secondarySpecKey = secondarySpecKey
    else
        profile.secondarySpecKey = nil
    end
    profile.mainStatus = mainStatus == "ALT" and "ALT" or "MAIN"
    profile.flex = flex == true
    profile.confirmed = true
    profile.updatedAt = GC.Util.Now()
    GC:FireCallback("PROFILE_UPDATED", profile, true)
    GC:Print("Dein Raidprofil wurde bestätigt.")
    return profile
end

local profileEvents = CreateFrame("Frame")
profileEvents:RegisterEvent("CHARACTER_POINTS_CHANGED")
profileEvents:RegisterEvent("PLAYER_LEVEL_UP")
profileEvents:RegisterEvent("PLAYER_GUILD_UPDATE")
profileEvents:RegisterEvent("SKILL_LINES_CHANGED")
profileEvents:RegisterEvent("TRADE_SKILL_SHOW")
profileEvents:SetScript("OnEvent", function()
    if GC.DB and GC.DB.data then
        GC.Profile:Refresh()
    end
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.Profile, function(self)
    self:Refresh()
end)
