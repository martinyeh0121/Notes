## qm
``` sh
USAGE:     qm <COMMAND> [ARGS] [OPTIONS]

       qm cloudinit dump <vmid> <type>
       qm cloudinit pending <vmid>
       qm cloudinit update <vmid>

       qm disk move <vmid> <disk> [<storage>] [OPTIONS]
       qm disk resize <vmid> <disk> <size> [OPTIONS]
       qm disk unlink <vmid> --idlist <string> [OPTIONS]
       qm disk import <vmid> <source> <storage> [OPTIONS]
       qm disk rescan  [OPTIONS]

       qm guest cmd <vmid> <command>
       qm guest exec-status <vmid> <pid>
       qm guest passwd <vmid> <username> [OPTIONS]
       qm guest exec <vmid> [<extra-args>] [OPTIONS]

       qm clone <vmid> <newid> [OPTIONS]
       qm config <vmid> [OPTIONS]
       qm create <vmid> [OPTIONS]
       qm delsnapshot <vmid> <snapname> [OPTIONS]
       qm destroy <vmid> [OPTIONS]
       qm list  [OPTIONS]
       qm listsnapshot <vmid>
       qm migrate <vmid> <target> [OPTIONS]
       qm pending <vmid>
       qm reboot <vmid> [OPTIONS]
       qm reset <vmid> [OPTIONS]
       qm resume <vmid> [OPTIONS]
       qm rollback <vmid> <snapname> [OPTIONS]
       qm sendkey <vmid> <key> [OPTIONS]
       qm set <vmid> [OPTIONS]
       qm shutdown <vmid> [OPTIONS]
       qm snapshot <vmid> <snapname> [OPTIONS]
       qm start <vmid> [OPTIONS]
       qm stop <vmid> [OPTIONS]
       qm suspend <vmid> [OPTIONS]
       qm template <vmid> [OPTIONS]

       qm cleanup <vmid> <clean-shutdown> <guest-requested>
       qm import <vmid> <source> --storage <string> [OPTIONS]
       qm importovf <vmid> <manifest> <storage> [OPTIONS]
       qm monitor <vmid>
       qm mtunnel 
       qm nbdstop <vmid>
       qm remote-migrate <vmid> [<target-vmid>] <target-endpoint> --target-bridge <string> --target-storage <string> [OPTIONS]
       qm showcmd <vmid> [OPTIONS]
       qm status <vmid> [OPTIONS]
       qm terminal <vmid> [OPTIONS]
       qm unlock <vmid>
       qm vncproxy <vmid>
       qm wait <vmid> [OPTIONS]

       qm help [<extra-args>] [OPTIONS]


# disk

# local
pvesm alloc local 100 qcow2 10G



qm set <vmid> -<interface><index> <storage>:<size>
qm set 100 -scsi1 local-lvm:10G
qm set 100 -scsi1 local:10G
qm set <vmid> -delete <interface><index>


# local-lvm
pvesm remove <storage>:<diskname>
pvesm remove local-lvm:vm-100-disk-1

qm set 702 -delete scsi1

```


## iptable


## route


## sed


#

以下是依照功能分類的 Ubuntu 常用指令整理，包括：網路、編譯環境、硬體配置、磁碟與儲存、容器化、系統監控、用戶與權限、安全性等面向。

---

## 🔌 網路（Networking）

| 功能         | 指令                                     | 說明                           |
| ---------- | -------------------------------------- | ---------------------------- |
| 顯示IP/網路介面  | `ip a` 或 `ifconfig`                    | 查看目前的網路設定                    |
| 顯示路由表      | `ip r` 或 `route -n`                    | 查看路由設定                       |
| 測試網路連線     | `ping 8.8.8.8`、`ping google.com`       | 測試網路是否正常                     |
| 顯示開啟的 port | `ss -tuln`、`netstat -tuln`             | 查看正在聽的 port（ss 較新）           |
| 檢查DNS解析    | `dig google.com`、`nslookup google.com` | 測試 DNS                       |
| 設定靜態IP     | 編輯 `/etc/netplan/*.yaml`               | Ubuntu 18.04+ 用 Netplan 管理網路 |

