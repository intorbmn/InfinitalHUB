local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VIM        = game:GetService("VirtualInputManager")
local player     = Players.LocalPlayer

-- ================= CONSTANTS =================
local PART_NAME = "HeadPlatform_" .. player.UserId
local CONFIG = { maxWalkSpeed = 80, maxJumpPower = 200, checkInterval = 0.2 }
local COL_ON  = Color3.fromRGB(0, 140, 60)
local COL_OFF = Color3.fromRGB(60, 60, 60)
local COL_TOKEN_ACTIVE = Color3.fromRGB(0, 120, 180)
local COL_FIELD_ACTIVE = Color3.fromRGB(0, 150, 60)

-- ================= STATE =================
local state = {
	scriptEnabled = true,
	walkSpeed = 65, jumpPower = 90, khoangcachpart = 5,
	keepWalkSpeed = true, minimized = false, isAnimating = false,
	autoFarm = false, activeTab = "main", farmPanel = "token",
}
local originalTransparency = {}

-- ================= TOKEN DATA =================
local ALL_TOKENS = {
	-- ====== ITEMS TOKENs ======
	{ id = "rbxassetid://183390139",  name = "Cog",             emoji = "⚙️", priority = false },
	{ id = "rbxassetid://1674871631", name = "Ticket",          emoji = "🎫", priority = true },
	{ id = "rbxassetid://1838129169", name = "Gumdrop",         emoji = "", priority = false },
	{ id = "rbxassetid://3012679515", name = "Coconut",         emoji = "🥥", priority = false },
	{ id = "rbxassetid://6087969886", name = "Snow Flake",      emoji = "❄️", priority = true },
	--Micro Converter
	{ id = "rbxassetid://8277901755", name = "Honey Suckle",    emoji = "", priority = false },
	--Whirligig
	--Field Dice
	{ id = "rbxassetid://8054996680", name = "Smooth Dice",     emoji = "🎲", priority = false },
	{ id = "rbxassetid://8055428094", name = "Loaded Dice",     emoji = "🎲", priority = false },
	{ id = "rbxassetid://3080740120", name = "Jelly Bean",      emoji = "🫘", priority = false },
	{ id = "rbxassetid://2495935291", name = "Red Extract",     emoji = "🧪", priority = false },
	--Blue Extract
	{ id = "rbxassetid://2542899798", name = "Glitter",         emoji = "✨", priority = false },
	{ id = "rbxassetid://2504978518", name = "Glue",            emoji = "🧴", priority = false },
	--Oil
	{ id = "rbxassetid://2584584968", name = "Enzymes",         emoji = "🧪", priority = false },
	--Tropical Drink
	{ id = "rbxassetid://3030569073", name = "Cloud Vial",      emoji = "☁️", priority = false },
	{ id = "rbxassetid://3036899811", name = "Robo Pass",       emoji = "🤖", priority = false },
	{ id = "rbxassetid://2028574353", name = "Treat",           emoji = "🦴", priority = false },
	--Sunflower Seed
	{ id = "rbxassetid://1952740625", name = "Strawberry",      emoji = "🍓", priority = false },
	{ id = "rbxassetid://1952796032", name = "Pineapple",       emoji = "🍍", priority = false },
	{ id = "rbxassetid://2028453802", name = "Blue Berry",      emoji = "🫐", priority = true },
	{ id = "rbxassetid://4483236276", name = "Blitterberry",    emoji = "🫐", priority = false },
	--Moon Charm
	{ id = "rbxassetid://6077173317", name = "Gingerbread Bear",emoji = "🍪", priority = true },
	--{ id = "rbxassetid://8058047989", name = "Red Balloon",     emoji = "🎈", priority = false },
	{ id = "rbxassetid://1471882621", name = "Royal Jelly",     emoji = "🍯", priority = false },
	{ id = "rbxassetid://2319943273", name = "Star Jelly",      emoji = "⭐", priority = true },
	{ id = "rbxassetid://1472135114", name = "Honey",           emoji = "🍯", priority = false },

	-- ====== SKILL TOKENS ======
	{ id = "rbxassetid://1629547638", name = "Link",            emoji = "🔗", priority = true },
	{ id = "rbxassetid://65867881",   name = "Haste",           emoji = "💨", priority = false },
	{ id = "rbxassetid://1442859163", name = "Red Boost",       emoji = "🔴", priority = false },
	{ id = "rbxassetid://1442863423", name = "Blue Boost",      emoji = "🔵", priority = false },
	{ id = "rbxassetid://1442725244", name = "Bomb",            emoji = "💣", priority = false },
	{ id = "rbxassetid://1442764904", name = "Bomb Plus",       emoji = "💥", priority = false },
	{ id = "rbxassetid://1472256444", name = "Baby's Love",     emoji = "💖", priority = false },
	{ id = "rbxassetid://2499540966", name = "Mark",            emoji = "✏️", priority = false },
	{ id = "rbxassetid://253828517",  name = "Melody",          emoji = "🎵", priority = false },
	{ id = "rbxassetid://1629649299", name = "Focus",           emoji = "🔍", priority = false },
	{ id = "rbxassetid://8173559749", name = "Target Practice", emoji = "🎯", priority = false },
	{ id = "rbxassetid://2305425690", name = "Puppy's Love",    emoji = "🐶", priority = false },
	{ id = "rbxassetid://1671281844", name = "Beamstorm",       emoji = "⚡", priority = false },
	{ id = "rbxassetid://8083436978", name = "Blue Balloon",    emoji = "🎈", priority = false },
	{ id = "rbxassetid://2319100769", name = "Fetch",           emoji = "🦮", priority = false },
	{ id = "rbxassetid://4889322534", name = "Fuzz Bombs",      emoji = "🐝", priority = false },
	{ id = "rbxassetid://5877939956", name = "Glitch",          emoji = "👾", priority = false },
	{ id = "rbxassetid://177997841",  name = "Glob",            emoji = "🟢", priority = false },
	{ id = "rbxassetid://1839454544", name = "Gummy Storm",     emoji = "🍬", priority = false },
	{ id = "rbxassetid://2319083910", name = "Impale",          emoji = "🗡️", priority = false },
	{ id = "rbxassetid://4519549299", name = "Inferno",         emoji = "🔥", priority = false },
	{ id = "rbxassetid://2000457501", name = "Inspire",         emoji = "✨", priority = false },
	{ id = "rbxassetid://3080529618", name = "Jelly Bean",      emoji = "🫘", priority = false },
	{ id = "rbxassetid://4528379338", name = "Mark Surge",      emoji = "📈", priority = false },
	{ id = "rbxassetid://5877998606", name = "Mind Hack",       emoji = "🧠", priority = false },
	{ id = "rbxassetid://4889470194", name = "Pollen Haze",     emoji = "🌸", priority = false },
	{ id = "rbxassetid://1874564120", name = "Pulse",           emoji = "💫", priority = false },
	{ id = "rbxassetid://3582501342", name = "Rain Call",       emoji = "🌧️", priority = false },
	{ id = "rbxassetid://1104415222", name = "Scratch",         emoji = "🐾", priority = false },
	{ id = "rbxassetid://4528414666", name = "Summon Frog",     emoji = "🐸", priority = false },
	{ id = "rbxassetid://8083943936", name = "Surprise Party",  emoji = "🎉", priority = false },
	{ id = "rbxassetid://3582519526", name = "Tornado",         emoji = "🌪️", priority = false },
	{ id = "rbxassetid://4519523935", name = "Triangulate",     emoji = "🔺", priority = false },
}

-- BUG FIX 1: tokenPriorityMap[id] = false là falsy -> "if tokenPriorityMap[tex]" không phân biệt
-- được token priority=false với token không có trong map.
-- Fix: dùng tokenPriorityMap[id] = true/nil thay vì true/false
-- Chỉ insert vào map khi priority = true
local tokenPriorityMap, tokenNameMap = {}, {}
for _, t in ipairs(ALL_TOKENS) do
	if t.priority then
		tokenPriorityMap[t.id] = true  -- chỉ mark token ưu tiên, nil = không ưu tiên
	end
	tokenNameMap[t.id] = t.emoji .. " " .. t.name
end

-- ================= FIELD DATA =================
local FIELDS = {
	["Sunflower Field"]   = {pos = Vector3.new(-209.0, 1.5, 176.6),     sizeX = 95,  sizeZ = 145},
	["Dandelion Field"]   = {pos = Vector3.new(-30.7, 1.5, 220.6),      sizeX = 160, sizeZ = 90},
	["Mushroom Field"]    = {pos = Vector3.new(-89.7, 2.0, 111.7),      sizeX = 140, sizeZ = 105},
	["Blue Flower Field"] = {pos = Vector3.new(146.9, 2.1, 99.3),       sizeX = 185, sizeZ = 85},
	["Clover Field"]      = {pos = Vector3.new(157.5, 31.6, 196.4),     sizeX = 120, sizeZ = 130},
	["Spider Field"]      = {pos = Vector3.new(-43.5, 18.1, -13.6),     sizeX = 130, sizeZ = 125},
	["Strawberry Field"]  = {pos = Vector3.new(-178.2, 18.1, -9.9),     sizeX = 105, sizeZ = 120},
	["Bamboo Field"]      = {pos = Vector3.new(133.0, 18.2, -25.6),     sizeX = 170, sizeZ = 90},
	["Pineapple Patch"]   = {pos = Vector3.new(256.5, 66.1, -207.5),    sizeX = 150, sizeZ = 110},
	["Cactus Field"]      = {pos = Vector3.new(-188.5, 65.5, -101.6),   sizeX = 150, sizeZ = 80},
	["Pumpkin Patch"]     = {pos = Vector3.new(-138.5, 65.5, -183.8),   sizeX = 150, sizeZ = 85},
	["Pine Tree Forest"]  = {pos = Vector3.new(-328.7, 65.5, -187.3),   sizeX = 105, sizeZ = 135},
	["Rose Field"]        = {pos = Vector3.new(-327.5, 17.6, 129.5),    sizeX = 140, sizeZ = 100},
	["Mountain Top Field"]= {pos = Vector3.new(77.7, 173.5, -165.4),    sizeX = 110, sizeZ = 125},
	["Stump Field"]       = {pos = Vector3.new(424.5, 94.4, -174.8),    sizeX = 130, sizeZ = 130},
	["Coconut Field"]     = {pos = Vector3.new(-254.5, 69.0, 469.5),    sizeX = 125, sizeZ = 90},
	["Pepper Patch"]      = {pos = Vector3.new(-488.8, 120.7, 535.7),   sizeX = 100, sizeZ = 125},
	["Ant Field"]         = {pos = Vector3.new(95.9, 29.8, 594.6),      sizeX = 140, sizeZ = 60},
	["Hub Field"]         = {pos = Vector3.new(0.0, 0.6, -10000.0),     sizeX = 135, sizeZ = 135},
	["Mixed Brick Field"] = {pos = Vector3.new(-47118.9, 289.6, 209.9), sizeX = 85,  sizeZ = 85},
	["Blue Brick Field"]  = {pos = Vector3.new(-47004.1, 289.6, 90.2),  sizeX = 85,  sizeZ = 85},
	["Red Brick Field"]   = {pos = Vector3.new(-47104.9, 289.6, -31.8), sizeX = 85,  sizeZ = 85},
	["White Brick Field"] = {pos = Vector3.new(-47010.1, 289.6, -156.9),sizeX = 85,  sizeZ = 85},
}

local selectedFields = {}

local fieldNameList = {
	"Sunflower Field", "Dandelion Field", "Mushroom Field", "Blue Flower Field",
	"Clover Field", "Spider Field", "Strawberry Field", "Bamboo Field",
	"Pineapple Patch", "Cactus Field", "Pumpkin Patch", "Pine Tree Forest",
	"Rose Field", "Mountain Top Field", "Stump Field", "Coconut Field",
	"Pepper Patch", "Ant Field", "Hub Field",
	"Mixed Brick Field", "Blue Brick Field", "Red Brick Field", "White Brick Field",
}

-- ================= SERVICES =================
local WTsFolder  = workspace:WaitForChild("Particles"):WaitForChild("WTs")
local npcBee     = workspace:WaitForChild("NPCBees")
local monsters   = workspace:WaitForChild("Monsters")
local sticker    = workspace:WaitForChild("HiddenStickers")
local Collectibles = workspace:WaitForChild("Collectibles")

-- ================= UI HELPERS =================
local function createUICorner(parent, r)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, r or 5)
	return c
