# BÁO CÁO THỰC HÀNH LAB 3: NHẬN DIỆN VÀ ỨNG PHÓ CÁC MỐI ĐE DỌA AN TOÀN THÔNG TIN

- **Môn học:** An toàn và Bảo mật Hệ thống Thông tin
- **Thời gian thực hiện:** 22/09/2026
- **Môi trường thực nghiệm:** Máy ảo Windows 10 x64 (VMware Workstation), Mạng Host-only cô lập

---

## 1. Mục tiêu và Phạm vi bài Lab
1. Thiết lập môi trường kiểm thử và thu thập thông tin cấu hình ban đầu (Baseline) của hệ thống, Windows Defender và Windows Firewall.
2. Mô phỏng và đánh giá khả năng phản hồi của Antivirus đối với mẫu chuỗi thử nghiệm độc hại chuẩn EICAR.
3. Kích hoạt cơ chế kiểm toán (Audit Policy), ghi nhận và phân tích nhật ký xác thực không hợp lệ (Event ID 4625).
4. Phân tích kỹ thuật duy trì quyền truy cập (Persistence) thông qua khóa Registry Run.
5. Kiểm tra và chứng minh tính toàn vẹn của chuỗi dữ liệu bằng chứng kỹ thuật số (Digital Evidence) bằng giải thuật hàm băm SHA-256.

---

## 2. Danh mục Bằng chứng và Ảnh minh chứng (Evidence & Screenshots)

| Tên File Minh Chứng | Tình Huống | Nội Dung Mô Tả |
| :--- | :---: | :--- |
| `H3_Baseline_Defender_Firewall.png` | TH1 | Ảnh chụp baseline cấu hình hệ điều hành, trạng thái Real-time Protection và cấu hình Firewall Profiles. |
| `H4_ProtectionHistory_EICAR.png` | TH2 | Ảnh chụp giao diện Protection History ghi nhận Defender phát hiện và cách ly thành công tệp EICAR. |
| `H5_Event4625.png` | TH3 | Chi tiết sự kiện Event ID 4625 (Audit Failure) của tài khoản `lab3user` trong Event Viewer. |
| `H7_Autoruns_Persistence.png` | TH4 | Vị trí khóa khởi động bất thường `Lab3Demo` tại đường dẫn `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`. |
| `H13_Evidence_SHA256.png` | TH7 | Danh sách mã băm SHA-256 tính toán toàn bộ các tệp bằng chứng trong thư mục `C:\LAB3\Evidence`. |

---

## 3. Cấu trúc Thư mục Nộp bài

```text
C:\LAB3\
├── Evidence\
│   ├── start_time.txt
│   ├── baseline_os.txt
│   ├── baseline_defender.txt
│   ├── baseline_firewall.txt
│   ├── eicar_write_error.txt / defender_eicar.txt
│   ├── auth_events_before_rotation.txt
│   ├── persistence_run.txt
│   └── evidence_hashes.sha256.txt
├── Screenshots\
│   ├── H3_Baseline_Defender_Firewall.png
│   ├── H4_ProtectionHistory_EICAR.png
│   ├── H5_Event4625.png
│   ├── H7_Autoruns_Persistence.png
│   └── H13_Evidence_SHA256.png
└── README.md