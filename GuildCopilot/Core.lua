local addonName, GC = ...

_G.GuildCopilot = GC

GC.addonName = addonName
GC.callbacks = {}
GC.initialized = false

function GC:Print(message)
    local prefix = "|cff4ec9ffGuild Copilot:|r "
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(prefix .. tostring(message))
    end
end

function GC:RegisterCallback(eventName, owner, callback)
    if type(eventName) ~= "string" or type(callback) ~= "function" then
        return
    end

    self.callbacks[eventName] = self.callbacks[eventName] or {}
    table.insert(self.callbacks[eventName], { owner = owner, callback = callback })
end

function GC:FireCallback(eventName, ...)
    local callbacks = self.callbacks[eventName]
    if not callbacks then
        return
    end

    for _, entry in ipairs(callbacks) do
        local ok, err = pcall(entry.callback, entry.owner, ...)
        if not ok then
            self:Print("|cffff5555Fehler in " .. eventName .. ":|r " .. tostring(err))
        end
    end
end

-- === Messung ==============================================================
--
-- Ob ein Ruckler vom Addon kommt, laesst sich nicht aus dem Code lesen, nur
-- messen. Diese Messung ist standardmaessig aus und kostet dann genau einen
-- Tabellenzugriff je Aufruf; eingeschaltet wird sie mit "/gcp debug".
--
-- Gemessen wird mit debugprofilestop() statt GetTimePreciseSec(): Ersteres
-- gibt es in jeder Spielfassung, Letzteres nicht.
GC.Perf = {
    enabled = false,
    samples = {},
}

function GC.Perf:Clock()
    if type(debugprofilestop) == "function" then
        return debugprofilestop()
    end
    return nil
end

-- Lua 5.1 (WoW) kennt unpack global, spaetere Fassungen nur table.unpack.
local unpackValues = unpack or table.unpack

function GC.Perf:Measure(label, fn, ...)
    if type(fn) ~= "function" then
        return
    end
    if not self.enabled then
        return fn(...)
    end
    -- Die Rueckgabe muss durchgereicht werden, und zwar VOLLSTAENDIG.
    --
    -- Hier stand "fn(...)" ohne return: Ausgeschaltet lieferte die Messung das
    -- Ergebnis der gemessenen Funktion, eingeschaltet nichts. Damit aenderte
    -- "/gcp debug" das Programmverhalten statt es nur zu beobachten - eine
    -- Messung, die das Gemessene veraendert, ist wertlos, und der naechste
    -- Aufrufer waere darauf hereingefallen. Die Zwischentabelle kostet eine
    -- Belegung je Aufruf; das ist genau dann hinnehmbar, wenn ohnehin gemessen
    -- wird, und im Regelfall (aus) wird sie nie angelegt.
    local started = self:Clock()
    local results = { fn(...) }
    local finished = self:Clock()
    if not started or not finished then
        return unpackValues(results)
    end
    local elapsed = finished - started
    local sample = self.samples[label]
    if not sample then
        sample = { count = 0, total = 0, worst = 0 }
        self.samples[label] = sample
    end
    sample.count = sample.count + 1
    sample.total = sample.total + elapsed
    if elapsed > sample.worst then
        sample.worst = elapsed
    end
    return unpackValues(results)
end

function GC.Perf:Reset()
    self.samples = {}
end

