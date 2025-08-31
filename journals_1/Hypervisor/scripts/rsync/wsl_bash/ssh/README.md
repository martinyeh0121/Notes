# SSH 設定工具

這個工具集提供了簡單的方式來設定 SSH 金鑰和配置檔案，支援單機和批次處理模式。

## 功能特點

- 自動安裝必要的依賴（如 sshpass）
- 支援互動式、命令列和批次處理模式
- 自動組織 SSH 設定檔案
- 支援多層目錄結構的金鑰管理

## 目錄結構

```
.
├── bin/           # 執行檔
│   ├── ssh-setup      # 互動式設定
│   ├── ssh-init       # 命令列設定
│   └── ssh-batch-init # 批次處理設定
├── config/        # 設定檔
│   └── hosts.yaml     # 批次處理主機清單
├── lib/           # 共用函式庫
│   └── ssh_utils.sh   # SSH 相關工具函式
└── test/          # 測試腳本
    └── testconfig.sh  # 設定檔測試
```

## 使用方式

### 1. 互動式設定 (ssh-setup)

```bash
./bin/ssh-setup
```

跟隨提示輸入必要資訊。

### 2. 命令列設定 (ssh-init)

```bash
./bin/ssh-init user@host key_name [password] [key_dir]
```

參數說明：
- user@host：遠端主機的使用者和位址
- key_name：金鑰的名稱（用作 SSH config 中的 Host）
- password：（可選）遠端主機的密碼
- key_dir：（可選）金鑰存放的子目錄，相對於 ~/.ssh

### 3. 批次處理設定 (ssh-batch-init)

1. 編輯 config/hosts.yaml：
```yaml
config:
  key_dir: "project/cluster"  # 相對於 ~/.ssh 的路徑，可選

hosts:
  - user_host: "user1@192.168.1.101"
    key_name: "node1"
    password: "password1"  # 可選
    setup:  # 可選，主機初始設定
      hostname: "new-node1"  # 新的 hostname
      new_password: "newpass1"  # 新的使用者密碼
```

2. 執行批次處理：
```bash
./bin/ssh-batch-init
```

## 注意事項

1. 所有金鑰都存放在 ~/.ssh 或其子目錄下
2. 設定檔會自動組織在 ~/.ssh/config.d/ 目錄下
3. 主設定檔 (~/.ssh/config) 會自動包含 config.d/* 的設定