# ProxmoxVE createVM_NAT0 說明

本資料夾提供在 Proxmox VE 上建立 Ubuntu 虛擬機（VM）與 NAT 網路設定的完整操作手冊。

## 內容摘要
- *sop/sop.md**：詳細步驟說明，包含：
  - Proxmox VE 軟體來源（Repository）修改方法
  - 下載 Ubuntu ISO 檔案建議
  - VM 建立與 Ubuntu 安裝（手動與自動腳本）
  - SSH 伺服器安裝與免密碼登入設定
  - 網路拓樸調整與 NAT 設定練習

  - **image.png / image-1.png / image-2.png**：操作截圖輔助說明 
- **sop2/sop2.md**：VM 新增硬碟、分割、格式化與掛載教學，並簡介 vzdump 備份操作。
  - 如何於 Proxmox UI 新增 VM 硬碟
  - 使用 fdisk 建立分割區、mkfs.ext4 格式化、mount 掛載
  - 驗證掛載點與查詢 UUID
  - 附有 vzdump 備份相關連結與截圖
 
  - **image-3.png**：操作截圖輔助說明

## 適用對象
- 初次接觸 Proxmox VE 或需標準化 VM 建置流程的同仁
- 需要快速完成 Ubuntu VM 部署、NAT 網路與硬碟掛載設定的使用者

## 快速開始
1. 依照 `sop/sop.md` 步驟操作，可選擇手動或自動腳本方式建立 VM
2. 若需新增硬碟與掛載，請參考 `sop2/sop2.md`
3. 參考圖片輔助理解每個步驟
4. 如需 SSH、NAT 或硬碟設定，請參考對應章節
