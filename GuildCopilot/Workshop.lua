local _, GC = ...

GC.Workshop = {
    incoming = {},
    completedIncoming = {},
    syncQueue = {},
    bulkPending = 0,
    syncSending = false,
    scanPending = false,
    syncStats = {
        queued = 0,
        sent = 0,
        failed = 0,
        receivedProfessions = 0,
        receivedRecipes = 0,
        lastSender = "",
    },
}

local MAX_PAYLOAD_BYTES = 180
local LEGACY_MAX_PAYLOAD_BYTES = 170
local MAX_RECORD_BYTES = 165
local MAX_TRANSFER_PARTS = 300
local MAX_INCOMING_TRANSFERS = 20
local INCOMING_TTL = 5 * 60
local MIN_REQUEST_REPLY_INTERVAL = 30
local SCAN_RETRY_DELAYS = { 0.15, 0.45, 1.0, 2.0 }

local function NormalizeKey(value)
    value = GC.Util.Trim(value):lower()
    value = value:gsub("ä", "a"):gsub("ö", "o"):gsub("ü", "u"):gsub("ß", "ss")
    value = value:gsub("[^%w]", "")
    -- Der deutsche TBC-Client nennt den Beruf "Alchimie", waehrend in
    -- Alltagssprache und alten Guild-Copilot-Versionen "Alchemie" steht.
    -- Beide Schreibweisen muessen denselben Filter- und Speicherschluessel
    -- ergeben.
    if value == "alchemie" then
        return "alchimie"
    end
    return value
end

local function ItemIDFromLink(link)
    return tonumber(tostring(link or ""):match("item:(%d+)"))
end

local function RecipeIDFromLink(link)
    return tonumber(tostring(link or ""):match("enchant:(%d+)"))
        or tonumber(tostring(link or ""):match("spell:(%d+)"))
end

local function SanitizedName(value)
    value = GC.Util.Trim(value)
    value = value:gsub("[,;|%%]", " ")
    return GC.Util.SafeChatText(value, 52)
end

local function SortedKeys(values)
    local keys = {}
    for key in pairs(values or {}) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    return keys
end

local function RecipeFingerprint(profession)
    local records = {}
    for _, recipeKey in ipairs(SortedKeys(profession.recipes)) do
        local recipe = profession.recipes[recipeKey]
        local reagents = {}
        for _, reagent in ipairs(recipe.reagents or {}) do
            reagents[#reagents + 1] = tostring(reagent.itemID or 0) .. ":" .. tostring(reagent.count or 0)
        end
        records[#records + 1] = table.concat({
            recipeKey,
            tostring(recipe.itemID or 0),
            recipe.name or "",
            table.concat(reagents, "."),
        }, ",")
    end
    return table.concat(records, ";")
end

local function FingerprintHash(value)
    local hash = 5381
    for index = 1, #tostring(value or "") do
        hash = ((hash * 33) + tostring(value):byte(index)) % 2147483647
    end
    return tostring(hash)
end

local function RecipeCount(profession)
    local count = 0
    for _ in pairs(profession and profession.recipes or {}) do
        count = count + 1
    end
    return count
end

