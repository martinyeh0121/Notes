#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "⚠️ 請以 root 權限執行"
   exit 1
fi

# ================== .bashrc ============================

# 獲取 UID 1000 的用戶
NORMAL_USER=$(awk -F: '$3 == 1000 {print $1}' /etc/passwd)
if [ -z "$NORMAL_USER" ]; then
    echo "⚠️ 找不到 UID 1000 的用戶"
    exit 1
fi

echo "🔄 設定 bash 歷史記錄時間戳"
# 函數：設定 bashrc
setup_bashrc() {
    local bashrc_path="$1"
    if grep -Eq '^[[:space:]]*HISTTIMEFORMAT="%F %T  "' "$bashrc_path"; then
        echo "   $bashrc_path 已設定 HISTTIMEFORMAT"
    elif grep -Eq '^[[:space:]]*#.*HISTTIMEFORMAT="%F %T  "' "$bashrc_path"; then
        echo "   發現被註解的設定，正在取消註解..."
        sed -i 's/^[[:space:]]*#\s*HISTTIMEFORMAT="%F %T  "/HISTTIMEFORMAT="%F %T  "/' "$bashrc_path"
    else
        echo "   正在加入 HISTTIMEFORMAT 設定..."
        echo 'HISTTIMEFORMAT="%F %T  "' >> "$bashrc_path"
    fi
}

# 設定 root 的 bashrc
echo "✅ 設定 root 的 .bashrc"
setup_bashrc "/root/.bashrc"
source "/root/.bashrc"

# 設定一般用戶的 bashrc
echo "✅ 設定 ${NORMAL_USER} 的 .bashrc"
setup_bashrc "/home/${NORMAL_USER}/.bashrc"
chown ${NORMAL_USER}:${NORMAL_USER} "/home/${NORMAL_USER}/.bashrc"


echo "✅ 所有服務設定完成！"
echo "👉 測試指令：history | tail -1 測試"