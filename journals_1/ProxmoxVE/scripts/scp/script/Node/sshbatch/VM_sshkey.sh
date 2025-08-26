#!/bin/bash
#  ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa_"$KEY_NAME" user@host
set -e

# === 互動輸入 ===
read -rp "請輸入遠端帳號與 IP（格式: user@host）: " USER_HOST
read -rp "請輸入金鑰後綴（建議hostname, 例如：mbvm250603）: " KEY_NAME
read -rsp "請輸入遠端密碼（可留空，按 Enter 跳過）: " PASSWORD

## 相依套件 =================================================
# === 檢查並安裝 sshpass（僅首次）===
if ! command -v sshpass >/dev/null 2>&1; then
  echo "[INFO] sshpass 未安裝，嘗試自動安裝..."

  if [ -f /etc/debian_version ]; then
    apt update && apt install -y sshpass
  elif [ -f /etc/redhat-release ]; then
    yum install -y epel-release
    yum install -y sshpass
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



## 開始設定  ==============================================



# ====== 建立 SSH 金鑰 ======
ssh-keygen -f ~/.ssh/id_rsa_"$KEY_NAME" -N ""

# ====== 複製金鑰到遠端主機 ======
if [ -n "$PASSWORD" ]; then
  sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa_"$KEY_NAME" "$USER_HOST"
else
  ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa_"$KEY_NAME" "$USER_HOST"
fi

# ====== SSH config 設定 ======

CONFIG_FILE="$HOME/.ssh/config"
user="${USER_HOST%@*}"
host_name="${USER_HOST#*@}"
identity_file="$HOME/.ssh/id_rsa_${KEY_NAME}"

# 建立 config 檔案（若不存在）
if [ ! -f "$CONFIG_FILE" ]; then
  touch "$CONFIG_FILE"
fi

# 移除同名 Host 區塊（避免重複）
sed -i "/^Host ${KEY_NAME}$/,/^$/d" "$CONFIG_FILE"

# 新增設定
cat <<EOF >> "$CONFIG_FILE"
Host ${KEY_NAME}
    HostName ${host_name}
    User ${user}
    IdentityFile ${identity_file}

EOF

echo "[SUCCESS] SSH 設定完成，可使用：ssh ${KEY_NAME}"
