#!/usr/bin/env bash
# LAB7 - kiem thu tat ca kich ban tu Client-A (Kali 10.6.0.21)
# Cach chay: bash /mnt/hgfs/LAB7/scripts/test.sh
P=http://10.6.0.30:8080
check() { # url -> ket qua
  body=$(curl -s -m 10 -x "$P" "$1")
  if echo "$body" | grep -q "LAB 7 - Website mo phong\|LAB7 Download Test"; then echo "CHO PHEP"
  elif [ -z "$body" ]; then echo "KHONG KET NOI DUOC (bi chan)"
  elif echo "$body" | grep -qi "ERR_ACCESS_DENIED\|ERR_CONNECT\|squid"; then echo "BI CHAN (Squid)"
  elif echo "$body" | grep -qi "bypass"; then echo "CANH BAO - co link bypass tam (E2Guardian)"
  else echo "BI CHAN (E2Guardian)"; fi
}
echo "Client: $(hostname) $(ip -4 -o addr show | awk '$2!="lo"{print $4}')   Thoi gian: $(date '+%d/%m/%Y %H:%M:%S')"
echo "================ TRUY CAP QUA PROXY 10.6.0.30:8080 ================"
for n in normal china mideast jobs weapons politics religion education entertainment games streaming blockedgame download; do
  printf "%-26s %s\n" "$n.lab7.test" "$(check http://$n.lab7.test/)"
done
echo "================ TRUY CAP TRUC TIEP (KHONG QUA PROXY) ================"
code=$(curl -s -m 6 -o /dev/null -w '%{http_code}' http://normal.lab7.test/)
[ "$code" = "000" ] && echo "http://normal.lab7.test  -> BI pfSense CHAN (timeout)" || echo "http://normal.lab7.test  -> HTTP $code (CHUA CHAN!)"
code=$(curl -s -m 6 -o /dev/null -w '%{http_code}' https://www.google.com/)
[ "$code" = "000" ] && echo "https://www.google.com   -> BI pfSense CHAN (timeout)" || echo "https://www.google.com   -> HTTP $code (CHUA CHAN!)"
echo "================ ANTIVIRUS (EICAR) ================"
curl -s -m 15 -x "$P" http://download.lab7.test/files/eicar.com.txt | grep -o -i -m 3 'virus[^<]*\|eicar[^<]*\|blocked[^<]*' || echo "(khong co noi dung)"
echo "================ GIOI HAN KICH THUOC ================"
for f in 100MB.bin 110MB.bin; do
  r=$(curl -s -m 120 -x "$P" -o /dev/null -w '%{http_code} %{size_download}' "http://download.lab7.test/files/$f")
  printf "%-10s HTTP %s byte\n" "$f" "$r"
done
