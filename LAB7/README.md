# Lab 7: Xây dựng chính sách Web Protection trên mô hình pfSense + Web Proxy

## 📌 Giới thiệu tổng quan
Bài thực hành chuyển các yêu cầu Web Protection của LAB Sophos gốc sang mô hình mã nguồn mở: **pfSense CE** làm firewall/gateway (L3/L4) và ép mọi lưu lượng web của client đi qua một **Web Proxy riêng** (L7) gồm **E2Guardian → Squid → ClamAV** chạy trên Ubuntu Server. Squid/SquidGuard **không** được cài trên pfSense vì Netgate đã đánh dấu các package này là deprecated.

- **Sinh viên:** Nguyễn Lê Anh Trúc – MSSV 1150080078 – Lớp 11ĐHCNPM1
- **Video:** *(cập nhật link YouTube)*

---

## 🏗️ Kiến trúc & Mô hình mạng

```text
Client-A (Kali 10.6.0.21) ──► E2Guardian :8080 ──► Squid 127.0.0.1:3128 ──► pfSense ──► Website
                         (WEB-PROXY 10.6.0.30, ClamAV quét file)
Truy cập trực tiếp TCP 80/443 từ client ──► bị pfSense chặn (chống bypass)
```

| Máy | IP | Vai trò |
| :--- | :--- | :--- |
| **pfSense-LAB6** | MGMT `192.168.56.254` · LAN `10.6.0.1` · DMZ `172.16.6.1` | Firewall, ép client đi qua proxy |
| **DC01** (Windows Server 2025) | `10.6.0.10` | AD + DNS, zone `lab7.test` |
| **WEB-PROXY** (Ubuntu, E2Guardian 5.5.9) | `10.6.0.30` | E2Guardian :8080, Squid :3128 (localhost), ClamAV |
| **DMZ-WEB** (Ubuntu + Nginx) | `172.16.6.10` (+ `172.16.6.30`) | 13 website mô phỏng `*.lab7.test` |
| **Client-A** (Kali Linux) | `10.6.0.21` | Máy người dùng kiểm thử |

---

## ⚙️ Các bước đã triển khai

1. **DMZ-WEB:** tạo 13 virtual host Nginx, file test 10/100/110 MB và EICAR bằng `setup_lab7_dmz_web.sh`.
2. **DC01:** tạo zone `lab7.test`; `entertainment`/`games` trỏ về `172.16.6.30`, các site còn lại về `172.16.6.10`; DNS forwarder `10.6.0.1`, `8.8.8.8`.
3. **WEB-PROXY:** clone từ DMZ-WEB, đặt IP `10.6.0.30`, cài Squid + E2Guardian + ClamAV; Squid chỉ nghe localhost.
4. **Chính sách E2Guardian:**
   - Hard block: `china`, `mideast`, `jobs`, `blockedgame` → `bannedsitelist` + `domainsnobypass` + ACL Squid `lab7_hardblock`.
   - Warning: `weapons`, `politics`, `religion`, `streaming` → `bannedsitelist`, `bypass = 300` (Acknowledge mở tạm 5 phút).
   - Exception: `normal`, `education`, `download` → `exceptionsitelist`, `contentscanexceptions = on` để vẫn quét AV.
   - ClamAV: `contentscanner = clamdscan.conf`.
5. **pfSense:** Alias `LAB7_CLIENTS`, `LAB7_PROXY`, `LAB7_ENT_SITE`, `MAIL_PORTS`; Schedule `LAB7_ENT_60M`; ruleset LAN 10 rule (DNS, client→proxy 8080, mail, **block client→WEB_PORTS**, proxy→entertainment theo schedule, proxy→web, explicit deny).

---

## 🧪 Kết quả kiểm thử

| Kịch bản | Kết quả |
| :--- | :--- |
| 1. Baseline `normal` | ✅ Qua proxy được phép; truy cập trực tiếp bị pfSense chặn (timeout) |
| 2. Geo-Sim `china`, `mideast` | ✅ Hard block |
| 3. Job Search `jobs` | ✅ Hard block |
| 4. Warning `weapons` | ✅ Trang cảnh báo + Acknowledge mở tạm 300 giây |
| 5. Education | ✅ Được phép, không cảnh báo |
| 6. Entertainment/Game | ✅ Trong schedule được phép · ⏳ ngoài schedule chưa chụp |
| 7. Streaming | ⏳ Đã đưa vào danh sách cảnh báo, chưa chụp riêng |
| 8. Specific game `blockedgame` | ✅ Hard block |
| 9. Antivirus EICAR | ✅ `*INFECTED* Eicar-Signature` |
| 10. Size 100/110 MB | ⚠️ Không kết luận (bị chặn do đuôi `.bin`, không phải do kích thước) |

### ⚠️ Sự cố đáng chú ý
- **E2Guardian 5.5** đọc danh sách tại `/etc/e2guardian/lists/example.group/` (biến `__LISTDIR__`), không phải `lists/` → nhóm warning ban đầu không bị chặn; đã sửa bằng `scripts/fix.sh`.
- `bannedextensionlist` mặc định cấm `.bin` → làm sai phép thử kích thước.
- Firefox báo timeout và E2Guardian không có log do cấu hình proxy nhầm trên máy thật thay vì Client-A.

---

## 📂 Cấu trúc thư mục

```text
LAB7/
├── README.md                                       # Tài liệu tổng quan bài thực hành
├── 11DHCNPM1-Lab7_1150080078-NguyenLeAnhTruc.docx  # Báo cáo chi tiết, hình minh chứng, câu hỏi phân tích
├── LAB7_pfSense_Web_Protection_2026.docx           # Đề bài
├── LAB7_Resources/                                 # Bộ tài nguyên của giảng viên
└── scripts/                                        # Script tự viết, chạy qua VMware Shared Folder
    ├── dmz.sh                  # DMZ-WEB: dựng 13 website mô phỏng
    ├── Add-LAB7-DNS-Truc.ps1   # DC01: tạo zone lab7.test
    ├── proxy.sh                # WEB-PROXY: IP + Squid + E2Guardian + ClamAV
    ├── fix.sh                  # Sửa thư mục danh sách E2Guardian 5.5, bỏ chặn .bin
    ├── policy.sh / logs.sh / diag.sh   # In chính sách, log, chẩn đoán
    └── test.sh                 # Client-A: kiểm thử toàn bộ kịch bản
```

> ⚠️ Không đưa file backup cấu hình pfSense (`config.xml`) hoặc private key CA lên repo.
