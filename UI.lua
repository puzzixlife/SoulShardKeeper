local ADDON, NS = ...

local L = NS.L
local MEDIA = "Interface\\AddOns\\" .. ADDON .. "\\Media\\"
local DUI_MEDIA = "Interface\\AddOns\\DaylightUI\\Media\\"

NS.UI = NS.UI or {}
local UI = NS.UI
local W = {}
UI.W = W

-- DaylightUI's own palette (its options theme): dark neutral panels, warm
-- text, thin rules. Values are read here rather than depending on DUI's
-- internals, so a DaylightUI update can't break this file.
local C = {
    bg = { 0.078, 0.078, 0.090, 0.97 },
    card = { 0.106, 0.106, 0.122, 0.98 },
    cardEdge = { 0.165, 0.165, 0.188, 1.0 },
    line = { 1, 1, 1, 0.06 },
    text = { 0.949, 0.933, 0.902 },
    label = { 0.76, 0.71, 0.62 },
    dim = { 0.55, 0.51, 0.45 },
    track = { 0.19, 0.19, 0.22, 1.0 },
    trackHover = { 0.25, 0.25, 0.29, 1.0 },
    control = { 0.133, 0.133, 0.153, 1.0 },
    controlHover = { 0.18, 0.18, 0.20, 1.0 },
    band = { 0.10, 0.09, 0.063, 1.0 },
    button = { 0.071, 0.071, 0.078, 1.0 },
    accent = { 0.635, 0.369, 0.780, 1.0 },   -- warlock purple
    accentHover = { 0.73, 0.47, 0.88, 1.0 },
    blue = { 0.239, 0.612, 1.0, 1.0 },
    pink = { 0.878, 0.404, 0.624, 1.0 },
    good = { 0.55, 0.85, 0.55, 1.0 },
    warn = { 0.95, 0.72, 0.32, 1.0 },
    bad = { 0.93, 0.36, 0.30, 1.0 },
    badge = { 0.035, 0.035, 0.045, 0.58 },
    ring = { 0.16, 0.16, 0.19, 0.95 },
}

local FONT = (GameFontNormal and GameFontNormal:GetFont()) or "Fonts\\FRIZQT__.TTF"
local M = {}
UI.M = M

local function addonLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        local ok, loaded = pcall(C_AddOns.IsAddOnLoaded, name)
        if ok then return loaded == true end
    end
    if IsAddOnLoaded then
        local ok, loaded = pcall(IsAddOnLoaded, name)
        if ok then return loaded == true end
    end
    return false
end

local function resolveMedia()
    local dui = addonLoaded("DaylightUI")
    M.hasDUI = dui
    M.orb = dui and (DUI_MEDIA .. "class\\warlock.tga") or (MEDIA .. "orb.tga")
    M.glow = dui and (DUI_MEDIA .. "glow.png") or (MEDIA .. "orb_glow.tga")
    M.pill = dui and (DUI_MEDIA .. "ui-pill.png") or "Interface\\Buttons\\WHITE8X8"
    M.round = dui and (DUI_MEDIA .. "ui-round.png") or "Interface\\Buttons\\WHITE8X8"
    M.roundLine = dui and (DUI_MEDIA .. "ui-round-line.png") or "Interface\\Buttons\\WHITE8X8"
    M.knob = dui and (DUI_MEDIA .. "ui-knob.png") or (MEDIA .. "slider.tga")
    M.close = dui and (DUI_MEDIA .. "ui-close.png") or nil
    M.gradient = dui and (DUI_MEDIA .. "gradient-daylight.png") or nil
    M.ring = dui and (DUI_MEDIA .. "crest-ring.png") or nil
    M.numberFont = dui and (DUI_MEDIA .. "fonts\\ExpresswayFree.ttf") or FONT
end