end

local function applyStyle(e, bgColor)
	e.BackgroundColor3 = bgColor or Color3.fromRGB(55, 55, 55)
	e.TextColor3 = Color3.new(1,1,1)
	e.Font = Enum.Font.Gotham
	e.TextSize = 14
	if e:IsA("TextLabel") then e.BackgroundTransparency = 1 end
	createUICorner(e)
end

-- BUG FIX 2: makeBoolBtn signature cũ có param "knobPosX" thừa gây nhầm lẫn khi gọi.
-- Xóa knobPosX, dùng AnchorPoint để định vị knob chính xác (như bool_btn_v2).
local function makeBoolBtn(parent, pos, size, defaultValue, onChange)
	local container = Instance.new("Frame")
	container.Position = pos
	container.Size = size
	container.BackgroundTransparency = 1
	container.Parent = parent

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 1, 0)
	track.Position = UDim2.new(0, 0, 0, 0)
	track.BorderSizePixel = 0
	track.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(80, 80, 80)
	track.Parent = container
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	-- AnchorPoint luôn là (0, 0.5), KHÔNG thay đổi
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Size = UDim2.new(0, 0, 1, -4)
	knob.BorderSizePixel = 0
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local arc = Instance.new("UIAspectRatioConstraint", knob)
	arc.AspectRatio = 1
	arc.AspectType = Enum.AspectType.ScaleWithParentSize
	arc.DominantAxis = Enum.DominantAxis.Height

	local value = defaultValue or false

	-- Tính vị trí X của knob dựa trên AbsoluteSize của track
	-- knobW = chiều cao track - 4px (do Size height = 1,-4)
	-- OFF: X = 2px từ trái
	-- ON:  X = trackWidth - knobW - 2px từ trái
	local function getKnobPos(on)
		local trackW = track.AbsoluteSize.X
		local knobW  = track.AbsoluteSize.Y - 4
		if on then
			return UDim2.new(0, trackW - knobW - 2, 0.5, 0)
		else
			return UDim2.new(0, 2, 0.5, 0)
		end
	end

	local function setToggle(on, animate)
		value = on
		local knobPos  = getKnobPos(on)
		local trackColor = on and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(80, 80, 80)

		if animate then
			local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(knob,  info, {Position = knobPos}):Play()
			TweenService:Create(track, info, {BackgroundColor3 = trackColor}):Play()
		else
			knob.Position = knobPos
			track.BackgroundColor3 = trackColor
		end

		if onChange then onChange(value) end
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = container
	btn.MouseButton1Click:Connect(function()
		setToggle(not value, true)
	end)

	-- Đợi 1 frame để AbsoluteSize có giá trị thực
	task.defer(function()
		setToggle(value, false)
	end)

	return container, function(newVal) setToggle(newVal, true) end
end

local function makeBtn(parent, pos, size, text)
	local b = Instance.new("TextButton", parent)
	b.Position, b.Size, b.Text = pos, size, text
	applyStyle(b); return b
end

local function makeBox(parent, pos, size, ph)
	local b = Instance.new("TextBox", parent)
	b.Position, b.Size = pos, size
	b.PlaceholderText = ph
	b.ClearTextOnFocus = false
	b.Text = ""
	applyStyle(b); return b
end

local function makeLabel(parent, pos, size, text)
	local l = Instance.new("TextLabel", parent)
	l.Position, l.Size, l.Text = pos, size, text
	l.TextColor3 = Color3.new(1,1,1)
	l.BackgroundColor3 = Color3.fromRGB(25,25,25)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 14
	l.TextXAlignment = Enum.TextXAlignment.Center
	applyStyle(l); return l
end

local function makeBeeFrame(parent, beeName)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0,144,0,72)
	frame.BackgroundColor3 = Color3.fromRGB(65,65,65)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.5
	createUICorner(frame)
	local lbl = Instance.new("TextLabel", frame)
	lbl.Position = UDim2.new(0,6,0,4); lbl.Size = UDim2.new(0,96,0,30)
	lbl.BackgroundTransparency = 1; lbl.Text = beeName
	lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
	local status = Instance.new("TextLabel", frame)
	status.Position = UDim2.new(1,-42,0,4); status.Size = UDim2.new(0,36,0,30)
	status.Text = ""; status.TextColor3 = Color3.new(1,1,1)
	status.Font = Enum.Font.GothamBold; status.TextSize = 14
	createUICorner(status)
	local locBtn = makeBtn(frame, UDim2.new(0,6,0,38), UDim2.new(1,-12,0,28), "Locate")
	return frame, status, locBtn
end

-- ================= GUI =================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PlayerControlUI"; gui.ResetOnSpawn = false

local frame0 = Instance.new("Frame", gui)
frame0.Size = UDim2.new(0,500,0,335)
frame0.Position = UDim2.fromScale(0.2, 0.075)
frame0.BackgroundTransparency = 1

local title = Instance.new("TextLabel", frame0)
title.Size = UDim2.new(1,0,0,35); title.Position = UDim2.new(0,0,0,0)
title.BackgroundColor3 = Color3.fromRGB(30,30,30)
title.Text = "fnnguyen's Script - Bee Swarm Simulator"
title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold
title.TextSize = 16; title.TextTransparency = 0.2
title.TextXAlignment = Enum.TextXAlignment.Left
createUICorner(title)

local closeBtn = makeBtn(title, UDim2.new(1,-35,0,2), UDim2.new(0,30,0,30), "X")
closeBtn.BackgroundColor3 = Color3.fromRGB(180,50,50); closeBtn.Font = Enum.Font.GothamBold

local minimizeBtn = makeBtn(title, UDim2.new(1,-70,0,2), UDim2.new(0,30,0,30), "-")
minimizeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100); minimizeBtn.Font = Enum.Font.GothamBold

local tabRow = Instance.new("Frame", frame0)
tabRow.Size = UDim2.new(1,0,0,30); tabRow.Position = UDim2.new(0,0,0,35)
tabRow.BackgroundColor3 = Color3.fromRGB(25,25,25); tabRow.BorderSizePixel = 0

local tabMainBtn = Instance.new("TextButton", tabRow)
tabMainBtn.Size = UDim2.new(0.25,0,1,0); tabMainBtn.Position = UDim2.new(0,0,0,0)
tabMainBtn.Text = "⚙ Main"; tabMainBtn.Font = Enum.Font.GothamBold
tabMainBtn.TextSize = 13; tabMainBtn.TextColor3 = Color3.new(1,1,1)
tabMainBtn.BackgroundColor3 = Color3.fromRGB(60,60,60); tabMainBtn.BorderSizePixel = 0

local tabFarmBtn = Instance.new("TextButton", tabRow)
tabFarmBtn.Size = UDim2.new(0.25,0,1,0); tabFarmBtn.Position = UDim2.new(0.25,0,0,0)
tabFarmBtn.Text = "🍯 Farm"; tabFarmBtn.Font = Enum.Font.GothamBold
tabFarmBtn.TextSize = 13; tabFarmBtn.TextColor3 = Color3.new(1,1,1)
tabFarmBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); tabFarmBtn.BorderSizePixel = 0

local tabMiscBtn = Instance.new("TextButton", tabRow)
tabMiscBtn.Size = UDim2.new(0.25,0,1,0); tabMiscBtn.Position = UDim2.new(0.5,0,0,0)
tabMiscBtn.Text = "Misc"; tabMiscBtn.Font = Enum.Font.GothamBold
tabMiscBtn.TextSize = 13; tabMiscBtn.TextColor3 = Color3.new(1,1,1)
tabMiscBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); tabMiscBtn.BorderSizePixel = 0

local tabSettingBtn = Instance.new("TextButton", tabRow)
tabSettingBtn.Size = UDim2.new(0.25,0,1,0); tabSettingBtn.Position = UDim2.new(0.75,0,0,0)
tabSettingBtn.Text = "Setting"; tabSettingBtn.Font = Enum.Font.GothamBold
tabSettingBtn.TextSize = 13; tabSettingBtn.TextColor3 = Color3.new(1,1,1)
tabSettingBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); tabSettingBtn.BorderSizePixel = 0

local contentFrame = Instance.new("Frame", frame0)
contentFrame.Size = UDim2.new(1,0,0,270); contentFrame.Position = UDim2.new(0,0,0,65)
contentFrame.BackgroundColor3 = Color3.fromRGB(40,40,40); contentFrame.BorderSizePixel = 0
contentFrame.BackgroundTransparency = 0.2; createUICorner(contentFrame)

-- ===== MAIN TAB =====
local mainTab = Instance.new("Frame", contentFrame)
mainTab.Size = UDim2.new(1,0,1,0); mainTab.BackgroundTransparency = 1; mainTab.Visible = true

local beeContainer = Instance.new("Frame", mainTab)
beeContainer.Name = "BeeContainer"
beeContainer.Position = UDim2.new(0,250,0,10); beeContainer.Size = UDim2.new(0,160,0,250)
beeContainer.BackgroundTransparency = 1
local beeList = Instance.new("UIListLayout", beeContainer)
beeList.Padding = UDim.new(0,8); beeList.HorizontalAlignment = Enum.HorizontalAlignment.Center
beeList.SortOrder = Enum.SortOrder.LayoutOrder

local wsBox  = makeBox(mainTab, UDim2.new(0,20,0,15),  UDim2.new(0,180,0,35), "WalkSpeed (max 80)")
local wsBtn  = makeBtn(mainTab, UDim2.new(0,205,0,15), UDim2.new(0,40,0,35),  "Apply")
local jpBox  = makeBox(mainTab, UDim2.new(0,20,0,55),  UDim2.new(0,180,0,35), "JumpPower (max 200)")
local jpBtn  = makeBtn(mainTab, UDim2.new(0,205,0,55), UDim2.new(0,40,0,35),  "Apply")
makeLabel(mainTab, UDim2.new(0,20,0,100), UDim2.new(0,225,0,35), "Create Part")
local kcBox  = makeBox(mainTab, UDim2.new(0,20,0,140), UDim2.new(0,180,0,35), "Khoảng Cách")
local kcBtn  = makeBtn(mainTab, UDim2.new(0,205,0,140),UDim2.new(0,40,0,35),  "Apply")
local createPartBtn = makeBtn(mainTab, UDim2.new(0,20,0,185), UDim2.new(0,220,0,30), "Tạo/TP")
local deletePartBtn = makeBtn(mainTab, UDim2.new(0,20,0,225), UDim2.new(0,220,0,30), "Xóa Part")

local _, vicBeeTF,    locateVicBtn     = makeBeeFrame(beeContainer, "Vicious Bee")
local _, windyBeeTF,  locateWindyBtn   = makeBeeFrame(beeContainer, "Windy Bee")
local _, stickerTF,   locateStickerBtn = makeBeeFrame(beeContainer, "Sticker")

-- ===== FARM TAB =====
local farmTab = Instance.new("Frame", contentFrame)
farmTab.Size = UDim2.new(1,0,1,0); farmTab.BackgroundTransparency = 1; farmTab.Visible = false

local farmStatusFrame = Instance.new("Frame", farmTab)
farmStatusFrame.Position = UDim2.new(0,253,0,10); farmStatusFrame.Size = UDim2.new(0.514,-20,0,40)
farmStatusFrame.BackgroundColor3 = Color3.fromRGB(65,65,65); farmStatusFrame.BorderSizePixel = 0
farmStatusFrame.BackgroundTransparency = 0.3; createUICorner(farmStatusFrame)

local farmLbl = Instance.new("TextLabel", farmStatusFrame)
farmLbl.Position = UDim2.new(0,10,0,0); farmLbl.Size = UDim2.new(0,120,1,0)
farmLbl.BackgroundTransparency = 1; farmLbl.Text = "🍯 Auto Farm"
farmLbl.TextColor3 = Color3.new(1,1,1); farmLbl.Font = Enum.Font.GothamBold
farmLbl.TextSize = 14; farmLbl.TextXAlignment = Enum.TextXAlignment.Left

local farmStatusBadge = Instance.new("TextLabel", farmStatusFrame)
farmStatusBadge.Position = UDim2.new(1,-80,0,5); farmStatusBadge.Size = UDim2.new(0,70,0,30)
farmStatusBadge.Text = "False"; farmStatusBadge.TextColor3 = Color3.new(1,1,1)
farmStatusBadge.Font = Enum.Font.GothamBold; farmStatusBadge.TextSize = 13
farmStatusBadge.BackgroundColor3 = Color3.fromRGB(200,0,0); createUICorner(farmStatusBadge)

