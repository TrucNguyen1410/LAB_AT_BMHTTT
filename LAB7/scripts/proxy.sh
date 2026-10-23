#!/usr/bin/env bash
# LAB7 - chay tren WEB-PROXY (may clone tu DMZ-WEB)
# Cach chay: sudo bash /mnt/hgfs/LAB7/scripts/proxy.sh
# Lam: dat IP 10.6.0.30, cai Squid + E2Guardian + ClamAV, cau hinh theo 03_WEB_PROXY.
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "Hay chay bang sudo"; exit 1; }
HERE="$(cd "$(dirname "$0")" && pwd)"
RES="$HERE/../LAB7_Resources/03_WEB_PROXY"
export DEBIAN_FRONTEND=noninteractive
# Neu Ubuntu dang tu cap nhat ngam (unattended-upgrades) thi cho toi da 15 phut thay vi bao loi
echo 'DPkg::Lock::Timeout "900";' > /etc/apt/apt.conf.d/99lab7-lock-wait

IFACE=$(ip -o link show | awk -F': ' '$2!="lo"{print $2; exit}')
echo "[1/7] Dat hostname web-proxy, IP 10.6.0.30/24 tren card $IFACE"
hostnamectl set-hostname web-proxy
grep -q 'web-proxy' /etc/hosts || echo "127.0.1.1 web-proxy" >> /etc/hosts
mkdir -p /root/netplan-backup && cp -f /etc/netplan/*.yaml /root/netplan-backup/ 2>/dev/null || true
rm -f /etc/netplan/*.yaml
cat > /etc/netplan/01-lab7-proxy.yaml <<EOF
network:
  version: 2
  ethernets:
    $IFACE:
      dhcp4: false
      addresses: [10.6.0.30/24]
      routes:
        - to: default
          via: 10.6.0.1
      nameservers:
        addresses: [10.6.0.10]
EOF
chmod 600 /etc/netplan/01-lab7-proxy.yaml
netplan apply
sleep 4
systemctl disable --now nginx 2>/dev/null || true

echo "[2/7] Kiem tra mang"
ping -c 2 -W 2 10.6.0.1  >/dev/null 2>&1 && echo "  ping 10.6.0.1  OK"  || echo "  !! khong ping duoc 10.6.0.1"
ping -c 2 -W 2 10.6.0.10 >/dev/null 2>&1 && echo "  ping 10.6.0.10 OK" || echo "  !! khong ping duoc 10.6.0.10"
getent hosts normal.lab7.test >/dev/null && echo "  DNS lab7.test OK" || echo "  !! chua phan giai duoc normal.lab7.test (chay script DNS tren DC01)"
if ! getent hosts archive.ubuntu.com >/dev/null; then
  echo "  !! Khong phan giai duoc archive.ubuntu.com -> kiem tra DC01 dang bat, Captive Portal da tat"; exit 1
fi
echo "  DNS Internet OK"

echo "[3/7] Cai Squid, E2Guardian, ClamAV (mat vai phut)"
apt-get update
if ! apt-cache policy e2guardian | grep -q 'Candidate: [0-9]'; then
  echo "  bat kho universe"
  S=/etc/apt/sources.list.d/ubuntu.sources
  [ -f "$S" ] && grep -q '^Components:' "$S" && ! grep -q 'universe' "$S" && \
    sed -i -E 's/^(Components: .*)$/\1 universe/' "$S"
  apt-get update
fi
apt-get install -y squid e2guardian clamav clamav-daemon clamav-freshclam curl openssl

echo "[4/7] Cau hinh Squid (chi nghe 127.0.0.1:3128)"
[ -f /etc/squid/squid.conf.orig ] || cp /etc/squid/squid.conf /etc/squid/squid.conf.orig
cat > /etc/squid/squid.conf <<'EOF'
# LAB7 - Squid la upstream cua E2Guardian, chi nghe localhost
http_port 127.0.0.1:3128
acl localhost src 127.0.0.1/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl CONNECT method CONNECT
# Hard block lop thu 2: du co bypass o E2Guardian, Squid van tu choi
acl lab7_hardblock dstdomain china.lab7.test mideast.lab7.test jobs.lab7.test blockedgame.lab7.test
http_access deny lab7_hardblock
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost
http_access deny all
# Gioi han file tai ve: lon hon 100 MB bi tu choi (100MB.bin duoc, 110MB.bin bi chan)
reply_body_max_size 100 MB
cache deny all
access_log daemon:/var/log/squid/access.log squid
coredump_dir /var/spool/squid
EOF
squid -k parse 2>&1 | tail -n 2

echo "[5/7] Cau hinh E2Guardian"
E2=/etc/e2guardian; MAIN=$E2/e2guardian.conf; F1=$E2/e2guardianf1.conf; L=$E2/lists
for f in "$MAIN" "$F1"; do [ -f "$f.orig" ] || cp "$f" "$f.orig"; done
setkv() { # file key value : sua dong (ke ca dang bi comment) hoac them moi
  local file=$1 key=$2 val=$3
  if grep -Eq "^[#[:space:]]*$key[[:space:]]*=" "$file"; then
    sed -i -E "0,/^[#[:space:]]*$key[[:space:]]*=.*/s||$key = $val|" "$file"
  else
    echo "$key = $val" >> "$file"
  fi
}
setkv "$MAIN" filterports 8080
setkv "$MAIN" proxyip 127.0.0.1
setkv "$MAIN" proxyport 3128
setkv "$MAIN" loglevel 3
setkv "$MAIN" enablessl off
# bat ClamAV scanner
sed -i -E "s|^#+[[:space:]]*(contentscanner[[:space:]]*=[[:space:]]*'[^']*clamdscan\.conf')|\1|" "$MAIN"
grep -Eq "^contentscanner[[:space:]]*=.*clamdscan" "$MAIN" || \
  echo "contentscanner = '$E2/contentscanners/clamdscan.conf'" >> "$MAIN"
