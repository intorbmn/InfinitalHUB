# fnnguyen Hub 🐝

Script hub cho Roblox — hiện hỗ trợ **Bee Swarm Simulator**, có thể mở rộng thêm game sau.

## Cách dùng (người dùng)

Chạy dòng này trong executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/loader.lua"))()
```

---

## Cấu trúc file

```
├── loader.lua       ← người dùng chạy dòng này
├── hub_ui.lua       ← GUI Hub chính (landing screen)
├── bss_main.lua     ← script BSS (copy từ bss_-_fnnguyen.lua)
├── config.json      ← cấu hình hub (version, notice, games list)
└── README.md
```

---

## Setup cho chủ hub (bạn)

### Bước 1 — Tạo GitHub repo
1. Vào [github.com](https://github.com) → **New repository**
2. Đặt tên (VD: `bss-hub`), chọn **Public**
3. Upload tất cả file trong thư mục này lên repo

### Bước 2 — Sửa BASE_URL trong loader.lua
Mở `loader.lua`, sửa dòng này:
```lua
local BASE_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/"
```
Thay `YOUR_USERNAME` và `YOUR_REPO` bằng tên thật của bạn.

### Bước 3 — Đặt script BSS
Copy file `bss_-_fnnguyen.lua` vào repo, đổi tên thành `bss_main.lua`
(hoặc sửa `script_url` trong `config.json` theo tên bạn muốn).

### Bước 4 — Lấy loadstring link
Raw URL của `loader.lua` sẽ có dạng:
```
https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/loader.lua
```

---

## Quản lý từ xa qua config.json

| Field | Tác dụng |
|---|---|
| `version` | Hiển thị version trong hub |
| `notice` | Thông báo cho user (VD: "Vừa update v2!") |
| `enabled` | Set `false` để tắt hub ngay lập tức (kill switch) |
| `discord` | Link Discord — user click sẽ copy link |

### Thêm game mới vào `games` array:
```json
{
    "id": "blox_fruits",
    "name": "Blox Fruits",
    "place_id": 2753915549,
    "icon": "⚔️",
    "status": "active",
    "script_url": "bloxfruits_main.lua"
}
```
Đặt `status: "coming_soon"` nếu chưa có script, nút sẽ tự disable.

---

## Tính năng Hub

- 🎮 **Auto-detect game** — tự nhận ra bạn đang chơi game nào, highlight và cho phép load nhanh
- 📢 **Remote notice** — đẩy thông báo cho tất cả user qua `config.json`
- ⛔ **Kill switch** — tắt hub từ xa nếu cần (`enabled: false`)
- 🖱️ **Draggable** — kéo cửa sổ hub thoải mái
- ➖ **Minimize** — thu nhỏ về title bar
- 📋 **Discord link** — copy link Discord 1 click
