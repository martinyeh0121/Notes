for i in 1M 4M 16M 32M 64M 128M 256M 512M 1G 2G 4G
do
  echo "Testing bs=$i..."
  dd if=/dev/zero of=/dev/null bs=$i count=1 status=none && echo "  ✅ Success" || echo "  ❌ Failed"
done
