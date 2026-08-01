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

-- Was tatsaechlich verglichen wird: die eigene Liste, sonst die Vorgabe.
function GC.Chat:GetRecruitmentWords(key)
    local definition = FILTER_LISTS[key]
    if not definition then
        return {}
    end
    local stored = self:GetRecruitmentFilters()[key]
    if #stored > 0 then
        return stored
    end
    return definition.default and GC[definition.default] or {}
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
-- Vorgabe wieder, und es bleibt keine Kopie stehen, die bei einer spaeteren
-- Aenderung der Vorgabe veraltet waere.
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
    local ownRealm = tostring(GC:GetPlayerFullName() or ""):match("%-(.+)$")
    if ownRealm and ownRealm ~= "" then
        return GC.Util.NormalizeName(trimmed .. "-" .. ownRealm)
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

-- Die Klasse steckt in der bereits erfassten GUID des Absenders; es braucht
-- also keine zusaetzliche Abfrage. Direkt nach dem Login ist der Namens-Cache
-- des Clients aber noch kalt, deshalb ist der Aufruf idempotent und wird beim
-- Anzeigen des Postfachs so lange wiederholt, bis er etwas liefert. Das
-- ergaenzt auch Interessenten, die vor dieser Version gespeichert wurden.
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

    self:MergeDuplicateLeads()
    local inbox = GC.DB:GetGuild().inbox
    local normalizedSender = GC.Util.NormalizeName(GC.Util.PlayerShortName(sender))
    local lead
    for _, existing in ipairs(inbox) do
        if SameLead(existing.name, existing.guid, sender, guid) then
            lead = existing
            break
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
    end
    lead.lastSeenAt = GC.Util.Now()
    lead.unread = true
    lead.source = source or lead.source
    lead.guid = lead.guid or guid
    self:ResolveLeadClass(lead)
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
    GC:FireCallback("INBOX_UPDATED", lead)
end

function GC.Chat:CaptureWhisper(message, sender, guid)
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

function GC.Chat:IsRecruitmentSignal(message)
    local normalized = tostring(message or ""):lower()
    if MatchesAnyWord(normalized, self:GetRecruitmentWords("chatExclusions")) then
        return false
    end
    return MatchesAnyWord(normalized, self:GetRecruitmentWords("chatTriggers"))
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
    table.remove(inbox, index)
    GC:FireCallback("INBOX_UPDATED")
    return true
end

function GC.Chat:ClearInbox()
    local inbox = GC.DB:GetGuild().inbox
    if #inbox == 0 then
        return false
    end
    for index = #inbox, 1, -1 do
        table.remove(inbox, index)
    end
    self.heardSenders = {}
    GC:FireCallback("INBOX_UPDATED")
    return true
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
