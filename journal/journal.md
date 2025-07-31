| 時間 from to | 工作內容           | 任務狀態 | 遇到的問題      | 解決方式 / 備註   |  備註2  | Link  |
|------------|--------------------------------------|----------|------------------------------------|--------------------------------------------------------|----------------------------------------|--------------------------------------|
| 20250625 | 使用 PVE 建立 VM 完成 ip 綁定 | ✅ | 無     | 熟悉操作 PVE Node     |  | [here](/journals_1/ProxmoxVE/sop.md#0--建立-proxmox-ve-node-account--設置路由----前言) |
| 20250626 | 練習用 Node 自訂內網網域 | ✅ | 無     | 熟悉 iptable 指令 / 網卡設定    |  |[here](/journals_1/ProxmoxVE/sop.md#網路拓樸調整)  |
| 20250626 | 練習 DHCP server 設定  | ⏳ | -- |  |  安全起見，待 VLAN 配置完繼續    |       |
| 20250626 | sop 試做  | 🔄 |    |    |      | [here](/journals_1/ProxmoxVE/sop.md)   |
| 20250627 | SSH 免密碼登入 batch-script | ✅ |  |      |     | [here](/journals_1/ProxmoxVE/other.md#ssh-免密碼登入) [bash](/journals_1/ProxmoxVE/scripts/ssh/)   |
| 20250627 | 日誌試做  | 🔄 |    |    |      | here   |
| 20250627 | proxy server  | ⏳ |    |    |      | []()   |
| 20250630 | PVE VM 轉移 vzdump | ☑️ |    |    |      | here   |
| 20250627 | PVE mount disk (Linux) | ☑️ |   |    | -> 系統碟轉移  | here   |
| 20250630 | OPE_request sync | ☑️ |    |    |    | [here](/journals_0/project/協助表單/manual.md)   |
| 20250702 | PVE 資料碟轉移/備份 (qcow2) | ☑️ |    |    |   | [here](/journals_1/ProxmoxVE/sops/sop2/sop2.md)   |
| 20250703 | PVE 資料碟轉移 (預計dd) | ⏳ |    |    |   | here   |
| 20250703 | PVE disk cli 操作 | ✅ |    | gpt 概覽 |   | [here](/journals_1/ProxmoxVE/man.md#-磁碟與檔案系統--pve--lvm-互動) |
| 20250703 | 調整 SSH 腳本 sshpass + read | ✅ |    |    |   | [here](/journals_1/ProxmoxVE/scripts/scp/script/root_Node/sshbatch/VM_sshkey.sh) |
| 20250703 | 調整 netplan / fstab 腳本 | ✅ |    |    |   | [netplan](/journals_1/ProxmoxVE/) [fstab](/journals_1/ProxmoxVE/scripts/scp/script/root_Node/disk/VM_disk_mount.bash)   |
| 20250707 | PVE 系統碟轉移 (dd/qcow2)  | ✅ |    |    |   | [here](/journals_1/ProxmoxVE/README.md)   |
| 20250707 | cloudinit / autoinstall | ⏳ |    |    |   | here   |
| 20250708 | cluster ops | ⏳ |    |    |   | [here](/journals_1/ProxmoxVE/README.md)  |
| 20250709 | qemu-guest-agent 功能整理 | ✅ |    |    |   | [here](/journals_1/ProxmoxVE/README.md)   |
| 20250710 | PVE API agent ping / disk lookup  | ✅ |    |  參閱 /sop4  |   | [here](/journals_1/ProxmoxVE/README.md)   |
| 20250710 | snmp setup script v1 | ✅ |    | 參閱 /scripts   |   | [here](/journals_1/ProxmoxVE/README.md)   |
| 20250714 | Appscript 研究 | ✅ |    |  ope_request  |   | [none]()   |
| 20250715 |  | ✅ |    |    |   | [none]()   |
| 20250716 | PVE API 抓 ip | ✅ |    | 參閱 /sop4   |   | [here](/journals_1/ProxmoxVE/README.md)   |
| 20250717 | Cacti batch create script | ✅ |    |  參閱 /sopxx  |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250717 | Cacti tree usage | ✅ |    | 參閱 /sopxx   |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250718 | snmp script (mib) debug | ✅ |    | 參閱 /sopxx   |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250718 | 主機重灌ubuntu / 裝GPU(待監控) | ✅ |    | 參閱 /sopxx   |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250721/22 | 主機重灌 ubuntu *6 + 主機配置清點 *8 / 流程優化規劃 | ✅ |   |   |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250722 | autoinstall (自動化安裝) 研究 | ✅ | iso 讀取 | 使用 rufus  |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250723 | 主機實作 autoinstall 無網路版本 *2 | ✅ |    | 參閱 /sopxx   |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250724 | cacti 監控開發環境 (16.xx) | ✅ |    | 系統自動掃描  |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250725 | cacti 監控開發環境 (16.xx) | ✅ |    | 系統自動掃描  |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250725 | 協助機房主機配線整理 | ✅ |    |   |   |   |
| 20250728 | cacti 安裝 spine poller | ✅ | | 支援精細抓取間隔 | 快速poll設備指標方案 | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250729 | PVE host rename | ✅ |    |   |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 20250729-31 | prometheus 容器/主機監控   | ✅ |    |   |   | [wait](/journals_1/ProxmoxVE/README.md)   |
| 備註細項 | node /snmp / dicm exporter | |  | file_sd label/target 維護接口 |  | [wait](/journals_1/ProxmoxVE/README.md)   |


<!-- | 20250703 | cloudinit / autoinstall | ⏳ |    |    |   | here   | -->
<!-- | 20  | 工作內容             | 任務狀態 | 遇到的問題      | 解決方式 / 備註   |  備註2  | Link  |-->



✅: 完成 , ⏳: 未完成 , 🔄: 持續調整 daily routine
☑️: 手冊待調整

- [penal](journals_1/ProxmoxVE/README.md) **<--**
- [Catalog](/README.md)