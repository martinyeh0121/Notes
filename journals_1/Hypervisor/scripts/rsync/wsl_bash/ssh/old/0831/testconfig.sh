#!/bin/bash

# 參數設定
USER_HOST1="mobagel@192.168.16.64"
KEY_NAME1="mbvm250604"
PASSWORD1="123456789"
WORKDIR="/home/martin/home/bash/ssh"
CONFIG_FILE="$HOME/.ssh/config"

# 拆解 user 和 host
user="${USER_HOST1%@*}"
host_name="${USER_HOST1#*@}"

# IdentityFile 假設你用 private key 並放在 WORKDIR 下
identity_file="${WORKDIR}/${KEY_NAME1}"

# 如果已存在同名 Host，先移除
sed -i "/^Host ${KEY_NAME1}$/,/^$/d" "$CONFIG_FILE"

# 新增 SSH config 設定
cat <<EOF >> "$CONFIG_FILE"
Host ${KEY_NAME1}
    HostName ${host_name}
    User ${user}
    IdentityFile ${identity_file}

EOF

echo "SSH config for '${KEY_NAME1}' has been added."

