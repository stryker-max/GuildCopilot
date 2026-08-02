local _, GC = ...

GC.WarcraftLogs = {
    syncIncoming = {},
    syncCompleted = {},
    syncDiscoveries = {},
    syncRequestReplies = {},
}

local REGION_SLUGS = {
    [1] = "us",
    [2] = "kr",
    [3] = "eu",
    [4] = "tw",
    [5] = "cn",
}

local function DecodePath(value)
    value = tostring(value or ""):gsub("%+", " ")
    return (value:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

local function EncodePath(value)
    value = GC.Util.Trim(value):lower()
    value = value:gsub("ä", "a"):gsub("ö", "o"):gsub("ü", "u"):gsub("ß", "ss")
    value = value:gsub("%s+", "-")
    return (value:gsub("[^%w%-]", function(character)
        return string.format("%%%02X", string.byte(character))
    end))
end

local function PutImportedProfile(members, name, profile)
    local fullKey = GC.Util.NormalizeName(name)
    local shortKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    members[fullKey] = profile
    members[shortKey] = profile
end

local function NormalizeLabel(value)
    value = GC.Util.Trim(value):lower()
    value = value:gsub("ä", "a"):gsub("ö", "o"):gsub("ü", "u"):gsub("ß", "ss")
    return (value:gsub("[^%w]", ""))
end

local function ResolveClass(value)
    local direct = GC.Util.Trim(value):upper()
    if GC.Classes[direct] then
        return direct
    end
    local normalized = NormalizeLabel(value)
    for classFile, classInfo in pairs(GC.Classes) do
        if normalized == NormalizeLabel(classFile)
            or normalized == NormalizeLabel(classInfo.name)
            or normalized == NormalizeLabel(classInfo.plural) then
            return classFile
        end
    end
end

local function ResolveSpec(classFile, value)
    value = GC.Util.Trim(value)
    local direct = value:upper()
    if GC.SpecByKey[direct] and GC.SpecByKey[direct].classFile == classFile then
        return direct
    end
    local normalized = NormalizeLabel(value)
    local classInfo = GC.Classes[classFile]
    for _, spec in ipairs(classInfo and classInfo.specs or {}) do
        if normalized == NormalizeLabel(spec.name) or normalized == NormalizeLabel(spec.recruitLabel) then
            return spec.key
        end
    end
end

function GC.WarcraftLogs:ParseGuildURL(url)
    url = GC.Util.Trim(url)
    local region, serverSlug, guildSlug
    local scheme, host, path = url:match("^([Hh][Tt][Tt][Pp][Ss]?)://([^/]+)(/.*)$")
    local sourceHost
    if scheme then
        host = host:lower()
        if host ~= "warcraftlogs.com" and not host:match("%.warcraftlogs%.com$") then
            return nil, "Bitte einen gültigen Warcraft-Logs-Gildenlink einfügen."
        end
        -- Der eingegebene Host wird uebernommen, statt auf eine feste Variante
        -- normalisiert zu werden. Sonst verliert eine gespeicherte Quelle wie
        -- "de.fresh.warcraftlogs.com" beim Speichern ihre Sprachvariante.
        sourceHost = host
        local cleanPath = path:match("^([^?#]*)") or ""
        region, serverSlug, guildSlug =
            cleanPath:match("^/guild/([^/]+)/([^/]+)/([^/]+)/?$")
    end
    if not region then
        region, serverSlug, guildSlug = url:match("^([^/]+)/([^/]+)/([^/?#]+)/?$")
    end
    if not region or not serverSlug or not guildSlug then
        return nil, "Bitte einen gültigen Warcraft-Logs-Gildenlink einfügen."
    end

    region = region:lower()
    serverSlug = serverSlug:lower()
    guildSlug = DecodePath(guildSlug:gsub("/$", ""))
    if guildSlug == "" or guildSlug:find("[/%z\1-\31]") then
        return nil, "Der Gildenname im Warcraft-Logs-Link ist ungültig."
    end
    if region ~= "eu" and region ~= "us" and region ~= "kr" and region ~= "tw" and region ~= "cn" then
        return nil, "Die Region im Warcraft-Logs-Link wird nicht unterstützt."
    end
    sourceHost = sourceHost or GC.Constants.WCL_DEFAULT_HOST
    return {
        url = "https://" .. sourceHost .. "/guild/"
            .. region .. "/" .. serverSlug .. "/" .. EncodePath(guildSlug),
        host = sourceHost,
        region = region,
        serverSlug = serverSlug,
        guildSlug = guildSlug,
    }
end

-- Uebernimmt eine Gildenquelle, die nicht aus einer eingegebenen URL stammt,
-- sondern ueber das Gildenprofil aus der Gilde kam. Die anzeigbare URL entsteht
-- hier, damit das Pfad-Encoding an einer Stelle bleibt.
function GC.WarcraftLogs:ApplySource(source)
    if type(source) ~= "table"
        or GC.Util.Trim(source.region) == ""
        or GC.Util.Trim(source.serverSlug) == "" then
        return false
    end
    local data = GC.DB:GetGuild().warcraftLogs
    local host = GC.Util.Trim(source.host)
    if host == "" then
        host = GC.Constants.WCL_DEFAULT_HOST
    end
    data.host = host
    data.region = source.region
    data.serverSlug = source.serverSlug
    data.guildSlug = source.guildSlug or ""
    data.url = "https://" .. host .. "/guild/" .. source.region .. "/"
        .. source.serverSlug .. "/" .. EncodePath(data.guildSlug)
    GC:FireCallback("WCL_UPDATED")
    return true
end

-- Der Host der gespeicherten Gildenquelle. Bestandsdaten aus Versionen ohne
-- dieses Feld fallen auf die Vorgabe zurueck.
function GC.WarcraftLogs:GetHost()
    local host = GC.Util.Trim(GC.DB:GetGuild().warcraftLogs.host)
    if host == "" then
        return GC.Constants.WCL_DEFAULT_HOST
    end
    return host
end

function GC.WarcraftLogs:GetSuggestedURL()
    local regionID = GetCurrentRegion and GetCurrentRegion() or 3
    local region = REGION_SLUGS[regionID] or "eu"
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName and GetRealmName() or ""
    local guildName = GC:GetGuildName()
    if guildName == "" or realm == "" then
        return ""
    end
    return "https://" .. self:GetHost() .. "/guild/"
        .. region .. "/" .. EncodePath(realm) .. "/" .. EncodePath(guildName)
end

-- Region und Realm-Slug fuer Charakter-Links. Die gespeicherte Gildenquelle ist
-- die verlaesslichste Angabe: Interessenten schreiben in TBC vom selben Realm.
-- Fehlt sie, wird aus Client-Region und eigenem Realm abgeleitet.
function GC.WarcraftLogs:GetCharacterScope(playerName)
    local data = GC.DB:GetGuild().warcraftLogs
    local region = GC.Util.Trim(data.region)
    if region == "" then
        region = REGION_SLUGS[GetCurrentRegion and GetCurrentRegion() or 3] or "eu"
    end

    -- Steht am Namen ein Realm, gilt dieser - sonst der Realm der Gildenquelle
    -- und zuletzt der eigene.
    local realmFromName = tostring(playerName or ""):match("^[^-]+%-(.+)$")
    local serverSlug = ""
    if realmFromName and GC.Util.Trim(realmFromName) ~= "" then
        serverSlug = EncodePath(realmFromName)
    end
    if serverSlug == "" then
        serverSlug = GC.Util.Trim(data.serverSlug)
    end
    if serverSlug == "" then
        local realm = GetNormalizedRealmName and GetNormalizedRealmName()
            or GetRealmName and GetRealmName() or ""
        serverSlug = EncodePath(realm)
    end
    return region, serverSlug
end

-- Kopierbare Profil-Links zu einem Interessenten. WoW-Addons duerfen weder
-- Browser oeffnen noch in die Zwischenablage schreiben; der Nutzer markiert und
-- kopiert selbst. Ohne ermittelbaren Realm entstehen bewusst keine halben
-- Links, sondern leere Zeichenketten.
function GC.WarcraftLogs:BuildCharacterLinks(playerName)
    local characterName = GC.Util.PlayerShortName(GC.Util.Trim(playerName))
    if characterName == "" then
        return { armory = "", logs = "" }
    end
    local region, serverSlug = self:GetCharacterScope(playerName)
    if serverSlug == "" then
        return { armory = "", logs = "" }
    end

    local encodedName = EncodePath(characterName)
    local function Fill(template)
        local link = tostring(template or "")
        link = link:gsub("<host>", self:GetHost())
        link = link:gsub("<region>", region)
        link = link:gsub("<realm>", serverSlug)
        link = link:gsub("<name>", encodedName)
        return link
    end
    return {
        armory = Fill(GC.Constants.ARMORY_CHARACTER_URL),
        logs = Fill(GC.Constants.WCL_CHARACTER_URL),
    }
end

function GC.WarcraftLogs:SaveSource(url)
    local source, errorMessage = self:ParseGuildURL(url)
    if not source then
        return false, errorMessage
    end
    local guildData = GC.DB:GetGuild()
    local data = guildData.warcraftLogs
    data.url = source.url
    data.host = source.host
    data.region = source.region
    data.serverSlug = source.serverSlug
    data.guildSlug = source.guildSlug
    -- Die Quelle gilt fuer die ganze Gilde: sie liefert auch Region und Realm
    -- fuer die Profil-Links im Postfach. Deshalb wandert sie ueber das
    -- Gildenprofil zu allen Mitgliedern, damit nur einer sie pflegen muss.
    guildData.profile.updatedAt = GC.Util.Now()
    if GC.Sync and GC.Sync.QueueGuildProfile then
        GC.Sync:QueueGuildProfile(true)
    end
    GC:FireCallback("WCL_UPDATED")
    return true, "Warcraft-Logs-Gilde gespeichert und für die Gilde synchronisiert."
end

-- Der Companion liefert Verbrauchsgegenstände als "Spell-ID:Anzahl". Welche
-- Kategorie dahintersteckt, entscheidet allein GC.Consumables im Addon;
-- unbekannte IDs werden ignoriert und erzeugen so nie falsche Zahlen.
local function DecodeConsumables(payload)
    local counters = {}
    for _, category in ipairs(GC.ConsumableCategories) do
        counters[category.key] = 0
    end

    -- Neben den Zählern bleiben die exakten Gegenstände erhalten (Name und
    -- Anzahl): Der Klick auf einen Teilnehmer zeigt sie im Detail. Uhrzeiten
    -- kennt der Logs-Export nicht.
    local items = {}
    for token in tostring(payload or ""):gmatch("[^,]+") do
        local spellID, count = token:match("^(%d+):(%d+)$")
        count = tonumber(count) or 0
        local consumable = spellID and GC.Consumables[tonumber(spellID)]
        local category = consumable and GC.ConsumableCategoryByKey[consumable.category]
        if category then
            -- Übernommen wird die gemeldete Anzahl, für JEDE Kategorie.
            -- Vorher wurden dauerhafte Buffs auf eins je Zauber gestutzt: Wer
            -- nach drei Wipes dreimal Buffood gegessen hatte, stand mit einem
            -- Essen da, und dieselbe Kappe traf Fläschchen und Elixiere. Der
            -- Companion zählt bereits Verbräuche, nicht Zustände - die zweite
            -- Zählung hier hat sie nur wieder eingeebnet.
            counters[category.key] = counters[category.key] + count
            if count > 0 then
                items[#items + 1] = {
                    n = consumable.name,
                    c = category.key,
                    count = count,
                }
            end
        elseif spellID and count > 0 then
            -- Unbekannte IDs verschwinden nicht mehr: kein Zähler (keine
            -- falschen Zahlen in den Spalten), aber ein Eintrag in der
            -- Gegenstandsliste - den Namen kennt notfalls der Spielclient.
            items[#items + 1] = { s = tonumber(spellID), count = count }
        end
    end
    return counters, items
end

-- Feste Suchmuster brechen, sobald das Format ein Feld dazubekommt. Deshalb
-- werden die Zeilen zerlegt statt gematcht: fehlende Felder sind leer,
-- zusätzliche Felder älterer oder neuerer Companion-Versionen stören nicht.
local function SplitFields(line)
    local fields = {}
    local position = 1
    while true do
        local separator = line:find("|", position, true)
        if not separator then
            fields[#fields + 1] = line:sub(position)
            break
        end
        fields[#fields + 1] = line:sub(position, separator - 1)
        position = separator + 1
    end
    return fields
end

-- Der Offline-Import nennt keine Zone: Sie steht im Combat Log nicht, wohl aber
-- die Bossnamen. Die Zuordnung Boss zu Instanz gibt es im Addon schon
-- (GC.RaidBosses), also wird sie hier benutzt statt eine zweite Tabelle im
-- Installer zu pflegen. Ein Abend in zwei Instanzen bekommt beide genannt.
local function ZoneFromBosses(payload)
    local instances = {}
    local seen = {}
    for name in tostring(payload or ""):gmatch("[^,]+") do
        local boss = GC.RaidMonitor and GC.RaidMonitor:ResolveBoss(GC.Util.Trim(name))
        if boss and not seen[boss.instance] then
            seen[boss.instance] = true
            instances[#instances + 1] = boss.instance
        end
    end
    return table.concat(instances, " / ")
end

local function ParseSessionLine(line, source)
    local fields = SplitFields(line)
    local code = GC.Util.Trim(fields[2] or "")
    local startedAt, endedAt, zone, pulls, kills, wipes =
        fields[3], fields[4], fields[5], fields[6], fields[7], fields[8]
    if code == "" then
        return nil
    end
    zone = GC.Util.Trim(zone)
    if zone == "" then
        zone = ZoneFromBosses(fields[9])
    end
    return {
        id = source .. ":" .. code,
        reportCode = code,
        startedAt = tonumber(startedAt) or 0,
        endedAt = tonumber(endedAt) or 0,
        zone = zone,
        startedBy = "",
        pulls = tonumber(pulls) or 0,
        kills = tonumber(kills) or 0,
        wipes = tonumber(wipes) or 0,
        participants = {},
        source = source,
        receivedAt = GC.Util.Now(),
    }
end

local function ParseParticipantLine(line)
    local fields = SplitFields(line)
    local name = GC.Util.Trim(fields[2] or "")
    if name == "" then
        return nil
    end
    local consumables, consumableItems = DecodeConsumables(fields[8])
    -- Feld 9 kam mit GCPWCL3 dazu; ältere Exporte lassen es weg.
    return {
        name = name,
        classFile = ResolveClass(fields[3]),
        seconds = math.max(0, tonumber(fields[4]) or 0),
        deaths = tonumber(fields[5]) or 0,
        resurrects = tonumber(fields[9]) or 0,
        interrupts = tonumber(fields[6]) or 0,
        dispels = tonumber(fields[7]) or 0,
        consumables = consumables,
        consumableItems = consumableItems,
    }
end

-- Beim Einfügen in WoW gehen einzelne Zeilenumbrüche verloren. Zwei Zeilen
-- verschmelzen dann zu einer und beide sind unbrauchbar: die Kopfzeile klebte
-- am ersten Profil, die Sitzungszeile am letzten - übrig blieben Profile und
-- lauter Teilnehmerzeilen ohne Sitzung.
--
-- Reparieren lässt sich das, weil die Marker eindeutig sind: eine Pipe kommt
-- nur als Feldtrenner vor, Namen werden davon befreit. Wo also mitten in einer
-- Zeile ein Datensatz beginnt, gehört davor ein Umbruch. Zusätzliche Leerzeilen
-- schaden nicht, die werden ohnehin übersprungen.
local function RepairLineBreaks(text)
    text = text:gsub("^(GCP%u+%d+|?%d*)", "%1\n")
    text = text:gsub("([^\n])(GCP%u+%d)", "%1\n%2")
    text = text:gsub("([^\n])(S|[%w%-]+|%d)", "%1\n%2")
    text = text:gsub("([^\n])(P|[^|\n]+|)", "%1\n%2")
    return text
end

function GC.WarcraftLogs:Import(text)
    text = tostring(text or ""):gsub("\r", "")
    -- Der WoW-Client verdoppelt beim Einfügen jede Pipe (Schutz vor
    -- Escape-Sequenzen): aus "S|code|…" wird "S||code||…". Der Parser las
    -- dann ein leeres Feld und verwarf Sitzungs- wie Teilnehmerzeilen
    -- kommentarlos - die Profilzeilen (Semikolons) überlebten als Einzige.
    -- Erkennbar ist das Escaping sicher am doppelten Trenner direkt nach dem
    -- Zeilentyp; echte Daten haben dort nie ein leeres Feld. Halbieren macht
    -- aus "||||" (leeres Feld, escaped) wieder "||" und aus "||" wieder "|".
    if text:find("S||", 1, true) or text:find("P||", 1, true)
        or text:match("GCP%u+%d+||") then
        text = text:gsub("||", "|")
    end
    text = RepairLineBreaks(text)
    local headerSeen = false
    local importSource = "MANUAL"
    local imported = {}
    local reportCount = 0

    local sessions = {}
    local currentSession
    -- Quelle der Sitzungen in diesem Import. Der Offline-Import aus dem Combat
    -- Log bleibt von Warcraft Logs getrennt: Beide beschreiben denselben Abend
    -- unterschiedlich genau, und Zahlen verschiedener Quellen werden nie
    -- miteinander verrechnet.
    local sessionSource = "WCL"

    -- Mitgezählt wird, was hereinkam. Ohne diese Zahlen lässt sich ein
    -- unvollständig eingefügter Export nicht von einem reinen Profilexport
    -- unterscheiden - genau daran ging eine Nachanalyse stumm verloren.
    local lineCount = 0
    local participantLines = 0
    -- Teilnehmerzeilen, deren Sitzungszeile (noch) fehlt. Sie werden nicht
    -- mehr sofort verworfen: Taucht im selben Import doch eine Sitzung auf,
    -- gehören sie zu ihr - ein zerwürfelter Paste stellt Zeilen auch mal um.
    local pendingParticipants = {}
    -- Die erste Zeile, die kein bekanntes Format hat, wandert in die
    -- Fehlermeldung. Ohne sie lässt sich aus der Ferne nie sagen, WAS beim
    -- Einfügen kaputtging.
    local firstUnknownLine

    for line in (text .. "\n"):gmatch("(.-)\n") do
        line = GC.Util.Trim(line)
        if line ~= "" then
            lineCount = lineCount + 1
            local marker, reports = line:match("^(GCP%u+%d+)|?(%d*)$")
            if marker then
                headerSeen = true
                if marker:sub(1, 6) == "GCPLOG" then
                    -- Der Offline-Import bringt keine Profile mit; die Klasse
                    -- steht im Combat Log nicht.
                    sessionSource = "LOG"
                else
                    importSource = "WARCRAFT_LOGS"
                    reportCount = tonumber(reports) or 0
                end
            elseif line:sub(1, 2) == "S|" then
                currentSession = ParseSessionLine(line, sessionSource)
                if currentSession then
                    sessions[#sessions + 1] = currentSession
                end
            elseif line:sub(1, 2) == "P|" then
                participantLines = participantLines + 1
                local participant = ParseParticipantLine(line)
                if participant and currentSession then
                    currentSession.participants[#currentSession.participants + 1] = participant
                elseif participant then
                    pendingParticipants[#pendingParticipants + 1] = participant
                end
            elseif line:match("^|%d*$") then
                -- Bruchstück der Kopfzeile: Beim Einfügen riss "GCPWCL3|1"
                -- zwischen Marker und Reportzahl auseinander. Die Zahl ist
                -- verzichtbar - überspringen statt als unlesbar melden.
                local fragment = tonumber(line:match("^|(%d+)$"))
                if headerSeen and reportCount == 0 and fragment then
                    reportCount = fragment
                end
            else
                local name, classFile, primarySpecKey, secondarySpecKey = line:match("^([^;]+);([^;]+);([^;]*);?([^;]*)$")
                name = GC.Util.Trim(name)
                classFile = ResolveClass(classFile)
                primarySpecKey = ResolveSpec(classFile, primarySpecKey)
                secondarySpecKey = ResolveSpec(classFile, secondarySpecKey)
                if name ~= "" and GC.Classes[classFile]
                    and GC.SpecByKey[primarySpecKey]
                    and GC.SpecByKey[primarySpecKey].classFile == classFile then
                    if not GC.SpecByKey[secondarySpecKey]
                        or GC.SpecByKey[secondarySpecKey].classFile ~= classFile
                        or secondarySpecKey == primarySpecKey then
                        secondarySpecKey = nil
                    end
                    local profile = {
                        fullName = name,
                        classFile = classFile,
                        raidSpecKey = primarySpecKey,
                        secondarySpecKey = secondarySpecKey,
                        confirmed = false,
                        source = importSource,
                        updatedAt = GC.Util.Now(),
                        receivedAt = GC.Util.Now(),
                    }
                    PutImportedProfile(imported, name, profile)
                elseif not firstUnknownLine then
                    firstUnknownLine = line
                end
            end
        end
    end

    -- Rettung statt Müll: Standen Teilnehmerzeilen vor ihrer Sitzungszeile,
    -- gehören sie zur ersten Sitzung dieses Imports. Nur wenn der ganze Paste
    -- keine einzige Sitzungszeile enthielt, bleibt es beim Fehlerhinweis.
    local orphanParticipants = 0
    if #pendingParticipants > 0 then
        if sessions[1] then
            for index = #pendingParticipants, 1, -1 do
                table.insert(sessions[1].participants, 1, pendingParticipants[index])
            end
        else
            orphanParticipants = #pendingParticipants
        end
    end

    -- In Chatnachrichten wäre "|" der Beginn einer Escape-Sequenz; für die
    -- Diagnosezeile wird das Zeichen deshalb ersetzt und die Zeile gekürzt.
    local unknownSample
    if firstUnknownLine then
        unknownSample = firstUnknownLine:sub(1, 44):gsub("|", "/")
            .. (#firstUnknownLine > 44 and "…" or "")
    end

    local uniqueCount = 0
    local seenProfiles = {}
    for _, profile in pairs(imported) do
        if not seenProfiles[profile] then
            seenProfiles[profile] = true
            uniqueCount = uniqueCount + 1
        end
    end

    local usableSessions = 0
    for _, session in ipairs(sessions) do
        if #session.participants > 0 then
            usableSessions = usableSessions + 1
        end
    end

    if lineCount == 0 then
        return false, "Das Importfeld ist leer."
    end

    if uniqueCount == 0 and usableSessions == 0 then
        if orphanParticipants > 0 then
            return false, orphanParticipants .. " Teilnehmerzeilen angekommen, aber keine einzige "
                .. "Sitzungszeile (S|…). Bitte das Feld leeren und die Importdatei KOMPLETT neu "
                .. "kopieren und einfügen."
                .. (unknownSample and (" Erste unlesbare Zeile: „" .. unknownSample .. "“") or "")
        end
        if headerSeen then
            -- Die Kopfzeile kam an, der Rest nicht: typischerweise wurde beim
            -- Einfügen abgeschnitten oder der Companion hat nur den Kopf
            -- geschrieben.
            return false, "Companion-Kopfzeile erkannt, aber keine Datenzeilen. Bitte den kompletten Inhalt der Importdatei einfügen."
                .. (unknownSample and (" Erste unlesbare Zeile: „" .. unknownSample .. "“") or "")
        end
        return false, "Keine gültigen Profile gefunden. Format: Name;Klasse;Primär-Spec;Dual-Spec"
    end

    local data = GC.DB:GetGuild().warcraftLogs
    -- Der Offline-Import aus dem Combat Log liefert keine Profile und keine
    -- Warcraft-Logs-Quelle. Er darf den dortigen Stand deshalb nicht anfassen -
    -- sonst löschte ein Logimport die Herkunftsangabe eines echten Reports.
    if sessionSource == "WCL" then
        if uniqueCount > 0 then
            data.members = imported
        end
        data.importedAt = GC.Util.Now()
        -- Ein eigener Import ersetzt einen zuvor empfangenen Stand.
        data.lastSyncFrom = ""
        if headerSeen then
            data.reportCount = reportCount
        end
    end

    -- Nachanalysen werden als eigene Auswertungen abgelegt und niemals mit
    -- einer Livesitzung verrechnet.
    local storedSessionIDs = {}
    for _, session in ipairs(sessions) do
        if #session.participants > 0 then
            GC.RaidMonitor:StoreSummary(session)
            -- Gezählt wird, was hinterher wirklich DA ist. StoreSummary kann
            -- "erfolgreich" speichern und die Aufbewahrung wirft den Eintrag
            -- gleich wieder hinaus - genau das darf nie mehr als Erfolg
            -- durchgehen.
            -- Ausdruecklich mit Quelle: Eine gleichnamige Livesitzung ist kein
            -- Beleg dafuer, dass dieser Import angekommen ist.
            if GC.RaidMonitor:GetSummary(session.id, session.source) ~= nil then
                storedSessionIDs[session.id] = true
            end
        end
    end
    local storedSessions = 0
    for _ in pairs(storedSessionIDs) do
        storedSessions = storedSessions + 1
    end
    if sessionSource == "WCL" then
        local knownWclSessions = 0
        for _, summary in ipairs(GC.RaidMonitor:GetSummaries()) do
            if summary.source == "WCL" then
                knownWclSessions = knownWclSessions + 1
            end
        end
        data.sessionCount = knownWclSessions
    end

    GC:FireCallback("WCL_UPDATED")
    GC:FireCallback("ROSTER_UPDATED")
    if GC.Sync and GC.Sync.Send then
        self:AnnounceRecruitmentData()
    end

    local parts = {}
    if uniqueCount > 0 then
        parts[#parts + 1] = uniqueCount .. (headerSeen and " Warcraft-Logs-Profile" or " Profile")
    end
    if storedSessions > 0 then
        parts[#parts + 1] = storedSessions
            .. (sessionSource == "LOG" and " Raidabende aus dem Combat Log" or " Raidauswertungen")
    end
    local message = GC.Util.JoinGerman(parts) .. " importiert."

    -- Ein Teilerfolg muss als solcher dastehen. Ein Companion-Export bringt
    -- immer eine Kopfzeile mit; fehlt sie, wurde unvollständig eingefügt und
    -- die Raidauswertung geht still verloren.
    local hints = {}
    if not headerSeen then
        hints[#hints + 1] = "ohne Companion-Kopfzeile"
    end
    if orphanParticipants > 0 then
        hints[#hints + 1] = orphanParticipants .. " Teilnehmerzeilen ohne Sitzungszeile (S|…) verworfen"
            .. " – bitte die Datei komplett neu einfügen"
    end
    if headerSeen and storedSessions == 0 and participantLines == 0 then
        hints[#hints + 1] = "keine Raidauswertung enthalten"
    end
    if usableSessions > storedSessions then
        hints[#hints + 1] = (usableSessions - storedSessions)
            .. " Auswertungen erkannt, aber nicht behalten – die Aufbewahrung hat sie verworfen; bitte melden"
    end
    if unknownSample and (orphanParticipants > 0 or storedSessions == 0) then
        hints[#hints + 1] = "erste unlesbare Zeile: „" .. unknownSample .. "“"
    end
    if #hints > 0 then
        message = message .. " Hinweis: " .. GC.Util.JoinGerman(hints) .. "."
    end
    return true, message
end

function GC.WarcraftLogs:GetImportedCount()
    local data = GC.DB:GetGuild().warcraftLogs
    local seen = {}
    local count = 0
    for _, profile in pairs(data.members or {}) do
        if not seen[profile] then
            seen[profile] = true
            count = count + 1
        end
    end
    return count
end

-- === Gildenweiter Rekrutierungs-Datensatz ================================
-- Die Copilot-Vorschläge hängen sowohl an importierten Log-Profilen als auch
-- an bereits bekannten Addon-Profilen. Bis 0.9.21 blieben beide Caches auf dem
-- Rechner, der sie zuerst gesehen hatte. Der folgende Transfer verteilt die
-- Profile selbst (keine kompletten Kampfprotokolle) und führt Addon-Profile
-- anhand ihres Zeitstempels zusammen.

local RECRUITMENT_PAYLOAD_BYTES = 160
local RECRUITMENT_MAX_PARTS = 100
local RECRUITMENT_INCOMING_TTL = 5 * 60
local RECRUITMENT_DISCOVERY_WAIT = 0.9
local RECRUITMENT_REPLY_INTERVAL = 15

local function SanitizedSyncField(value, maximumBytes)
    value = GC.Util.Trim(value):gsub("[,;|%%]", " ")
    return GC.Util.SafeChatText(value, maximumBytes or 48)
end

local function ValidSpecForClass(specKey, classFile)
    return specKey == "" or (GC.SpecByKey[specKey] and GC.SpecByKey[specKey].classFile == classFile)
end

local function SplitRecord(record)
    local fields = {}
    for field in (tostring(record or "") .. ","):gmatch("(.-),") do
        fields[#fields + 1] = field
    end
    return fields
end

local function AddProfileRecord(records, profile, fallbackName)
    local name = SanitizedSyncField(profile.fullName or fallbackName, 48)
    local classFile = tostring(profile.classFile or "")
    local detectedSpecKey = tostring(profile.detectedSpecKey or "")
    local raidSpecKey = tostring(profile.raidSpecKey or "")
    local secondarySpecKey = tostring(profile.secondarySpecKey or "")
    if name == "" or not GC.Classes[classFile]
        or not ValidSpecForClass(detectedSpecKey, classFile)
        or not ValidSpecForClass(raidSpecKey, classFile)
        or not ValidSpecForClass(secondarySpecKey, classFile) then
        return false
    end
    if detectedSpecKey == "" and raidSpecKey == "" then
        return false
    end
    records[#records + 1] = table.concat({
        "P",
        name,
        classFile,
        detectedSpecKey,
        raidSpecKey,
        secondarySpecKey,
        profile.mainStatus == "ALT" and "A" or "M",
        profile.flex and "1" or "0",
        profile.confirmed and "1" or "0",
        tostring(tonumber(profile.updatedAt) or 0),
    }, ",")
    return true
end

function GC.WarcraftLogs:BuildRecruitmentSyncRecords()
    local guildData = GC.DB:GetGuild()
    local records = {}
    local logCount = 0
    local addonCount = 0
    local revision = tonumber(guildData.warcraftLogs.importedAt) or 0

    local seenLogs = {}
    for key, profile in pairs(guildData.warcraftLogs.members or {}) do
        if type(profile) == "table" and not seenLogs[profile] then
            seenLogs[profile] = true
            local name = SanitizedSyncField(profile.fullName or key, 48)
            local classFile = tostring(profile.classFile or "")
            local raidSpecKey = tostring(profile.raidSpecKey or "")
            local secondarySpecKey = tostring(profile.secondarySpecKey or "")
            if name ~= "" and GC.Classes[classFile]
                and raidSpecKey ~= "" and ValidSpecForClass(raidSpecKey, classFile)
                and ValidSpecForClass(secondarySpecKey, classFile) then
                records[#records + 1] = table.concat({
                    "L",
                    name,
                    classFile,
                    raidSpecKey,
                    secondarySpecKey,
                }, ",")
                logCount = logCount + 1
            end
        end
    end

    local profilesByName = {}
    local ownProfile = GC.Profile:Get()
    profilesByName[GC.Util.NormalizeName(GC:GetPlayerFullName())] = {
        profile = ownProfile,
        name = GC:GetPlayerFullName(),
    }
    for key, profile in pairs(guildData.remoteProfiles or {}) do
        if type(profile) == "table" then
            local name = profile.fullName or key
            local normalized = GC.Util.NormalizeName(name)
            local previous = profilesByName[normalized]
            if normalized ~= "" and (not previous
                or (tonumber(profile.updatedAt) or 0) > (tonumber(previous.profile.updatedAt) or 0)) then
                profilesByName[normalized] = { profile = profile, name = name }
            end
        end
    end
    local profileNames = {}
    for normalized in pairs(profilesByName) do
        profileNames[#profileNames + 1] = normalized
    end
    table.sort(profileNames)
    for _, normalized in ipairs(profileNames) do
        local entry = profilesByName[normalized]
        if AddProfileRecord(records, entry.profile, entry.name) then
            addonCount = addonCount + 1
            revision = math.max(revision, tonumber(entry.profile.updatedAt) or 0)
        end
    end

    table.sort(records)
    return records, {
        logCount = logCount,
        addonCount = addonCount,
        -- Logprofile erhalten hoehere Gewichtung, weil sie in einem Import
        -- typischerweise den groessten Teil der Gilde auf einmal abdecken.
        score = (logCount * 1000) + addonCount,
        revision = revision,
        importedAt = tonumber(guildData.warcraftLogs.importedAt) or 0,
        reportCount = tonumber(guildData.warcraftLogs.reportCount) or 0,
    }
end

function GC.WarcraftLogs:GetRecruitmentSyncStats()
    local _, stats = self:BuildRecruitmentSyncRecords()
    return stats
end

function GC.WarcraftLogs:BuildRecruitmentSyncMessages()
    local records, stats = self:BuildRecruitmentSyncRecords()
    if #records == 0 then
        return {}, nil, stats
    end

    local payloads = {}
    local current = ""
    for _, record in ipairs(records) do
        local candidate = current == "" and record or (current .. ";" .. record)
        if #candidate > RECRUITMENT_PAYLOAD_BYTES and current ~= "" then
            payloads[#payloads + 1] = current
            current = record
        else
            current = candidate
        end
    end
    payloads[#payloads + 1] = current
    if #payloads > RECRUITMENT_MAX_PARTS then
        return {}, nil, stats
    end

    local token = tostring(GC.Util.Now()) .. tostring(math.random(1000, 9999))
    local messages = {}
    for index, payload in ipairs(payloads) do
        messages[index] = table.concat({
            "L",
            tostring(GC.Constants.SCHEMA_VERSION),
            "D",
            token,
            tostring(index),
            tostring(#payloads),
            tostring(stats.importedAt),
            tostring(stats.reportCount),
            payload,
        }, "|")
    end
    return messages, token, stats
end

local function IsBetterRecruitmentDataset(candidateScore, candidateRevision, localStats)
    candidateScore = tonumber(candidateScore) or 0
    candidateRevision = tonumber(candidateRevision) or 0
    return candidateScore > (localStats.score or 0)
        or (candidateScore == (localStats.score or 0)
            and candidateRevision > (localStats.revision or 0))
end

function GC.WarcraftLogs:RequestRecruitmentData()
    if not GC.Sync or not IsInGuild or not IsInGuild() then
        return false
    end
    local stats = self:GetRecruitmentSyncStats()
    local token = tostring(GC.Util.Now()) .. tostring(math.random(100, 999))
    self.syncDiscoveries[token] = {
        offers = {},
        requestedAt = GC.Util.Now(),
    }
    local sent = GC.Sync:Send(table.concat({
        "L",
        tostring(GC.Constants.SCHEMA_VERSION),
        "R",
        token,
        tostring(stats.score),
        tostring(stats.revision),
    }, "|"))
    if not sent then
        self.syncDiscoveries[token] = nil
        return false
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(RECRUITMENT_DISCOVERY_WAIT, function()
            GC.WarcraftLogs:ChooseRecruitmentOffer(token)
        end)
    end
    return true
end

function GC.WarcraftLogs:ChooseRecruitmentOffer(token)
    local discovery = self.syncDiscoveries[token]
    if not discovery then
        return false
    end
    self.syncDiscoveries[token] = nil
    local best
    for _, offer in pairs(discovery.offers) do
        if not best or offer.score > best.score
            or (offer.score == best.score and offer.revision > best.revision)
            or (offer.score == best.score and offer.revision == best.revision
                and GC.Util.NormalizeName(offer.sender) < GC.Util.NormalizeName(best.sender)) then
            best = offer
        end
    end
    if not best then
        return false
    end
    return GC.Sync:Send(table.concat({
        "L",
        tostring(GC.Constants.SCHEMA_VERSION),
        "Q",
        token,
    }, "|"), "WHISPER", best.sender)
end

function GC.WarcraftLogs:AnnounceRecruitmentData()
    if not GC.Sync then
        return false
    end
    local stats = self:GetRecruitmentSyncStats()
    if stats.score <= 0 then
        return false
    end
    return GC.Sync:Send(table.concat({
        "L",
        tostring(GC.Constants.SCHEMA_VERSION),
        "U",
        tostring(stats.score),
        tostring(stats.revision),
    }, "|"))
end

function GC.WarcraftLogs:QueueRecruitmentTransfer(target)
    local messages, token = self:BuildRecruitmentSyncMessages()
    if #messages == 0 or not token or not GC.Sync then
        return false
    end
    return GC.Sync:QueueReliable(messages, target, "L", token)
end

function GC.WarcraftLogs:ReceiveRecruitmentData(fields, sender, distribution)
    local token = fields[4]
    local part = tonumber(fields[5])
    local total = tonumber(fields[6])
    local importedAt = tonumber(fields[7]) or 0
    local reportCount = tonumber(fields[8]) or 0
    local payload = fields[9] or ""
    local senderKey = GC.Util.NormalizeName(sender)
    if distribution ~= "WHISPER" or senderKey == "" or not token
        or #token > 40 or not part or not total or part < 1 or part > total
        or total > RECRUITMENT_MAX_PARTS or #payload > RECRUITMENT_PAYLOAD_BYTES then
        return false
    end

    local now = GC.Util.Now()
    local incomingKey = senderKey .. "|" .. token
    for key, completedAt in pairs(self.syncCompleted) do
        if (now - (tonumber(completedAt) or 0)) > RECRUITMENT_INCOMING_TTL then
            self.syncCompleted[key] = nil
        end
    end
    if self.syncCompleted[incomingKey] then
        GC.Sync:SendReliableAck("L", token, part, sender)
        return true
    end
    for key, incoming in pairs(self.syncIncoming) do
        if (now - (tonumber(incoming.receivedAt) or 0)) > RECRUITMENT_INCOMING_TTL then
            self.syncIncoming[key] = nil
        end
    end

    local incoming = self.syncIncoming[incomingKey]
    if incoming and (incoming.total ~= total or incoming.importedAt ~= importedAt
        or incoming.reportCount ~= reportCount) then
        self.syncIncoming[incomingKey] = nil
        return false
    end
    if not incoming then
        incoming = {
            total = total,
            importedAt = importedAt,
            reportCount = reportCount,
            parts = {},
            received = 0,
            receivedAt = now,
        }
        self.syncIncoming[incomingKey] = incoming
    end
    if incoming.parts[part] and incoming.parts[part] ~= payload then
        self.syncIncoming[incomingKey] = nil
        return false
    elseif not incoming.parts[part] then
        incoming.parts[part] = payload
        incoming.received = incoming.received + 1
    end
    incoming.receivedAt = now
    GC.Sync:SendReliableAck("L", token, part, sender)
    if incoming.received < total then
        return true
    end

    local imported = {}
    local importedCount = 0
    local addonProfiles = {}
    for chunkIndex = 1, total do
        for record in tostring(incoming.parts[chunkIndex] or ""):gmatch("[^;]+") do
            local recordFields = SplitRecord(record)
            if recordFields[1] == "L" and #recordFields == 5 then
                local name = recordFields[2]
                local classFile = recordFields[3]
                local raidSpecKey = recordFields[4]
                local secondarySpecKey = recordFields[5]
                if GC.Util.Trim(name) ~= "" and GC.Classes[classFile]
                    and raidSpecKey ~= "" and ValidSpecForClass(raidSpecKey, classFile)
                    and ValidSpecForClass(secondarySpecKey, classFile) then
                    local profile = {
                        fullName = name,
                        classFile = classFile,
                        raidSpecKey = raidSpecKey,
                        secondarySpecKey = secondarySpecKey ~= "" and secondarySpecKey or nil,
                        confirmed = false,
                        source = "WARCRAFT_LOGS",
                        updatedAt = importedAt,
                        receivedAt = now,
                    }
                    PutImportedProfile(imported, name, profile)
                    importedCount = importedCount + 1
                end
            elseif recordFields[1] == "P" and #recordFields == 10 then
                local name = recordFields[2]
                local classFile = recordFields[3]
                local detectedSpecKey = recordFields[4]
                local raidSpecKey = recordFields[5]
                local secondarySpecKey = recordFields[6]
                local updatedAt = tonumber(recordFields[10]) or 0
                if GC.Util.Trim(name) ~= "" and GC.Classes[classFile]
                    and ValidSpecForClass(detectedSpecKey, classFile)
                    and ValidSpecForClass(raidSpecKey, classFile)
                    and ValidSpecForClass(secondarySpecKey, classFile) then
                    addonProfiles[#addonProfiles + 1] = {
                        fullName = name,
                        classFile = classFile,
                        detectedSpecKey = detectedSpecKey ~= "" and detectedSpecKey or nil,
                        raidSpecKey = raidSpecKey ~= "" and raidSpecKey or nil,
                        secondarySpecKey = secondarySpecKey ~= "" and secondarySpecKey or nil,
                        mainStatus = recordFields[7] == "A" and "ALT" or "MAIN",
                        flex = recordFields[8] == "1",
                        confirmed = recordFields[9] == "1",
                        updatedAt = updatedAt,
                        receivedAt = now,
                    }
                end
            end
        end
    end

    local guildData = GC.DB:GetGuild()
    local currentLogCount = self:GetImportedCount()
    if importedCount > 0 and (importedAt > (tonumber(guildData.warcraftLogs.importedAt) or 0)
        or (importedAt == (tonumber(guildData.warcraftLogs.importedAt) or 0)
            and importedCount >= currentLogCount)
        or currentLogCount == 0) then
        guildData.warcraftLogs.members = imported
        guildData.warcraftLogs.importedAt = importedAt
        guildData.warcraftLogs.reportCount = reportCount
        -- Woher der uebernommene Stand kam, gehoert sichtbar in den Status:
        -- sonst sieht ein empfangener Datensatz wie ein eigener Import aus.
        guildData.warcraftLogs.lastSyncFrom = GC.Util.PlayerShortName(sender)
    end

    local ownKey = GC.Util.NormalizeName(GC:GetPlayerFullName())
    for _, profile in ipairs(addonProfiles) do
        local fullKey = GC.Util.NormalizeName(profile.fullName)
        local shortKey = GC.Util.NormalizeName(GC.Util.PlayerShortName(profile.fullName))
        local member = GC.Roster and GC.Roster:GetMember(profile.fullName)
        local classMatches = not member or not member.classFile or member.classFile == profile.classFile
        if fullKey ~= "" and fullKey ~= ownKey and classMatches then
            local existing = guildData.remoteProfiles[fullKey] or guildData.remoteProfiles[shortKey]
            if not existing or (tonumber(profile.updatedAt) or 0) >= (tonumber(existing.updatedAt) or 0) then
                guildData.remoteProfiles[fullKey] = profile
                guildData.remoteProfiles[shortKey] = profile
            end
        end
    end

    self.syncIncoming[incomingKey] = nil
    self.syncCompleted[incomingKey] = now
    GC:FireCallback("WCL_UPDATED")
    GC:FireCallback("ROSTER_UPDATED")
    return true
end

function GC.WarcraftLogs:ReceiveSync(fields, sender, distribution)
    local operation = fields[3]
    if operation == "D" then
        return self:ReceiveRecruitmentData(fields, sender, distribution)
    elseif operation == "R" then
        local token = fields[4]
        local requesterScore = tonumber(fields[5]) or 0
        local requesterRevision = tonumber(fields[6]) or 0
        local stats = self:GetRecruitmentSyncStats()
        if distribution ~= "GUILD" or not token or #token > 40
            or not IsBetterRecruitmentDataset(stats.score, stats.revision, {
                score = requesterScore,
                revision = requesterRevision,
            }) then
            return false
        end
        local function Offer()
            GC.Sync:Send(table.concat({
                "L",
                tostring(GC.Constants.SCHEMA_VERSION),
                "N",
                token,
                tostring(stats.score),
                tostring(stats.revision),
            }, "|"), "WHISPER", sender)
        end
        if C_Timer and C_Timer.After then
            C_Timer.After(0.05 + (math.random() * 0.45), Offer)
        else
            Offer()
        end
        return true
    elseif operation == "N" then
        local discovery = self.syncDiscoveries[fields[4]]
        local score = tonumber(fields[5])
        local revision = tonumber(fields[6])
        if distribution ~= "WHISPER" or not discovery or not score or not revision then
            return false
        end
        discovery.offers[GC.Util.NormalizeName(sender)] = {
            sender = sender,
            score = score,
            revision = revision,
        }
        return true
    elseif operation == "Q" then
        if distribution ~= "WHISPER" then
            return false
        end
        local senderKey = GC.Util.NormalizeName(sender)
        local now = GC.Util.Now()
        if senderKey == "" or (self.syncRequestReplies[senderKey]
            and (now - self.syncRequestReplies[senderKey]) < RECRUITMENT_REPLY_INTERVAL) then
            return false
        end
        self.syncRequestReplies[senderKey] = now
        return self:QueueRecruitmentTransfer(sender)
    elseif operation == "U" then
        local score = tonumber(fields[4])
        local revision = tonumber(fields[5])
        local stats = self:GetRecruitmentSyncStats()
        if distribution ~= "GUILD" or not score or not revision
            or not IsBetterRecruitmentDataset(score, revision, stats) then
            return false
        end
        local requestToken = tostring(GC.Util.Now()) .. tostring(math.random(100, 999))
        return GC.Sync:Send(table.concat({
            "L",
            tostring(GC.Constants.SCHEMA_VERSION),
            "Q",
            requestToken,
        }, "|"), "WHISPER", sender)
    end
    return false
end