local function BuildRecipeRecord(recipe, recordLimit)
    recordLimit = math.min(MAX_RECORD_BYTES, tonumber(recordLimit) or MAX_RECORD_BYTES)
    local reagentTokens = {}
    for _, reagent in ipairs(recipe.reagents or {}) do
        if tonumber(reagent.itemID) then
            reagentTokens[#reagentTokens + 1] = tostring(reagent.itemID) .. ":" .. tostring(reagent.count or 1)
        end
    end

    local name = SanitizedName(recipe.name)
    local function Compose()
        return table.concat({
            recipe.key or "",
            tostring(recipe.itemID or 0),
            name,
            table.concat(reagentTokens, "."),
        }, ",")
    end

    local record = Compose()
    while #record > recordLimit and #reagentTokens > 0 do
        table.remove(reagentTokens)
        record = Compose()
    end
    while #record > recordLimit and #name > 8 do
        name = GC.Util.SafeChatText(name, #name - 4)
        record = Compose()
    end
    if #record > recordLimit then
        name = ""
        record = Compose()
    end
    return #record <= recordLimit and record or nil
end

local function BuildCompactRecipeRecord(recipe, recordLimit)
    recordLimit = math.min(MAX_RECORD_BYTES, tonumber(recordLimit) or MAX_RECORD_BYTES)
    local recipeKey = GC.Util.SafeChatText(tostring(recipe.key or ""), 36)
    if recipeKey == "" then
        return nil
    end

    local name = ""
    if not recipeKey:match("^I%d+$") then
        name = SanitizedName(recipe.name)
    end

    local reagentTokens = {}
    for _, reagent in ipairs(recipe.reagents or {}) do
        local itemID = tonumber(reagent.itemID)
        if itemID then
            local count = math.max(1, math.floor(tonumber(reagent.count) or 1))
            reagentTokens[#reagentTokens + 1] = tostring(itemID) .. ":" .. tostring(count)
        end
    end

    local function Compose()
        return table.concat({ recipeKey, name, table.concat(reagentTokens, ".") }, ",")
    end

    local record = Compose()
    while #record > recordLimit and #reagentTokens > 0 do
        table.remove(reagentTokens)
        record = Compose()
    end
    while #record > recordLimit and #name > 8 do
        name = GC.Util.SafeChatText(name, #name - 4)
        record = Compose()
    end
    if #record > recordLimit then
        name = ""
        record = Compose()
    end
    return #record <= recordLimit and record or nil
end

local function BuildMessage(fields)
    local escaped = {}
    for index, value in ipairs(fields) do
        escaped[index] = GC.Util.EscapeField(value)
    end
    return table.concat(escaped, "|")
end

local function ResolveItemName(itemID, fallback)
    if tonumber(itemID) and tonumber(itemID) > 0 and GetItemInfo then
        local name = GetItemInfo(tonumber(itemID))
        if name then
            return name
        end
    end
    return fallback or (tonumber(itemID) and ("Item #" .. itemID) or "Unbekannt")
end

local function ResolveRecipeName(recipeKey, fallback)
    local itemID = tonumber(tostring(recipeKey or ""):match("^I(%d+)$"))
    if itemID then
        return ResolveItemName(itemID, fallback)
    end

    local spellID = tonumber(tostring(recipeKey or ""):match("^E(%d+)$"))
    if spellID and type(GetSpellInfo) == "function" then
        local ok, name = pcall(GetSpellInfo, spellID)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    return fallback or tostring(recipeKey or "Unbekanntes Rezept")
end

function GC.Workshop:GetOwnData()
    local profile = GC.Profile:Get()
    profile.workshop = profile.workshop or { professions = {} }
    profile.workshop.professions = profile.workshop.professions or {}
    local professions = profile.workshop.professions
    local legacyAlchemy = professions.alchemie
    local clientAlchemy = professions.alchimie
    if legacyAlchemy and not clientAlchemy then
        legacyAlchemy.key = "alchimie"
        professions.alchimie = legacyAlchemy
        professions.alchemie = nil
    elseif legacyAlchemy and clientAlchemy and legacyAlchemy ~= clientAlchemy then
        for recipeKey, recipe in pairs(legacyAlchemy.recipes or {}) do
            clientAlchemy.recipes[recipeKey] = clientAlchemy.recipes[recipeKey] or recipe
        end
        clientAlchemy.fingerprint = RecipeFingerprint(clientAlchemy)
        clientAlchemy.fingerprintHash = FingerprintHash(clientAlchemy.fingerprint)
        professions.alchemie = nil
    end
    return profile.workshop
end

function GC.Workshop:ScheduleScan()
    self:ScanOpenProfession()
    if self.scanPending then
        return
    end

    self.scanPending = true
    local attempt = 1
    local function RetryScan()
        GC.Workshop:ScanOpenProfession()
        attempt = attempt + 1
        local delay = SCAN_RETRY_DELAYS[attempt]
        if delay and C_Timer and C_Timer.After then
            C_Timer.After(delay, RetryScan)
        else
            GC.Workshop.scanPending = false
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(SCAN_RETRY_DELAYS[attempt], RetryScan)
    else
        self.scanPending = false
    end
end

function GC.Workshop:StoreProfession(professionName, skillLevel, maxSkillLevel, recipes, scannedCount)
    if not next(recipes) then
        return false
    end

    local professionKey = NormalizeKey(professionName)
    local workshop = self:GetOwnData()
    local previous = workshop.professions[professionKey]
    if previous
        and (tonumber(skillLevel) or 0) >= (tonumber(previous.skillLevel) or 0)
        and (tonumber(maxSkillLevel) or 0) >= (tonumber(previous.maxSkillLevel) or 0) then
        for recipeKey, previousRecipe in pairs(previous.recipes or {}) do
            if not recipes[recipeKey] then
                recipes[recipeKey] = previousRecipe
            end
        end
    end
    local profession = {
        key = professionKey,
        name = professionName,
        skillLevel = tonumber(skillLevel) or 0,
        maxSkillLevel = tonumber(maxSkillLevel) or 0,
        updatedAt = GC.Util.Now(),
        recipes = recipes,
    }
    profession.fingerprint = RecipeFingerprint(profession)
    profession.fingerprintHash = FingerprintHash(profession.fingerprint)
    workshop.professions[professionKey] = profession
    self.lastScan = {
        name = professionName,
        recipes = #SortedKeys(recipes),
        scannedAt = GC.Util.Now(),
    }

    local changed = not previous or previous.fingerprint ~= profession.fingerprint
    if changed then
        local profile = GC.Profile:Get()
        profile.updatedAt = GC.Util.Now()
        self:QueueProfessionSync(profession)
        GC:Print(professionName .. ": " .. (tonumber(scannedCount) or 0) .. " Einträge geprüft, "
            .. #SortedKeys(recipes) .. " Rezepte gespeichert.")
    end
    GC:FireCallback("WORKSHOP_UPDATED", profession)
    return true, changed
end

local function SafeAPICall(func, ...)
    if type(func) ~= "function" then
        return nil
    end
    local ok, result = pcall(func, ...)
    return ok and result or nil
end

local function PrepareClassicTradeSkill(professionName)
    if GC.Workshop.preparedProfession ~= professionName then
        GC.Workshop.preparedProfession = professionName
        if type(ExpandTradeSkillSubClass) == "function" then
            SafeAPICall(ExpandTradeSkillSubClass, 0)
        end
        if type(SetTradeSkillInvSlotFilter) == "function" then
            SafeAPICall(SetTradeSkillInvSlotFilter, 0, 1, 0)
        end
        if type(SetTradeSkillSubClassFilter) == "function" then
            SafeAPICall(SetTradeSkillSubClassFilter, 0, 1, 0)
        end
        if type(SetTradeSkillItemNameFilter) == "function" then
            SafeAPICall(SetTradeSkillItemNameFilter, nil)
        end
        if type(SetTradeSkillItemLevelFilter) == "function" then
            SafeAPICall(SetTradeSkillItemLevelFilter, 0, 0)
        end
        if type(TradeSkillOnlyShowSkillUps) == "function" then
            SafeAPICall(TradeSkillOnlyShowSkillUps, false)
        end
        if type(TradeSkillOnlyShowMakeable) == "function" then
            SafeAPICall(TradeSkillOnlyShowMakeable, false)
        end
    end

    if type(GetNumTradeSkills) ~= "function" or type(GetTradeSkillInfo) ~= "function"
        or type(ExpandTradeSkillSubClass) ~= "function" then
        return
    end

    for index = (tonumber(SafeAPICall(GetNumTradeSkills)) or 0), 1, -1 do
        local ok, _, skillType, _, isExpanded = pcall(GetTradeSkillInfo, index)
        if ok and (skillType == "header" or skillType == "subheader") and isExpanded == false then
            SafeAPICall(ExpandTradeSkillSubClass, index)
        end
    end
end

function GC.Workshop:ScanModernProfession()
    local api = C_TradeSkillUI
    if not api or type(api.GetRecipeInfo) ~= "function" or type(api.GetRecipeSchematic) ~= "function" then
        return false
    end
    if type(api.IsTradeSkillReady) == "function" and not SafeAPICall(api.IsTradeSkillReady) then
        return false
    end
    if type(api.IsDataSourceChanging) == "function" and SafeAPICall(api.IsDataSourceChanging) then
        return false
    end

    local baseInfo = SafeAPICall(api.GetBaseProfessionInfo) or {}
    local professionName = baseInfo.parentProfessionName or baseInfo.professionName
    if not professionName or professionName == "" or professionName == "UNKNOWN" then
        return false
    end

    local recipeIDs = {}
    if type(api.GetAllRecipeIDs) == "function" then
        recipeIDs = SafeAPICall(api.GetAllRecipeIDs) or {}
    elseif type(api.GetFilteredRecipeIDs) == "function" then
        recipeIDs = SafeAPICall(api.GetFilteredRecipeIDs) or {}
    end
    if #recipeIDs == 0 then
        return false
    end

    local recipes = {}
    for _, recipeID in ipairs(recipeIDs) do
        local recipeInfo = SafeAPICall(api.GetRecipeInfo, recipeID)
        if recipeInfo and recipeInfo.name and recipeInfo.learned ~= false then
            local itemLink = SafeAPICall(api.GetRecipeItemLink, recipeID)
            local recipeLink = SafeAPICall(api.GetRecipeLink, recipeID)
            local itemID = ItemIDFromLink(itemLink)
            local recipeKey = itemID and ("I" .. itemID) or ("E" .. tostring(recipeID))
            local reagents = {}
            local schematic = SafeAPICall(api.GetRecipeSchematic, recipeID, false)
            for _, slot in ipairs(schematic and schematic.reagentSlotSchematics or {}) do
                local reagent = slot.reagents and slot.reagents[1]
                local reagentItemID = reagent and reagent.itemID
                if reagentItemID then
                    reagents[#reagents + 1] = {
                        itemID = reagentItemID,
                        name = ResolveItemName(reagentItemID),
                        count = tonumber(slot.quantityRequired) or 1,
                    }
                end
            end
            recipes[recipeKey] = {
                key = recipeKey,
                name = recipeInfo.name,
                itemID = itemID,
                recipeID = tonumber(recipeID),
                itemLink = itemLink or recipeLink,
                profession = professionName,
                reagents = reagents,
            }
        end
    end
    return self:StoreProfession(
        professionName,
        baseInfo.skillLevel or baseInfo.skillLineCurrentLevel,
        baseInfo.maxSkillLevel or baseInfo.skillLineMaxLevel,
        recipes,
        #recipeIDs
    )
end

function GC.Workshop:ScanClassicCraftProfession()
    if not GetCraftInfo or not GetNumCrafts then
        return false
    end
    local professionName, skillLevel, maxSkillLevel
    if GetCraftSkillLine then
        professionName, skillLevel, maxSkillLevel = GetCraftSkillLine(1)
    end
    if (not professionName or professionName == "" or professionName == "UNKNOWN")
        and GetCraftDisplaySkillLine then
        professionName = GetCraftDisplaySkillLine()
    end
    if not professionName or professionName == "" or professionName == "UNKNOWN" then
        return false
    end

    local recipes = {}
    local recipeCount = GetNumCrafts() or 0
    for recipeIndex = 1, recipeCount do
        local recipeName, _, recipeType = GetCraftInfo(recipeIndex)
        if recipeName and recipeType ~= "header" and recipeType ~= "subheader" then
            local itemLink = GetCraftItemLink and GetCraftItemLink(recipeIndex)
            local recipeID = RecipeIDFromLink(itemLink)
            local itemID = ItemIDFromLink(itemLink)
            local recipeKey = itemID and ("I" .. itemID)
                or recipeID and ("E" .. recipeID)
                or ("N" .. NormalizeKey(recipeName))
            local reagents = {}
            local reagentCount = GetCraftNumReagents and (GetCraftNumReagents(recipeIndex) or 0) or 0
            for reagentIndex = 1, reagentCount do
                local reagentName, _, requiredCount = GetCraftReagentInfo(recipeIndex, reagentIndex)
                local reagentLink = GetCraftReagentItemLink
                    and GetCraftReagentItemLink(recipeIndex, reagentIndex)
                reagents[#reagents + 1] = {
                    itemID = ItemIDFromLink(reagentLink),
                    name = reagentName,
                    count = tonumber(requiredCount) or 1,
                }
            end
            recipes[recipeKey] = {
                key = recipeKey,
                name = recipeName,
                itemID = itemID,
                recipeID = recipeID,
                itemLink = itemLink,
                profession = professionName,
                reagents = reagents,
            }
        end
    end
    return self:StoreProfession(professionName, skillLevel, maxSkillLevel, recipes, recipeCount)
end

function GC.Workshop:ScanOpenProfession()
    if GetTradeSkillLine then
        local tradeSkillName, _, tradeSkillMaximum = GetTradeSkillLine()
        if tradeSkillName == "UNKNOWN" or (tonumber(tradeSkillMaximum) or 0) == 0 then
            local craftSuccess, craftChanged = self:ScanClassicCraftProfession()
            if craftSuccess then
                return craftSuccess, craftChanged
            end
        end
    end
    if C_TradeSkillUI and type(C_TradeSkillUI.GetRecipeInfo) == "function" then
        local modernSuccess, modernChanged = self:ScanModernProfession()
        if modernSuccess then
            return modernSuccess, modernChanged
        end
    end
    if not GetTradeSkillLine or not GetNumTradeSkills or not GetTradeSkillInfo then
        return false
    end

    local professionName, skillLevel, maxSkillLevel = GetTradeSkillLine()
    if not professionName or professionName == "" or professionName == "UNKNOWN" then
        return false
    end

    PrepareClassicTradeSkill(professionName)

    local recipes = {}
    local recipeCount = GetNumTradeSkills() or 0
    for recipeIndex = 1, recipeCount do
        local recipeName, recipeType = GetTradeSkillInfo(recipeIndex)
        if recipeName and recipeType ~= "header" and recipeType ~= "subheader" then
            local itemLink = GetTradeSkillItemLink and GetTradeSkillItemLink(recipeIndex)
            local recipeLink = GetTradeSkillRecipeLink and GetTradeSkillRecipeLink(recipeIndex)
            local itemID = ItemIDFromLink(itemLink)
            local recipeID = RecipeIDFromLink(recipeLink)
            local recipeKey = itemID and ("I" .. itemID)
                or recipeID and ("E" .. recipeID)
                or ("N" .. NormalizeKey(recipeName))
            local reagents = {}
            local reagentCount = GetTradeSkillNumReagents and (GetTradeSkillNumReagents(recipeIndex) or 0) or 0
            for reagentIndex = 1, reagentCount do
                local reagentName, _, requiredCount = GetTradeSkillReagentInfo(recipeIndex, reagentIndex)
                local reagentLink = GetTradeSkillReagentItemLink
                    and GetTradeSkillReagentItemLink(recipeIndex, reagentIndex)
                reagents[#reagents + 1] = {
                    itemID = ItemIDFromLink(reagentLink),
                    name = reagentName,
                    count = tonumber(requiredCount) or 1,
                }
            end
            recipes[recipeKey] = {
                key = recipeKey,
                name = recipeName,
                itemID = itemID,
                recipeID = recipeID,
                itemLink = itemLink,
                profession = professionName,
                reagents = reagents,
            }
        end
    end
    return self:StoreProfession(professionName, skillLevel, maxSkillLevel, recipes, recipeCount)
end

function GC.Workshop:BuildProfessionMessages(profession, compact, crafterName)
    local operation = compact == false and "D" or "C"
    local token = tostring(GC.Util.Now()) .. tostring(math.random(100, 999))
    -- Der Herstellername wird als zusaetzliches Feld angehaengt, damit auch die
    -- Berufe der eigenen Twinks korrekt dem jeweiligen Charakter zugeordnet
    -- werden. Aeltere Clients ignorieren das Feld schlicht und schreiben die
    -- Daten wie bisher dem Absender zu.
    local crafterField = GC.Util.SafeChatText(GC.Util.Trim(crafterName or ""), 40)
    local fingerprintHash = profession.fingerprintHash
        or FingerprintHash(profession.fingerprint or RecipeFingerprint(profession))

    -- Das Nutzlast-Budget ergibt sich aus dem echten 255-Byte-Chatlimit
    -- abzueglich der vollstaendigen Kopfzeile (mit dreistelligen Platzhaltern
    -- fuer Teil und Gesamtzahl). Eine feste Nutzlastgroesse hat bei langen
    -- Berufs- oder Herstellernamen das Limit gesprengt; solche Pakete wurden
    -- vor dem Senden kommentarlos verworfen und der Transfer blieb beim
    -- Empfaenger fuer immer unvollstaendig.
    local header = BuildMessage({
        "W",
        GC.Constants.SCHEMA_VERSION,
        operation,
        token,
        "000",
        "000",
        profession.key,
        profession.name,
        "",
        tostring(profession.updatedAt or 0),
        fingerprintHash,
        crafterField,
    })
    local payloadLimit = math.min(
        compact == false and LEGACY_MAX_PAYLOAD_BYTES or MAX_PAYLOAD_BYTES,
        GC.Constants.MAX_CHAT_BYTES - #header
    )

    local records = {}
    for _, recipeKey in ipairs(SortedKeys(profession.recipes)) do
        local recipe = profession.recipes[recipeKey]
        local record = compact == false
            and BuildRecipeRecord(recipe, payloadLimit)
            or BuildCompactRecipeRecord(recipe, payloadLimit)
        if record then
            records[#records + 1] = record
        end
    end

    local payloads = {}
    local current = ""
    for _, record in ipairs(records) do
        local candidate = current == "" and record or (current .. ";" .. record)
        if #candidate > payloadLimit and current ~= "" then
            payloads[#payloads + 1] = current
            current = record
        else
            current = candidate
        end
    end
    payloads[#payloads + 1] = current

    local messages = {}
    for index, payload in ipairs(payloads) do
        messages[#messages + 1] = BuildMessage({
            "W",
            GC.Constants.SCHEMA_VERSION,
            operation,
            token,
            index,
            #payloads,
            profession.key,
            profession.name,
            payload,
            tostring(profession.updatedAt or 0),
            fingerprintHash,
            crafterField,
        })
    end
    return messages, token
end

function GC.Workshop:QueueProfessionSync(profession, compact, target, reliable, crafterName)
    if not profession then
        return
    end

    local messages, token = self:BuildProfessionMessages(profession, compact, crafterName)
    if reliable and target and compact ~= false and GC.Sync and GC.Sync.QueueReliable then
        self.syncStats.queued = self.syncStats.queued + #messages
        local queued = GC.Sync:QueueReliable(
            messages,
            target,
            "W",
            token,
            function()
                GC.Workshop.syncStats.sent = GC.Workshop.syncStats.sent + #messages
                GC:FireCallback("WORKSHOP_UPDATED")
            end,
            function(entry)
                -- Kommt der bestaetigte Fluestertransfer nicht durch (in manchen
                -- Umgebungen erreichen Addon-Fluester den Empfaenger nicht,
                -- waehrend der Gildenkanal laeuft), wird der Beruf ueber den
                -- bewaehrten Gildenkanal nachgereicht. So bekommt der Anfragende
                -- die Daten trotzdem, ohne dass ein Fehl-Banner stehen bleibt -
                -- echte Verluste zaehlt die Gilden-Warteschlange selbst.
                local lost = entry.failedCount
                    or math.max(1, #messages - (entry.acknowledgedCount or 0))
                if lost > 0 then
                    GC.Workshop:QueueProfessionSync(profession, true, nil, nil, crafterName)
                else
                    GC:FireCallback("WORKSHOP_UPDATED")
                end
            end
        )
        if not queued then
            -- Der Fluesterweg liess sich gar nicht erst starten: sofort ueber
            -- den Gildenkanal senden.
            self:QueueProfessionSync(profession, true, nil, nil, crafterName)
        end
        GC:FireCallback("WORKSHOP_UPDATED")
        return queued
    end

    -- Zusammen mit dem Beruf identifiziert der Herstellername ein Paket
    -- eindeutig, damit zwei eigene Charaktere mit demselben Beruf sich beim
    -- Einreihen nicht gegenseitig verdraengen.
    local crafterKey = GC.Util.NormalizeName(crafterName or "")
    for index = #self.syncQueue, 1, -1 do
        if self.syncQueue[index].professionKey == profession.key
            and self.syncQueue[index].target == target
            and (self.syncQueue[index].crafterKey or "") == crafterKey then
            table.remove(self.syncQueue, index)
        end
    end

    for _, message in ipairs(messages) do
        if #message <= GC.Constants.MAX_CHAT_BYTES then
            self.syncQueue[#self.syncQueue + 1] = {
                message = message,
                retries = 0,
                professionKey = profession.key,
                crafterKey = crafterKey,
                distribution = target and "WHISPER" or "GUILD",
                target = target,
            }
            self.syncStats.queued = self.syncStats.queued + 1
        else
            self.syncStats.failed = self.syncStats.failed + 1
        end
    end
    GC:FireCallback("WORKSHOP_UPDATED")
    self:PumpSyncQueue()
end

-- Alle Berufe aller eigenen Charaktere desselben Accounts, jeweils mit dem
-- richtigen Charakternamen. So teilt jeder eingeloggte Charakter der Gilde auch
-- die Berufe seiner Twinks mit - das Addon kennt sie ja lokal aus der
-- gemeinsamen SavedVariables und muss sie nicht erneut erlernen.
function GC.Workshop:GetAccountProfessions()
    local entries = {}
    local ownName = GC:GetPlayerFullName()
    local ownKey = GC.Util.NormalizeName(ownName)
    for _, profession in pairs(self:GetOwnData().professions) do
        entries[#entries + 1] = { crafter = ownName, profession = profession }
    end
    for characterKey, character in pairs((GC.DB.data and GC.DB.data.characters) or {}) do
        local characterName = (type(character) == "table" and character.fullName) or characterKey
        local workshop = type(character) == "table" and character.workshop
        if workshop and workshop.professions
            and GC.Util.NormalizeName(characterName) ~= ownKey then
            for _, profession in pairs(workshop.professions) do
                entries[#entries + 1] = { crafter = characterName, profession = profession }
            end
        end
    end
    return entries
end

function GC.Workshop:QueueAllProfessions(compact, target, reliable)
    if #self.syncQueue == 0 and not self.syncSending then
        self.syncStats.queued = 0
        self.syncStats.sent = 0
        self.syncStats.failed = 0
    end
    for _, entry in ipairs(self:GetAccountProfessions()) do
        self:QueueProfessionSync(entry.profession, compact, target, reliable, entry.crafter)
    end
end

function GC.Workshop:PumpSyncQueue()
    if self.syncSending or #self.syncQueue == 0 then
        return
    end
    self.syncSending = true
    while #self.syncQueue > 0 do
        local entry = table.remove(self.syncQueue, 1)
        self.bulkPending = (self.bulkPending or 0) + 1
        local queued = GC.Sync and GC.Sync:SendBulk(
            entry.message,
            entry.distribution,
            entry.target,
            function(success)
                GC.Workshop.bulkPending = math.max(0, (GC.Workshop.bulkPending or 1) - 1)
                if success then
                    GC.Workshop.syncStats.sent = GC.Workshop.syncStats.sent + 1
                else
                    GC.Workshop.syncStats.failed = GC.Workshop.syncStats.failed + 1
                end
                GC:FireCallback("WORKSHOP_UPDATED")
            end
        )
        if not queued then
            self.bulkPending = math.max(0, (self.bulkPending or 1) - 1)
            self.syncStats.failed = self.syncStats.failed + 1
        end
    end
    self.syncSending = false
    GC:FireCallback("WORKSHOP_UPDATED")
end

function GC.Workshop:RequestGuildData()
    if not IsInGuild or not IsInGuild() then
        return false, "Du bist in keiner Gilde."
    end
    if not GC.Sync or not GC.Sync:Send(BuildMessage({ "W", GC.Constants.SCHEMA_VERSION, "Q", "3" })) then
        return false, "Werkstatt-Anfrage konnte nicht gesendet werden."
    end
    self.syncStats.receivedProfessions = 0
    self.syncStats.receivedRecipes = 0
    self.syncStats.lastSender = ""
    -- Eine neue Anfrage startet einen frischen Abgleichzyklus. Ein alter
    -- Fehlschlag-Zaehler aus einem frueheren Zyklus darf den Statushinweis nicht
    -- dauerhaft blockieren, sonst bleibt "Uebertragung unvollstaendig" stehen,
    -- obwohl der neue Durchlauf laeuft.
    self.syncStats.failed = 0
    GC:FireCallback("WORKSHOP_UPDATED")
    return true, "Anfrage gesendet. Rezeptlisten werden ohne künstliche Wartezeit übertragen."
end

function GC.Workshop:GetPendingPacketCount()
    local reliable = GC.Sync and GC.Sync.GetReliablePendingCount
        and GC.Sync:GetReliablePendingCount("W") or 0
    return #self.syncQueue + (self.bulkPending or 0) + reliable
end

function GC.Workshop:BuildManifestMessages()
    local records = {}
    for _, professionKey in ipairs(SortedKeys(self:GetOwnData().professions)) do
        local profession = self:GetOwnData().professions[professionKey]
        local fingerprintHash = profession.fingerprintHash
            or FingerprintHash(profession.fingerprint or RecipeFingerprint(profession))
        records[#records + 1] = table.concat({
            profession.key,
            tostring(profession.updatedAt or 0),
            tostring(RecipeCount(profession)),
            fingerprintHash,
        }, ",")
    end
    local messages = {}
    local current = ""
    for _, record in ipairs(records) do
        local candidate = current == "" and record or (current .. ";" .. record)
        if #candidate > MAX_PAYLOAD_BYTES and current ~= "" then
            messages[#messages + 1] = BuildMessage({
                "W",
                GC.Constants.SCHEMA_VERSION,
                "M",
                current,
            })
            current = record
        else
            current = candidate
        end
    end
    if current ~= "" then
        messages[#messages + 1] = BuildMessage({
            "W",
            GC.Constants.SCHEMA_VERSION,
            "M",
            current,
        })
    end
    return messages
end

function GC.Workshop:SendManifest(target)
    if GC.Util.Trim(target) == "" or not GC.Sync then
        return false
    end
    local messages = self:BuildManifestMessages()
    if #messages == 0 then
        return false
    end
    local queued = true
    for _, message in ipairs(messages) do
        queued = GC.Sync:SendBulk(message, "WHISPER", target) and queued
    end
    return queued
end

local function DecodeRecipeRecord(record, professionName)
    local recipeKey, itemID, recipeName, reagentText = record:match("^([^,]+),([^,]*),([^,]*),?(.*)$")
    if not recipeKey then
        return nil
    end
    itemID = tonumber(itemID)
    local reagents = {}
    for reagentToken in tostring(reagentText or ""):gmatch("[^.]+") do
        local reagentID, count = reagentToken:match("^(%d+):(%d+)$")
        if reagentID then
            reagentID = tonumber(reagentID)
            reagents[#reagents + 1] = {
                itemID = reagentID,
                name = ResolveItemName(reagentID),
                count = tonumber(count) or 1,
            }
        end
    end
    return {
        key = recipeKey,
        itemID = itemID and itemID > 0 and itemID or nil,
        name = ResolveItemName(itemID, recipeName ~= "" and recipeName or recipeKey),
        profession = professionName,
        reagents = reagents,
    }
end

local function DecodeCompactRecipeRecord(record, professionName)
    local recipeKey, recipeName, reagentText = record:match("^([^,]+),([^,]*),(.*)$")
    if not recipeKey then
        return nil
    end

    local itemID = tonumber(recipeKey:match("^I(%d+)$"))
    local recipeID = tonumber(recipeKey:match("^E(%d+)$"))
    local reagents = {}
    for reagentToken in tostring(reagentText or ""):gmatch("[^.]+") do
        local reagentID, count = reagentToken:match("^(%d+):(%d+)$")
        if reagentID then
            reagentID = tonumber(reagentID)
            reagents[#reagents + 1] = {
                itemID = reagentID,
                name = ResolveItemName(reagentID),
                count = tonumber(count) or 1,
            }
        end
    end
    return {
        key = recipeKey,
        recipeID = recipeID,
        itemID = itemID,
        name = ResolveRecipeName(recipeKey, recipeName ~= "" and recipeName or nil),
        profession = professionName,
        reagents = reagents,
    }
end

local function SupportsCompactWorkshop(sender)
    local user = GC.Sync and GC.Sync.GetAddonUser and GC.Sync:GetAddonUser(sender)
    local capabilities = user and tostring(user.capabilities or "") or ""
    return ("," .. capabilities .. ","):find(",workshop2,", 1, true) ~= nil
end

local function SupportsReliableWorkshop(sender)
    local user = GC.Sync and GC.Sync.GetAddonUser and GC.Sync:GetAddonUser(sender)
    local capabilities = user and tostring(user.capabilities or "") or ""
    return ("," .. capabilities .. ","):find(",workshop3,", 1, true) ~= nil
end

function GC.Workshop:ReceiveSync(fields, sender, distribution)
    local operation = fields[3]
    if operation == "Q" then
        local senderKey = GC.Util.NormalizeName(sender)
        local now = GC.Util.Now()
        self.requestReplies = self.requestReplies or {}
        local lastReply = self.requestReplies[senderKey]
        if senderKey == ""
            or (lastReply and (now - lastReply) < MIN_REQUEST_REPLY_INTERVAL) then
            return
        end
        self.requestReplies[senderKey] = now
        -- Der Abgleich läuft bewusst über den schnellen, zuverlässigen
        -- Gildenkanal statt über Flüsternachrichten: in manchen Umgebungen
        -- erreichen Addon-Flüster den Empfänger nicht, der Gildenkanal aber
        -- schon. Gesendet werden alle Berufe des gesamten Accounts (inklusive
        -- der eigenen Twinks), jeweils dem richtigen Charakter zugeordnet.
        self:QueueAllProfessions(SupportsCompactWorkshop(sender))
        return
    elseif operation == "M" then
        local senderKey = GC.Util.NormalizeName(sender)
        if senderKey == "" or distribution ~= "WHISPER" then
            return
        end
        local crafter = GC.DB:GetGuild().workshop.crafters[senderKey]
        local requested = {}
        for record in tostring(fields[4] or ""):gmatch("[^;]+") do
            local professionKey, updatedText, countText, fingerprintHash =
                record:match("^([^,]+),(%d+),(%d+),(%d+)$")
            local updatedAt = tonumber(updatedText)
            local recipeCount = tonumber(countText)
            local known = crafter and crafter.professions and crafter.professions[professionKey]
            if professionKey and #professionKey <= 80 and updatedAt and recipeCount
                and #fingerprintHash <= 20
                and (not known
                    or tonumber(known.updatedAt) ~= updatedAt
                    or RecipeCount(known) ~= recipeCount
                    or tostring(known.fingerprintHash or "") ~= fingerprintHash) then
                requested[#requested + 1] = professionKey
            end
        end
        for _, professionKey in ipairs(requested) do
            GC.Sync:Send(BuildMessage({
                "W",
                GC.Constants.SCHEMA_VERSION,
                "R",
                professionKey,
            }), "WHISPER", sender)
        end
        return
    elseif operation == "R" then
        if distribution ~= "WHISPER" then
            return
        end
        local professionKey = NormalizeKey(fields[4])
        local profession = self:GetOwnData().professions[professionKey]
        if profession then
            self:QueueProfessionSync(profession, true, sender, true)
        end
        return
    end
    if operation ~= "D" and operation ~= "C" then
        return
    end

    local token = fields[4]
    local part = tonumber(fields[5])
    local total = tonumber(fields[6])
    local professionKey = fields[7] or ""
    local professionName = fields[8] or ""
    local payload = fields[9] or ""
    local updatedAt = tonumber(fields[10]) or GC.Util.Now()
    local fingerprintHash = tostring(fields[11] or "")
    -- Feld 12 (optional): der eigentliche Hersteller. Fehlt es (aeltere Clients
    -- oder eigener Charakter), wird der Beruf wie bisher dem Absender
    -- zugeschrieben. So teilt ein Spieler auch die Berufe seiner Twinks mit.
    local craftedBy = GC.Util.Trim(fields[12] or "")
    if not token or not part or not total or total < 1 or part < 1 or part > total
        or total > MAX_TRANSFER_PARTS
        or #token > 40 or #professionKey > 80 or #professionName > 80
        or #payload > MAX_PAYLOAD_BYTES
        or #fingerprintHash > 20 or #craftedBy > 60
        or professionKey == "" or professionName == "" then
        return
    end

    local senderKey = GC.Util.NormalizeName(sender)
    if senderKey == "" then
        return
    end
    local crafterName = craftedBy ~= "" and craftedBy or sender
    local crafterKey = GC.Util.NormalizeName(crafterName)
    if crafterKey == "" then
        crafterName = sender
        crafterKey = senderKey
    end
    local now = GC.Util.Now()
    local incomingCount = 0
    for key, transfer in pairs(self.incoming) do
        if (now - (transfer.receivedAt or 0)) > INCOMING_TTL then
            self.incoming[key] = nil
        else
            incomingCount = incomingCount + 1
        end
    end

    local incomingKey = senderKey .. "|" .. token .. "|" .. professionKey .. "|" .. crafterKey
    for key, completedAt in pairs(self.completedIncoming) do
        if (now - (tonumber(completedAt) or 0)) > INCOMING_TTL then
            self.completedIncoming[key] = nil
        end
    end
    if self.completedIncoming[incomingKey] then
        if operation == "C" and distribution == "WHISPER" and GC.Sync then
            GC.Sync:SendReliableAck("W", token, part, sender)
        end
        return
    end

    local incoming = self.incoming[incomingKey]
    if incoming and (incoming.total ~= total
        or incoming.professionKey ~= professionKey
        or incoming.professionName ~= professionName
        or incoming.operation ~= operation
        or incoming.updatedAt ~= updatedAt
        or incoming.fingerprintHash ~= fingerprintHash) then
        self.incoming[incomingKey] = nil
        return
    end
    if not incoming then
        if incomingCount >= MAX_INCOMING_TRANSFERS then
            return
        end
        incoming = {
            parts = {},
            received = 0,
            total = total,
            professionKey = professionKey,
            professionName = professionName,
            operation = operation,
            updatedAt = updatedAt,
            fingerprintHash = fingerprintHash,
            receivedAt = now,
        }
    end
    incoming.receivedAt = now
    if incoming.parts[part] and incoming.parts[part] ~= payload then
        self.incoming[incomingKey] = nil
        return
    elseif not incoming.parts[part] then
        incoming.parts[part] = payload
        incoming.received = incoming.received + 1
    end
    self.incoming[incomingKey] = incoming
    if operation == "C" and distribution == "WHISPER" and GC.Sync then
        GC.Sync:SendReliableAck("W", token, part, sender)
    end
    if incoming.received < incoming.total then
        return
    end

    local recipes = {}
    for partIndex = 1, incoming.total do
        for record in tostring(incoming.parts[partIndex] or ""):gmatch("[^;]+") do
            local recipe = operation == "C"
                and DecodeCompactRecipeRecord(record, professionName)
                or DecodeRecipeRecord(record, professionName)
            if recipe then
                recipes[recipe.key] = recipe
            end
        end
    end

    local crafters = GC.DB:GetGuild().workshop.crafters
    local crafter = crafters[crafterKey] or {
        name = crafterName,
        professions = {},
    }
    crafter.name = crafterName
    crafter.updatedAt = GC.Util.Now()
    crafter.professions[professionKey] = {
        key = professionKey,
        name = professionName,
        updatedAt = incoming.updatedAt,
        fingerprintHash = incoming.fingerprintHash ~= ""
            and incoming.fingerprintHash
            or FingerprintHash(RecipeFingerprint({ recipes = recipes })),
        recipes = recipes,
    }
    crafters[crafterKey] = crafter
    self.incoming[incomingKey] = nil
    self.completedIncoming[incomingKey] = now
    local receivedRecipeCount = 0
    for _ in pairs(recipes) do
        receivedRecipeCount = receivedRecipeCount + 1
    end
    self.syncStats.receivedProfessions = self.syncStats.receivedProfessions + 1
    self.syncStats.receivedRecipes = self.syncStats.receivedRecipes + receivedRecipeCount
    self.syncStats.lastSender = GC.Util.PlayerShortName(crafterName)
    GC:FireCallback("WORKSHOP_UPDATED")
end

local function AddCrafterToCatalog(catalog, crafterName, professions)
    for _, profession in pairs(professions or {}) do
        for recipeKey, recipe in pairs(profession.recipes or {}) do
            local entry = catalog[recipeKey]
            if not entry then
                entry = {
                    key = recipeKey,
                    name = ResolveRecipeName(recipeKey, recipe.name),
                    itemID = recipe.itemID,
                    profession = profession.name or recipe.profession or "Unbekannt",
                    reagents = GC.Util.DeepCopy(recipe.reagents or {}),
                    crafters = {},
                    crafterKeys = {},
                }
                catalog[recipeKey] = entry
            else
                entry.name = ResolveRecipeName(recipeKey, entry.name or recipe.name)
            end
            local crafterKey = GC.Util.NormalizeName(crafterName)
            if not entry.crafterKeys[crafterKey] then
                entry.crafterKeys[crafterKey] = true
                entry.crafters[#entry.crafters + 1] = GC.Util.PlayerShortName(crafterName)
            end
            if #entry.reagents == 0 and #(recipe.reagents or {}) > 0 then
                entry.reagents = GC.Util.DeepCopy(recipe.reagents)
            end
        end
    end
end

function GC.Workshop:GetCatalog(query, professionFilter, favoritesOnly)
    local catalog = {}
    local ownName = GC:GetPlayerFullName()
    AddCrafterToCatalog(catalog, ownName, self:GetOwnData().professions)
    -- Weitere Charaktere desselben Accounts: ihre Berufe liegen lokal in der
    -- gemeinsamen SavedVariables. So sieht jeder eigene Charakter auch die
    -- Berufe der anderen eigenen Charaktere (z. B. die Verzauberkunst des
    -- Magier-Twinks auf dem Main), ohne auf eine Netzwerksynchronisierung zu
    -- warten - das Addon kennt die Daten ja bereits.
    local ownKey = GC.Util.NormalizeName(ownName)
    for characterKey, character in pairs((GC.DB.data and GC.DB.data.characters) or {}) do
        local workshop = type(character) == "table" and character.workshop
        local characterName = (type(character) == "table" and character.fullName) or characterKey
        if workshop and workshop.professions
            and GC.Util.NormalizeName(characterName) ~= ownKey then
            AddCrafterToCatalog(catalog, characterName, workshop.professions)
        end
    end
    for _, crafter in pairs(GC.DB:GetGuild().workshop.crafters or {}) do
        AddCrafterToCatalog(catalog, crafter.name, crafter.professions)
    end

    query = NormalizeKey(query)
    professionFilter = NormalizeKey(professionFilter)
    local favorites = GC.DB:GetSettings().workshopFavorites or {}
    local entries = {}
    for _, entry in pairs(catalog) do
        table.sort(entry.crafters)
        local searchable = NormalizeKey(entry.name .. " " .. entry.profession .. " " .. table.concat(entry.crafters, " "))
        local professionMatches = professionFilter == "" or NormalizeKey(entry.profession) == professionFilter
        local favoriteMatches = not favoritesOnly or favorites[entry.key] == true
        if professionMatches and favoriteMatches and (query == "" or searchable:find(query, 1, true)) then
            entries[#entries + 1] = entry
        end
    end
    table.sort(entries, function(left, right)
        if left.profession ~= right.profession then
            return left.profession < right.profession
        end
        return left.name < right.name
    end)
    return entries
end

function GC.Workshop:IsFavorite(recipeKey)
    if not recipeKey or recipeKey == "" then
        return false
    end
    return GC.DB:GetSettings().workshopFavorites[recipeKey] == true
end

function GC.Workshop:SetFavorite(recipeKey, favorite)
    if not recipeKey or recipeKey == "" then
        return false
    end
    local favorites = GC.DB:GetSettings().workshopFavorites
    if favorite then
        favorites[recipeKey] = true
    else
        favorites[recipeKey] = nil
    end
    return true
end

function GC.Workshop:GetMissingOwnProfessions()
    local ignored = {
        [NormalizeKey("Kräuterkunde")] = true,
        [NormalizeKey("Kürschnerei")] = true,
    }
    local known = self:GetOwnData().professions or {}
    local missing = {}
    for _, profession in ipairs(GC.Profile:Get().professions or {}) do
        local name = profession and profession.name
        local key = NormalizeKey(name)
        if name and name ~= "" and not ignored[key] and not known[key] then
            missing[#missing + 1] = name
        end
    end
    table.sort(missing)
    return missing
end

function GC.Workshop:GetSummary()
    local entries = self:GetCatalog("")
    local crafters = {}
    local professions = {}
    for _, entry in ipairs(entries) do
        professions[entry.profession] = true
        for _, crafter in ipairs(entry.crafters) do
            crafters[GC.Util.NormalizeName(crafter)] = true
        end
    end
    local crafterCount = 0
    local professionCount = 0
    for _ in pairs(crafters) do
        crafterCount = crafterCount + 1
    end
    for _ in pairs(professions) do
        professionCount = professionCount + 1
    end
    return {
        recipes = #entries,
        crafters = crafterCount,
        professions = professionCount,
    }
end

local workshopEvents = CreateFrame("Frame")
workshopEvents:RegisterEvent("TRADE_SKILL_SHOW")
workshopEvents:RegisterEvent("TRADE_SKILL_UPDATE")
workshopEvents:RegisterEvent("CRAFT_SHOW")
workshopEvents:RegisterEvent("CRAFT_UPDATE")
workshopEvents:RegisterEvent("GET_ITEM_INFO_RECEIVED")
workshopEvents:SetScript("OnEvent", function(_, event)
    if event == "GET_ITEM_INFO_RECEIVED" then
        GC:FireCallback("WORKSHOP_UPDATED")
    else
        if event == "TRADE_SKILL_SHOW" then
            GC.Workshop.preparedProfession = nil
        end
        GC.Workshop:ScheduleScan()
    end
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.Workshop, function(self)
    self:GetOwnData()
    if C_Timer and C_Timer.After then
        C_Timer.After(10, function()
            -- Der Abgleich ist fester Hintergrunddienst und läuft über den
            -- schnellen, zuverlässigen Gildenkanal. Erst den Bestand der Gilde
            -- anfragen ...
            GC.Workshop:RequestGuildData()
        end)
        C_Timer.After(16, function()
            -- ... und die eigenen Berufe (inklusive der Twinks aus dem lokalen
            -- Cache) aktiv in die Gilde geben, damit andere sie bekommen, ohne
            -- selbst anfragen zu müssen. Der Zeitstempel sorgt beim Empfänger
            -- dafür, dass neuere Daten alte ersetzen.
            if IsInGuild and IsInGuild() then
                GC.Workshop:QueueAllProfessions()
            end
        end)
    end
end)