local toggleFarmBtn = makeBtn(farmTab, UDim2.new(0,10,0,15), UDim2.new(0.51,-20,0,30), "▶ Bật Auto Farm")
toggleFarmBtn.BackgroundColor3 = Color3.fromRGB(55,55,55); toggleFarmBtn.Font = Enum.Font.GothamBold

local chooseTokenBtn = Instance.new("TextButton", farmTab)
chooseTokenBtn.Position = UDim2.new(0,10,0,60); chooseTokenBtn.Size = UDim2.new(0.5,-14,0,26)
chooseTokenBtn.Text = "🍀 Token"; chooseTokenBtn.Font = Enum.Font.GothamBold
chooseTokenBtn.TextSize = 12; chooseTokenBtn.TextColor3 = Color3.new(1,1,1)
chooseTokenBtn.BackgroundColor3 = COL_TOKEN_ACTIVE; chooseTokenBtn.BorderSizePixel = 0
createUICorner(chooseTokenBtn, 5)

local chooseFieldBtn = Instance.new("TextButton", farmTab)
chooseFieldBtn.Position = UDim2.new(0.5,4,0,60); chooseFieldBtn.Size = UDim2.new(0.5,-14,0,26)
chooseFieldBtn.Text = "🌿 Field (0)"; chooseFieldBtn.Font = Enum.Font.GothamBold
chooseFieldBtn.TextSize = 12; chooseFieldBtn.TextColor3 = Color3.new(1,1,1)
chooseFieldBtn.BackgroundColor3 = COL_OFF; chooseFieldBtn.BorderSizePixel = 0
createUICorner(chooseFieldBtn, 5)

local targetLabel = Instance.new("TextLabel", farmTab)
targetLabel.Position = UDim2.new(0,10,0,92); targetLabel.Size = UDim2.new(1,-20,0,22)
targetLabel.BackgroundColor3 = Color3.fromRGB(30,30,30); targetLabel.BackgroundTransparency = 0.3
targetLabel.TextColor3 = Color3.fromRGB(180,180,180); targetLabel.Font = Enum.Font.Gotham
targetLabel.TextSize = 12; targetLabel.Text = "Mục tiêu: --"
targetLabel.TextXAlignment = Enum.TextXAlignment.Left; createUICorner(targetLabel)

local hotkeyHint = Instance.new("TextLabel", farmTab)
hotkeyHint.Position = UDim2.new(0,10,1,-20); hotkeyHint.Size = UDim2.new(1,-20,0,16)
hotkeyHint.BackgroundTransparency = 1; hotkeyHint.TextColor3 = Color3.fromRGB(100,100,100)
hotkeyHint.Font = Enum.Font.Gotham; hotkeyHint.TextSize = 11
hotkeyHint.Text = "Phím tắt: [T] Bật/Tắt Auto Farm"
hotkeyHint.TextXAlignment = Enum.TextXAlignment.Center

local PANEL_POS  = UDim2.new(0,10,0,120)
local PANEL_SIZE = UDim2.new(1,-20,0,128)

-- ===== TOKEN PANEL =====
local tokenPanel = Instance.new("Frame", farmTab)
tokenPanel.Position = PANEL_POS; tokenPanel.Size = PANEL_SIZE
tokenPanel.BackgroundTransparency = 1; tokenPanel.Visible = true

local tpTitle = Instance.new("TextLabel", tokenPanel)
tpTitle.Size = UDim2.new(1,0,0,16); tpTitle.BackgroundTransparency = 1
tpTitle.TextColor3 = Color3.fromRGB(255,200,50); tpTitle.Font = Enum.Font.GothamBold
tpTitle.TextSize = 11; tpTitle.TextXAlignment = Enum.TextXAlignment.Left
tpTitle.Text = "⭐ Token ưu tiên — xanh = ưu tiên"

local tokenScroll = Instance.new("ScrollingFrame", tokenPanel)
tokenScroll.Position = UDim2.new(0,0,0,18); tokenScroll.Size = UDim2.new(1,0,0,110)
tokenScroll.BackgroundColor3 = Color3.fromRGB(30,30,30); tokenScroll.BackgroundTransparency = 0.3
tokenScroll.BorderSizePixel = 0; tokenScroll.ScrollBarThickness = 4
tokenScroll.ScrollBarImageColor3 = Color3.fromRGB(100,100,100)
createUICorner(tokenScroll)

local tGrid = Instance.new("UIGridLayout", tokenScroll)
tGrid.CellSize = UDim2.new(0,113,0,26); tGrid.CellPadding = UDim2.new(0,4,0,4)
tGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
tGrid.SortOrder = Enum.SortOrder.LayoutOrder
local tPad = Instance.new("UIPadding", tokenScroll)
tPad.PaddingLeft = UDim.new(0,5); tPad.PaddingTop = UDim.new(0,4)

for i, t in ipairs(ALL_TOKENS) do
	local btn = Instance.new("TextButton", tokenScroll)
	btn.Size = UDim2.new(0,113,0,26); btn.Font = Enum.Font.Gotham; btn.TextSize = 11
	btn.TextColor3 = Color3.new(1,1,1); btn.BorderSizePixel = 0
	btn.Text = t.emoji .. " " .. t.name; btn.LayoutOrder = i
	btn.BackgroundColor3 = t.priority and COL_ON or COL_OFF
	createUICorner(btn, 4)
	btn.MouseButton1Click:Connect(function()
		t.priority = not t.priority
		-- BUG FIX 1 (sync): cập nhật tokenPriorityMap đúng cách
		tokenPriorityMap[t.id] = t.priority or nil
		btn.BackgroundColor3 = t.priority and COL_ON or COL_OFF
	end)
end
task.defer(function()
	tokenScroll.CanvasSize = UDim2.new(0,0,0, tGrid.AbsoluteContentSize.Y + 8)
end)

-- ===== FIELD PANEL =====
local fieldPanel = Instance.new("Frame", farmTab)
fieldPanel.Position = PANEL_POS; fieldPanel.Size = PANEL_SIZE
fieldPanel.BackgroundTransparency = 1; fieldPanel.Visible = false

local fpTitle = Instance.new("TextLabel", fieldPanel)
fpTitle.Size = UDim2.new(1,0,0,16); fpTitle.BackgroundTransparency = 1
fpTitle.TextColor3 = Color3.fromRGB(100,220,100); fpTitle.Font = Enum.Font.GothamBold
fpTitle.TextSize = 11; fpTitle.TextXAlignment = Enum.TextXAlignment.Left
fpTitle.Text = "🌿 Chọn field farm — xanh = đang chọn"

local fieldScroll = Instance.new("ScrollingFrame", fieldPanel)
fieldScroll.Position = UDim2.new(0,0,0,18); fieldScroll.Size = UDim2.new(1,0,0,110)
fieldScroll.BackgroundColor3 = Color3.fromRGB(30,30,30); fieldScroll.BackgroundTransparency = 0.3
fieldScroll.BorderSizePixel = 0; fieldScroll.ScrollBarThickness = 4
fieldScroll.ScrollBarImageColor3 = Color3.fromRGB(100,100,100)
createUICorner(fieldScroll)

local fGrid = Instance.new("UIGridLayout", fieldScroll)
fGrid.CellSize = UDim2.new(0,150,0,26); fGrid.CellPadding = UDim2.new(0,4,0,4)
fGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
fGrid.SortOrder = Enum.SortOrder.LayoutOrder
local fPad = Instance.new("UIPadding", fieldScroll)
fPad.PaddingLeft = UDim.new(0,5); fPad.PaddingTop = UDim.new(0,4)

local fieldBtnMap = {}

local function updateFieldTabLabel()
	chooseFieldBtn.Text = "🌿 Field (" .. #selectedFields .. ")"
end

local function isFieldSelected(name)
	for _, n in ipairs(selectedFields) do
		if n == name then return true end
	end
	return false
end

for i, name in ipairs(fieldNameList) do
	local btn = Instance.new("TextButton", fieldScroll)
	btn.Size = UDim2.new(0,150,0,26); btn.Font = Enum.Font.Gotham; btn.TextSize = 11
	btn.TextColor3 = Color3.new(1,1,1); btn.BorderSizePixel = 0
	btn.Text = name; btn.LayoutOrder = i
	btn.BackgroundColor3 = COL_OFF
	createUICorner(btn, 4)
	fieldBtnMap[name] = btn

	btn.MouseButton1Click:Connect(function()
		if isFieldSelected(name) then
			table.clear(selectedFields)
			btn.BackgroundColor3 = COL_OFF
		else
			for _, otherBtn in pairs(fieldBtnMap) do
				otherBtn.BackgroundColor3 = COL_OFF
			end
			table.clear(selectedFields)
			table.insert(selectedFields, name)
			btn.BackgroundColor3 = COL_ON
		end
		updateFieldTabLabel()
	end)
end

task.defer(function()
	fieldScroll.CanvasSize = UDim2.new(0,0,0, fGrid.AbsoluteContentSize.Y + 8)
end)

local function setFarmPanel(panel)
	state.farmPanel = panel
	tokenPanel.Visible = panel == "token"
	fieldPanel.Visible = panel == "field"
	chooseTokenBtn.BackgroundColor3 = panel == "token" and COL_TOKEN_ACTIVE or COL_OFF
	chooseFieldBtn.BackgroundColor3 = panel == "field" and COL_FIELD_ACTIVE or COL_OFF
end

chooseTokenBtn.MouseButton1Click:Connect(function() setFarmPanel("token") end)
chooseFieldBtn.MouseButton1Click:Connect(function() setFarmPanel("field") end)

-- ===== MISC TAB =====
local miscTab = Instance.new("Frame", contentFrame)
miscTab.Size = UDim2.new(1,0,1,0); miscTab.BackgroundTransparency = 1; miscTab.Visible = false

--local DISPENSERS = {
--	"Blueberry Dispenser", "Coconut Dispenser", "Free Ant Pass Dispenser",
--	"Free Robo Pass Dispenser", "Free Royal Jelly Dispenser",
--	"Glue Dispenser", "Honey Dispenser", "Strawberry Dispenser",
--}

--local ToysFolder = workspace:WaitForChild("Toys")
--local StatCache  = require(game:GetService("ReplicatedStorage"):WaitForChild("ClientStatCache"))
--local OsTime     = require(game:GetService("ReplicatedStorage"):WaitForChild("OsTime"))
--local Events     = require(game:GetService("ReplicatedStorage"):WaitForChild("Events"))
--local autoDisRunning = false

--local function getDisCooldown(toy)
--	local Cooldown = toy:FindFirstChild("Cooldown")
--	if not Cooldown then return 0 end
--	local ok, statCache = pcall(function() return StatCache:Get() end)
--	if not ok or not statCache then return 0 end
--	local toyTimes = statCache.ToyTimes or {}
--	local lastUsed = toyTimes[toy.Name] or 0
--	local elapsed  = math.floor(OsTime()) - lastUsed
--	local remaining = Cooldown.Value - elapsed
--	return remaining > 0 and remaining or 0
--end

--local function getNextCooldown()
--	local minCd = math.huge
--	for _, toy in ipairs(ToysFolder:GetDescendants()) do
--		if toy:IsA("Model") and table.find(DISPENSERS, toy.Name) then
--			local cd = getDisCooldown(toy)
--			if cd > 0 and cd < minCd then minCd = cd end
--		end
--	end
--	return minCd == math.huge and 60 or minCd
--end

--local function useAllDispensers()
--	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
--	if not hrp then return end
--	for _, toy in ipairs(ToysFolder:GetDescendants()) do
--		if toy:IsA("Model") and table.find(DISPENSERS, toy.Name) then
--			local platform = toy:FindFirstChild("Platform")
--			if platform and (platform.Position - hrp.Position).Magnitude <= 20 then
--				if getDisCooldown(toy) == 0 then
--					Events.ClientCall("ToyEvent", toy.Name)
--				end
--			end
--		end
--	end
--end

local useDisBtn = makeBtn(miscTab, UDim2.new(0,10,0,15), UDim2.new(0,150,0,30), "Use all dispensers")
--useDisBtn.MouseButton1Click:Connect(useAllDispensers)

local autoDisLabel = Instance.new("TextLabel", miscTab)
autoDisLabel.Size = UDim2.new(0,100,0,15); autoDisLabel.Position = UDim2.new(0,10,0,50)
autoDisLabel.BackgroundTransparency = 1; autoDisLabel.Text = "Auto use dispenser"
autoDisLabel.TextColor3 = Color3.new(1,1,1); autoDisLabel.TextSize = 9

