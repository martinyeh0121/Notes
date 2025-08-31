#!/bin/bash

USER_HOST=$1   # "mobagel@192.168.16.62"
KEY_NAME=$2    # "mbvm250603"
PASSWORD=$3    # "密碼，可選"
KEY_DIR=$4     # "~/.ssh"，可選

# 預設 key dir
: "${KEY_DIR:=$HOME/.ssh}"
KEY_PATH="${KEY_DIR}/id_rsa_${KEY_NAME}"

# 確保 key dir 存在
mkdir -p "$KEY_DIR"

# 產生金鑰
ssh-keygen -f "$KEY_PATH" -N ""

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

#ssh-copy-id -i ~/.ssh/id_rsa_${KEY_NAME} $USER_HOST

# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa_${KEY_NAME} $USER_HOST



# === 更新 SSH config ===
CONFIG_FILE="$HOME/.ssh/config"
user="${USER_HOST%@*}"
host_name="${USER_HOST#*@}"

# 確保 config 存在
touch "$CONFIG_FILE"

# 刪掉舊的 Host 區塊 (Host 字串分隔)
sed -i "/^Host ${KEY_NAME}$/,/^Host /{ /^Host ${KEY_NAME}$/d; /^Host /!d }" "$CONFIG_FILE"

# # 若已存在同名 Host 則先移除 (空行分隔)
# sed -i "/^Host ${KEY_NAME}$/,/^$/d" "$CONFIG_FILE"

# 新增設定
cat <<EOF >> "$CONFIG_FILE"

Host ${KEY_NAME}
    HostName ${host_name}
    User ${user}
    IdentityFile ${KEY_PATH}
EOF