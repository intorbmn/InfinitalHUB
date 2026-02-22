-- ============================================================
--   fnnguyen Hub  |  hub_ui.lua
--   Modern dark GUI launcher - tự động detect game & load script
-- ============================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local HttpService  = game:GetService("HttpService")
local player       = Players.LocalPlayer

-- ========== CONFIG (được truyền vào từ loader) ==========
-- HUB_CONFIG được inject bởi loader.lua trước khi load file này
local HUB_CONFIG  = _G.HUB_CONFIG or {}
local BASE_URL    = HUB_CONFIG.base_url    or ""
local REMOTE_CFG  = HUB_CONFIG.remote_cfg  or {}
local HUB_VERSION = REMOTE_CFG.version     or "1.0.0"
local HUB_NAME    = REMOTE_CFG.hub_name    or "fnnguyen Hub"
local HUB_AUTHOR  = REMOTE_CFG.author      or "fnnguyen"
local DISCORD     = REMOTE_CFG.discord     or ""
local GAMES_LIST  = REMOTE_CFG.games       or {}

-- ========== THEME ==========
local T = {
    bg          = Color3.fromRGB(12,  12,  18),
    surface     = Color3.fromRGB(20,  20,  30),
    surface2    = Color3.fromRGB(28,  28,  42),
    border      = Color3.fromRGB(45,  45,  65),
    accent      = Color3.fromRGB(99,  102, 241),   -- indigo
    accentHover = Color3.fromRGB(118, 120, 255),
    accentDim   = Color3.fromRGB(40,  42,  100),
    green       = Color3.fromRGB(34,  197, 94),
    red         = Color3.fromRGB(239, 68,  68),
    yellow      = Color3.fromRGB(234, 179, 8),
    text        = Color3.fromRGB(240, 240, 255),
    textSub     = Color3.fromRGB(140, 140, 170),
    textDim     = Color3.fromRGB(80,  80,  110),
    white       = Color3.new(1, 1, 1),
}

-- ========== HELPERS ==========
local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end
local function stroke(p, col, thick)
    local s = Instance.new("UIStroke", p)
    s.Color = col or T.border; s.Thickness = thick or 1
    return s
end
local function pad(p, t, r, b, l)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingRight  = UDim.new(0, r or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, l or 0)
end
local function lbl(parent, text, size, color, bold, xa)
    local l = Instance.new("TextLabel", parent)
    l.Text = text; l.TextSize = size or 14
    l.TextColor3 = color or T.text
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, size and size + 6 or 20)
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextWrapped = true
    return l
end
local function frame(parent, size, pos, bg, transp)
    local f = Instance.new("Frame", parent)
    f.Size = size; f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = bg or T.surface
    f.BackgroundTransparency = transp or 0
    f.BorderSizePixel = 0
    return f
end
local function tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.2,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end
local function gradientH(parent, c0, c1)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = 90
    return g
end

-- ========== DETECT CURRENT GAME ==========
local function detectGame()
    local placeId = game.PlaceId
    for _, g in ipairs(GAMES_LIST) do
        if g.place_id == placeId then return g end
    end
    return nil
end

-- ========== LOAD GAME SCRIPT ==========
local function loadGameScript(gameEntry)
    if not gameEntry or not gameEntry.script_url then return end
    local url = BASE_URL .. gameEntry.script_url
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        warn("[Hub] Không load được script: " .. tostring(result))
        return
    end
    local fn, err = loadstring(result)
    if not fn then
        warn("[Hub] Lỗi compile: " .. tostring(err))
        return
    end
    local ok2, err2 = pcall(fn)
    if not ok2 then
        warn("[Hub] Lỗi runtime: " .. tostring(err2))
    end
end

-- ========== BUILD GUI ==========
-- Xóa hub cũ nếu có
local oldGui = player.PlayerGui:FindFirstChild("fnnguyen_Hub")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "fnnguyen_Hub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999

-- ===== BACKDROP (blur overlay khi mở) =====
local backdrop = frame(gui, UDim2.new(1,0,1,0), nil, Color3.new(0,0,0), 0.5)
backdrop.ZIndex = 1

