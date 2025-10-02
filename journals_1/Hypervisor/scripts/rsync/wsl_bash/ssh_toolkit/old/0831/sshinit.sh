#!/bin/bash

USER_HOST=$1   # "mobagel@192.168.16.62"
KEY_NAME=$2    # "mbvm250603"
PASSWORD=$3    # "密碼，可選"
KEY_DIR=$4     # "~/.ssh"，可選
CONFIG_PATH=$5 # "~/.ssh/config.d/xxx"，可選

# 預設 key dir
: "${KEY_DIR:=$HOME/.ssh}"
KEY_PATH="${KEY_DIR}/id_rsa_${KEY_NAME}"

# 確保 key dir 存在
mkdir -p "$KEY_DIR"

# 產生金鑰
ssh-keygen -f "$KEY_PATH" -N "" -q

# 複製到遠端
if [ -n "$PASSWORD" ]; then
  sshpass -p "$PASSWORD" ssh-copy-id \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "$KEY_PATH" "$USER_HOST"
else
  ssh-copy-id \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "$KEY_PATH" "$USER_HOST"
fi

# === 更新 SSH config ===
# 預設 config path
: "${CONFIG_PATH:=$HOME/.ssh/config}"
user="${USER_HOST%@*}"
host_name="${USER_HOST#*@}"

# 確保 config 檔存在
mkdir -p "$(dirname "$CONFIG_PATH")"
touch "$CONFIG_PATH"

# 刪掉舊的 Host 區塊 (Host block 以空行或下一個 Host 分隔)，最後一個 Host block 沒空行，也能正確刪掉
sed -i "/^Host ${KEY_NAME}$/,/^Host /{ /^Host ${KEY_NAME}$/d; /^Host /!d }" "$CONFIG_PATH"

# # 若已存在同名 Host 則先移除 (空行分隔)
# sed -i "/^Host ${KEY_NAME}$/,/^$/d" "$CONFIG_FILE"

# 新增 Host block (前後保留空行)
cat <<EOF >> "$CONFIG_PATH"

Host ${KEY_NAME}
    HostName ${host_name}
    User ${user}
    IdentityFile ${KEY_PATH}

EOF