-- Sortiert nach der schlechtesten Einzelmessung: Ein Ruckler ist ein einzelner
-- langer Aufruf, kein hoher Durchschnitt.
function GC.Perf:Report()
    local rows = {}
    for label, sample in pairs(self.samples) do
        rows[#rows + 1] = { label = label, sample = sample }
    end
    if #rows == 0 then
        return { "Noch nichts gemessen." }
    end
    table.sort(rows, function(left, right)
        return left.sample.worst > right.sample.worst
    end)
    local lines = {}
    for index = 1, math.min(#rows, 12) do
        local row = rows[index]
        lines[#lines + 1] = string.format("%s: %d\195\151, schlimmste %.1f ms, Schnitt %.1f ms",
            row.label, row.sample.count, row.sample.worst, row.sample.total / row.sample.count)
    end
    return lines
end

GC.Util = {}

function GC.Util.Trim(value)
    if type(value) ~= "string" then
        return ""
    end
    return value:match("^%s*(.-)%s*$") or ""
end

function GC.Util.NormalizeName(name)
    name = GC.Util.Trim(name):lower()
    return name:gsub("%s+", "")
end

function GC.Util.PlayerShortName(name)
    if type(name) ~= "string" then
        return ""
    end
    return name:match("^([^-]+)") or name
end

-- Der Schluessel, unter dem ein Charakter in allen Tabellen steht.
--
-- Derselbe Charakter erreicht das Addon je nach Quelle mit und ohne
-- Realmanteil: GetPlayerFullName() haengt ihn immer an, UnitName() nie, und
-- der Absender einer Addon-Nachricht mal so, mal so. Wer beides ungeprueft als
-- Schluessel nimmt, fuehrt denselben Spieler doppelt - genau das ist in der
-- Werkstatt passiert, waehrend Raidmonitor und Ausruestungspruefung laengst
-- gekuerzt haben. Der Realm faellt deshalb ueberall weg; in einer TBC-Gilde
-- sind ohnehin alle auf demselben Realm.
function GC.Util.PlayerKey(name)
    return GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
end

function GC.Util.DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, item in pairs(value) do
        result[GC.Util.DeepCopy(key)] = GC.Util.DeepCopy(item)
    end
    return result
end

function GC.Util.MergeDefaults(target, defaults)
    target = type(target) == "table" and target or {}
    for key, defaultValue in pairs(defaults) do
        if target[key] == nil then
            target[key] = GC.Util.DeepCopy(defaultValue)
        elseif type(defaultValue) == "table" then
            if type(target[key]) ~= "table" then
                -- Alte oder von Hand bearbeitete SavedVariables dürfen einen
                -- ganzen Einstellungszweig nicht unbenutzbar machen.
                target[key] = GC.Util.DeepCopy(defaultValue)
            else
                GC.Util.MergeDefaults(target[key], defaultValue)
            end
        end
    end
    return target
end

function GC.Util.JoinGerman(items)
    if #items == 0 then
        return ""
    elseif #items == 1 then
        return items[1]
    elseif #items == 2 then
        -- Die Bindewoerter laufen durch die Sprachschicht: Auf englischen
        -- Clients wird aus "A und B" ein "A and B".
        return items[1] .. GC.L(" und ") .. items[2]
    end

    local head = {}
    for index = 1, #items - 1 do
        head[#head + 1] = items[index]
    end
    return table.concat(head, ", ") .. GC.L(" sowie ") .. items[#items]
end

function GC.Util.SafeChatText(text, maximumBytes)
    text = GC.Util.Trim(text)
    maximumBytes = math.max(0, math.floor(tonumber(maximumBytes) or GC.Constants.MAX_CHAT_BYTES))
    if #text <= maximumBytes then
        return text
    end

    local suffix = maximumBytes >= 4 and "..." or ""
    local contentBytes = maximumBytes - #suffix
    if contentBytes <= 0 then
        return suffix:sub(1, maximumBytes)
    end

    local clipped = text:sub(1, contentBytes)
    if #clipped > 0 and clipped:byte(#clipped) >= 128 then
        local sequenceStart = #clipped
        while sequenceStart > 1 do
            local byte = clipped:byte(sequenceStart)
            if byte < 128 or byte >= 192 then
                break
            end
            sequenceStart = sequenceStart - 1
        end

        local lead = clipped:byte(sequenceStart)
        local expectedBytes
        if lead and lead >= 194 and lead <= 223 then
            expectedBytes = 2
        elseif lead and lead >= 224 and lead <= 239 then
            expectedBytes = 3
        elseif lead and lead >= 240 and lead <= 244 then
            expectedBytes = 4
        end
        local availableBytes = #clipped - sequenceStart + 1
        if not expectedBytes or availableBytes < expectedBytes then
            clipped = clipped:sub(1, sequenceStart - 1)
        end
    end

    local lastSpace = clipped:match("^.*()%s")
    if suffix ~= "" and lastSpace and lastSpace > contentBytes * 0.7 then
        clipped = clipped:sub(1, lastSpace - 1)
    end
    return clipped .. suffix
end

function GC.Util.EscapeField(value)
    value = tostring(value or "")
    return value:gsub("%%", "%%25"):gsub("|", "%%7C"):gsub("\n", "%%0A")
end

function GC.Util.UnescapeField(value)
    value = tostring(value or "")
    return value:gsub("%%0A", "\n"):gsub("%%7C", "|"):gsub("%%25", "%%")
end

function GC.Util.SplitFields(payload)
    local fields = {}
    for field in (tostring(payload) .. "|"):gmatch("(.-)|") do
        fields[#fields + 1] = GC.Util.UnescapeField(field)
    end
    return fields
end

-- Zeitstempel entscheiden gildenweit, welcher Stand des Gildenprofils gewinnt.
-- Die lokale Systemuhr taugt dafuer schlecht: Sie geht auf jedem Rechner ein
-- bisschen anders, und eine falsch gestellte Uhr in der Zukunft konnte jede
-- spaetere Aenderung der ganzen Gilde blockieren. GetServerTime() liefert
-- dagegen fuer alle auf demselben Realm dieselbe Zeit. Wo es die Funktion
-- nicht gibt, bleibt es bei der Systemuhr.
function GC.Util.Now()
    if GetServerTime then
        local ok, serverTime = pcall(GetServerTime)
        if ok and tonumber(serverTime) then
            return serverTime
        end
    end
    return time and time() or 0
end

function GC.Util.TodayISO()
    return date and date("%Y-%m-%d") or "1970-01-01"
end

function GC.Util.AddDaysISO(days)
    days = tonumber(days) or 0
    if date and time then
        local ok, value = pcall(date, "%Y-%m-%d", time() + (days * 24 * 60 * 60))
        if ok and type(value) == "string" and value:match("^%d%d%d%d%-%d%d%-%d%d$") then
            return value
        end
    end
    return GC.Util.TodayISO()
end

local DAYS_PER_MONTH = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

function GC.Util.IsLeapYear(year)
    year = tonumber(year)
    if not year then
        return false
    end
    return year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0)
end

function GC.Util.DaysInMonth(year, month)
    month = tonumber(month)
    if not month or month < 1 or month > 12 then
        return nil
    end
    if month == 2 and GC.Util.IsLeapYear(year) then
        return 29
    end
    return DAYS_PER_MONTH[month]
end

function GC.Util.FormatISO(year, month, day)
    return string.format("%04d-%02d-%02d", tonumber(year) or 0, tonumber(month) or 0, tonumber(day) or 0)
end

function GC.Util.IsValidISODate(value)
    local year, month, day = tostring(value or ""):match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    if not year or year < 2000 or year > 2099 or not month or month < 1 or month > 12 or not day then
        return false
    end
    return day >= 1 and day <= (GC.Util.DaysInMonth(year, month) or 0)
end

-- Nimmt an, was Leute tatsaechlich tippen. Anlass war die Rueckmeldung aus der
-- Gilde: Mit "JJJJ-MM-TT" kommen viele nicht zurecht und tragen 15.08.2026 ein.
-- Das ist keine Fehleingabe, sondern die hier uebliche Schreibweise - sie wird
-- deshalb angenommen und umgerechnet. Gespeichert und synchronisiert wird
-- weiterhin ausschliesslich ISO: Nur damit funktionieren die Vergleiche
-- "liegt zwischen von und bis" ueber einen simplen Stringvergleich.
function GC.Util.NormalizeDateInput(value)
    value = GC.Util.Trim(value)
    if value == "" then
        return ""
    end
    if GC.Util.IsValidISODate(value) then
        return value
    end
    -- 15.8.2026, 15.08.2026, 15/8/2026 und dieselben mit zweistelligem Jahr.
    local day, month, year = value:match("^(%d%d?)[%.%-/](%d%d?)[%.%-/](%d%d%d%d)$")
    if not day then
        day, month, year = value:match("^(%d%d?)[%.%-/](%d%d?)[%.%-/](%d%d)$")
        if year then
            year = "20" .. year
        end
    end
    if not day then
        return value
    end
    local candidate = GC.Util.FormatISO(year, month, day)
    if not GC.Util.IsValidISODate(candidate) then
        return value
    end
    return candidate
end

local function ISODateOrdinal(value)
    if not GC.Util.IsValidISODate(value) then
        return nil
    end
    local year, month, day = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    local monthOffsets = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 }
    local leapDays = math.floor((year - 1) / 4) - math.floor((year - 1) / 100)
        + math.floor((year - 1) / 400)
    local ordinal = ((year - 1) * 365) + leapDays + monthOffsets[month] + day
    if month > 2 and (year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0)) then
        ordinal = ordinal + 1
    end
    return ordinal
end

-- Wochentag eines ISO-Datums, 1 = Montag bis 7 = Sonntag.
--
-- Gerechnet statt gefragt: date()/time() haengen an der Systemzeitzone und der
-- Sommerzeit, und ein Kalenderblatt, das je nach Uhrzeit einen Tag verrutscht,
-- waere schlimmer als keins. Die fortlaufende Tagesnummer oben gibt es ohnehin;
-- als Anker dient der 1. Januar 2000, ein Samstag.
local ANCHOR_ORDINAL = 730120
local ANCHOR_WEEKDAY = 6

function GC.Util.WeekdayOfISO(value)
    local ordinal = ISODateOrdinal(value)
    if not ordinal then
        return nil
    end
    return ((ordinal - ANCHOR_ORDINAL + ANCHOR_WEEKDAY - 1) % 7) + 1
end

function GC.Util.DaysBetweenISO(left, right)
    local leftOrdinal = ISODateOrdinal(left)
    local rightOrdinal = ISODateOrdinal(right)
    if not leftOrdinal or not rightOrdinal then
        return nil
    end
    return rightOrdinal - leftOrdinal
end

function GC.Util.IsDateInRange(value, rangeFrom, rangeTo)
    return GC.Util.IsValidISODate(value)
        and GC.Util.IsValidISODate(rangeFrom)
        and GC.Util.IsValidISODate(rangeTo)
        and value >= rangeFrom
        and value <= rangeTo
end

-- Der eigene Name aendert sich innerhalb einer Sitzung nicht. Er wurde
-- trotzdem bei jedem Aufruf neu aus drei API-Aufrufen und einer
-- Zeichenverkettung zusammengesetzt - und er steht in Schleifen ueber alle
-- Gildenmitglieder (Roster:GetProfile ruft ihn zweimal je Mitglied auf, bei
-- 500 Mitgliedern also tausendmal je Uebersicht).
--
-- Gemerkt wird ausdruecklich NUR ein belastbarer Name: Direkt nach dem Laden
-- gibt der Client noch keinen heraus, und ein gemerktes "Unbekannt" waere fuer
-- den Rest der Sitzung falsch. PLAYER_LOGIN verwirft den Merker zusaetzlich,
-- damit der erste belastbare Stand auch wirklich der gemerkte ist.
function GC:GetPlayerFullName()
    local cached = self.playerFullName
    if cached then
        return cached
    end

    -- Hier stand "local name, realm = UnitFullName and UnitFullName(...)".
    -- Lua kuerzt einen and-Ausdruck auf genau einen Wert, realm blieb deshalb
    -- immer leer und wurde jedes Mal ueber den Fallback unten neu geholt.
    local name, realm
    if UnitFullName then
        name, realm = UnitFullName("player")
    end
    if not name or name == "" then
        name = UnitName and UnitName("player")
    end
    if not realm or realm == "" then
        realm = GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName and GetRealmName() or ""
    end
    -- Ohne Namen darf hier nichts verkettet werden, sonst bricht der Aufruf ab.
    if not name or name == "" then
        return "Unbekannt"
    end

    local fullName = name
    if realm and realm ~= "" then
        fullName = name .. "-" .. realm
    end
    self.playerFullName = fullName
    return fullName
end

function GC:GetGuildName()
    local guildName = GetGuildInfo and GetGuildInfo("player")
    return guildName or ""
end

function GC:GetGuildKey()
    local guildName = self:GetGuildName()
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName and GetRealmName() or ""
    if guildName == "" then
        return "UNGUILDED@" .. realm
    end
    return guildName .. "@" .. realm
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName == addonName then
            GC:FireCallback("ADDON_LOADED")
        end
    elseif event == "PLAYER_LOGIN" then
        GC.initialized = true
        -- Erst ab hier gibt der Client Namen und Realm belastbar heraus; ein
        -- frueher gemerkter Stand wird deshalb verworfen.
        GC.playerFullName = nil
        GC:FireCallback("PLAYER_LOGIN")
        GC:Print(GC.LFormat("v{v} geladen. Öffnen mit |cffffffff/gcp|r.",
            { v = GC.Constants.VERSION }))
    end
end)
