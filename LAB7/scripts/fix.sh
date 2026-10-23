#!/usr/bin/env bash
# LAB7 - sua E2Guardian: kich hoat danh sach site (banned/exception/nobypass) + bo chan duoi .bin
# Cach chay: sudo bash /mnt/hgfs/LAB7/scripts/fix.sh
HERE="$(cd "$(dirname "$0")" && pwd)"
RES="$HERE/../LAB7_Resources/03_WEB_PROXY/lists"
E2=/etc/e2guardian; F1=$E2/e2guardianf1.conf
cp -n "$F1" "$F1.bak-fix" 2>/dev/null

addlist() { touch "$2"; [ -n "$(tail -c1 "$2")" ] && echo >> "$2"
  while IFS= read -r d || [ -n "$d" ]; do d=${d%$'\r'}; [ -z "$d" ] && continue
    grep -qxF "$d" "$2" || echo "$d" >> "$2"; done < "$1"; }

echo "[1] Bat cac dong sitelist trong e2guardianf1.conf"
for n in banned exception bannedbypass; do
  sed -i -E "s|^#+[[:space:]]*(sitelist[[:space:]]*=[[:space:]]*'name=$n,)|\1|" "$F1"
  grep -E "^sitelist[[:space:]]*=[[:space:]]*'name=$n," "$F1" || echo "  !! khong thay dong sitelist name=$n"
done

echo "[2] Them domain vao moi ban sao cua danh sach"
for f in $(find $E2 -name bannedsitelist); do addlist "$RES/hard_block_sites.txt" "$f"; addlist "$RES/warning_sites.txt" "$f"; echo "  $f"; done
for f in $(find $E2 -name domainsnobypass); do addlist "$RES/hard_block_sites.txt" "$f"; echo "  $f"; done
for f in $(find $E2 -name exceptionsitelist); do addlist "$RES/allow_sites.txt" "$f"; echo "  $f"; done

echo "[3] Bo chan duoi .bin (de kiem thu gioi han 100MB/110MB)"
for f in $(find $E2 -name bannedextensionlist); do sed -i -E 's/^(\.bin)([[:space:]]|$)/#\1\2/' "$f"; done

systemctl restart e2guardian; sleep 4
echo "[4] Kiem tra"
printf "  e2guardian: %s\n" "$(systemctl is-active e2guardian)"
for n in weapons china normal education; do
  b=$(curl -s -m 8 -x http://127.0.0.1:8080 "http://$n.lab7.test/")
  if echo "$b" | grep -q "Website mo phong"; then r="CHO PHEP"
  elif echo "$b" | grep -qi "bypass"; then r="CANH BAO + link bypass"
  else r="BI CHAN"; fi
  printf "  %-22s %s\n" "$n.lab7.test" "$r"
done
tail -n 4 /var/log/e2guardian/access.log | cut -c1-160
echo "[5] Thong tin chan doan (gui kem neu weapons van CHO PHEP)"
grep -nE "^[^#]*(listdir|__LISTDIR__|storyboard)" $E2/e2guardian.conf $F1 | head -n 8
journalctl -u e2guardian --no-pager -n 20 | grep -iE "error|warn|list" | tail -n 6
