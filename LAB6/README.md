# Lab 6: Xác thực Active Directory và Chính sách truy cập trên pfSense

## 📌 Giới thiệu tổng quan
Bài thực hành dựng một **pfSense CE 2.7.2** riêng cho LAB 6 trên VMware Workstation với 4 vùng mạng (WAN, MGMT, LAN, DMZ), tích hợp **Active Directory qua LDAP**, dùng AD làm nguồn xác thực cho **Captive Portal**, và chuẩn bị **Alias + Schedule** để xây dựng chính sách truy cập tương đương LAB Sophos gốc (chặn site theo máy, chặn nhóm site, cho phép theo khung giờ, giới hạn dịch vụ).

- **Sinh viên:** Nguyễn Lê Anh Trúc – MSSV 1150080078 – Lớp 11ĐHCNPM1
- **Video:** https://youtu.be/omvIcu0DjVw

---

## 🏗️ Kiến trúc & Mô hình mạng

| Vùng mạng | Interface | Chế độ VMware | Địa chỉ pfSense | Vai trò |
| :--- | :--- | :--- | :--- | :--- |
| **WAN** | `em0` | NAT (VMnet8) | DHCP `192.168.174.x` | Ra Internet |
| **MGMT** | `em1` | Host-only (VMnet2) | `192.168.56.254/24` | WebGUI quản trị riêng cho máy thật `192.168.56.1` |
| **LAN** | `em2` | LAN Segment `lab6-lan` | `10.6.0.1/24` | DC01 + Client, có Captive Portal |
| **DMZ** | `em3` | LAN Segment `lab6-dmz` | `172.16.6.1/24` | DMZ-WEB mô phỏng các nhóm website |

| Máy | IP | Ghi chú |
| :--- | :--- | :--- |
| DC01 (Windows Server 2025) | `10.6.0.10` | AD DS + DNS, domain `lab6.test` |
| Client-A (Kali Linux) | `10.6.0.21` | Đại diện tài khoản `sv_a` |
| Client-B | `10.6.0.22` | Đại diện tài khoản `sv_b` |
| DMZ-WEB (Ubuntu + Nginx) | `172.16.6.10 / .20 / .30 / .40` | GENERAL / JOB / SOCIAL / RESTRICTED site |

---

## ⚙️ Các bước đã triển khai

1. **pfSense-LAB6:** full clone VM pfSense rồi *Reset to factory defaults* (không dùng config LAB 5), gán 4 interface theo MAC, tắt DHCP trên LAN/MGMT/DMZ, tạo rule MGMT cho phép `192.168.56.1` vào WebGUI (443).
2. **DC01:** cài AD DS + DNS, forest `lab6.test`, OU `LAB6-Users` (`sv_a`, `sv_b`), service account `svc_pfsense_ldap` (không phải Domain Admin), DNS Forwarder `10.6.0.1`.
3. **LDAP Authentication Server `LAB6-AD`:** `10.6.0.10:389`, Entire Subtree, Base DN `DC=lab6,DC=test`, container `OU=LAB6-Users,DC=lab6,DC=test`, template Microsoft AD → test `sv_a`, `sv_b` thành công tại *Diagnostics → Authentication*.
4. **Captive Portal `LAB6_USERS`** trên LAN, xác thực bằng `LAB6-AD`; DC01 nằm trong *Allowed IP Addresses*. Client-A bị chuyển tới trang login `10.6.0.1:8002`, đăng nhập `sv_a` xong mới truy cập được web.
5. **DMZ-WEB:** 4 IP qua netplan + Nginx; rule DMZ: Block DMZ → LAN (log), Block DMZ → MGMT, Pass DMZ → Any.
6. **Alias:** `CLIENT_A`, `CLIENT_B`, `POLICY_CLIENTS`, `GENERAL_SITE`, `JOB_SITE`, `SOCIAL_SITE`, `RESTRICTED_SITE`, `WEB_PORTS (80,443)`.
7. **Schedule:** `LUNCH_WINDOW` (11:30–13:00 T2–T6), `WORK_HOURS` (08:00–17:00 T2–T6), `TEST_NOW`.

### ⚠️ Sự cố đáng chú ý
Windows Server 2025 mặc định **bắt buộc LDAP signing**, khiến pfSense báo `Could not bind to LDAP server` khi simple bind qua cổng 389. Trong lab cô lập đã tắt *Domain controller: LDAP server signing requirements* (+ *Enforcement*) trên Default Domain Controllers Policy. Triển khai thật nên dùng **LDAPS (636)** với chứng chỉ phù hợp.

---

## 🧪 Ruleset thiết kế cho các kịch bản (tab LAN, first-match)

| # | Action | Source → Destination | Port | Schedule | Kịch bản |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 1 | Block + Log | CLIENT_A → JOB_SITE | TCP/80 | — | KB1 |
| 2 | Block + Log | POLICY_CLIENTS → RESTRICTED_SITE | TCP/80 | — | KB2 |
| 3 | Pass | CLIENT_B → SOCIAL_SITE | TCP/80 | LUNCH_WINDOW | KB3 |
| 4 | Block + Log | CLIENT_B → SOCIAL_SITE | TCP/80 | — | KB3 |
| 5 | Pass | POLICY_CLIENTS → GENERAL_SITE | TCP/80 | — | Site thường |
| 6 | Pass | POLICY_CLIENTS → Any | WEB_PORTS | WORK_HOURS | KB4 |
| 7 | Block + Log | POLICY_CLIENTS → Any | Any | — | KB4 (explicit deny) |

> Trạng thái: LDAP, Captive Portal, Alias, Schedule đã hoàn thành có minh chứng. Các kịch bản 1–5 đã thiết kế ruleset, **chưa thực hiện kiểm thử** trong bản nộp này.

---

## 📂 Cấu trúc thư mục

```text
LAB6/
├── README.md                                      # Tài liệu tổng quan bài thực hành
├── 11DHCNPM1-Lab6_1150080078-NguyenLeAnhTruc.docx # Báo cáo chi tiết, hình minh chứng, 12 câu hỏi
└── LAB6_pfSense_AD_Access_Policies_2026.pdf       # Đề bài
```
