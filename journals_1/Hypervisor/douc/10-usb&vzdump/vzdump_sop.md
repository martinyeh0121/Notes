# PVE VM 備份與 USB 轉移操作指南

本文檔說明如何在 Proxmox VE (PVE) 中使用 vzdump 進行 VM 備份，以及如何將備份檔案轉移到 USB 裝置。

## ✅ VM 備份流程 (vzdump)

### 1. 檢查備份位置

預設的備份位置在：
```bash
cd /var/lib/vz/dump/
```

### 2. 確認 VM 狀態和 ID

```bash
# 列出所有 VM
qm list

# 檢查特定 VM 狀態
qm status <VMID>
```

### 3. 執行 vzdump 備份

```bash
# 基本備份命令
vzdump <VMID>

# 指定格式的備份 (例如: zst 壓縮)
vzdump <VMID> --compress zst

# 完整備份選項範例
vzdump <VMID> \
  --compress zst \
  --mode snapshot \
  --dumpdir /var/lib/vz/dump \
  --maxfiles 3
```

備份檔案格式為：`vzdump-qemu-<VMID>-<DATE>_<TIME>.vma.zst`

## 📦 USB 裝置掛載與檔案轉移

### 1. 檢查 USB 裝置

```bash
# 列出所有塊裝置
lsblk

# 或使用 fdisk 查看詳細資訊
fdisk -l
```

### 2. 建立掛載點並掛載 USB

```bash
# 建立掛載點
mkdir -p /mnt/usb

# 掛載 USB 裝置 (假設裝置為 /dev/sdb)
sudo mount /dev/sdb /mnt/usb
```

### 3. 檔案轉移

```bash
# # 複製備份檔案到 USB (使用具體的備份檔案名稱)
# cp vzdump-qemu-<VMID>-<DATE>_<TIME>.vma.zst /mnt/usb/

# 或複製特定 VM 的備份組 (zst + log + note)
cp vzdump-qemu-<VMID>-<DATE>_<TIME>* /mnt/usb/

# 確認檔案已複製
ls -l /mnt/usb
```

### 4. 卸載 USB 裝置

```bash
# 卸載 USB
sudo umount /dev/sdb
```

## 🔍 常見問題與注意事項

1. **備份前檢查**
   - 確保目標 VM 狀態穩定
   - 檢查備份目錄有足夠空間
   - 建議在低負載時段執行備份

2. **USB 相關注意事項**
   - 使用 `lsblk` 確認正確的 USB 裝置名稱
   - 確保 USB 格式化為 Linux 相容的檔案系統（如 ext4）
   - 轉移大檔案時注意 USB 的空間容量

3. **安全性建議**
   - 備份完成後驗證檔案完整性
   - 重要資料建議使用多個備份位置
   - 定期測試備份檔案的還原功能

## 📝 指令速查表

| 操作 | 指令 |
|------|------|
| 進入備份目錄 | `cd /var/lib/vz/dump/` |
| 列出區塊裝置 | `lsblk` |
| 掛載 USB | `sudo mount /dev/sdb /mnt/usb` |
| 複製備份 | `cp vzdump-qemu-<VMID>-* /mnt/usb/` |
| 卸載 USB | `sudo umount /dev/sdb` |
| VM 狀態檢查 | `qm status <VMID>` |
| 執行備份 | `vzdump <VMID> --compress zst` |