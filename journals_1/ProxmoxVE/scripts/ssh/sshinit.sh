USER_HOST=$1 # "mobagel@192.168.16.62"
KEY_NAME=$2 # "mbvm250603"
WORKDIR=$3 # "目前目錄，可選"
PASSWORD=$4 # "密碼，可選"

if [ -n "$WORKDIR" ]; then
  echo "[INFO] 工作目錄: $WORKDIR"
fi

ssh-keygen -f ~/.ssh/id_rsa_${KEY_NAME} -N ""

if [ -n "$PASSWORD" ]; then
  sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa_${KEY_NAME} $USER_HOST
else
  ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa_${KEY_NAME} $USER_HOST
#ssh-copy-id -i ~/.ssh/id_rsa_${KEY_NAME} $USER_HOST
fi
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa_${KEY_NAME} $USER_HOST

# === 新增/更新 SSH config ===
# @config
CONFIG_FILE="$HOME/.ssh/config"
user="${USER_HOST%@*}"
host_name="${USER_HOST#*@}"
identity_file="$HOME/.ssh/id_rsa_${KEY_NAME}"

# 若 config 不存在則建立
if [ ! -f "$CONFIG_FILE" ]; then
  touch "$CONFIG_FILE"
fi

# 若已存在同名 Host 則先移除
sed -i "/^Host ${KEY_NAME}$/,/^$/d" "$CONFIG_FILE"

# 新增設定
cat <<EOF >> "$CONFIG_FILE"
Host ${KEY_NAME}
    HostName ${host_name}
    User ${user}
    IdentityFile ${identity_file}

EOF