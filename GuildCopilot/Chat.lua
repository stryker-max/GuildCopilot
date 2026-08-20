local _, GC = ...

GC.Chat = {
    sessionActive = false,
    sessionStartedAt = 0,
    heardSenders = {},
}

-- Wie lange nach dem Posten der Werbung ein eingehender Fluesterer noch als
-- Antwort darauf gilt. Ohne diese Grenze hatte "Fluestern nur waehrend einer
-- Suche" gar kein Ende: sessionActive wurde beim ersten erfolgreichen Post
-- gesetzt und bis zum naechsten Neuladen der Oberflaeche nie zurueckgenommen.
-- Die Einstellung war damit ab dem ersten Post faktisch wirkungslos, und
-- sessionStartedAt wurde zwar gefuellt, aber nie gelesen.
local SESSION_DURATION = 60 * 60

-- Laeuft gerade eine Suche? Der Ablauf wird beim Nachfragen festgestellt; ein
-- eigener Timer waere fuer eine reine Ja/Nein-Frage Verschwendung.
function GC.Chat:IsSessionActive()
    if not self.sessionActive then
        return false
    end
    if (GC.Util.Now() - (self.sessionStartedAt or 0)) > SESSION_DURATION then
        self.sessionActive = false
        return false
    end
    return true
end

-- Der Ton fuer die eigene Profilbestaetigung. Er ist bewusst vom Bewerberton
-- getrennt: Der eine meldet einen fremden Interessenten, der andere bestaetigt
-- die eigene Eingabe.
function GC.Chat:PlayProfileSound()
    local settings = GC.DB:GetSettings()
    return self:PlaySuccessSound(settings.profileSoundKey or GC.DefaultProfileSoundKey)
end

function GC.Chat:PlaySuccessSound(overrideKey)
    local settings = GC.DB:GetSettings()
    local soundKey = overrideKey or settings.successSoundKey or "READY_CHECK"
    local selectedOption
    for _, option in ipairs(GC.SuccessSoundOptions or {}) do
        if option.key == soundKey then
            selectedOption = option
            break
        end
    end
    selectedOption = selectedOption or (GC.SuccessSoundOptions and GC.SuccessSoundOptions[1])
    local soundID = selectedOption
        and ((SOUNDKIT and SOUNDKIT[selectedOption.key]) or selectedOption.soundID)
        or ((SOUNDKIT and SOUNDKIT.READY_CHECK) or 8960)
    if PlaySound and soundID then
        PlaySound(soundID, "Master")
        return true
    end
    return false
end

-- === Trigger- und Ausschlusswoerter =====================================
--
-- Die Vorgaben stehen in Constants.lua, gespeichert wird nur die eigene
-- Fassung. Ein geleertes Triggerfeld faellt deshalb auf die Vorgabe zurueck,
-- statt die Erkennung stillschweigend abzuschalten - dafuer sind die Schalter
-- "captureOnlyDuringSearch" und "watchRecruitmentTriggers" da. Ein leeres
-- Ausschlussfeld heisst schlicht "kein Ausschluss".

local FILTER_LISTS = {
    chatTriggers = { default = "DefaultChatTriggers" },
    chatExclusions = {},
    whisperTriggers = { default = "DefaultWhisperTriggers" },
    whisperExclusions = {},
}

function GC.Chat:GetRecruitmentFilters()
    local settings = GC.DB:GetSettings()
    local filters = settings.recruitmentFilters
    if type(filters) ~= "table" then
        filters = {}
        settings.recruitmentFilters = filters
    end
    for key in pairs(FILTER_LISTS) do
        if type(filters[key]) ~= "table" then
            filters[key] = {}
        end
    end
    return filters
end