-- ===== MAIN WINDOW =====
local WIN_W, WIN_H = 520, 360
local win = frame(gui,
    UDim2.new(0, WIN_W, 0, WIN_H),
    UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
    T.bg)
win.ZIndex = 2
corner(win, 14)
stroke(win, T.border, 1)

-- Drop shadow illusion
local shadow = frame(gui,
    UDim2.new(0, WIN_W+30, 0, WIN_H+30),
    UDim2.new(0.5, -(WIN_W+30)/2, 0.5, -(WIN_H+30)/2),
    Color3.new(0,0,0), 0.5)
shadow.ZIndex = 1
corner(shadow, 18)

-- ===== SIDEBAR =====
local sidebar = frame(win, UDim2.new(0,170,1,0), nil, T.surface)
sidebar.ZIndex = 3
corner(sidebar, 14)
-- Mask right side corners
local sidebarMask = frame(win, UDim2.new(0,14,1,0), UDim2.new(0,156,0,0), T.surface)
sidebarMask.ZIndex = 3

-- Logo area
local logoArea = frame(sidebar, UDim2.new(1,0,0,110), nil, Color3.new(0,0,0), 1)
logoArea.ZIndex = 4

-- Gradient accent bar at top of sidebar
local accentBar = frame(sidebar, UDim2.new(1,0,0,3), nil, T.accent)
accentBar.ZIndex = 5
gradientH(accentBar,
    Color3.fromRGB(99, 102, 241),
    Color3.fromRGB(168, 85, 247))

-- Hub icon (emoji as TextLabel)
local hubIcon = Instance.new("TextLabel", logoArea)
hubIcon.Size = UDim2.new(1,0,0,52)
hubIcon.Position = UDim2.new(0,0,0,18)
hubIcon.BackgroundTransparency = 1
hubIcon.Text = "🐝"
hubIcon.TextSize = 36
hubIcon.Font = Enum.Font.GothamBold
hubIcon.TextXAlignment = Enum.TextXAlignment.Center
hubIcon.ZIndex = 6

local hubNameLbl = Instance.new("TextLabel", logoArea)
hubNameLbl.Size = UDim2.new(1,-16,0,20)
hubNameLbl.Position = UDim2.new(0,8,0,66)
hubNameLbl.BackgroundTransparency = 1
hubNameLbl.Text = HUB_NAME
hubNameLbl.TextSize = 13
hubNameLbl.Font = Enum.Font.GothamBold
hubNameLbl.TextColor3 = T.text
hubNameLbl.TextXAlignment = Enum.TextXAlignment.Center
hubNameLbl.ZIndex = 6

local hubVerLbl = Instance.new("TextLabel", logoArea)
hubVerLbl.Size = UDim2.new(1,-16,0,16)
hubVerLbl.Position = UDim2.new(0,8,0,86)
hubVerLbl.BackgroundTransparency = 1
hubVerLbl.Text = "v" .. HUB_VERSION .. " by " .. HUB_AUTHOR
hubVerLbl.TextSize = 10
hubVerLbl.Font = Enum.Font.Gotham
hubVerLbl.TextColor3 = T.textDim
hubVerLbl.TextXAlignment = Enum.TextXAlignment.Center
hubVerLbl.ZIndex = 6

-- Divider
local div1 = frame(sidebar, UDim2.new(1,-24,0,1), UDim2.new(0,12,0,108), T.border)
div1.ZIndex = 6

-- Nav items
local NAV_ITEMS = {
    { icon = "🎮", label = "Games",   id = "games"   },
    { icon = "⚙️",  label = "Settings", id = "settings" },
    { icon = "💬", label = "Discord", id = "discord"  },
}
local navContainer = frame(sidebar, UDim2.new(1,0,0,150), UDim2.new(0,0,0,116))
navContainer.ZIndex = 5
local navList = Instance.new("UIListLayout", navContainer)
navList.Padding = UDim.new(0,2)
navList.SortOrder = Enum.SortOrder.LayoutOrder

local activeNavId = "games"
local navBtns = {}

