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

-- Welche Faehigkeit ein Hauptberuf ist. Sekundaeres wie Kochkunst, Erste Hilfe
-- und Angeln gehoert ausdruecklich nicht dazu - im Profil stehen die beiden
-- Hauptberufe. "Alchemie" ist die aeltere Schreibweise derselben Sache.
local PROFESSION_BY_NAME = {}
for _, professionName in ipairs(GC.ProfessionOptions) do
    if professionName ~= "" then
        PROFESSION_BY_NAME[GC.Util.NormalizeName(professionName)] = professionName
    end
end
PROFESSION_BY_NAME[GC.Util.NormalizeName("Alchemie")] = "Alchimie"

-- Die Berufe aus dem Faehigkeitenfenster lesen.
--
-- GetProfessions() ist eine Retail-API und im Anniversary-Client schlicht nicht
-- vorhanden. Bis 0.9.45 stieg die Erfassung dort wortlos aus - die Statuszeile
-- meldete trotzdem "Automatische Synchronisierung aktiv", und stehen blieb, was
-- jemand von Hand eingetragen hatte. Classic fuehrt die Berufe stattdessen als
-- Faehigkeitszeilen.
--
-- Rueckgabe: Liste der gefundenen Berufe, oder nil, wenn der Client gar keine
-- Auskunft gibt. Der Unterschied ist wichtig - "nichts gefunden" und "kann
-- nicht nachsehen" sind zwei verschiedene Antworten, und nur die erste heisst,
-- dass dieser Charakter keinen Beruf hat.
local function ReadSkillLineProfessions()
    if type(GetNumSkillLines) ~= "function" or type(GetSkillLineInfo) ~= "function" then
        return nil
    end

    -- Eine eingeklappte Kategorie zaehlt GetNumSkillLines nicht mit. Welche
    -- zugeklappt war, wird notiert und hinterher wiederhergestellt: Das
    -- Faehigkeitenfenster des Spielers soll danach aussehen wie vorher.
    local collapsed = {}
    for index = 1, (GetNumSkillLines() or 0) do
        local name, isHeader, isExpanded = GetSkillLineInfo(index)
        if isHeader and not isExpanded and name then
            collapsed[name] = true
        end
    end
    local anyCollapsed = next(collapsed) ~= nil
    if anyCollapsed and type(ExpandSkillHeader) == "function" then
        pcall(ExpandSkillHeader, 0)
    end

    local found = {}
    local seen = {}
    for index = 1, (GetNumSkillLines() or 0) do
        local name, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(index)
        local canonical = (not isHeader) and name and PROFESSION_BY_NAME[GC.Util.NormalizeName(name)]
        if canonical and not seen[canonical] then
            seen[canonical] = true
            found[#found + 1] = {
                name = canonical,
                skillLevel = tonumber(skillRank) or 0,
                maxSkillLevel = tonumber(skillMaxRank) or 0,
            }
        end
    end

    -- Rueckwaerts zuklappen: Jedes Zuklappen verschiebt die Zeilen darunter.
    if anyCollapsed and type(CollapseSkillHeader) == "function" then
        for index = (GetNumSkillLines() or 0), 1, -1 do
            local name, isHeader = GetSkillLineInfo(index)
            if isHeader and name and collapsed[name] then
                pcall(CollapseSkillHeader, index)
            end
        end
    end

    return found
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