local function tint(texture, color, alpha)
    if not texture then return end
    texture:SetVertexColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function ink(fontString, color, alpha)
    if not fontString then return end
    fontString:SetTextColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function setFont(fontString, size, flags)
    fontString:SetFont(FONT, size, flags or "")
    fontString:SetShadowColor(0, 0, 0, 0.7)
    fontString:SetShadowOffset(1, -1)
end

local function setNumberFont(fontString, size, flags)
    fontString:SetFont(M.numberFont or FONT, size, flags or "")
    fontString:SetShadowColor(0, 0, 0, 0.7)
    fontString:SetShadowOffset(1, -1)
end

-- A rounded rectangle from DaylightUI's nine-slice round texture. Without
-- DaylightUI the same call falls back to a plain white square, so the addon
-- still works on its own.
local function rounded(parent, layer, outline, color)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
    texture:SetTexture(outline and M.roundLine or M.round)
    if M.hasDUI and texture.SetTextureSliceMargins then
        texture:SetTextureSliceMargins(10, 10, 10, 10)
        if texture.SetTextureSliceMode and Enum and Enum.UITextureSliceMode then
            texture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
        end
    end
    tint(texture, color)
    return texture
end

local function rule(parent, y, inset)
    local texture = parent:CreateTexture(nil, "ARTWORK")
    texture:SetColorTexture(C.line[1], C.line[2], C.line[3], C.line[4])
    texture:SetHeight(1)
    texture:SetPoint("TOPLEFT", parent, "TOPLEFT", inset or 16, y)
    texture:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -(inset or 16), y)
    return texture
end

local function makeCard(parent, y, height, title, accent)
    local card = CreateFrame("Frame", nil, parent)
    card:SetSize(448, height)
    card:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, y)

    local background = rounded(card, "BACKGROUND", false, C.card)
    background:SetAllPoints(card)
    if M.hasDUI then
        local edge = rounded(card, "BORDER", true, C.cardEdge)
        edge:SetAllPoints(card)
    end

    local lit = card:CreateTexture(nil, "ARTWORK")
    lit:SetColorTexture(0.216, 0.216, 0.243, 0.7)
    lit:SetPoint("TOPLEFT", card, "TOPLEFT", 1, -1)
    lit:SetPoint("TOPRIGHT", card, "TOPRIGHT", -1, -1)
    lit:SetHeight(1)

    local chip = card:CreateTexture(nil, "ARTWORK")
    chip:SetColorTexture(accent[1], accent[2], accent[3], 1)
    chip:SetSize(3, 14)
    chip:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -14)

    local heading = card:CreateFontString(nil, "ARTWORK")
    setFont(heading, 13, "")
    heading:SetPoint("TOPLEFT", card, "TOPLEFT", 26, -11)
    heading:SetText(title)
    ink(heading, C.text)

    return card
end

local function makeToggle(card, y, text, get, set)
    local label = card:CreateFontString(nil, "ARTWORK")
    setFont(label, 12, "")
    label:SetPoint("TOPLEFT", card, "TOPLEFT", 16, y)
    label:SetText(text)
    ink(label, C.text)

    local toggle = CreateFrame("Button", nil, card)
    toggle:SetSize(36, 18)
    toggle:SetPoint("TOPRIGHT", card, "TOPRIGHT", -16, y + 2)

    toggle.track = toggle:CreateTexture(nil, "ARTWORK")
    toggle.track:SetTexture(M.pill)
    toggle.track:SetAllPoints(toggle)

    toggle.knob = toggle:CreateTexture(nil, "OVERLAY")
    toggle.knob:SetTexture(M.knob)
    toggle.knob:SetSize(14, 14)

    local function paint()
        local on = get() == true
        tint(toggle.track, on and C.accent or C.track)
        toggle.knob:ClearAllPoints()
        toggle.knob:SetPoint("LEFT", toggle, "LEFT", on and 19 or 3, 0)
        tint(toggle.knob, C.text)
    end

    toggle:SetScript("OnClick", function()
        set(not get())
        paint()
        UI.UpdateOptions()
    end)
    toggle:SetScript("OnEnter", function()
        tint(toggle.track, get() and C.accentHover or C.trackHover)
    end)
    toggle:SetScript("OnLeave", paint)
    toggle.paint = paint
    paint()
    return toggle
