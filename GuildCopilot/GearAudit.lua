local _, GC = ...

GC.GearAudit = {
    queue = {},
    active = nil,
    scanning = false,
    selectedName = nil,
    status = "",
}

local INSPECT_INTERVAL = 1.5
local INSPECT_TIMEOUT = 4
local AUDIT_TTL = 7 * 24 * 60 * 60
local AUTO_SELF_DELAY = 3
local AUTO_SELF_LOGIN_DELAY = 8

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
    return self:GetAutoSettings().auditSelf ~= false
end

function GC.GearAudit:GetGuildEnchantRule(enchantID)
    enchantID = tonumber(enchantID)
    if not enchantID then
        return nil
    end
    return GC.DB:GetGuild().enchantRules[tostring(enchantID)]
end

function GC.GearAudit:CanEditEnchantRules()
    return GC.Roster:CanEditGuildSettings()
end

function GC.GearAudit:SetEnchantRule(enchantID, verdict, enchantName)
    enchantID = tonumber(enchantID)
    if not enchantID or enchantID <= 0 then
        return false, "Für diesen Slot gibt es keine Verzauberung zu bewerten."
    end
    if not self:CanEditEnchantRules() then
        return false, "Dein Gildenrang darf den Regelsatz nicht ändern."
    end

    local rules = GC.DB:GetGuild().enchantRules
    local key = tostring(enchantID)
    if not verdict then
        if not rules[key] then
            return false, "Für diese Verzauberung ist nichts hinterlegt."
        end
        rules[key] = nil
        self:OnEnchantRulesChanged()
        return true, "Bewertung entfernt."
    end
    if not GC.GearVerdicts[verdict] then
        return false, "Unbekannte Bewertung."
    end

    local count = 0
    for _ in pairs(rules) do
        count = count + 1
    end
    if not rules[key] and count >= 80 then
        return false, "Der Regelsatz ist voll."
    end

    rules[key] = {
        verdict = verdict,
        name = GC.Util.Trim(enchantName):gsub("[,:|]", " "),
        by = GC.Util.PlayerShortName(GC:GetPlayerFullName()),
        at = GC.Util.Now(),
    }
    self:OnEnchantRulesChanged()
    return true, (GC.Util.Trim(enchantName) ~= "" and enchantName or ("Verzauberung " .. enchantID))
        .. " gilt jetzt als " .. GC.GearVerdicts[verdict].label .. "."
end

-- Reihum durch die Stufen und wieder zurueck auf "keine Bewertung".
function GC.GearAudit:CycleEnchantRule(enchantID, enchantName)
    local current = self:GetGuildEnchantRule(enchantID)
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
    return self:SetEnchantRule(enchantID, nextVerdict, enchantName)
end

-- Nur neu bewerten, ohne etwas zu senden. Diesen Weg nimmt der Empfang: Wer
-- ein Gildenprofil bekommt, darf es nicht sofort wieder verschicken, sonst
-- schaukeln sich zwei Clients gegenseitig auf.
function GC.GearAudit:ReapplyEnchantRules()
    for _, audit in pairs(GC.DB:GetGuild().gearAudits or {}) do
        for _, entry in ipairs(audit.slots or {}) do
            if entry.verdict ~= "EMPTY" and (tonumber(entry.enchantID) or 0) > 0 then
                local slot = { key = entry.key, enchantRequired = entry.required }
                entry.verdict, entry.reason =
                    self:EvaluateEnchant(slot, entry.enchantID, audit.role, entry.enchantName)
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

function GC.GearAudit:EvaluateEnchant(slot, enchantID, role, enchantName)
    if (tonumber(enchantID) or 0) <= 0 then
        if slot.enchantRequired then
            return "MISSING", "Keine Verzauberung auf einem Pflichtslot."
        end
        return nil
    end

    local guildRule = self:GetGuildEnchantRule(enchantID)
    if guildRule and GC.GearVerdicts[guildRule.verdict] then
        local label = enchantName
        if not label or label == "" then
            label = guildRule.name ~= "" and guildRule.name or ("Verzauberung " .. enchantID)
        end
        return guildRule.verdict, label .. "  •  Gildenregel von " .. (guildRule.by or "?")
    end

    local rule = GC.EnchantRuleSet.rules[enchantID]
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

    if rule.slots then
        local matches = false
        for _, slotKey in ipairs(rule.slots) do
            if slotKey == slot.key then
                matches = true
                break
            end
        end
        if not matches then
            return "UNKNOWN", "Regel gilt nicht für diesen Slot."
        end
    end
    if rule.roles and role then
        local matches = false
        for _, ruleRole in ipairs(rule.roles) do
            if ruleRole == role then
                matches = true
                break
            end
        end
        if not matches then
            return "UNKNOWN", "Regel gilt nicht für diese Rolle."
        end
    end

    local reason = rule.name or enchantName or ("Verzauberung " .. enchantID)
    if rule.source and rule.source ~= "" then
        reason = reason .. "  •  Quelle: " .. rule.source
    end
    return rule.verdict or "UNKNOWN", reason
end

