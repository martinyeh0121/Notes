ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11

## PVE API

### PVE API手冊: 目前看起來一樣
官網: https://pve.proxmox.com/pve-docs/api-viewer/index.html
server: https://192.168.16.180:8006/pve-docs/api-viewer/index.html

### API使用

0. bash
curl -k -X GET "https://192.168.16.180:8006/api2/json/access/domains" \
     -H "Authorization: PVEAPIToken=martin@pve\!get-info=22020252-94ea-4ba8-b8a2-d730f3d301f5" \
     > ./result/domains.json

1. python
```python 詳見副檔
base_url = "https://192.168.16.180:8006/api2/json"
endpoint = [
    "/access/domains",       # 身份驗證域的列表（Authentication domains）。
    "/access/domains/pam",   # PAM（Pluggable Authentication Modules）的身份驗證配置。
    "/access/domains/pve",   # Proxmox VE 自帶的身份驗證域配置。
    "/access/groups",        # 使用者群組列表，管理群組及其成員。 空
    "/access/openid",        # OpenID Connect 的配置（單一登入相關）。
    "/access/roles",         # 系統角色的列表及權限分配（定義角色和權限）。
    "/access/tfa",           # 多因素身份驗證（Two-Factor Authentication）設置。
    "/access/users",         # 使用者帳號列表及其詳細資訊。
    "/nodes",                # 節點列表及狀態資訊，每個節點代表一個物理伺服器。
    "/cluster",              # 叢集的狀態資訊，`key["node"]` 為節點名稱。
    "/pools",                # 資源池的列表，便於資源分組管理。
    "/access",               # 使用者及存取權限的綜合資訊。
    "/storage",              # 存儲後端的列表及其詳細資訊。
    "/version"               # Proxmox VE 的版本資訊（包括版本號和詳細描述）。
]
```

### 以下是 Proxmox VE API 各種常見的 `endpoint` 及其用途的詳細註解整理：(GPT) (待讀)


#### **`/access`**
- **`/access/domains`**: 管理身份驗證域（Authentication Domains），例如 LDAP、PAM 等。
- **`/access/groups`**: 管理使用者群組。
- **`/access/roles`**: 查看和管理角色及其權限。
- **`/access/users`**: 查看和管理使用者帳戶。
- **`/access/tfa`**: 多因素身份驗證（Two-Factor Authentication）的設置。
- **`/access/openid`**: 配置 OpenID Connect（單一登入相關功能）。

---

#### **`/cluster`**
- **`/cluster`**: 查看叢集的整體狀態資訊，包括節點列表和配置。
- **`/cluster/resources`**: 查詢叢集中所有資源的統一列表（包括虛擬機、存儲、節點等）。
- **`/cluster/tasks`**: 查詢叢集中執行的所有異步任務。
- **`/cluster/backup`**: 查詢或管理叢集的備份計畫。
- **`/cluster/log`**: 查看叢集日誌記錄。

---

#### **`/nodes`**
- **`/nodes`**: 查看所有節點的列表及基本資訊。
- **`/nodes/{node}/status`**: 獲取特定節點的狀態（資源使用情況）。
- **`/nodes/{node}/qemu`**: 管理節點上的 QEMU 虛擬機（例如創建、刪除、啟動等操作）。
- **`/nodes/{node}/lxc`**: 管理節點上的 LXC 容器。
- **`/nodes/{node}/tasks`**: 查看節點上的任務執行記錄。
- **`/nodes/{node}/log`**: 查看節點的日誌記錄。
- **`/nodes/{node}/services`**: 查看或管理節點上的系統服務。
- **`/nodes/{node}/network`**: 查看和管理節點的網路配置。

---

#### **`/storage`**
- **`/storage`**: 查看和管理存儲後端。
- **`/storage/{storage}`**: 獲取特定存儲的詳細資訊。
- **`/storage/{storage}/content`**: 查看存儲中的內容（例如 ISO 文件、磁碟映像等）。

---

#### **`/pools`**
- **`/pools`**: 查看或管理資源池。
- **`/pools/{pool}`**: 獲取特定資源池的詳細資訊。

---

#### **`/version`**
- **`/version`**: 獲取 Proxmox VE 的版本資訊，包括版本號和編譯日期。

---

#### **`/qemu` (虛擬機相關)**
- **`/nodes/{node}/qemu`**: 查看特定節點上的所有虛擬機。
- **`/nodes/{node}/qemu/{vmid}`**: 查看或管理特定虛擬機（VM）的詳細資訊。
- **`/nodes/{node}/qemu/{vmid}/status`**: 獲取虛擬機的當前運行狀態（例如 running, stopped）。
- **`/nodes/{node}/qemu/{vmid}/snapshot`**: 管理虛擬機的快照。

---

#### **`/lxc` (LXC 容器相關)**
- **`/nodes/{node}/lxc`**: 查看節點上的所有 LXC 容器。
- **`/nodes/{node}/lxc/{vmid}`**: 查看或管理特定容器的資訊。
- **`/nodes/{node}/lxc/{vmid}/status`**: 獲取容器的運行狀態。

