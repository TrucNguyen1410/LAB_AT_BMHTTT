# BÁO CÁO THỰC HÀNH LAB 4: KHẢO SÁT VÀ ĐÁNH GIÁ BỀ MẶT MẠNG BẰNG NMAP

- **Môn học:** An toàn Hệ thống Thông tin
- **Họ và tên:** Nguyễn Lê Anh Trúc
- **Tên bài thực hành:** Lab 4 - Network Surface Mapping with Nmap

---

## 1. Thông tin Môi trường Thực hành
- **Nền tảng ảo hóa:** VMware Workstation
- **Mạng Host-Only:** Dải mạng 192.168.157.0/24
  - **Máy quét (Attacker):** Kali Linux (`192.168.157.133`)
  - **Máy mục tiêu (Target):** Ubuntu Server 26.04 (`192.168.157.132`)
  - **Gateway/DHCP:** `192.168.157.254`

---

## 2. Các tình huống và Kết quả thực hiện

| STT | Nhiệm vụ / Tình huống | Lệnh thực hiện | Kết quả | Minh chứng |
|:---:|:---|:---|:---:|:---|
| 1 | Xác định IP và kết nối mạng | `ip -br addr`, `ip a`, `ping -c 4` | PASS | `screenshots/Anh1_IP_Kali.png`<br>`screenshots/Anh2_IP_Target.png` |
| 2 | Dò tìm máy đang hoạt động (Host Discovery) | `sudo nmap -sn 192.168.157.0/24` | PASS | `screenshots/Anh3_HostDiscovery_sn.png` |
| 3 | Quét cổng TCP SYN (SYN Scan) | `sudo nmap -sS 192.168.157.132` | PASS | `screenshots/Anh4_SYN_Scan.png` |
| 4 | Nhận diện phiên bản dịch vụ | `sudo nmap -sV 192.168.157.132` | PASS | `screenshots/Anh5_Version_sV.png` |
| 5 | Nhận diện hệ điều hành (OS Detection) | `sudo nmap -O 192.168.157.132` | PASS | `screenshots/Anh6_OS_Detection.png` |
| 6 | Kiểm tra an toàn dịch vụ bằng NSE Script | `sudo nmap --script banner -p 22 192.168.157.132` | PASS | `screenshots/Anh7_NSE_Scan.png` |
| 7 | Xuất kết quả và lập hồ sơ chứng cứ | `nmap -oA`, `xsltproc`, `sha256sum` | PASS | `screenshots/Anh8_Output_Files.png`<br>`evidence_sha256.csv` |

---

## 3. Lỗi gặp phải và Cách khắc phục
1. **Lỗi gõ sai dải IP khi Host Discovery:**
   - *Mô tả:* Nhập nhầm thành `192.1668.157.0/24` khiến Nmap báo lỗi *Failed to resolve*.
   - *Khắc phục:* Kiểm tra lại cú pháp và gõ đúng dải mạng `192.168.157.0/24`.
2. **Lỗi cú pháp lệnh nhận diện hệ điều hành:**
   - *Mô tả:* Gõ nhầm tham số `-0` (số 0) thay vì `-O` (chữ O in hoa), Nmap báo *unrecognized option '-0'*.
   - *Khắc phục:* Sửa lại cờ lệnh chính xác là `sudo nmap -O 192.168.157.132`.
3. **Mạng Host-Only không truy cập được Internet trên Kali:**
   - *Mô tả:* Không thể gửi file trực tiếp qua web từ Kali vì card mạng đang ở chế độ Host-Only cô lập.
   - *Khắc phục:* Chuyển tạm card mạng sang NAT hoặc truyền file nội bộ qua lệnh copy.