end

local function makeSlider(card, y, text, minValue, maxValue, step, get, set, formatter)
    local label = card:CreateFontString(nil, "ARTWORK")
    setFont(label, 12, "")
    label:SetPoint("TOPLEFT", card, "TOPLEFT", 16, y)
    label:SetText(text)
    ink(label, C.text)

    local value = card:CreateFontString(nil, "ARTWORK")
    setNumberFont(value, 12, "")
    value:SetPoint("TOPRIGHT", card, "TOPRIGHT", -16, y)
    ink(value, C.text)

    -- A plain Button rather than a Slider: this client only starts a Slider
    -- drag on its 16 px thumb, so the whole DaylightUI bar is the hit area.
    local slider = CreateFrame("Button", nil, card)
    slider:SetSize(416, 24)
    slider:SetPoint("TOPLEFT", card, "TOPLEFT", 16, y - 24)
    slider:SetFrameLevel(card:GetFrameLevel() + 5)
    slider:EnableMouse(true)
    slider.min, slider.max, slider.step = minValue, maxValue, step
    slider.valueText = value

    slider.track = slider:CreateTexture(nil, "BACKGROUND")
    slider.track:SetTexture(M.pill)
    slider.track:SetPoint("LEFT", slider, "LEFT", 0, 0)
    slider.track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
    slider.track:SetHeight(4)
    tint(slider.track, C.track)

    slider.fill = slider:CreateTexture(nil, "BORDER")
    if M.gradient then
        slider.fill:SetTexture(M.gradient)
        tint(slider.fill, { 1, 1, 1, 0.95 })
    else
        slider.fill:SetTexture(M.pill)
        tint(slider.fill, C.accent)
    end
    slider.fill:SetPoint("LEFT", slider.track, "LEFT", 0, 0)
    slider.fill:SetHeight(4)

    slider.knob = slider:CreateTexture(nil, "OVERLAY")
    slider.knob:SetTexture(M.knob)
    slider.knob:SetSize(16, 16)
    tint(slider.knob, C.text)

    local function apply(raw, notify)
        local clamped = math.max(minValue, math.min(maxValue, raw or minValue))
        local stepped = minValue + math.floor((clamped - minValue) / step + 0.5) * step
        stepped = math.max(minValue, math.min(maxValue, stepped))

        slider.value = stepped
        local width = slider:GetWidth() or 416
        local fraction = maxValue > minValue and ((stepped - minValue) / (maxValue - minValue)) or 0
        slider.fill:SetWidth(math.max(0.01, width * fraction))
        slider.knob:ClearAllPoints()
        slider.knob:SetPoint("CENTER", slider, "LEFT", width * fraction, 0)
        slider.valueText:SetText(formatter(stepped))

        if notify ~= false and not UI.syncing then
            set(stepped)
        end
    end

    function slider:SetValue(valueNow)
        apply(valueNow, true)
    end

    function slider:GetValue()
        return self.value or minValue
    end

    local function valueFromCursor()
        local effective = slider:GetEffectiveScale()
        local left = slider:GetLeft()
        local width = slider:GetWidth()
        if not effective or effective <= 0 or not left or not width or width <= 0 then
            return
        end
        local cursorX = GetCursorPosition() / effective
        local fraction = (cursorX - left) / width
        fraction = math.max(0, math.min(1, fraction))
        apply(minValue + fraction * (maxValue - minValue), true)
    end

    slider:SetScript("OnMouseDown", function(self)
        self.dragging = true
        valueFromCursor()
    end)
    slider:SetScript("OnUpdate", function(self)
        if self.dragging then
            valueFromCursor()
        end
    end)
    slider:SetScript("OnMouseUp", function(self)
        self.dragging = false
    end)
    slider:SetScript("OnHide", function(self)
        self.dragging = false
    end)
    slider:SetScript("OnEnter", function()
        tint(slider.track, C.trackHover)
    end)
    slider:SetScript("OnLeave", function(self)
        self.dragging = false
        tint(slider.track, C.track)
    end)

    apply(get(), false)
    return slider
