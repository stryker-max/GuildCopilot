local _, GC = ...

GC.GearAudit = {
    queue = {},
    active = nil,
    scanning = false,
    selectedName = nil,
    status = "",
    equipmentIncoming = {},
}

local INSPECT_INTERVAL = 1.5
local INSPECT_TIMEOUT = 4
local AUDIT_TTL = 7 * 24 * 60 * 60
local AUTO_SELF_DELAY = 3
local AUTO_SELF_LOGIN_DELAY = 8
local MAX_SELF_READ_RETRIES = 5
local EQUIPMENT_CHUNK_BYTES = 165
local EQUIPMENT_MAX_PARTS = 10
local EQUIPMENT_MAX_INCOMING = 40
local EQUIPMENT_INCOMING_TTL = 5 * 60
local EQUIPMENT_REPLY_INTERVAL = 30
local EQUIPMENT_SEND_INTERVAL = 0.45
local EQUIPMENT_MAX_RETRIES = 5

local function WholeNumber(value, minimum, maximum)
    value = tonumber(value)
    if not value or value % 1 ~= 0 or value < minimum or value > maximum then
        return nil
    end
    return value
end

local function GearSlotByID()
    local slots = {}
    for _, slot in ipairs(GC.GearSlots) do
        slots[slot.id] = slot
    end
    return slots
end

