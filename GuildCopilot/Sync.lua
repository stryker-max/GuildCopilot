local _, GC = ...

GC.Sync = {
    registered = false,
    sendPending = false,
    guildProfileSendPending = false,
    guildProfileForceSend = false,
    guildProfileIncoming = {},
    bulkQueue = {},
    bulkAllowance = 4000,
    reliableQueue = {},
    lastAnnounceAt = 0,
}

-- Der Handshake läuft bewusst ohne Dauerbroadcast: gesendet wird nur beim
-- Login, beim Betreten einer Gruppe und als Antwort auf eine Anfrage. Beide
-- Mindestabstände verhindern, dass mehrere gleichzeitige Logins den
-- Addon-Kanal fluten.
local MIN_ANNOUNCE_INTERVAL = 60
local MIN_REPLY_INTERVAL = 15
local MIN_PROFILE_REPLY_INTERVAL = 30
local MIN_MANUAL_SYNC_INTERVAL = 15
local INCOMING_TTL = 5 * 60
-- ChatThrottleLib nutzt dieselben konservativen Grenzwerte. Ist die Bibliothek
-- bereits durch ein anderes Addon geladen, reihen wir uns dort ein. Andernfalls
-- stellt diese kleine lokale Warteschlange denselben Schutz bereit: bis zu 4 KB
-- Burst und danach 800 Bytes pro Sekunde. Alle Pakete werden sofort eingereiht;
-- es gibt keine feste Pause pro Rezept.
local BULK_BYTES_PER_SECOND = 800
local BULK_BURST_BYTES = 4000
local BULK_MESSAGE_OVERHEAD = 40
local BULK_MAX_RETRIES = 8
-- Lehnt der Client eine Nachricht ab (eingebautes Addon-Ratenlimit), braucht der
-- Kanal echte Zeit zum Erholen. Die Wiederholungen bekommen deshalb einen
-- wachsenden zeitlichen Abstand, statt im selben Frame zu verbrennen.
local BULK_RETRY_BACKOFF = 0.75
local BULK_MAX_RETRY_DELAY = 4
-- Der Rahmen, dessen OnUpdate die Bulk-Warteschlange antreibt. Er steht hier
-- oben, damit SendBulk und PumpBulk ihn zeigen und verstecken koennen: Ein
-- verstecktes Frame bekommt kein OnUpdate, eine leere Warteschlange kostet
-- damit keinen einzigen Handleraufruf pro Frame. Verdrahtet wird das Skript
-- unten bei den uebrigen Ereignisrahmen.
local bulkFrame = CreateFrame("Frame")
local RELIABLE_WINDOW = 4
local RELIABLE_RETRY_DELAY = 1.5
-- Der Whisper-Transfer teilt sich das Kanalbudget mit ChatThrottleLib und dem
-- Verkehr anderer Addons. Ein einzelnes Paket darf deshalb mehrfach und mit
-- wachsendem Abstand erneut anlaufen, bevor es als verloren gilt; sonst meldet
-- ein kurzzeitig ueberlasteter Kanal faelschlich einen Fehlschlag.
local RELIABLE_MAX_ATTEMPTS = 8
local RELIABLE_MAX_RETRY_DELAY = 6

local function PruneIncoming(transfers)
    local cutoff = GC.Util.Now() - INCOMING_TTL
    for key, transfer in pairs(transfers) do
        if (tonumber(transfer.receivedAt) or 0) < cutoff then
            transfers[key] = nil
        end
    end
end

local function BoolField(value)
    return value and "1" or "0"
end

local function SortedEnabledRanks(values)
    local ranks = {}
    for rankIndex, enabled in pairs(values or {}) do
        local rank = tonumber(rankIndex)
        if enabled and rank and rank >= 0 and rank <= 9 and rank % 1 == 0 then
            ranks[#ranks + 1] = rank
        end
    end
    table.sort(ranks, function(left, right)
        return left < right
    end)
    for index, rank in ipairs(ranks) do
        ranks[index] = tostring(rank)
    end
    return ranks
end

local function DecodeEnabledRanks(payload)
    local ranks = {}
    for rankIndex in tostring(payload or ""):gmatch("[^,]+") do
        local rank = tonumber(rankIndex)
        if rank and rank >= 0 and rank <= 9 and rank % 1 == 0 then
            ranks[tostring(rank)] = true
        end
    end
    return ranks
end

-- Entscheidungen als "name:status:datum", getrennt durch Komma. Das Feld hängt
-- am Ende der Gildenprofil-Nutzlast, damit ältere Clients es schlicht
-- ignorieren; fehlt es beim Empfang, bleiben die eigenen Einträge stehen.
local function EncodeMemberCareDecisions(decisions)
    local records = {}
    for _, decision in pairs(decisions or {}) do
        local name = GC.Util.Trim(decision.name):gsub("[,:|]", "")
        if name ~= "" and GC.MemberCareDecisions[decision.status] then
            records[#records + 1] = table.concat({
                name,
                decision.status,
                decision.until_ or "",
            }, ":")
        end
    end
    table.sort(records)
    while #records > GC.MemberCareMaxDecisions do
        table.remove(records)
    end
    return table.concat(records, ",")
end

local function DecodeMemberCareDecisions(payload)
    local decisions = {}
    for record in tostring(payload or ""):gmatch("[^,]+") do
        local name, status, untilDate = record:match("^([^:]+):([^:]+):?([^:]*)$")
        if name and GC.MemberCareDecisions[status] then
            decisions[GC.Util.NormalizeName(name)] = {
                name = name,
                status = status,
                until_ = untilDate or "",
                at = GC.Util.Now(),
            }
        end
    end
    return decisions
end

-- Nur ID und Stufe wandern durch die Gilde; den Namen loest jeder Client in
-- seiner eigenen Sprache aus dem Tooltip auf.
local VERDICT_CODES = { OPTIMAL = "O", SOLID = "S", IMPROVABLE = "V" }
local VERDICT_BY_CODE = { O = "OPTIMAL", S = "SOLID", V = "IMPROVABLE" }