end

local function makeButton(parent, text, width, height, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, height)

    button.outline = button:CreateTexture(nil, "BACKGROUND")
    button.outline:SetTexture("Interface\\Buttons\\WHITE8X8")
    button.outline:SetAllPoints(button)
    button.outline:SetVertexColor(0.024, 0.024, 0.027, 1)

    button.band = button:CreateTexture(nil, "BACKGROUND")
    button.band:SetTexture("Interface\\Buttons\\WHITE8X8")
    button.band:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    button.band:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    button.band:SetVertexColor(C.band[1], C.band[2], C.band[3], 1)

    button.fill = button:CreateTexture(nil, "BACKGROUND")
    button.fill:SetTexture("Interface\\Buttons\\WHITE8X8")
    button.fill:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -3)
    button.fill:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    button.fill:SetVertexColor(C.button[1], C.button[2], C.button[3], 1)

    button.label = button:CreateFontString(nil, "OVERLAY")
    setFont(button.label, 12, "")
    button.label:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.label:SetText(text)
    ink(button.label, C.text)

    local function paint(hover, down)
        if hover then
            button.band:SetVertexColor(C.accent[1], C.accent[2], C.accent[3], 1)
        else
            button.band:SetVertexColor(C.band[1], C.band[2], C.band[3], 1)
        end
        local shade = down and 0.045 or 0.071
        button.fill:SetVertexColor(shade, shade, shade + 0.006, 1)
        button.label:SetAlpha(down and 0.8 or 1)
    end

    button:SetScript("OnEnter", function() paint(true, false) end)
    button:SetScript("OnLeave", function() paint(false, false) end)
    button:SetScript("OnMouseDown", function() paint(true, true) end)
    button:SetScript("OnMouseUp", function() paint(true, false) end)
    button:SetScript("OnClick", onClick)
    paint(false, false)
    return button
end

local function makeClose(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(28, 28)
    button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, -8)

    if M.close then
        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetTexture(M.close)
        button.icon:SetSize(14, 14)
        button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
        tint(button.icon, C.text)
    else
        button.text = button:CreateFontString(nil, "ARTWORK")
        setFont(button.text, 16, "")
        button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.text:SetText("X")
        ink(button.text, C.label)
    end

    local function paint(hover)
        if button.icon then tint(button.icon, hover and C.accent or C.text) end
        if button.text then ink(button.text, hover and C.accent or C.text) end
    end

    button:SetScript("OnEnter", function() paint(true) end)
    button:SetScript("OnLeave", function() paint(false) end)
    button:SetScript("OnClick", function() parent:Hide() end)
    return button
end

function UI.Init()
    if UI.initialized then return end
    UI.initialized = true

    resolveMedia()
    UI.CreateOrb()
    UI.CreateOptions()
    UI.ApplyPosition()
    UI.ApplyScale()
    UI.ApplyVisibility()
    UI.Update()
end

