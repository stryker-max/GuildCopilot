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
        elseif type(defaultValue) == "table" and type(target[key]) == "table" then
            GC.Util.MergeDefaults(target[key], defaultValue)
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
        return items[1] .. " und " .. items[2]
    end

    local head = {}
    for index = 1, #items - 1 do
        head[#head + 1] = items[index]
    end
    return table.concat(head, ", ") .. " sowie " .. items[#items]
end

function GC.Util.SafeChatText(text, maximumBytes)
    text = GC.Util.Trim(text)
    maximumBytes = maximumBytes or GC.Constants.MAX_CHAT_BYTES
    if #text <= maximumBytes then
        return text
    end

    local clipped = text:sub(1, maximumBytes - 3)
    while #clipped > 0 and clipped:byte(#clipped) >= 128 and clipped:byte(#clipped) < 192 do
        clipped = clipped:sub(1, -2)
    end
    if #clipped > 0 and clipped:byte(#clipped) >= 192 then
        clipped = clipped:sub(1, -2)
    end

    local lastSpace = clipped:match("^.*()%s")
    if lastSpace and lastSpace > maximumBytes * 0.7 then
        clipped = clipped:sub(1, lastSpace - 1)
    end
    return clipped .. "..."
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

function GC.Util.Now()
    return time and time() or 0
end

function GC:GetPlayerFullName()
    local name, realm = UnitFullName and UnitFullName("player")
    if not name then
        name = UnitName and UnitName("player")
    end
    if not realm or realm == "" then
        realm = GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName and GetRealmName() or ""
    end
    if realm and realm ~= "" then
        return name .. "-" .. realm
    end
    return name or "Unbekannt"
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
        GC:FireCallback("PLAYER_LOGIN")
        GC:Print("v" .. GC.Constants.VERSION .. " geladen. Öffnen mit |cffffffff/gcp|r.")
    end
end)