local function EncodeEnchantRules(rules)
    local records = {}
    for enchantID, rule in pairs(rules or {}) do
        local code = VERDICT_CODES[rule.verdict]
        if code and tonumber(enchantID) then
            records[#records + 1] = tostring(tonumber(enchantID)) .. ":" .. code
        end
    end
    table.sort(records)
    while #records > 80 do
        table.remove(records)
    end
    return table.concat(records, ",")
end

-- Spec-Bewertungen als "spec:id:code". Das Feld haengt am Ende der Nutzlast,
-- damit aeltere Clients es schlicht ignorieren, statt daran zu scheitern.
local function EncodeSpecEnchantRules(specRules)
    local records = {}
    for specKey, rules in pairs(specRules or {}) do
        if GC.SpecByKey[specKey] then
            for enchantID, rule in pairs(rules or {}) do
                local code = VERDICT_CODES[rule.verdict]
                if code and tonumber(enchantID) then
                    records[#records + 1] = specKey .. ":" .. tostring(tonumber(enchantID)) .. ":" .. code
                end
            end
        end
    end
    table.sort(records)
    while #records > 240 do
        table.remove(records)
    end
    return table.concat(records, ",")
end

local function DecodeSpecEnchantRules(payload)
    local specRules = {}
    for record in tostring(payload or ""):gmatch("[^,]+") do
        local specKey, enchantID, code = record:match("^([%u]+:%d+):(%d+):(%a)$")
        if specKey and GC.SpecByKey[specKey] and VERDICT_BY_CODE[code] then
            specRules[specKey] = specRules[specKey] or {}
            specRules[specKey][enchantID] = {
                verdict = VERDICT_BY_CODE[code],
                name = "",
                by = "",
                at = GC.Util.Now(),
            }
        end
    end
    return specRules
end

local function DecodeEnchantRules(payload)
    local rules = {}
    for record in tostring(payload or ""):gmatch("[^,]+") do
        local enchantID, code = record:match("^(%d+):(%a)$")
        if enchantID and VERDICT_BY_CODE[code] then
            rules[enchantID] = {
                verdict = VERDICT_BY_CODE[code],
                name = "",
                by = "",
                at = GC.Util.Now(),
            }
        end
    end
    return rules
end

-- Die Warcraft-Logs-Gildenquelle als "host,region,realm,gilde". Kommas kommen
-- in Hosts und Slugs nicht vor, der Gildenname wird beim Lesen wieder
-- zusammengesetzt. Das Feld haengt am Ende der Gildenprofil-Nutzlast, damit
-- aeltere Clients es schlicht ignorieren.
local function EncodeWarcraftLogsSource(data)
    data = data or {}
    local region = GC.Util.Trim(data.region)
    local serverSlug = GC.Util.Trim(data.serverSlug)
    if region == "" or serverSlug == "" then
        return ""
    end
    -- Die Klammern sind nicht schmueckend: gsub liefert zwei Werte, und der
    -- letzte Eintrag einer Tabellenliste wuerde beide aufnehmen.
    return table.concat({
        (GC.Util.Trim(data.host):gsub(",", "")),
        (region:gsub(",", "")),
        (serverSlug:gsub(",", "")),
        (GC.Util.Trim(data.guildSlug):gsub(",", " ")),
    }, ",")
end

local function DecodeWarcraftLogsSource(payload)
    local host, region, serverSlug, guildSlug =
        tostring(payload or ""):match("^([^,]*),([^,]+),([^,]+),(.*)$")
    if not region or GC.Util.Trim(serverSlug) == "" then
        return nil
    end
    host = GC.Util.Trim(host)
    if host == "" then
        host = GC.Constants.WCL_DEFAULT_HOST
    end
    return {
        host = host,
        region = region,
        serverSlug = serverSlug,
        guildSlug = GC.Util.Trim(guildSlug),
    }
end

function GC.Sync:RegisterPrefix()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        self.registered = C_ChatInfo.RegisterAddonMessagePrefix(GC.Constants.COMM_PREFIX) == true
    elseif RegisterAddonMessagePrefix then
        self.registered = RegisterAddonMessagePrefix(GC.Constants.COMM_PREFIX) == true
    end
end

-- Der Anniversary-Client liefert Enum.SendAddonMessageResult (0 = Erfolg,
-- 3/8 = gedrosselt, ...), klassische Clients true oder gar nichts. Wer nur auf
-- "~= false" prueft, haelt gedrosselte Pakete fuer zugestellt - sie gehen dann
-- lautlos verloren und der Transfer bleibt ohne erkennbaren Grund
-- unvollstaendig. Nur ein echter Erfolg zaehlt als gesendet; alles andere
-- laesst die Warteschlangen mit ihrem Backoff erneut anlaufen.
local function AddonSendSucceeded(result)
    if result == nil or result == true then
        return true
    end
    if type(result) == "number" then
        return result == 0
    end
    return result ~= false
end

function GC.Sync:Send(payload, distribution, target)
    distribution = distribution or "GUILD"
    if not payload or #payload > GC.Constants.MAX_CHAT_BYTES then
        return false
    end
    if distribution == "GUILD" and (not IsInGuild or not IsInGuild()) then
        return false
    end
    if distribution == "WHISPER" and GC.Util.Trim(target) == "" then
        return false
    end

    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        local success, result = pcall(
            C_ChatInfo.SendAddonMessage,
            GC.Constants.COMM_PREFIX,
            payload,
            distribution,
            target
        )
        return success and AddonSendSucceeded(result)
    elseif SendAddonMessage then
        local success, result = pcall(
            SendAddonMessage,
            GC.Constants.COMM_PREFIX,
            payload,
            distribution,
            target
        )
        return success and AddonSendSucceeded(result)
    end
    return false
end

local function FinishBulkEntry(entry, success)
    if type(entry.callback) == "function" then
        pcall(entry.callback, success == true)
    end
end

-- Grosse Datenmengen landen in einer gemeinsamen, durchsatzorientierten
-- Warteschlange. Ein vorhandenes ChatThrottleLib kennt auch den Verkehr
-- anderer Addons; der eingebaute Fallback macht Guild Copilot eigenstaendig.
function GC.Sync:SendBulk(payload, distribution, target, callback)
    distribution = distribution or "GUILD"
    if not payload or #payload > GC.Constants.MAX_CHAT_BYTES then
        return false
    end
    if distribution == "GUILD" and (not IsInGuild or not IsInGuild()) then
        return false
    end
    if distribution == "WHISPER" and GC.Util.Trim(target) == "" then
        return false
    end

    local throttle = _G and _G.ChatThrottleLib
    if throttle and type(throttle.SendAddonMessage) == "function" then
        local queueName = GC.Constants.COMM_PREFIX .. ":" .. distribution .. ":" .. (target or "")
        local ok = pcall(
            throttle.SendAddonMessage,
            throttle,
            "BULK",
            GC.Constants.COMM_PREFIX,
            payload,
            distribution,
            target,
            queueName,
            function(_, sent)
                FinishBulkEntry({ callback = callback }, sent ~= false)
            end,
            nil
        )
        if ok then
            return true
        end
    end

    self.bulkQueue[#self.bulkQueue + 1] = {
        payload = payload,
        distribution = distribution,
        target = target,
        callback = callback,
        retries = 0,
    }
    -- Waehrend der Leerlaufpause hat sich das Sendebudget weiter gefuellt;
    -- die verstrichene Zeit wird beim Aufwachen in einem Schritt nachgebucht.
    local idle = 0
    if self.bulkIdleAt then
        idle = math.max(0, GC.Util.Now() - self.bulkIdleAt)
        self.bulkIdleAt = nil
    end
    bulkFrame:Show()
    self:PumpBulk(idle)
    return true
end

-- Werkstattkataloge und Gildenbankbestaende sind die einzigen wirklich grossen
-- Uebertragungen im Addon. Im Kampf haben sie nichts verloren: Dort zaehlt
-- jede Millisekunde, und niemand sieht in dem Moment in die Werkstatt.
-- Die Warteschlange bleibt dabei stehen, es geht nichts verloren - sie laeuft
-- weiter, sobald der Kampf vorbei ist.
--
-- Handshakes, Profile und Raidauswertungen laufen bewusst nicht hierueber:
-- Sie sind wenige Bytes und teils zeitkritisch.
local function InCombat()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        return true
    end
    return type(UnitAffectingCombat) == "function" and UnitAffectingCombat("player") == true
end

function GC.Sync:PumpBulk(elapsed)
    elapsed = math.max(0, tonumber(elapsed) or 0)
    self.bulkAllowance = math.min(
        BULK_BURST_BYTES,
        (tonumber(self.bulkAllowance) or BULK_BURST_BYTES) + (elapsed * BULK_BYTES_PER_SECOND)
    )

    if #self.bulkQueue > 0 and InCombat() then
        return
    end

    -- Hat der Client zuletzt eine Nachricht abgelehnt, erst nach einer echten
    -- Wartezeit erneut senden. Ohne diese Pause verbraucht ein Ratenlimit alle
    -- Wiederholungen im selben Sekundenbruchteil, und Pakete gelten faelschlich
    -- als verloren, obwohl der Kanal nur kurz dicht war.
    if (self.bulkCooldown or 0) > 0 then
        self.bulkCooldown = math.max(0, self.bulkCooldown - elapsed)
        if self.bulkCooldown > 0 then
            return
        end
    end

    while #self.bulkQueue > 0 do
        local entry = self.bulkQueue[1]
        local cost = #entry.payload + BULK_MESSAGE_OVERHEAD
        if self.bulkAllowance < cost then
            return
        end

        local sent = self:Send(entry.payload, entry.distribution, entry.target)
        if sent then
            self.bulkAllowance = self.bulkAllowance - cost
            table.remove(self.bulkQueue, 1)
            FinishBulkEntry(entry, true)
        else
            entry.retries = entry.retries + 1
            if entry.retries >= BULK_MAX_RETRIES then
                table.remove(self.bulkQueue, 1)
                FinishBulkEntry(entry, false)
            else
                -- Der Kanal hat abgelehnt (Client-Ratenlimit). Kein Kanalbudget
                -- verbraucht, aber mit wachsendem zeitlichem Abstand erneut
                -- versuchen, damit sich das Limit erholen kann.
                self.bulkAllowance = math.max(cost, self.bulkAllowance)
                self.bulkCooldown = math.min(
                    BULK_MAX_RETRY_DELAY,
                    BULK_RETRY_BACKOFF * entry.retries
                )
                return
            end
        end
    end

    -- Die Warteschlange ist leer: schlafen legen, bis SendBulk wieder etwas
    -- einreiht. Der Zeitstempel merkt sich den Beginn der Pause fuer die
    -- Budget-Nachbuchung beim Aufwachen.
    self.bulkIdleAt = self.bulkIdleAt or GC.Util.Now()
    bulkFrame:Hide()
end

local function ReliableEntryID(kind, token, target)
    return table.concat({
        tostring(kind or ""),
        tostring(token or ""),
        GC.Util.NormalizeName(target),
    }, "|")
end

function GC.Sync:GetReliablePendingCount(kind)
    local count = 0
    local function AddEntry(entry)
        if not kind or entry.kind == kind then
            count = count + math.max(0, #entry.messages - (entry.acknowledgedCount or 0))
        end
    end
    if self.reliableActive then
        AddEntry(self.reliableActive)
    end
    for _, entry in ipairs(self.reliableQueue) do
        AddEntry(entry)
    end
    return count
end

function GC.Sync:QueueReliable(messages, target, kind, token, onComplete, onFailure)
    if type(messages) ~= "table" or #messages == 0
        or GC.Util.Trim(target) == "" or GC.Util.Trim(kind) == ""
        or GC.Util.Trim(token) == "" then
        return false
    end
    for _, message in ipairs(messages) do
        if type(message) ~= "string" or #message > GC.Constants.MAX_CHAT_BYTES then
            return false
        end
    end

    local entry = {
        id = ReliableEntryID(kind, token, target),
        kind = kind,
        token = token,
        target = target,
        messages = messages,
        acknowledged = {},
        acknowledgedCount = 0,
        failed = {},
        failedCount = 0,
        pending = {},
        attempts = {},
        retryParts = {},
        nextPart = 1,
        inFlight = 0,
        onComplete = onComplete,
        onFailure = onFailure,
    }
    self.reliableQueue[#self.reliableQueue + 1] = entry
    self:PumpReliable()
    return true
end

function GC.Sync:FinishReliable(success)
    local entry = self.reliableActive
    if not entry then
        return
    end
    self.reliableActive = nil
    local callback = success and entry.onComplete or entry.onFailure
    if type(callback) == "function" then
        pcall(callback, entry)
    end
    if self.reliablePumping then
        self.reliablePumpPending = true
    else
        self:PumpReliable()
    end
end

-- Der Transfer ist fertig, sobald jedes Teilpaket entweder bestaetigt oder
-- endgueltig aufgegeben wurde. Erfolg meldet nur, wer kein einziges Paket
-- verloren hat; sonst geht die tatsaechliche Zahl verlorener Pakete in den
-- Fehlschlag-Rueckruf ein.
function GC.Sync:MaybeFinishReliable()
    local entry = self.reliableActive
    if not entry then
        return false
    end
    if (entry.acknowledgedCount + (entry.failedCount or 0)) >= #entry.messages then
        self:FinishReliable((entry.failedCount or 0) == 0)
        return true
    end
    return false
end

local function GiveUpReliablePart(self, entry, part)
    if entry.acknowledged[part] or entry.failed[part] then
        return
    end
    entry.failed[part] = true
    entry.failedCount = (entry.failedCount or 0) + 1
    if not self:MaybeFinishReliable() and self.reliableActive == entry then
        self:PumpReliable()
    end
end

function GC.Sync:ReliablePartDispatched(entryID, part, success)
    local entry = self.reliableActive
    if not entry or entry.id ~= entryID or entry.acknowledged[part] or entry.failed[part] then
        return
    end
    if not success then
        entry.attempts[part] = (entry.attempts[part] or 0) + 1
        entry.pending[part] = nil
        entry.inFlight = math.max(0, entry.inFlight - 1)
        if entry.attempts[part] >= RELIABLE_MAX_ATTEMPTS then
            GiveUpReliablePart(self, entry, part)
            return
        end
        entry.retryParts[#entry.retryParts + 1] = part
        self:PumpReliable()
        return
    end

    entry.attempts[part] = (entry.attempts[part] or 0) + 1
    local attempt = entry.attempts[part]
    if not C_Timer or type(C_Timer.After) ~= "function" then
        return
    end
    -- Wachsender Abstand: ein ueberlasteter Kanal bekommt mehr Zeit, das ACK
    -- doch noch zu liefern, bevor erneut gesendet wird.
    local delay = math.min(RELIABLE_RETRY_DELAY * attempt, RELIABLE_MAX_RETRY_DELAY)
    C_Timer.After(delay, function()
        local active = GC.Sync.reliableActive
        if not active or active.id ~= entryID or active.acknowledged[part]
            or active.failed[part]
            or active.attempts[part] ~= attempt or not active.pending[part] then
            return
        end
        active.pending[part] = nil
        active.inFlight = math.max(0, active.inFlight - 1)
        if attempt >= RELIABLE_MAX_ATTEMPTS then
            GiveUpReliablePart(GC.Sync, active, part)
            return
        end
        active.retryParts[#active.retryParts + 1] = part
        GC.Sync:PumpReliable()
    end)
end

function GC.Sync:PumpReliable()
    if self.reliablePumping then
        return
    end
    if not self.reliableActive then
        self.reliableActive = table.remove(self.reliableQueue, 1)
    end
    local entry = self.reliableActive
    if not entry then
        return
    end

    self.reliablePumping = true
    while self.reliableActive == entry and entry.inFlight < RELIABLE_WINDOW do
        local part = table.remove(entry.retryParts, 1)
        if not part then
            part = entry.nextPart
            entry.nextPart = entry.nextPart + 1
        end
        if not part or part > #entry.messages then
            break
        end
        if not entry.acknowledged[part] and not entry.pending[part] and not entry.failed[part] then
            local queuedPart = part
            entry.pending[part] = true
            entry.inFlight = entry.inFlight + 1
            local queued = self:SendBulk(entry.messages[queuedPart], "WHISPER", entry.target, function(success)
                GC.Sync:ReliablePartDispatched(entry.id, queuedPart, success)
            end)
            if not queued then
                -- Ein abgelehnter Sendeversuch (kein gueltiges Ziel, nicht in der
                -- Gilde) ist dauerhaft. Das Paket gilt als verloren, statt die
                -- Warteschlange ohne Fortschritt kreisen zu lassen.
                entry.pending[queuedPart] = nil
                entry.inFlight = math.max(0, entry.inFlight - 1)
                GiveUpReliablePart(self, entry, queuedPart)
                break
            end
        end
    end
    self.reliablePumping = false
    if self.reliablePumpPending or (not self.reliableActive and #self.reliableQueue > 0) then
        self.reliablePumpPending = false
        self:PumpReliable()
    end
end

function GC.Sync:SendReliableAck(kind, token, part, target)
    if GC.Util.Trim(kind) == "" or GC.Util.Trim(token) == ""
        or not tonumber(part) or GC.Util.Trim(target) == "" then
        return false
    end
    return self:Send(table.concat({
        "A",
        tostring(GC.Constants.SCHEMA_VERSION),
        GC.Util.EscapeField(kind),
        GC.Util.EscapeField(token),
        tostring(part),
    }, "|"), "WHISPER", target)
end

function GC.Sync:ReceiveReliableAck(fields, sender)
    if tonumber(fields[2]) ~= GC.Constants.SCHEMA_VERSION then
        return false
    end
    local kind = fields[3]
    local token = fields[4]
    local part = tonumber(fields[5])
    local entry = self.reliableActive
    if not entry or entry.kind ~= kind or entry.token ~= token
        or GC.Util.NormalizeName(entry.target) ~= GC.Util.NormalizeName(sender)
        or not part or part < 1 or part > #entry.messages
        or entry.acknowledged[part] then
        return false
    end

    -- Trifft doch noch ein spaetes ACK fuer ein bereits aufgegebenes Paket ein,
    -- zaehlt es wieder als zugestellt.
    if entry.failed[part] then
        entry.failed[part] = nil
        entry.failedCount = math.max(0, (entry.failedCount or 0) - 1)
    end
    entry.acknowledged[part] = true
    entry.acknowledgedCount = entry.acknowledgedCount + 1
    if entry.pending[part] then
        entry.pending[part] = nil
        entry.inFlight = math.max(0, entry.inFlight - 1)
    end
    if (entry.acknowledgedCount + (entry.failedCount or 0)) >= #entry.messages then
        self:FinishReliable((entry.failedCount or 0) == 0)
    else
        self:PumpReliable()
    end
    return true
end

function GC.Sync:BuildProfileMessage()
    local profile = GC.Profile:Get()
    local professions = profile.professions or {}
    local profession1 = professions[1] or {}
    local profession2 = professions[2] or {}
    local absence = profile.absence or {}
    local fields = {
        "P",
        tostring(GC.Constants.SCHEMA_VERSION),
        profile.classFile or "",
        profile.detectedSpecKey or "",
        profile.talentSignature or "",
        profile.raidSpecKey or "",
        profile.secondarySpecKey or "",
        profile.mainStatus or "MAIN",
        BoolField(profile.flex),
        BoolField(profile.confirmed),
        profession1.name or "",
        profession1.skillLevel and (profession1.skillLevel .. "/" .. (profession1.maxSkillLevel or 0)) or "",
        profession2.name or "",
        profession2.skillLevel and (profession2.skillLevel .. "/" .. (profession2.maxSkillLevel or 0)) or "",
        tostring(profile.updatedAt or GC.Util.Now()),
        absence.from or "",
        absence.to or "",
        absence.reason or "",
    }
    for index, value in ipairs(fields) do
        fields[index] = GC.Util.EscapeField(value)
    end
    return table.concat(fields, "|")
end

function GC.Sync:SendProfile()
    self.sendPending = false
    self:Send(self:BuildProfileMessage())
end

function GC.Sync:QueueProfile()
    if self.sendPending then
        return
    end
    self.sendPending = true
    C_Timer.After(1, function()
        self:SendProfile()
    end)
end

-- Auf Zuruf alles anstossen: Versionen und Profile erfragen, das eigene
-- Profil senden, das Gildenprofil nachfordern. Gedacht fuer den Fall, dass
-- jemand nicht auf den naechsten Login warten will.
function GC.Sync:RequestSync()
    local now = GC.Util.Now()
    if (now - (self.lastManualSyncAt or 0)) < MIN_MANUAL_SYNC_INTERVAL then
        return false, "Der Abgleich lief gerade eben schon."
    end
    self.lastManualSyncAt = now

    self:AnnounceVersion(true)
    self:QueueProfile()
    self:RequestGuildProfile()
    if GC.Workshop then
        GC.Workshop:RequestGuildData()
    end
    if GC.WarcraftLogs then
        GC.WarcraftLogs:RequestRecruitmentData()
    end
    return true, "Abgleich angefragt."
end

-- Antwort auf eine Anfrage. Gedrosselt, damit mehrere Logins kurz
-- hintereinander nicht jedes Mal das ganze Profil erneut durch die Gilde
-- schicken; wer neu dazukommt, hat es dann vom letzten Mal noch nicht, deshalb
-- ist das Fenster bewusst kurz gehalten.
function GC.Sync:ReplyWithProfile()
    local now = GC.Util.Now()
    if (now - (self.lastProfileReplyAt or 0)) < MIN_PROFILE_REPLY_INTERVAL then
        return false
    end
    self.lastProfileReplyAt = now
    self:QueueProfile()
    return true
end

function GC.Sync:BuildGuildProfileMessages()
    local guildData = GC.DB:GetGuild()
    local profile = guildData.profile
    local permissions = guildData.profilePermissions
    local templates = guildData.replyTemplates
    local memberCare = guildData.memberCare
    local roster = guildData.roster
    local inboxSound = guildData.inboxSound
    local fields = {
        "GP",
        tostring(profile.updatedAt or 0),
        profile.description or "",
        profile.raidTimes or "",
        profile.progress or "",
        profile.lootSystem or "",
        profile.discord or "",
        profile.contact or "",
        BoolField(permissions.configured),
        table.concat(SortedEnabledRanks(permissions.editorRanks), ","),
        templates.THANKS or "",
        templates.INFO or "",
        templates.DISCORD or "",
        tostring(memberCare.inactivityDays or 60),
        BoolField(memberCare.protectedRanksConfigured),
        table.concat(SortedEnabledRanks(memberCare.protectedRanks), ","),
        BoolField(memberCare.accessRanksConfigured),
        table.concat(SortedEnabledRanks(memberCare.accessRanks), ","),
        BoolField(roster.rankFilterConfigured),
        table.concat(SortedEnabledRanks(roster.activeRaiderRanks), ","),
        EncodeMemberCareDecisions(memberCare.decisions),
        EncodeEnchantRules(guildData.enchantRules),
        EncodeSpecEnchantRules(guildData.enchantSpecRules),
        EncodeWarcraftLogsSource(guildData.warcraftLogs),
        -- Die Content-Phase der Gilde. Sie entscheidet, welche Regeln des
        -- ausgelieferten Verzauberungs-Regelsatzes ueberhaupt schon gelten.
        profile.contentPhase or "",
        -- Welche Raenge den Bewerberton hoeren. Steht am Ende, damit aeltere
        -- Clients die Nutzlast weiter lesen koennen; sie spielen dann wie
        -- bisher nach ihrer eigenen Vorgabe.
        BoolField(inboxSound.ranksConfigured),
        table.concat(SortedEnabledRanks(inboxSound.ranks), ","),
    }
    for index, value in ipairs(fields) do
        fields[index] = GC.Util.EscapeField(value)
    end
    local payload = table.concat(fields, "|")
    local chunks = {}
    local chunkSize = 175
    for offset = 1, #payload, chunkSize do
        chunks[#chunks + 1] = payload:sub(offset, offset + chunkSize - 1)
    end
    local token = tostring(GC.Util.Now()) .. tostring(math.random(1000, 9999))
    local messages = {}
    for index, chunk in ipairs(chunks) do
        messages[index] = table.concat({
            "G",
            tostring(GC.Constants.SCHEMA_VERSION),
            token,
            tostring(index),
            tostring(#chunks),
            chunk,
        }, "|")
    end
    return messages
end

function GC.Sync:SendGuildProfile(force)
    self.guildProfileSendPending = false
    force = force == true or self.guildProfileForceSend
    self.guildProfileForceSend = false
    if not force and not GC.Roster:CanEditGuildProfile() then
        return false
    end
    local messages = self:BuildGuildProfileMessages()
    local index = 1
    local retries = 0
    local function SendNext()
        local message = messages[index]
        if not message then
            return
        end
        local sent = self:Send(message)
        if sent then
            index = index + 1
            retries = 0
        else
            retries = retries + 1
            if retries >= 5 then
                return
            end
        end
        if messages[index] then
            C_Timer.After(sent and 0.45 or 1.25, SendNext)
        end
    end
    SendNext()
    return true
end

function GC.Sync:QueueGuildProfile(force)
    self.guildProfileForceSend = self.guildProfileForceSend or force == true
    if self.guildProfileSendPending then
        return
    end
    self.guildProfileSendPending = true
    C_Timer.After(0.6, function()
        self:SendGuildProfile()
    end)
end

function GC.Sync:ReceiveGuildProfileChunk(message, sender)
    -- Der Abgleich ist rangunabhaengig: die neuesten Daten gewinnen. Jeder
    -- Client haelt eine Kopie des Gildenprofils, also darf sie auch von einem
    -- einfachen Mitglied kommen - etwa wenn ein Offizier frisch auf einem
    -- anderen Rechner einsteigt und nur ein Mitglied gerade online ist. Vor dem
    -- Ueberschreiben schuetzt weiter unten der Zeitstempelvergleich: ein
    -- aelterer Stand wird verworfen, nur ein neuerer uebernommen. Gesperrt bleibt
    -- lediglich, wer nachweislich kein Gildenmitglied ist.
    if #GC.Roster.members > 0 and not GC.Roster:IsGuildMember(sender)
        and not GC.Roster:CanEditGuildProfile(sender) then
        return
    end
    local schemaText, token, indexText, totalText, chunk =
        message:match("^G|([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.*)$")
    local schemaVersion = tonumber(schemaText)
    local index = tonumber(indexText)
    local total = tonumber(totalText)
    if schemaVersion ~= GC.Constants.SCHEMA_VERSION
        or not index or not total or index < 1 or index > total or total > 30
        or #token > 40 or #chunk > 175 then
        return
    end

    PruneIncoming(self.guildProfileIncoming)
    local incomingKey = GC.Util.NormalizeName(sender) .. "|" .. token
    local incoming = self.guildProfileIncoming[incomingKey]
    if not incoming or incoming.total ~= total then
        incoming = {
            total = total,
            chunks = {},
            receivedAt = GC.Util.Now(),
        }
        self.guildProfileIncoming[incomingKey] = incoming
    end
    incoming.chunks[index] = chunk

    local payloadParts = {}
    for chunkIndex = 1, total do
        if incoming.chunks[chunkIndex] == nil then
            return
        end
        payloadParts[chunkIndex] = incoming.chunks[chunkIndex]
    end
    self.guildProfileIncoming[incomingKey] = nil

    local fields = GC.Util.SplitFields(table.concat(payloadParts))
    if fields[1] ~= "GP" then
        return
    end
    local updatedAt = tonumber(fields[2]) or 0
    local guildData = GC.DB:GetGuild()
    if updatedAt < (tonumber(guildData.profile.updatedAt) or 0) then
        return
    end

    guildData.profile.description = fields[3] or ""
    guildData.profile.raidTimes = fields[4] or ""
    guildData.profile.progress = fields[5] or ""
    guildData.profile.lootSystem = fields[6] or ""
    guildData.profile.discord = fields[7] or ""
    guildData.profile.contact = fields[8] or ""
    guildData.profile.updatedAt = updatedAt
    guildData.profilePermissions.configured = fields[9] == "1"
    guildData.profilePermissions.editorRanks = DecodeEnabledRanks(fields[10])
    guildData.replyTemplates.THANKS = fields[11] or ""
    guildData.replyTemplates.INFO = fields[12] or ""
    guildData.replyTemplates.DISCORD = fields[13] or ""
    guildData.memberCare.inactivityDays = math.max(7, math.min(365, tonumber(fields[14]) or 60))
    guildData.memberCare.protectedRanksConfigured = fields[15] == "1"
    guildData.memberCare.protectedRanks = DecodeEnabledRanks(fields[16])
    guildData.memberCare.accessRanksConfigured = fields[17] == "1"
    guildData.memberCare.accessRanks = DecodeEnabledRanks(fields[18])
    guildData.roster.rankFilterConfigured = fields[19] == "1"
    guildData.roster.activeRaiderRanks = DecodeEnabledRanks(fields[20])
    -- Ältere Absender senden das Feld nicht; dann bleiben die eigenen
    -- Entscheidungen unangetastet statt gelöscht zu werden.
    if fields[21] ~= nil then
        guildData.memberCare.decisions = DecodeMemberCareDecisions(fields[21])
    end
    if fields[22] ~= nil then
        guildData.enchantRules = DecodeEnchantRules(fields[22])
        if GC.GearAudit then
            GC.GearAudit:ReapplyEnchantRules()
        end
    end
    -- Fehlt das Feld, sendet der Absender eine aeltere Version. Dann bleiben
    -- die eigenen Spec-Regeln stehen, statt geleert zu werden.
    if fields[23] ~= nil then
        guildData.enchantSpecRules = DecodeSpecEnchantRules(fields[23])
        if GC.GearAudit then
            GC.GearAudit:ReapplyEnchantRules()
        end
    end
    -- Die Warcraft-Logs-Gildenquelle. Ein leeres oder fehlendes Feld laesst die
    -- eigene Quelle stehen: wer sie noch nicht gesetzt hat, soll sie einem
    -- anderen nicht loeschen.
    local wclSource = fields[24] ~= nil and DecodeWarcraftLogsSource(fields[24]) or nil
    if wclSource and GC.WarcraftLogs then
        GC.WarcraftLogs:ApplySource(wclSource)
    end
    -- Die Content-Phase. Nur bekannte Phasen werden uebernommen; ein leeres
    -- oder fehlendes Feld laesst die eigene Einstellung stehen, damit ein
    -- aelterer Client sie nicht zurueckdreht.
    local phase = fields[25]
    if type(phase) == "string" and GC.ContentPhaseByKey[phase] then
        guildData.profile.contentPhase = phase
        if GC.GearAudit then
            GC.GearAudit:ReapplyEnchantRules()
        end
    end
    -- Die Rangfreigabe fuer den Bewerberton. Fehlt das Feld, sendet ein
    -- aelterer Client; dann bleibt die eigene Freigabe stehen, statt auf
    -- "niemand hoert etwas" zurueckzufallen.
    if fields[26] ~= nil then
        guildData.inboxSound.ranksConfigured = fields[26] == "1"
        guildData.inboxSound.ranks = DecodeEnabledRanks(fields[27])
    end
    GC:FireCallback("GUILD_PROFILE_UPDATED", sender)
    GC:FireCallback("SETTINGS_UPDATED")
end

function GC.Sync:RequestGuildProfile()
    self:Send("GQ|" .. tostring(GC.Constants.SCHEMA_VERSION))
end

-- Antwort auf eine Gildenprofil-Anfrage. Offiziere schicken ihren Stand immer.
-- Einfache Mitglieder geben ihre zwischengespeicherte Kopie nur weiter, wenn
-- sie ueberhaupt eine gepflegte Fassung haben - so bekommt ein frisch
-- eingestiegener Client die Infos auch dann, wenn gerade kein Offizier online
-- ist. Der Zeitstempelvergleich beim Empfaenger sorgt dafuer, dass niemand
-- einen neueren Stand mit einer alten Kopie ueberschreibt.
function GC.Sync:ReplyToGuildProfileRequest()
    local canEdit = GC.Roster:CanEditGuildProfile()
    local hasProfile = (tonumber(GC.DB:GetGuild().profile.updatedAt) or 0) > 0
    if not canEdit and not hasProfile then
        return false
    end
    local now = GC.Util.Now()
    if (now - (self.lastGuildProfileReplyAt or 0)) < MIN_PROFILE_REPLY_INTERVAL then
        return false
    end
    self.lastGuildProfileReplyAt = now
    if not C_Timer or type(C_Timer.After) ~= "function" then
        self:SendGuildProfile(true)
        return true
    end
    C_Timer.After(0.5 + math.random(), function()
        GC.Sync:SendGuildProfile(true)
    end)
    return true
end

-- Direkt nach dem Login ist der Gildenroster oft noch leer; dann steht der
-- eigene Rang noch nicht fest. Ein paar Versuche warten darauf, damit ein
-- Offizier nicht faelschlich als einfaches Mitglied startet. Anschliessend wird
-- immer der aktuellste Stand erfragt (Annahme regelt der Zeitstempel), und wer
-- selbst pflegen darf, schickt seinen Stand zusaetzlich aktiv in die Gilde.
function GC.Sync:PrimeGuildProfileSync(attempt)
    attempt = tonumber(attempt) or 1
    if #GC.Roster.members == 0 and attempt < 5 and C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(2, function()
            GC.Sync:PrimeGuildProfileSync(attempt + 1)
        end)
        return
    end
    self:RequestGuildProfile()
    if GC.Roster:CanEditGuildProfile() then
        self:QueueGuildProfile()
    end
end

function GC.Sync:ReceiveProfile(fields, sender)
    local schemaVersion = tonumber(fields[2]) or 0
    local classFile = fields[3]
    local detectedSpecKey = fields[4] ~= "" and fields[4] or nil
    local raidSpecKey = fields[6] ~= "" and fields[6] or nil
    local secondarySpecKey
    local statusIndex = 7
    if schemaVersion >= 3 then
        secondarySpecKey = fields[7] ~= "" and fields[7] or nil
        statusIndex = 8
    end
    if not GC.Classes[classFile] then
        return
    end
    if detectedSpecKey and (not GC.SpecByKey[detectedSpecKey] or GC.SpecByKey[detectedSpecKey].classFile ~= classFile) then
        return
    end
    if raidSpecKey and (not GC.SpecByKey[raidSpecKey] or GC.SpecByKey[raidSpecKey].classFile ~= classFile) then
        return
    end
    if secondarySpecKey and (not GC.SpecByKey[secondarySpecKey] or GC.SpecByKey[secondarySpecKey].classFile ~= classFile) then
        return
    end
    if secondarySpecKey == raidSpecKey then
        secondarySpecKey = nil
    end

    local updatedAtIndex = statusIndex + 3
    local professions = {}
    if schemaVersion >= 4 then
        local function ReadSyncedProfession(name, skillText)
            if name == "" then
                return nil
            end
            local skillLevel, maxSkillLevel = tostring(skillText or ""):match("^(%d+)/(%d+)$")
            return {
                name = name,
                skillLevel = tonumber(skillLevel) or 0,
                maxSkillLevel = tonumber(maxSkillLevel) or 0,
            }
        end
        professions[1] = ReadSyncedProfession(fields[statusIndex + 3], fields[statusIndex + 4])
        professions[2] = ReadSyncedProfession(fields[statusIndex + 5], fields[statusIndex + 6])
        updatedAtIndex = statusIndex + 7
    end

    local profile = {
        fullName = sender,
        classFile = classFile,
        detectedSpecKey = detectedSpecKey,
        talentSignature = fields[5],
        raidSpecKey = raidSpecKey,
        secondarySpecKey = secondarySpecKey,
        mainStatus = fields[statusIndex] == "ALT" and "ALT" or "MAIN",
        flex = fields[statusIndex + 1] == "1",
        confirmed = fields[statusIndex + 2] == "1",
        professions = professions,
        updatedAt = tonumber(fields[updatedAtIndex]) or GC.Util.Now(),
        receivedAt = GC.Util.Now(),
    }
    if schemaVersion >= 6 then
        profile.absence = {
            from = fields[updatedAtIndex + 1] or "",
            to = fields[updatedAtIndex + 2] or "",
            reason = fields[updatedAtIndex + 3] or "",
        }
    else
        profile.absence = {
            from = "",
            to = "",
            reason = "",
        }
    end
    local key = GC.Util.NormalizeName(sender)
    local shortKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(sender))
    local profiles = GC.DB:GetGuild().remoteProfiles
    profiles[key] = profile
    profiles[shortKey] = profile
    GC:FireCallback("ROSTER_UPDATED")
end

function GC.Sync:BuildVersionMessage(requestReply)
    local fields = {
        "V",
        tostring(GC.Constants.SCHEMA_VERSION),
        GC.Constants.VERSION,
        table.concat(GC.Capabilities, ","),
        BoolField(requestReply),
        -- Feld 6: anonymes Account-Kennzeichen. Damit lassen sich die
        -- Charaktere eines Spielers zusammenfassen - WoW selbst verraet das
        -- nie. Aeltere Clients ignorieren das Feld schlicht.
        GC.DB:GetAccountTag(),
    }
    for index, value in ipairs(fields) do
        fields[index] = GC.Util.EscapeField(value)
    end
    return table.concat(fields, "|")
end

function GC.Sync:AnnounceVersion(requestReply, minimumInterval)
    minimumInterval = tonumber(minimumInterval) or 0
    local now = GC.Util.Now()
    if minimumInterval > 0 and (now - (self.lastAnnounceAt or 0)) < minimumInterval then
        return false
    end
    if not self:Send(self:BuildVersionMessage(requestReply)) then
        return false
    end
    self.lastAnnounceAt = now
    return true
end

function GC.Sync:NoteAddonUser(sender, info)
    if GC.Util.Trim(sender) == "" then
        return false
    end
    info = info or {}

    local guildData = GC.DB:GetGuild()
    local key = GC.Util.NormalizeName(sender)
    local shortKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(sender))
    local entry = guildData.addonUsers[key] or guildData.addonUsers[shortKey]
    local changed = entry == nil
    entry = entry or {}

    local schemaVersion = tonumber(info.schemaVersion)
    if schemaVersion and entry.schemaVersion ~= schemaVersion then
        entry.schemaVersion = schemaVersion
        changed = true
    end
    local version = GC.Util.Trim(info.version)
    if version ~= "" and entry.version ~= version then
        entry.version = version
        changed = true
    end
    local capabilities = GC.Util.Trim(info.capabilities)
    if capabilities ~= "" and entry.capabilities ~= capabilities then
        entry.capabilities = capabilities
        changed = true
    end
    local accountTag = GC.Util.Trim(info.accountTag)
    if accountTag ~= "" and entry.accountTag ~= accountTag then
        entry.accountTag = accountTag
        changed = true
    end
    if info.source == "HANDSHAKE" and not entry.handshake then
        entry.handshake = true
        changed = true
    end

    entry.name = sender
    entry.seenAt = GC.Util.Now()
    guildData.addonUsers[key] = entry
    guildData.addonUsers[shortKey] = entry
    if changed then
        GC:FireCallback("ADDON_USERS_UPDATED")
    end
    return changed
end

function GC.Sync:ReceiveVersion(fields, sender)
    local schemaVersion = tonumber(fields[2])
    if not schemaVersion then
        return
    end
    self:NoteAddonUser(sender, {
        schemaVersion = schemaVersion,
        version = fields[3],
        capabilities = fields[4],
        accountTag = fields[6],
        source = "HANDSHAKE",
    })

    -- Nur auf ausdrückliche Anfragen antworten, niemals auf eine Antwort.
    if fields[5] == "1" then
        C_Timer.After(0.5 + math.random() * 4, function()
            self:AnnounceVersion(false, MIN_REPLY_INTERVAL)
        end)
        -- Das eigene Profil gleich mitschicken. Ohne diese Antwort erfaehrt ein
        -- Client nur von denen etwas, die sich nach ihm einloggen oder ihr
        -- Profil aendern: Wer zuerst da war, hat laengst in einen leeren Raum
        -- gesendet.
        --
        -- Die Streuung haengt an der Zahl der bekannten Nutzer. Bei zweien
        -- muss niemand zehn Sekunden warten; bei zwanzig darf nicht alles
        -- gleichzeitig losgehen, sonst verschluckt der Addon-Kanal Nachrichten.
        local others = math.max(0, (self:GetAddonUserStats().known or 1) - 1)
        local spread = math.min(9, math.max(1, others))
        C_Timer.After(0.5 + math.random() * spread, function()
            self:ReplyWithProfile()
        end)
        if GC.GearAudit then
            GC.GearAudit:ReplyWithEquipmentSnapshot()
        end
    end
end

function GC.Sync:GetAddonUser(name)
    local addonUsers = GC.DB:GetGuild().addonUsers
    return addonUsers[GC.Util.NormalizeName(name)]
        or addonUsers[GC.Util.NormalizeName(GC.Util.PlayerShortName(name))]
end

function GC.Sync:GetAddonUserStats()
    local stats = {
        known = 1,
        compatible = 1,
        outdated = 0,
        ahead = 0,
        -- "known" zaehlt Charaktere, "players" Accounts: wer mit Main und zwei
        -- Twinks unterwegs war, ist ein Spieler und nicht drei. Charaktere ohne
        -- gemeldetes Kennzeichen zaehlen einzeln - lieber eine Zahl zu hoch als
        -- fremde Spieler faelschlich zusammenlegen.
        players = 1,
        outdatedNames = {},
    }
    local ownTag = GC.DB:GetAccountTag()
    local countedTags = {}

    -- Ausgetretene Mitglieder erst ausblenden, wenn das Roster gelesen ist;
    -- direkt nach dem Login ist es noch leer.
    local rosterReady = #GC.Roster.members > 0
    local seen = {}
    for _, entry in pairs(GC.DB:GetGuild().addonUsers or {}) do
        if not seen[entry] and (not rosterReady or GC.Roster:IsGuildMember(entry.name)) then
            seen[entry] = true
            stats.known = stats.known + 1
            local accountTag = GC.Util.Trim(entry.accountTag)
            if accountTag == "" then
                stats.players = stats.players + 1
            elseif accountTag ~= ownTag and not countedTags[accountTag] then
                countedTags[accountTag] = true
                stats.players = stats.players + 1
            end
            local schemaVersion = tonumber(entry.schemaVersion) or 0
            if schemaVersion == GC.Constants.SCHEMA_VERSION then
                stats.compatible = stats.compatible + 1
            elseif schemaVersion > GC.Constants.SCHEMA_VERSION then
                stats.ahead = stats.ahead + 1
                stats.outdatedNames[#stats.outdatedNames + 1] = GC.Util.PlayerShortName(entry.name)
            else
                stats.outdated = stats.outdated + 1
                stats.outdatedNames[#stats.outdatedNames + 1] = GC.Util.PlayerShortName(entry.name)
            end
        end
    end
    table.sort(stats.outdatedNames)
    return stats
end

function GC.Sync:AnnounceSessionStart(session)
    return self:Send(table.concat({
        "RS",
        tostring(GC.Constants.SCHEMA_VERSION),
        session.id,
        tostring(session.startedAt),
        GC.Util.EscapeField(session.zone or ""),
    }, "|"), "RAID")
end

function GC.Sync:AnnounceSessionEnd(summary)
    return self:Send(table.concat({
        "RE",
        tostring(GC.Constants.SCHEMA_VERSION),
        summary.id,
        tostring(summary.endedAt),
    }, "|"), "RAID")
end

-- Die Zusammenfassung geht gedrosselt und in Teilen raus; fehlgeschlagene
-- Pakete werden begrenzt wiederholt, damit keine Lücke entsteht.
function GC.Sync:DistributeSummary(summary, distribution, target)
    local messages = GC.RaidMonitor:BuildSummaryMessages(summary)
    local index = 1
    local retries = 0
    local function SendNext()
        local message = messages[index]
        if not message then
            return
        end
        local sent = self:Send(message, distribution or "RAID", target)
        if sent then
            index = index + 1
            retries = 0
        else
            retries = retries + 1
            if retries >= 5 then
                return
            end
        end
        if messages[index] then
            C_Timer.After(sent and 0.5 or 1.5, SendNext)
        end
    end
    SendNext()
    return #messages
end

function GC.Sync:OnMessage(prefix, message, distribution, sender)
    if prefix ~= GC.Constants.COMM_PREFIX then
        return
    end
    if GC.Util.NormalizeName(sender) == GC.Util.NormalizeName(GC:GetPlayerFullName()) then
        return
    end

    if distribution ~= "GUILD" and distribution ~= "WHISPER"
        and distribution ~= "RAID" and distribution ~= "PARTY" then
        return
    end

    -- Ältere Clients kennen den Handshake nicht. Ihre Schemaversion steht aber
    -- in jedem P-, W-, G- und GQ-Paket, sodass sie trotzdem als Addon-Nutzer
    -- mit abweichender Version sichtbar werden.
    local messageType, messageSchema = message:match("^(%a+)|(%d+)")
    if messageType == "P" or messageType == "W" or messageType == "G"
        or messageType == "GQ" or messageType == "E" or messageType == "L"
        or messageType == "B" or messageType == "O" then
        self:NoteAddonUser(sender, { schemaVersion = messageSchema, source = "TRAFFIC" })
    end

    -- Direkte Datentransfers duerfen nur von Gildenmitgliedern kommen. Direkt
    -- nach dem Login ist der Roster noch leer; dann greift diese Zusatzpruefung
    -- bewusst noch nicht.
    if distribution == "WHISPER" and #GC.Roster.members > 0
        and (messageType == "A" or messageType == "W" or messageType == "L"
            or messageType == "E" or messageType == "O")
        and not GC.Roster:IsGuildMember(sender) then
        return
    end

    if messageType == "A" and distribution == "WHISPER" then
        self:ReceiveReliableAck(GC.Util.SplitFields(message), sender)
        return
    elseif message:sub(1, 2) == "W|" and (distribution == "GUILD" or distribution == "WHISPER") then
        local fields = GC.Util.SplitFields(message)
        if tonumber(fields[2]) == GC.Constants.SCHEMA_VERSION and GC.Workshop then
            GC.Workshop:ReceiveSync(fields, sender, distribution)
        end
        return
    elseif message:sub(1, 2) == "B|" and distribution == "GUILD" then
        -- Materialbestand: geteilt wird ausschliesslich die Gildenbank, und die
        -- gehoert allen. Eigene Taschen- und Bankbestaende verlassen den Account
        -- nie, es gibt fuer sie gar keinen Sendeweg.
        if GC.Inventory then
            GC.Inventory:ReceiveSync(GC.Util.SplitFields(message), sender)
        end
        return
    elseif message:sub(1, 2) == "L|" and (distribution == "GUILD" or distribution == "WHISPER") then
        local fields = GC.Util.SplitFields(message)
        if tonumber(fields[2]) == GC.Constants.SCHEMA_VERSION and GC.WarcraftLogs then
            GC.WarcraftLogs:ReceiveSync(fields, sender, distribution)
        end
        return
    elseif message:sub(1, 2) == "G|" and distribution == "GUILD" then
        self:ReceiveGuildProfileChunk(message, sender)
        return
    elseif message:sub(1, 2) == "E|" and (distribution == "GUILD" or distribution == "WHISPER") then
        if GC.GearAudit then
            GC.GearAudit:ReceiveEquipmentChunk(message, sender)
        end
        return
    elseif message == ("RQ|" .. tostring(GC.Constants.SCHEMA_VERSION)) and distribution == "GUILD" then
        if GC.RaidMonitor then
            GC.RaidMonitor:OnMessage(message, sender, distribution)
        end
        return
    elseif message == ("GQ|" .. tostring(GC.Constants.SCHEMA_VERSION)) and distribution == "GUILD" then
        self:ReplyToGuildProfileRequest()
        return
    end

    -- Gildenaufträge: Broadcasts über den Gildenkanal, Abgleichantworten
    -- gezielt per Flüstern. Vor dem Raid-Sammelzweig, der WHISPER schluckt.
    if messageType == "O" and (distribution == "GUILD" or distribution == "WHISPER") then
        if GC.Orders then
            GC.Orders:OnMessage(message, sender, distribution)
        end
        return
    end

    -- Raidauswertungen verwenden RAID/PARTY sowie gezielte WHISPER-Antworten.
    -- Erst nachdem die gildenweiten Direkttransfers oben geroutet wurden,
    -- landet der restliche Verkehr beim Raidmodul.
    if distribution == "RAID" or distribution == "PARTY" or distribution == "WHISPER" then
        if GC.RaidMonitor then
            GC.RaidMonitor:OnMessage(message, sender, distribution)
        end
        return
    end

    local fields = GC.Util.SplitFields(message)
    local schemaVersion = tonumber(fields[2])
    if fields[1] == "P"
        and (schemaVersion == 2 or schemaVersion == 3 or schemaVersion == 4
            or schemaVersion == 5 or schemaVersion == 6
            or schemaVersion == GC.Constants.SCHEMA_VERSION) then
        self:ReceiveProfile(fields, sender)
    elseif fields[1] == "V" then
        -- Bewusst ohne Schemaprüfung: gerade abweichende Versionen sollen
        -- erkannt werden.
        self:ReceiveVersion(fields, sender)
    end
end

local syncEvents = CreateFrame("Frame")
syncEvents:RegisterEvent("CHAT_MSG_ADDON")
syncEvents:RegisterEvent("GROUP_ROSTER_UPDATE")
syncEvents:SetScript("OnEvent", function(_, event, prefix, message, distribution, sender)
    if event == "GROUP_ROSTER_UPDATE" then
        local inGroup = IsInGroup and IsInGroup() == true
        if inGroup and not GC.Sync.wasInGroup then
            GC.Sync:AnnounceVersion(false, MIN_ANNOUNCE_INTERVAL)
        end
        GC.Sync.wasInGroup = inGroup
        return
    end
    GC.Sync:OnMessage(prefix, message, distribution, sender)
end)

-- Der Rahmen selbst steht oben bei den BULK-Konstanten; er ist nur sichtbar,
-- solange die Warteschlange Arbeit hat.
bulkFrame:SetScript("OnUpdate", function(_, elapsed)
    GC.Sync:PumpBulk(elapsed)
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.Sync, function(self)
    self:RegisterPrefix()
    C_Timer.After(3, function()
        self:QueueProfile()
    end)
    C_Timer.After(5, function()
        self:PrimeGuildProfileSync()
    end)
    C_Timer.After(7, function()
        self.wasInGroup = IsInGroup and IsInGroup() == true
        self:AnnounceVersion(true)
    end)
    C_Timer.After(9, function()
        if GC.WarcraftLogs then
            GC.WarcraftLogs:RequestRecruitmentData()
        end
    end)
    C_Timer.After(13, function()
        -- Gildenaufträge abgleichen: Wer etwas kennt, liefert es nach.
        if GC.Orders then
            GC.Orders:RequestSync()
        end
    end)
    C_Timer.After(17, function()
        -- ... und der Gegenweg: die eigenen laufenden Aufträge in die Gilde
        -- drücken, für alle, an denen die Live-Broadcasts vorbeigingen.
        if GC.Orders then
            GC.Orders:PushOwnOrders()
        end
    end)
end)

GC:RegisterCallback("PROFILE_UPDATED", GC.Sync, function(self)
    self:QueueProfile()
end)
