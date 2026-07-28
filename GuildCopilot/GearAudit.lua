local _, GC = ...

GC.GearAudit = {
    queue = {},
    active = nil,
    scanning = false,
    lastRequestAt = 0,
    selectedName = nil,
    status = "",
}

local INSPECT_INTERVAL = 1.5
local INSPECT_TIMEOUT = 4
local AUDIT_TTL = 7 * 24 * 60 * 60

local SLOT_BY_ID = {}
for _, slot in ipairs(GC.GearSlots) do
    SLOT_BY_ID[slot.id] = slot
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

-- GetItemStats meldet die Sockel des Grundgegenstands. Die Differenz zu den
-- tatsächlich eingesetzten Steinen ergibt die leeren Sockel; die Rechnung
-- stimmt auch dann, wenn die API nur unbesetzte Sockel zurückgeben sollte.
function GC.GearAudit:CountEmptySockets(link, filledGems)
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

function GC.GearAudit:ResolveEnchantName(link, enchantID)
    if (tonumber(enchantID) or 0) <= 0 then
        return nil
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
                return name
            end
        end
    end
    return nil
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

    local rule = GC.EnchantRuleSet.rules[enchantID]
    if not rule then
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

function GC.GearAudit:AuditSelf()
    if type(GetInventoryItemLink) ~= "function" then
        return false, "Die Ausrüstung konnte nicht gelesen werden."
    end
    local _, classFile = UnitClass("player")
    local audit = self:BuildAudit(GC:GetPlayerFullName(), classFile, function(slotID)
        return GetInventoryItemLink("player", slotID)
    end, "SELF")
    self:StoreAudit(audit)
    self.selectedName = audit.name
    self:SetStatus("Eigene Ausrüstung geprüft.")
    return true, "Eigene Ausrüstung geprüft: " .. self:DescribeFindings(audit)
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
gearEvents:SetScript("OnEvent", function(_, event, guid)
    if event == "INSPECT_READY" then
        GC.GearAudit:OnInspectReady(guid)
    end
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.GearAudit, function(self)
    self:Prune()
end)
