#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "⚠️ 請以 root 權限執行"
   exit 1
fi

# ================== .bashrc ============================

# history ts
grep -q '^[^#]*HISTTIMEFORMAT="%F %T  "' ~/.bashrc || echo 'HISTTIMEFORMAT="%F %T  "' >> ~/.bashrc
source ~/.bashrc


echo "✅ 所有服務設定完成！"
echo "👉 可使用 history | tail -1 測試"