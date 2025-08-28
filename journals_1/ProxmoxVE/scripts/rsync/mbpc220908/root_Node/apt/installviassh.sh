#!/bin/bash
set -e

### 設定子檔案所在資料夾

# 取得腳本所在資料夾
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 定義 setup 資料夾的路徑
SETUP_DIR="$SCRIPT_DIR/setup"

# Installation scripts in order
INSTALL_SCRIPTS=(
    "prometheus/node_exporter_linux.sh"
    "qemu/qemu.sh"
    "snmp/snmp.sh"
    "PAM/PAM.sh"
    "install_general.sh"
    "setting_general.sh"
)

# 檢查腳本執行權限
echo "==== 檢查腳本執行權限 ===="
for script in "${INSTALL_SCRIPTS[@]}"; do
    if [ -f "$SETUP_DIR/$script" ]; then
        if [ ! -x "$SETUP_DIR/$script" ]; then
            echo "⚠️ 設定執行權限: $script"
            chmod +x "$SETUP_DIR/$script"
        fi
    else
        echo "⚠️ 找不到腳本: $script"
    fi
done

# 讀取要部署的主機列表（用空格分隔）
read -p "請輸入要部署的主機（空格分隔）： " -a HOSTS

for host in "${HOSTS[@]}"; do
    echo "==== Deploying to $host ===="
    
    # 記錄失敗的腳本
    failed_scripts=()
    
    for script in "${INSTALL_SCRIPTS[@]}"; do
        echo "🔄 執行腳本: $script"
        if [ -f "$SETUP_DIR/$script" ]; then
            if ssh "$host" 'sudo bash -s' < "$SETUP_DIR/$script"; then
                echo "✅ 成功執行: $script"
            else
                echo "⚠️ 執行失敗: $script"
                failed_scripts+=("$script")
            fi
        else
            echo "⚠️ 找不到腳本: $script"
            failed_scripts+=("$script")
        fi
    done
    
    # 顯示執行結果摘要
    echo "==== $host 部署摘要 ===="
    if [ ${#failed_scripts[@]} -eq 0 ]; then
        echo "✅ 所有腳本執行成功"
    else
        echo "⚠️ 以下腳本執行失敗:"
        printf '%s\n' "${failed_scripts[@]}"
    fi

    echo "✅ $host 部署完成"
done

echo "==== 服務端口使用說明 ===="
echo "⚠️ 以下端口將被服務占用："
echo "  - TCP 9100: prometheus_node_exporter"
echo "  - UDP 161:  SNMP"
echo "請確保這些端口未被其他服務使用"

