# SSH 基礎指令說明

## 1. SSH 連線
```bash
# 基本連線
ssh user@hostname
ssh user@192.168.1.100

# 指定 port
ssh -p 2222 user@hostname

# 使用金鑰
ssh -i ~/.ssh/id_rsa_keyname user@hostname

# 使用 config 中的別名
ssh server_001012
```

## 2. SSH 金鑰管理

### 2.1 產生金鑰
```bash
# 基本用法
ssh-keygen

# 指定檔名
ssh-keygen -f ~/.ssh/id_rsa_keyname

# 指定加密方式
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_keyname
```

### 2.2 複製金鑰到遠端
```bash
# 基本用法
ssh-copy-id user@hostname

# 指定金鑰
ssh-copy-id -i ~/.ssh/id_rsa_keyname user@hostname

# 指定 port
ssh-copy-id -p 2222 user@hostname

# 忽略 known_hosts 檢查（首次連線）
ssh-copy-id -o StrictHostKeyChecking=no user@hostname
```

## 3. SSH Config 設定

### 3.1 基本結構
```bash
# ~/.ssh/config
Host myserver
    HostName 192.168.1.100
    User username
    Port 22
    IdentityFile ~/.ssh/id_rsa_keyname
```

### 3.2 多層設定
```bash
# ~/.ssh/config
Include config.d/*

# ~/.ssh/config.d/work
Host work-*
    User workuser
    IdentityFile ~/.ssh/id_rsa_work

Host work-dev
    HostName 192.168.1.100

Host work-prod
    HostName 192.168.1.200
```

## 4. 常用選項

### 4.1 連線選項
```bash
# 顯示除錯資訊
ssh -v user@hostname
ssh -vv user@hostname  # 更詳細
ssh -vvv user@hostname # 最詳細

# 壓縮傳輸
ssh -C user@hostname

# 指定本地 port 轉發
ssh -L 8080:localhost:80 user@hostname
```

### 4.2 安全選項
```bash
# 只使用金鑰認證
ssh -o PasswordAuthentication=no user@hostname

# 批次模式（不互動）
ssh -o BatchMode=yes user@hostname

# 忽略 known_hosts
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null user@hostname
```

## 5. 檔案權限
```bash
# 設定正確的權限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa_*
chmod 644 ~/.ssh/id_rsa_*.pub
```

## 6. 常用檔案位置
```
~/.ssh/                    # SSH 目錄
~/.ssh/config             # 主要設定檔
~/.ssh/config.d/          # 子設定檔目錄
~/.ssh/known_hosts       # 已知主機列表
~/.ssh/authorized_keys   # 授權金鑰列表
```