-- BUG FIX 2 (call site): xóa tham số knobPosX thừa (false trước function)
local autoUseDisToggle, setUseDisToggle = makeBoolBtn(
	miscTab,
	UDim2.new(0, 120, 0, 50),
	UDim2.new(0, 36, 0, 18),
	false,
	function(val)
		--		autoDisRunning = val
		--		if val then
		--			task.spawn(function()
		--				while autoDisRunning do
		--					useAllDispensers()
		--					local waitTime = getNextCooldown()
		--					for i = 1, waitTime do
		--						if not autoDisRunning then break end
		--						task.wait(1)
		--					end
		--				end
		--			end)
		--		end
	end
)

local nw = Instance.new("TextLabel", miscTab)
nw.Size = UDim2.new(0,150,0,15); nw.Position = UDim2.new(0,15,0,30); nw.Rotation = -15
nw.BackgroundTransparency = 1; nw.Text = "This shit not working!"
nw.TextColor3 = Color3.new(1,0,0); nw.TextSize = 10; nw.TextWrap = true

local autoSpLabel = Instance.new("TextLabel", miscTab)
autoSpLabel.Size = UDim2.new(0,100,0,15); autoSpLabel.Position = UDim2.new(0,10,0,75)
autoSpLabel.BackgroundTransparency = 1; autoSpLabel.Text = "Auto sprinkler"
autoSpLabel.TextColor3 = Color3.new(1,1,1); autoSpLabel.TextSize = 9

local autoSp = false
local autoUseSpToggle, setUseSpToggle = makeBoolBtn(
	miscTab,
	UDim2.new(0, 120, 0, 75),
	UDim2.new(0, 36, 0, 18),
	false,
	function(val)
		autoSp = val
	end
)

-- ===== SETTING TAB =====
local settingTab = Instance.new("Frame", contentFrame)
settingTab.Size = UDim2.new(1,0,1,0); settingTab.BackgroundTransparency = 1; settingTab.Visible = false

-- ================= TAB SWITCHING =================
local function setActiveTab(tabName)
	state.activeTab = tabName
	mainTab.Visible    = tabName == "main"
	farmTab.Visible    = tabName == "farm"
	miscTab.Visible    = tabName == "misc"
	settingTab.Visible = tabName == "setting"
	tabMainBtn.BackgroundColor3    = tabName == "main"    and Color3.fromRGB(60,60,60) or Color3.fromRGB(40,40,40)
	tabFarmBtn.BackgroundColor3    = tabName == "farm"    and Color3.fromRGB(60,60,60) or Color3.fromRGB(40,40,40)
	tabMiscBtn.BackgroundColor3    = tabName == "misc"    and Color3.fromRGB(60,60,60) or Color3.fromRGB(40,40,40)
	tabSettingBtn.BackgroundColor3 = tabName == "setting" and Color3.fromRGB(60,60,60) or Color3.fromRGB(40,40,40)
end

tabMainBtn.MouseButton1Click:Connect(function() setActiveTab("main") end)
tabFarmBtn.MouseButton1Click:Connect(function() setActiveTab("farm") end)
tabMiscBtn.MouseButton1Click:Connect(function() setActiveTab("misc") end)
tabSettingBtn.MouseButton1Click:Connect(function() setActiveTab("setting") end)

-- ================= TRANSPARENCY =================
local function saveTransparency(e)
	if e:IsA("GuiObject") and not e:IsA("UICorner") and not e:IsA("UIListLayout")
		and not e:IsA("UIGridLayout") and not e:IsA("UIPadding") then
		originalTransparency[e] = e.BackgroundTransparency
		for _, c in ipairs(e:GetChildren()) do saveTransparency(c) end
	end
end
saveTransparency(contentFrame)

-- ================= DRAG =================
local dragging, dragStart, startPos
title.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = i.Position; startPos = frame0.Position
	end
end)
title.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragStart
		frame0.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
	end
end)

-- ================= UTILITY =================
local function getHumanoid()
	local c = player.Character or player.CharacterAdded:Wait()
	return c, c:WaitForChild("Humanoid")
end

local function updateBeeStatus(lbl, exists)
	lbl.Text = exists and "True" or "False"
	lbl.BackgroundColor3 = exists and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end

local function checkViciousMob()
	for _, c in ipairs(monsters:GetChildren()) do
		if c:IsA("Model") and string.find(string.lower(c.Name),"vicious") then return true end
	end
	return false
end

local function checkWindyNPC()
	local w = npcBee:FindFirstChild("Windy")
	return w ~= nil and w:IsA("BasePart")
end

local function getBeePartFromModel(model)
	if not model:IsA("Model") then return nil end
	if model.PrimaryPart then return model.PrimaryPart end
	for _, n in ipairs({"Head","Torso","HumanoidRootPart","UpperTorso","LowerTorso"}) do
		local p = model:FindFirstChild(n)
		if p and p:IsA("BasePart") then return p end
	end
	for _, c in ipairs(model:GetDescendants()) do
		if c:IsA("BasePart") then return c end
	end
end

local function removeLocate(parent)
	if not parent then return end
	local g = parent:FindFirstChild("LocateGui"); if g then g:Destroy() end
	local sg = player.PlayerGui:FindFirstChild("LocateIndicators")
	if sg then local i = sg:FindFirstChild("Indicator_"..tostring(parent)); if i then i:Destroy() end end
end

local function createLocate(parent, text, color)
	if not parent or parent:FindFirstChild("LocateGui") then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "LocateGui"; bb.Parent = parent
	bb.Size = UDim2.new(0,100,0,40); bb.StudsOffset = Vector3.new(0,3,0); bb.AlwaysOnTop = true
	local lbl = Instance.new("TextLabel", bb)
	lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
	lbl.Text = text or "📍"; lbl.TextColor3 = color or Color3.fromRGB(255,0,0); lbl.TextScaled = true

	local sg = player.PlayerGui:FindFirstChild("LocateIndicators")
	if not sg then
		sg = Instance.new("ScreenGui"); sg.Name = "LocateIndicators"
		sg.ResetOnSpawn = false; sg.Parent = player.PlayerGui
	end
	local ind = Instance.new("Frame", sg)
	ind.Name = "Indicator_"..tostring(parent)
	ind.Size = UDim2.new(0,150,0,50)
	ind.BackgroundColor3 = Color3.fromRGB(30,30,30); ind.BackgroundTransparency = 0.3
	ind.BorderSizePixel = 0; createUICorner(ind, 8)
	local stroke = Instance.new("UIStroke", ind); stroke.Color = color or Color3.fromRGB(255,0,0); stroke.Thickness = 2
	local arrow = Instance.new("TextLabel", ind)
	arrow.Size = UDim2.new(0,30,1,0); arrow.Position = UDim2.new(0,5,0,0)
	arrow.BackgroundTransparency = 1; arrow.Text = "➤"
	arrow.TextColor3 = color or Color3.fromRGB(255,0,0); arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 24
	local tl = Instance.new("TextLabel", ind)
	tl.Size = UDim2.new(1,-40,0.5,0); tl.Position = UDim2.new(0,35,0,0)
	tl.BackgroundTransparency = 1; tl.Text = text or "📍"
	tl.TextColor3 = Color3.new(1,1,1); tl.Font = Enum.Font.GothamBold; tl.TextSize = 14
	tl.TextXAlignment = Enum.TextXAlignment.Left; tl.TextWrapped = true
	tl.TextTruncate = Enum.TextTruncate.None; tl.TextYAlignment = Enum.TextYAlignment.Top
	local dl = Instance.new("TextLabel", ind)
	dl.Size = UDim2.new(1,-40,0.5,0); dl.Position = UDim2.new(0,35,0.5,0)
	dl.BackgroundTransparency = 1; dl.Text = "..."
	dl.TextColor3 = Color3.fromRGB(200,200,200); dl.Font = Enum.Font.Gotham; dl.TextSize = 12
	dl.TextXAlignment = Enum.TextXAlignment.Left

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not parent or not parent.Parent then ind:Destroy(); conn:Disconnect(); return end
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		dl.Text = string.format("%.1f studs", (parent.Position-hrp.Position).Magnitude)
		local sp, onScreen = workspace.CurrentCamera:WorldToViewportPoint(parent.Position)
		if onScreen then
			ind.Position = UDim2.new(0,sp.X-75,0,sp.Y-25)
			arrow.Text = "●"; stroke.Color = Color3.fromRGB(0,255,0)
		else
			local vs = workspace.CurrentCamera.ViewportSize
			local cx,cy = vs.X/2, vs.Y/2
			local a = math.atan2(sp.Y-cy, sp.X-cx)
			ind.Position = UDim2.new(0,cx+math.cos(a)*(vs.X/2-100)-75, 0, cy+math.sin(a)*(vs.Y/2-100)-25)
			arrow.Text = "➤"; arrow.Rotation = math.deg(a); stroke.Color = color or Color3.fromRGB(255,0,0)
		end
	end)
	bb.AncestryChanged:Connect(function() if not bb.Parent then ind:Destroy(); conn:Disconnect() end end)
end

local function getWindyInfoFromMonsters()
	for _, c in ipairs(monsters:GetChildren()) do
		if c:IsA("Model") and string.find(string.lower(c.Name),"windy") then
			return string.match(c.Name,"%d+") or "?", c
		end
	end
	return nil, nil
end

local function updateWindyLocate()
	local wp = npcBee:FindFirstChild("Windy")
	if not wp or not wp:IsA("BasePart") or not wp:FindFirstChild("LocateGui") then return end
	removeLocate(wp)
	createLocate(wp, "📍 WINDY LV."..(getWindyInfoFromMonsters() or "?"), Color3.fromRGB(0,150,255))
end

-- ================= BEE MONITORING =================
local function checkBees()
	if not state.scriptEnabled then return end
	updateBeeStatus(vicBeeTF, WTsFolder:FindFirstChild("WaitingThorn") ~= nil or checkViciousMob())
	updateBeeStatus(windyBeeTF, checkWindyNPC())
	local count = 0
	for _, c in ipairs(sticker:GetChildren()) do if c.Name == "HiddenStickerPart" then count += 1 end end
	updateBeeStatus(stickerTF, count > 0)
	if count > 0 then stickerTF.Text = tostring(count) end
end
checkBees()

task.spawn(function()
	while state.scriptEnabled do
		if checkWindyNPC() then
			local wp = npcBee:FindFirstChild("Windy")
			if wp and wp:IsA("BasePart") then
				local loc = wp:FindFirstChild("LocateGui")
				if loc then
					local lv = getWindyInfoFromMonsters()
					local bl = loc:FindFirstChild("TextLabel")
					if bl and bl.Text ~= "📍 WINDY LV."..(lv or "?") then updateWindyLocate() end
				end
			end
		end
		task.wait(1)
	end
end)

local function updateStickerStatus()
	local count = 0
	for _, c in ipairs(sticker:GetChildren()) do if c.Name == "HiddenStickerPart" then count += 1 end end
	stickerTF.Text = count > 0 and tostring(count) or "0"
	stickerTF.BackgroundColor3 = count > 0 and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end
updateStickerStatus()

sticker.ChildAdded:Connect(function(c) if state.scriptEnabled and c.Name=="HiddenStickerPart" then updateStickerStatus() end end)
sticker.ChildRemoved:Connect(function(c) if state.scriptEnabled and c.Name=="HiddenStickerPart" then updateStickerStatus(); removeLocate(c) end end)
WTsFolder.ChildAdded:Connect(function(c) if state.scriptEnabled and c.Name=="WaitingThorn" then updateBeeStatus(vicBeeTF,true) end end)
WTsFolder.ChildRemoved:Connect(function(c) if state.scriptEnabled and c.Name=="WaitingThorn" then removeLocate(c); updateBeeStatus(vicBeeTF,checkViciousMob()) end end)
monsters.ChildAdded:Connect(function(c)
	if not state.scriptEnabled then return end
	if c:IsA("Model") then
		local ln = string.lower(c.Name)
		if string.find(ln,"vicious") and not WTsFolder:FindFirstChild("WaitingThorn") then updateBeeStatus(vicBeeTF,true) end
		if string.find(ln,"windy") then updateWindyLocate() end
	end
end)
monsters.ChildRemoved:Connect(function(c)
	if not state.scriptEnabled then return end
	if c:IsA("Model") then
		local ln = string.lower(c.Name)
		if string.find(ln,"vicious") then
			local bp = getBeePartFromModel(c); if bp then removeLocate(bp) end
			updateBeeStatus(vicBeeTF, WTsFolder:FindFirstChild("WaitingThorn") ~= nil or checkViciousMob())
		end
		if string.find(ln,"windy") then updateWindyLocate() end
	end
end)
npcBee.ChildAdded:Connect(function(c) if state.scriptEnabled and c.Name=="Windy" and c:IsA("BasePart") then updateBeeStatus(windyBeeTF,true) end end)
npcBee.ChildRemoved:Connect(function(c) if state.scriptEnabled and c.Name=="Windy" and c:IsA("BasePart") then removeLocate(c); updateBeeStatus(windyBeeTF,false) end end)

