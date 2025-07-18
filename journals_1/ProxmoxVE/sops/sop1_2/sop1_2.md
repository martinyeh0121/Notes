要使用官方提供的 Ubuntu 22.04 Cloud Image（例如 `jammy-server-cloudimg-amd64.img`）來建立 VM 並自動化執行剛剛的 Cloud-init 設定，這是一個非常專業又實用的做法 👏

以下我會一步步從 **Cloud Image + Cloud-init + QEMU/PVE 模板** 的角度完成系統安裝。

---

## ✅ 前置條件

工具或環境：

* Ubuntu 主機 或 Proxmox VE 環境
* `cloud-localds`（產生 Cloud-init ISO）
* `qemu-img`（轉換 image 格式）
* `jammy-server-cloudimg-amd64.img`（Ubuntu 22.04 Cloud Image）

---

## 🪜 步驟一：下載 Cloud Image

```bash
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

---

## 🪜 步驟二：建立 Cloud-init 設定檔（`user-data.yaml`）

建立一份名為 `user-data.yaml` 的檔案，內容如下：

```yaml
#cloud-config
hostname: ubuntu-server
timezone: Asia/Taipei

users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1...YOUR_PUBLIC_KEY...

package_update: true
package_upgrade: true

packages:
  - tasksel
  - net-tools
  - curl
  - vim
  - git
  - htop
  - python3-pip
  - openssh-server
  - fail2ban
  - ufw
  - unzip

write_files:
  - path: /etc/needrestart/needrestart.conf
    content: |
      \$nrconf{restart} = 'a';

runcmd:
  - export DEBIAN_FRONTEND=noninteractive
  - DEBIAN_FRONTEND=noninteractive tasksel install server
  - systemctl enable ssh
  - ufw allow OpenSSH
  - ufw --force enable
  - echo "✅ Server 初始化完成於 $(date)" >> /var/log/cloud-init-status.log
```

⚠️ 記得將 SSH 金鑰替換成自己的 `~/.ssh/id_rsa.pub` 的內容。

---

## 🪜 步驟三：產生 `cidata.iso`（Cloud-init disk）

你需要有 `cloud-localds` 工具（在 Ubuntu 上用 `cloud-image-utils` 套件提供）：

```bash
sudo apt install cloud-image-utils
```

產生 Cloud-init ISO：

```bash
cloud-localds cidata.iso user-data.yaml
```

---

## 🪜 步驟四：用 QEMU 測試

```bash
qemu-system-x86_64 \
  -m 2048 \
  -smp 2 \
  -hda jammy-server-cloudimg-amd64.img \
  -cdrom cidata.iso \
  -net nic -net user,hostfwd=tcp::2222-:22 \
  -nographic
```

然後你就可以從主機 `ssh ubuntu@localhost -p 2222` 登入 VM，密碼登入已停用，請用金鑰登入。

---

## 🪜 步驟五：Proxmox 上使用

如果你是用 Proxmox VE，可以這樣匯入建立模板：

### 1️⃣ 建立空白 VM

```bash
qm create 9000 --name ubuntu-cloud --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
```

### 2️⃣ 將 image 轉成 qcow2 格式並匯入

```bash
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
```

接著掛載磁碟、CD-ROM、設定 Cloud-init：

```bash
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
```

### 3️⃣ 設定 Cloud-init 內容（GUI 或 CLI）

你可以在 PVE Web UI 進入 VM → Cloud-Init → 填入：

* IP
* Gateway
* SSH Key

或者使用：

```bash
qm set 9000 --sshkey ~/.ssh/id_rsa.pub
```

### 4️⃣ 啟動 VM，Cloud-init 會自動執行你剛剛的 `user-data.yaml`

你可以打開 console 或直接 ssh 連進去觀察 `/var/log/cloud-init.log`。

---

## ✅ 補充：建立模板用 snapshot

在確認 Cloud-init 成功執行後，你可以停機後建立 template 來重複使用：

```bash
qm template 9000
```

---

## ☑️ 結論

| 階段      | 工具               | 功能                 |
| ------- | ---------------- | ------------------ |
| 設定 YAML | `user-data.yaml` | 自動化安裝邏輯            |
| 產生 ISO  | `cloud-localds`  | 模擬 Cloud-init disk |
| 測試      | QEMU / PVE       | 驗證自動化流程            |
| 大量複製    | Proxmox Template | 一鍵複製成多台 VM         |

---

要不要我幫你一鍵產生一份打包 zip，包括：

* YAML 設定檔
* shell 指令集（可複製貼上）
* 檔案結構說明

會讓你操作更流暢。需要嗎？