function UI.CreateOrb()
    local button = CreateFrame("Button", "SoulShardKeeperButton", UIParent)
    button:SetSize(72, 72)
    button:SetFrameStrata("HIGH")
    button:SetFrameLevel(50)
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHitRectInsets(4, 4, 4, 4)

    button.aura = button:CreateTexture(nil, "BACKGROUND")
    button.aura:SetTexture(M.glow)
    button.aura:SetBlendMode("ADD")
    button.aura:SetSize(92, 92)
    button.aura:SetPoint("CENTER", button, "CENTER", 0, 0)
    tint(button.aura, C.accent, 0.32)

    button:SetNormalTexture(M.orb)
    button:SetPushedTexture(M.orb)
    button:SetHighlightTexture(M.glow, "ADD")

    local pushed = button:GetPushedTexture()
    if pushed then pushed:SetVertexColor(0.80, 0.80, 0.80) end
    local highlight = button:GetHighlightTexture()
    if highlight then
        highlight:SetAlpha(0.28)
        highlight:SetVertexColor(C.accent[1], C.accent[2], C.accent[3], 1)
    end

    if M.ring then
        button.ring = button:CreateTexture(nil, "OVERLAY")
        button.ring:SetTexture(M.ring)
        button.ring:SetAllPoints(button)
        tint(button.ring, C.ring)
    end

    button.countBadge = button:CreateTexture(nil, "OVERLAY")
    button.countBadge:SetTexture(M.pill)
    button.countBadge:SetSize(34, 20)
    button.countBadge:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.countBadge:SetVertexColor(C.badge[1], C.badge[2], C.badge[3], C.badge[4])

    local count = button:CreateFontString(nil, "OVERLAY")
    setNumberFont(count, 20, "OUTLINE")
    count:SetPoint("CENTER", button, "CENTER", 0, 0)
    count:SetText("0")
    ink(count, C.text)
    button.count = count

    local offBadge = button:CreateFontString(nil, "OVERLAY")
    setNumberFont(offBadge, 9, "OUTLINE")
    offBadge:SetPoint("BOTTOM", button, "BOTTOM", 0, 4)
    offBadge:SetText("OFF")
    ink(offBadge, C.dim)
    offBadge:Hide()
    button.offBadge = offBadge

    local alertGlow = button:CreateTexture(nil, "OVERLAY")
    alertGlow:SetTexture(M.glow)
    alertGlow:SetBlendMode("ADD")
    alertGlow:SetAllPoints(button)
    alertGlow:SetVertexColor(1.0, 0.22, 0.30, 1.0)
    alertGlow:SetAlpha(0)
    button.alertGlow = alertGlow

    button:SetScript("OnMouseDown", function()
        NS.suppressAutoUntil = GetTime() + 0.15
    end)

    button:SetScript("OnDragStart", function(self)
        if NS.db.locked then return end
        NS.dragging = true
        GameTooltip:Hide()
        self:StartMoving()
    end)

    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        NS.dragging = false
        NS.suppressClick = GetTime() + 0.2
        UI.SavePosition()
    end)

    button:SetScript("OnClick", function(_, mouseButton)
        if GetTime() < (NS.suppressClick or 0) then return end
        if mouseButton == "LeftButton" then
            NS:DeleteOne(true)
        elseif mouseButton == "RightButton" then
            UI.OpenOptions()
        end
    end)

    button:SetScript("OnEnter", function()
        if button.ring then tint(button.ring, C.accent, 1) end
        button.aura:SetAlpha(0.55)
        UI.ShowTooltip()
    end)

    button:SetScript("OnLeave", function()
        if button.ring then tint(button.ring, C.ring) end
        button.aura:SetAlpha(0.32)
        GameTooltip:Hide()
    end)

    button:SetScript("OnUpdate", function(self, elapsed)
        if self.alerting then
            self.pulse = (self.pulse or 0) + elapsed
            self.alertGlow:SetAlpha(0.22 + 0.16 * (0.5 + 0.5 * math.sin(self.pulse * 4.0)))
        elseif self.alertGlow:GetAlpha() ~= 0 then
            self.alertGlow:SetAlpha(0)
        end
    end)

    UI.button = button
end