local function setNavActive(id)
    activeNavId = id
    for nid, btn in pairs(navBtns) do
        local isActive = nid == id
        tween(btn, {BackgroundColor3 = isActive and T.accentDim or Color3.new(0,0,0)}, 0.15)
        btn.BackgroundTransparency = isActive and 0 or 1
        local il = btn:FindFirstChild("IconLabel")
        local tl = btn:FindFirstChild("TextLabel")
        if il then il.TextColor3 = isActive and T.accentHover or T.textSub end
        if tl then tl.TextColor3 = isActive and T.text or T.textSub end
    end
end

for i, nav in ipairs(NAV_ITEMS) do
    local btn = frame(navContainer, UDim2.new(1,-16,0,34), nil, T.accentDim)
    btn.Position = UDim2.new(0,8,0,0)
    btn.BackgroundTransparency = 1
    btn.ZIndex = 6
    btn.LayoutOrder = i
    corner(btn, 7)

    local iconL = Instance.new("TextLabel", btn)
    iconL.Name = "IconLabel"
    iconL.Size = UDim2.new(0,24,1,0)
    iconL.Position = UDim2.new(0,10,0,0)
    iconL.BackgroundTransparency = 1
    iconL.Text = nav.icon
    iconL.TextSize = 16
    iconL.Font = Enum.Font.Gotham
    iconL.TextColor3 = T.textSub
    iconL.TextXAlignment = Enum.TextXAlignment.Center
    iconL.ZIndex = 7

    local textL = Instance.new("TextLabel", btn)
    textL.Size = UDim2.new(1,-44,1,0)
    textL.Position = UDim2.new(0,38,0,0)
    textL.BackgroundTransparency = 1
    textL.Text = nav.label
    textL.TextSize = 13
    textL.Font = Enum.Font.GothamBold
    textL.TextColor3 = T.textSub
    textL.TextXAlignment = Enum.TextXAlignment.Left
    textL.ZIndex = 7

    -- Invisible click button
    local clickBtn = Instance.new("TextButton", btn)
    clickBtn.Size = UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 8
    navBtns[nav.id] = btn

    clickBtn.MouseEnter:Connect(function()
        if activeNavId ~= nav.id then
            tween(btn, {BackgroundTransparency = 0.7}, 0.1)
            btn.BackgroundColor3 = T.surface2
        end
    end)
    clickBtn.MouseLeave:Connect(function()
        if activeNavId ~= nav.id then
            tween(btn, {BackgroundTransparency = 1}, 0.1)
        end
    end)
    clickBtn.MouseButton1Click:Connect(function()
        setNavActive(nav.id)
        -- Show/hide pages handled below
        for _, page in pairs(_G._hubPages or {}) do page.Visible = false end
        local targetPage = _G._hubPages and _G._hubPages[nav.id]
        if targetPage then targetPage.Visible = true end
        if nav.id == "discord" and DISCORD ~= "" then
            setclipboard(DISCORD)
            -- Brief feedback
            textL.Text = "Copied!"
            task.delay(1.5, function() textL.Text = nav.label end)
        end
    end)
end
setNavActive("games")

-- Sidebar footer - status dot
local footerArea = frame(sidebar, UDim2.new(1,0,0,30), UDim2.new(0,0,1,-30), Color3.new(0,0,0), 1)
footerArea.ZIndex = 5
local statusDot = frame(footerArea, UDim2.new(0,8,0,8), UDim2.new(0,12,0.5,-4), T.green)
statusDot.ZIndex = 6
corner(statusDot, 4)
local statusLbl = Instance.new("TextLabel", footerArea)
statusLbl.Size = UDim2.new(1,-30,1,0)
statusLbl.Position = UDim2.new(0,26,0,0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Connected"
statusLbl.TextSize = 10
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextColor3 = T.textDim
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.ZIndex = 6

-- ===== CONTENT AREA =====
local content = frame(win, UDim2.new(1,-170,1,-1), UDim2.new(0,170,0,1), Color3.new(0,0,0), 1)
content.ZIndex = 3

-- Title bar
local titleBar = frame(content, UDim2.new(1,0,0,46), nil, Color3.new(0,0,0), 1)
titleBar.ZIndex = 4

local pageTitleLbl = Instance.new("TextLabel", titleBar)
pageTitleLbl.Size = UDim2.new(1,-80,1,0)
pageTitleLbl.Position = UDim2.new(0,20,0,0)
pageTitleLbl.BackgroundTransparency = 1
pageTitleLbl.Text = "Games"
pageTitleLbl.TextSize = 16
pageTitleLbl.Font = Enum.Font.GothamBold
pageTitleLbl.TextColor3 = T.text
pageTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
pageTitleLbl.ZIndex = 5

-- Close button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(1,-36,0.5,-14)
closeBtn.BackgroundColor3 = Color3.fromRGB(60,30,30)
closeBtn.Text = "✕"
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = T.red
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 6
corner(closeBtn, 7)

-- Minimize button
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0,28,0,28)
minBtn.Position = UDim2.new(1,-70,0.5,-14)
minBtn.BackgroundColor3 = Color3.fromRGB(50,45,20)
minBtn.Text = "–"
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.TextColor3 = T.yellow
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 6
corner(minBtn, 7)

