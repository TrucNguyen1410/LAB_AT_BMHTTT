#!/usr/bin/env bash
# LAB7 - chan doan E2Guardian tren WEB-PROXY
# Cach chay: sudo bash /mnt/hgfs/LAB7/scripts/diag.sh
E2=/etc/e2guardian
echo "== e2guardian -v =="; e2guardian -v 2>&1 | head -n 2
echo "== Cac dong sitelist/storyboard trong f1 =="
grep -nE "^[^#]*(sitelist|storyboard|bannedsite|domainsnobypass|groupname)" $E2/e2guardianf1.conf
echo "== Nhom/auth trong e2guardian.conf =="
grep -nE "^[^#]*(filtergroups|authplugin|storyboard|listdir|languagedir|reportinglevel|weightedphrasemode)" $E2/e2guardian.conf
echo "== Duoi file bannedsitelist (hex 3 dong cuoi) =="
tail -n 3 $E2/lists/bannedsitelist | od -c | tail -n 5
echo "== Thu truc tiep tren proxy =="
for n in weapons china normal; do
  printf "%-22s " "$n.lab7.test"
  curl -s -m 8 -x http://127.0.0.1:8080 "http://$n.lab7.test/" | grep -o -i -m1 '<title>[^<]*' || echo "(rong)"
done
echo "== access.log (8 dong cuoi) =="
tail -n 8 /var/log/e2guardian/access.log 2>/dev/null
echo "== journal e2guardian (loi gan nhat) =="
journalctl -u e2guardian --no-pager -n 15 2>/dev/null | grep -iv "started\|stopping\|stopped" | tail -n 10
