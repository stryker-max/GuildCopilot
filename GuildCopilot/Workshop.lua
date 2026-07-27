local _, GC = ...

GC.Workshop = {
    incoming = {},
    syncQueue = {},
    syncSending = false,
    scanPending = false,
}

local MAX_PAYLOAD_BYTES = 170
local MAX_RECORD_BYTES = 165

local function NormalizeKey(value)
    value = GC.Util.Trim(value):lower()
    value = value:gsub("ä", "a"):gsub("ö", "o"):gsub("ü", "u"):gsub("ß", "ss")
    return (value:gsub("[^%w]", ""))
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
    value = value:gsub("[,;|]", " ")
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

local function BuildRecipeRecord(recipe)
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
    while #record > MAX_RECORD_BYTES and #reagentTokens > 0 do
        table.remove(reagentTokens)
        record = Compose()
    end
    while #record > MAX_RECORD_BYTES and #name > 8 do
        name = GC.Util.SafeChatText(name, #name - 4)
        record = Compose()
    end
    return record
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

function GC.Workshop:GetOwnData()
    local profile = GC.Profile:Get()
    profile.workshop = profile.workshop or { professions = {} }
    profile.workshop.professions = profile.workshop.professions or {}
    return profile.workshop
end

function GC.Workshop:ScheduleScan()
    self.scanGeneration = (self.scanGeneration or 0) + 1
    local generation = self.scanGeneration
    for _, delay in ipairs({ 0.25, 0.75, 1.5, 2.5 }) do
        C_Timer.After(delay, function()
            if self.scanGeneration == generation then
                self:ScanOpenProfession()
            end
        end)
    end
end

function GC.Workshop:StoreProfession(professionName, skillLevel, maxSkillLevel, recipes, scannedCount)
    if not next(recipes) then
        return false
    end

    local professionKey = NormalizeKey(professionName)
    local workshop = self:GetOwnData()
    local previous = workshop.professions[professionKey]
    local profession = {
        key = professionKey,
        name = professionName,
        skillLevel = tonumber(skillLevel) or 0,
        maxSkillLevel = tonumber(maxSkillLevel) or 0,
        updatedAt = GC.Util.Now(),
        recipes = recipes,
    }
    profession.fingerprint = RecipeFingerprint(profession)
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
        SafeAPICall(api.GetFilteredRecipeIDs, recipeIDs)
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

    if ExpandTradeSkillSubClass then
        ExpandTradeSkillSubClass(0)
    end

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

function GC.Workshop:BuildProfessionMessages(profession)
    local records = {}
    for _, recipeKey in ipairs(SortedKeys(profession.recipes)) do
        records[#records + 1] = BuildRecipeRecord(profession.recipes[recipeKey])
    end

    local payloads = {}
    local current = ""
    for _, record in ipairs(records) do
        local candidate = current == "" and record or (current .. ";" .. record)
        if #candidate > MAX_PAYLOAD_BYTES and current ~= "" then
            payloads[#payloads + 1] = current
            current = record
        else
            current = candidate
        end
    end
    payloads[#payloads + 1] = current

    local token = tostring(GC.Util.Now()) .. tostring(math.random(100, 999))
    local messages = {}
    for index, payload in ipairs(payloads) do
        messages[#messages + 1] = BuildMessage({
            "W",
            GC.Constants.SCHEMA_VERSION,
            "D",
            token,
            index,
            #payloads,
            profession.key,
            profession.name,
            payload,
        })
    end
    return messages
end

function GC.Workshop:QueueProfessionSync(profession)
    if not profession then
        return
    end
    for _, message in ipairs(self:BuildProfessionMessages(profession)) do
        if #message <= GC.Constants.MAX_CHAT_BYTES then
            self.syncQueue[#self.syncQueue + 1] = message
        end
    end
    self:PumpSyncQueue()
end

function GC.Workshop:QueueAllProfessions()
    for _, profession in pairs(self:GetOwnData().professions) do
        self:QueueProfessionSync(profession)
    end
end

function GC.Workshop:PumpSyncQueue()
    if self.syncSending or #self.syncQueue == 0 then
        return
    end
    self.syncSending = true
    local message = table.remove(self.syncQueue, 1)
    if GC.Sync then
        GC.Sync:Send(message)
    end
    C_Timer.After(0.18, function()
        self.syncSending = false
        self:PumpSyncQueue()
    end)
end

function GC.Workshop:RequestGuildData()
    if not IsInGuild or not IsInGuild() then
        return false, "Du bist in keiner Gilde."
    end
    if not GC.Sync or not GC.Sync:Send(BuildMessage({ "W", GC.Constants.SCHEMA_VERSION, "Q" })) then
        return false, "Werkstatt-Anfrage konnte nicht gesendet werden."
    end
    return true, "Werkstattdaten bei Online-Gildenmitgliedern angefragt."
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

function GC.Workshop:ReceiveSync(fields, sender)
    local operation = fields[3]
    if operation == "Q" then
        C_Timer.After(math.random() * 1.5, function()
            self:QueueAllProfessions()
        end)
        return
    end
    if operation ~= "D" then
        return
    end

    local token = fields[4]
    local part = tonumber(fields[5])
    local total = tonumber(fields[6])
    local professionKey = fields[7]
    local professionName = fields[8]
    local payload = fields[9] or ""
    if not token or not part or not total or total < 1 or part < 1 or part > total
        or professionKey == "" or professionName == "" then
        return
    end

    local senderKey = GC.Util.NormalizeName(sender)
    local incomingKey = senderKey .. "|" .. token .. "|" .. professionKey
    local incoming = self.incoming[incomingKey] or {
        parts = {},
        received = 0,
        total = total,
        professionKey = professionKey,
        professionName = professionName,
    }
    if not incoming.parts[part] then
        incoming.parts[part] = payload
        incoming.received = incoming.received + 1
    end
    self.incoming[incomingKey] = incoming
    if incoming.received < incoming.total then
        return
    end

    local recipes = {}
    for partIndex = 1, incoming.total do
        for record in tostring(incoming.parts[partIndex] or ""):gmatch("[^;]+") do
            local recipe = DecodeRecipeRecord(record, professionName)
            if recipe then
                recipes[recipe.key] = recipe
            end
        end
    end

    local crafters = GC.DB:GetGuild().workshop.crafters
    local crafter = crafters[senderKey] or {
        name = sender,
        professions = {},
    }
    crafter.name = sender
    crafter.updatedAt = GC.Util.Now()
    crafter.professions[professionKey] = {
        key = professionKey,
        name = professionName,
        updatedAt = GC.Util.Now(),
        recipes = recipes,
    }
    crafters[senderKey] = crafter
    self.incoming[incomingKey] = nil
    GC:FireCallback("WORKSHOP_UPDATED")
end

local function AddCrafterToCatalog(catalog, crafterName, professions)
    for _, profession in pairs(professions or {}) do
        for recipeKey, recipe in pairs(profession.recipes or {}) do
            local entry = catalog[recipeKey]
            if not entry then
                entry = {
                    key = recipeKey,
                    name = recipe.name or recipeKey,
                    itemID = recipe.itemID,
                    profession = profession.name or recipe.profession or "Unbekannt",
                    reagents = GC.Util.DeepCopy(recipe.reagents or {}),
                    crafters = {},
                    crafterKeys = {},
                }
                catalog[recipeKey] = entry
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

function GC.Workshop:GetCatalog(query, professionFilter)
    local catalog = {}
    AddCrafterToCatalog(catalog, GC:GetPlayerFullName(), self:GetOwnData().professions)
    for _, crafter in pairs(GC.DB:GetGuild().workshop.crafters or {}) do
        AddCrafterToCatalog(catalog, crafter.name, crafter.professions)
    end

    query = NormalizeKey(query)
    professionFilter = NormalizeKey(professionFilter)
    local entries = {}
    for _, entry in pairs(catalog) do
        table.sort(entry.crafters)
        local searchable = NormalizeKey(entry.name .. " " .. entry.profession .. " " .. table.concat(entry.crafters, " "))
        local professionMatches = professionFilter == "" or NormalizeKey(entry.profession) == professionFilter
        if professionMatches and (query == "" or searchable:find(query, 1, true)) then
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
        GC.Workshop:ScheduleScan()
    end
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.Workshop, function(self)
    self:GetOwnData()
end)
