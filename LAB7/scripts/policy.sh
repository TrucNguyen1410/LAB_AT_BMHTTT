#!/usr/bin/env bash
# LAB7 - in chinh sach dang ap dung tren WEB-PROXY (de chup anh minh chung)
# Cach chay: sudo bash /mnt/hgfs/LAB7/scripts/policy.sh
E2=/etc/e2guardian; L=$E2/lists
echo "===== E2Guardian e2guardian.conf ====="
grep -E '^(filterip|filterports|proxyip|proxyport|loglevel|enablessl|contentscanner)[[:space:]]*=' $E2/e2guardian.conf
echo "===== E2Guardian e2guardianf1.conf ====="
grep -E '^(reportinglevel|bypass|contentscanexceptions)[[:space:]]*=' $E2/e2guardianf1.conf
echo "===== bannedsitelist (hard block + warning) ====="; grep 'lab7' $L/bannedsitelist
echo "===== domainsnobypass (KHONG cho bypass) =====";    grep 'lab7' $L/domainsnobypass
echo "===== exceptionsitelist (whitelist) =====";         grep 'lab7' $L/exceptionsitelist
echo "===== Squid ====="
grep -E '^(http_port|acl lab7_hardblock|http_access deny lab7|reply_body_max_size)' /etc/squid/squid.conf
for s in squid e2guardian clamav-daemon; do printf "%-15s %s\n" "$s" "$(systemctl is-active $s)"; done
