local _, GC = ...

GC.Workshop = {
    incoming = {},
    completedIncoming = {},
    syncQueue = {},
    bulkPending = 0,
    syncSending = false,
    scanPending = false,
    -- Berufe, die ein fremdes Manifest gemeldet hat und die hier noch fehlen.
    -- Sie sind der Unterschied zwischen "gerade ist nichts unterwegs" und
    -- "der Stand ist vollstaendig" - genau die Frage, die der
    -- Fortschrittsbalken beantworten soll.
    pendingWants = {},
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
-- Fehlende Rezepte werden gesammelt und mit Streuung nachgefordert, damit bei
-- vielen Mitgliedern nicht alle gleichzeitig dasselbe Rezept anfragen.
local MISSING_REQUEST_DELAY = 8
local MISSING_REQUEST_SUPPRESS = 60
local MAX_KEYS_PER_REQUEST = 40
local DEPARTED_PRUNE_INTERVAL = 60
-- So lange gilt ein aus dem Manifest gemeldeter Beruf als "kommt noch". Danach
-- ist er nicht mehr unterwegs, sondern ausgeblieben - und der Balken sagt das
-- statt ewig weiterzulaufen.
local WANT_TTL = 120
-- Die Merkliste unterdrueckter Rezeptanfragen wuchs bisher unbegrenzt: ein
-- Eintrag je Rezept, in einer grossen Gilde ueber Stunden mehrere tausend.
-- Sie wird deshalb aufgeraeumt, sobald sie zu gross wird.
local MAX_SUPPRESSED_REQUESTS = 600

-- Rezeptschluessel sind Item- oder Zauber-IDs. Nach Typ gruppiert und als
-- Differenzen aufsteigender Zahlen kosten 294 Schluessel rund 590 Bytes statt
-- 34 KB voller Rezeptdaten - der Grund, weshalb ein Beruf beim Zweiten und
-- allen Folgenden nur noch aus Schluesseln besteht.
local function EncodeRecipeKeys(keys)
    local numeric = { I = {}, E = {} }
    local literal = {}
    for _, recipeKey in ipairs(keys) do
        local prefix, digits = tostring(recipeKey):match("^([IE])(%d+)$")
        if prefix and #digits <= 12 then
            local group = numeric[prefix]
            group[#group + 1] = tonumber(digits)
        elseif tostring(recipeKey):match("^N[%w]+$") then
            literal[#literal + 1] = tostring(recipeKey):sub(2)
        end
    end

    local parts = {}
    for _, prefix in ipairs({ "I", "E" }) do
        local group = numeric[prefix]
        if #group > 0 then
            table.sort(group)
            local deltas, previous = {}, 0
            for _, id in ipairs(group) do
                if id ~= previous then
                    deltas[#deltas + 1] = tostring(id - previous)
                    previous = id
                end
            end
            parts[#parts + 1] = prefix .. "=" .. table.concat(deltas, ".")
        end
    end
    if #literal > 0 then
        table.sort(literal)
        parts[#parts + 1] = "N=" .. table.concat(literal, ".")
    end
    return table.concat(parts, ";")
end

local function DecodeRecipeKeys(payload)
    local keys = {}
    for group in tostring(payload or ""):gmatch("[^;]+") do
        local prefix, values = group:match("^([IEN])=(.*)$")
        if prefix == "N" then
            for name in tostring(values):gmatch("[^.]+") do
                keys[#keys + 1] = "N" .. name
            end
        elseif prefix then
            local current = 0
            for delta in tostring(values):gmatch("[^.]+") do
                local step = tonumber(delta)
                if not step or step < 0 then
                    break
                end
                current = current + step
                if current > 0 then
                    keys[#keys + 1] = prefix .. tostring(current)
                end
            end
        end
    end
    return keys
end

-- Nach aussen sichtbar, damit die Tests die Kodierung direkt pruefen koennen.
GC.Workshop.EncodeRecipeKeys = function(_, keys)
    return EncodeRecipeKeys(keys)
end
GC.Workshop.DecodeRecipeKeys = function(_, payload)
    return DecodeRecipeKeys(payload)
end

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

local function RecipeKeyCount(profession)
    local count = 0
    for _ in pairs(profession and profession.recipeKeys or {}) do
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

-- Der eigene Werkstatt-Datensatz zu einem Berufsnamen, egal in welcher
-- Schreibweise er ankommt (Alchemie/Alchimie). Für die Profilseite: Skill,
-- Rezeptzahl und Stand des letzten Einlesens.
function GC.Workshop:GetOwnProfession(professionName)
    if GC.Util.Trim(professionName or "") == "" then
        return nil
    end
    return self:GetOwnData().professions[NormalizeKey(professionName)]
end

-- Der gildenweite Bestand besteht aus zwei getrennten Teilen: einem
-- Rezeptkatalog, in dem jedes Rezept genau einmal steht, und einem Index, wer
-- welches Rezept kann. Vor dieser Trennung hielt jeder Crafter eine eigene
-- Vollkopie aller Rezepte - bei hundert Mitgliedern ein Vielfaches an
-- Uebertragung und Speicher fuer immer dieselben Daten.
function GC.Workshop:GetGuildWorkshop()
    local workshop = GC.DB:GetGuild().workshop
    workshop.crafters = workshop.crafters or {}
    workshop.catalog = workshop.catalog or {}
    if not workshop.catalogMigrated then
        workshop.catalogMigrated = true
        for _, crafter in pairs(workshop.crafters) do
            for professionKey, profession in pairs((type(crafter) == "table" and crafter.professions) or {}) do
                if type(profession) == "table" and type(profession.recipes) == "table" then
                    profession.recipeKeys = profession.recipeKeys or {}
                    for recipeKey, recipe in pairs(profession.recipes) do
                        profession.recipeKeys[recipeKey] = true
                        if not workshop.catalog[recipeKey] and type(recipe) == "table" then
                            workshop.catalog[recipeKey] = {
                                key = recipeKey,
                                itemID = recipe.itemID,
                                recipeID = recipe.recipeID,
                                name = recipe.name,
                                professionKey = professionKey,
                                profession = profession.name or recipe.profession,
                                reagents = recipe.reagents or {},
                            }
                        end
                    end
                    profession.recipes = nil
                end
            end
        end
    end

    -- Bis 0.9.87 stand der eigene Charakter mit Realmanteil in der Tabelle
    -- ("alex-ewigerhain"), von fremden Clients gemeldete Herstellernamen aber
    -- ohne ("alex"). Derselbe Spieler fuellte damit zwei Zeilen. Die alten
    -- Schluessel werden einmalig auf den Kurznamen zusammengefuehrt; bei
    -- doppelten Berufen gewinnt der neuere Stand.
    if not workshop.crafterKeysMigrated then
        workshop.crafterKeysMigrated = true
        -- Erst sammeln, dann umhaengen: Waehrend eines pairs-Durchlaufs einen
        -- NEUEN Schluessel zu setzen ist in Lua nicht definiert.
        local moves = {}
        for key, crafter in pairs(workshop.crafters) do
            local shortKey = GC.Util.PlayerKey(key)
            if shortKey ~= "" and shortKey ~= key and type(crafter) == "table" then
                moves[#moves + 1] = { from = key, to = shortKey, crafter = crafter }
            end
        end
        for _, move in ipairs(moves) do
            local target = workshop.crafters[move.to]
            if type(target) ~= "table" then
                workshop.crafters[move.to] = move.crafter
            else
                target.professions = target.professions or {}
                for professionKey, profession in pairs(move.crafter.professions or {}) do
                    local known = target.professions[professionKey]
                    if not known
                        or (tonumber(profession.updatedAt) or 0) > (tonumber(known.updatedAt) or 0) then
                        target.professions[professionKey] = profession
                    end
                end
            end
            workshop.crafters[move.from] = nil
        end
    end
    return workshop
end

-- Ein Rezept wandert nur dann in den Katalog, wenn es dort fehlt oder bisher
-- ohne Reagenzien steckt. Rezeptdaten sind fuer alle identisch: der Schluessel
-- ist die Item- beziehungsweise Zauber-ID, die Reagenzien haengen nicht am
-- Spieler. Deshalb gibt es nichts abzuwaegen, wenn zwei Absender dasselbe
-- Rezept melden.
function GC.Workshop:StoreCatalogRecipe(recipe, professionKey, professionName)
    if type(recipe) ~= "table" or GC.Util.Trim(recipe.key) == "" then
        return false
    end
    local catalog = self:GetGuildWorkshop().catalog
    local existing = catalog[recipe.key]
    if existing and #(existing.reagents or {}) > 0 and #(recipe.reagents or {}) == 0 then
        return false
    end
    catalog[recipe.key] = {
        key = recipe.key,
        itemID = recipe.itemID,
        recipeID = recipe.recipeID,
        name = recipe.name,
        professionKey = professionKey or (existing and existing.professionKey),
        profession = professionName or (existing and existing.profession),
        reagents = recipe.reagents or (existing and existing.reagents) or {},
    }
    self:InvalidateCatalog()
    return true
end

-- Traegt ein, wer einen Beruf mit welchen Rezepten kann. "sharedBy" haelt fest,
-- welches Gildenmitglied den Eintrag eingebracht hat: Twinks stehen nicht im
-- Gildenroster und duerfen beim Aufraeumen nicht mit Ausgetretenen verwechselt
-- werden.
function GC.Workshop:ClaimRecipes(info)
    local crafterKey = GC.Util.PlayerKey(info.crafter)
    if crafterKey == "" or GC.Util.Trim(info.professionKey) == "" then
        return nil
    end
    local workshop = self:GetGuildWorkshop()
    local crafter = workshop.crafters[crafterKey] or { professions = {} }
    crafter.name = info.crafter
    crafter.professions = crafter.professions or {}
    crafter.updatedAt = GC.Util.Now()
    if GC.Util.Trim(info.sharedBy) ~= "" then
        crafter.sharedBy = info.sharedBy
    end

    -- Ein aelterer Stand darf einen neueren nicht zurueckdrehen. Das trifft
    -- zwei reale Faelle: ein Paket, das sich im Gildenkanal verspaetet hat,
    -- und einen Zweitclient, der seit Stunden laeuft und seinen alten Stand
    -- weitermeldet. Beide haben bisher die Rezeptliste ueberschrieben - bei
    -- einer vollen Schluesselliste ("K") samt der Rezepte, die seitdem
    -- dazugelernt wurden.
    --
    -- Gleichstand zaehlt als "schon da": Derselbe Stand zweimal aendert
    -- nichts, und die Ordnung bleibt damit eindeutig.
    local incomingAt = tonumber(info.updatedAt) or GC.Util.Now()
    local known = crafter.professions[info.professionKey]
    if known and (tonumber(known.updatedAt) or 0) > incomingAt then
        workshop.crafters[crafterKey] = crafter
        return crafter
    end

    local recipeKeys = {}
    for _, recipeKey in ipairs(info.recipeKeys or {}) do
        recipeKeys[recipeKey] = true
    end
    crafter.professions[info.professionKey] = {
        key = info.professionKey,
        name = info.professionName,
        updatedAt = incomingAt,
        fingerprintHash = info.fingerprintHash,
        recipeKeys = recipeKeys,
    }
    workshop.crafters[crafterKey] = crafter
    self:ClearWanted(info.crafter, info.professionKey)
    self:InvalidateCatalog()
    return crafter
end

-- Welche der gemeldeten Rezepte kennt dieser Client noch gar nicht? Nur fuer
-- die lohnt eine Nachforderung der vollen Daten - und zwar einmal gildenweit,
-- nicht einmal je Spieler.
function GC.Workshop:GetUnknownRecipeKeys(recipeKeys)
    local catalog = self:GetGuildWorkshop().catalog
    local own = self:GetOwnData().professions
    local missing = {}
    for _, recipeKey in ipairs(recipeKeys or {}) do
        local known = catalog[recipeKey] and #(catalog[recipeKey].reagents or {}) > 0
        if not known then
            for _, profession in pairs(own) do
                if (profession.recipes or {})[recipeKey] then
                    known = true
                    break
                end
            end
        end
        if not known then
            missing[#missing + 1] = recipeKey
        end
    end
    return missing
end

-- Fehlt zu einem gemeldeten Rezept die Datenzeile, wird sie beim Hersteller
-- nachgefordert - aber mit Streuung und nur einmal je Rezept. Sieht dieser
-- Client in der Zwischenzeit die Anfrage eines anderen oder trifft das Rezept
-- ein, entfaellt die eigene Anfrage. So bleibt es bei hundert Mitgliedern bei
-- wenigen Anfragen statt hundert gleichlautenden.
-- Abgelaufene Merker fliegen raus, sobald die Liste zu gross wird. Sie ist rein
-- lokal und lebt nur in dieser Sitzung, wuchs aber mit jedem je angefragten
-- Rezept weiter - in einer grossen Gilde ueber einen Raidabend hinweg um
-- mehrere tausend Eintraege.
local function PruneSuppressed(suppressed, ttl)
    local count = 0
    for _ in pairs(suppressed) do
        count = count + 1
    end
    if count <= MAX_SUPPRESSED_REQUESTS then
        return
    end
    local cutoff = GC.Util.Now() - ttl
    for key, at in pairs(suppressed) do
        if (tonumber(at) or 0) < cutoff then
            suppressed[key] = nil
        end
    end
end

function GC.Workshop:ScheduleMissingRecipeRequest(crafterName, recipeKeys)
    local missing = self:GetUnknownRecipeKeys(recipeKeys)
    if #missing == 0 or GC.Util.Trim(crafterName) == "" then
        return false
    end
    self.suppressedRequests = self.suppressedRequests or {}
    PruneSuppressed(self.suppressedRequests, MISSING_REQUEST_SUPPRESS)
    local now = GC.Util.Now()
    local pending = {}
    for _, recipeKey in ipairs(missing) do
        local suppressedAt = self.suppressedRequests[recipeKey]
        if not suppressedAt or (now - suppressedAt) > MISSING_REQUEST_SUPPRESS then
            pending[#pending + 1] = recipeKey
        end
    end
    if #pending == 0 then
        return false
    end
    if not C_Timer or type(C_Timer.After) ~= "function" then
        return self:SendMissingRecipeRequest(crafterName, pending)
    end
    C_Timer.After(1 + math.random() * MISSING_REQUEST_DELAY, function()
        GC.Workshop:SendMissingRecipeRequest(crafterName, pending)
    end)
    return true
end

function GC.Workshop:SendMissingRecipeRequest(crafterName, recipeKeys)
    if not GC.Sync then
        return false
    end
    -- Zwischen Planung und Absenden kann das Rezept eingetroffen sein oder ein
    -- anderer die Anfrage gestellt haben.
    local stillMissing = self:GetUnknownRecipeKeys(recipeKeys)
    self.suppressedRequests = self.suppressedRequests or {}
    local now = GC.Util.Now()
    local wanted = {}
    for _, recipeKey in ipairs(stillMissing) do
        local suppressedAt = self.suppressedRequests[recipeKey]
        if not suppressedAt or (now - suppressedAt) > MISSING_REQUEST_SUPPRESS then
            wanted[#wanted + 1] = recipeKey
            if #wanted >= MAX_KEYS_PER_REQUEST then
                break
            end
        end
    end
    if #wanted == 0 then
        return false
    end
    for _, recipeKey in ipairs(wanted) do
        self.suppressedRequests[recipeKey] = now
    end
    local message = BuildMessage({
        "W",
        GC.Constants.SCHEMA_VERSION,
        "N",
        GC.Util.SafeChatText(GC.Util.Trim(crafterName), 40),
        EncodeRecipeKeys(wanted),
    })
    if #message > GC.Constants.MAX_CHAT_BYTES then
        return false
    end
    return GC.Sync:SendBulk(message, "GUILD")
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
    self:InvalidateCatalog()
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

-- "recipeKeyFilter" schraenkt die Nutzlast auf einzelne Rezepte ein. Damit
-- werden nachgeforderte Rezepte gezielt nachgeliefert, statt den ganzen Beruf
-- erneut zu senden.
function GC.Workshop:BuildProfessionMessages(profession, compact, crafterName, recipeKeyFilter)
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
        if not recipeKeyFilter or recipeKeyFilter[recipeKey] then
            local recipe = profession.recipes[recipeKey]
            local record = compact == false
                and BuildRecipeRecord(recipe, payloadLimit)
                or BuildCompactRecipeRecord(recipe, payloadLimit)
            if record then
                records[#records + 1] = record
            end
        end
    end
    if recipeKeyFilter and #records == 0 then
        return {}, token
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

-- Die Schluesselliste eines Berufs: nur "wer kann was", ohne Rezeptdaten. Sie
-- nutzt dieselbe Kopfzeile und damit dieselbe Zusammensetzung beim Empfaenger
-- wie ein voller Transfer - nur die Nutzlast ist eine andere.
function GC.Workshop:BuildKeyListMessages(profession, crafterName)
    local token = tostring(GC.Util.Now()) .. tostring(math.random(100, 999))
    local crafterField = GC.Util.SafeChatText(GC.Util.Trim(crafterName or ""), 40)
    local fingerprintHash = profession.fingerprintHash
        or FingerprintHash(profession.fingerprint or RecipeFingerprint(profession))
    local header = BuildMessage({
        "W", GC.Constants.SCHEMA_VERSION, "K", token, "000", "000",
        profession.key, profession.name, "",
        tostring(profession.updatedAt or 0), fingerprintHash, crafterField,
    })
    local payloadLimit = math.min(
        MAX_PAYLOAD_BYTES,
        GC.Constants.MAX_CHAT_BYTES - #header
    )

    local payload = EncodeRecipeKeys(SortedKeys(profession.recipes))
    -- Wie beim Gildenprofil wird stumpf nach Bytes geschnitten; gelesen wird
    -- erst die wieder zusammengesetzte Nutzlast.
    local chunks = {}
    for offset = 1, math.max(1, #payload), payloadLimit do
        chunks[#chunks + 1] = payload:sub(offset, offset + payloadLimit - 1)
    end

    local messages = {}
    for index, chunk in ipairs(chunks) do
        messages[#messages + 1] = BuildMessage({
            "W", GC.Constants.SCHEMA_VERSION, "K", token, index, #chunks,
            profession.key, profession.name, chunk,
            tostring(profession.updatedAt or 0), fingerprintHash, crafterField,
        })
    end
    return messages, token
end

function GC.Workshop:QueueProfessionSync(profession, compact, target, reliable, crafterName, recipeKeyFilter)
    if not profession then
        return
    end

    local messages, token = self:BuildProfessionMessages(profession, compact, crafterName, recipeKeyFilter)
    if #messages == 0 then
        return false
    end
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
    local crafterKey = GC.Util.PlayerKey(crafterName or "")
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
    local ownKey = GC.Util.PlayerKey(ownName)
    for _, profession in pairs(self:GetOwnData().professions) do
        entries[#entries + 1] = { crafter = ownName, profession = profession }
    end
    for characterKey, character in pairs((GC.DB.data and GC.DB.data.characters) or {}) do
        local characterName = (type(character) == "table" and character.fullName) or characterKey
        local workshop = type(character) == "table" and character.workshop
        if workshop and workshop.professions
            and GC.Util.PlayerKey(characterName) ~= ownKey then
            for _, profession in pairs(workshop.professions) do
                entries[#entries + 1] = { crafter = characterName, profession = profession }
            end
        end
    end
    return entries
end

-- Reiht eine Schluesselliste in dieselbe Warteschlange ein wie volle Transfers.
function GC.Workshop:QueueKeyList(profession, crafterName)
    if not profession then
        return false
    end
    local messages = self:BuildKeyListMessages(profession, crafterName)
    local crafterKey = GC.Util.PlayerKey(crafterName or "")
    for index = #self.syncQueue, 1, -1 do
        local queued = self.syncQueue[index]
        if queued.professionKey == profession.key and queued.keyList
            and (queued.crafterKey or "") == crafterKey then
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
                keyList = true,
                distribution = "GUILD",
            }
            self.syncStats.queued = self.syncStats.queued + 1
        else
            self.syncStats.failed = self.syncStats.failed + 1
        end
    end
    GC:FireCallback("WORKSHOP_UPDATED")
    self:PumpSyncQueue()
    return true
end

-- "fullData" verlangt ausdruecklich die vollen Rezeptdaten. Ohne das Kennzeichen
-- gehen nur Schluessellisten raus. Vorher entschied das eine gildenweite
-- Vermutung: ein einziger Eintrag mit veralteten Faehigkeiten liess damit jeden
-- Login und jedes /reload zum Vollversand werden.
function GC.Workshop:QueueAllProfessions(compact, target, reliable, fullData)
    if #self.syncQueue == 0 and not self.syncSending then
        self.syncStats.queued = 0
        self.syncStats.sent = 0
        self.syncStats.failed = 0
    end
    -- Der Regelfall ist die kurze Schluesselliste: die Rezeptdaten selbst sind
    -- in der Gilde langst bekannt, weil jedes Rezept fuer alle identisch ist.
    -- Volle Daten gehen nur an gezielte Empfaenger oder solange noch ein Client
    -- ohne Schluesselliste in der Gilde ist.
    local keyListOnly = not target and compact ~= false and not fullData
    for _, entry in ipairs(self:GetAccountProfessions()) do
        if keyListOnly then
            self:QueueKeyList(entry.profession, entry.crafter)
        else
            self:QueueProfessionSync(entry.profession, compact, target, reliable, entry.crafter)
            if not target then
                -- Zusammen mit den vollen Daten geht die Schluesselliste raus,
                -- damit aktuelle Clients den Herstellerindex auch dann sauber
                -- fuehren, wenn einzelne Rezeptpakete verloren gehen.
                self:QueueKeyList(entry.profession, entry.crafter)
            end
        end
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

-- === Bekannte Luecken ======================================================
--
-- Ein fremdes Manifest sagt, welche Berufe es in der Gilde gibt. Was davon hier
-- fehlt, ist eine Luecke mit Namen - und damit die einzige belastbare Antwort
-- auf "bin ich auf dem aktuellsten Stand?". Ohne diese Liste wuerde ein Client,
-- bei dem gerade kein Paket unterwegs ist, sich fuer vollstaendig halten,
-- obwohl er drei Berufe nie bekommen hat.

local function WantKey(crafter, professionKey)
    return GC.Util.PlayerKey(crafter) .. "|" .. tostring(professionKey or "")
end

function GC.Workshop:NoteWanted(entries)
    local now = GC.Util.Now()
    self.pendingWants = self.pendingWants or {}
    for _, entry in ipairs(entries or {}) do
        if GC.Util.Trim(entry.crafter) ~= "" and GC.Util.Trim(entry.professionKey) ~= "" then
            self.pendingWants[WantKey(entry.crafter, entry.professionKey)] = {
                crafter = entry.crafter,
                professionKey = entry.professionKey,
                at = now,
            }
        end
    end
    if GC.Sync and GC.Sync.WakeProgress then
        GC.Sync:WakeProgress()
    end
end

function GC.Workshop:ClearWanted(crafter, professionKey)
    if not self.pendingWants then
        return
    end
    self.pendingWants[WantKey(crafter, professionKey)] = nil
end

function GC.Workshop:GetPendingWantCount()
    local now = GC.Util.Now()
    local count = 0
    for key, want in pairs(self.pendingWants or {}) do
        if (now - (tonumber(want.at) or 0)) > WANT_TTL then
            self.pendingWants[key] = nil
        else
            count = count + 1
        end
    end
    return count
end

-- Welche Berufe genau noch fehlen - fuer den Tooltip des Balkens.
function GC.Workshop:GetPendingWantNames(maximum)
    local names = {}
    local now = GC.Util.Now()
    for _, want in pairs(self.pendingWants or {}) do
        if (now - (tonumber(want.at) or 0)) <= WANT_TTL then
            names[#names + 1] = GC.Util.PlayerShortName(want.crafter)
        end
    end
    table.sort(names)
    while #names > (tonumber(maximum) or 6) do
        table.remove(names)
    end
    return names
end

-- Manifest fuer den Gildenkanal: je Beruf des Accounts nur Hersteller,
-- Zeitstempel, Anzahl und Fingerabdruck. Wer nichts Neues hat, kostet damit ein
-- Paket pro Login statt einer vollen Schluesselliste.
function GC.Workshop:BuildKeyManifestMessages()
    local records = {}
    for _, entry in ipairs(self:GetAccountProfessions()) do
        local profession = entry.profession
        local fingerprintHash = profession.fingerprintHash
            or FingerprintHash(profession.fingerprint or RecipeFingerprint(profession))
        records[#records + 1] = table.concat({
            (GC.Util.Trim(entry.crafter):gsub(",", "")),
            profession.key,
            tostring(tonumber(profession.updatedAt) or 0),
            tostring(RecipeCount(profession)),
            fingerprintHash,
        }, ",")
    end
    if #records == 0 then
        return {}
    end
    table.sort(records)

    local header = BuildMessage({ "W", GC.Constants.SCHEMA_VERSION, "KM", "" })
    local payloadLimit = math.min(MAX_PAYLOAD_BYTES,
        GC.Constants.MAX_CHAT_BYTES - #header)
    local messages = {}
    local current = ""
    for _, record in ipairs(records) do
        local candidate = current == "" and record or (current .. ";" .. record)
        if #candidate > payloadLimit and current ~= "" then
            messages[#messages + 1] = BuildMessage({
                "W", GC.Constants.SCHEMA_VERSION, "KM", current,
            })
            current = record
        else
            current = candidate
        end
    end
    if current ~= "" then
        messages[#messages + 1] = BuildMessage({
            "W", GC.Constants.SCHEMA_VERSION, "KM", current,
        })
    end
    return messages
end

function GC.Workshop:SendKeyManifest()
    if not GC.Sync or not IsInGuild or not IsInGuild() then
        return false
    end
    local messages = self:BuildKeyManifestMessages()
    if #messages == 0 then
        return false
    end
    for _, message in ipairs(messages) do
        if #message <= GC.Constants.MAX_CHAT_BYTES then
            GC.Sync:SendBulk(message, "GUILD")
        end
    end
    return true
end

-- Fordert die Schluesselliste eines fremden Berufs an - gestreut und nur einmal,
-- damit nicht alle gleichzeitig dasselbe verlangen.
function GC.Workshop:ScheduleKeyListRequest(wanted)
    self.suppressedKeyRequests = self.suppressedKeyRequests or {}
    local now = GC.Util.Now()
    local pending = {}
    for _, entry in ipairs(wanted or {}) do
        local suppressKey = GC.Util.PlayerKey(entry.crafter) .. "|" .. entry.professionKey
        local suppressedAt = self.suppressedKeyRequests[suppressKey]
        if not suppressedAt or (now - suppressedAt) > MISSING_REQUEST_SUPPRESS then
            pending[#pending + 1] = entry
        end
    end
    if #pending == 0 then
        return false
    end
    if not C_Timer or type(C_Timer.After) ~= "function" then
        return self:SendKeyListRequest(pending)
    end
    C_Timer.After(1 + math.random() * MISSING_REQUEST_DELAY, function()
        GC.Workshop:SendKeyListRequest(pending)
    end)
    return true
end

function GC.Workshop:SendKeyListRequest(wanted)
    if not GC.Sync then
        return false
    end
    self.suppressedKeyRequests = self.suppressedKeyRequests or {}
    local now = GC.Util.Now()
    local byCrafter = {}
    local order = {}
    for _, entry in ipairs(wanted or {}) do
        local suppressKey = GC.Util.PlayerKey(entry.crafter) .. "|" .. entry.professionKey
        local suppressedAt = self.suppressedKeyRequests[suppressKey]
        if not suppressedAt or (now - suppressedAt) > MISSING_REQUEST_SUPPRESS then
            self.suppressedKeyRequests[suppressKey] = now
            if not byCrafter[entry.crafter] then
                byCrafter[entry.crafter] = {}
                order[#order + 1] = entry.crafter
            end
            local list = byCrafter[entry.crafter]
            list[#list + 1] = entry.professionKey
        end
    end
    if #order == 0 then
        return false
    end
    for _, crafter in ipairs(order) do
        local message = BuildMessage({
            "W",
            GC.Constants.SCHEMA_VERSION,
            "KR",
            GC.Util.SafeChatText(GC.Util.Trim(crafter), 40),
            table.concat(byCrafter[crafter], ","),
        })
        if #message <= GC.Constants.MAX_CHAT_BYTES then
            GC.Sync:SendBulk(message, "GUILD")
        end
    end
    return true
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

local function SupportsKeyListWorkshop(sender)
    local user = GC.Sync and GC.Sync.GetAddonUser and GC.Sync:GetAddonUser(sender)
    local capabilities = user and tostring(user.capabilities or "") or ""
    return ("," .. capabilities .. ","):find(",workshop4,", 1, true) ~= nil
end

local function SupportsReliableWorkshop(sender)
    local user = GC.Sync and GC.Sync.GetAddonUser and GC.Sync:GetAddonUser(sender)
    local capabilities = user and tostring(user.capabilities or "") or ""
    return ("," .. capabilities .. ","):find(",workshop3,", 1, true) ~= nil
end

function GC.Workshop:ReceiveSync(fields, sender, distribution)
    local operation = fields[3]
    if operation == "Q" then
        local senderKey = GC.Util.PlayerKey(sender)
        local now = GC.Util.Now()
        self.requestReplies = self.requestReplies or {}
        local lastReply = self.requestReplies[senderKey]
        if senderKey == ""
            or (lastReply and (now - lastReply) < MIN_REQUEST_REPLY_INTERVAL) then
            return
        end
        self.requestReplies[senderKey] = now
        -- Der Abgleich läuft über den Gildenkanal, weil Addon-Flüster in
        -- manchen Umgebungen nicht ankommen. Entscheidend ist, was *dieser*
        -- Fragende versteht: kennt er Manifeste, bekommt er nur eines (ein
        -- Paket) und fordert daraus gezielt an, was ihm fehlt. Nur ein Client
        -- ohne Manifest-Verständnis braucht den vollen Bestand. Früher
        -- entschied das die Gilde als Ganzes - ein einziger veralteter Eintrag
        -- ließ dann jeden Abgleich zum Vollversand werden.
        if SupportsKeyListWorkshop(sender) then
            self:SendKeyManifest()
        else
            self:QueueAllProfessions(SupportsCompactWorkshop(sender), nil, nil, true)
        end
        return
    elseif operation == "M" then
        local senderKey = GC.Util.PlayerKey(sender)
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
    elseif operation == "KM" then
        -- Ein fremdes Manifest. Angefordert wird nur, was hier nachweislich
        -- fehlt oder veraltet ist; unveraenderte Berufe kosten null Pakete.
        local wanted = {}
        local crafters = self:GetGuildWorkshop().crafters
        for record in tostring(fields[4] or ""):gmatch("[^;]+") do
            local crafter, professionKey, updatedText, countText, fingerprint =
                record:match("^([^,]+),([^,]+),(%d+),(%d+),(%d+)$")
            local updatedAt = tonumber(updatedText)
            local recipeCount = tonumber(countText)
            if crafter and professionKey and updatedAt and recipeCount
                and #crafter <= 60 and #professionKey <= 80 and #fingerprint <= 20 then
                local known = crafters[GC.Util.PlayerKey(crafter)]
                local knownProfession = known and known.professions
                    and known.professions[professionKey]
                local stale = not knownProfession
                    or (tonumber(knownProfession.updatedAt) or 0) ~= updatedAt
                    or RecipeKeyCount(knownProfession) ~= recipeCount
                    or tostring(knownProfession.fingerprintHash or "") ~= fingerprint
                if stale then
                    wanted[#wanted + 1] = { crafter = crafter, professionKey = professionKey }
                end
            end
        end
        if #wanted > 0 then
            -- Erst vormerken, dann anfragen: Vorgemerkt ist die Luecke auch
            -- dann, wenn die Anfrage gerade unterdrueckt wird, weil ein anderer
            -- sie schon gestellt hat.
            self:NoteWanted(wanted)
            self:ScheduleKeyListRequest(wanted)
        end
        return
    elseif operation == "KR" then
        -- Jemand verlangt die Schluesselliste eines Berufs. Angesprochen ist der
        -- genannte Hersteller; auch eine fremde Anfrage unterdrueckt die eigene.
        local wantedCrafter = GC.Util.Trim(fields[4] or "")
        local wantedKey = GC.Util.PlayerKey(wantedCrafter)
        self.suppressedKeyRequests = self.suppressedKeyRequests or {}
        local requested = {}
        for professionKey in tostring(fields[5] or ""):gmatch("[^,]+") do
            requested[NormalizeKey(professionKey)] = true
            self.suppressedKeyRequests[wantedKey .. "|" .. NormalizeKey(professionKey)] =
                GC.Util.Now()
        end
        if wantedKey == "" or not next(requested) then
            return
        end
        for _, entry in ipairs(self:GetAccountProfessions()) do
            if GC.Util.PlayerKey(entry.crafter) == wantedKey
                and requested[entry.profession.key] then
                self:QueueKeyList(entry.profession, entry.crafter)
            end
        end
        return
    elseif operation == "N" then
        -- Jemandem fehlen Rezeptdaten. Angesprochen ist genau der genannte
        -- Hersteller; die Antwort geht dennoch ueber den Gildenkanal, weil in
        -- der Regel mehreren dasselbe Rezept fehlt.
        local wantedCrafter = GC.Util.Trim(fields[4] or "")
        local requestedKeys = DecodeRecipeKeys(fields[5])
        self.suppressedRequests = self.suppressedRequests or {}
        PruneSuppressed(self.suppressedRequests, MISSING_REQUEST_SUPPRESS)
        local now = GC.Util.Now()
        for _, recipeKey in ipairs(requestedKeys) do
            -- Wer dieselbe Anfrage schon unterwegs sieht, stellt sie nicht
            -- erneut. Sonst fragen bei hundert Mitgliedern hundert Clients
            -- dasselbe Rezept nach.
            self.suppressedRequests[recipeKey] = now
        end
        local wantedKey = GC.Util.PlayerKey(wantedCrafter)
        if wantedKey == "" or #requestedKeys == 0 then
            return
        end
        local filter = {}
        for _, recipeKey in ipairs(requestedKeys) do
            filter[recipeKey] = true
        end
        for _, entry in ipairs(self:GetAccountProfessions()) do
            if GC.Util.PlayerKey(entry.crafter) == wantedKey then
                self:QueueProfessionSync(entry.profession, true, nil, nil, entry.crafter, filter)
            end
        end
        return
    end
    if operation ~= "D" and operation ~= "C" and operation ~= "K" then
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

    local senderKey = GC.Util.PlayerKey(sender)
    if senderKey == "" then
        return
    end
    local crafterName = craftedBy ~= "" and craftedBy or sender
    local crafterKey = GC.Util.PlayerKey(crafterName)
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

    self.incoming[incomingKey] = nil
    self.completedIncoming[incomingKey] = now

    local receivedKeys = {}
    local receivedRecipeCount = 0
    if operation == "K" then
        -- Nur "wer kann was". Die Schluesselliste ist byteweise geteilt und wird
        -- deshalb erst zusammengesetzt und dann gelesen. Die Rezeptdaten selbst
        -- stehen im Katalog, weil sie fuer alle identisch sind.
        local assembled = {}
        for partIndex = 1, incoming.total do
            assembled[partIndex] = incoming.parts[partIndex] or ""
        end
        receivedKeys = DecodeRecipeKeys(table.concat(assembled))
        -- Auch ohne uebertragene Rezeptdaten sind das die Rezepte, die dieser
        -- Hersteller ab jetzt nachweislich kann - der Status soll sie nennen.
        receivedRecipeCount = #receivedKeys
    else
        -- Rezeptpakete sind an Datensatzgrenzen geteilt, ohne das Trennzeichen
        -- mitzunehmen. Sie werden deshalb Paket fuer Paket gelesen; ein
        -- Zusammensetzen wuerde den letzten Datensatz eines Pakets mit dem
        -- ersten des naechsten verschmelzen.
        for partIndex = 1, incoming.total do
            for record in tostring(incoming.parts[partIndex] or ""):gmatch("[^;]+") do
                local recipe = operation == "C"
                    and DecodeCompactRecipeRecord(record, professionName)
                    or DecodeRecipeRecord(record, professionName)
                if recipe then
                    self:StoreCatalogRecipe(recipe, professionKey, professionName)
                    receivedKeys[#receivedKeys + 1] = recipe.key
                    receivedRecipeCount = receivedRecipeCount + 1
                end
            end
        end
    end

    -- Eine gezielte Nachlieferung enthaelt nur einzelne Rezepte und darf den
    -- vollstaendigen Herstellerindex nicht auf diese wenigen zusammenstreichen.
    local existing = self:GetGuildWorkshop().crafters[crafterKey]
    local existingProfession = existing and existing.professions
        and existing.professions[professionKey]
    local isPartialDelivery = operation ~= "K" and existingProfession
        and existingProfession.recipeKeys
        and RecipeKeyCount(existingProfession) > #receivedKeys
    if isPartialDelivery then
        for recipeKey in pairs(existingProfession.recipeKeys) do
            receivedKeys[#receivedKeys + 1] = recipeKey
        end
    end

    self:ClaimRecipes({
        crafter = crafterName,
        sharedBy = sender,
        professionKey = professionKey,
        professionName = professionName,
        recipeKeys = receivedKeys,
        updatedAt = incoming.updatedAt,
        fingerprintHash = incoming.fingerprintHash ~= "" and incoming.fingerprintHash or nil,
    })

    if operation == "K" then
        self:ScheduleMissingRecipeRequest(crafterName, receivedKeys)
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
            local crafterKey = GC.Util.PlayerKey(crafterName)
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

-- Der Katalogaufbau ist der teuerste Vorgang der ganzen Werkstatt: Er laeuft
-- ueber die eigenen Rezepte, die aller Twinks desselben Accounts und den
-- kompletten Gildenindex und kopiert dabei jede Reagenzienliste. Bei mehreren
-- tausend Rezepten ist das nichts, was pro Tastendruck passieren darf - und
-- genau das tat es: die Suche baute ihn ueber GetSummary und GetCatalog gleich
-- zweimal je Zeichen neu auf. Gebaut wird jetzt einmal; gesucht wird im
-- Ergebnis. Neu entsteht der Index nur, wenn sich die Daten wirklich geaendert
-- haben - dafuer sorgt InvalidateCatalog an den vier schreibenden Stellen.
function GC.Workshop:GetCatalogIndex()
    if self.catalogIndex then
        return self.catalogIndex
    end

    local catalog = {}
    local ownName = GC:GetPlayerFullName()
    AddCrafterToCatalog(catalog, ownName, self:GetOwnData().professions)
    -- Weitere Charaktere desselben Accounts: ihre Berufe liegen lokal in der
    -- gemeinsamen SavedVariables. So sieht jeder eigene Charakter auch die
    -- Berufe der anderen eigenen Charaktere (z. B. die Verzauberkunst des
    -- Magier-Twinks auf dem Main), ohne auf eine Netzwerksynchronisierung zu
    -- warten - das Addon kennt die Daten ja bereits.
    local ownKey = GC.Util.PlayerKey(ownName)
    for characterKey, character in pairs((GC.DB.data and GC.DB.data.characters) or {}) do
        local workshop = type(character) == "table" and character.workshop
        local characterName = (type(character) == "table" and character.fullName) or characterKey
        if workshop and workshop.professions
            and GC.Util.PlayerKey(characterName) ~= ownKey then
            AddCrafterToCatalog(catalog, characterName, workshop.professions)
        end
    end
    -- Der gildenweite Teil: der Katalog liefert die Rezeptdaten, der
    -- Herstellerindex nur noch die Namen. Fehlt zu einem gemeldeten Rezept die
    -- Datenzeile noch, entsteht der Eintrag trotzdem - Name und Beruf loest der
    -- Client aus der Item- beziehungsweise Zauber-ID selbst auf, allein die
    -- Reagenzien bleiben leer, bis die Nachlieferung eintrifft.
    local guildWorkshop = self:GetGuildWorkshop()
    for _, crafter in pairs(guildWorkshop.crafters) do
        local crafterKey = GC.Util.PlayerKey(crafter.name)
        for _, profession in pairs(crafter.professions or {}) do
            for recipeKey in pairs(profession.recipeKeys or {}) do
                local known = guildWorkshop.catalog[recipeKey]
                local entry = catalog[recipeKey]
                if not entry then
                    entry = {
                        key = recipeKey,
                        name = ResolveRecipeName(recipeKey, known and known.name),
                        itemID = known and known.itemID,
                        profession = (known and known.profession)
                            or profession.name or "Unbekannt",
                        reagents = GC.Util.DeepCopy((known and known.reagents) or {}),
                        crafters = {},
                        crafterKeys = {},
                    }
                    catalog[recipeKey] = entry
                elseif #entry.reagents == 0 and known and #(known.reagents or {}) > 0 then
                    entry.reagents = GC.Util.DeepCopy(known.reagents)
                end
                if not entry.crafterKeys[crafterKey] then
                    entry.crafterKeys[crafterKey] = true
                    entry.crafters[#entry.crafters + 1] = GC.Util.PlayerShortName(crafter.name)
                end
            end
        end
    end

    -- Suchtext und Berufsschluessel entstehen einmal hier und nicht bei jedem
    -- Tastendruck erneut fuer jeden der tausenden Eintraege.
    local entries = {}
    local byKey = {}
    for _, entry in pairs(catalog) do
        table.sort(entry.crafters)
        entry.searchable = NormalizeKey(
            entry.name .. " " .. entry.profession .. " " .. table.concat(entry.crafters, " "))
        entry.professionKey = NormalizeKey(entry.profession)
        entries[#entries + 1] = entry
        byKey[entry.key] = entry
    end
    table.sort(entries, function(left, right)
        if left.profession ~= right.profession then
            return left.profession < right.profession
        end
        return left.name < right.name
    end)

    -- Der Schluesselindex haengt bewusst NICHT am Ergebnisarray: Aufrufer
    -- duerfen weiter mit pairs darueber laufen, ohne ein Zusatzfeld zu treffen.
    self.catalogByKey = byKey
    self.catalogIndex = entries
    return entries
end

-- Verwirft den zwischengespeicherten Index.
--
-- REGEL FUER NEUE SCHREIBSTELLEN: Wer an den eigenen Berufen, am Herstellerindex
-- oder am Rezeptkatalog etwas aendert, ruft das hier auf. Ein pauschales Netz an
-- WORKSHOP_UPDATED gab es kurzzeitig, es ist wieder weg: Dieses Ereignis feuert
-- auch fuer reine Synchronisierungszaehler, und bei geoeffneter Werkstatt wurde
-- der Katalog waehrend eines Transfers dutzendfach neu gebaut - genau der
-- Aufwand, den der Cache vermeiden soll.
--
-- Die Wanderungen in GetOwnData und GetGuildWorkshop brauchen keinen Aufruf:
-- Sie laufen einmalig INNERHALB des Aufbaus, ihr Ergebnis steht also schon im
-- frisch gebauten Index.
function GC.Workshop:InvalidateCatalog()
    self.catalogIndex = nil
    self.catalogByKey = nil
    self.catalogSummary = nil
end

-- Ein einzelnes Rezept nach Schluessel. Vorher suchten die Aufrufer linear
-- durch den kompletten Katalog - bei jedem Auftragsdialog einmal komplett.
function GC.Workshop:GetCatalogEntry(recipeKey)
    self:GetCatalogIndex()
    return self.catalogByKey[tostring(recipeKey or "")]
end

function GC.Workshop:GetCatalog(query, professionFilter, favoritesOnly)
    local entries = self:GetCatalogIndex()
    query = NormalizeKey(query)
    professionFilter = NormalizeKey(professionFilter)
    if query == "" and professionFilter == "" and not favoritesOnly then
        return entries
    end

    local favorites = GC.DB:GetSettings().workshopFavorites or {}
    local matches = {}
    for _, entry in ipairs(entries) do
        local professionMatches = professionFilter == "" or entry.professionKey == professionFilter
        local favoriteMatches = not favoritesOnly or favorites[entry.key] == true
        if professionMatches and favoriteMatches
            and (query == "" or entry.searchable:find(query, 1, true)) then
            matches[#matches + 1] = entry
        end
    end
    return matches
end

-- Wer die Gilde verlaesst, verschwindet mit seinen Rezepten aus der Werkstatt.
-- Der Roster allein reicht als Maßstab aber nicht: Twinks stehen nie im
-- Gildenroster, und ihre Berufe werden seit 0.9.26 bewusst geteilt. Ein Eintrag
-- faellt deshalb nur, wenn weder der Hersteller selbst noch das Gildenmitglied,
-- das ihn eingebracht hat, noch im Roster steht. Solange der Roster nach dem
-- Login leer ist, wird gar nichts entfernt.
function GC.Workshop:PruneDepartedCrafters()
    if #GC.Roster.members == 0 then
        return 0
    end
    local workshop = self:GetGuildWorkshop()
    local ownKeys = {}
    for characterKey, character in pairs((GC.DB.data and GC.DB.data.characters) or {}) do
        local characterName = (type(character) == "table" and character.fullName) or characterKey
        ownKeys[GC.Util.PlayerKey(characterName)] = true
    end
    ownKeys[GC.Util.PlayerKey(GC:GetPlayerFullName())] = true

    local removed = 0
    for crafterKey, crafter in pairs(workshop.crafters) do
        local name = type(crafter) == "table" and crafter.name or crafterKey
        local sharedBy = type(crafter) == "table" and crafter.sharedBy or nil
        local keep = ownKeys[crafterKey]
            or GC.Roster:IsGuildMember(name)
            or (sharedBy and GC.Roster:IsGuildMember(sharedBy))
        if not keep then
            workshop.crafters[crafterKey] = nil
            removed = removed + 1
        end
    end

    -- Rezepte, die niemand mehr kann, muellen den Katalog nicht zu.
    if removed > 0 then
        local stillClaimed = {}
        for _, crafter in pairs(workshop.crafters) do
            for _, profession in pairs((type(crafter) == "table" and crafter.professions) or {}) do
                for recipeKey in pairs(profession.recipeKeys or {}) do
                    stillClaimed[recipeKey] = true
                end
            end
        end
        for _, profession in pairs(self:GetOwnData().professions) do
            for recipeKey in pairs(profession.recipes or {}) do
                stillClaimed[recipeKey] = true
            end
        end
        for recipeKey in pairs(workshop.catalog) do
            if not stillClaimed[recipeKey] then
                workshop.catalog[recipeKey] = nil
            end
        end
        self:InvalidateCatalog()
        GC:FireCallback("WORKSHOP_UPDATED")
    end
    return removed
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

-- Die Kennzahlen haengen ausschliesslich am Index. Sie werden deshalb mit ihm
-- zusammen gehalten, statt bei jedem Tastendruck in der Suche neu ueber alle
-- Rezepte und deren Hersteller zu laufen.
function GC.Workshop:GetSummary()
    if self.catalogSummary and self.catalogIndex then
        return self.catalogSummary
    end
    local entries = self:GetCatalogIndex()
    local crafters = {}
    local professions = {}
    for _, entry in ipairs(entries) do
        -- Berufe nach normalisiertem Schluessel zaehlen, nicht nach dem
        -- Namens-String: Sonst zaehlen die Alt-Schreibweise "Alchemie" neben
        -- "Alchimie" und der "Unbekannt"-Platzhalter als eigene Berufe -
        -- die Karte zeigte 13 Berufe, wo TBC hoechstens 12 kennt.
        local professionKey = NormalizeKey(entry.profession)
        if professionKey == NormalizeKey("Alchemie") then
            professionKey = NormalizeKey("Alchimie")
        end
        if professionKey ~= "" and professionKey ~= NormalizeKey("Unbekannt") then
            professions[professionKey] = true
        end
        for _, crafter in ipairs(entry.crafters) do
            crafters[GC.Util.PlayerKey(crafter)] = true
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
    self.catalogSummary = {
        recipes = #entries,
        crafters = crafterCount,
        professions = professionCount,
    }
    return self.catalogSummary
end

-- GET_ITEM_INFO_RECEIVED meldet jeden einzelnen Gegenstand, den der Client in
-- seinen Item-Cache nachlaedt - beim Login mit kaltem Cache sind das tausende
-- Ereignisse in kurzer Zeit. Jedes davon feuerte bisher WORKSHOP_UPDATED, und
-- bei offener Werkstattseite zeichnete jedes einzelne die komplette Seite neu.
-- Fuer die Oberflaeche zaehlt nur "demnaechst neu zeichnen", nicht jedes Item:
-- gesammelt wird auf hoechstens zwei Auffrischungen pro Sekunde.
local NAME_REFRESH_DELAY = 0.5

function GC.Workshop:ScheduleNameRefresh()
    if self.nameRefreshPending then
        return
    end
    -- Nachgeladene Namen aendern Anzeige UND Suchtext, der Index muss also weg.
    if not C_Timer or type(C_Timer.After) ~= "function" then
        self:InvalidateCatalog()
        GC:FireCallback("WORKSHOP_UPDATED")
        return
    end
    self.nameRefreshPending = true
    C_Timer.After(NAME_REFRESH_DELAY, function()
        GC.Workshop.nameRefreshPending = false
        GC.Workshop:InvalidateCatalog()
        GC:FireCallback("WORKSHOP_UPDATED")
    end)
end

local workshopEvents = CreateFrame("Frame")
workshopEvents:RegisterEvent("TRADE_SKILL_SHOW")
workshopEvents:RegisterEvent("TRADE_SKILL_UPDATE")
workshopEvents:RegisterEvent("CRAFT_SHOW")
workshopEvents:RegisterEvent("CRAFT_UPDATE")
workshopEvents:RegisterEvent("GET_ITEM_INFO_RECEIVED")
workshopEvents:SetScript("OnEvent", function(_, event)
    if event == "GET_ITEM_INFO_RECEIVED" then
        GC.Workshop:ScheduleNameRefresh()
    else
        if event == "TRADE_SKILL_SHOW" then
            GC.Workshop.preparedProfession = nil
        end
        GC.Workshop:ScheduleScan()
    end
end)

-- Der Roster wird nach jeder Gildenaktualisierung neu gelesen; das Aufraeumen
-- haengt sich dort an, bleibt aber gedrosselt, weil das Ereignis oft feuert.
GC:RegisterCallback("ROSTER_UPDATED", GC.Workshop, function(self)
    local now = GC.Util.Now()
    if (now - (self.lastDepartedPruneAt or 0)) < DEPARTED_PRUNE_INTERVAL then
        return
    end
    self.lastDepartedPruneAt = now
    self:PruneDepartedCrafters()
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
            -- ... und den eigenen Bestand ankündigen. Gesendet wird nur das
            -- Manifest: Hersteller, Zeitstempel, Anzahl und Fingerabdruck je
            -- Beruf. Wer davon etwas nicht hat, fordert es an - wer alles kennt,
            -- verursacht keinen weiteren Verkehr. Ein Login ohne Änderungen
            -- kostet damit ein Paket statt einer vollen Schlüsselliste.
            -- Nur das Manifest, nie der volle Bestand: ein Login oder /reload
            -- kostet damit ein Paket statt achtzig. Wer wirklich etwas nicht
            -- hat, fordert es aus dem Manifest gezielt an, und ein Client ohne
            -- Manifest-Verständnis bekommt beim eigenen "Q" den vollen Bestand.
            if IsInGuild and IsInGuild() then
                GC.Workshop:SendKeyManifest()
            end
        end)
    end
end)
