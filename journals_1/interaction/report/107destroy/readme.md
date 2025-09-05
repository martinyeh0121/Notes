

![alt text](image-1.png)

![alt text](image.png)

nas3  disk0
![alt text](image-2.png)
![alt text](image-3.png)

直接刪除
![alt text](image-4.png)

qm list config .. 有關107都卡死

``` sh

rbd snap purge -p main vm-107-disk-0
rbd rm -p main vm-107-disk-0

root@mbpc220610:~# ls /etc/pve/nodes/*/qemu-server/107.conf
/etc/pve/nodes/mbpc220610/qemu-server/107.conf
root@mbpc220610:~# mv /etc/pve/nodes/mbpc220610/qemu-server/107.conf /etc/pve/nodes/mbpc220610/qemu-server/107.conf.bak
root@mbpc220610:~# 
```

![alt text](image-7.png)

成功暫緩

![alt text](image-6.png)

![alt text](image-5.png)
list 正常
![alt text](image-8.png)