-- ================= WALKSPEED KEEPER =================
task.spawn(function()
	while state.scriptEnabled do
		if state.keepWalkSpeed then
			local char = player.Character
			if char then
				local hum = char:FindFirstChild("Humanoid")
				if hum then
					if state.walkSpeed and hum.WalkSpeed < state.walkSpeed then hum.WalkSpeed = state.walkSpeed end
					if state.jumpPower and hum.JumpPower < state.jumpPower then hum.JumpPower = state.jumpPower end
				end
			end
		end
		task.wait(CONFIG.checkInterval)
	end
end)

-- ================= AUTO FARM =================
local function getTexture(child)
	local f = child:FindFirstChild("FrontDecal")
	return f and f.Texture or nil
end

local function updateFarmStatus(on)
	if on then
		farmStatusBadge.Text = "True"; farmStatusBadge.BackgroundColor3 = Color3.fromRGB(0,200,0)
		toggleFarmBtn.Text = "⏹ Tắt Auto Farm"; toggleFarmBtn.BackgroundColor3 = Color3.fromRGB(0,130,50)
	else
		farmStatusBadge.Text = "False"; farmStatusBadge.BackgroundColor3 = Color3.fromRGB(200,0,0)
		toggleFarmBtn.Text = "▶ Bật Auto Farm"; toggleFarmBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
		targetLabel.Text = "Mục tiêu: --"
	end
end

local collectedTokens = {}
local COLLECT_TIMEOUT = 2.5
local capFull = false
local WAYPOINT_SKIP_DIST = 30
local UNSET_POS = Vector3.new(0, -100000, 0)

-- ================= CAPACITY MONITOR =================
local coreStats   = player:WaitForChild("CoreStats")
local pollenVal   = coreStats:WaitForChild("Pollen")
local capacityVal = coreStats:WaitForChild("Capacity")

local function checkCapacity()
	if pollenVal.Value >= capacityVal.Value then capFull = true
	elseif pollenVal.Value == 0 then capFull = false end
end
pollenVal:GetPropertyChangedSignal("Value"):Connect(checkCapacity)
checkCapacity()

-- =================================================================================
-- WAYPOINTS
-- =================================================================================
local WP = {
	gan_spawn_chung             = Vector3.new(-115.88,   4.689,    239.19),
	cong_1_sunflower            = Vector3.new(-220.835,  3.999,    258.015),
	nga_3_sun_dan_mush          = Vector3.new(-161.1,    3.999,    164.72),
	goc_rose_field              = Vector3.new(-262.91,   19.95,    171.096),
	dau_blue_flower_field       = Vector3.new(36.609,    3.999,    122.682),
	dau_cong_5                  = Vector3.new(-1.170,    4.052,    164.780),
	cong_5                      = Vector3.new(-1.28,     20,       12.3),
	chan_cau_thang_10           = Vector3.new(205.141,   20.006,   -21.036),
	giua_cau_thang_10           = Vector3.new(205.324,   41.280,   54.562),
	giua_cau_thang_10_2         = Vector3.new(230.166,   41.280,   53.612),
	cong_10                     = Vector3.new(231.594,   67.999,   -92.190),
	dau_cau_thang_strawberry    = Vector3.new(-140.49,   19.999,   56),
	giua_cau_thang_strawberry   = Vector3.new(-236,      34.53,    56),
	cong_15                     = Vector3.new(-238.598,  67.999,   -80.498),
	truoc_shop_badge            = Vector3.new(-339.087,  67.999,   -88.741),
	chan_doc_rose               = Vector3.new(-338.979,  19.950,   96.558),
	chan_doc_mountain           = Vector3.new(-242.973,  67.999,   -237.184),
	giua_doc_mountain           = Vector3.new(-103.570,  117.999,  -237.897),
	giua_doc_mountain_2         = Vector3.new(-95.638,   117.999,  -178.777),
	giua_doc_mountain_3         = Vector3.new(-83.285,   117.999,  -153.723),
	giua_doc_mountain_4         = Vector3.new(-82.178,   117.999,  -78.727),
	truoc_cong_25               = Vector3.new(-82.178,   117.999,  -78.727),
	sau_cong_25                 = Vector3.new(98.922,    175.999,  -118.626),
	red_cannon                  = Vector3.new(-239.72,   17.47,    344.65),
	mid_red_cannon              = Vector3.new(-79.25,    203.54,   72.44),
}

-- =================================================================================
-- FIELD_TO_FIELD_PATHS
-- =================================================================================
local FIELD_TO_FIELD_PATHS = {
	["Sunflower Field -> Dandelion Field"]  = { WP.nga_3_sun_dan_mush },
	["Sunflower Field -> Mushroom Field"]   = { WP.nga_3_sun_dan_mush },
	["Dandelion Field -> Mushroom Field"]   = {},

	["Sunflower Field -> Blue Flower Field"]   = { WP.nga_3_sun_dan_mush, WP.dau_cong_5, WP.dau_blue_flower_field },
	["Sunflower Field -> Spider Field"]        = { WP.nga_3_sun_dan_mush, WP.dau_cong_5, WP.cong_5 },
	["Sunflower Field -> Bamboo Field"]        = { WP.nga_3_sun_dan_mush, WP.dau_cong_5, WP.cong_5 },
	["Sunflower Field -> Pineapple Patch"]     = { WP.nga_3_sun_dan_mush, WP.dau_cong_5, WP.cong_5, FIELDS["Bamboo Field"].pos, WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },
	["Dandelion Field -> Blue Flower Field"]   = { WP.dau_cong_5, WP.dau_blue_flower_field },
	["Dandelion Field -> Spider Field"]        = { WP.dau_cong_5, WP.cong_5 },
	["Dandelion Field -> Bamboo Field"]        = { WP.dau_cong_5, WP.cong_5 },
	["Dandelion Field -> Pineapple Patch"]     = { WP.dau_cong_5, WP.cong_5, FIELDS["Bamboo Field"].pos, WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },
	["Mushroom Field -> Blue Flower Field"]    = { WP.dau_cong_5, WP.dau_blue_flower_field },
	["Mushroom Field -> Spider Field"]         = { WP.dau_cong_5, WP.cong_5 },
	["Mushroom Field -> Bamboo Field"]         = { WP.dau_cong_5, WP.cong_5 },
	["Mushroom Field -> Pineapple Patch"]      = { WP.dau_cong_5, WP.cong_5, FIELDS["Bamboo Field"].pos, WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },

	["Blue Flower Field -> Spider Field"]      = { WP.dau_blue_flower_field, WP.dau_cong_5, WP.cong_5 },
	["Blue Flower Field -> Bamboo Field"]      = { WP.dau_blue_flower_field, WP.dau_cong_5, WP.cong_5 },
	["Blue Flower Field -> Pineapple Patch"]   = { WP.dau_blue_flower_field, WP.dau_cong_5, WP.cong_5, FIELDS["Bamboo Field"].pos, WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },
	["Spider Field -> Bamboo Field"]           = {},
	["Spider Field -> Pineapple Patch"]        = { FIELDS["Bamboo Field"].pos, WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },
	["Bamboo Field -> Pineapple Patch"]        = { WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },

	["Blue Flower Field -> Strawberry Field"]  = { WP.dau_blue_flower_field, WP.dau_cong_5, WP.cong_5 },
	["Spider Field -> Strawberry Field"]       = {},
	["Bamboo Field -> Strawberry Field"]       = {},
	["Pineapple Patch -> Strawberry Field"]    = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },

	["Strawberry Field -> Cactus Field"]       = { WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },
	["Strawberry Field -> Pumpkin Patch"]      = { WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },
	["Strawberry Field -> Pine Tree Forest"]   = { WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },
	["Strawberry Field -> Mountain Top Field"] = { WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15, WP.chan_doc_mountain, WP.giua_doc_mountain, WP.giua_doc_mountain_2, WP.giua_doc_mountain_3, WP.giua_doc_mountain_4, WP.truoc_cong_25, WP.sau_cong_25 },

	["Cactus Field -> Pumpkin Patch"]          = {},
	["Cactus Field -> Pine Tree Forest"]       = {},
	["Cactus Field -> Mountain Top Field"]     = { WP.chan_doc_mountain, WP.giua_doc_mountain, WP.giua_doc_mountain_2, WP.giua_doc_mountain_3, WP.giua_doc_mountain_4, WP.truoc_cong_25, WP.sau_cong_25 },
	["Pumpkin Patch -> Pine Tree Forest"]      = {},
	["Pumpkin Patch -> Mountain Top Field"]    = { WP.chan_doc_mountain, WP.giua_doc_mountain, WP.giua_doc_mountain_2, WP.giua_doc_mountain_3, WP.giua_doc_mountain_4, WP.truoc_cong_25, WP.sau_cong_25 },
	["Pine Tree Forest -> Mountain Top Field"] = { WP.chan_doc_mountain, WP.giua_doc_mountain, WP.giua_doc_mountain_2, WP.giua_doc_mountain_3, WP.giua_doc_mountain_4, WP.truoc_cong_25, WP.sau_cong_25 },

	["Rose Field -> Sunflower Field"]          = { WP.goc_rose_field },
	["Rose Field -> Dandelion Field"]          = { WP.goc_rose_field, WP.nga_3_sun_dan_mush },
	["Rose Field -> Mushroom Field"]           = { WP.goc_rose_field, WP.nga_3_sun_dan_mush },
	["Rose Field -> Blue Flower Field"]        = { WP.goc_rose_field, WP.nga_3_sun_dan_mush, WP.dau_cong_5, WP.dau_blue_flower_field },
	["Rose Field -> Spider Field"]             = { WP.chan_doc_rose, WP.truoc_shop_badge, WP.cong_15, WP.giua_cau_thang_strawberry, WP.dau_cau_thang_strawberry },
	["Rose Field -> Bamboo Field"]             = { WP.chan_doc_rose, WP.truoc_shop_badge, WP.cong_15, WP.giua_cau_thang_strawberry, WP.dau_cau_thang_strawberry },
	["Rose Field -> Pineapple Patch"]          = { WP.chan_doc_rose, WP.truoc_shop_badge, WP.cong_15, WP.giua_cau_thang_strawberry, WP.dau_cau_thang_strawberry, FIELDS["Bamboo Field"].pos, WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },
	["Rose Field -> Strawberry Field"]         = { WP.chan_doc_rose, WP.truoc_shop_badge, WP.cong_15, WP.giua_cau_thang_strawberry, WP.dau_cau_thang_strawberry },
	["Rose Field -> Cactus Field"]             = { WP.chan_doc_rose, WP.truoc_shop_badge },
	["Rose Field -> Pumpkin Patch"]            = { WP.chan_doc_rose, WP.truoc_shop_badge },
	["Rose Field -> Pine Tree Forest"]         = { WP.chan_doc_rose, WP.truoc_shop_badge },
	["Rose Field -> Mountain Top Field"]       = { WP.chan_doc_rose, WP.truoc_shop_badge, WP.chan_doc_mountain, WP.giua_doc_mountain, WP.giua_doc_mountain_2, WP.giua_doc_mountain_3, WP.giua_doc_mountain_4, WP.truoc_cong_25, WP.sau_cong_25 },

	["Sunflower Field -> Cactus Field"]        = { WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },
	["Sunflower Field -> Pumpkin Patch"]       = { WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },
	["Sunflower Field -> Pine Tree Forest"]    = { WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },
	["Dandelion Field -> Cactus Field"]        = { WP.nga_3_sun_dan_mush, WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },
	["Dandelion Field -> Pumpkin Patch"]       = { WP.nga_3_sun_dan_mush, WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },
	["Dandelion Field -> Pine Tree Forest"]    = { WP.nga_3_sun_dan_mush, WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },
	["Mushroom Field -> Cactus Field"]         = { WP.nga_3_sun_dan_mush, WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },
	["Mushroom Field -> Pumpkin Patch"]        = { WP.nga_3_sun_dan_mush, WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },
	["Mushroom Field -> Pine Tree Forest"]     = { WP.nga_3_sun_dan_mush, WP.goc_rose_field, WP.chan_doc_rose, WP.truoc_shop_badge },

	["Sunflower Field -> Strawberry Field"]    = { WP.nga_3_sun_dan_mush, WP.dau_cong_5, WP.cong_5 },
	["Dandelion Field -> Strawberry Field"]    = { WP.dau_cong_5, WP.cong_5 },
	["Mushroom Field -> Strawberry Field"]     = { WP.dau_cong_5, WP.cong_5 },

	["Pineapple Patch -> Cactus Field"]        = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos, WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },
	["Pineapple Patch -> Pumpkin Patch"]       = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos, WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },
	["Pineapple Patch -> Pine Tree Forest"]    = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos, WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },

	["Stump Field -> Sunflower Field"]         = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Dandelion Field"]         = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Mushroom Field"]          = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Blue Flower Field"]       = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Spider Field"]            = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Bamboo Field"]            = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Strawberry Field"]        = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Pineapple Patch"]         = {},
	["Stump Field -> Cactus Field"]            = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Pumpkin Patch"]           = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Pine Tree Forest"]        = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Rose Field"]              = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Mountain Top Field"]      = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Coconut Field"]           = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },
	["Stump Field -> Pepper Patch"]            = { WP.cong_10, WP.giua_cau_thang_10_2, WP.giua_cau_thang_10, WP.chan_cau_thang_10, FIELDS["Bamboo Field"].pos },

	["Coconut Field -> Pepper Patch"]          = {},
	["Sunflower Field -> Coconut Field"]       = {},
	["Dandelion Field -> Coconut Field"]       = {},
	["Mushroom Field -> Coconut Field"]        = {},
	["Rose Field -> Coconut Field"]            = {},
	["Spider Field -> Coconut Field"]          = {},
	["Sunflower Field -> Pepper Patch"]        = {},
	["Mushroom Field -> Pepper Patch"]         = {},
}

