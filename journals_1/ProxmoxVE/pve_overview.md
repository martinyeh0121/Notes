| 路徑                        | 用途                | 是否建議備份？          | 備註                  |
| ------------------------- | ----------------- | ---------------- | ------------------- |
| `/var/lib/pve-cluster/`   | Cluster 資料庫       | ✅ 若你還想還原 cluster | 包含 `config.db`      |
| `/etc/network/interfaces` | 網路設定              | ✅ 強烈建議           | 包含 VM bridge、VLAN 等 |
| `/etc/hosts`              | 本地 DNS 設定         | ✅                | Proxmox 有用到         |
| `/etc/resolv.conf`        | DNS 設定            | ✅                | 通常一起備份              |
| `/etc/hostname`           | 節點名稱              | ✅                | 與 cluster 名稱有關      |
| `/etc/fstab`              | 磁碟掛載設定            | ✅                | 若使用 NFS、iSCSI 等     |
| `/etc/storage.cfg`（如果存在）  | 自訂 storage 設定     | ✅                | 舊版 Proxmox 可能有      |
| `/etc/lvm/`               | LVM 設定            | ✅                | 如果你用 LVM-thin       |
| `/etc/zfs/`               | ZFS 設定            | ✅                | 如果你用 ZFS 儲存池        |
| `/root/`                  | root 帳號設定與 script | ✅ 個人            | 有時放備份/自訂 script     |
| `/etc/cron.*`             | 備份排程與腳本           | ✅                | 包含自訂 cron 任務        |