function UI.CreateOptions()
    local panel = CreateFrame("Frame", "SoulShardKeeperOptions", UIParent)
    panel:SetSize(480, 690)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("DIALOG")
    panel:SetToplevel(true)
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:Hide()
    W.panel = panel

    local background = rounded(panel, "BACKGROUND", false, C.bg)
    background:SetAllPoints(panel)
    if M.hasDUI then
        local edge = rounded(panel, "BORDER", true, C.cardEdge)
        edge:SetAllPoints(panel)
    end

    local gradient = panel:CreateTexture(nil, "ARTWORK")
    if M.gradient then
        gradient:SetTexture(M.gradient)
        gradient:SetVertexColor(1, 1, 1, 0.92)
    else
        gradient:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0.9)
    end
    gradient:SetPoint("TOPLEFT", panel, "TOPLEFT", 1, -1)
    gradient:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -1, -1)
    gradient:SetHeight(2)

    local icon = panel:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(M.orb)
    icon:SetSize(24, 24)
    icon:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -16)
    W.icon = icon

    local title = panel:CreateFontString(nil, "ARTWORK")
    setFont(title, 18, "")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 52, -13)
    title:SetText(L.TITLE)
    ink(title, C.text)
    W.title = title

    local subtitle = panel:CreateFontString(nil, "ARTWORK")
    setFont(subtitle, 11, "")
    subtitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 52, -37)
    subtitle:SetText(L.SUBTITLE)
    ink(subtitle, C.label)
    W.subtitle = subtitle

    W.close = makeClose(panel)
    rule(panel, -64, 16)

    local autoCard = makeCard(panel, -78, 216, L.AUTO_SECTION, C.accent)
    W.autoCard = autoCard

    W.enableToggle = makeToggle(autoCard, -46, L.AUTO_ENABLE,
        function() return NS.db.enabled end,
        function(value)
            NS.db.enabled = value
            NS:Refresh()
        end)

    W.capSlider = makeSlider(autoCard, -78, L.CAP_LABEL, 0, 100, 1,
        function() return NS.db.cap end,
        function(value)
            NS.db.cap = value
            NS:Refresh()
        end,
        function(value) return tostring(value) end)

    local capNote = autoCard:CreateFontString(nil, "ARTWORK")
    setFont(capNote, 10, "")
    capNote:SetPoint("TOPLEFT", autoCard, "TOPLEFT", 16, -124)
    capNote:SetWidth(416)
    capNote:SetJustifyH("LEFT")
    capNote:SetWordWrap(true)
    capNote:SetText(L.CAP_ZERO_NOTE)
    ink(capNote, C.dim)

    W.chatToggle = makeToggle(autoCard, -150, L.CHAT_CHECK,
        function() return not NS.db.quiet end,
        function(value) NS.db.quiet = not value end)

    W.glintToggle = makeToggle(autoCard, -180, L.GLINT_CHECK,
        function() return NS.db.quietGlint end,
        function(value) NS.db.quietGlint = value end)

    local orbCard = makeCard(panel, -304, 196, L.BUTTON_SECTION, C.pink)
    W.orbCard = orbCard

    W.showToggle = makeToggle(orbCard, -46, L.SHOW_CHECK,
        function() return not NS.db.hidden end,
        function(value)
            NS.db.hidden = not value
            UI.ApplyVisibility()
        end)

    W.lockToggle = makeToggle(orbCard, -76, L.LOCK_CHECK,
        function() return NS.db.locked end,
        function(value) NS.db.locked = value end)

    W.scaleSlider = makeSlider(orbCard, -108, L.SCALE_LABEL, 70, 160, 5,
        function() return NS.db.scale * 100 end,
        function(value)
            NS.db.scale = value / 100
            UI.ApplyScale()
        end,
        function(value) return value .. "%" end)

    W.resetButton = makeButton(orbCard, L.RESET_BUTTON, 104, 24, function()
        UI.ResetPosition()
        NS:Print(L.MSG_RESET)
    end)
    W.resetButton:SetPoint("TOPLEFT", orbCard, "TOPLEFT", 16, -160)

    W.destroyButton = makeButton(orbCard, L.DESTROY_BUTTON, 126, 24, function()
        NS:DeleteOne(true)
    end)
    W.destroyButton:SetPoint("TOPLEFT", orbCard, "TOPLEFT", 128, -160)

    local statusCard = makeCard(panel, -510, 112, L.STATUS_SECTION, C.blue)
    W.statusCard = statusCard

    local current = statusCard:CreateFontString(nil, "ARTWORK")
    setFont(current, 16, "OUTLINE")
    current:SetPoint("TOPLEFT", statusCard, "TOPLEFT", 16, -34)
    current:SetText(L.CURRENT_LINE:format(0))
    ink(current, C.text)
    W.current = current

    local excess = statusCard:CreateFontString(nil, "ARTWORK")
    setFont(excess, 11, "")
    excess:SetPoint("TOPLEFT", statusCard, "TOPLEFT", 16, -60)
    excess:SetText(L.EXCESS_LINE:format(0))
    ink(excess, C.dim)
    W.excess = excess

    local status = statusCard:CreateFontString(nil, "ARTWORK")
    setFont(status, 11, "")
    status:SetPoint("TOPLEFT", statusCard, "TOPLEFT", 16, -82)
    status:SetWidth(416)
    status:SetJustifyH("LEFT")
    status:SetWordWrap(true)
    status:SetText(L.STATUS_WITHIN)
    ink(status, C.good)
    W.status = status

    local footer = panel:CreateFontString(nil, "ARTWORK")
    setFont(footer, 11, "")
    footer:SetPoint("BOTTOM", panel, "BOTTOM", 0, 20)
    footer:SetText(L.FOOTER)
    ink(footer, C.label)
    W.footer = footer

    local command = panel:CreateFontString(nil, "ARTWORK")
    setFont(command, 10, "")
    command:SetPoint("BOTTOM", panel, "BOTTOM", 0, 4)
    command:SetText(L.CMD_FOOTER)
    ink(command, C.dim)
    W.command = command

    panel:SetScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            self:StartMoving()
        end
    end)
    panel:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    panel:SetScript("OnShow", function()
        UI.SyncControls()
        UI.UpdateOptions()
    end)

    if UISpecialFrames then
        tinsert(UISpecialFrames, "SoulShardKeeperOptions")
    end