-- item:itemID:enchantID:gem1:gem2:gem3:gem4:...
function GC.GearAudit:ParseItemLink(link)
    local itemString = tostring(link or ""):match("|Hitem:([%-%d:]*)")
    if not itemString or itemString == "" then
        return nil
    end

    local parts = {}
    for value in (itemString .. ":"):gmatch("([^:]*):") do
        parts[#parts + 1] = tonumber(value) or 0
    end
    if (parts[1] or 0) <= 0 then
        return nil
    end

    local gems = {}
    local filledGems = 0
    for index = 3, 6 do
        local gemID = parts[index] or 0
        gems[#gems + 1] = gemID
        if gemID > 0 then
            filledGems = filledGems + 1
        end
    end
    return {
        itemID = parts[1],
        enchantID = parts[2] or 0,
        gems = gems,
        filledGems = filledGems,
    }
end

-- === Verzauberung im Klartext ==============================================
--
-- Statt eine eigene Enchant-Datenbank zu pflegen, lässt sich WoW die
-- Verzauberung selbst auflösen: Der Tooltip wird zweimal aufgebaut, einmal mit
-- und einmal mit auf 0 gesetzter Verzauberung. Die Zeile, die nur in der
-- ersten Fassung vorkommt, ist die Verzauberung – in der Sprache des Clients
-- und ohne jede Pflege.

local SCAN_TOOLTIP_NAME = "GuildCopilotScanTooltip"
local scanTooltip

local function TooltipLines(link)
    if not link or link == "" or type(CreateFrame) ~= "function" then
        return nil
    end
    if not scanTooltip then
        local created = pcall(function()
            scanTooltip = CreateFrame("GameTooltip", SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
        end)
        if not created or not scanTooltip then
            return nil
        end
    end

    if scanTooltip.SetOwner and UIParent then
        pcall(scanTooltip.SetOwner, scanTooltip, UIParent, "ANCHOR_NONE")
    end
    if scanTooltip.ClearLines then
        pcall(scanTooltip.ClearLines, scanTooltip)
    end
    if not scanTooltip.SetHyperlink or not pcall(scanTooltip.SetHyperlink, scanTooltip, link) then
        return nil
    end

    local ok, count = pcall(scanTooltip.NumLines, scanTooltip)
    count = ok and tonumber(count) or 0
    local lines = {}
    for index = 1, count do
        local fontString = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. index]
        local text = fontString and fontString.GetText and fontString:GetText()
        if text and text ~= "" then
            lines[#lines + 1] = text
        end
    end
    return lines
end

-- Leere Sockel: zuerst aus dem Tooltip, weil GetItemStats in Classic als
-- veraltet gilt und dort nicht zuverlaessig antwortet. WoW liefert die
-- Beschriftungen leerer Sockel als globale, bereits uebersetzte Zeichenketten
-- (EMPTY_SOCKET_RED und so weiter) - der Abgleich bleibt damit
-- sprachunabhaengig. Nur wenn kein Tooltip zustande kommt, wird gerechnet.
local EMPTY_SOCKET_KEYS = {
    "EMPTY_SOCKET_RED",
    "EMPTY_SOCKET_YELLOW",
    "EMPTY_SOCKET_BLUE",
    "EMPTY_SOCKET_META",
    "EMPTY_SOCKET_PRISMATIC",
    "EMPTY_SOCKET_NO_COLOR",
}

local function CountSocketLines(lines)
    local labels = {}
    for _, key in ipairs(EMPTY_SOCKET_KEYS) do
        local label = _G[key]
        if type(label) == "string" and label ~= "" then
            labels[label] = true
        end
    end
    if not next(labels) then
        return nil
    end

    local count = 0
    for _, text in ipairs(lines) do
        if labels[GC.Util.Trim(text)] then
            count = count + 1
        end
    end
    return count
end

function GC.GearAudit:CountEmptySockets(link, filledGems)
    local lines = TooltipLines(link)
    if lines and #lines > 0 then
        local fromTooltip = CountSocketLines(lines)
        if fromTooltip then
            return fromTooltip
        end
    end

    if type(GetItemStats) ~= "function" then
        return nil
    end
    local ok, stats = pcall(GetItemStats, link)
    if not ok or type(stats) ~= "table" then
        return nil
    end

    local sockets = 0
    for key, value in pairs(stats) do
        if tostring(key):find("EMPTY_SOCKET", 1, true) then
            sockets = sockets + (tonumber(value) or 0)
        end
    end
    if sockets == 0 then
        return 0
    end
    return math.max(0, sockets - (tonumber(filledGems) or 0))
end

local enchantNameCache = {}

function GC.GearAudit:ResolveEnchantName(link, enchantID)
    enchantID = tonumber(enchantID) or 0
    if enchantID <= 0 then
        return nil
    end
    -- Der Name haengt nur an der Verzauberung, nicht am Gegenstand. Einmal
    -- aufgeloest gilt er fuer den ganzen Raid.
    local cached = enchantNameCache[enchantID]
    if cached ~= nil then
        return cached ~= false and cached or nil
    end
    local enchanted = TooltipLines(link)
    if not enchanted or #enchanted == 0 then
        return nil
    end

    -- Ohne Vergleichsfassung ist kein Abgleich moeglich. Dann lieber nichts
    -- melden, als die erste Tooltipzeile - den Gegenstandsnamen - faelschlich
    -- als Verzauberung auszugeben.
    local plainLink = tostring(link):gsub("(|Hitem:%d+):[^:|]*", "%1:0", 1)
    local plain = TooltipLines(plainLink)
    if not plain or #plain == 0 then
        return nil
    end

    local remaining = {}
    for _, text in ipairs(plain) do
        remaining[text] = (remaining[text] or 0) + 1
    end
    for _, text in ipairs(enchanted) do
        if (remaining[text] or 0) > 0 then
            remaining[text] = remaining[text] - 1
        else
            local name = GC.Util.Trim(text)
            if name ~= "" then
                enchantNameCache[enchantID] = name
                return name
            end
        end
    end
    enchantNameCache[enchantID] = false
    return nil
end

-- === Gildeneigener Regelsatz ===============================================
--
-- Die Guides nennen Verzauberungen beim Namen, der Item-Link nur ihre ID.
-- Beides trifft sich im Client: Die Gilde bewertet eine erkannte Verzauberung
-- einmal in der Oberflaeche, das Addon merkt sich die ID und gibt sie
-- gildenweit weiter. Damit werden Empfehlungen als IDs versioniert statt als
-- abgeschriebener Guide-Text.

GC.GearAudit.RATING_ORDER = { "OPTIMAL", "SOLID", "IMPROVABLE" }

-- Lokale Automatik-Schalter. Der Zugriff geht bewusst ueber eine Funktion:
-- MergeDefaults ergaenzt den Zweig erst beim naechsten Login, und bis dahin
-- darf nichts auf eine fehlende Tabelle zugreifen.
function GC.GearAudit:GetAutoSettings()
    local settings = GC.DB:GetSettings()
    return settings and settings.gearAudit or {}
end

-- Ob eine vorhandene, aber nirgends bewertete Verzauberung als in Ordnung
-- durchgeht. Das erfindet keine Qualitaet: Es sagt nur "verzaubert ist besser
-- als nicht verzaubert" und haelt damit die Liste frei fuer die Funde, die
-- direkt aus dem Item-Link hervorgehen.
function GC.GearAudit:AcceptsUnratedEnchants()
    return self:GetAutoSettings().acceptUnratedEnchants ~= false
end

function GC.GearAudit:AuditsSelfAutomatically()
    return true
end

-- === Ausnahmen je Slot =====================================================
--
-- Nicht jeder angelegte Gegenstand gehoert zur Raidausruestung: Farmgear,
-- Widerstandsteile und Encounter-Sets werden bewusst nicht verzaubert. Ohne
-- Ausnahme meldet der Audit dort dauerhaft dieselben Funde, und wer diese
-- Meldung nicht abstellen kann, hoert irgendwann auf hinzusehen.
--
-- Die Ausnahme setzt jeder fuer seine eigene Ausruestung. Sie behauptet nichts
-- ueber Qualitaet, sie sagt nur: dieser Slot gehoert nicht zur Wertung.

function GC.GearAudit:GetSlotExceptions()
    local settings = GC.DB:GetSettings()
    if not settings.gearAudit then
        settings.gearAudit = {}
    end
    settings.gearAudit.slotExceptions = settings.gearAudit.slotExceptions or {}
    return settings.gearAudit.slotExceptions
end

function GC.GearAudit:IsSlotExempt(slotKey)
    local reason = self:GetSlotExceptions()[slotKey]
    return type(reason) == "string" and GC.GearExemptionReasonByKey[reason] ~= nil
end

-- reasonKey = nil hebt die Ausnahme wieder auf.
function GC.GearAudit:SetSlotException(slotKey, reasonKey)
    local known = false
    for _, slot in ipairs(GC.GearSlots) do
        if slot.key == slotKey then
            known = true
            break
        end
    end
    if not known then
        return false, "Unbekannter Ausrüstungsplatz."
    end
    if reasonKey ~= nil and not GC.GearExemptionReasonByKey[reasonKey] then
        return false, "Unbekannter Ausnahmegrund."
    end

    local exceptions = self:GetSlotExceptions()
    exceptions[slotKey] = reasonKey
    self:AuditSelf(true, true)
    GC:FireCallback("GEAR_AUDIT_UPDATED")
    if reasonKey then
        return true, "Der Ausrüstungsplatz zählt jetzt als "
            .. GC.GearExemptionReasonByKey[reasonKey].label .. " und wird nicht mehr gemeldet."
    end
    return true, "Der Ausrüstungsplatz wird wieder geprüft."
end

-- Reihum durch die Gruende und wieder zurueck auf "keine Ausnahme".
function GC.GearAudit:CycleSlotException(slotKey)
    local current = self:GetSlotExceptions()[slotKey]
    local nextReason = GC.GearExemptionReasons[1].key
    if current then
        nextReason = nil
        for index, reason in ipairs(GC.GearExemptionReasons) do
            if reason.key == current then
                local following = GC.GearExemptionReasons[index + 1]
                nextReason = following and following.key or nil
                break
            end
        end
    end
    return self:SetSlotException(slotKey, nextReason)
end

-- === Bewertungen je Spec ===================================================
--
-- Dieselbe Verzauberung ist nicht fuer jeden gleich gut: Feingefuehl auf der
-- Waffe ist fuer einen Waffen-Krieger etwas anderes als fuer einen
-- Schutz-Krieger. Bewertet wird deshalb je Spec.
--
-- Die alten Bewertungen ohne Spec-Bezug bleiben als Rueckfall bestehen. Wer
-- schon welche gepflegt hat, verliert sie nicht; sie greifen ueberall dort,
-- wo fuer die konkrete Spec nichts hinterlegt ist.

function GC.GearAudit:GetSpecRuleTable(specKey, create)
    if type(specKey) ~= "string" or specKey == "" then
        return nil
    end
    local guildData = GC.DB:GetGuild()
    guildData.enchantSpecRules = guildData.enchantSpecRules or {}
    if not guildData.enchantSpecRules[specKey] and create then
        guildData.enchantSpecRules[specKey] = {}
    end
    return guildData.enchantSpecRules[specKey]
end

function GC.GearAudit:GetSpecKeyForProfile(profile)
    local specKey = profile and (profile.raidSpecKey or profile.detectedSpecKey)
    if specKey and GC.SpecByKey[specKey] then
        return specKey
    end
    return nil
end

function GC.GearAudit:DescribeSpec(specKey)
    local spec = specKey and GC.SpecByKey[specKey]
    if not spec then
        return "ohne Spec"
    end
    local class = GC.Classes[spec.classFile]
    return (class and class.name or spec.classFile) .. " " .. spec.name
end

-- Erst die Spec, dann die allgemeine Regel.
function GC.GearAudit:GetGuildEnchantRule(enchantID, specKey)
    enchantID = tonumber(enchantID)
    if not enchantID then
        return nil
    end
    local key = tostring(enchantID)

    local specRules = self:GetSpecRuleTable(specKey, false)
    if specRules and specRules[key] then
        return specRules[key], true
    end
    return GC.DB:GetGuild().enchantRules[key], false
end

function GC.GearAudit:CanEditEnchantRules()
    return GC.Roster:CanEditGuildSettings()
end

-- Ohne specKey wird die allgemeine Regel gesetzt, mit specKey die der Spec.
function GC.GearAudit:SetEnchantRule(enchantID, verdict, enchantName, specKey)
    enchantID = tonumber(enchantID)
    if not enchantID or enchantID <= 0 then
        return false, "Für diesen Slot gibt es keine Verzauberung zu bewerten."
    end
    if not self:CanEditEnchantRules() then
        return false, "Dein Gildenrang darf den Regelsatz nicht ändern."
    end

    local scoped = specKey ~= nil and GC.SpecByKey[specKey] ~= nil
    local rules = scoped and self:GetSpecRuleTable(specKey, true) or GC.DB:GetGuild().enchantRules
    local scopeText = scoped and (" für " .. self:DescribeSpec(specKey)) or " für alle Specs"

    local key = tostring(enchantID)
    if not verdict then
        if not rules[key] then
            return false, "Für diese Verzauberung ist" .. scopeText .. " nichts hinterlegt."
        end
        rules[key] = nil
        self:OnEnchantRulesChanged()
        return true, "Bewertung" .. scopeText .. " entfernt."
    end
    if not GC.GearVerdicts[verdict] then
        return false, "Unbekannte Bewertung."
    end

    local count = 0
    for _ in pairs(rules) do
        count = count + 1
    end
    if not rules[key] and count >= 80 then
        return false, "Der Regelsatz" .. scopeText .. " ist voll."
    end

    rules[key] = {
        verdict = verdict,
        name = GC.Util.Trim(enchantName):gsub("[,:|]", " "),
        by = GC.Util.PlayerShortName(GC:GetPlayerFullName()),
        at = GC.Util.Now(),
    }
    self:OnEnchantRulesChanged()
    return true, (GC.Util.Trim(enchantName) ~= "" and enchantName or ("Verzauberung " .. enchantID))
        .. " gilt" .. scopeText .. " jetzt als " .. GC.GearVerdicts[verdict].label .. "."
end

-- Reihum durch die Stufen und wieder zurueck auf "keine Bewertung".
--
-- Weitergeschaltet wird immer die Regel der uebergebenen Spec. Eine allgemeine
-- Regel bleibt dabei unangetastet - sie wird nur ueberstimmt, sobald die Spec
-- eine eigene bekommt.
function GC.GearAudit:CycleEnchantRule(enchantID, enchantName, specKey)
    local scoped = specKey ~= nil and GC.SpecByKey[specKey] ~= nil
    local rules = scoped and self:GetSpecRuleTable(specKey, false) or GC.DB:GetGuild().enchantRules
    local current = rules and rules[tostring(tonumber(enchantID) or 0)]

    local nextVerdict = self.RATING_ORDER[1]
    if current then
        nextVerdict = nil
        for index, verdict in ipairs(self.RATING_ORDER) do
            if current.verdict == verdict then
                nextVerdict = self.RATING_ORDER[index + 1]
                break
            end
        end
    end
    return self:SetEnchantRule(enchantID, nextVerdict, enchantName, specKey)
end

-- Nur neu bewerten, ohne etwas zu senden. Diesen Weg nimmt der Empfang: Wer
-- ein Gildenprofil bekommt, darf es nicht sofort wieder verschicken, sonst
-- schaukeln sich zwei Clients gegenseitig auf.
function GC.GearAudit:ReapplyEnchantRules()
    for _, audit in pairs(GC.DB:GetGuild().gearAudits or {}) do
        for _, entry in ipairs(audit.slots or {}) do
            if entry.verdict ~= "EMPTY" and (tonumber(entry.enchantID) or 0) > 0 then
                local slot = { key = entry.key, enchantRequired = entry.required }
                entry.verdict, entry.reason = self:EvaluateEnchant(
                    slot, entry.enchantID, audit.role, entry.enchantName, audit.specKey)
            end
        end
        audit.unknownEnchants = 0
        for _, entry in ipairs(audit.slots or {}) do
            if entry.verdict == "UNKNOWN" then
                audit.unknownEnchants = audit.unknownEnchants + 1
            end
        end
    end
    GC:FireCallback("GEAR_AUDIT_UPDATED")
end

-- Eigene Aenderung: neu bewerten und gildenweit verteilen.
function GC.GearAudit:OnEnchantRulesChanged()
    self:ReapplyEnchantRules()
    GC.DB:GetGuild().profile.updatedAt = GC.Util.Now()
    if GC.Sync and GC.Sync.QueueGuildProfile then
        GC.Sync:QueueGuildProfile(true)
    end
end

function GC.GearAudit:GetRoleForProfile(profile)
    local specKey = profile and (profile.raidSpecKey or profile.detectedSpecKey)
    local spec = specKey and GC.SpecByKey[specKey]
    return spec and spec.role or nil
end

-- Welche Archetypen zu einer Spec gehoeren. Ohne bestaetigtes Profil bleibt das
-- leer - dann greift keine archetypgebundene Regel, statt zu raten.
function GC.GearAudit:GetArchetypesForSpec(specKey)
    if type(specKey) ~= "string" or specKey == "" then
        return nil
    end
    return GC.SpecArchetypes[specKey]
end

-- Die Phase, in der die Gilde gerade spielt. Sie entscheidet nur darueber, ob
-- eine Regel schon gilt: Was es im Spiel noch gar nicht gibt, darf nicht als
-- Empfehlung erscheinen.
function GC.GearAudit:GetContentPhase()
    local guildData = GC.DB:GetGuild()
    local stored = guildData and guildData.profile and guildData.profile.contentPhase
    if type(stored) == "string" and GC.ContentPhaseByKey[stored] then
        return stored
    end
    return GC.DefaultContentPhase
end

function GC.GearAudit:SetContentPhase(phaseKey)
    if not GC.ContentPhaseByKey[phaseKey] then
        return false, "Unbekannte Phase."
    end
    if not self:CanEditEnchantRules() then
        return false, "Dein Gildenrang darf die Phase nicht ändern."
    end
    local guildData = GC.DB:GetGuild()
    guildData.profile.contentPhase = phaseKey
    self:OnEnchantRulesChanged()
    return true, "Die Gilde spielt jetzt in Phase " .. GC.ContentPhaseByKey[phaseKey].label .. "."
end

-- Eine Regel aus einer spaeteren Phase gilt noch nicht.
function GC.GearAudit:RuleAppliesToPhase(rule)
    if not rule or not rule.phase then
        return true
    end
    local rulePhase = GC.ContentPhaseByKey[rule.phase]
    local guildPhase = GC.ContentPhaseByKey[self:GetContentPhase()]
    if not rulePhase or not guildPhase then
        return true
    end
    return rulePhase.order <= guildPhase.order
end

local function ListContains(list, value)
    if type(list) ~= "table" or value == nil then
        return false
    end
    for _, entry in ipairs(list) do
        if entry == value then
            return true
        end
    end
    return false
end

-- Passt die Regel zu Slot, Rolle, Archetyp und Phase des Geprueften?
--
-- Passt sie nicht, wird sie schlicht nicht angewendet. Sie gilt dann als
-- "keine Regel vorhanden" - eine Verzauberung wird nie deshalb schlecht
-- bewertet, weil eine fremde Regel nicht auf sie passt.
function GC.GearAudit:RuleApplies(rule, slot, role, specKey)
    if not rule then
        return false
    end
    if rule.slots and not ListContains(rule.slots, slot.key) then
        return false
    end
    if rule.roles and role and not ListContains(rule.roles, role) then
        return false
    end
    if rule.archetypes then
        local archetypes = self:GetArchetypesForSpec(specKey)
        if not archetypes then
            -- Ohne bekannte Spec laesst sich der Archetyp nicht bestimmen.
            -- Dann gilt eine archetypgebundene Regel bewusst nicht.
            return false
        end
        local matches = false
        for _, archetype in ipairs(archetypes) do
            if ListContains(rule.archetypes, archetype) then
                matches = true
                break
            end
        end
        if not matches then
            return false
        end
    end
    return self:RuleAppliesToPhase(rule)
end

function GC.GearAudit:EvaluateEnchant(slot, enchantID, role, enchantName, specKey)
    if (tonumber(enchantID) or 0) <= 0 then
        if slot.enchantRequired then
            return "MISSING", "Keine Verzauberung auf einem Pflichtslot."
        end
        return nil
    end

    local guildRule, fromSpec = self:GetGuildEnchantRule(enchantID, specKey)
    if guildRule and GC.GearVerdicts[guildRule.verdict] then
        local label = enchantName
        if not label or label == "" then
            label = guildRule.name ~= "" and guildRule.name or ("Verzauberung " .. enchantID)
        end
        -- Sichtbar machen, worauf die Bewertung beruht: auf der Spec des
        -- Geprueften oder auf einer Regel, die fuer alle gilt.
        local scope = fromSpec
            and ("Regel für " .. self:DescribeSpec(specKey))
            or "Regel für alle Specs"
        return guildRule.verdict, label .. "  •  " .. scope .. ", von " .. (guildRule.by or "?")
    end

    local rule = GC.EnchantRuleSet.rules[tonumber(enchantID)]
    -- Eine Regel, die auf diesen Spieler nicht passt (anderer Slot, andere
    -- Rolle, anderer Archetyp, spaetere Phase), wird behandelt, als gaebe es
    -- sie nicht. Sonst wuerde ein Schurken-Handschuhwert einen Magier
    -- schlechter dastehen lassen, obwohl ueber ihn gar nichts ausgesagt ist.
    if rule and not self:RuleApplies(rule, slot, role, specKey) then
        rule = nil
    end

    if not rule then
        local label = (enchantName and enchantName ~= "")
            and enchantName
            or ("Verzauberung " .. enchantID)
        if self:AcceptsUnratedEnchants() then
            return "SOLID", "Verzaubert: " .. label .. "  •  automatisch anerkannt"
        end
        if enchantName and enchantName ~= "" then
            return "UNKNOWN", "Verzaubert: " .. enchantName
        end
        return "UNKNOWN", "Verzauberung " .. enchantID .. " ist in der Regelliste noch nicht bewertet."
    end

    local reason = enchantName
    if not reason or reason == "" then
        reason = rule.name or ("Verzauberung " .. enchantID)
    end
    if rule.source and rule.source ~= "" then
        reason = reason .. "  •  Quelle: " .. rule.source
    end
    return rule.verdict or "UNKNOWN", reason
end

function GC.GearAudit:BuildAudit(playerName, classFile, readLink, source, readItemID, exceptions)
    -- Fuer die eigene Ausruestung gelten die selbst gesetzten Ausnahmen. Bei
    -- fremden Spielern kommen sie aus deren Snapshot; wer keine mitschickt,
    -- wird vollstaendig geprueft.
    if exceptions == nil and (source or "INSPECT") == "SELF" then
        exceptions = self:GetSlotExceptions()
    end
    exceptions = exceptions or {}
    local profile = GC.Roster:GetProfile(playerName)
    local role = self:GetRoleForProfile(profile)
    -- Die Spec entscheidet ueber die Bewertung und wandert deshalb mit in die
    -- Pruefung. Ohne bestaetigtes Profil bleibt sie leer, dann greifen nur die
    -- allgemeinen Regeln.
    local specKey = self:GetSpecKeyForProfile(profile)
    local audit = {
        name = GC.Util.PlayerShortName(playerName),
        classFile = classFile or (profile and profile.classFile),
        role = role,
        specKey = specKey,
        inspectedAt = GC.Util.Now(),
        source = source or "INSPECT",
        ruleVersion = GC.EnchantRuleSet.version,
        slots = {},
        missingEnchants = 0,
        emptySockets = 0,
        unknownEnchants = 0,
        emptySlots = 0,
        unreadableSlots = 0,
        exemptSlots = 0,
    }

    for _, slot in ipairs(GC.GearSlots) do
        local link = readLink(slot.id)
        local parsed = link and self:ParseItemLink(link)
        local entry = {
            key = slot.key,
            label = slot.label,
            itemLink = link,
        }

        entry.required = slot.enchantRequired == true

        -- Ein ausgenommener Slot wird weiter angezeigt, damit sichtbar bleibt,
        -- was dort steckt - er zaehlt nur nicht als Fund.
        local exemptionReason = exceptions[slot.key]
        if type(exemptionReason) == "string" and GC.GearExemptionReasonByKey[exemptionReason] then
            entry.exempt = exemptionReason
            entry.verdict = "EXEMPT"
            entry.reason = GC.GearExemptionReasonByKey[exemptionReason].label
                .. ": zählt nicht als Fund."
            if parsed then
                entry.itemID = parsed.itemID
                entry.enchantID = parsed.enchantID
            end
            audit.exemptSlots = audit.exemptSlots + 1
        elseif not parsed then
            local knownItemID
            if type(readItemID) == "function" then
                local ok, itemID = pcall(readItemID, slot.id)
                if ok then
                    knownItemID = WholeNumber(itemID, 1, 99999999)
                end
            end
            if knownItemID then
                entry.itemID = knownItemID
                entry.unreadable = true
                entry.verdict = "UNKNOWN"
                entry.reason = "Gegenstandsdaten noch nicht vollständig geladen."
                audit.unreadableSlots = audit.unreadableSlots + 1
            else
                entry.verdict = "EMPTY"
                entry.reason = "Kein Gegenstand angelegt."
                if slot.enchantRequired then
                    audit.emptySlots = audit.emptySlots + 1
                end
            end
        else
            entry.itemID = parsed.itemID
            entry.enchantID = parsed.enchantID
            entry.emptySockets = self:CountEmptySockets(link, parsed.filledGems) or 0
            entry.enchantName = self:ResolveEnchantName(link, parsed.enchantID)
            local verdict, reason = self:EvaluateEnchant(
                slot, parsed.enchantID, role, entry.enchantName, specKey)
            entry.verdict = verdict
            entry.reason = reason

            if verdict == "MISSING" then
                audit.missingEnchants = audit.missingEnchants + 1
            elseif verdict == "UNKNOWN" then
                audit.unknownEnchants = audit.unknownEnchants + 1
            end
            audit.emptySockets = audit.emptySockets + entry.emptySockets
        end

        audit.slots[#audit.slots + 1] = entry
    end
    return audit
end

-- === Automatischer Ausrüstungsabgleich =====================================
--
-- Geteilte Daten sind absichtlich nur Messwerte: Slot, Gegenstand,
-- Verzauberungs-ID und Zahl leerer Sockel. Bewertungen und Begründungen
-- entstehen auf dem empfangenden Client aus dem aktuellen Gildenregelsatz.
-- Damit muss weder ein fremder Tooltiptext übertragen noch eine alte
-- Bewertung als Wahrheit behandelt werden.

function GC.GearAudit:BuildEquipmentMessages(audit)
    audit = audit or self:GetAudit(GC:GetPlayerFullName())
    local classFile = audit and audit.classFile
    if not audit or not GC.Classes[classFile] or (tonumber(audit.unreadableSlots) or 0) > 0 then
        return {}, nil
    end

    local specKey = audit.specKey
    if specKey and (not GC.SpecByKey[specKey] or GC.SpecByKey[specKey].classFile ~= classFile) then
        specKey = nil
    end

    local entriesByKey = {}
    for _, entry in ipairs(audit.slots or {}) do
        if type(entry) == "table" and type(entry.key) == "string" then
            entriesByKey[entry.key] = entry
        end
    end

    local records = {}
    local equipped = 0
    for _, slot in ipairs(GC.GearSlots) do
        local entry = entriesByKey[slot.key] or {}
        local itemID = WholeNumber(entry.itemID, 0, 99999999) or 0
        local enchantID = WholeNumber(entry.enchantID, 0, 99999999) or 0
        local emptySockets = WholeNumber(entry.emptySockets, 0, 4) or 0
        if itemID <= 0 then
            enchantID = 0
            emptySockets = 0
        else
            equipped = equipped + 1
        end
        records[#records + 1] = table.concat({
            tostring(slot.id),
            tostring(itemID),
            tostring(enchantID),
            tostring(emptySockets),
        }, ":")
    end
    if equipped == 0 then
        return {}, nil
    end

    local recordText = table.concat(records, ",")

    -- Ausgenommene Slots als eigenes Feld. Es wird nur angehaengt, wenn es
    -- wirklich Ausnahmen gibt: Aeltere Clients pruefen die Feldzahl streng und
    -- verwerfen ein Paket mit Zusatzfeld. Ohne Ausnahmen - der Regelfall -
    -- bleibt das Paket deshalb unveraendert und fuer alle lesbar.
    local exemptKeys = {}
    for _, entry in ipairs(audit.slots or {}) do
        if type(entry) == "table" and type(entry.exempt) == "string"
            and GC.GearExemptionReasonByKey[entry.exempt] then
            exemptKeys[#exemptKeys + 1] = entry.key .. ":" .. entry.exempt
        end
    end
    local exemptText = table.concat(exemptKeys, ",")

    local fingerprint = table.concat({ classFile, specKey or "", recordText, exemptText }, "|")
    local payloadFields = {
        "ES",
        classFile,
        specKey or "",
        tostring(WholeNumber(audit.inspectedAt, 1, 9999999999) or GC.Util.Now()),
        recordText,
    }
    if exemptText ~= "" then
        payloadFields[#payloadFields + 1] = exemptText
    end
    local payload = table.concat(payloadFields, "|")

    local chunks = {}
    for offset = 1, #payload, EQUIPMENT_CHUNK_BYTES do
        chunks[#chunks + 1] = payload:sub(offset, offset + EQUIPMENT_CHUNK_BYTES - 1)
    end
    if #chunks == 0 or #chunks > EQUIPMENT_MAX_PARTS then
        return {}, nil
    end

    local token = tostring(GC.Util.Now()) .. tostring(math.random(1000, 9999))
    local messages = {}
    for index, chunk in ipairs(chunks) do
        messages[index] = table.concat({
            "E",
            tostring(GC.Constants.SCHEMA_VERSION),
            token,
            tostring(index),
            tostring(#chunks),
            chunk,
        }, "|")
    end
    return messages, fingerprint
end

function GC.GearAudit:SendEquipmentSnapshot(audit, force)
    if not GC.Sync or type(GC.Sync.Send) ~= "function" then
        return false
    end
    local messages, fingerprint = self:BuildEquipmentMessages(audit)
    if #messages == 0 or not fingerprint then
        return false
    end
    if not force and fingerprint == self.lastEquipmentFingerprint then
        return false
    end

    self.equipmentSendGeneration = (self.equipmentSendGeneration or 0) + 1
    local generation = self.equipmentSendGeneration
    local index = 1
    local retries = 0
    local function SendNext()
        if self.equipmentSendGeneration ~= generation then
            return
        end
        local message = messages[index]
        if not message then
            self.lastEquipmentFingerprint = fingerprint
            return
        end
        local sent = GC.Sync:Send(message)
        if sent then
            index = index + 1
            retries = 0
        else
            retries = retries + 1
            if retries >= EQUIPMENT_MAX_RETRIES then
                return
            end
        end
        C_Timer.After(sent and EQUIPMENT_SEND_INTERVAL or 1.25, SendNext)
    end
    SendNext()
    return true
end

function GC.GearAudit:QueueEquipmentSnapshot(audit, force)
    self.pendingEquipmentAudit = audit or self:GetAudit(GC:GetPlayerFullName())
    self.pendingEquipmentForce = self.pendingEquipmentForce or force == true
    if not self.pendingEquipmentAudit or self.equipmentSendPending then
        return false
    end
    if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then
        return false
    end

    self.equipmentSendPending = true
    C_Timer.After(1.2, function()
        self.equipmentSendPending = false
        local pending = self.pendingEquipmentAudit
        local forced = self.pendingEquipmentForce
        self.pendingEquipmentAudit = nil
        self.pendingEquipmentForce = false
        self:SendEquipmentSnapshot(pending, forced)
    end)
    return true
end

function GC.GearAudit:ReplyWithEquipmentSnapshot()
    local now = GC.Util.Now()
    if self.lastEquipmentReplyAt
        and (now - self.lastEquipmentReplyAt) < EQUIPMENT_REPLY_INTERVAL then
        return false
    end
    if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then
        return false
    end
    local audit = self:GetAudit(GC:GetPlayerFullName())
    if not audit or audit.source ~= "SELF" then
        return false
    end
    self.lastEquipmentReplyAt = now
    C_Timer.After(0.5 + math.random() * 2.5, function()
        -- Bis die gestreute Antwort gesendet wird, kann sich die Ausrüstung
        -- geändert haben. Deshalb die echten Slots erneut lesen und nicht nur
        -- den zuletzt gespeicherten Snapshot wiederholen.
        self:AuditSelf(true, true)
    end)
    return true
end

function GC.GearAudit:BuildSyncedAudit(sender, classFile, specKey, inspectedAt, records, exceptions)
    local spec = specKey and GC.SpecByKey[specKey]
    local audit = {
        name = GC.Util.PlayerShortName(sender),
        classFile = classFile,
        role = spec and spec.role or nil,
        specKey = specKey,
        inspectedAt = inspectedAt,
        receivedAt = GC.Util.Now(),
        source = "SYNC",
        ruleVersion = GC.EnchantRuleSet.version,
        slots = {},
        missingEnchants = 0,
        emptySockets = 0,
        unknownEnchants = 0,
        emptySlots = 0,
        unreadableSlots = 0,
        exemptSlots = 0,
    }

    for _, slot in ipairs(GC.GearSlots) do
        local measured = records[slot.id]
        local entry = {
            key = slot.key,
            label = slot.label,
            required = slot.enchantRequired == true,
        }
        local exemptionReason = exceptions and exceptions[slot.key]
        if type(exemptionReason) == "string" and GC.GearExemptionReasonByKey[exemptionReason] then
            entry.exempt = exemptionReason
            entry.verdict = "EXEMPT"
            entry.reason = GC.GearExemptionReasonByKey[exemptionReason].label
                .. ": zählt nicht als Fund."
            if measured and measured.itemID > 0 then
                entry.itemID = measured.itemID
                entry.enchantID = measured.enchantID
            end
            audit.exemptSlots = audit.exemptSlots + 1
        elseif not measured or measured.itemID <= 0 then
            entry.verdict = "EMPTY"
            entry.reason = "Kein Gegenstand angelegt."
            if entry.required then
                audit.emptySlots = audit.emptySlots + 1
            end
        else
            entry.itemID = measured.itemID
            entry.enchantID = measured.enchantID
            entry.emptySockets = measured.emptySockets
            entry.verdict, entry.reason = self:EvaluateEnchant(
                slot, measured.enchantID, audit.role, nil, specKey)
            if entry.verdict == "MISSING" then
                audit.missingEnchants = audit.missingEnchants + 1
            elseif entry.verdict == "UNKNOWN" then
                audit.unknownEnchants = audit.unknownEnchants + 1
            end
            audit.emptySockets = audit.emptySockets + measured.emptySockets
        end
        audit.slots[#audit.slots + 1] = entry
    end
    return audit
end

function GC.GearAudit:DecodeEquipmentPayload(payload, sender)
    local fields = GC.Util.SplitFields(payload)
    -- Feld 6 (ausgenommene Slots) ist freiwillig und kam erst spaeter dazu.
    if #fields < 5 or #fields > 6 or fields[1] ~= "ES" or not GC.Classes[fields[2]] then
        return nil
    end

    local classFile = fields[2]
    local specKey = fields[3] ~= "" and fields[3] or nil
    if specKey and (not GC.SpecByKey[specKey] or GC.SpecByKey[specKey].classFile ~= classFile) then
        return nil
    end
    local member = GC.Roster and GC.Roster:GetMember(sender)
    if member and member.classFile and member.classFile ~= classFile then
        return nil
    end

    local now = GC.Util.Now()
    local inspectedAt = WholeNumber(fields[4], 1, 9999999999)
    if not inspectedAt or inspectedAt < (now - AUDIT_TTL) or inspectedAt > (now + 300) then
        return nil
    end

    local slotsByID = GearSlotByID()
    local records = {}
    local count = 0
    local equipped = 0
    for record in tostring(fields[5] or ""):gmatch("[^,]+") do
        local slotText, itemText, enchantText, socketsText =
            record:match("^(%d+):(%d+):(%d+):(%d+)$")
        local slotID = WholeNumber(slotText, 1, 19)
        local itemID = WholeNumber(itemText, 0, 99999999)
        local enchantID = WholeNumber(enchantText, 0, 99999999)
        local emptySockets = WholeNumber(socketsText, 0, 4)
        if not slotID or not slotsByID[slotID] or records[slotID]
            or not itemID or not enchantID or not emptySockets
            or (itemID == 0 and (enchantID ~= 0 or emptySockets ~= 0)) then
            return nil
        end
        records[slotID] = {
            itemID = itemID,
            enchantID = enchantID,
            emptySockets = emptySockets,
        }
        count = count + 1
        if itemID > 0 then
            equipped = equipped + 1
        end
    end
    if count ~= #GC.GearSlots or equipped == 0 then
        return nil
    end

    -- Ausgenommene Slots. Das Feld ist freiwillig, aber wenn es da ist, muss es
    -- stimmen: Ein unlesbarer Eintrag laesst das ganze Paket durchfallen, damit
    -- ein beschaedigtes oder fremdes Paket nicht doch halb uebernommen wird.
    local exceptions = {}
    if fields[6] ~= nil then
        local slotKeys = {}
        for _, slot in ipairs(GC.GearSlots) do
            slotKeys[slot.key] = true
        end
        local exemptCount = 0
        for pair in tostring(fields[6]):gmatch("[^,]+") do
            local slotKey, reasonKey = pair:match("^(%u[%u%d]*):(%u+)$")
            if not slotKey or not slotKeys[slotKey] or not GC.GearExemptionReasonByKey[reasonKey]
                or exceptions[slotKey] then
                return nil
            end
            exceptions[slotKey] = reasonKey
            exemptCount = exemptCount + 1
        end
        -- Ein leeres Zusatzfeld haette gar nicht erst gesendet werden duerfen.
        if exemptCount == 0 then
            return nil
        end
    end

    return self:BuildSyncedAudit(sender, classFile, specKey, inspectedAt, records, exceptions)
end

function GC.GearAudit:ReceiveEquipmentChunk(message, sender)
    local schemaText, token, indexText, totalText, chunk =
        message:match("^E|([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.*)$")
    local schemaVersion = tonumber(schemaText)
    local index = WholeNumber(indexText, 1, EQUIPMENT_MAX_PARTS)
    local total = WholeNumber(totalText, 1, EQUIPMENT_MAX_PARTS)
    local senderKey = GC.Util.NormalizeName(sender)
    if schemaVersion ~= GC.Constants.SCHEMA_VERSION or not index or not total
        or index > total or senderKey == "" or not token or #token > 40
        or not token:match("^[%w%-]+$")
        or type(chunk) ~= "string" or #chunk > EQUIPMENT_CHUNK_BYTES then
        return false
    end

    local now = GC.Util.Now()
    local incomingCount = 0
    for key, transfer in pairs(self.equipmentIncoming) do
        if (now - (tonumber(transfer.receivedAt) or 0)) > EQUIPMENT_INCOMING_TTL then
            self.equipmentIncoming[key] = nil
        else
            incomingCount = incomingCount + 1
        end
    end

    local incomingKey = senderKey .. "|" .. token
    local incoming = self.equipmentIncoming[incomingKey]
    if incoming and incoming.total ~= total then
        self.equipmentIncoming[incomingKey] = nil
        return false
    end
    if not incoming then
        if incomingCount >= EQUIPMENT_MAX_INCOMING then
            return false
        end
        incoming = {
            total = total,
            chunks = {},
            received = 0,
            receivedAt = now,
        }
        self.equipmentIncoming[incomingKey] = incoming
    end
    incoming.receivedAt = now
    if incoming.chunks[index] and incoming.chunks[index] ~= chunk then
        self.equipmentIncoming[incomingKey] = nil
        return false
    elseif not incoming.chunks[index] then
        incoming.chunks[index] = chunk
        incoming.received = incoming.received + 1
    end
    if incoming.received < total then
        return true
    end

    local payload = {}
    for chunkIndex = 1, total do
        if incoming.chunks[chunkIndex] == nil then
            return true
        end
        payload[chunkIndex] = incoming.chunks[chunkIndex]
    end
    self.equipmentIncoming[incomingKey] = nil

    local audit = self:DecodeEquipmentPayload(table.concat(payload), sender)
    if not audit then
        return false
    end
    local current = self:GetAudit(sender)
    if current and (tonumber(current.inspectedAt) or 0) > audit.inspectedAt then
        return false
    end
    self:StoreAudit(audit)
    return true
end

function GC.GearAudit:StoreAudit(audit)
    if not audit or not audit.name or audit.name == "" then
        return false
    end
    GC.DB:GetGuild().gearAudits[GC.Util.NormalizeName(audit.name)] = audit
    GC:FireCallback("GEAR_AUDIT_UPDATED")
    return true
end

function GC.GearAudit:GetIssueCount(audit)
    audit = audit or {}
    return (tonumber(audit.missingEnchants) or 0)
        + (tonumber(audit.emptySockets) or 0)
        + (tonumber(audit.emptySlots) or 0)
        + (tonumber(audit.unreadableSlots) or 0)
end

function GC.GearAudit:GetAudits()
    local audits = {}
    for _, audit in pairs(GC.DB:GetGuild().gearAudits or {}) do
        audits[#audits + 1] = audit
    end
    table.sort(audits, function(left, right)
        local leftIssues = self:GetIssueCount(left)
        local rightIssues = self:GetIssueCount(right)
        if leftIssues ~= rightIssues then
            return leftIssues > rightIssues
        end
        return tostring(left.name) < tostring(right.name)
    end)
    return audits
end

function GC.GearAudit:GetAudit(name)
    if not name then
        return nil
    end
    return GC.DB:GetGuild().gearAudits[GC.Util.NormalizeName(GC.Util.PlayerShortName(name))]
end

function GC.GearAudit:Prune()
    local cutoff = GC.Util.Now() - AUDIT_TTL
    local audits = GC.DB:GetGuild().gearAudits or {}
    for key, audit in pairs(audits) do
        if (audit.inspectedAt or 0) < cutoff then
            audits[key] = nil
        end
    end
end

function GC.GearAudit:AuditSelf(automatic, forceSnapshot)
    if type(GetInventoryItemLink) ~= "function" then
        return false, "Die Ausrüstung konnte nicht gelesen werden."
    end
    local _, classFile = UnitClass("player")
    local audit = self:BuildAudit(GC:GetPlayerFullName(), classFile, function(slotID)
        return GetInventoryItemLink("player", slotID)
    end, "SELF", function(slotID)
        if type(GetInventoryItemID) == "function" then
            return GetInventoryItemID("player", slotID)
        end
    end)
    self:StoreAudit(audit)
    self.selectedName = audit.name
    if (audit.unreadableSlots or 0) > 0 then
        self.unreadableRetryCount = (self.unreadableRetryCount or 0) + 1
        if self.unreadableRetryCount <= MAX_SELF_READ_RETRIES then
            self:QueueSelfAudit(1)
            self:SetStatus("Eigene Gegenstandsdaten werden noch geladen; Prüfung wird wiederholt.")
            return false, "Ausrüstung noch nicht vollständig lesbar; die Prüfung wird automatisch wiederholt."
        end
        self:SetStatus("Eigene Gegenstandsdaten sind noch nicht vollständig lesbar.")
        return false, "Unvollständige Ausrüstung wurde nicht an die Gilde übertragen."
    end
    self.unreadableRetryCount = 0
    self:QueueEquipmentSnapshot(audit, forceSnapshot)
    self:SetStatus(automatic and "Eigene Ausrüstung automatisch geprüft." or "Eigene Ausrüstung geprüft.")
    return true, "Eigene Ausrüstung geprüft: " .. self:DescribeFindings(audit)
end

-- Automatische Selbstpruefung.
--
-- Beim Umziehen feuert PLAYER_EQUIPMENT_CHANGED je Slot einzeln, ein
-- kompletter Satz Ausruestung loest also ein gutes Dutzend Ereignisse aus.
-- Deshalb wird nur einmal eingeplant und der Rest verworfen, bis der Lauf
-- durch ist. Der Verzoegerung liegt zugrunde, dass der Client den Item-Link
-- erst mit etwas Abstand vollstaendig liefert.
function GC.GearAudit:QueueSelfAudit(delay)
    if self.autoSelfPending then
        return false
    end
    if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then
        return false
    end

    self.autoSelfPending = true
    C_Timer.After(delay or AUTO_SELF_DELAY, function()
        self.autoSelfPending = false
        self:AuditSelf(true)
    end)
    return true
end

-- Aufbereitete Funde in ganzen Sätzen, damit die Oberfläche nicht nur Zahlen
-- zeigt: "3 fehlende Verzauberungen: Schulter, Brust, Rücken".
function GC.GearAudit:GetFindings(audit)
    local findings = {}
    if not audit then
        return findings
    end

    local missingEnchants = {}
    local socketSlots = {}
    local emptySlots = {}
    local unreadableSlots = {}
    local unknownEnchants = 0
    for _, entry in ipairs(audit.slots or {}) do
        if entry.verdict == "MISSING" then
            missingEnchants[#missingEnchants + 1] = entry.label
        elseif entry.verdict == "EMPTY" and entry.required then
            emptySlots[#emptySlots + 1] = entry.label
        elseif entry.verdict == "UNKNOWN" and not entry.unreadable then
            unknownEnchants = unknownEnchants + 1
        end
        if (entry.emptySockets or 0) > 0 then
            socketSlots[#socketSlots + 1] = entry.label
        end
        if entry.unreadable then
            unreadableSlots[#unreadableSlots + 1] = entry.label
        end
    end

    if #missingEnchants == 1 then
        findings[#findings + 1] = {
            severity = "PROBLEM",
            text = "1 fehlende Verzauberung: " .. missingEnchants[1],
        }
    elseif #missingEnchants > 1 then
        findings[#findings + 1] = {
            severity = "PROBLEM",
            text = #missingEnchants .. " fehlende Verzauberungen: " .. table.concat(missingEnchants, ", "),
        }
    end

    local emptySockets = audit.emptySockets or 0
    if emptySockets > 0 then
        findings[#findings + 1] = {
            severity = "PROBLEM",
            text = (emptySockets == 1 and "1 leerer Sockel" or (emptySockets .. " leere Sockel"))
                .. ": " .. table.concat(socketSlots, ", "),
        }
    end

    if #emptySlots > 0 then
        findings[#findings + 1] = {
            severity = "WARNING",
            text = (#emptySlots == 1 and "1 leerer Ausrüstungsplatz" or (#emptySlots .. " leere Ausrüstungsplätze"))
                .. ": " .. table.concat(emptySlots, ", "),
        }
    end

    if #unreadableSlots > 0 then
        findings[#findings + 1] = {
            severity = "WARNING",
            text = (#unreadableSlots == 1
                and "1 Ausrüstungsplatz noch nicht lesbar"
                or (#unreadableSlots .. " Ausrüstungsplätze noch nicht lesbar"))
                .. ": " .. table.concat(unreadableSlots, ", "),
        }
    end

    if #findings == 0 then
        findings[#findings + 1] = {
            severity = "OK",
            text = "Alles verzaubert und alle Sockel besetzt.",
        }
    end

    -- Nur erwähnen, wenn überhaupt Regeln gepflegt sind. Bei leerer Regelliste
    -- wäre "alles unbewertet" nur Rauschen.
    local ruleCount = 0
    for _ in pairs(GC.EnchantRuleSet.rules) do
        ruleCount = ruleCount + 1
    end
    if ruleCount > 0 and unknownEnchants > 0 then
        findings[#findings + 1] = {
            severity = "INFO",
            text = unknownEnchants .. " Verzauberungen sind noch nicht bewertet.",
        }
    end
    return findings
end

function GC.GearAudit:GetOverview()
    local overview = {
        players = 0,
        missingEnchants = 0,
        emptySockets = 0,
        emptySlots = 0,
        unreadableSlots = 0,
        clean = 0,
    }
    for _, audit in ipairs(self:GetAudits()) do
        overview.players = overview.players + 1
        overview.missingEnchants = overview.missingEnchants + (audit.missingEnchants or 0)
        overview.emptySockets = overview.emptySockets + (audit.emptySockets or 0)
        overview.emptySlots = overview.emptySlots + (audit.emptySlots or 0)
        overview.unreadableSlots = overview.unreadableSlots + (audit.unreadableSlots or 0)
        if self:GetIssueCount(audit) == 0 then
            overview.clean = overview.clean + 1
        end
    end
    return overview
end

function GC.GearAudit:DescribeFindings(audit)
    local parts = {}
    if (audit.missingEnchants or 0) > 0 then
        parts[#parts + 1] = audit.missingEnchants .. " fehlende Verzauberungen"
    end
    if (audit.emptySockets or 0) > 0 then
        parts[#parts + 1] = audit.emptySockets .. " leere Sockel"
    end
    if (audit.emptySlots or 0) > 0 then
        parts[#parts + 1] = audit.emptySlots .. " leere Slots"
    end
    if (audit.unreadableSlots or 0) > 0 then
        parts[#parts + 1] = audit.unreadableSlots .. " noch nicht lesbare Slots"
    end
    if #parts == 0 then
        return "keine fehlenden Verzauberungen oder leeren Sockel."
    end
    return GC.Util.JoinGerman(parts) .. "."
end

-- === Inspect-Warteschlange ==================================================
--
-- WoW erlaubt nur eine Inspektion gleichzeitig und nur in Reichweite. Die
-- Warteschlange arbeitet deshalb einen Spieler nach dem anderen ab und
-- überspringt jeden, der nicht erreichbar ist.

function GC.GearAudit:CollectRaidTargets()
    local targets = {}
    if not GetNumGroupMembers or not UnitExists then
        return targets
    end

    local inRaid = IsInRaid and IsInRaid()
    local memberCount = GetNumGroupMembers() or 0
    for index = 1, memberCount do
        local unit = (inRaid and "raid" or "party") .. index
        if UnitExists(unit) and not UnitIsUnit(unit, "player") then
            targets[#targets + 1] = {
                unit = unit,
                name = UnitName(unit),
            }
        end
    end
    return targets
end

function GC.GearAudit:CanInspectUnit(unit)
    if CanInspect and CanInspect(unit) == false then
        return false
    end
    if UnitIsConnected and UnitIsConnected(unit) == false then
        return false
    end
    if CheckInteractDistance and CheckInteractDistance(unit, 1) == false then
        return false
    end
    return true
end

function GC.GearAudit:HasFreshSyncedAudit(name)
    local audit = self:GetAudit(name)
    return audit ~= nil
        and audit.source == "SYNC"
        and (tonumber(audit.inspectedAt) or 0) >= (GC.Util.Now() - AUDIT_TTL)
end

function GC.GearAudit:StartRaidScan()
    if self.scanning then
        return false, "Es läuft bereits eine Prüfung."
    end

    local targets = self:CollectRaidTargets()
    if #targets == 0 then
        return false, "Es sind keine Gruppenmitglieder zum Prüfen da."
    end

    local inspectTargets = {}
    local shared = 0
    local firstSharedName
    for _, target in ipairs(targets) do
        if self:HasFreshSyncedAudit(target.name) then
            shared = shared + 1
            firstSharedName = firstSharedName or target.name
        else
            inspectTargets[#inspectTargets + 1] = target
        end
    end

    self.queue = inspectTargets
    self.scanning = true
    self.skipped = 0
    self.completed = 0
    self.shared = shared
    if firstSharedName then
        self.selectedName = GC.Util.PlayerShortName(firstSharedName)
    end
    self:SetStatus("Prüfe " .. #inspectTargets .. " Spieler"
        .. (shared > 0 and (", " .. shared .. " bereits per Addon-Abgleich") or "") .. " …")
    self:ProcessQueue()
    return true, shared > 0
        and ("Ausrüstungsprüfung gestartet; " .. shared .. " Spieler liefern ihre Daten selbst.")
        or "Ausrüstungsprüfung gestartet."
end

function GC.GearAudit:SetStatus(status)
    self.status = status or ""
    GC:FireCallback("GEAR_AUDIT_UPDATED")
end

function GC.GearAudit:FinishScan()
    if ClearInspectPlayer then
        ClearInspectPlayer()
    end
    self.scanning = false
    self.active = nil
    self.queue = {}
    local message = (self.completed or 0) .. " Spieler per Inspect geprüft"
    if (self.shared or 0) > 0 then
        message = message .. ", " .. self.shared .. " über Addon-Daten"
    end
    if (self.skipped or 0) > 0 then
        message = message .. ", " .. self.skipped .. " nicht in Reichweite"
    end
    self:SetStatus(message .. ".")
    return message
end

function GC.GearAudit:ProcessQueue()
    if not self.scanning then
        return
    end
    local target = table.remove(self.queue, 1)
    if not target then
        self:FinishScan()
        return
    end

    if not self:CanInspectUnit(target.unit) then
        self.skipped = (self.skipped or 0) + 1
        C_Timer.After(0.05, function()
            self:ProcessQueue()
        end)
        return
    end

    self.active = {
        unit = target.unit,
        name = target.name,
        guid = UnitGUID and UnitGUID(target.unit),
        startedAt = GC.Util.Now(),
    }
    if NotifyInspect then
        NotifyInspect(target.unit)
    end

    C_Timer.After(INSPECT_TIMEOUT, function()
        if self.active and self.active.unit == target.unit then
            self.skipped = (self.skipped or 0) + 1
            self.active = nil
            if ClearInspectPlayer then
                ClearInspectPlayer()
            end
            self:ProcessQueue()
        end
    end)
end

function GC.GearAudit:OnInspectReady(guid)
    local active = self.active
    if not active then
        return false
    end
    if guid and active.guid and guid ~= active.guid then
        return false
    end

    local unit = active.unit
    local _, classFile = UnitClass(unit)
    local audit = self:BuildAudit(active.name or UnitName(unit), classFile, function(slotID)
        return GetInventoryItemLink(unit, slotID)
    end, "INSPECT", function(slotID)
        if type(GetInventoryItemID) == "function" then
            return GetInventoryItemID(unit, slotID)
        end
    end)
    self:StoreAudit(audit)
    self.completed = (self.completed or 0) + 1
    self.active = nil
    if ClearInspectPlayer then
        ClearInspectPlayer()
    end

    if self.scanning then
        C_Timer.After(INSPECT_INTERVAL, function()
            self:ProcessQueue()
        end)
    end
    return true
end

local gearEvents = CreateFrame("Frame")
gearEvents:RegisterEvent("INSPECT_READY")
gearEvents:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
gearEvents:RegisterEvent("UNIT_INVENTORY_CHANGED")
gearEvents:RegisterEvent("GET_ITEM_INFO_RECEIVED")
gearEvents:SetScript("OnEvent", function(_, event, value)
    if event == "INSPECT_READY" then
        GC.GearAudit:OnInspectReady(value)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        GC.GearAudit.unreadableRetryCount = 0
        GC.GearAudit:QueueSelfAudit()
    elseif event == "UNIT_INVENTORY_CHANGED" and value == "player" then
        GC.GearAudit.unreadableRetryCount = 0
        GC.GearAudit:QueueSelfAudit()
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        local own = GC.GearAudit:GetAudit(GC:GetPlayerFullName())
        if own and (own.unreadableSlots or 0) > 0 then
            GC.GearAudit:QueueSelfAudit(0.5)
        end
    end
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.GearAudit, function(self)
    self:Prune()
    -- Beim Login grosszuegiger warten: Item-Links und Tooltips sind direkt
    -- nach dem Laden noch nicht vollstaendig, die Verzauberungsnamen kaemen
    -- sonst leer zurueck.
    self:QueueSelfAudit(AUTO_SELF_LOGIN_DELAY)
end)
