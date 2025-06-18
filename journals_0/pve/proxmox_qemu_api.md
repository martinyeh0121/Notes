# Proxmox VE API - `/nodes/{node}/qemu/{vmid}` 詳細說明

在 Proxmox VE API 中，`/nodes/{node}/qemu/{vmid}` 之下有多個子路徑可用來管理 QEMU 虛擬機，以下是完整列表與簡要說明。

---

## 1️⃣ `/config` - 獲取或修改 VM 設定
- **`GET /nodes/{node}/qemu/{vmid}/config`**：獲取 VM 的所有設定，如 CPU、記憶體、磁碟、網卡等。
- **`POST /nodes/{node}/qemu/{vmid}/config`**：修改 VM 設定，例如變更 CPU、RAM、網路卡等（部分參數需要關機才能修改）。

---

## 2️⃣ `/status` - 查看或操作 VM 狀態
- **`GET /nodes/{node}/qemu/{vmid}/status/current`**：獲取 VM 的當前狀態（如 CPU 使用率、記憶體、磁碟、網速、運行時間等）。
- **`GET /nodes/{node}/qemu/{vmid}/status/stop`**：關閉 VM。
- **`GET /nodes/{node}/qemu/{vmid}/status/start`**：啟動 VM。
- **`GET /nodes/{node}/qemu/{vmid}/status/reset`**：重置（強制重啟）VM。
- **`GET /nodes/{node}/qemu/{vmid}/status/shutdown`**：正常關機（需要 VM 內部支援 ACPI）。
- **`GET /nodes/{node}/qemu/{vmid}/status/suspend`**：暫停 VM（需要支援）。
- **`GET /nodes/{node}/qemu/{vmid}/status/resume`**：從暫停狀態恢復 VM。

---

## 3️⃣ `/agent` - QEMU Guest Agent（需安裝 Guest Agent）
- **`GET /nodes/{node}/qemu/{vmid}/agent/get-osinfo`**：獲取 VM 內部的作業系統資訊。
- **`GET /nodes/{node}/qemu/{vmid}/agent/get-fsinfo`**：獲取 VM 內部的磁碟資訊。
- **`GET /nodes/{node}/qemu/{vmid}/agent/get-users`**：獲取 VM 內部的登入使用者。
- **`GET /nodes/{node}/qemu/{vmid}/agent/network-get-interfaces`**：獲取 VM 內部的網路介面資訊。

---

## 4️⃣ `/vncproxy` & `/vncwebsocket` - 遠端桌面（VNC 控制）
- **`POST /nodes/{node}/qemu/{vmid}/vncproxy`**：創建 VNC 連線會話，返回 `port` 和 `ticket`。
- **`GET /nodes/{node}/qemu/{vmid}/vncwebsocket`**：透過 WebSocket 連接 VNC。

---

## 5️⃣ `/monitor` - 向 QEMU 監控台發送命令
- **`POST /nodes/{node}/qemu/{vmid}/monitor`**：發送 QEMU 監控台指令，例如掛載磁碟、修改設定等。

---

## 6️⃣ `/migrate` - 遷移 VM
- **`POST /nodes/{node}/qemu/{vmid}/migrate`**：將 VM 遷移到其他節點。

---

## 7️⃣ `/resize` - 擴展 VM 磁碟
- **`POST /nodes/{node}/qemu/{vmid}/resize`**：擴展 VM 磁碟大小（適用於 LVM、qcow2 等格式）。

---

## 8️⃣ `/snapshot` - 快照管理
- **`GET /nodes/{node}/qemu/{vmid}/snapshot`**：獲取 VM 所有快照。
- **`POST /nodes/{node}/qemu/{vmid}/snapshot`**：創建快照。
- **`POST /nodes/{node}/qemu/{vmid}/snapshot/{snapname}/rollback`**：回滾到某個快照。
- **`DELETE /nodes/{node}/qemu/{vmid}/snapshot/{snapname}`**：刪除快照。

---

## 9️⃣ `/spiceproxy` - Spice 遠端桌面
- **`POST /nodes/{node}/qemu/{vmid}/spiceproxy`**：獲取 SPICE 連線資訊。

---

## 🔟 `/termproxy` - QEMU 內部 Shell
- **`POST /nodes/{node}/qemu/{vmid}/termproxy`**：開啟一個 Shell 會話（如果 VM 支援）。

---

## 1️⃣1️⃣ `/cloudinit` - Cloud-init 設定（適用於雲端 VM）
- **`GET /nodes/{node}/qemu/{vmid}/cloudinit`**：獲取 cloud-init 設定。
- **`POST /nodes/{node}/qemu/{vmid}/cloudinit`**：更新 cloud-init 設定。

---

## 1️⃣2️⃣ `/firewall` - VM 防火牆設定
- **`GET /nodes/{node}/qemu/{vmid}/firewall`**：獲取 VM 防火牆設定。
- **`POST /nodes/{node}/qemu/{vmid}/firewall/rules`**：新增防火牆規則。

---

## 📌 API 總結

| API Endpoint | 功能 |
|-------------|------|
| `/config` | 獲取/修改 VM 設定 |
| `/status/current` | 查詢 VM 當前狀態 |
| `/status/start` | 啟動 VM |
| `/status/stop` | 強制關閉 VM |
| `/status/shutdown` | 正常關機 VM |
| `/status/suspend` | 暫停 VM |
| `/status/resume` | 恢復 VM |
| `/agent/get-osinfo` | 取得 VM 內部 OS 資訊 |
| `/agent/network-get-interfaces` | 取得 VM 內部網卡資訊 |
| `/vncproxy` | 取得 VNC 連線資訊 |
| `/vncwebsocket` | 透過 WebSocket 連接 VNC |
| `/monitor` | 向 QEMU 監控台發送指令 |
| `/migrate` | VM 遷移到其他節點 |
| `/resize` | 擴展 VM 磁碟 |
| `/snapshot` | 創建/管理快照 |
| `/snapshot/{snapname}/rollback` | 回滾快照 |
| `/firewall` | 設定 VM 防火牆 |
| `/cloudinit` | 設定 Cloud-init |
| `/spiceproxy` | 取得 SPICE 連線資訊 |

---

這些 API 幾乎可以對 VM 進行所有的管理操作 🚀  



QEMU(Quick Emulator)