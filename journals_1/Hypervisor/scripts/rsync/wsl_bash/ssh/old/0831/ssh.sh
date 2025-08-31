#!/bin/bash

# ===== 設定工作目錄 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1
echo "[INFO] 腳本執行於：$SCRIPT_DIR"

# ===== 互動式輸入 =====
read -rp "請輸入遠端帳號與 IP（格式: user@host）: " USER_HOST
read -rp "請輸入 SSH Host 別名（例如 node1）: " SSH_HOST
read -rp "請輸入金鑰後綴（建議 hostname，例如 mbvm250603）: " KEY_NAME
read -rsp "請輸入遠端密碼（可留空，按 Enter 跳過）: " PASSWORD
echo
read -rp "請輸入 SSH key 目錄相對於 ~/.ssh（例如 mobagel/dev_cluster，預設為 ~/.ssh）: " RAW_KEY_DIR
RAW_KEY_DIR=${RAW_KEY_DIR:-""}

# ===== 設定目錄與檔案 =====
DEFAULT_SSH_DIR="$HOME/.ssh"
if [[ -z "$RAW_KEY_DIR" ]]; then
    KEY_DIR="$DEFAULT_SSH_DIR"
else
    KEY_DIR="$DEFAULT_SSH_DIR/$RAW_KEY_DIR"
fi

CONFIG_DIR="$HOME/.ssh/config.d"
mkdir -p "$KEY_DIR" "$CONFIG_DIR"

# 產生 config 檔名，把 / 換成 _
CONFIG_PATH="$CONFIG_DIR/${RAW_KEY_DIR//\//_}"
CONFIG_PATH=${CONFIG_PATH%/}  # 去掉尾部斜線

# 若不存在 config 檔案，建立並加註解
if [ ! -f "$CONFIG_PATH" ]; then
    echo -e "##### $KEY_DIR #####\n" > "$CONFIG_PATH"
fi

# ===== 檢查 sshpass =====
if ! command -v sshpass >/dev/null 2>&1; then
    echo "[INFO] sshpass 未安裝，嘗試自動安裝..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y sshpass
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y epel-release && sudo yum install -y sshpass
    elif [ "$(uname)" == "Darwin" ]; then
        if ! command -v brew >/dev/null 2>&1; then
            echo "[ERROR] macOS 請先安裝 Homebrew：https://brew.sh/"
            exit 1
        fi
        brew install hudochenkov/sshpass/sshpass
    else
        echo "[ERROR] 無法自動安裝 sshpass，請手動安裝。"
        exit 1
    fi
    echo "[INFO] sshpass 安裝完成"
else
    echo "[INFO] sshpass 已安裝"
fi

# ===== 建立 SSH 金鑰 =====
KEY_PATH="$KEY_DIR/id_rsa_${KEY_NAME}"
ssh-keygen -f "$KEY_PATH" -N "" -q

# ===== 複製金鑰到遠端 =====
if [ -n "$PASSWORD" ]; then
    sshpass -p "$PASSWORD" ssh-copy-id \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -i "$KEY_PATH" "$USER_HOST"
else
    ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -i "$KEY_PATH" "$USER_HOST"
fi

# ===== 更新 SSH config =====
user="${USER_HOST%@*}"
host_name="${USER_HOST#*@}"

# 刪除舊 Host block（保留空行）
awk -v host="Host ${SSH_HOST}" '
    $0 == host {inblock=1; next}
    inblock && /^Host / {inblock=0}
    !inblock
' "$CONFIG_PATH" > "${CONFIG_PATH}.tmp" && mv -f "${CONFIG_PATH}.tmp" "$CONFIG_PATH"

# 新增 Host block
cat <<EOF >> "$CONFIG_PATH"

Host ${SSH_HOST}
    HostName ${host_name}
    User ${user}
    IdentityFile ${KEY_PATH}

EOF

# ===== 確保主 config include config.d/* =====
MAIN_CONFIG="$HOME/.ssh/config"
if ! grep -q "^Include config.d/\*" "$MAIN_CONFIG" 2>/dev/null; then
    echo -e "\nInclude config.d/*" >> "$MAIN_CONFIG"
fi

echo "[SUCCESS] SSH 設定完成，可使用：ssh ${SSH_HOST}"