-- Separator line under titlebar
local sep = frame(content, UDim2.new(1,-24,0,1), UDim2.new(0,12,0,45), T.border)
sep.ZIndex = 4

-- ===== PAGE CONTAINER =====
local pageContainer = frame(content, UDim2.new(1,0,1,-50), UDim2.new(0,0,0,50), Color3.new(0,0,0), 1)
pageContainer.ZIndex = 3
_G._hubPages = {}

-- ========================================================
--   PAGE: GAMES
-- ========================================================
local gamesPage = frame(pageContainer, UDim2.new(1,0,1,0), nil, Color3.new(0,0,0), 1)
gamesPage.ZIndex = 4
_G._hubPages["games"] = gamesPage

-- Notice banner (if any)
local noticeTxt = REMOTE_CFG.notice or ""
if noticeTxt ~= "" then
    local noticeBanner = frame(gamesPage,
        UDim2.new(1,-24,0,30), UDim2.new(0,12,0,8),
        Color3.fromRGB(40,35,10))
    noticeBanner.ZIndex = 5
    corner(noticeBanner, 6)
    stroke(noticeBanner, T.yellow, 1)
    local noticeL = lbl(noticeBanner, "📢  " .. noticeTxt, 11, T.yellow, false, Enum.TextXAlignment.Left)
    noticeL.Size = UDim2.new(1,-12,1,0)
    noticeL.Position = UDim2.new(0,6,0,0)
    noticeL.ZIndex = 6
end

-- Auto-detect current game banner
local detectedGame = detectGame()
if detectedGame then
    local autoFrame = frame(gamesPage,
        UDim2.new(1,-24,0,38), UDim2.new(0,12, 0, noticeTxt~="" and 46 or 8),
        T.accentDim)
    autoFrame.ZIndex = 5
    corner(autoFrame, 8)
    stroke(autoFrame, T.accent, 1)

    local autoIcon = lbl(autoFrame, detectedGame.icon or "🎮", 18, T.text, true, Enum.TextXAlignment.Center)
    autoIcon.Size = UDim2.new(0,30,1,0)
    autoIcon.ZIndex = 6

    local autoTxtFrame = Instance.new("Frame", autoFrame)
    autoTxtFrame.Size = UDim2.new(1,-120,1,0)
    autoTxtFrame.Position = UDim2.new(0,36,0,0)
    autoTxtFrame.BackgroundTransparency = 1
    autoTxtFrame.ZIndex = 6

    local autoName = lbl(autoTxtFrame, detectedGame.name or "Unknown", 12, T.text, true)
    autoName.Size = UDim2.new(1,0,0,18)
    autoName.Position = UDim2.new(0,0,0,4)
    autoName.ZIndex = 7
    local autoSub = lbl(autoTxtFrame, "✅  Game được nhận diện tự động", 10, T.green)
    autoSub.Size = UDim2.new(1,0,0,14)
    autoSub.Position = UDim2.new(0,0,0,20)
    autoSub.ZIndex = 7

    local autoBtn = Instance.new("TextButton", autoFrame)
    autoBtn.Size = UDim2.new(0,80,0,26)
    autoBtn.Position = UDim2.new(1,-88,0.5,-13)
    autoBtn.BackgroundColor3 = T.accent
    autoBtn.Text = "▶  Load"
    autoBtn.TextSize = 12
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextColor3 = T.white
    autoBtn.BorderSizePixel = 0
    autoBtn.ZIndex = 7
    corner(autoBtn, 6)

    autoBtn.MouseEnter:Connect(function() tween(autoBtn, {BackgroundColor3 = T.accentHover}, 0.1) end)
    autoBtn.MouseLeave:Connect(function() tween(autoBtn, {BackgroundColor3 = T.accent}, 0.1) end)
    autoBtn.MouseButton1Click:Connect(function()
        autoBtn.Text = "Loading..."
        autoBtn.BackgroundColor3 = T.accentDim
        -- Animate cửa sổ hub ra
        tween(win, {Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2 - 20), BackgroundTransparency = 0}, 0.3)
        tween(backdrop, {BackgroundTransparency = 1}, 0.3)
        task.delay(0.3, function()
            tween(win, {Size = UDim2.new(0,WIN_W,0,0)}, 0.2, Enum.EasingStyle.Back)
            task.delay(0.22, function()
                gui:Destroy()
                loadGameScript(detectedGame)
            end)
        end)
    end)
