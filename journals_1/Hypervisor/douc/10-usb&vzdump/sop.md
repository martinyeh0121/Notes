以下是您在 Linux 上操作 NFS 掛載與效能測試的流程整理，包括 **掛載流程** 和 **網路儲存效能測試（透過 `dd` 與 `iperf3`）**：

---

## ✅ NFS 掛載流程整理

### 1. 安裝 NFS 所需套件（客戶端）

```bash
sudo apt update
sudo apt install nfs-common -y
```

### 2. 檢查 NFS 伺服器可用的共享路徑

```bash
showmount -e 172.16.1.202
```

輸出範例（表示伺服器 IP 為 172.16.1.202 的共享資料夾）：

```
Export list for 172.16.1.202:
/mnt/stable *
```

### 3. 建立掛載點資料夾（若尚未建立）

```bash
sudo mkdir -p /mnt/nas
```

### 4. 掛載 NFS 資料夾

```bash
sudo mount -t nfs 172.16.1.202:/mnt/stable /mnt/nas
```

### 5. 檢查掛載情況

```bash
df -h
# 或僅查看掛載點空間使用情況
df -h /mnt/nas
```

### 6. 卸載（如果需要重新掛載）

```bash
sudo umount /mnt/nas
```

---

## 🚀 效能測試流程整理

### 1. 使用 `dd` 測試讀取速度（直接從 NFS 讀到記憶體）

```bash
dd if=/mnt/nas/path/to/yourfile of=/dev/null bs=1G count=5 iflag=direct
```

範例結果：

```bash
5+0 records in
5+0 records out
5368709120 bytes (5.4 GB, 5.0 GiB) copied, 7.65 s, 702 MB/s
```

📝 解釋：

* `bs=1G`: 每次讀 1GB
* `count=5`: 讀 5 次，共 5GB
* `iflag=direct`: 直接 I/O，避免使用快取
* `of=/dev/null`: 只測試讀取速度（不寫入磁碟）

### 2. 寫入速度測試（寫入 NFS）

```bash
dd if=/dev/zero of=/mnt/nas/testfile bs=1G count=5 oflag=direct
```

📝 解釋：

* `oflag=direct`: 避免系統快取，真實寫入速度
* 測試完可以刪除檔案：`rm /mnt/nas/testfile`

### 3. 使用 `iperf3` 測試網路速度

#### 伺服器端（例如：NFS Server 上執行）

```bash
iperf3 -s
```

#### 用戶端執行（例如：目前這台 client）

```bash
iperf3 -c 172.16.1.202
```

範例輸出：

```
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-10.00 sec  1.08 GBytes   926 Mbits/sec
```

---

## 📌 其他實用指令

### 找出最大的檔案

```bash
find /mnt/nas -type f -exec du -h {} + 2>/dev/null | sort -hr | head -n 10
```

---

## 🧾 總結

| 操作項目      | 指令摘要                                                     |          |        |
| --------- | -------------------------------------------------------- | -------- | ------ |
| 安裝 NFS    | `sudo apt install nfs-common -y`                         |          |        |
| 掛載 NFS    | `sudo mount -t nfs 172.16.1.202:/mnt/stable /mnt/nas`    |          |        |
| 卸載 NFS    | `sudo umount /mnt/nas`                                   |          |        |
| NFS 讀效能測試 | `dd if=yourfile of=/dev/null bs=1G count=5 iflag=direct` |          |        |
| NFS 寫效能測試 | `dd if=/dev/zero of=testfile bs=1G count=5 oflag=direct` |          |        |
| 網路速度測試    | `iperf3 -c 172.16.1.202`                                 |          |        |
| 列出最大檔案    | \`find /mnt/nas -type f -exec du -h {} +                 | sort -hr | head\` |

---

如需我幫你產出這些內容的 `.md` 或 `.sh` 文件，可直接告訴我。