---

## ⚙️ 編譯環境 / 程式開發

| 功能        | 指令                                                 | 說明               |
| --------- | -------------------------------------------------- | ---------------- |
| 安裝 GCC    | `sudo apt install build-essential`                 | 安裝基本 C/C++ 編譯工具  |
| Python 環境 | `python3 --version`、`sudo apt install python3-pip` | 安裝與檢查 Python     |
| 虛擬環境      | `python3 -m venv env`                              | 建立虛擬環境           |
| Node.js   | `sudo apt install nodejs npm`                      | 安裝 Node.js 與 npm |
| 套件管理      | `pip install pandas`、`npm install express`         | Python / JS 套件安裝 |
| 交叉編譯工具    | `sudo apt install gcc-arm-none-eabi`               | 針對嵌入式裝置等交叉編譯器    |

---

## 💽 硬體與系統資訊

| 功能      | 指令                            | 說明          |
| ------- | ----------------------------- | ----------- |
| 查看CPU   | `lscpu`                       | 顯示 CPU 詳細資訊 |
| 查看記憶體   | `free -h`、`cat /proc/meminfo` | 顯示 RAM 使用狀況 |
| 查看硬碟與掛載 | `lsblk`、`df -h`、`mount`       | 查看磁碟與掛載情況   |
| 顯示裝置資訊  | `lshw`、`lspci`、`lsusb`        | 顯示硬體細節      |
| 檢查溫度    | `sensors`（需先安裝 `lm-sensors`）  | 顯示硬體溫度      |

---

## 💾 磁碟與檔案系統 + PVE / LVM 互動

### 🔍 一般磁碟操作（Ubuntu 基礎）

| 功能      | 指令                     | 說明             |
| ------- | ---------------------- | -------------- |
| 顯示磁碟與分割 | `lsblk`、`fdisk -l`     | 檢查有哪些磁碟與分割區    |
| 顯示 UUID | `blkid`                | 顯示裝置的 UUID 與類型 |
| 掛載裝置    | `mount /dev/sdX1 /mnt` | 手動掛載磁碟或分割區     |
| 建立檔案系統  | `mkfs.ext4 /dev/sdX1`  | 格式化成 EXT4      |
| 查看掛載狀況  | `df -h`、`mount`        | 顯示掛載點與使用量      |
| 永久掛載    | 編輯 `/etc/fstab`        | 設定開機自動掛載       |

---

### 🧱 LVM 基礎（Ubuntu / PVE 共通）

| 功能                 | 指令                                   | 說明               |
| ------------------ | ------------------------------------ | ---------------- |
| 顯示 LVM 磁碟資訊        | `pvdisplay`、`vgdisplay`、`lvdisplay`  | 分別顯示實體磁碟、卷組、邏輯卷  |
| 掃描所有 PV            | `pvs`、`vgs`、`lvs`                    | 精簡顯示 PV/VG/LV 概況 |
| 建立 Physical Volume | `pvcreate /dev/sdX`                  | 初始化新的實體磁碟        |
| 建立 Volume Group    | `vgcreate vgdata /dev/sdX`           | 建立卷組             |
| 建立 Logical Volume  | `lvcreate -L 100G -n lvdata vgdata`  | 建立邏輯卷            |
| 格式化 LV             | `mkfs.ext4 /dev/vgdata/lvdata`       | 建立檔案系統於 LV 上     |
| 掛載 LV              | `mount /dev/vgdata/lvdata /mnt/data` | 掛載邏輯卷            |

---

### 📦 Proxmox VE (PVE) LVM 實務操作