end

function UI.SyncControls()
    if not W.panel then return end

    UI.syncing = true
    if W.enableToggle then W.enableToggle.paint() end
    if W.chatToggle then W.chatToggle.paint() end
    if W.glintToggle then W.glintToggle.paint() end
    if W.showToggle then W.showToggle.paint() end
    if W.lockToggle then W.lockToggle.paint() end
    if W.capSlider then W.capSlider:SetValue(NS.db.cap) end
    if W.scaleSlider then W.scaleSlider:SetValue(NS.db.scale * 100) end
    UI.syncing = false

    if W.capSlider then
        W.capSlider.valueText:SetText(tostring(NS.db.cap))
    end
    if W.scaleSlider then
        local percent = math.floor(NS.db.scale * 100 + 0.5)
        W.scaleSlider.valueText:SetText(percent .. "%")
    end
end

function UI.UpdateOptions()
    if not W.panel or not W.panel:IsShown() then return end

    local count = NS.state.count or 0
    local cap = NS.db.cap or 0
    local excess = NS.state.excess or 0

    if W.current then
        W.current:SetText(L.CURRENT_LINE:format(count))
        if count > cap then
            ink(W.current, C.bad)
        elseif count == 0 then
            ink(W.current, C.dim)
        else
            ink(W.current, C.text)
        end
    end

    if W.excess then
        W.excess:SetText(L.EXCESS_LINE:format(excess))
        ink(W.excess, excess > 0 and C.warn or C.good)
    end

    if W.status then
        local text, r, g, b = NS:GetStatus()
        W.status:SetText(text)
        W.status:SetTextColor(r, g, b)
    end

    if W.capSlider then W.capSlider.valueText:SetText(tostring(cap)) end
    if W.scaleSlider then
        W.scaleSlider.valueText:SetText(string.format("%d%%", math.floor(NS.db.scale * 100 + 0.5)))
    end
end

