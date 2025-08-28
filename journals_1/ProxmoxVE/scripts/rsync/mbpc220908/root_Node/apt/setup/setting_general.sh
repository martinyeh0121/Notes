#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "⚠️ 請以 root 權限執行"
   exit 1
fi

# ================== .bashrc ============================

echo "🔄 設定 ~/.bashrc"
if grep -Eq '^[[:space:]]*HISTTIMEFORMAT="%F %T  "' ~/.bashrc; then
    echo "   HISTTIMEFORMAT 已經設定在 ~/.bashrc"
elif grep -Eq '^[[:space:]]*#.*HISTTIMEFORMAT="%F %T  "' ~/.bashrc; then
    echo "   發現被註解的 HISTTIMEFORMAT 設定"
    echo "✅ 正在取消註解設定..."
    sed -i 's/^[[:space:]]*#\s*HISTTIMEFORMAT="%F %T  "/HISTTIMEFORMAT="%F %T  "/' ~/.bashrc
else
    echo "✅ 正在加入 HISTTIMEFORMAT 設定到 ~/.bashrc"
    echo 'HISTTIMEFORMAT="%F %T  "' >> ~/.bashrc
fi

source ~/.bashrc


echo "✅ 所有服務設定完成！"
echo "👉 測試指令：history | tail -1 測試"