-- =================================================================================
-- FIELD_PATHS
-- =================================================================================
local FIELD_PATHS = {
	["Sunflower Field"]   = { WP.cong_1_sunflower },
	["Dandelion Field"]   = { WP.gan_spawn_chung },
	["Mushroom Field"]    = { WP.gan_spawn_chung },
	["Clover Field"]      = { WP.gan_spawn_chung, FIELDS["Dandelion Field"].pos },
	["Spider Field"]      = { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5 },
	["Strawberry Field"]  = { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5 },
	["Bamboo Field"]      = { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5 },
	["Pineapple Patch"]   = { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5, FIELDS["Bamboo Field"].pos, WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },
	["Blue Flower Field"] = { WP.gan_spawn_chung, WP.dau_cong_5, WP.dau_blue_flower_field },
	["Cactus Field"]      = { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5, WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },
	["Pumpkin Patch"]     = { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5, WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },
	["Pine Tree Forest"]  = { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5, WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15 },
	["Rose Field"]        = { WP.cong_1_sunflower, WP.goc_rose_field },
	["Mountain Top Field"]= { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5, WP.dau_cau_thang_strawberry, WP.giua_cau_thang_strawberry, WP.cong_15, WP.chan_doc_mountain, WP.giua_doc_mountain, WP.giua_doc_mountain_2, WP.giua_doc_mountain_3, WP.giua_doc_mountain_4, WP.truoc_cong_25, WP.sau_cong_25 },
	["Stump Field"]       = { WP.gan_spawn_chung, WP.dau_cong_5, WP.cong_5, FIELDS["Bamboo Field"].pos, WP.chan_cau_thang_10, WP.giua_cau_thang_10, WP.giua_cau_thang_10_2, WP.cong_10 },
	["Coconut Field"]     = {},
	["Pepper Patch"]      = {},
	["Ant Field"]         = {},
}

-- ================= PATH HELPERS =================

-- Tìm index của waypoint GẦN NHẤT với currentPos trong danh sách wps.
-- Trả về index đó để bắt đầu đi từ đó, bỏ qua các wp trước nó.
-- Nếu đã đứng gần dest hơn bất kỳ wp nào (tức giữa chừng) thì bỏ luôn path.
local function findNearestWaypointIndex(wps, currentPos, destPos)
	local bestIdx  = 1
	local bestDist = math.huge
	for i, pos in ipairs(wps) do
		local d = (pos - currentPos).Magnitude
		if d < bestDist then
			bestDist = d
			bestIdx  = i
		end
	end
	-- Nếu dest gần hơn wp gần nhất -> không cần đi qua wp nào nữa
	local distToDest = (currentPos - destPos).Magnitude
	if distToDest < bestDist then
		return #wps + 1  -- index vượt quá -> vòng lặp sẽ rỗng
	end
	return bestIdx
end

local function getFieldToFieldPath(fromField, toField, currentPos)
	local wps = FIELD_TO_FIELD_PATHS[fromField .. " -> " .. toField]
	if not wps then
		local rev = FIELD_TO_FIELD_PATHS[toField .. " -> " .. fromField]
		if rev then
			wps = {}
			for i = #rev, 1, -1 do table.insert(wps, rev[i]) end
		end
	end
	if not wps then return nil end
	if #wps == 0 then return {} end
	local destPos = FIELDS[toField] and FIELDS[toField].pos or currentPos
	local startIdx = findNearestWaypointIndex(wps, currentPos, destPos)
	local filtered = {}
	for i = startIdx, #wps do
		if (wps[i] - currentPos).Magnitude > WAYPOINT_SKIP_DIST then
			table.insert(filtered, wps[i])
		end
	end
	return filtered
end

local function getPathToField(fieldName, currentPos)
	local wps = FIELD_PATHS[fieldName]
	if not wps or #wps == 0 then return {} end
	local destPos  = FIELDS[fieldName] and FIELDS[fieldName].pos or currentPos
	local startIdx = findNearestWaypointIndex(wps, currentPos, destPos)
	local filtered = {}
	for i = startIdx, #wps do
		if (wps[i] - currentPos).Magnitude > WAYPOINT_SKIP_DIST then
			table.insert(filtered, wps[i])
		end
	end
	return filtered
end

local function getPathToHive(fieldName, currentPos)
	local wps = FIELD_PATHS[fieldName]
	if not wps or #wps == 0 then return {} end
	-- Đường về hive = đảo ngược FIELD_PATHS
	-- Tìm wp gần nhất (theo chiều ngược) rồi đi từ đó về spawn
	local reversed = {}
	for i = #wps, 1, -1 do reversed[#reversed+1] = wps[i] end
	local spawnPos = player:FindFirstChild("SpawnPos")
	local destPos  = spawnPos and spawnPos.Value.Position or currentPos
	local startIdx = findNearestWaypointIndex(reversed, currentPos, destPos)
	local filtered = {}
	for i = startIdx, #reversed do
		if (reversed[i] - currentPos).Magnitude > WAYPOINT_SKIP_DIST then
			table.insert(filtered, reversed[i])
		end
	end
	return filtered
end

-- ================= MOVE HELPERS =================
local function moveWithJump(hum, hrp, destPos, interruptCheck)
	hum:MoveTo(destPos)
	local lastPos = hrp.Position
	local stuckTimer = 0
	while task.wait(0.05) do
		if interruptCheck and interruptCheck() then return false end
		if (hrp.Position - destPos).Magnitude < 6 then return true end
		local moved = (hrp.Position - lastPos).Magnitude
		if moved < 0.5 then
			stuckTimer += 0.05
			if stuckTimer >= 0.8 then
				hum.Jump = true; task.wait(0.1)
				hum:MoveTo(destPos); stuckTimer = 0
			end
		else
			stuckTimer = 0
		end
		lastPos = hrp.Position
	end
	return false
end

local function moveThroughPath(hum, hrp, pathPoints, destPos, label, interruptCheck)
	for _, pos in ipairs(pathPoints) do
		if interruptCheck and interruptCheck() then return false end
		if (hrp.Position - pos).Magnitude <= WAYPOINT_SKIP_DIST then continue end
		targetLabel.Text = label .. " ..."
		if not moveWithJump(hum, hrp, pos, interruptCheck) then return false end
	end
	if interruptCheck and interruptCheck() then return false end
	targetLabel.Text = label
	moveWithJump(hum, hrp, destPos, interruptCheck)
	return true
end

-- ================= FIELD HELPERS =================
local function isInField(pos, data)
	if not data then return false end
	local rel = pos - data.pos
	return math.abs(rel.X) <= data.sizeX/2 and math.abs(rel.Z) <= data.sizeZ/2
end

local function getAnyCurrentField(hrp)
	for name, data in pairs(FIELDS) do
		if isInField(hrp.Position, data) then return name, data end
	end
	return nil, nil
end

local function getCurrentField(hrp)
	if #selectedFields == 0 then return nil, nil end
	local name = selectedFields[1]
	local data = FIELDS[name]
	if data and isInField(hrp.Position, data) then return name, data end
	return nil, nil
end

local function getSelectedFieldData()
	if #selectedFields == 0 then return nil, nil end
	local name = selectedFields[1]
	return name, FIELDS[name]
end

local function cleanCollected()
	for token in pairs(collectedTokens) do
		if not token.Parent then collectedTokens[token] = nil end
	end
end

--local function findBestToken(hrp, fieldData, excludeToken)
--	local bPri, bPriD = nil, math.huge
--	local bNor, bNorD = nil, math.huge
--	for _, child in ipairs(Collectibles:GetChildren()) do
--		if child.Name == "C" and child.Parent
--			and child ~= excludeToken
--			and not collectedTokens[child]
--			and isInField(child.Position, fieldData) then
--			local ok, dist = pcall(function() return (hrp.Position - child.Position).Magnitude end)
--			if ok then
--		local tex = getTexture(child)
--				-- BUG FIX 1: tokenPriorityMap[tex] chỉ true/nil -> check đúng
--				if tex and tokenPriorityMap[tex] then
--					if dist < bPriD then bPri, bPriD = child, dist end
--				else
--					if dist < bNorD then bNor, bNorD = child, dist end
--				end
--			end
--		end
--	end
--	if bPri then local t = getTexture(bPri); return bPri, (t and tokenNameMap[t] or "⭐"), true end
--	if bNor then local t = getTexture(bNor); return bNor, (t and tokenNameMap[t] or "🍯"), false end
--	return nil, nil, false
--end

-- Cách 2: dùng VirtualInputManager của Roblox (không cần executor API)
local function pressE()
	VIM:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
	task.wait(0.1)
	VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Cách 3: mouse1click vào prompt trên screen nếu biết vị trí
-- (ít dùng vì cần tính toán WorldToViewport)

-- ================= DÙNG TRONG CLAIM HIVE / NỘP POLLEN =================
-- Di chuyển đến vị trí -> đợi dừng -> pressE
-- Không cần tìm ProximityPrompt nữa, chỉ cần đứng đúng chỗ

local function pressEWithRetry(times, interval)
	times    = times    or 3
	interval = interval or 0.3
	for i = 1, times do
		pressE()
		task.wait(interval)
	end
end

-- ================= CLAIM HIVE =================
local function claimHive(hum, hrp)
	local spawnPos = player:FindFirstChild("SpawnPos")
	if not spawnPos then return end
	if (spawnPos.Value.Position - UNSET_POS).Magnitude > 0.1 then return end

	local HivePlatforms = workspace:WaitForChild("HivePlatforms")

	for _, platform in ipairs(HivePlatforms:GetChildren()) do
		local playerRef = platform:FindFirstChild("PlayerRef")

		if playerRef and playerRef.Value == player.Name then
			local plat = platform:FindFirstChild("Platform")
			if plat then moveWithJump(hum, hrp, plat.Position, nil) end
			return
		end

		if playerRef and playerRef.Value ~= nil and playerRef.Value ~= "" then continue end

		local plat = platform:FindFirstChild("Platform")
		if not plat then continue end

		moveWithJump(hum, hrp, plat.Position, nil)
		task.wait(0.5)
		pressEWithRetry(1, 0.3)

		if (spawnPos.Value.Position - UNSET_POS).Magnitude > 0.1 then
			print("✅ Claimed:", platform.Name); return
		end
		if playerRef and playerRef.Value == player.Name then
			print("✅ Claimed (ref):", platform.Name); return
		end

	end
