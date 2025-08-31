#!/bin/bash

HOSTS_FILE="hosts.yaml"
DEFAULT_SSH_DIR="$HOME/.ssh"

# 讀取 config.workdir 與 config.key_dir
WORKDIR=$(pwd)
RAW_KEY_DIR=$(yq -r '.config.key_dir' "$HOSTS_FILE")

if [[ -z "$RAW_KEY_DIR" || "$RAW_KEY_DIR" == "null" ]]; then
  KEY_DIR="$DEFAULT_SSH_DIR"
else
  KEY_DIR="${DEFAULT_SSH_DIR}/${RAW_KEY_DIR}"
fi

# 確保 key 目錄存在
mkdir -p "$KEY_DIR"

# 產生對應 config 檔案名稱（把 / 換成 _）
CONFIG_DIR="$HOME/.ssh/config.d"
mkdir -p "$CONFIG_DIR"
CONFIG_PATH="${CONFIG_DIR}/${RAW_KEY_DIR//\//_}"

# 若不存在 config 檔案，建立並加註解
if [ ! -f "$CONFIG_PATH" ]; then
    echo -e "##### ${KEY_DIR} #####\n" > "$CONFIG_PATH"
fi

# 逐台主機處理
count=$(yq '.hosts | length' "$HOSTS_FILE")
for ((i=0; i<count; i++)); do
  USER_HOST=$(yq -r ".hosts[$i].user_host" "$HOSTS_FILE")
  KEY_NAME=$(yq -r ".hosts[$i].key_name" "$HOSTS_FILE")
  PASSWORD=$(yq -r ".hosts[$i].password" "$HOSTS_FILE")

  echo "=== 設定 $USER_HOST ($KEY_NAME) ==="
  bash sshinit.sh "$USER_HOST" "$KEY_NAME" "$PASSWORD" "$KEY_DIR" "$CONFIG_PATH"
  echo
done