end

-- Games list scroll
local gamesScrollTop = (noticeTxt~="" and 46 or 8) + (detectedGame and 54 or 0)
local gamesScroll = Instance.new("ScrollingFrame", gamesPage)
gamesScroll.Size = UDim2.new(1,-24, 1, -gamesScrollTop - 10)
gamesScroll.Position = UDim2.new(0,12,0,gamesScrollTop + 4)
gamesScroll.BackgroundTransparency = 1
gamesScroll.BorderSizePixel = 0
gamesScroll.ScrollBarThickness = 3
gamesScroll.ScrollBarImageColor3 = T.accent
gamesScroll.ZIndex = 4

local gamesList = Instance.new("UIListLayout", gamesScroll)
gamesList.Padding = UDim.new(0,6)
gamesList.SortOrder = Enum.SortOrder.LayoutOrder

local currentPlaceId = game.PlaceId

for i, g in ipairs(GAMES_LIST) do
    local isCurrentGame = g.place_id == currentPlaceId
    local isActive = g.status == "active"

    local card = frame(gamesScroll, UDim2.new(1,0,0,52), nil,
        isActive and T.surface2 or Color3.fromRGB(20,18,25))
    card.LayoutOrder = i
    card.ZIndex = 5
    corner(card, 8)
    stroke(card, isCurrentGame and T.accent or T.border, isCurrentGame and 1 or 1)

    -- Game icon
    local iconLbl = lbl(card, g.icon or "🎮", 22, T.text, true, Enum.TextXAlignment.Center)
    iconLbl.Size = UDim2.new(0,36,1,0)
    iconLbl.Position = UDim2.new(0,10,0,0)
    iconLbl.ZIndex = 6

    -- Info
    local infoF = Instance.new("Frame", card)
    infoF.Size = UDim2.new(1,-130,1,0)
    infoF.Position = UDim2.new(0,52,0,0)
    infoF.BackgroundTransparency = 1
    infoF.ZIndex = 6

    local nameLbl = lbl(infoF, g.name or "Unknown Game", 13, T.text, true)
    nameLbl.Size = UDim2.new(1,0,0,20)
    nameLbl.Position = UDim2.new(0,0,0,8)
    nameLbl.ZIndex = 7

    local statusColor = isActive and T.green or T.textDim
    local statusText  = isActive and "● Active" or "● Coming Soon"
    if isCurrentGame then statusText = "● Current Game" statusColor = T.accent end
    local statusL = lbl(infoF, statusText, 10, statusColor)
    statusL.Size = UDim2.new(1,0,0,14)
    statusL.Position = UDim2.new(0,0,0,28)
    statusL.ZIndex = 7

    -- Action button
    local btnText  = isCurrentGame and "▶  Load" or (isActive and "▶  Load" or "Soon")
    local btnColor = isCurrentGame and T.accent or (isActive and T.surface or T.border)
    local actionBtn = Instance.new("TextButton", card)
    actionBtn.Size = UDim2.new(0,76,0,28)
    actionBtn.Position = UDim2.new(1,-84,0.5,-14)
    actionBtn.BackgroundColor3 = btnColor
    actionBtn.Text = btnText
    actionBtn.TextSize = 11
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextColor3 = isActive and T.white or T.textDim
    actionBtn.BorderSizePixel = 0
    actionBtn.Active = isActive
    actionBtn.ZIndex = 7
    corner(actionBtn, 6)

    if isActive then
        actionBtn.MouseEnter:Connect(function()
            tween(actionBtn, {BackgroundColor3 = T.accentHover}, 0.1)
        end)
        actionBtn.MouseLeave:Connect(function()
            tween(actionBtn, {BackgroundColor3 = isCurrentGame and T.accent or T.surface}, 0.1)
        end)
        actionBtn.MouseButton1Click:Connect(function()
            actionBtn.Text = "Loading..."
            tween(win, {Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2 - 20)}, 0.3)
            tween(backdrop, {BackgroundTransparency = 1}, 0.3)
            task.delay(0.3, function()
                tween(win, {Size = UDim2.new(0,WIN_W,0,0)}, 0.2, Enum.EasingStyle.Back)
                task.delay(0.22, function()
                    gui:Destroy()
                    loadGameScript(g)
                end)
            end)
        end)
    end
