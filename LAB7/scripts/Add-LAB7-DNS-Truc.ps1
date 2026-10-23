# LAB7 - chay tren DC01 (chuot phai file -> Run with PowerShell)
# Dua tren 02_DNS/Add-LAB7-DNS.ps1 cua giang vien.
# Khac biet: entertainment/games tro ve 172.16.6.30 (IP phu cua DMZ-WEB) de pfSense
# co the ap Schedule 60 phut theo IP dich; cac site con lai tro ve 172.16.6.10.
$zone = "lab7.test"
$records = [ordered]@{
  normal="172.16.6.10"; china="172.16.6.10"; mideast="172.16.6.10"; jobs="172.16.6.10"
  weapons="172.16.6.10"; politics="172.16.6.10"; religion="172.16.6.10"; education="172.16.6.10"
  entertainment="172.16.6.30"; games="172.16.6.30"
  streaming="172.16.6.10"; blockedgame="172.16.6.10"; download="172.16.6.10"
}
if (-not (Get-DnsServerZone -Name $zone -ErrorAction SilentlyContinue)) {
  Add-DnsServerPrimaryZone -Name $zone -ReplicationScope "Domain"
}
foreach ($n in $records.Keys) {
  Get-DnsServerResourceRecord -ZoneName $zone -Name $n -RRType A -ErrorAction SilentlyContinue |
    Remove-DnsServerResourceRecord -ZoneName $zone -Force
  Add-DnsServerResourceRecordA -ZoneName $zone -Name $n -IPv4Address $records[$n]
}
Write-Host "`n===== Ban ghi A trong zone lab7.test =====" -ForegroundColor Cyan
Get-DnsServerResourceRecord -ZoneName $zone -RRType A |
  Select-Object HostName, @{n="IP";e={$_.RecordData.IPv4Address}} | Format-Table -AutoSize
Resolve-DnsName normal.lab7.test -Server 127.0.0.1 | Format-Table -AutoSize
Read-Host "Xong. Nhan Enter de dong"