function GC.GearAudit:BuildAudit(playerName, classFile, readLink, source)
    local profile = GC.Roster:GetProfile(playerName)
    local role = self:GetRoleForProfile(profile)
    local audit = {
        name = GC.Util.PlayerShortName(playerName),
        classFile = classFile or (profile and profile.classFile),
        role = role,
        inspectedAt = GC.Util.Now(),
        source = source or "INSPECT",
        ruleVersion = GC.EnchantRuleSet.version,
        slots = {},
        missingEnchants = 0,
        emptySockets = 0,
        unknownEnchants = 0,
        emptySlots = 0,
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
        if not parsed then
            entry.verdict = "EMPTY"
            entry.reason = "Kein Gegenstand angelegt."
            if slot.enchantRequired then
                audit.emptySlots = audit.emptySlots + 1
            end
        else
            entry.itemID = parsed.itemID
            entry.enchantID = parsed.enchantID
            entry.emptySockets = self:CountEmptySockets(link, parsed.filledGems) or 0
            entry.enchantName = self:ResolveEnchantName(link, parsed.enchantID)
            local verdict, reason = self:EvaluateEnchant(slot, parsed.enchantID, role, entry.enchantName)
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

function GC.GearAudit:StoreAudit(audit)
    if not audit or not audit.name or audit.name == "" then
        return false
    end
    GC.DB:GetGuild().gearAudits[GC.Util.NormalizeName(audit.name)] = audit
    GC:FireCallback("GEAR_AUDIT_UPDATED")
    return true
end

function GC.GearAudit:GetAudits()
    local audits = {}
    for _, audit in pairs(GC.DB:GetGuild().gearAudits or {}) do
        audits[#audits + 1] = audit
    end
    table.sort(audits, function(left, right)
        local leftIssues = (left.missingEnchants or 0) + (left.emptySockets or 0)
        local rightIssues = (right.missingEnchants or 0) + (right.emptySockets or 0)
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

function GC.GearAudit:AuditSelf(automatic)
    if type(GetInventoryItemLink) ~= "function" then
        return false, "Die Ausrüstung konnte nicht gelesen werden."
    end
    local _, classFile = UnitClass("player")
    local audit = self:BuildAudit(GC:GetPlayerFullName(), classFile, function(slotID)
        return GetInventoryItemLink("player", slotID)
    end, "SELF")
    self:StoreAudit(audit)
    self.selectedName = audit.name
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
    if not self:AuditsSelfAutomatically() or self.autoSelfPending then
        return false
    end
    if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then
        return false
    end

    self.autoSelfPending = true
    C_Timer.After(delay or AUTO_SELF_DELAY, function()
        self.autoSelfPending = false
        if self:AuditsSelfAutomatically() then
            self:AuditSelf(true)
        end
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
    local unknownEnchants = 0
    for _, entry in ipairs(audit.slots or {}) do
        if entry.verdict == "MISSING" then
            missingEnchants[#missingEnchants + 1] = entry.label
        elseif entry.verdict == "EMPTY" and entry.required then
            emptySlots[#emptySlots + 1] = entry.label
        elseif entry.verdict == "UNKNOWN" then
            unknownEnchants = unknownEnchants + 1
        end
        if (entry.emptySockets or 0) > 0 then
            socketSlots[#socketSlots + 1] = entry.label
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
        clean = 0,
    }
    for _, audit in ipairs(self:GetAudits()) do
        overview.players = overview.players + 1
        overview.missingEnchants = overview.missingEnchants + (audit.missingEnchants or 0)
        overview.emptySockets = overview.emptySockets + (audit.emptySockets or 0)
        overview.emptySlots = overview.emptySlots + (audit.emptySlots or 0)
        if (audit.missingEnchants or 0) == 0 and (audit.emptySockets or 0) == 0 then
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

function GC.GearAudit:StartRaidScan()
    if self.scanning then
        return false, "Es läuft bereits eine Prüfung."
    end

    local targets = self:CollectRaidTargets()
    if #targets == 0 then
        return false, "Es sind keine Gruppenmitglieder zum Prüfen da."
    end

    self.queue = targets
    self.scanning = true
    self.skipped = 0
    self.completed = 0
    self:SetStatus("Prüfe " .. #targets .. " Spieler …")
    self:ProcessQueue()
    return true, "Ausrüstungsprüfung gestartet."
end

function GC.GearAudit:SetStatus(status)
    self.status = status or ""
    GC:FireCallback("GEAR_AUDIT_UPDATED")
end

function GC.GearAudit:FinishScan()
    self.scanning = false
    self.active = nil
    self.queue = {}
    local message = (self.completed or 0) .. " Spieler geprüft"
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
    end, "INSPECT")
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
gearEvents:SetScript("OnEvent", function(_, event, guid)
    if event == "INSPECT_READY" then
        GC.GearAudit:OnInspectReady(guid)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        GC.GearAudit:QueueSelfAudit()
    end
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.GearAudit, function(self)
    self:Prune()
    -- Beim Login grosszuegiger warten: Item-Links und Tooltips sind direkt
    -- nach dem Laden noch nicht vollstaendig, die Verzauberungsnamen kaemen
    -- sonst leer zurueck.
    self:QueueSelfAudit(AUTO_SELF_LOGIN_DELAY)
end)
