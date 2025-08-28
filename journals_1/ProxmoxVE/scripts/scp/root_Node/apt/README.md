# 系統設定腳本說明

本目錄包含一系列用於系統配置和服務安裝的腳本。

## 腳本概述

### 基礎安裝
- `install_general.sh`: 安裝基礎系統工具
  - 安裝：wget, unzip, libsmi2-common, dos2unix, ncdu, ufw, sshpass
  - 預設停用 UFW 防火牆

- `setting_general.sh`: 配置基本系統設定
  - 設定 bash 歷史記錄時間戳格式
  - 修改 .bashrc 配置

### 系統安全
- `PAM/setting_general.sh`: 配置 PAM 密碼策略
  - 設定密碼複雜度要求（長度、字元類型）
  - 配置密碼有效期（90天）
  - 設定密碼更改限制
  - 套用到所有系統用戶

### 監控工具
- `prometheus/node_exporter_linux.sh`: 安裝設定 Prometheus Node Exporter
  - 建立專用系統用戶
  - 設定 systemd 服務（端口 9100）
  - 配置開機自動啟動
  - 安裝前檢查端口占用

- `snmp/snmp_open.sh`: 安裝設定 SNMP 服務
  - 安裝 SNMP、SNMPD 相關工具
  - 設定 MIB 支援
  - 配置 SNMPD 基本設定
  - 啟用 SNMP 服務（端口 161/udp）

### 虛擬機支援
- `qemu/qemu.sh`: 安裝 QEMU 客戶端代理
  - 自動檢測是否為虛擬機（主機名包含 'vm'）
  - 根據環境安裝 qemu-guest-agent
  - 啟用並啟動服務

## 安裝順序

腳本設計按以下順序執行：
1. install_general.sh（基礎工具）
2. setting_general.sh（基本設定）
3. PAM/setting_general.sh（密碼策略）
4. prometheus/node_exporter_linux.sh（監控代理）
5. qemu/qemu.sh（虛擬機支援）
6. snmp/snmp_open.sh（SNMP 服務）

## 系統要求

- 需要 root 權限執行所有腳本
- 基於 Debian 的 Linux 發行版
- 需要網際網路連接以安裝套件

## 使用方式

這些腳本通常通過 `installviassh.sh` 腳本進行遠端部署，但也可以單獨執行：

```bash
sudo ./install_general.sh
sudo ./setting_general.sh
sudo ./PAM/setting_general.sh
sudo ./prometheus/node_exporter_linux.sh
sudo ./qemu/qemu.sh
sudo ./snmp/snmp_open.sh
```

## 端口使用

- Node Exporter: TCP 9100
- SNMP: UDP 161

## 安全注意事項

- 安裝後預設停用 UFW 防火牆
- SNMP 使用基本設定，生產環境需要進一步加強安全性
- 所有服務配置為系統開機時自動啟動
- PAM 密碼策略適用於所有用戶（包括 root）
- 密碼要求：
  - 最小長度：12 字元
  - 必須包含：大寫字母、小寫字母、數字和特殊字元
  - 密碼有效期：90 天
  - 密碼最短使用期限：1 天
  - 密碼過期警告：7 天前