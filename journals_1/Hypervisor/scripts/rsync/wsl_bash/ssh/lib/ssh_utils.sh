#!/bin/bash

# 檢查並安裝 sshpass
check_install_sshpass() {
    if ! command -v sshpass >/dev/null 2>&1; then
        echo "🔄 sshpass 未安裝，嘗試自動安裝..."
        if [ -f /etc/debian_version ]; then
            sudo apt update && sudo apt install -y sshpass
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y epel-release && sudo yum install -y sshpass
        elif [ "$(uname)" == "Darwin" ]; then
            if ! command -v brew >/dev/null 2>&1; then
                echo "⚠️ macOS 請先安裝 Homebrew：https://brew.sh/"
                return 1
            fi
            brew install hudochenkov/sshpass/sshpass
        else
            echo "⚠️ 無法自動安裝 sshpass，請手動安裝。"
            return 1
        fi
        echo "✅ sshpass 安裝完成"
    else
        echo "✅ sshpass 已安裝"
    fi
    return 0
}

# 設定 SSH 目錄和設定檔
setup_ssh_dirs() {
    local raw_key_dir=$1
    local default_ssh_dir="$HOME/.ssh"
    local key_dir config_dir config_path

    # 設定金鑰目錄
    if [[ -z "$raw_key_dir" ]]; then
        key_dir="$default_ssh_dir"
    else
        key_dir="$default_ssh_dir/$raw_key_dir"
    fi

    # 設定 config 目錄和檔案
    config_dir="$HOME/.ssh/config.d"
    mkdir -p "$key_dir" "$config_dir"

    # 產生 config 檔名，把 / 換成 _
    config_path="$config_dir/${raw_key_dir//\//_}"
    config_path=${config_path%/}  # 去掉尾部斜線

    # 若不存在 config 檔案，建立並加註解
    if [ ! -f "$config_path" ]; then
        echo -e "##### $key_dir #####\n" > "$config_path"
    fi

    echo "$key_dir:$config_path"
}

# 產生並複製 SSH 金鑰
generate_copy_key() {
    local user_host=$1
    local key_path=$2
    local password=$3

    # 產生金鑰
    ssh-keygen -f "$key_path" -N "" -q

    # 複製到遠端
    if [ -n "$password" ]; then
        sshpass -p "$password" ssh-copy-id \
            -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            -i "$key_path" "$user_host"
    else
        ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            -i "$key_path" "$user_host"
    fi
}

# 更新 SSH config
update_ssh_config() {
    local config_path=$1
    local ssh_host=$2
    local user_host=$3
    local key_path=$4

    local user="${user_host%@*}"
    local host_name="${user_host#*@}"

    # 刪除舊 Host block（保留空行）
    awk -v host="Host ${ssh_host}" '
        $0 == host {inblock=1; next}
        inblock && /^Host / {inblock=0}
        !inblock
    ' "$config_path" > "${config_path}.tmp" && mv -f "${config_path}.tmp" "$config_path"

    # 新增 Host block
    cat <<EOF >> "$config_path"

Host ${ssh_host}
    HostName ${host_name}
    User ${user}
    IdentityFile ${key_path}

EOF
}

# 確保主 config include config.d/*
ensure_main_config() {
    local main_config="$HOME/.ssh/config"
    if ! grep -q "^Include config.d/\*" "$main_config" 2>/dev/null; then
        echo -e "\nInclude config.d/*" >> "$main_config"
    fi
}

# 設定遠端主機的 hostname 和密碼
setup_remote_host() {
    local user_host=$1
    local password=$2
    local new_hostname=$3
    local new_password=$4

    if [[ -z "$new_hostname" && -z "$new_password" ]]; then
        return 0
    fi

    local username="${user_host%@*}"
    echo "🔄 設定 hostname 與密碼..."

    local commands=""
    if [ -n "$new_hostname" ]; then
        commands+="echo '更改 hostname 為 $new_hostname';"
        commands+="sudo hostnamectl set-hostname $new_hostname;"
    fi
    
    if [ -n "$new_password" ]; then
        commands+="echo '更改使用者密碼';"
        commands+="echo '$username:$new_password' | sudo chpasswd;"
    fi

    if [ -n "$commands" ]; then
        sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user_host" "$commands"
        echo "✅ 遠端主機設定完成"
    fi
}