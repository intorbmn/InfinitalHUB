-- ============================================================
--   fnnguyen Hub  |  loader.lua
--   Người dùng chỉ cần chạy file này (1 dòng loadstring)
-- ============================================================

local HttpService = game:GetService("HttpService")

local BASE_URL = "https://raw.githubusercontent.com/intorbmn/InfinitalHUB/main/"

-- ========== FETCH CONFIG ==========
local ok, configRaw = pcall(function()
    return game:HttpGet(BASE_URL .. "config.json")
end)

if not ok then
    warn("[fnnguyen Hub] ❌ Không thể kết nối server. Kiểm tra lại URL hoặc kết nối mạng.")
    return
end

local ok2, config = pcall(function()
    return HttpService:JSONDecode(configRaw)
end)

if not ok2 or type(config) ~= "table" then
    warn("[fnnguyen Hub] ❌ config.json bị lỗi hoặc không đọc được.")
    return
end

-- ========== KILL SWITCH (tắt hub từ xa) ==========
if config.enabled == false then
    warn("[fnnguyen Hub] ⛔ Hub hiện đang tạm ngưng. Vui lòng thử lại sau.")
    if config.notice and config.notice ~= "" then
        warn("[fnnguyen Hub] 📢 " .. config.notice)
    end
    return
end

-- ========== IN THÔNG BÁO ==========
print(string.rep("─", 40))
print(string.format("  %s  v%s  by %s",
    config.hub_name  or "fnnguyen Hub",
    config.version   or "?",
    config.author    or "fnnguyen"))
if config.notice and config.notice ~= "" then
    print("  📢 " .. config.notice)
end
print(string.rep("─", 40))

-- ========== INJECT CONFIG VÀO GLOBAL ==========
-- hub_ui.lua sẽ đọc _G.HUB_CONFIG để biết BASE_URL và config
_G.HUB_CONFIG = {
    base_url   = BASE_URL,
    remote_cfg = config,
}

-- ========== LOAD HUB UI ==========
local ok3, uiRaw = pcall(function()
    return game:HttpGet(BASE_URL .. "hub_ui.lua")
end)

if not ok3 then
    warn("[fnnguyen Hub] ❌ Không load được hub_ui.lua: " .. tostring(uiRaw))
    return
end

local fn, err = loadstring(uiRaw)
if not fn then
    warn("[fnnguyen Hub] ❌ Lỗi compile hub_ui.lua: " .. tostring(err))
    return
end

local ok4, err4 = pcall(fn)
if not ok4 then
    warn("[fnnguyen Hub] ❌ Lỗi runtime hub_ui.lua: " .. tostring(err4))
end