-- Erst die Retail-API, dann die Faehigkeitszeilen von Classic. Rueckgabe wie
-- bei ReadSkillLineProfessions: nil heisst "kein Weg, es herauszufinden".
local function ReadProfessions()
    if type(GetProfessions) == "function" then
        local profession1, profession2 = GetProfessions()
        -- Einzeln einsammeln: Fehlt der erste Beruf, endet ipairs ueber eine
        -- Tabelle mit nil an Position 1 sofort und verschluckt den zweiten.
        local first = ReadProfession(profession1)
        local second = ReadProfession(profession2)
        if first or second then
            local detected = {}
            if first then
                detected[#detected + 1] = first
            end
            if second then
                detected[#detected + 1] = second
            end
            return detected
        end
    end
    return ReadSkillLineProfessions()
end

-- Ergebnis des letzten automatischen Lesens. Rein lokal, wird nie gesendet -
-- es beschreibt diesen Client, nicht den Charakter.
--   OK          mindestens ein Beruf gelesen
--   EMPTY       nachgesehen, dieser Charakter hat keinen Hauptberuf
--   UNAVAILABLE der Client gibt die Berufsliste nicht heraus
--   MANUAL      die Uebernahme ist abgeschaltet, es gilt die eigene Auswahl
function GC.Profile:GetProfessionSource(profile)
    profile = profile or self:Get()
    if not profile.professionAuto then
        return "MANUAL"
    end
    return profile.professionSource or "UNAVAILABLE"
end

function GC.Profile:RefreshProfessions(profile)
    profile = profile or self:Get()
    if not profile.professionAuto then
        return false
    end

    local detected = ReadProfessions()
    if not detected then
        -- Nicht nachsehen koennen ist keine Antwort: Was gespeichert ist,
        -- bleibt stehen, aber die Oberflaeche darf keinen Erfolg behaupten.
        profile.professionSource = "UNAVAILABLE"
        return false
    end

    profile.professionSource = #detected > 0 and "OK" or "EMPTY"
    if #detected == 0 then
        return false
    end

    local changed = ProfessionChanged(profile.professions[1], detected[1])
        or ProfessionChanged(profile.professions[2], detected[2])
    profile.professions = { detected[1], detected[2] }
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

-- Ergebnis der letzten Bestaetigung. Bisher stand es nur im Chat und war nach
-- ein paar Kampfmeldungen weggescrollt - wer nebenher etwas anderes tat, wusste
-- hinterher nicht, ob sein Profil nun steht. Deshalb bleibt es am Profil.
function GC.Profile:GetLastConfirmation()
    return self.lastConfirmation
end

function GC.Profile:NoteConfirmation(ok, message)
    self.lastConfirmation = {
        ok = ok == true,
        message = message,
        at = GC.Util.Now(),
    }
    GC:FireCallback("PROFILE_CONFIRMATION_CHANGED")
    return self.lastConfirmation
end

function GC.Profile:Confirm(raidSpecKey, secondarySpecKey, mainStatus, flex)
    if secondarySpecKey == "MAIN" or secondarySpecKey == "ALT" then
        flex = mainStatus
        mainStatus = secondarySpecKey
        secondarySpecKey = nil
    end

    local function Fail(message)
        self:NoteConfirmation(false, message)
        return nil, message
    end

    local profile = self:Refresh()
    raidSpecKey = raidSpecKey or profile.raidSpecKey or profile.detectedSpecKey
    local raidSpec = raidSpecKey and GC.SpecByKey[raidSpecKey]
    if not raidSpec or raidSpec.classFile ~= profile.classFile then
        return Fail("Bitte zuerst eine gültige Primär-Spec deiner Klasse auswählen.")
    end
    profile.raidSpecKey = raidSpecKey

    if secondarySpecKey
        and (secondarySpecKey == profile.raidSpecKey
            or not GC.SpecByKey[secondarySpecKey]
            or GC.SpecByKey[secondarySpecKey].classFile ~= profile.classFile) then
        return Fail("Die Dual-Spec muss zu deiner Klasse passen und sich von der Primär-Spec unterscheiden.")
    end
    if secondarySpecKey then
        profile.secondarySpecKey = secondarySpecKey
    else
        profile.secondarySpecKey = nil
    end
    profile.mainStatus = mainStatus == "ALT" and "ALT" or "MAIN"
    profile.flex = flex == true
    profile.confirmed = true
    profile.updatedAt = GC.Util.Now()
    profile.confirmedAt = profile.updatedAt
    GC:FireCallback("PROFILE_UPDATED", profile, true)
    GC:Print("Dein Raidprofil wurde bestätigt.")
    -- Eigener Ton: Der Bewerberton meldet einen fremden Interessenten, das hier
    -- ist die Rueckmeldung auf die eigene Eingabe. Beides gleich klingen zu
    -- lassen hiess, zweimal nachzusehen.
    if GC.Chat and GC.Chat.PlayProfileSound then
        GC.Chat:PlayProfileSound()
    end
    self:NoteConfirmation(true, "Raidprofil bestätigt.")
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