-- Ein Wort je Zeile. Verglichen wird spaeter ueber :lower(), deshalb wird hier
-- schon kleingeschrieben gespeichert; getrimmt, ohne Leerzeilen und ohne
-- Doppelte, damit die Liste beim naechsten Oeffnen aufgeraeumt aussieht.
local function CleanWordList(text)
    local words = {}
    local seen = {}
    for line in (tostring(text or "") .. "\n"):gmatch("([^\r\n]*)[\r\n]") do
        local word = GC.Util.Trim(line):lower()
        if word ~= "" and not seen[word] then
            seen[word] = true
            words[#words + 1] = word
            if #words >= GC.MaxRecruitmentFilterWords then
                break
            end
        end
    end
    return words
end

GC.Chat.CleanRecruitmentWordList = function(_, text)
    return CleanWordList(text)
end

-- Was tatsaechlich verglichen wird: immer zuerst die eigene Liste. Ist sie
-- leer, greift die mitgelieferte Vorgabe NUR, solange die freie Erkennung an
-- ist - sie ist ab 0.9.135 der Hauptschalter fuer die ganze eingebaute Schicht.
-- Steht sie aus, zaehlt strikt, was im Feld steht: ein leeres Feld erfasst
-- nichts. Ausschlusslisten haben keine Vorgabe und bleiben davon unberuehrt.
function GC.Chat:GetRecruitmentWords(key)
    local definition = FILTER_LISTS[key]
    if not definition then
        return {}
    end
    local stored = self:GetRecruitmentFilters()[key]
    if #stored > 0 then
        return stored
    end
    if definition.default and GC.DB:GetSettings().smartRecruitmentDetection then
        return GC[definition.default]
    end
    return {}
end

-- Was im Eingabefeld steht: nur die eigene Fassung. Ein leeres Feld zeigt
-- damit an, dass die Vorgabe gilt, statt sie als eigene Eingabe auszugeben.
function GC.Chat:GetRecruitmentWordText(key)
    if not FILTER_LISTS[key] then
        return ""
    end
    return table.concat(self:GetRecruitmentFilters()[key], "\n")
end

-- Die mitgelieferte Vorgabe als Text, damit sie sich in den Einstellungen zum
-- Bearbeiten eintragen laesst. Ausschlusslisten haben keine Vorgabe und
-- liefern deshalb einen leeren Text.
function GC.Chat:GetRecruitmentDefaultText(key)
    local definition = FILTER_LISTS[key]
    if not definition or not definition.default then
        return ""
    end
    return table.concat(GC[definition.default] or {}, "\n")
end

function GC.Chat:SetRecruitmentWordText(key, text)
    if not FILTER_LISTS[key] then
        return false
    end
    self:GetRecruitmentFilters()[key] = CleanWordList(text)
    GC:FireCallback("SETTINGS_UPDATED")
    return true
end

-- Vorgabe wiederherstellen heisst: die eigene Liste leeren. Dann greift die
-- Vorgabe wieder (sofern die freie Erkennung an ist), und es bleibt keine
-- Kopie stehen, die bei einer spaeteren Aenderung der Vorgabe veraltet waere.
function GC.Chat:RestoreRecruitmentDefaults()
    local filters = self:GetRecruitmentFilters()
    for key in pairs(FILTER_LISTS) do
        filters[key] = {}
    end
    GC:FireCallback("SETTINGS_UPDATED")
    return true
end

local function MatchesAnyWord(normalizedMessage, words)
    for _, word in ipairs(words) do
        if normalizedMessage:find(word, 1, true) then
            return true
        end
    end
    return false
end

local function NormalizeChannelName(name)
    name = tostring(name or ""):lower()
    name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    name = name:gsub("[%s%-%._]", "")
    name = name:gsub("%d+", "")
    return name
end

-- Der eigene Realm aendert sich innerhalb einer Sitzung nicht, wurde aber bis
-- 0.9.96 bei JEDEM Namensvergleich neu ueber ":match" aus dem eigenen Namen
-- geschnitten - und verglichen wird bei jeder eingehenden Nachricht gegen
-- jeden Postfacheintrag. Gemerkt wird nur ein belastbarer Realm: Direkt nach
-- dem Laden gibt der Client noch keinen heraus, und ein gemerktes Nichts waere
-- fuer den Rest der Sitzung falsch.
local ownRealm
local function OwnRealm()
    if ownRealm then
        return ownRealm
    end
    local realm = tostring(GC:GetPlayerFullName() or ""):match("%-(.+)$")
    if realm and realm ~= "" then
        ownRealm = realm
    end
    return ownRealm
end

-- Ein Name ohne Realm meint immer den eigenen. Erst wenn beide Namen auf
-- dieselbe Schreibweise gebracht sind, laesst sich sagen, ob zwei Eintraege
-- derselbe Spieler sind: "Thrall" und "Thrall-Aegwynn" sind es auf Aegwynn,
-- "Thrall" und "Thrall-Frostwolf" nicht. Vorher wurden beide Faelle gleich
-- behandelt und ein fremder Spieler mit dem eigenen zusammengelegt.
local function CanonicalLeadName(name)
    local trimmed = GC.Util.Trim(tostring(name or ""))
    if trimmed == "" then
        return ""
    end
    if trimmed:find("-", 1, true) then
        return GC.Util.NormalizeName(trimmed)
    end
    local realm = OwnRealm()
    if realm then
        return GC.Util.NormalizeName(trimmed .. "-" .. realm)
    end
    -- Ohne bekannten eigenen Realm bleibt nur der nackte Name. Dann wird wie
    -- bisher ueber den Kurznamen verglichen.
    return GC.Util.NormalizeName(trimmed)
end

GC.Chat.CanonicalLeadName = function(_, name)
    return CanonicalLeadName(name)
end

local function SameLead(leftName, leftGUID, rightName, rightGUID)
    if leftGUID and leftGUID ~= "" and rightGUID and rightGUID ~= "" then
        return leftGUID == rightGUID
    end
    return CanonicalLeadName(leftName) == CanonicalLeadName(rightName)
end

-- === Postfachfilter ========================================================
--
-- Manche schreiben immer wieder, ohne dass daraus je etwas wird. Wer hier
-- steht, erzeugt keinen neuen Eintrag mehr - entweder dauerhaft oder bis zu
-- einem Datum. Abgelaufene Eintraege raeumt der Filter selbst weg, damit die
-- Liste nicht endlos waechst.

function GC.Chat:GetInboxFilters()
    local guildData = GC.DB:GetGuild()
    guildData.inboxFilters = guildData.inboxFilters or {}
    return guildData.inboxFilters
end

function GC.Chat:PruneInboxFilters()
    local filters = self:GetInboxFilters()
    local today = GC.Util.TodayISO()
    for key, entry in pairs(filters) do
        local untilDate = entry and entry.until_ or ""
        if untilDate ~= "" and untilDate < today then
            filters[key] = nil
        end
    end
end

function GC.Chat:IsInboxFiltered(name)
    if GC.Util.Trim(name) == "" then
        return false
    end
    self:PruneInboxFilters()
    local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    return self:GetInboxFilters()[key] ~= nil
end

-- days = nil oder 0 bedeutet dauerhaft.
function GC.Chat:SetInboxFilter(name, days)
    name = GC.Util.Trim(name)
    if name == "" then
        return false, "Kein Spieler ausgewählt."
    end

    local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    if key == "" then
        return false, "Kein Spieler ausgewählt."
    end

    days = tonumber(days) or 0
    local untilDate = days > 0 and GC.Util.AddDaysISO(days) or ""
    self:GetInboxFilters()[key] = {
        name = GC.Util.PlayerShortName(name),
        until_ = untilDate,
        at = GC.Util.Now(),
    }

    -- Den vorhandenen Eintrag gleich mitnehmen, sonst bleibt er sichtbar
    -- stehen, obwohl kuenftig nichts mehr nachkommt.
    local inbox = GC.DB:GetGuild().inbox
    for index = #inbox, 1, -1 do
        if GC.Util.NormalizeName(GC.Util.PlayerShortName(inbox[index].name)) == key then
            table.remove(inbox, index)
        end
    end

    GC:FireCallback("INBOX_UPDATED")
    if untilDate ~= "" then
        return true, GC.Util.PlayerShortName(name) .. " ist bis " .. untilDate .. " ausgeblendet."
    end
    return true, GC.Util.PlayerShortName(name) .. " wird dauerhaft ignoriert."
end

function GC.Chat:ClearInboxFilter(key)
    local filters = self:GetInboxFilters()
    if not filters[key] then
        return false
    end
    filters[key] = nil
    GC:FireCallback("INBOX_UPDATED")
    return true
end

function GC.Chat:GetInboxFilterList()
    self:PruneInboxFilters()
    local list = {}
    for key, entry in pairs(self:GetInboxFilters()) do
        list[#list + 1] = {
            key = key,
            name = entry.name or key,
            until_ = entry.until_ or "",
            at = entry.at or 0,
        }
    end
    table.sort(list, function(left, right)
        return tostring(left.name):lower() < tostring(right.name):lower()
    end)
    return list
end

-- === Gelöschtes bleibt gelöscht, bis eine neue Nachricht kommt ============
--
-- Das Postfach ist gildenweit: Löschst du einen Interessenten, hält ein anderer
-- Gildenmitglied seine Kopie womöglich noch und schickt sie beim nächsten
-- Abgleich zurück - der Eintrag wäre sofort wieder da. Ein Löschen legt deshalb
-- einen rein LOKALEN Merker an. Solange er steht, holt der SYNC diesen Spieler
-- nicht wieder herein - egal wie oft ein Kollege seine alte Kopie schickt.
--
-- Aufgehoben wird der Merker durch genau EIN Ereignis: Der Spieler meldet sich
-- SELBST wieder (CaptureLead - eine direkte Flüster- oder Kanalnachricht, die
-- dieser Client selbst empfängt). Das ist ein echter neuer Kontakt; dann darf
-- er wieder ins Postfach, und der Merker fällt. Eine bloße Sync-Kopie eines
-- anderen zählt ausdrücklich NICHT als neue Nachricht - sonst wäre der Merker
-- wertlos.
--
-- Der Merker geht nie ins Netz und steht nicht in der Ignorierliste - er ist
-- kein "dauerhaft ignorieren", sondern ein "nicht per Sync zurückspülen". Damit
-- die Liste nicht unbegrenzt wächst, ist ihre Zahl gedeckelt; beim Überlauf
-- fallen die ältesten Merker weg (die betreffen längst weggeräumte Bewerber).
local MAX_INBOX_TOMBSTONES = 1000

function GC.Chat:GetInboxTombstones()
    local guildData = GC.DB:GetGuild()
    guildData.inboxTombstones = guildData.inboxTombstones or {}
    return guildData.inboxTombstones
end

-- Beim Überlauf die ältesten Merker fallen lassen. Gemessen an ihrem
-- Zeitstempel; wer am längsten gelöscht ist, wird am ehesten wieder freigegeben.
function GC.Chat:PruneInboxTombstones()
    local tombstones = self:GetInboxTombstones()
    local count = 0
    for _ in pairs(tombstones) do
        count = count + 1
    end
    if count <= MAX_INBOX_TOMBSTONES then
        return
    end
    local ordered = {}
    for key, entry in pairs(tombstones) do
        ordered[#ordered + 1] = { key = key, at = tonumber(entry and entry.at) or 0 }
    end
    table.sort(ordered, function(left, right)
        return left.at < right.at
    end)
    for index = 1, count - MAX_INBOX_TOMBSTONES do
        tombstones[ordered[index].key] = nil
    end
end

function GC.Chat:NoteInboxTombstone(name)
    local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    if key == "" then
        return
    end
    self:GetInboxTombstones()[key] = { at = GC.Util.Now() }
    self:PruneInboxTombstones()
end

-- Der Spieler ist selbst wieder aufgetaucht: Merker weg, er darf wieder ins
-- Postfach und wird auch nicht mehr vom Sync ferngehalten.
function GC.Chat:ClearInboxTombstone(name)
    local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    if key == "" then
        return
    end
    self:GetInboxTombstones()[key] = nil
end

function GC.Chat:IsInboxTombstoned(name)
    if GC.Util.Trim(name) == "" then
        return false
    end
    local key = GC.Util.NormalizeName(GC.Util.PlayerShortName(name))
    return self:GetInboxTombstones()[key] ~= nil
end

function GC.Chat:MergeDuplicateLeads()
    local inbox = GC.DB:GetGuild().inbox
    local index = 1
    while index <= #inbox do
        local lead = inbox[index]
        if type(lead) ~= "table" then
            table.remove(inbox, index)
        else
            if type(lead.messages) ~= "table" then
                lead.messages = {}
            end
            for messageIndex = #lead.messages, 1, -1 do
                if type(lead.messages[messageIndex]) ~= "table" then
                    table.remove(lead.messages, messageIndex)
                end
            end
            local compareIndex = index + 1
            while compareIndex <= #inbox do
                local duplicate = inbox[compareIndex]
                if type(duplicate) ~= "table" then
                    table.remove(inbox, compareIndex)
                elseif SameLead(lead.name, lead.guid, duplicate.name, duplicate.guid) then
                    if type(duplicate.messages) ~= "table" then
                        duplicate.messages = {}
                    end
                    for _, message in ipairs(duplicate.messages or {}) do
                        if type(message) == "table" then
                            lead.messages[#lead.messages + 1] = message
                        end
                    end
                    table.sort(lead.messages, function(left, right)
                        return (tonumber(left.receivedAt) or 0) < (tonumber(right.receivedAt) or 0)
                    end)
                    while #lead.messages > 20 do
                        table.remove(lead.messages, 1)
                    end
                    if not tostring(lead.name or ""):find("-", 1, true)
                        and tostring(duplicate.name or ""):find("-", 1, true) then
                        lead.name = duplicate.name
                    end
                    lead.guid = lead.guid or duplicate.guid
                    lead.classFile = lead.classFile or duplicate.classFile
                    lead.level = lead.level or duplicate.level
                    local firstSeenAt = tonumber(lead.firstSeenAt)
                    local duplicateFirstSeenAt = tonumber(duplicate.firstSeenAt)
                    lead.firstSeenAt = firstSeenAt and duplicateFirstSeenAt
                        and math.min(firstSeenAt, duplicateFirstSeenAt)
                        or firstSeenAt
                        or duplicateFirstSeenAt
                        or tonumber(lead.lastSeenAt)
                        or tonumber(duplicate.lastSeenAt)
                        or GC.Util.Now()
                    lead.lastSeenAt = math.max(
                        tonumber(lead.lastSeenAt) or 0,
                        tonumber(duplicate.lastSeenAt) or 0)
                    lead.unread = lead.unread or duplicate.unread
                    table.remove(inbox, compareIndex)
                else
                    compareIndex = compareIndex + 1
                end
            end
            if not tonumber(lead.firstSeenAt) then
                lead.firstSeenAt = tonumber(lead.lastSeenAt) or GC.Util.Now()
            end
            index = index + 1
        end
    end
end

function GC.Chat:FindChannel(kind)
    local definition = GC.ChannelKinds[kind]
    if not definition or not GetChannelList then
        return nil
    end

    local channels = { GetChannelList() }
    for index = 1, #channels, 3 do
        local channelID = channels[index]
        local channelName = channels[index + 1]
        local disabled = channels[index + 2]
        if channelID and channelID > 0 and channelName and not disabled then
            local normalizedName = NormalizeChannelName(channelName)
            for _, alias in ipairs(definition.aliases) do
                local normalizedAlias = NormalizeChannelName(alias)
                if normalizedName == normalizedAlias or normalizedName:find(normalizedAlias, 1, true) then
                    return channelID, channelName
                end
            end
        end
    end
    return nil
end

function GC.Chat:GetRemainingCooldown(kind)
    local lastPost = GC.DB:GetGuild().lastPosts[kind] or 0
    local settings = GC.DB:GetSettings()
    local cooldown = tonumber(settings.postCooldown) or GC.Constants.DEFAULT_POST_COOLDOWN
    if kind == "LFG" then
        cooldown = math.max(cooldown, tonumber(settings.lfgCooldown) or GC.Constants.DEFAULT_LFG_COOLDOWN)
    end
    return math.max(0, (lastPost + cooldown) - GC.Util.Now())
end

function GC.Chat:SendChat(text, chatType, language, channelID, target)
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        C_ChatInfo.SendChatMessage(text, chatType, language, channelID or target)
        return true
    elseif SendChatMessage then
        SendChatMessage(text, chatType, language, channelID or target)
        return true
    end
    return false
end

function GC.Chat:StartSearch(text)
    text = GC.Util.SafeChatText(text)
    if text == "" then
        return false, "Bitte zuerst einen Werbetext eingeben."
    end

    local settings = GC.DB:GetSettings()
    local guildData = GC.DB:GetGuild()
    if guildData.recruitment.confirmedText ~= text then
        return false, "Bitte den aktuellen Werbetext zuerst bestätigen."
    end
    local posted = {}
    local skipped = {}

    for _, kind in ipairs({ "RECRUITMENT", "LFG", "TRADE", "GENERAL" }) do
        if settings.channels[kind] then
            if self:GetRemainingCooldown(kind) > 0 then
                skipped[#skipped + 1] = GC.ChannelKinds[kind].label .. " (Cooldown)"
            else
                local channelID = self:FindChannel(kind)
                if channelID then
                    if self:SendChat(text, "CHANNEL", nil, channelID) then
                        guildData.lastPosts[kind] = GC.Util.Now()
                        posted[#posted + 1] = GC.ChannelKinds[kind].label
                    end
                else
                    skipped[#skipped + 1] = GC.ChannelKinds[kind].label .. " (nicht beigetreten)"
                end
            end
        end
    end

    if #posted > 0 then
        self.sessionActive = true
        self.sessionStartedAt = GC.Util.Now()
        self.heardSenders = {}
        table.insert(guildData.postHistory, 1, {
            postedAt = GC.Util.Now(),
            text = text,
            channels = table.concat(posted, ", "),
        })
        while #guildData.postHistory > 50 do
            table.remove(guildData.postHistory)
        end
    end

    GC:FireCallback("CHAT_STATUS", posted, skipped)
    if #posted == 0 then
        return false, #skipped > 0 and table.concat(skipped, ", ") or "Keine Kanäle ausgewählt."
    end
    return true, "Gepostet in: " .. table.concat(posted, ", ")
end

-- === Automatische Wiederholung =============================================
--
-- WoW erlaubt Kanalnachrichten aus Addon-Code nur im unmittelbaren Kontext
-- einer echten Eingabe; ein Timer darf nie selbst posten. Der Umweg, den auch
-- MessageQueue und AutoFlood gehen: Ist die Automatik bereit, lauscht ein
-- unsichtbarer Rahmen auf den naechsten Tastendruck und postet in dessen
-- Kontext. Bewusst nur Tastatur, keine Maus - ein mausempfindlicher
-- Vollbildrahmen wuerde genau den Klick schlucken, der das Posten ausloest,
-- die dokumentierte Schwaeche von MessageQueue. Die Taste wird durchgereicht
-- und nicht gelesen; der Rahmen erfaehrt nur, DASS gedrueckt wurde.
--
-- SetPropagateKeyboardInput ist fuer Addons im Kampf gesperrt und wird
-- deshalb genau einmal beim Laden gesetzt, nie wieder. Fehlt eine der beiden
-- Tastaturmethoden, bleibt der Rahmen dauerhaft aus: Ein Lauscher, der
-- Tasten nicht durchreichen kann, wuerde die Steuerung schlucken.
local autoPostFrame = CreateFrame("Frame", "GuildCopilotAutoPostFrame")
autoPostFrame:SetFrameStrata("TOOLTIP")
autoPostFrame:SetPoint("TOPLEFT")
autoPostFrame:SetSize(1, 1)
autoPostFrame:Hide()
local autoPostSupported = autoPostFrame.EnableKeyboard ~= nil
    and autoPostFrame.SetPropagateKeyboardInput ~= nil
if autoPostSupported then
    autoPostFrame:EnableKeyboard(true)
    autoPostFrame:SetPropagateKeyboardInput(true)
    autoPostFrame:SetScript("OnKeyDown", function()
        GC.Chat:RunAutoPost()
    end)
end

function GC.Chat:IsAutoPostSupported()
    return autoPostSupported
end

function GC.Chat:IsAutoPostArmed()
    return autoPostFrame:IsShown() == true
end

-- Scharf heisst: Der naechste Tastendruck postet. Entschaerft wird beim
-- Treffer sofort; neu geschaerft wird ueber den Auffrisch-Takt des
-- Werbebalkens, sobald Text, Kanal und Cooldown wieder bereit sind. Der
-- Zustand lebt nur im Rahmen selbst und ueberlebt kein /reload - nach dem
-- Laden ist die Automatik immer erst einmal entschaerft.
function GC.Chat:SetAutoPostArmed(armed)
    if not autoPostSupported then
        return
    end
    autoPostFrame:SetShown(armed == true)
end

-- Laeuft im Kontext des Tastendrucks - nur hier darf in Kanaele gesendet
-- werden. StartSearch prueft alles erneut (bestaetigter Text, Cooldowns,
-- beigetretene Kanaele) und setzt lastPosts erst beim echten Versand; die
-- Automatik kann dadurch nie einen veralteten Zustand posten, und der
-- Cooldown zaehlt ab dem Moment, in dem die Nachricht wirklich rausging.
function GC.Chat:RunAutoPost()
    if not self:IsAutoPostArmed() then
        return
    end
    self:SetAutoPostArmed(false)
    if GC.DB:GetSettings().postBar.autoRepeat ~= true then
        return
    end
    local recruitment = GC.DB:GetGuild().recruitment
    local success, message = self:StartSearch(recruitment.confirmedText or "")
    self.lastAutoPost = {
        at = GC.Util.Now(),
        success = success == true,
        message = tostring(message or ""),
    }
end

-- Die Klasse steckt in der bereits erfassten GUID des Absenders; es braucht
-- also keine zusaetzliche Abfrage. Direkt nach dem Login ist der Namens-Cache
-- des Clients aber noch kalt, deshalb ist der Aufruf idempotent und wird beim
-- Anzeigen des Postfachs so lange wiederholt, bis er etwas liefert. Das
-- ergaenzt auch Interessenten, die vor dieser Version gespeichert wurden.
-- === Was der Bewerber selbst hinschreibt ==================================
--
-- "ENH sucht Anschluss an Gilde", "70er Schurke sucht nette Gilde". Klasse und
-- Stufe stehen fast immer im Text - und das ist die einzige Quelle, die ohne
-- Serveranfrage auskommt: Die GUID liefert die Klasse nur bei bekanntem Namen
-- und die Stufe nie.
--
-- Gelesen wird nur, was dasteht. Nichts wird geraten, und eine gefundene
-- Angabe ueberschreibt nie eine sicherere (die Klasse aus der GUID).
function GC.Chat:ReadClassFromText(text)
    local lowered = tostring(text or ""):lower()
    if lowered == "" then
        return nil
    end
    local best, bestAt
    for classFile, aliases in pairs(GC.LeadClassAliases) do
        for _, alias in ipairs(aliases) do
            -- Ganze Woerter: "ele" darf nicht in "elegant" treffen.
            local at = lowered:find("%f[%w]" .. alias .. "%f[%W]")
            if at and (not bestAt or at < bestAt) then
                best, bestAt = classFile, at
            end
        end
    end
    return best
end

function GC.Chat:ReadLevelFromText(text)
    local lowered = tostring(text or ""):lower()
    if lowered == "" then
        return nil
    end
    for _, pattern in ipairs(GC.LeadLevelPatterns) do
        local found = tonumber(lowered:match(pattern))
        if found and found >= 1 and found <= GC.LeadLevelMax then
            return found
        end
    end
    -- Ohne Marker nur im plausiblen Bereich. Eine nackte "2" ist in einer
    -- Kanalnachricht so gut wie nie eine Stufe.
    for number in lowered:gmatch("%f[%w](%d%d?)%f[%W]") do
        local found = tonumber(number)
        if found and found >= GC.LeadLevelBareMin and found <= GC.LeadLevelMax then
            return found
        end
    end
    return nil
end

-- Traegt nach, was am Eintrag noch fehlt. Sicherere Quellen gewinnen: eine
-- ueber die GUID aufgeloeste Klasse wird nie durch eine geratene ersetzt.
function GC.Chat:ReadLeadDetails(lead, text)
    if type(lead) ~= "table" then
        return
    end
    if GC.Util.Trim(lead.classFile) == "" then
        lead.classFile = self:ReadClassFromText(text)
    end
    if not tonumber(lead.level) then
        lead.level = self:ReadLevelFromText(text)
    end
end

function GC.Chat:ResolveLeadClass(lead)
    if type(lead) ~= "table" or GC.Util.Trim(lead.classFile) ~= "" then
        return lead and lead.classFile or nil
    end
    if GC.Util.Trim(lead.guid) == "" or type(GetPlayerInfoByGUID) ~= "function" then
        return nil
    end
    local ok, _, classFile = pcall(GetPlayerInfoByGUID, lead.guid)
    if ok and classFile and GC.Classes[classFile] then
        lead.classFile = classFile
        return classFile
    end
    return nil
end

function GC.Chat:CaptureLead(message, sender, guid, source)
    local settings = GC.DB:GetSettings()
    if GC.Util.Trim(sender) == ""
        or GC.Util.NormalizeName(sender) == GC.Util.NormalizeName(GC:GetPlayerFullName()) then
        return
    end
    if GC.Roster:IsGuildMember(sender) then
        return
    end
    if self:IsInboxFiltered(sender) then
        return
    end
    -- Der Spieler meldet sich selbst wieder: Ein früheres Löschen hält ihn ab
    -- jetzt nicht mehr vom Sync fern. Das ist der EINE Weg, einen Merker
    -- aufzuheben - eine direkte neue Nachricht, nicht eine fremde Sync-Kopie.
    self:ClearInboxTombstone(sender)

    -- Bis 0.9.96 lief hier zuerst MergeDuplicateLeads - ein Paarvergleich ueber
    -- das ganze Postfach, also O(n^2), und das bei JEDER eingehenden Nachricht:
    -- 1,11 ms bei 100 Eintraegen. Gebraucht wird davon nichts. Es kommt genau
    -- ein Eintrag hinzu, und der kann nur mit BESTEHENDEN zusammenfallen -
    -- genau das leistet die Suche unten in einem Durchlauf. Der vollstaendige
    -- Abgleich ist eine Reparatur fuer Altbestaende und steht dort, wo er
    -- hingehoert: beim Login.
    local inbox = GC.DB:GetGuild().inbox
    local normalizedSender = GC.Util.NormalizeName(GC.Util.PlayerShortName(sender))
    local lead
    local searchIndex = 1
    while searchIndex <= #inbox do
        local existing = inbox[searchIndex]
        if type(existing) ~= "table" then
            -- Kaputte Eintraege raeumte bisher der Abgleich nebenbei weg; ohne
            -- ihn wuerde SameLead hier ueber einen Nichttabelleneintrag
            -- stolpern.
            table.remove(inbox, searchIndex)
        elseif SameLead(existing.name, existing.guid, sender, guid) then
            lead = existing
            break
        else
            searchIndex = searchIndex + 1
        end
    end

    if not lead then
        lead = {
            name = sender,
            guid = guid,
            firstSeenAt = GC.Util.Now(),
            messages = {},
            source = source,
        }
        table.insert(inbox, 1, lead)
    else
        -- Was der Abgleich sonst nebenbei erledigte, jetzt nur fuer den einen
        -- betroffenen Eintrag: Nachrichtenliste sicherstellen, beschaedigte
        -- Nachrichten entfernen, fehlenden Ersterfassungszeitpunkt nachtragen.
        if type(lead.messages) ~= "table" then
            lead.messages = {}
        end
        for messageIndex = #lead.messages, 1, -1 do
            if type(lead.messages[messageIndex]) ~= "table" then
                table.remove(lead.messages, messageIndex)
            end
        end
        if not tonumber(lead.firstSeenAt) then
            lead.firstSeenAt = tonumber(lead.lastSeenAt) or GC.Util.Now()
        end
    end
    lead.lastSeenAt = GC.Util.Now()
    lead.unread = true
    lead.source = source or lead.source
    lead.guid = lead.guid or guid
    self:ResolveLeadClass(lead)
    -- Was die GUID nicht hergibt, steht oft im Text selbst.
    self:ReadLeadDetails(lead, message)
    table.insert(lead.messages, {
        receivedAt = GC.Util.Now(),
        text = message,
        source = source,
    })
    while #lead.messages > 20 do
        table.remove(lead.messages, 1)
    end

    -- Der eigene Schalter entscheidet, ob ueberhaupt ein Ton kommt, der
    -- Gildenrang, ob er einen betrifft. Erfasst wird in jedem Fall - wer
    -- spaeter ins Postfach sieht, soll nichts verpasst haben.
    if settings.successSound
        and GC.Roster:HearsInboxSound()
        and not self.heardSenders[normalizedSender] then
        self.heardSenders[normalizedSender] = true
        self:PlaySuccessSound()
    end
    -- Und ab damit in die Gilde. Nur beim ERSTEN Mal: Die Ursprungsnachricht
    -- ist das, was uebertragen wird, und die aendert sich nie. Ein Bewerber,
    -- der seinen Werbetext zum zehnten Mal in den Kanal schreibt, kostet
    -- deshalb kein zehntes Paket.
    if #lead.messages == 1 then
        self:SendLead(lead)
    end
    GC:FireCallback("INBOX_UPDATED", lead)
end

function GC.Chat:CaptureWhisper(message, sender, guid)
    -- Werkstatt-Befehle zuerst: "!rezept <suche>" beantwortet der Katalog
    -- (sofern eingeschaltet). Ein behandelter Befehl gehoert nie ins
    -- Bewerber-Postfach - sonst laege jeder Rezeptfrager als Interessent da.
    if GC.Workshop and GC.Workshop.AnswerRecipeWhisper
        and GC.Workshop:AnswerRecipeWhisper(message, sender) then
        return
    end
    local settings = GC.DB:GetSettings()
    if settings.captureOnlyDuringSearch and not self:IsSessionActive() then
        return
    end
    local knownLead = false
    for _, lead in ipairs(GC.DB:GetGuild().inbox) do
        if SameLead(lead.name, lead.guid, sender, guid) then
            knownLead = true
            break
        end
    end
    local normalizedMessage = tostring(message or ""):lower()
    -- Ausschluss schlaegt Trigger. Er verhindert aber nur, dass ein Wort
    -- jemanden neu ins Postfach holt: Wer schon drinsteht, dessen Unterhaltung
    -- laeuft weiter, sonst fehlte ausgerechnet die Nachricht, die ein
    -- Ausschlusswort zufaellig enthaelt.
    local recruitmentSignal = not MatchesAnyWord(normalizedMessage, self:GetRecruitmentWords("whisperExclusions"))
        and MatchesAnyWord(normalizedMessage, self:GetRecruitmentWords("whisperTriggers"))
    if not knownLead and not recruitmentSignal then
        return
    end
    self:CaptureLead(message, sender, guid, "WHISPER")
end

-- Kurze Buchstabenkuerzel ("lf", "lfg") nur an einer Wortgrenze werten. Als
-- reiner Teilstring steckte "lf " sonst im Ende ganz gewoehnlicher Woerter -
-- "half ", "self ", "wolf ", "elf ", "golf ", "myself " - und machte, sobald
-- irgendwo spaeter "gilde"/"guild" stand, aus einer harmlosen Zeile einen
-- vermeintlichen Bewerber. Laengere Suchwoerter bleiben bewusst Teilstringsuche,
-- damit "sucht" weiterhin in "gesucht" trifft (die passive Form ist Absicht).
local function SeekWordPosition(normalizedMessage, word)
    local letters = word:gsub("%s+$", "")
    if #letters <= 3 and letters:find("^%a+$") then
        local trailer = word:sub(#letters + 1):gsub("%W", "%%%0")
        return normalizedMessage:find("%f[%a]" .. letters .. trailer)
    end
    return normalizedMessage:find(word, 1, true)
end

-- Die frueheste Fundstelle irgendeines der Woerter, oder nil.
local function FirstPosition(normalizedMessage, words)
    local earliest
    for _, word in ipairs(words) do
        local at = SeekWordPosition(normalizedMessage, word)
        if at and (not earliest or at < earliest) then
            earliest = at
        end
    end
    return earliest
end

-- === Sucht hier jemand eine Gilde - oder sucht eine Gilde jemanden? =======
--
-- Die Begruendung steht bei den Wortlisten in Constants.lua. Kurz: Die
-- Reihenfolge entscheidet.
--
--     "ENH sucht Anschluss an Gilde"   -> Suchwort zuerst  -> Bewerber
--     "Gilde sucht noch aktive Raider" -> Gildenwort zuerst -> Werbung
--
-- Das faengt nebenbei die passive Form richtig ab, ohne eine eigene Regel:
-- In "Raider fuer unsere Gilde gesucht" steht "gilde" vor dem "sucht" in
-- "gesucht" - also Werbung, und das stimmt. Das ehrliche "Gilde gesucht!"
-- eines Bewerbers faengt weiterhin die Wendungsliste ab, die vorher laeuft.
local function LooksLikeGuildSeeker(normalizedMessage)
    local guildAt = FirstPosition(normalizedMessage, GC.GuildSeekerGuildWords)
    if not guildAt then
        return false
    end
    -- "Anschluss", "beitreten", "Aufnahme": Die verraten den Bewerber, egal wo
    -- sie stehen - die deutsche Verbstellung schiebt sie hinter das Objekt
    -- ("einer Gilde beitreten").
    if not MatchesAnyWord(normalizedMessage, GC.GuildSeekerJoinWords) then
        local seekAt = FirstPosition(normalizedMessage, GC.GuildSeekerSeekWords)
        if not seekAt or seekAt > guildAt then
            return false
        end
    end
    return true
end

GC.Chat.LooksLikeGuildSeeker = function(_, message)
    return LooksLikeGuildSeeker(tostring(message or ""):lower())
end

function GC.Chat:IsRecruitmentSignal(message)
    local normalized = tostring(message or ""):lower()
    if MatchesAnyWord(normalized, self:GetRecruitmentWords("chatExclusions")) then
        return false
    end

    -- Die EIGENE Wendungsliste ist eine Zusage: Was du selbst eintraegst, wird
    -- erfasst, ohne Wenn und Aber. Sie steht deshalb vor jeder Klugheit.
    local ownTriggers = self:GetRecruitmentFilters().chatTriggers
    if #ownTriggers > 0 and MatchesAnyWord(normalized, ownTriggers) then
        return true
    end

    -- Ohne die freie Erkennung bleibt es beim Wortvergleich, und die eigene
    -- Liste ersetzt die Vorgabe vollstaendig - wer sie eng haelt, bekommt
    -- genau diese Enge.
    if not GC.DB:GetSettings().smartRecruitmentDetection then
        return MatchesAnyWord(normalized, self:GetRecruitmentWords("chatTriggers"))
    end

    -- Ab hier darf das Addon eigenstaendig urteilen - und ein erkennbares
    -- Werbemerkmal wiegt schwerer als eine mitgelieferte Wendung. Sonst holt
    -- die Vorgabe "gilde gesucht" jedes "Raider fuer unsere Gilde gesucht"
    -- herein, also genau die Konkurrenzwerbung, die niemand im Postfach will.
    if MatchesAnyWord(normalized, GC.GuildSeekerAdMarkers) then
        return false
    end
    if MatchesAnyWord(normalized, self:GetRecruitmentWords("chatTriggers")) then
        return true
    end
    -- Und zuletzt die freie Erkennung fuer alles, was niemand vorher aufschreibt.
    return LooksLikeGuildSeeker(normalized)
end

function GC.Chat:SendReply(playerName, text)
    text = GC.Util.SafeChatText(text)
    if GC.Util.Trim(playerName) == "" or text == "" then
        return false
    end
    local sent = self:SendChat(text, "WHISPER", nil, nil, playerName)
    if sent then
        for _, lead in ipairs(GC.DB:GetGuild().inbox) do
            if SameLead(lead.name, lead.guid, playerName) then
                lead.unread = false
                lead.lastReplyAt = GC.Util.Now()
                break
            end
        end
        GC:FireCallback("INBOX_UPDATED")
    end
    return sent
end

function GC.Chat:Invite(playerName)
    if C_GuildInfo and C_GuildInfo.Invite then
        C_GuildInfo.Invite(playerName)
        return true
    elseif GuildInvite then
        GuildInvite(playerName)
        return true
    end
    return false
end

function GC.Chat:RemoveLead(index)
    local inbox = GC.DB:GetGuild().inbox
    index = tonumber(index)
    if not index or not inbox[index] then
        return false
    end
    -- Merker setzen: Der Sync holt diesen Spieler nicht mehr herein, bis er
    -- sich selbst wieder meldet (siehe NoteInboxTombstone).
    self:NoteInboxTombstone(inbox[index].name)
    table.remove(inbox, index)
    GC:FireCallback("INBOX_UPDATED")
    return true
end

function GC.Chat:ClearInbox()
    local inbox = GC.DB:GetGuild().inbox
    if #inbox == 0 then
        return false
    end
    -- Bewusst OHNE Merker: "Alles leeren" ist ein Aufräumen der Ansicht, kein
    -- Wegwerfen einzelner Bewerber. Sonst bliebe das gildenweite Postfach sieben
    -- Tage leer, obwohl Kollegen noch aktive Interessenten haben. Wer einen
    -- bestimmten dauerhaft los sein will, löscht ihn einzeln oder ignoriert ihn.
    for index = #inbox, 1, -1 do
        table.remove(inbox, index)
    end
    self.heardSenders = {}
    GC:FireCallback("INBOX_UPDATED")
    return true
end

-- === Das Postfach gildenweit ==============================================
--
-- Bis 0.9.131 war das Postfach das einzige gemeinsame Arbeitsmittel, das jeder
-- nur fuer sich hatte: Wer geflüstert wurde, sah den Bewerber - die anderen
-- nicht. Zwei Offiziere haben denselben Bewerber angeschrieben, ein dritter
-- gar keinen, weil er dachte, es sei erledigt.
--
-- Uebertragen wird nach dem Schneeballprinzip wie alles andere: Jeder Client
-- speichert, was er kennt, und reicht es weiter. Keine Berechtigungen, keine
-- ausgezeichneten Absender.
--
-- WAS uebertragen wird (Owner-Entscheidung):
--   * die URSPRUNGSNACHRICHT im Wortlaut - die, mit der jemand aufgefallen
--     ist ("Priester sucht Gilde"). Kein Chatverlauf: Der ist bei hundert
--     Eintraegen mit je zwanzig Nachrichten mehrere hundert Kilobyte, und die
--     spaeteren Zeilen sind fast immer Wiederholungen desselben Werbetexts.
--   * Fluesternachrichten ausdruecklich eingeschlossen.
--
-- Was NICHT mitfaehrt:
--   * "unread" - ob DU den Eintrag gelesen hast, ist deine Sache;
--   * der weitere Nachrichtenverlauf, den jeder lokal fuer sich behaelt;
--   * der Bearbeitungsstand (wer geantwortet hat) - ausdruecklich nicht
--     gewuenscht: Es geht darum, dass alle dieselben Bewerber SEHEN, nicht
--     darum, die Bearbeitung im Addon zu verwalten;
--   * die Ignorierliste - sie bleibt lokal und WIRKT auch gegen Fremdeintraege.
--
-- Die Ursprungsnachricht aendert sich nie. Ein Eintrag geht deshalb genau
-- einmal raus und danach nie wieder.

local INBOX_SYNC_PREFIX = "I"

-- Ein Eintrag passt selten in ein Chatpaket: Eine Bewerbung darf im Spiel 255
-- Zeichen lang sein, dazu kommen Name, GUID, Klasse und Zeitstempel. Der
-- fertige Datensatz wird deshalb gestueckelt uebertragen, genau wie die
-- Gildenbank ihre Faecher stueckelt, und beim Empfaenger ueber den Token
-- wieder zusammengesetzt.
local function BuildInboxRecord(lead)
    local first = type(lead.messages) == "table" and lead.messages[1] or nil
    return table.concat({
        GC.Util.EscapeField(lead.name or ""),
        GC.Util.EscapeField(lead.guid or ""),
        GC.Util.EscapeField(lead.classFile or ""),
        GC.Util.EscapeField(tostring(tonumber(lead.firstSeenAt) or 0)),
        GC.Util.EscapeField(tostring(tonumber(lead.lastSeenAt) or 0)),
        GC.Util.EscapeField(lead.source or ""),
        GC.Util.EscapeField(first and first.text or ""),
    }, "|")
end

local function ParseInboxRecord(payload)
    local fields = GC.Util.SplitFields(payload)
    if GC.Util.Trim(fields[1]) == "" then
        return nil
    end
    return {
        name = fields[1],
        guid = GC.Util.Trim(fields[2]) ~= "" and fields[2] or nil,
        classFile = GC.Util.Trim(fields[3]) ~= "" and fields[3] or nil,
        firstSeenAt = tonumber(fields[4]) or 0,
        lastSeenAt = tonumber(fields[5]) or 0,
        source = fields[6] or "",
        text = fields[7] or "",
    }
end

function GC.Chat:BuildInboxMessages(lead)
    if type(lead) ~= "table" or GC.Util.Trim(lead.name) == "" then
        return {}
    end
    local token = tostring(GC.Util.Now()) .. tostring(math.random(100, 999))
    local header = table.concat({
        INBOX_SYNC_PREFIX, tostring(GC.Constants.SCHEMA_VERSION), "IL",
        GC.Util.EscapeField(token), "000", "000", "",
    }, "|")
    local payload = GC.Util.EscapeField(BuildInboxRecord(lead))
    local limit = GC.Constants.MAX_CHAT_BYTES - #header
    if limit < 16 then
        return {}
    end

    local chunks = {}
    for offset = 1, math.max(1, #payload), limit do
        chunks[#chunks + 1] = payload:sub(offset, offset + limit - 1)
    end
    local messages = {}
    for index, chunk in ipairs(chunks) do
        messages[#messages + 1] = table.concat({
            INBOX_SYNC_PREFIX, tostring(GC.Constants.SCHEMA_VERSION), "IL",
            GC.Util.EscapeField(token), tostring(index), tostring(#chunks), chunk,
        }, "|")
    end
    return messages
end

function GC.Chat:SendLead(lead, distribution, target)
    if not GC.Sync then
        return false
    end
    local messages = self:BuildInboxMessages(lead)
    if #messages == 0 then
        return false
    end
    for _, message in ipairs(messages) do
        GC.Sync:SendBulk(message, distribution or "GUILD", target)
    end
    return true
end

-- Der ganze Bestand. Geht als Antwort auf eine Anfrage gezielt per Fluestern
-- raus, damit nicht die halbe Gilde dasselbe gleichzeitig in den Gildenkanal
-- schiebt.
function GC.Chat:SendInbox(distribution, target)
    local sent = 0
    for _, lead in ipairs(GC.DB:GetGuild().inbox) do
        if self:SendLead(lead, distribution, target) then
            sent = sent + 1
        end
    end
    return sent
end

function GC.Chat:RequestInbox()
    if not GC.Sync or not IsInGuild or not IsInGuild() then
        return false
    end
    return GC.Sync:Send(table.concat({
        INBOX_SYNC_PREFIX, tostring(GC.Constants.SCHEMA_VERSION), "IQ",
    }, "|"))
end

-- Ein fremder Eintrag wird eingefuegt, nicht ueberschrieben: Der Absender
-- kennt seinen Stand, wir unseren, und beide sind wahr.
function GC.Chat:MergeRemoteLead(record)
    if type(record) ~= "table" or GC.Util.Trim(record.name) == "" then
        return false
    end
    -- Dieselben Sperren wie beim eigenen Erfassen. Ohne sie holt ein fremdes
    -- Paket zurueck, was hier bewusst ausgeschlossen wurde - der eigene
    -- Charakter, ein Gildenmitglied, ein Ignorierter.
    if GC.Util.NormalizeName(record.name) == GC.Util.NormalizeName(GC:GetPlayerFullName()) then
        return false
    end
    if GC.Roster:IsGuildMember(record.name) then
        return false
    end
    if self:IsInboxFiltered(record.name) then
        return false
    end
    -- Gelöscht: nicht per Sync zurückholen. Gilt bewusst nur hier, nicht bei der
    -- eigenen Erfassung - meldet der Spieler sich selbst direkt, hebt CaptureLead
    -- den Merker auf, und er darf wieder herein.
    if self:IsInboxTombstoned(record.name) then
        return false
    end

    local inbox = GC.DB:GetGuild().inbox
    local lead
    for index = #inbox, 1, -1 do
        local existing = inbox[index]
        if type(existing) ~= "table" then
            table.remove(inbox, index)
        elseif SameLead(existing.name, existing.guid, record.name, record.guid) then
            lead = existing
        end
    end

    if not lead then
        lead = {
            name = record.name,
            guid = record.guid,
            firstSeenAt = record.firstSeenAt > 0 and record.firstSeenAt or GC.Util.Now(),
            source = record.source,
            messages = {},
            -- Ungelesen: Ein Bewerber, den ein Kollege aufgenommen hat, ist
            -- fuer DICH neu. Ein Klang kommt dabei nicht - beim Nachreichen
            -- eines ganzen Postfachs waere das ein Trommelfeuer.
            unread = true,
        }
        table.insert(inbox, 1, lead)
    end

    lead.guid = lead.guid or record.guid
    lead.classFile = lead.classFile or record.classFile
    lead.source = lead.source or record.source
    if record.firstSeenAt > 0 and (not tonumber(lead.firstSeenAt) or record.firstSeenAt < lead.firstSeenAt) then
        lead.firstSeenAt = record.firstSeenAt
    end
    if record.lastSeenAt > (tonumber(lead.lastSeenAt) or 0) then
        lead.lastSeenAt = record.lastSeenAt
    end
    -- Der Wortlaut nur, wenn hier noch keiner steht: Die eigene Aufzeichnung
    -- ist die genauere - sie hat den ganzen Verlauf, nicht nur den Anfang.
    if type(lead.messages) ~= "table" then
        lead.messages = {}
    end
    if #lead.messages == 0 and GC.Util.Trim(record.text) ~= "" then
        lead.messages[1] = {
            receivedAt = lead.firstSeenAt,
            text = record.text,
            source = record.source,
            remote = true,
        }
    end
    self:ResolveLeadClass(lead)
    -- Klasse und Stufe werden NICHT uebertragen, sondern beim Empfaenger aus
    -- demselben Text gelesen. Das spart Protokollfelder und haelt beide Seiten
    -- automatisch gleich, sobald die Erkennung besser wird.
    self:ReadLeadDetails(lead, record.text)
    return true
end

function GC.Chat:ReceiveSync(message, sender, distribution)
    local fields = GC.Util.SplitFields(message)
    if tonumber(fields[2]) ~= GC.Constants.SCHEMA_VERSION then
        return
    end
    local kind = fields[3]

    if kind == "IQ" then
        -- Gefragt wird in den Gildenkanal, geantwortet wird gezielt. Gestreut,
        -- damit nicht alle gleichzeitig losschicken.
        if distribution ~= "GUILD" or GC.Util.Trim(sender) == "" then
            return
        end
        if GC.Util.NormalizeName(sender) == GC.Util.NormalizeName(GC:GetPlayerFullName()) then
            return
        end
        if #GC.DB:GetGuild().inbox == 0 then
            return
        end
        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(1 + math.random() * 5, function()
                GC.Chat:SendInbox("WHISPER", sender)
            end)
        else
            self:SendInbox("WHISPER", sender)
        end
        return
    end

    if kind ~= "IL" then
        return
    end

    local token = fields[4]
    if GC.Util.Trim(token) == "" then
        return
    end
    local index = tonumber(fields[5]) or 0
    local count = tonumber(fields[6]) or 0
    if index < 1 or count < 1 or index > count or count > 8 then
        return
    end

    self.inboxIncoming = self.inboxIncoming or {}
    local key = tostring(sender) .. "\1" .. token
    local pending = self.inboxIncoming[key]
    if not pending then
        pending = { chunks = {}, count = count, at = GC.Util.Now() }
        self.inboxIncoming[key] = pending
    end
    pending.chunks[index] = fields[7] or ""
    pending.at = GC.Util.Now()

    for position = 1, pending.count do
        if pending.chunks[position] == nil then
            return
        end
    end
    self.inboxIncoming[key] = nil

    -- Genau zwei Entschluesselungen, nicht drei: Der Datensatz wird beim Senden
    -- zweimal maskiert (jedes Feld in BuildInboxRecord, dann der ganze Datensatz
    -- in BuildInboxMessages). SplitFields am eingehenden Paket macht die aeussere
    -- Maskierung rueckgaengig, ParseInboxRecords SplitFields die innere. Ein
    -- zusaetzliches UnescapeField hier war eine Entschluesselung zu viel und
    -- verwandelte ein maskiertes "%7C" mitten im Text in ein echtes "|" - woran
    -- die naechste Feldzerlegung die Bewerbernachricht abschnitt (Itemlinks,
    -- Farbcodes). Deshalb der rohe Datensatz direkt an ParseInboxRecord.
    local record = ParseInboxRecord(table.concat(pending.chunks))
    if record and self:MergeRemoteLead(record) then
        GC.DB:Prune()
        GC:FireCallback("INBOX_UPDATED")
    end
end

local chatEvents = CreateFrame("Frame")
chatEvents:RegisterEvent("CHAT_MSG_WHISPER")
chatEvents:RegisterEvent("CHAT_MSG_CHANNEL")
chatEvents:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
chatEvents:SetScript("OnEvent", function(_, event, ...)
    if event == "CHAT_MSG_WHISPER" then
        local message, sender, _, _, _, _, _, _, _, _, _, guid = ...
        GC.Chat:CaptureWhisper(message, sender, guid)
    elseif event == "CHAT_MSG_CHANNEL" then
        local message, sender, _, _, _, _, _, _, channelName, _, _, guid = ...
        if GC.DB:GetSettings().watchRecruitmentTriggers and GC.Chat:IsRecruitmentSignal(message) then
            GC.Chat:CaptureLead(message, sender, guid, channelName or "CHANNEL")
        end
    elseif event == "CHAT_MSG_CHANNEL_NOTICE" then
        local noticeType, _, _, _, _, _, _, channelIndex, channelName = ...
        local lfgChannelID = GC.Chat:FindChannel("LFG")
        if noticeType == "THROTTLED" and lfgChannelID then
            if tonumber(channelIndex) == tonumber(lfgChannelID)
                or NormalizeChannelName(channelName):find("suchenachgruppe", 1, true)
                or NormalizeChannelName(channelName):find("lookingforgroup", 1, true) then
                GC.DB:GetGuild().lastPosts.LFG = GC.Util.Now()
                GC:FireCallback("CHAT_STATUS", {}, { "SucheNachGruppe (Server-Cooldown)" })
            end
        end
    end
end)

GC:RegisterCallback("PLAYER_LOGIN", GC.Chat, function(self)
    self:MergeDuplicateLeads()
end)