end

task.defer(function()
    gamesScroll.CanvasSize = UDim2.new(0,0,0, gamesList.AbsoluteContentSize.Y + 8)
end)

-- ========================================================
--   PAGE: SETTINGS
-- ========================================================
local settingsPage = frame(pageContainer, UDim2.new(1,0,1,0), nil, Color3.new(0,0,0), 1)
settingsPage.Visible = false
settingsPage.ZIndex = 4
_G._hubPages["settings"] = settingsPage

local function settingRow(parent, yOff, labelTxt, valueText, accent)
    local row = frame(parent, UDim2.new(1,-24,0,40), UDim2.new(0,12,0,yOff), T.surface2)
    row.ZIndex = 5
    corner(row, 7)

    local rowLbl = lbl(row, labelTxt, 12, T.textSub)
    rowLbl.Size = UDim2.new(0.55,0,1,0)
    rowLbl.Position = UDim2.new(0,12,0,0)
    rowLbl.ZIndex = 6

    local valLbl = lbl(row, valueText or "", 12, accent or T.text, true, Enum.TextXAlignment.Right)
    valLbl.Size = UDim2.new(0.4,0,1,0)
    valLbl.Position = UDim2.new(0.55,0,0,0)
    valLbl.ZIndex = 6
    return row, valLbl
end

local sTitle = lbl(settingsPage, "Hub Info", 13, T.textSub, true)
sTitle.Size = UDim2.new(1,-24,0,18)
sTitle.Position = UDim2.new(0,12,0,10)
sTitle.ZIndex = 5

settingRow(settingsPage, 32,  "Hub Version",  "v" .. HUB_VERSION,  T.accent)
settingRow(settingsPage, 78,  "Author",        HUB_AUTHOR,         T.text)
settingRow(settingsPage, 124, "Game Detected", detectedGame and detectedGame.name or "None", detectedGame and T.green or T.textDim)
settingRow(settingsPage, 170, "Place ID",      tostring(game.PlaceId), T.textSub)
settingRow(settingsPage, 216, "Executor",      identifyexecutor and identifyexecutor() or "Unknown", T.textSub)

-- ========================================================
--   PAGE: DISCORD
-- ========================================================
local discordPage = frame(pageContainer, UDim2.new(1,0,1,0), nil, Color3.new(0,0,0), 1)
discordPage.Visible = false
discordPage.ZIndex = 4
_G._hubPages["discord"] = discordPage

local dcCenter = frame(discordPage, UDim2.new(1,-40,0,120), UDim2.new(0,20,0,40), T.surface2)
dcCenter.ZIndex = 5
corner(dcCenter, 10)
stroke(dcCenter, T.border, 1)

