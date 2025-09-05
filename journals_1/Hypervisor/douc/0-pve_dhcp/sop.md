# 系統安裝流程













# 如果你想要設定一台 **DHCP 伺服器**，這裡以在 **Debian / Ubuntu 系統** 上使用 `isc-dhcp-server` 為例，給你一份 **完整設定說明與範例設定檔**：

---

## ✅ 安裝 DHCP Server（以 Debian/Ubuntu 為例）

```bash
sudo apt update
sudo apt install isc-dhcp-server
```

---

## ✅ 設定檔位置

| 檔案路徑                           | 說明        |
| ------------------------------ | --------- |
| `/etc/dhcp/dhcpd.conf`         | DHCP 主設定檔 |
| `/etc/default/isc-dhcp-server` | 指定使用哪個介面  |

---

## ✅ `/etc/dhcp/dhcpd.conf` 範例設定

```conf
# 全域設定
default-lease-time 600;
max-lease-time 7200;
authoritative;

# 子網設定（假設你的內網是 192.168.1.0/24）
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.100 192.168.1.200;
  option routers 192.168.1.1;
  option subnet-mask 255.255.255.0;
  option domain-name-servers 8.8.8.8, 1.1.1.1;
  option domain-name "localdomain";
}
```

### ➕ 可選：針對特定 MAC 綁定固定 IP

```conf
host my-server {
  hardware ethernet 00:11:22:33:44:55;
  fixed-address 192.168.1.50;
}
```

---

## ✅ `/etc/default/isc-dhcp-server`（設定使用哪個網路介面）

修改這一行，設定 DHCP 要作用的介面（例如 `eth0` 或 `ens18`）：

```bash
INTERFACESv4="eth0"
```

---

## ✅ 啟動與重新啟動服務

```bash
sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server
```

---

## ✅ 確認服務狀態

```bash
sudo systemctl status isc-dhcp-server
```

---

## ✅ DHCP 記錄檔（可查看租用狀況）

```bash
/var/lib/dhcp/dhcpd.leases
```

---

如果你是在 **PVE（Proxmox）或裸機上架設內部 DHCP 伺服器**，要注意：

* 不要與現有的路由器（如家用 router）重複提供 DHCP
* 建議只在 isolated/internal network 中開啟

---

需要我幫你產出一個適用你環境的設定嗎？你只需要提供：

1. 你希望分配的 IP 範圍（如 192.168.100.100-200）
2. 子網路（如 /24）
3. gateway IP
4. 使用的網卡名稱（如 `vmbr1`, `eth0`）

我可以幫你產出一份完整設定。

``` sh
# 1️⃣ 確認 server 已開啟轉發
sysctl net.ipv4.ip_forward
# 若回傳 0，開啟：
sudo sysctl -w net.ipv4.ip_forward=1

# 套用 net.ipv4.ip_forward=1 到 /etc/sysctl.conf

if grep -q "^[[:space:]]*#\s*net.ipv4.ip_forward" /etc/sysctl.conf; then
  # 找到被註解的，就取消註解
  sudo sed -i 's/^[[:space:]]*#\s*net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
elif grep -q "^[[:space:]]*net.ipv4.ip_forward" /etc/sysctl.conf; then
  # 找到已經存在的，就強制改成 1
  sudo sed -i 's/^[[:space:]]*net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
else
  # 完全沒有，就加在最後一行
  echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
fi


# 2️⃣ 設定 NAT (讓 172.23.0.0/24 可以透過 192.168.16.62 出去)
#暫時
sudo iptables -t nat -A POSTROUTING -s 172.23.0.0/24 -o vmbr0 -j MASQUERADE
# 永久
sudo apt install iptables-persistent
sudo netfilter-persistent save

# 3️⃣ 允許 FORWARD 封包
sudo iptables -A FORWARD -i vmbr1 -o vmbr0 -j ACCEPT
sudo iptables -A FORWARD -i vmbr0 -o vmbr1 -m state --state RELATED,ESTABLISHED -j ACCEPT
```