| 功能                  | 指令 / 操作                                                  | 說明                                 |
| ------------------- | -------------------------------------------------------- | ---------------------------------- |
| 查看儲存池（Storage）      | Web GUI 或 `pvesm status`                                 | 查看所有儲存狀態（含 LVM）                    |
| 建立 LVM 磁碟池          | `pvesm add lvm NAME --vgname VGNAME`                     | 在 PVE 新增 LVM 儲存                    |
| 列出 PVE 支援儲存類型       | `pvesm list`、`pvesm status`                              | 顯示 LVM-thin、ZFS、Dir 等儲存類型          |
| 新增 LVM-thin         | `pvesm add lvmthin NAME --vgname VG --thinpool THINPOOL` | 建立 LVM-thin 儲存（支援 snapshot）        |
| 在 GUI 建立 VM 時選用 LVM | Web GUI → 儲存選單                                           | 使用 LVM 或 LVM-thin 作為 VM 磁碟 backend |
| 刪除 VM 後清除 LV        | `lvremove /dev/vgname/vm-100-disk-0`                     | VM 刪除後殘留磁碟需手動移除                    |
| 調整 LV 大小            | `lvextend -L +50G /dev/vgdata/lvdata` + `resize2fs`      | 擴充 LV 容量後需調整檔案系統                   |

---

### 🧰 進階應用

| 情境          | 指令                                               | 說明               |
| ----------- | ------------------------------------------------ | ---------------- |
| 磁碟熱插拔後掃描    | `echo "- - -" > /sys/class/scsi_host/hostX/scan` | 掃描新磁碟（替代 reboot） |
| LV Snapshot | `lvcreate -s -L 5G -n snap1 /dev/vgdata/lvdata`  | 建立快照             |
| 還原 Snapshot | `lvconvert --merge /dev/vgdata/snap1`            | 從快照還原            |
| 移除 VG / LV  | `vgremove`、`lvremove`                            | 小心操作，會清除資料！      |

---

如果你常用 **PVE GUI** 進行管理，建議搭配 CLI 作以下事務：

* 🛠 清除殘留磁碟（VM 已刪但 LVM 未移除）
* 📈 建立自定儲存池（支援 snapshot 的 LVM-thin）
* 🚀 透過 CLI 先設定好大容量磁碟，再從 GUI 新增 VM 使用

---

## 📦 容器與虛擬化

| 功能         | 指令                                     | 說明                |
| ---------- | -------------------------------------- | ----------------- |
| Docker 安裝  | `sudo apt install docker.io`           | 安裝 Docker         |
| 執行容器       | `docker run -it ubuntu bash`           | 啟動 Ubuntu 容器      |
| 查看容器狀態     | `docker ps -a`                         | 查看目前容器            |
| 建立映像檔      | `docker build -t myimage .`            | 用 Dockerfile 建映像檔 |
| LXD/LXC 管理 | `lxc launch ubuntu:20.04 my-container` | 輕量級容器管理           |

---

## 📊 系統監控與效能分析

| 功能        | 指令                                     | 說明       |
| --------- | -------------------------------------- | -------- |
| 即時監控      | `top`、`htop`（需安裝）                      | 顯示系統資源使用 |
| 查看系統啟動時間  | `uptime`、`who -b`                      | 顯示開機時間   |
| 磁碟 I/O 分析 | `iotop`（需安裝）                           | 顯示磁碟存取狀況 |
| 系統日誌      | `journalctl`、`dmesg`、`/var/log/syslog` | 查看系統事件記錄 |

---

## 👤 用戶與權限

| 功能   | 指令                            | 說明                |
| ---- | ----------------------------- | ----------------- |
| 新增用戶 | `sudo adduser alice`          | 建立新用戶             |
| 更改群組 | `sudo usermod -aG sudo alice` | 加入 sudo 群組        |
| 切換用戶 | `su - alice`                  | 切換到其他使用者          |
| 設定密碼 | `passwd alice`                | 更改密碼              |
| 檢查身份 | `id`、`whoami`                 | 查看目前的 UID/GID 等資訊 |

---

## 🔒 安全性與防火牆

| 功能                    | 指令                                    | 說明                                |
| --------------------- | ------------------------------------- | --------------------------------- |
| 防火牆設定                 | `sudo ufw enable`、`sudo ufw allow 22` | 啟用與設定防火牆                          |
| 查看防火牆規則               | `sudo ufw status verbose`             | 查看目前防火牆狀態                         |
| SELinux / AppArmor 狀態 | `aa-status`                           | AppArmor 狀態查看（Ubuntu 多用 AppArmor） |
| 權限修改                  | `chmod`、`chown`                       | 修改檔案/資料夾權限                        |
