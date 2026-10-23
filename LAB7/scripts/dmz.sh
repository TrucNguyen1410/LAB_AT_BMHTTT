#!/usr/bin/env bash
# LAB7 - chay tren DMZ-WEB (172.16.6.10): tao 13 website *.lab7.test + file test
# Cach chay: sudo bash /mnt/hgfs/LAB7/scripts/dmz.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
apt-get install -y python3 >/dev/null 2>&1 || true
bash "$HERE/../LAB7_Resources/01_DMZ_WEB/setup_lab7_dmz_web.sh"

echo
echo "================ KIEM TRA DMZ-WEB ================"
ip -4 -o addr show | awk '$2!="lo"{print "IP:", $4}'
for n in normal china jobs weapons education entertainment games download; do
  t=$(curl -s -H "Host: $n.lab7.test" http://127.0.0.1/ | grep -o '<title>[^<]*' | sed 's/<title>//')
  printf "%-26s -> %s\n" "$n.lab7.test" "${t:-LOI}"
done
ls -lh /var/www/lab7/download/files
