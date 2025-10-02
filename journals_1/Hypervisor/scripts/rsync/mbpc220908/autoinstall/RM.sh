xorriso -as mkisofs \
  -o ./iso_build/ubuntu-uefi-autoinstall.iso \
  -V "UEFI_ONLY" \
  -J -R -l -iso-level 3 \
  -isohybrid-gpt-basdat \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  ./iso

xorriso -as mkisofs \
  -o ./iso_build/ubuntu-autoinstall.iso \
  -V "UBUNTU_CUSTOM" \
  -J -R -l -iso-level 3 \
  -isohybrid-gpt-basdat \
  -eltorito-boot boot/grub/i386-pc/eltorito.img \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
     -e boot/grub/efi.img \
     -no-emul-boot \
  ./iso
  
cp ./iso_build/youriso.iso /mnt/c/Users/marti/Downloads/isos/


# 掛載 iso
sudo mount -o loop ./ubuntu-22.04.5-live-server-amd64_ori.iso /mnt/iso

# 解壓縮 iso
7z -y x ubuntu-22.04.5-live-server-amd64.iso -o source-files

# 進入 source-files/
# cd source-files/
cd /home/isos/ubuntu22045/origin/source-files

# 移動 [BOOT] 到 ../BOOT
mv  '[BOOT]' ../BOOT

# 修改 grubcfg  boot/grub/grub.cfg`
# 加入 autoinstall/user-data


# 查看 iso 檔案結構
xorriso -indev ubuntu-22.04.5-live-server-amd64.iso -report_el_torito as_mkisofs

# 打包 iso 依據檔案結構
xorriso -as mkisofs -r \
  -V 'Ubuntu 22.04 LTS AUTO (EFIBIOS)' \
  -o ../build/ubuntu-22.04-autoinstall_pug.iso \
  --grub2-mbr ../BOOT/1-Boot-NoEmul.img \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b ../BOOT/2-Boot-NoEmul.img \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
  -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:::' \
  -no-emul-boot \
  .



xorriso -as mkisofs \
  -r -V "Ubuntu-Server 22.04.5 LTS amd64" \
  -o ../custom_ubuntu_22.04.5.iso \
  -J -l \
  -c boot.catalog \
  -b boot/grub/i386-pc/eltorito.img \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e EFI/boot/bootx64.efi \
     -no-emul-boot \
  .
# xorriso -as mkisofs -r \
#   -V 'Ubuntu-Server 22.04.5(AUTO)' \
#   -o ../ubuntu-22.04-autoinstall.iso \
#   --grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:'../ubuntu-22.04.5-live-server-amd64_ori.iso' \
#   --protective-msdos-label \
#   -partition_offset 16 \
#   --mbr-force-bootable \
#   -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:4162948d-4173019d::'../ubuntu-22.04.5-live-server-amd64_ori.iso' \
#   -appended_part_as_gpt \
#   -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
#   -c '/boot.catalog' \
#   -b '/boot/grub/i386-pc/eltorito.img' \
#   -no-emul-boot \
#   -boot-load-size 4 \
#   -boot-info-table \
#   --grub2-boot-info \
#   -eltorito-alt-boot \
#   -e '--interval:appended_partition_2_start_1040737s_size_10072d:all::' \
#   -no-emul-boot \
#   -boot-load-size 10072 \
#   .
SRC_ISO="../ubuntu-22.04.5-live-server-amd64_ori.iso"
DST_ISO="../build/ubuntu-22.04-autoinstall.iso"

xorriso -as mkisofs -r \
  -V 'Ubuntu-Server 22.04.5(AUTO)' \
  -o "$DST_ISO" \
  --modification-date='2024091118464800' \
  --grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:"$SRC_ISO" \
  --protective-msdos-label \
  -partition_cyl_align off \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:4162948d-4173019d::"$SRC_ISO" \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
  -no-emul-boot \
  -boot-info-table \
  --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2_start_1040737s_size_10072d:all::' \
  -no-emul-boot \
  -boot-load-size 10072 \
  .




  -V 'Ubuntu-Server 22.04.5 LTS amd64(AUTO)'
--modification-date='2024091118464800'
--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:'ubuntu-22.04.5-live-server-amd64.iso'
--protective-msdos-label
-partition_cyl_align off
-partition_offset 16
--mbr-force-bootable
-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:4162948d-4173019d::'ubuntu-22.04.5-live-server-amd64.iso'
-appended_part_as_gpt
-iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7
-c '/boot.catalog'
-b '/boot/grub/i386-pc/eltorito.img'
-no-emul-boot
-boot-load-size 4
-boot-info-table
--grub2-boot-info
-eltorito-alt-boot
-e '--interval:appended_partition_2_start_1040737s_size_10072d:all::'
-no-emul-boot
-boot-load-size 10072


cp ../ubuntu-22.04-autoinstall.iso /mnt/c/Users/marti/Downloads/isos/

scp ../ubuntu-22.04-autoinstall.iso root@192.168.5.132:/var/lib/vz/template/iso
# 


# xorriso -as mkisofs → 用 xorriso 打包 ISO

# -o ubuntu-uefi-autoinstall.iso → 輸出檔名

# -V "UEFI_ONLY" → ISO 卷標

# -J -R -l -iso-level 3 → 支援 Windows/Unix 長檔名，ISO9660 Level 3

# -eltorito-alt-boot → 開啟 El Torito alternative boot（UEFI 開機）

# -e boot/grub/efi.img → 指定 UEFI 映像檔

# -no-emul-boot → EFI 映像直接載入，不模擬軟碟

# -isohybrid-gpt-basdat → Hybrid ISO，可寫 USB，支援 GPT

# iso/ → 來源目錄（包含官方 ISO、autoinstall、efi.img）


## 事前準備
# sudo apt install dosfstools -y
# 建立 efi.img 10 M

## 建立一個 10 M 的 efi.img
dd if=/dev/zero of=./iso/boot/grub/efi.img bs=1M count=10
mkfs.vfat efi.img

## 確認 efi.img 是否是 10 M
ls -lh ./iso/boot/grub/efi.img