local dcIcon = lbl(dcCenter, "💬", 32, T.text, true, Enum.TextXAlignment.Center)
dcIcon.Size = UDim2.new(1,0,0,44)
dcIcon.Position = UDim2.new(0,0,0,12)
dcIcon.ZIndex = 6

local dcTitle = lbl(dcCenter, "Join Discord", 15, T.text, true, Enum.TextXAlignment.Center)
dcTitle.Size = UDim2.new(1,0,0,20)
dcTitle.Position = UDim2.new(0,0,0,58)
dcTitle.ZIndex = 6

if DISCORD ~= "" then
    local dcLinkBtn = Instance.new("TextButton", dcCenter)
    dcLinkBtn.Size = UDim2.new(0.7,0,0,32)
    dcLinkBtn.Position = UDim2.new(0.15,0,0,86)
    dcLinkBtn.BackgroundColor3 = Color3.fromRGB(88,101,242)
    dcLinkBtn.Text = "📋  Copy Link"
    dcLinkBtn.TextSize = 12
    dcLinkBtn.Font = Enum.Font.GothamBold
    dcLinkBtn.TextColor3 = T.white
    dcLinkBtn.BorderSizePixel = 0
    dcLinkBtn.ZIndex = 7
    corner(dcLinkBtn, 8)
    dcLinkBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, DISCORD)
        dcLinkBtn.Text = "✅  Copied!"
        task.delay(2, function() dcLinkBtn.Text = "📋  Copy Link" end)
    end)
else
    local noDc = lbl(dcCenter, "Discord chưa được thiết lập.", 11, T.textDim, false, Enum.TextXAlignment.Center)
    noDc.Size = UDim2.new(1,0,0,18)
    noDc.Position = UDim2.new(0,0,0,88)
    noDc.ZIndex = 6
end

-- ========================================================
--   CLOSE / MINIMIZE LOGIC
-- ========================================================
local minimized = false
local miniBtn_Y_store

closeBtn.MouseButton1Click:Connect(function()
    tween(win, {Size = UDim2.new(0,WIN_W,0,0), BackgroundTransparency = 1}, 0.2, Enum.EasingStyle.Back)
    tween(backdrop, {BackgroundTransparency = 1}, 0.2)
    task.delay(0.25, function() gui:Destroy() end)
end)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Shrink to just title bar
        tween(win, {Size = UDim2.new(0,WIN_W,0,46)}, 0.25, Enum.EasingStyle.Quad)
        tween(backdrop, {BackgroundTransparency = 1}, 0.2)
        sidebar.Visible = false
        sep.Visible = false
        for _, p in pairs(_G._hubPages) do p.Visible = false end
        minBtn.Text = "□"
    else
        tween(win, {Size = UDim2.new(0,WIN_W,0,WIN_H)}, 0.25, Enum.EasingStyle.Quad)
        tween(backdrop, {BackgroundTransparency = 0.5}, 0.2)
        sidebar.Visible = true
        sep.Visible = true
        -- Show active page
        for pid, p in pairs(_G._hubPages) do
            p.Visible = pid == activeNavId
        end
        minBtn.Text = "–"
    end
end)

-- ========================================================
--   DRAG
-- ========================================================
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = win.Position
    end
end)
titleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ========================================================
--   PAGE TITLE SYNC
-- ========================================================
local pageTitles = { games="Games", settings="Settings", discord="Discord" }
for nid, btn in pairs(navBtns) do
    local cb = btn:FindFirstChildWhichIsA("TextButton")
    if cb then
        cb.MouseButton1Click:Connect(function()
            pageTitleLbl.Text = pageTitles[nid] or nid
        end)
    end
end

-- ========================================================
--   ENTRANCE ANIMATION
-- ========================================================
win.Size     = UDim2.new(0, WIN_W, 0, 0)
win.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 30)
backdrop.BackgroundTransparency = 1
task.defer(function()
    tween(backdrop, {BackgroundTransparency = 0.5}, 0.25)
    tween(win, {
        Size     = UDim2.new(0,WIN_W,0,WIN_H),
        Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end)
