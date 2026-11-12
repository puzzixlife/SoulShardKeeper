local ADDON, NS = ...

local L = NS.L

local SHARD_ID = 6265
local MAX_CAP = 100
local REFRESH_DELAY = 0.12
local DELETE_COOLDOWN = 0.35
local DEFAULT_POINT = "CENTER"
local DEFAULT_X = 260
local DEFAULT_Y = -140
local LAYOUT_VERSION = 2

local defaults = {
    enabled = true,
    cap = 20,
    locked = false,
    hidden = false,
    scale = 1.0,
    point = DEFAULT_POINT,
    x = DEFAULT_X,
    y = DEFAULT_Y,
    quiet = true,
    quietGlint = false,
    welcome = false,
    layoutVersion = 0,
}

local validPoints = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true,
    LEFT = true, CENTER = true, RIGHT = true,
    BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}

local ignoredKeys = {
    LSHIFT = true, RSHIFT = true,
    LCTRL = true, RCTRL = true,
    LALT = true, RALT = true,
    ESCAPE = true, ENTER = true, RETURN = true,
    UNKNOWN = true,
}

local function clamp(value, low, high)
    if value < low then return low end
    if value > high then return high end
    return value
end

local function isInCombat()
    return (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player")) or false
end

NS.db = NS.db or {}
NS.state = NS.state or { count = 0, excess = 0, inCombat = false, cursor = false }
NS.initialized = false
NS.disabled = false
NS.dbReady = false
NS.lastDelete = 0
NS.lastExcess = 0
NS.lastFailPrint = 0
NS.refreshSerial = 0
NS.dragging = false
NS.suppressClick = 0
NS.suppressAutoUntil = 0

function NS:Print(message)
    local text = "|cffa335ee" .. L.TITLE .. "|r " .. tostring(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(text)
    else
        print(text)
    end
end

function NS:InitDB()
    SoulShardKeeperDB = SoulShardKeeperDB or {}
    self.db = SoulShardKeeperDB

    for key, value in pairs(defaults) do
        if self.db[key] == nil then
            self.db[key] = value
        end
    end

    self.db.cap = clamp(math.floor(tonumber(self.db.cap) or defaults.cap), 0, MAX_CAP)
    self.db.scale = clamp(tonumber(self.db.scale) or defaults.scale, 0.7, 1.6)
    self.db.enabled = self.db.enabled ~= false
    self.db.locked = self.db.locked == true
    self.db.hidden = self.db.hidden == true
    self.db.quiet = self.db.quiet ~= false
    self.db.quietGlint = self.db.quietGlint == true
    self.db.welcome = self.db.welcome == true

    if self.db.layoutVersion ~= LAYOUT_VERSION then
        self.db.layoutVersion = LAYOUT_VERSION
        self.db.point = DEFAULT_POINT
        self.db.x = DEFAULT_X
        self.db.y = DEFAULT_Y
    elseif not validPoints[self.db.point] then
        self.db.point = DEFAULT_POINT
        self.db.x = DEFAULT_X
        self.db.y = DEFAULT_Y
    end
    self.db.x = tonumber(self.db.x) or DEFAULT_X
    self.db.y = tonumber(self.db.y) or DEFAULT_Y

    self.dbReady = true
end

function NS:Scan()
    local total = 0
    local maxBag = NUM_BAG_SLOTS or 4
    for bag = 0, maxBag do
        local slots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, slots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID == SHARD_ID then
                total = total + (info.stackCount or 1)
            end
        end
    end
    return total
end

function NS:FindShard()
    local maxBag = NUM_BAG_SLOTS or 4
    for bag = 0, maxBag do
        local slots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = slots, 1, -1 do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID == SHARD_ID and not info.isLocked then
                return bag, slot, info.stackCount or 1
            end
        end
    end
    return nil
end

function NS:GetStatus()
    if not self.db or not self.db.enabled then
        return L.STATUS_OFF, 0.55, 0.51, 0.45
    end
    if self.state.inCombat then
        return L.STATUS_COMBAT, 0.95, 0.72, 0.32
    end
    if self.state.cursor then
        return L.STATUS_CURSOR, 0.95, 0.72, 0.32
    end
    if (self.state.excess or 0) > 0 then
        return L.STATUS_WAITING:format(self.state.excess), 0.93, 0.36, 0.30
    end
    return L.STATUS_WITHIN, 0.55, 0.85, 0.55
end

function NS:QueueRefresh(delay)
    self.refreshSerial = self.refreshSerial + 1
    local serial = self.refreshSerial
    C_Timer.After(delay or REFRESH_DELAY, function()
        if serial == NS.refreshSerial and NS.initialized then
            NS:Refresh()
        end
    end)
end

function NS:Refresh()
    if not self.initialized or self.disabled or not self.dbReady then
        return
    end

    local count = self:Scan()
    local cap = self.db.cap
    local excess = count > cap and (count - cap) or 0

    self.state.count = count
    self.state.excess = excess
    self.state.inCombat = isInCombat()
    self.state.cursor = (CursorHasItem and CursorHasItem()) and true or false

    if self.db.enabled and excess > 0 and self.lastExcess == 0 then
        self:Print(L.MSG_EXCEED:format(excess))
    end
    self.lastExcess = excess

    if NS.UI and NS.UI.Update then
        NS.UI.Update()
    end
end

local function muteGemSounds()
    if not NS.db.quietGlint then return end
    if MuteSoundFile then
        pcall(MuteSoundFile, 567568)
        pcall(MuteSoundFile, 567574)
    end
    C_Timer.After(1.0, function()
        if UnmuteSoundFile then
            pcall(UnmuteSoundFile, 567568)
            pcall(UnmuteSoundFile, 567574)
        end
    end)
end

function NS:DeleteOne(force)
    if not self.dbReady then return false end

    if isInCombat() then
        if force then self:Print(L.MSG_COMBAT) end
        return false
    end

    if CursorHasItem and CursorHasItem() then
        if force then self:Print(L.MSG_CURSOR) end
        return false
    end

    local count = self:Scan()
    if count <= 0 then
        if force then self:Print(L.MSG_NO_SHARDS) end
        return false
    end

    if not force and count <= self.db.cap then
        return false
    end

    local bag, slot, stack = self:FindShard()
    if not bag then
        if force then self:Print(L.MSG_LOCKED) end
        return false
    end

    self.lastDelete = GetTime()
    muteGemSounds()

    local deleted = false

    if stack > 1 then
        C_Container.SplitContainerItem(bag, slot, 1)
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemID == SHARD_ID and (info.stackCount or 1) == stack - 1 then
            local cursorType, cursorItemID = GetCursorInfo()
            if cursorType == "item" and tonumber(cursorItemID) == SHARD_ID then
                DeleteCursorItem()
                deleted = not (CursorHasItem and CursorHasItem())
                if not deleted and ClearCursor then ClearCursor() end
            elseif cursorType and ClearCursor then
                ClearCursor()
            end
        elseif ClearCursor then
            ClearCursor()
        end
    else
        C_Container.PickupContainerItem(bag, slot)
        local cursorType, cursorItemID = GetCursorInfo()
        if cursorType == "item" and tonumber(cursorItemID) == SHARD_ID then
            DeleteCursorItem()
            deleted = not (CursorHasItem and CursorHasItem())
            if not deleted and ClearCursor then ClearCursor() end
        elseif cursorType and ClearCursor then
            ClearCursor()
        end
    end

    if deleted then
        local newCount = count - 1
        self.state.count = newCount
        self.state.excess = newCount > self.db.cap and (newCount - self.db.cap) or 0

        if NS.UI and NS.UI.Update then
            NS.UI.Update()
            if NS.UI.Flash then NS.UI.Flash() end
        end

        if not self.db.quiet then
            self:Print(L.MSG_DELETED:format(count, newCount, self.db.cap))
        end

        self:QueueRefresh(0.15)
    else
        if GetTime() - self.lastFailPrint > 5 then
            self:Print(L.MSG_FAILED)
            self.lastFailPrint = GetTime()
        end
    end

    return deleted
end

function NS:IsOurUI()
    local focus = GetMouseFocus and GetMouseFocus()
    if not focus then return false end
    if NS.UI and NS.UI.button and focus == NS.UI.button then return true end
    if NS.UI and NS.UI.W and NS.UI.W.panel then
        local panel = NS.UI.W.panel
        if focus == panel then return true end
        if focus.IsDescendantOf then
            local ok, result = pcall(focus.IsDescendantOf, focus, panel)
            if ok and result then return true end
        end
    end
    return false
end

function NS:OnHardwareEvent(source)
    if not self.initialized or self.disabled or not self.dbReady then return end
    if not self.db.enabled then return end
    if self.dragging then return end
    if isInCombat() then return end
    if CursorHasItem and CursorHasItem() then return end
    if source == "mouse" and GetTime() < (self.suppressAutoUntil or 0) then return end
    if GetTime() - self.lastDelete < DELETE_COOLDOWN then return end

    if source == "mouse" and self:IsOurUI() then
        return
    end

    if source == "key" then
        if GetCurrentKeyBoardFocus then
            local focus = GetCurrentKeyBoardFocus()
            if focus and focus.IsObjectType then
                local ok, isEditBox = pcall(focus.IsObjectType, focus, "EditBox")
                if ok and isEditBox then return end
            end
        end
        if ChatFrame1EditBox and ChatFrame1EditBox:IsShown() and ChatFrame1EditBox:HasFocus() then
            return
        end
        local panel = NS.UI and NS.UI.W and NS.UI.W.panel
        if panel and panel:IsShown() and panel:IsMouseOver() then
            return
        end
    end

    self:DeleteOne(false)
end

function NS:CreateHardwareListeners()
    if self.hardwareCreated then return end
    self.hardwareCreated = true

    local keys = CreateFrame("Frame", nil, UIParent)
    keys:EnableKeyboard(true)
    local propagateOK = pcall(function()
        keys:SetPropagateKeyboardInput(true)
    end)

    if propagateOK then
        keys:SetScript("OnKeyDown", function(_, key)
            if ignoredKeys[key] then return end
            NS:OnHardwareEvent("key")
        end)
        self.keyListener = keys
    else
        keys:EnableKeyboard(false)
    end

    if WorldFrame and WorldFrame.HookScript then
        WorldFrame:HookScript("OnMouseDown", function()
            NS:OnHardwareEvent("mouse")
        end)
    end
end

function NS:Initialize()
    if self.initialized then return end
    if not self.dbReady then self:InitDB() end

    local _, class = UnitClass("player")
    if class ~= "WARLOCK" then
        self.disabled = true
        self.initialized = true
        return
    end

    if NS.UI and NS.UI.Init then
        NS.UI.Init()
    end

    self:CreateHardwareListeners()
    self.initialized = true
    self:Refresh()

    if not self.db.welcome then
        self.db.welcome = true
        self:Print(L.MSG_WELCOME)
    end
end

function NS:OpenOptions()
    if self.disabled then
        self:Print(L.MSG_ONLY_WARLOCK)
        return
    end
    if not self.initialized then
        self:Initialize()
    end
    if NS.UI and NS.UI.OpenOptions then
        NS.UI.OpenOptions()
    else
        self:Print(L.MSG_NO_UI)
    end
end

function NS:SetCap(value)
    value = clamp(math.floor(tonumber(value) or 0), 0, MAX_CAP)
    self.db.cap = value
    self:Refresh()
    if NS.UI and NS.UI.SyncControls then
        NS.UI.SyncControls()
    end
    self:Print(L.MSG_CAP_SET:format(value))
end

local function printHelp()
    NS:Print(L.HELP_HEADER)
    for _, line in ipairs(L.HELP_LINES) do
        NS:Print(line)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON then
            NS:InitDB()
        end
    elseif event == "PLAYER_LOGIN" then
        NS:Initialize()
    elseif event == "PLAYER_ENTERING_WORLD" then
        NS:Initialize()
        if NS.initialized and not NS.disabled then
            NS:QueueRefresh(0.25)
        end
    elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
        if NS.initialized and not NS.disabled then
            NS:QueueRefresh()
        end
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        if NS.initialized and not NS.disabled then
            NS:Refresh()
        end
    end
end)

SLASH_SOULSHARDKEEPER1 = "/ssk"
SLASH_SOULSHARDKEEPER2 = "/shardkeeper"
SlashCmdList["SOULSHARDKEEPER"] = function(message)
    NS:Initialize()

    if NS.disabled then
        NS:Print(L.MSG_ONLY_WARLOCK)
        return
    end

    local text = (message or ""):match("^%s*(.-)%s*$")
    local command, argument = text:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")
    argument = argument or ""

    if command == "" then
        NS:OpenOptions()
    elseif command == "show" then
        NS.db.hidden = false
        if NS.UI and NS.UI.ApplyVisibility then NS.UI.ApplyVisibility() end
        NS:Print(L.MSG_SHOWN)
    elseif command == "hide" then
        NS.db.hidden = true
        if NS.UI and NS.UI.ApplyVisibility then NS.UI.ApplyVisibility() end
        NS:Print(L.MSG_HIDDEN)
    elseif command == "lock" then
        NS.db.locked = true
        if NS.UI and NS.UI.SyncControls then NS.UI.SyncControls() end
        NS:Print(L.MSG_LOCKED_POS)
    elseif command == "unlock" then
        NS.db.locked = false
        if NS.UI and NS.UI.SyncControls then NS.UI.SyncControls() end
        NS:Print(L.MSG_UNLOCKED_POS)
    elseif command == "cap" then
        local value = tonumber(argument)
        if value then
            NS:SetCap(value)
        else
            NS:Print(L.MSG_BAD_CAP)
        end
    elseif command == "on" then
        NS.db.enabled = true
        NS:Refresh()
        if NS.UI and NS.UI.SyncControls then NS.UI.SyncControls() end
        NS:Print(L.MSG_AUTO_ON)
    elseif command == "off" then
        NS.db.enabled = false
        NS:Refresh()
        if NS.UI and NS.UI.SyncControls then NS.UI.SyncControls() end
        NS:Print(L.MSG_AUTO_OFF)
    elseif command == "status" then
        local status = NS:GetStatus()
        local auto = NS.db.enabled and L.ON or L.OFF
        NS:Print(L.MSG_STATUS:format(NS.state.count or 0, NS.db.cap, auto, status))
    elseif command == "reset" then
        if NS.UI and NS.UI.ResetPosition then
            NS.UI.ResetPosition()
        end
        NS:Print(L.MSG_RESET)
    else
        printHelp()
    end
end