end

-- ================= SPRINKLER =================
local function hasSprinklerInField(fieldData)
	local gadgets = workspace:FindFirstChild("Gadgets")
	if not gadgets then return false end
	for _, s in ipairs(gadgets:GetChildren()) do
		local pos = s:IsA("BasePart") and s.Position
			or (s:IsA("Model") and s.PrimaryPart and s.PrimaryPart.Position)
		if pos and isInField(pos, fieldData) then
			return true
		end
	end
	return false
end

local sprinklerPlacedFields = {} -- tránh đặt lại liên tục mỗi tick

local function placeSprinkler(hum, hrp, fieldData, fieldName)
	if not autoSp then return end
	if sprinklerPlacedFields[fieldName] then return end  -- đã thử đặt rồi
	if hasSprinklerInField(fieldData) then
		sprinklerPlacedFields[fieldName] = true
		return
	end
	local center = fieldData.pos
	if (hrp.Position - center).Magnitude > 8 then
		moveWithJump(hum, hrp, center, nil)
	end
	VIM:SendKeyEvent(true,  Enum.KeyCode.One, false, game)
	task.wait(0.1)
	VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
	task.wait(0.3)
	-- Đánh dấu đã đặt nếu có sprinkler xuất hiện
	if hasSprinklerInField(fieldData) then
		sprinklerPlacedFields[fieldName] = true
	end
end

-- Reset khi tắt autoSp để có thể đặt lại khi bật
-- (gọi setUseSpToggle sẽ tự update autoSp rồi)

-- ================= COLLECTIBLES CACHE =================
local tokenCache      = {}
local tokenCacheDirty = true
local lastSelectedField = nil

local function rebuildTokenCache()
	tokenCache = {}
	local fieldName = selectedFields[1]
	if not fieldName then return end
	local fieldData = FIELDS[fieldName]
	if not fieldData then return end
	for _, child in ipairs(Collectibles:GetChildren()) do
		if child.Name == "C" and isInField(child.Position, fieldData) then
			tokenCache[child] = true
		end
	end
	tokenCacheDirty = false
end

Collectibles.ChildAdded:Connect(function(child)
	if child.Name ~= "C" then return end
	local fieldName = selectedFields[1]
	if not fieldName then return end
	local fieldData = FIELDS[fieldName]
	if fieldData and isInField(child.Position, fieldData) then
		tokenCache[child] = true
	end
end)

Collectibles.ChildRemoved:Connect(function(child)
	tokenCache[child] = nil
	collectedTokens[child] = nil
end)

local function findBestTokenFast(hrp, fieldData, excludeToken)
	if tokenCacheDirty then rebuildTokenCache() end
	local bPri, bPriD = nil, math.huge
	local bNor, bNorD = nil, math.huge
	for child in pairs(tokenCache) do
		if child ~= excludeToken and not collectedTokens[child]
			and child.Parent and isInField(child.Position, fieldData) then
			local ok, dist = pcall(function() return (hrp.Position - child.Position).Magnitude end)
			if ok then
				local tex = getTexture(child)
				if tex and tokenPriorityMap[tex] then
					if dist < bPriD then bPri, bPriD = child, dist end
				else
					if dist < bNorD then bNor, bNorD = child, dist end
				end
			end
		end
	end
	if bPri then local t = getTexture(bPri); return bPri, (t and tokenNameMap[t] or "⭐"), true end
	if bNor then local t = getTexture(bNor); return bNor, (t and tokenNameMap[t] or "🍯"), false end
	return nil, nil, false
end

-- ================= AUTO FARM LOOP =================
-- BUG FIX: capFull block chạy trong task.spawn riêng để không bị
-- "continue" của vòng lặp chính bỏ qua khi đang giữa hành trình về hive
local returningToHive = false
local hiveChecked = false

local function toggleFarm()
	state.autoFarm = not state.autoFarm
	if state.autoFarm then
		hiveChecked = false  -- cho phép check lại khi bật
	end
	updateFarmStatus(state.autoFarm)
end

task.spawn(function()
	while true do
		task.wait(0.05)
		if not state.autoFarm then
			returningToHive = false
			continue
		end

		local char = player.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChild("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then continue end

		-- Chỉ claim hive 1 lần duy nhất khi bật autoFarm
		if not hiveChecked then
			hiveChecked = true
			claimHive(hum, hrp)
		end

		-- ===== FULL POLLEN -> VỀ HIVE =====
		if capFull then
			if returningToHive then continue end
			returningToHive = true

			task.spawn(function()
				local spawnPos = player:FindFirstChild("SpawnPos")
				if not spawnPos then returningToHive = false; return end

				local dest = spawnPos.Value.Position

				local function buildHivePath()
					local c = player.Character
					local h = c and c:FindFirstChild("HumanoidRootPart")
					if not h then return {} end
					if (h.Position - dest).Magnitude <= 50 then return {} end
					local curFieldName = #selectedFields > 0 and selectedFields[1] or nil
					return curFieldName and getPathToHive(curFieldName, h.Position) or {}
				end

				local c2 = player.Character
				local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
				local hum2 = c2 and c2:FindFirstChild("Humanoid")
				if not h2 or not hum2 then returningToHive = false; return end

				-- ① Di chuyển về hive theo path
				moveThroughPath(hum2, h2, buildHivePath(), dest, "🍯 Full → về hive", function()
					return not state.autoFarm
				end)

				if not state.autoFarm then returningToHive = false; return end

				-- ② Đợi player thực sự đứng sát hive (< 8 studs) rồi mới bấm E
				-- Nếu vẫn còn xa thì tiếp tục MoveTo + jump cho đến khi tới nơi
				targetLabel.Text = "🍯 Đang tiến đến hive..."
				local HIVE_DIST   = 8    -- khoảng cách đủ gần để bấm E
				local MAX_WAIT    = 10   -- giây chờ tối đa trước khi thử lại MoveTo
				local waitTimer   = 0

				while task.wait(0.1) do
					if not state.autoFarm or not capFull then break end

					local c3 = player.Character
					local h3 = c3 and c3:FindFirstChild("HumanoidRootPart")
					local hum3 = c3 and c3:FindFirstChild("Humanoid")
					if not h3 or not hum3 then break end

					local dist = (h3.Position - dest).Magnitude

					if dist <= HIVE_DIST then
						-- ✅ Đã đứng sát hive → dừng di chuyển, bấm E
						hum3:MoveTo(h3.Position)
						break
					end

					-- Vẫn còn xa → tiếp tục di chuyển + jump nếu bị kẹt
					hum3:MoveTo(dest)
					waitTimer += 0.1
					if waitTimer >= MAX_WAIT then
						-- Thử jump để thoát kẹt rồi reset timer
						hum3.Jump = true
						task.wait(0.15)
						hum3:MoveTo(dest)
						waitTimer = 0
					end
				end

				if not state.autoFarm or not capFull then
					returningToHive = false
					return
				end

				-- ③ Đã sát hive → bấm E, retry đến khi pollen về 0
				targetLabel.Text = "🍯 Đang nộp pollen..."
				local MAX_RETRY  = 3  -- số lần bấm E tối đa
				local RETRY_WAIT = 0.5  -- giây giữa mỗi lần retry

				for i = 1, MAX_RETRY do
					if not state.autoFarm then break end
					if not capFull then break end   -- pollen đã nộp xong

					-- Nếu bị đẩy ra xa thì đi vào lại trước khi bấm
					local c4 = player.Character
					local h4 = c4 and c4:FindFirstChild("HumanoidRootPart")
					local hum4 = c4 and c4:FindFirstChild("Humanoid")
					if not h4 or not hum4 then break end

					if (h4.Position - dest).Magnitude > HIVE_DIST then
						-- Bị đẩy ra → đi lại gần
						moveWithJump(hum4, h4, dest, function()
							return not state.autoFarm or not capFull
						end)
						if not capFull then break end
					end

					pressE()
					task.wait(RETRY_WAIT)
				end

				-- ④ Xong
				if not capFull then
					targetLabel.Text = "✅ Đã nộp xong, quay lại farm..."
				else
					targetLabel.Text = "⚠️ Nộp pollen thất bại, thử lại..."
				end

				task.wait(1.5)
				returningToHive = false
			end)

			continue
		end

		if returningToHive then continue end

		-- ===== CHƯA CHỌN FIELD =====
		if #selectedFields == 0 then
			targetLabel.Text = "Chưa chọn field nào"
			hum:MoveTo(hrp.Position)
			continue
		end

		if selectedFields[1] ~= lastSelectedField then
			lastSelectedField = selectedFields[1]
			tokenCacheDirty = true
			sprinklerPlacedFields = {}
		end

		cleanCollected()

		local fieldName, fieldData = getCurrentField(hrp)

		if not fieldName then
			local targetFieldName, targetFieldData = getSelectedFieldData()
			if not targetFieldName then
				targetLabel.Text = "Không tìm thấy field"
				continue
			end

			if isInField(hrp.Position, targetFieldData) then continue end

			local destPos   = targetFieldData.pos
			local interrupt = function() return not state.autoFarm or capFull end
			local path      = nil

			-- Ưu tiên dùng field-to-field path nếu đang đứng trong field khác
			local fromField = getAnyCurrentField(hrp)
			if fromField and fromField ~= targetFieldName then
				path = getFieldToFieldPath(fromField, targetFieldName, hrp.Position)
			end

			-- Fallback: dùng FIELD_PATHS từ spawn, bắt đầu từ waypoint gần nhất
			if not path then
				path = getPathToField(targetFieldName, hrp.Position)
			end

			moveThroughPath(hum, hrp, path, destPos,
				"→ Đến field: " .. targetFieldName, interrupt)
			continue
		end

		placeSprinkler(hum, hrp, fieldData, fieldName)

		local target, name, isP = findBestTokenFast(hrp, fieldData, nil)
		if not target then
			targetLabel.Text = "[" .. fieldName .. "] Không có token"
			hum:MoveTo(hrp.Position)
			continue
		end

		local nxtT, nxtN, nxtP = findBestTokenFast(hrp, fieldData, target)
		collectedTokens[target] = true
		targetLabel.Text = "[" .. fieldName .. "] " .. name .. (isP and " ⭐" or "")
		hum:MoveTo(target.Position)

		local timeout = 0

		while task.wait(0.05) do
			if not state.autoFarm then break end
			if capFull then break end

			local curName, curData = getCurrentField(hrp)

			if not target.Parent then
				if nxtT and nxtT.Parent and not collectedTokens[nxtT]
					and curData and isInField(nxtT.Position, curData) then
					target, name, isP = nxtT, nxtN, nxtP
					nxtT, nxtN, nxtP = findBestTokenFast(hrp, curData, target)
					collectedTokens[target] = true
					targetLabel.Text = "[" .. (curName or fieldName) .. "] " .. name .. (isP and " ⭐" or "")
					hum:MoveTo(target.Position)
					timeout = 0; continue
				end
				break
			end

			if not curData or not isInField(target.Position, curData) then
				collectedTokens[target] = nil
				targetLabel.Text = "Bỏ qua: ngoài field"
				break
			end

			local ok, d = pcall(function() return (hrp.Position - target.Position).Magnitude end)
			if not ok or d < 4 then break end

			if not nxtT or not nxtT.Parent or collectedTokens[nxtT]
				or (curData and not isInField(nxtT.Position, curData)) then
				nxtT, nxtN, nxtP = findBestTokenFast(hrp, curData, target)
			end

			if not isP and nxtP and nxtT then
				collectedTokens[target] = nil
				target, name, isP = nxtT, nxtN, nxtP
				nxtT, nxtN, nxtP = findBestTokenFast(hrp, curData, target)
				collectedTokens[target] = true
				targetLabel.Text = "[" .. (curName or fieldName) .. "] " .. name .. " ⭐"
				hum:MoveTo(target.Position)
				timeout = 0; continue
			end

			timeout += 0.05
			if timeout > COLLECT_TIMEOUT then
				collectedTokens[target] = nil
				targetLabel.Text = "Bỏ qua: timeout"
				break
			end
		end
	end
end)

toggleFarmBtn.MouseButton1Click:Connect(toggleFarm)
UIS.InputBegan:Connect(function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.T then toggleFarm() end
end)

-- ================= SETTINGS =================
local SETTINGS_FILE = "bss_settings.json"

local function saveSettings()
	local data = {
		walkSpeed      = state.walkSpeed,
		jumpPower      = state.jumpPower,
		khoangcachpart = state.khoangcachpart,
		autoSp         = autoSp         or false,
		autoDisRunning = autoDisRunning or false,
		selectedField  = selectedFields and selectedFields[1] or nil,
		tokenPriority  = {},
	}
	if ALL_TOKENS then
		for _, t in ipairs(ALL_TOKENS) do
			data.tokenPriority[t.id] = t.priority
		end
	end
	local ok, err = pcall(function()
		writefile(SETTINGS_FILE, HttpService:JSONEncode(data))
	end)
	if not ok then warn("❌ Lưu settings thất bại:", err) end
end

local function loadSettings()
	if not isfile(SETTINGS_FILE) then return nil end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(SETTINGS_FILE))
	end)
	if not ok or type(data) ~= "table" then
		warn("❌ Đọc settings thất bại, dùng mặc định")
		return nil
	end
	print("✅ Đã load settings")
	return data
