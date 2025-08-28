#!/bin/bash
set -e

echo "📢 安裝前提醒："
echo " - Node Exporter 預設會使用 TCP port 9100，請確認系統中沒有其他服務佔用該 port"
echo " - systemd 服務檔 /etc/systemd/system/prometheus_node_exporter.service 會被建立 / 覆蓋"
echo " - 若已有 node_exporter 在執行，也可能會導致啟動失敗"

# 檢查是否以 root 執行腳本
# $EUID 是當前執行者的 UID，root 的 UID 是 0
if [[ $EUID -ne 0 ]]; then
  echo "⚠️ 錯誤：請使用 sudo 執行此腳本，例如：sudo ./node_exporter_linux.sh"
  exit 1
fi

echo "🔍 事前檢查: Node Exporter (/usr/local/bin, /opt), port 狀態, systemd"

# 檢查 9100 port 是否已被佔用
if ss -tuln | grep -q ':9100'; then
  echo "⚠️ 警告：port 9100 已被佔用，可能已有 prometheus_node_exporter 或其他服務在執行。"
  echo "   建議使用：sudo lsof -i :9100 或 sudo netstat -tulnp 查看詳細資訊。"
  echo "➡️  中止安裝。"
  exit 1
#   read -p "❓ 是否仍要繼續安裝？(y/N): " confirm
#   if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
#     echo "➡️  中止安裝。"
#   fi
fi

FOUND_PATH=$(find /usr/local/bin /opt -type f -name node_exporter 2>/dev/null | head -n 1)

if [[ -n "$FOUND_PATH" ]]; then
  echo "✅ 已偵測到 node_exporter 安裝於：$FOUND_PATH"
  read -p "❓ 是否要重新安裝？(y/N): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "➡️  中止安裝。"
    exit 0
  fi
fi

# systemd 服務檔檢查
SERVICE_FILE="/etc/systemd/system/prometheus_node_exporter.service"
if [[ -f "$SERVICE_FILE" ]]; then
  echo "⚠️ 偵測到 systemd 服務檔已存在：$SERVICE_FILE"
  read -p "❓ 是否繼續安裝，會覆蓋此服務設定檔？(y/N): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "➡️  中止安裝。"
    exit 1
  fi
fi

# 建立暫存資料夾，並進入該資料夾
mkdir -p ./tmp
cd tmp

# 建立 prometheus_node_exporter 使用者，無家目錄且不能登入
useradd --no-create-home --shell /usr/sbin/nologin prometheus_node_exporter

# 下載 Node Exporter 二進位檔（版本 1.9.1，Linux amd64 版）
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz

# 解壓縮下載的檔案
tar xvf node_exporter-1.9.1.linux-amd64.tar.gz

# 將 node_exporter 執行檔複製到 /usr/local/bin
cp node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/

# 設定該執行檔的擁有者為 prometheus_node_exporter 使用者
chown prometheus_node_exporter:prometheus_node_exporter /usr/local/bin/node_exporter

# 返回上一層並刪除暫存資料夾
cd ..
rm -rf ./tmp



## ============================================================


# 建立 systemd 服務設定檔
tee /etc/systemd/system/prometheus_node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=prometheus_node_exporter
Group=prometheus_node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=":9100"

[Install]
WantedBy=default.target
EOF

# 重新初始化 systemd 服務環境（必要時重新載入元件）
systemctl daemon-reexec

# 重新載入 systemd 設定（讀取新的服務檔案）
systemctl daemon-reload

# 啟用 node_exporter 服務
systemctl enable --now prometheus_node_exporter

# 顯示成功訊息
echo "✅ Node Exporter 安裝並啟動成功！ 可用 systemctl status prometheus_node_exporter 檢查"