setkv "$F1" reportinglevel 3
setkv "$F1" bypass 300
# download.lab7.test nam trong exceptionsitelist nhung file van phai qua AV
# -> bat quet ca site ngoai le (neu de off, EICAR tren site whitelist se khong bi quet)
setkv "$F1" contentscanexceptions on
if grep -Eq "^[#[:space:]]*cgikey[[:space:]]*=" "$F1"; then
  setkv "$F1" cgikey "'lab7-$(openssl rand -hex 12)'"
fi
addlist() { # src dst : them domain (khong trung lap)
  touch "$2"
  while IFS= read -r d || [ -n "$d" ]; do
    d=${d%$'\r'}; [ -z "$d" ] && continue
    grep -qxF "$d" "$2" || echo "$d" >> "$2"
  done < "$1"
}
addlist "$RES/lists/hard_block_sites.txt" "$L/bannedsitelist"
addlist "$RES/lists/warning_sites.txt"    "$L/bannedsitelist"
addlist "$RES/lists/hard_block_sites.txt" "$L/domainsnobypass"   # khong cho bypass
addlist "$RES/lists/allow_sites.txt"      "$L/exceptionsitelist"

echo "[6/7] ClamAV: tai CSDL virus + noi voi E2Guardian"
CS=$E2/contentscanners/clamdscan.conf
SOCK=$(awk '/^LocalSocket /{print $2}' /etc/clamav/clamd.conf); SOCK=${SOCK:-/var/run/clamav/clamd.ctl}
[ -f "$CS" ] && setkv "$CS" clamdudsfile "'$SOCK'"
# Chi trong lab: cho clamd chay quyen root de doc duoc file tam cua E2Guardian
sed -i -E 's/^User .*/User root/' /etc/clamav/clamd.conf
if [ "$(systemctl show e2guardian -p PrivateTmp --value 2>/dev/null)" = "yes" ]; then
  mkdir -p /var/lib/e2guardian/scan
  chmod 1777 /var/lib/e2guardian/scan
  setkv "$MAIN" filecachedir "'/var/lib/e2guardian/scan'"
fi
systemctl stop clamav-freshclam 2>/dev/null || true
freshclam || echo "  !! freshclam loi (co the thu lai sau: sudo freshclam)"
systemctl enable --now clamav-freshclam 2>/dev/null || true
systemctl enable clamav-daemon
systemctl restart clamav-daemon
echo "  cho clamd nap CSDL..."; for i in $(seq 1 60); do [ -S "$SOCK" ] && break; sleep 2; done

echo "[7/7] Khoi dong dich vu"
systemctl enable squid e2guardian
systemctl restart squid
systemctl restart e2guardian
sleep 3
echo
echo "================ KET QUA WEB-PROXY ================"
hostname; ip -4 -o addr show "$IFACE" | awk '{print "IP:", $4}'
for s in squid e2guardian clamav-daemon; do printf "  %-15s %s\n" "$s" "$(systemctl is-active $s)"; done
ss -lntp | grep -E ':8080|:3128' || true
e2guardian -v 2>/dev/null | head -n 1 || true
printf "Test qua proxy normal.lab7.test: "
curl -s -m 10 -x http://127.0.0.1:8080 http://normal.lab7.test/ | grep -o '<title>[^<]*' | sed 's/<title>//' || echo "LOI"
