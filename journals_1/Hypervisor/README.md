# ProxmoxVE 操作手冊

## 目錄

### 基礎設定 (0)
- [DHCP 服務器設置](./douc/0-pve_dhcp/sop.md#dhcp-伺服器設定) `start: 20250626`
  - DHCP 主設定檔配置
  - 網路介面設定
  - 服務啟動與監控

### VM 建置與管理 (1)
- [PVE 基礎建置](./douc/1-pve_basic/sop.md#proxmoxve-vm-建置) `start: 20250625`
  - PVE Node 套件來源設定
  - Ubuntu VM 建置流程
  - SSH 設定與免密碼登入
  - 網路拓樸配置
  - [架構圖](./douc/1-pve_basic/routing.jpg)

#### VM 進階設定 (1)
- [VM 自動安裝](./douc/1_1-pve_vm_autoinstall/sop.md#vm-自動安裝) `start: 20250722`
  - Autoinstall 設定
  - 自動化部署流程
  - 配置管理

- [VM Cloud-Init](./douc/1_2-pve_vm_cloudinit/sop.md#vm-cloudinit) `start: 20250707`
  - Cloud-Init 配置
  - 雲端初始化設定
  - 自動化部署

- [VM 資源管理](./douc/1_3-pve_vm_resource/sop.md#vm-資源管理) `start: 20250703`
  - CPU/記憶體配置
  - 資源限制設定
  - 效能監控

### 系統維護 (2-4)
- [磁碟搬移](./douc/2-pve_disk_move/sop.md#磁碟搬移) `start: 20250702`
  - 磁碟搬移流程
  - 備份策略設定
  - 還原程序

- [叢集管理](./douc/3-pve_cluster/sop.md#叢集管理) `start: 20250708`
  - 叢集建置
  - 節點管理
  <!-- - 高可用性設定 -->

- [Agent 與 API](./douc/4-pve_agent_api/sop.md#agent-與-api) `start: 20250709`
  - qemu-guest-agent
  - PVE API
  - 系統整合

### 系統監控 (5-6)

- [SNMP 與 Cacti](./douc/5-snmp_cacti/sop.md#snmp-與-cacti) `start: 20250710`
  - SNMP 配置
  - Cacti 監控
  - 效能數據收集

- [Cacti Puller](./douc/6-cacti_puller/sop.md#cacti-puller) `start: 20250717`
  - 數據收集
  - 監控配置
  - 效能分析

### PVE 進階_實作與測試 (7-8)

- [PVE 節點重命名](./douc/7_1-pve_rename_node/sop.md#pve-節點重命名) `start: 20250729`
  - 節點命名規則
  - 重命名流程
  - 配置更新

- [Linux 系統重命名](./douc/7_2-pve_rename_linux/sop.md#linux-系統重命名) `start: 20250806`
  - 系統命名設定
  - 主機名配置
  - 網路設定更新

- [Ceph 存儲](./douc/8-pve_ceph/sop.md#ceph-存儲) `start: 20250731`
  - Ceph 部署
  - 存儲配置
  - 叢集管理



## PVE 系統架構

### 重要路徑
```yml
rc:
  disk:
    - /etc/fstab  # 系統開機時掛載檔案系統的設定檔案

  net:
    if:
      - /etc/snmp/snmpd.conf      # SNMP 伺服器設定檔
      - /etc/netplan/             # Netplan 網路設定檔（Ubuntu 17.10+）
      - /etc/network/interfaces   # 舊版網路設定檔

    dhcp:
      - /etc/dhcp/dhcpd.conf          # DHCP 主設定檔 
      - /etc/default/isc-dhcp-server  # 指定使用哪個介面
    
PVE:
  local:
    path: /var/lib/vz/
    dump: /var/lib/vz/dump/        # VM/CT 備份檔 (.vma/.zst/.lzo)
    images: /var/lib/vz/images/    # disk 映像檔 (raw/qcow2)
    templates: /var/lib/vz/template/ # 模板與 ISO 映像檔

  local-lvm:
    storage_type: LVM-Thin        # VM/CT 虛擬磁碟儲存
    device: /dev/pve/data         # LVM thin pool 裝置位置
    mount_point: 無（非掛載）      # 透過 PVE 工具管理
    contains:
      - VM disk images (.raw/.qcow2 的 LV)
      - LXC container rootfs 資料

  ceph:
    config: /etc/ceph/ceph.conf   # Ceph 主要配置文件，cluster 會連結至 /etc/pve
    keyring: /etc/ceph/ceph.client.admin.keyring  # Ceph 管理員金鑰
    mon: /var/lib/ceph/mon/      # Monitor 守護進程數據
    osd: /var/lib/ceph/osd/      # OSD 守護進程數據
    status_check: |
      ceph -s                    # 集群狀態
      ceph health detail         # 健康狀態詳情
      ceph osd tree             # OSD 樹狀結構

  /etc/pve:
    path: /etc/pve/
    description: |
      Proxmox 的叢集配置檔案系統，存放：
        - storage.cfg         # 儲存定義
        - datacenter.cfg      # 整體設定
        - vzdump.cron         # 備份排程
        - nodes/<node>/qemu-server/<vmid>.conf  # VM 配置
        - nodes/<node>/lxc/<ctid>.conf          # LXC 配置
        - ceph.conf           # ceph 叢集配置文件
    shared_across_nodes: 是（透過 Corosync 同步）
    priv_key_files: |
      - /etc/pve/priv/authorized_keys   # SSH 授權金鑰
      - /etc/pve/priv/pve-root-ca.key   # PVE Root CA 私鑰
      - /etc/pve/priv/pve-ssl.key       # PVE SSL 私鑰
      - /etc/pve/priv/ticket.key        # Ticket 加密金鑰
      - /etc/pve/priv/<node>.key        # 節點 RSA 私鑰
      - /etc/pve/priv/<node>.pub        # 節點 RSA 公鑰

ssh:
  - ~/.ssh/                 # SSH 設定，包括金鑰與授權
  - ~/.ssh/id_rsa          # SSH 私鑰
  - ~/.ssh/id_rsa.pub      # SSH 公鑰
  - ~/.ssh/authorized_keys # 授權的公鑰列表
  - ~/.ssh/known_hosts     # 已知主機的公鑰
  - ~/.ssh/config          # SSH 客戶端配置

### PVE 系統說明
- 基於 Debian 的虛擬化平台，管理 KVM 虛擬機與 LXC 容器
- 預設網頁管理介面：`https://<your-ip>:8006`
- 重要檔案位置：
  - 設定檔：`/etc/pve/`
  - 虛擬機設定：`/etc/pve/qemu-server/`
  - 節點設定：`/etc/hosts`, `/etc/network/interfaces`

### 存儲管理
- **local-lvm**：
  - PVE 預設使用的 LVM-thin 儲存池
  - 用於儲存 VM 磁碟（如 `vm-100-disk-0`）
  - 管理指令：
    ```bash
    lvs   # 顯示 LVM volume
    pvs   # 顯示實體磁碟
    vgs   # 顯示 volume group
    ```
  - 相關設定檔：
    - `/etc/lvm/lvm.conf`：LVM 設定
    - `/etc/pve/storage.cfg`：PVE 儲存定義

- **儲存類型**：
  - 支援：local、local-lvm、NFS、iSCSI、Ceph 等
  - 設定範例（storage.cfg）：
    ```ini
    dir: local
        path /var/lib/vz
        content iso,backup,vztmpl

    lvmthin: local-lvm
        thinpool data
        vgname pve
        content rootdir,images
    ```

## 注意事項
1. 所有操作前請確保已備份重要數據
2. 遵循標準操作流程進行維護
3. 重要配置變更請記錄在文檔中
4. 定期檢查系統日誌和監控數據
5. 重要更改前先在測試環境驗證