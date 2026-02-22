# Infinital Hub 🐝

Script hub cho Roblox — hiện hỗ trợ **Bee Swarm Simulator**, có thể mở rộng thêm game sau.

## Cách dùng (người dùng)

Chạy dòng này trong executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/intorbmn/InfinitalHUB/main/loader.lua"))()
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
