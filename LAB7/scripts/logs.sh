#!/usr/bin/env bash
# LAB7 - xem log E2Guardian / Squid / ClamAV gan nhat (de chup anh)
# Cach chay: sudo bash /mnt/hgfs/LAB7/scripts/logs.sh
E2LOG=$(ls /var/log/e2guardian/access.log 2>/dev/null || ls -t /var/log/e2guardian/* 2>/dev/null | head -n 1)
echo "===== E2Guardian ($E2LOG) - 20 dong lab7 gan nhat ====="
grep -i 'lab7' "$E2LOG" 2>/dev/null | tail -n 20
echo "===== Squid access.log - 10 dong gan nhat ====="
tail -n 10 /var/log/squid/access.log 2>/dev/null
echo "===== ClamAV - phat hien EICAR ====="
journalctl -u clamav-daemon --no-pager 2>/dev/null | grep -i 'eicar\|FOUND' | tail -n 5