end

-- Gọi sau khi toàn bộ UI đã tạo xong
local function applySettings(data)
	if not data then return end

	if data.walkSpeed      then state.walkSpeed      = data.walkSpeed      end
	if data.jumpPower      then state.jumpPower      = data.jumpPower      end
	if data.khoangcachpart then state.khoangcachpart = data.khoangcachpart end

	if wsBox then wsBox.Text = tostring(state.walkSpeed) end
	if jpBox then jpBox.Text = tostring(state.jumpPower) end
	if kcBox then kcBox.Text = tostring(state.khoangcachpart) end

	if data.autoSp ~= nil and setUseSpToggle then
		autoSp = data.autoSp
		setUseSpToggle(autoSp)
	end
	if data.autoDisRunning ~= nil and setUseDisToggle then
		autoDisRunning = data.autoDisRunning
		setUseDisToggle(autoDisRunning)
	end

	if data.selectedField and FIELDS and FIELDS[data.selectedField] then
		table.clear(selectedFields)
		table.insert(selectedFields, data.selectedField)
		if fieldBtnMap then
			for name, btn in pairs(fieldBtnMap) do
				btn.BackgroundColor3 = name == data.selectedField and COL_ON or COL_OFF
			end
		end
		if updateFieldTabLabel then updateFieldTabLabel() end
	end

	if type(data.tokenPriority) == "table" and ALL_TOKENS then
		for _, t in ipairs(ALL_TOKENS) do
			local saved = data.tokenPriority[t.id]
			if saved ~= nil then
				t.priority = saved
				if tokenPriorityMap then
					tokenPriorityMap[t.id] = saved or nil
				end
			end
		end
		if tokenScroll then
			for _, btn in ipairs(tokenScroll:GetChildren()) do
				if btn:IsA("TextButton") then
					local t = ALL_TOKENS[btn.LayoutOrder]
					if t then
						btn.BackgroundColor3 = t.priority and COL_ON or COL_OFF
					end
				end
			end
		end
	end

	local char = player.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			hum.WalkSpeed    = state.walkSpeed
			hum.UseJumpPower = true
			hum.JumpPower    = state.jumpPower
		end
	end
end

-- Auto save mỗi 30 giây
task.spawn(function()
	while true do
		task.wait(30)
		if state.scriptEnabled then saveSettings() end
	end
end)

-- ================= MINIMIZE =================
local function fadeElement(e, t, dur)
	local ti = TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	if e:IsA("TextButton") or e:IsA("TextLabel") or e:IsA("TextBox") then
		local bg = (t == 0 and originalTransparency[e]) or t
		TweenService:Create(e, ti, {TextTransparency=t, BackgroundTransparency=bg}):Play()
	elseif e:IsA("Frame") or e:IsA("ScrollingFrame") then
		local bg = (t == 0 and originalTransparency[e]) or t
		TweenService:Create(e, ti, {BackgroundTransparency=bg}):Play()
		for _, c in ipairs(e:GetChildren()) do
			if c:IsA("GuiObject") and not c:IsA("UICorner") and not c:IsA("UIListLayout")
				and not c:IsA("UIGridLayout") and not c:IsA("UIPadding") then
				fadeElement(c, t, dur)
			end
		end
	end
end

minimizeBtn.MouseButton1Click:Connect(function()
	if state.isAnimating then return end
	state.isAnimating = true
	state.minimized = not state.minimized
	if state.minimized then
		for _, c in ipairs(contentFrame:GetChildren()) do
			if c:IsA("GuiObject") then
				if c:IsA("TextBox") then c.TextEditable = false end
				if c:IsA("TextButton") then c.Active = false; c.AutoButtonColor = false end
				fadeElement(c, 1, 0.2)
			end
		end
		for _, c in ipairs(tabRow:GetChildren()) do
			if c:IsA("TextButton") then c.Active = false; c.AutoButtonColor = false end
			if c:IsA("GuiObject") then fadeElement(c, 1, 0.2) end
		end
		task.wait(0.2)
		TweenService:Create(contentFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quad), {Size=UDim2.new(1,0,0,0)}):Play()
		TweenService:Create(tabRow,       TweenInfo.new(0.3,Enum.EasingStyle.Quad), {Size=UDim2.new(1,0,0,0)}):Play()
		minimizeBtn.Text = "+"
		task.wait(0.3)
		contentFrame.Visible = false; tabRow.Visible = false
		frame0.Size = UDim2.new(0,500,0,35)
	else
		contentFrame.Visible = true; tabRow.Visible = true
		TweenService:Create(tabRow,       TweenInfo.new(0.3,Enum.EasingStyle.Quad), {Size=UDim2.new(1,0,0,30)}):Play()
		TweenService:Create(contentFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quad), {Size=UDim2.new(1,0,0,270)}):Play()
		minimizeBtn.Text = "-"
		task.wait(0.3)
		for _, c in ipairs(contentFrame:GetChildren()) do
			if c:IsA("GuiObject") then
				if c:IsA("TextBox") then c.TextEditable = true end
				if c:IsA("TextButton") then c.Active = true; c.AutoButtonColor = true end
				fadeElement(c, 0, 0.2)
			end
		end
		for _, c in ipairs(tabRow:GetChildren()) do
			if c:IsA("TextButton") then c.Active = true; c.AutoButtonColor = true end
			if c:IsA("GuiObject") then fadeElement(c, 0, 0.2) end
		end
		task.wait(0.2)
		frame0.Size = UDim2.new(0,500,0,335)
	end
	state.isAnimating = false
end)

-- ================= BUTTON HANDLERS =================
closeBtn.MouseButton1Click:Connect(function()
	saveSettings()
	state.scriptEnabled = false; state.keepWalkSpeed = false; state.autoFarm = false
	local p = workspace:FindFirstChild(PART_NAME); if p then p:Destroy() end
	gui:Destroy()
end)

wsBtn.MouseButton1Click:Connect(function()
	if state.minimized then return end
	local v = tonumber(wsBox.Text); if not v then return end
	state.walkSpeed = math.clamp(v,1,CONFIG.maxWalkSpeed); wsBox.Text = tostring(state.walkSpeed)
	state.keepWalkSpeed = true
	local _, hum = getHumanoid(); hum.WalkSpeed = state.walkSpeed
end)

jpBtn.MouseButton1Click:Connect(function()
	if state.minimized then return end
	local v = tonumber(jpBox.Text); if not v then return end
	state.jumpPower = math.clamp(v,1,CONFIG.maxJumpPower); jpBox.Text = tostring(state.jumpPower)
	local _, hum = getHumanoid(); hum.UseJumpPower = true; hum.JumpPower = state.jumpPower
end)

kcBtn.MouseButton1Click:Connect(function()
	if state.minimized then return end
	local v = tonumber(kcBox.Text); if not v then return end
	state.khoangcachpart = math.clamp(v,1,50); kcBox.Text = tostring(state.khoangcachpart)
	local p = workspace:FindFirstChild(PART_NAME)
	if p then
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		if head then p.CFrame = head.CFrame * CFrame.new(0,state.khoangcachpart,0) end
	end
end)

locateVicBtn.MouseButton1Click:Connect(function()
	if state.minimized then return end
	local wt = WTsFolder:FindFirstChild("WaitingThorn")
	if wt then
		if wt:FindFirstChild("LocateGui") then removeLocate(wt) else createLocate(wt,"📍 VICIOUS THORN",Color3.fromRGB(255,0,0)) end
		return
	end
	local hasAny = false
	for _, c in ipairs(monsters:GetChildren()) do
		if c:IsA("Model") and string.find(string.lower(c.Name),"vicious") then
			local bp = getBeePartFromModel(c); if bp and bp:FindFirstChild("LocateGui") then hasAny = true; break end
		end
	end
	for _, c in ipairs(monsters:GetChildren()) do
		if c:IsA("Model") and string.find(string.lower(c.Name),"vicious") then
			local bp = getBeePartFromModel(c); if bp then
				if hasAny then removeLocate(bp)
				else createLocate(bp,"📍 VICIOUS BEE LV."..(string.match(c.Name,"%d+") or "?"),Color3.fromRGB(255,0,0)) end
			end
		end
	end
end)

locateWindyBtn.MouseButton1Click:Connect(function()
	if state.minimized then return end
	local wp = npcBee:FindFirstChild("Windy")
	if not wp or not wp:IsA("BasePart") then return end
	if wp:FindFirstChild("LocateGui") then removeLocate(wp)
	else createLocate(wp,"📍 WINDY LV."..(getWindyInfoFromMonsters() or "?"),Color3.fromRGB(0,150,255)) end
end)

locateStickerBtn.MouseButton1Click:Connect(function()
	if state.minimized then return end
	local stickers = {}
	for _, c in ipairs(sticker:GetChildren()) do if c.Name=="HiddenStickerPart" then table.insert(stickers,c) end end
	if #stickers == 0 then return end
	local hasLoc = false
	for _, sp in ipairs(stickers) do if sp:FindFirstChild("LocateGui") then hasLoc = true; break end end
	for i, sp in ipairs(stickers) do
		if hasLoc then removeLocate(sp) else createLocate(sp,"📍 STICKER #"..i,Color3.fromRGB(255,215,0)) end
	end
end)

stickerTF:GetPropertyChangedSignal("Text"):Connect(function()
	if stickerTF.Text == "0" then
		for _, c in ipairs(sticker:GetChildren()) do if c.Name=="HiddenStickerPart" then removeLocate(c) end end
	end
end)
vicBeeTF:GetPropertyChangedSignal("Text"):Connect(function()
	if vicBeeTF.Text ~= "True" then
		local wt = WTsFolder:FindFirstChild("WaitingThorn"); if wt then removeLocate(wt) end
		for _, c in ipairs(monsters:GetChildren()) do
			if c:IsA("Model") and string.find(string.lower(c.Name),"vicious") then
				local bp = getBeePartFromModel(c); if bp then removeLocate(bp) end
			end
		end
	end
end)
windyBeeTF:GetPropertyChangedSignal("Text"):Connect(function()
	if windyBeeTF.Text ~= "True" then
		local wp = npcBee:FindFirstChild("Windy"); if wp and wp:IsA("BasePart") then removeLocate(wp) end
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(0.1)
	local _, hum = getHumanoid()
	if state.walkSpeed then hum.WalkSpeed = state.walkSpeed end
	if state.jumpPower then hum.UseJumpPower = true; hum.JumpPower = state.jumpPower end
end)

-- ================= PART MANAGEMENT =================
createPartBtn.MouseButton1Click:Connect(function()
	if state.minimized or workspace:FindFirstChild(PART_NAME) then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local head = char:WaitForChild("Head"); local root = char:WaitForChild("HumanoidRootPart")
	local part = Instance.new("Part")
	part.Name = PART_NAME; part.Size = Vector3.new(6,0.5,6)
	part.Material = Enum.Material.Neon; part.Color = Color3.fromRGB(0,255,0)
	part.Anchored = true; part.CanCollide = true
	part.CFrame = head.CFrame * CFrame.new(0,state.khoangcachpart,0)
	part.Parent = workspace
	TweenService:Create(root, TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out), {
		CFrame = part.CFrame * CFrame.new(0,3,0)
	}):Play()
end)

deletePartBtn.MouseButton1Click:Connect(function()
	if state.minimized then return end
	local p = workspace:FindFirstChild(PART_NAME); if p then p:Destroy() end
end)