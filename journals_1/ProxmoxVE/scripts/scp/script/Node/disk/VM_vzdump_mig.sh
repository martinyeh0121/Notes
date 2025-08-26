# qm snapshot 100 100_1 --description "Backup test"

vzdump 100 --mode snapshot --storage local --compress zstd
qmrestore /var/lib/vz/dump/vzdump-qemu-100-2025_06_30-.vma.zst 200 --storage local-lvm