function UI.Update()
    local button = UI.button
    if not button then return end

    local count = NS.state.count or 0
    local cap = NS.db.cap or 0
    local over = count > cap

    local size
    if count >= 1000 then
        size = 15
    elseif count >= 100 then
        size = 17
    else
        size = 20
    end

    local color
    if UI.flashUntil and GetTime() < UI.flashUntil then
        color = C.good
    elseif over then
        color = C.bad
    elseif count == 0 then
        color = C.dim
    else
        color = C.text
    end

    button.count:SetFont(M.numberFont or FONT, size, "OUTLINE")
    button.count:SetText(tostring(count))
    ink(button.count, color)
    button.countBadge:SetWidth(count >= 1000 and 46 or (count >= 100 and 40 or 34))
    button.offBadge:SetShown(not NS.db.enabled)

    button.alerting = over and NS.db.enabled and not NS.state.inCombat
    button.alertGlow:SetShown(button.alerting)
    if not button.alerting then
        button.alertGlow:SetAlpha(0)
    end

    if W.panel and W.panel:IsShown() then
        UI.UpdateOptions()
    end
end

function UI.Flash()
    UI.flashUntil = GetTime() + 0.28
    UI.Update()
    C_Timer.After(0.3, function()
        UI.flashUntil = nil
        UI.Update()
    end)
end

function UI.ShowTooltip()
    local button = UI.button
    if not button then return end

    local count = NS.state.count or 0
    local cap = NS.db.cap or 0
    local status, sr, sg, sb = NS:GetStatus()

    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L.TITLE, C.text[1], C.text[2], C.text[3])
    GameTooltip:AddDoubleLine(L.TIP_COUNT, tostring(count), 1, 1, 1, C.text[1], C.text[2], C.text[3])
    GameTooltip:AddDoubleLine(L.TIP_CAP, tostring(cap), 1, 1, 1, C.label[1], C.label[2], C.label[3])
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L.TIP_LEFT, C.label[1], C.label[2], C.label[3])
    GameTooltip:AddLine(L.TIP_RIGHT, C.label[1], C.label[2], C.label[3])
    GameTooltip:AddLine(L.TIP_DRAG, C.dim[1], C.dim[2], C.dim[3])
    if NS.db.locked then
        GameTooltip:AddLine(L.TIP_LOCKED, C.accent[1], C.accent[2], C.accent[3])
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(status, sr, sg, sb, true)
    GameTooltip:Show()
end

function UI.ApplyPosition()
    local button = UI.button
    if not button then return end
    button:ClearAllPoints()
    button:SetPoint(NS.db.point, UIParent, NS.db.point, NS.db.x, NS.db.y)
end

function UI.ApplyScale()
    if UI.button then
        UI.button:SetScale(NS.db.scale)
    end
end

function UI.ApplyVisibility()
    local button = UI.button
    if not button then return end
    if NS.db.hidden then
        GameTooltip:Hide()
        button:Hide()
    else
        button:Show()
    end
end

function UI.SavePosition()
    local button = UI.button
    if not button then return end
    local point, _, _, x, y = button:GetPoint(1)
    if point then
        NS.db.point = point
        NS.db.x = x
        NS.db.y = y
    end
end

function UI.ResetPosition()
    NS.db.scale = 1.0
    NS.db.point = "CENTER"
    NS.db.x = 260
    NS.db.y = -140
    UI.ApplyPosition()
    UI.ApplyScale()
    UI.SyncControls()
    NS:Refresh()
end

function UI.OpenOptions()
    if not W.panel then return end
    W.panel:Show()
    W.panel:Raise()
    UI.SyncControls()
    UI.UpdateOptions()
end

function UI.ToggleOptions()
    if not W.panel then return end
    if W.panel:IsShown() then
        W.panel:Hide()
    else
        UI.OpenOptions()
    end
end

function UI.IsOptionsShown()
    return W.panel and W.panel:IsShown()
end

function SoulShardKeeper_OnCompartmentClick()
    if NS and NS.OpenOptions then
        NS:OpenOptions()
    end
end