---

#### **`/replication`**
- **`/replication`**: 查看或管理叢集中的複製任務（例如資料同步任務）。

---

#### **`/backup`**
- **`/nodes/{node}/vzdump`**: 管理虛擬機和容器的備份。
- **`/nodes/{node}/vzdump/status`**: 查詢備份任務的狀態。

---

#### **用途場景與補充**
1. **叢集與節點管理：**
   - 使用 `/nodes` 和 `/cluster` 系列 API 檢查節點和叢集的運行情況。

2. **虛擬機與容器：**
   - `/qemu` 和 `/lxc` 系列 API 提供了創建、啟動、停止虛擬機和容器的能力。

3. **存儲與備份：**
   - 使用 `/storage` 和 `/backup` API 管理 ISO、磁碟映像和定期備份計畫。

如果有需要更詳細的說明或針對特定 API 的補充，請告訴我！ 😊

### json reply (GPT)
1. 叢集(節點)資訊
endpoint: /nodes
使用: node
```json
node_keys = {
    "node": "節點名稱（即物理伺服器名稱）。",
    "status": "節點的當前狀態，例如 'online', 'offline'。",
    "id": "節點的唯一標識符，例如 'node/node1'。",
    "maxcpu": "節點上的總 CPU 核心數量。",
    "cpu": "節點當前的 CPU 使用率（以百分比的小數表示，例如 0.25 表示 25%）。",
    "maxmem": "節點的總記憶體大小（以 Byte 為單位）。",
    "mem": "節點當前使用的記憶體大小（以 Byte 為單位）。",
    "maxdisk": "節點的總磁碟空間大小（以 Byte 為單位）。",
    "disk": "節點當前使用的磁碟空間大小（以 Byte 為單位）。",
    "loadavg": "節點的系統負載平均值（最近 1 分鐘的值）。",
    "type": "節點類型（通常為 'node'，表示伺服器節點）。",
    "ssl_fingerprint": "節點的 SSL 憑證指紋（用於安全通信驗證）。",
    "uptime": "節點的運行時間（以秒為單位）。",
    "level": "節點的類型，例如 'cluster' 或 'standalone'（叢集或獨立節點）。",
    "id_node": "對應節點 ID 的簡化名稱（如節點名稱）。"
}
```


2. 虛擬機資訊
endpoint: /nodes/{node}/qemu
使用: name tag cpu mem
```json
qemu_keys = { 
    "vmid": "虛擬機的唯一 ID（Virtual Machine ID）。 - /config",
    "name": "虛擬機名稱（可選，描述性名稱）。 - /config",
    "status": "虛擬機狀態，例如 'running', 'stopped', 'paused'。 - /status/current",
    "cpus": "分配給虛擬機的 CPU 核心數。 - /config",
    "maxmem": "分配給虛擬機的最大記憶體（以 Byte 為單位）。 - /config",
    "disk": "虛擬機的磁碟使用量（以 Byte 為單位）。 - /status/current",
    "maxdisk": "虛擬機的磁碟大小上限（以 Byte 為單位）。 - /config",
    "uptime": "虛擬機已運行的時間（以秒為單位）。 - /status/current",
    "cpu": "虛擬機的當前 CPU 使用率（百分比的小數表示，例如 0.25 代表 25%）。 - /status/current",
    "pid": "虛擬機進程 ID（僅在虛擬機正在運行時有效）。 - /status/current",
    "netin": "虛擬機的網路流量輸入量（以 Byte 為單位）。 - /status/current",
    "netout": "虛擬機的網路流量輸出量（以 Byte 為單位）。 - /status/current",
    "template": "是否為模板虛擬機（1 表示模板，0 表示普通虛擬機）。 - /config", //#
    "tags": "虛擬機的標籤（用於標記和分組）。 - /config",
    "type": "類型，通常為 'qemu'（標識為虛擬機）。 - /config",
    "node": "虛擬機所在的節點名稱（即伺服器名稱）。 - /config",
    "agent": "是否啟用了 QEMU Guest Agent（1 表示啟用，0 表示禁用）。 - /config",
    "balloon": "動態記憶體分配大小（如果啟用了 ballooning）。 - /config", //#
    "running-qemu": "虛擬機當前運行的 QEMU 版本。 - /status/current",
    "config": "虛擬機的配置檔案詳細內容。 - /config",
    "snapshots": "虛擬機的快照列表及其相關資訊。 - /snapshot", //#
    "iso": "虛擬機掛載的 ISO 文件（光碟映像）。 - /config",
    "os": "虛擬機的作業系統類型（例如 'linux', 'windows' 等）。 - /config", //#
    "disk-read": "虛擬機的磁碟讀取總量（以 Byte 為單位）。 - /status/current",
    "disk-write": "虛擬機的磁碟寫入總量（以 Byte 為單位）。 - /status/current",
}
```

3. 使用者
role / tag 




