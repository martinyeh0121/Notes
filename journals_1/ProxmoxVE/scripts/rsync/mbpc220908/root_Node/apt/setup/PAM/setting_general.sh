#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo "⚠️ 請以 root 權限執行"
   exit 1
fi

echo "==== 安裝 PAM 密碼品質模組 ===="
apt-get update
apt-get install -y libpam-pwquality \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold"

echo "==== 設定 PAM 密碼策略 ===="
PAM_FILE="/etc/pam.d/common-password"
# Backup original file
cp "$PAM_FILE" "${PAM_FILE}.backup"

# Update PAM configuration
sed -i 's/password.*requisite.*pam_pwquality\.so.*/password   requisite    pam_pwquality.so retry=3 minlen=12 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 enforce_for_root/' "$PAM_FILE"

echo "==== 設定登入策略 ===="
LOGIN_DEFS="/etc/login.defs"
# Backup original file
cp "$LOGIN_DEFS" "${LOGIN_DEFS}.backup"

# Update password aging controls
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' "$LOGIN_DEFS"
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' "$LOGIN_DEFS"
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' "$LOGIN_DEFS"

echo "==== 套用密碼策略到現有使用者 ===="
# Find all regular users (UID >= 1000)
for user in $(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd); do
    echo "更新使用者密碼策略: $user"
    chage -M 90 -m 1 -W 7 "$user"
done

echo "✅ PAM 與密碼策略設定完成"
echo "⚠️ 新密碼要求說明："
echo "  - 最小長度：12 個字元"
echo "  - 必須包含：大寫字母、小寫字母、數字和特殊字元"
echo "  - 密碼有效期：90 天"
echo "  - 密碼最短使用期限：1 天"
echo "  - 密碼過期警告：7 天前"
echo "  - 這些規則同樣適用於 root 帳號"