ProxmoxVE 操作手冊

- [sops](./sops)

    - [overview](./README.md) 

    - [sop](./sops/sop/sop.md)
        - VM 建置 
        - NAT 簡單實作
        - [架構圖01 (實做到v1)](./sops/routing.jpg)
    
    - [sop2](./sops/sop2/sop2.md)
        - disk 搬移 / 備份

    - [sop3](./sops/sop3/sop3.md)
        - cluster op

    - [sop4](./sops/sop4/sop4.md)
        - qemu-guest-agent
        - PVE API

- [scripts](./scripts/scp/script/)


- notes







- [manuals](./man.md)


- [stack](./other.md)




## Entries

``` yml

rc

disk:
- /etc/fstab  
  # 系統開機時掛載檔案系統的設定檔案（如磁碟分割、自動掛載等）

net:

    if:
        /etc/snmp/snmpd.conf  
        # SNMP (Simple Network Management Protocol) 伺服器的設定檔，通常用於監控系統資源
        /etc/netplan/$(ls /etc/netplan | head -n 1)  
        # Netplan 網路設定檔（Ubuntu 17.10+ 採用），實際檔名會依系統而異
        /etc/network/interfaces  
        # 舊版網路設定檔（適用於使用 ifupdown 而非 netplan 的系統）

    dhcp:
        /etc/dhcp/dhcpd.conf # DHCP 主設定檔 
        /etc/default/isc-dhcp-server #指定使用哪個介面
    
PVE:

    local:
        path: /var/lib/vz/
        dump: /var/lib/vz/dump/             # vm / ct 備份檔: 儲存手動或排程的 VM/CT 備份檔 (.vma/.zst/.lzo)
        images: /var/lib/vz/images/         # disk 映像檔: 儲存使用 raw 或 qcow2 格式的虛擬機映像檔
        templates: /var/lib/vz/template/    # 模板 template / ISO 映像檔（template/iso）與 container 模板（template/cache）

    local-lvm:
        storage_type: LVM-Thin               # 一般用於 VM/CT 的虛擬磁碟儲存（LV 格式，不是檔案）
        device: /dev/pve/data                # 真正的 LVM thin pool 裝置位置
        mount_point: 無（非掛載於檔案系統）    # 不存在一般目錄結構；內容透過 PVE 工具管理
        contains:
            - VM disk images (.raw/.qcow2 的 LVM 對應 LV)
            - LXC container 的 rootfs 資料
        access_via: Proxmox 管理介面或 `lvdisplay`, `lvs`, `pvesh`

    /etc/pve:
        path: /etc/pve/
        description: |
            Proxmox 的叢集配置檔案系統（PVE Cluster File System）
            存放以下重要設定檔：
                - storage.cfg         儲存定義
                - datacenter.cfg      整體設定
                - vzdump.cron         備份排程設定
                - nodes/<node>/qemu-server/<vmid>.conf     每台 VM 的配置檔
                - nodes/<node>/lxc/<ctid>.conf             每個 LXC 的配置檔
        shared_across_nodes: 是的（透過 Corosync 同步）



- ~/.ssh/  
  # 使用者的 SSH 設定資料夾，包括金鑰 (id_rsa)、授權金鑰 (authorized_keys) 等

- 
```

### 2. **PVE (Proxmox Virtual Environment)**

* **說明**：基於 Debian 的虛擬化平台，用來管理 KVM 虛擬機與 LXC 容器。
* **預設網頁管理介面**：`https://<your-ip>:8006`
* **重要檔案與指令**：

  * 設定檔：`/etc/pve/`
  * 虛擬機設定：`/etc/pve/qemu-server/`
  * 節點設定：`/etc/hosts`, `/etc/network/interfaces`

### 3. **local-lvm**

* **說明**：PVE 預設使用的 **LVM-thin 儲存池**，用來儲存 VM 磁碟（如 `vm-100-disk-0`）。

* **在 PVE 中的用途**：

  * 儲存虛擬磁碟、ISO、容器等。

* **查看方式**：

  ```bash
  lvs   # 顯示 LVM volume
  pvs   # 顯示實體磁碟
  vgs   # 顯示 volume group
  ```

* **相關檔案**：

  * `/etc/lvm/lvm.conf`：LVM 設定
  * `/etc/pve/storage.cfg`：PVE 儲存定義設定

### 4. **storage**

* **說明**：PVE 支援多種儲存方式，如 local、local-lvm、NFS、iSCSI、Ceph 等。
* **設定檔**：

  * `/etc/pve/storage.cfg`
* **舉例**（storage.cfg 範例）：

  ```ini
  dir: local
      path /var/lib/vz
      content iso,backup,vztmpl

  lvmthin: local-lvm
      thinpool data
      vgname pve
      content rootdir,images
  ```
