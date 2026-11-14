# LAB 10: MÃ HÓA ĐỐI XỨNG CỔ ĐIỂN (CLASSICAL SYMMETRIC CRYPTOGRAPHY)

## Thông tin sinh viên
- **Họ và tên:** Nguyễn Lê Anh Trúc
- **MSSV:** 1150080078
- **Lớp:** 11ĐHCNPM1
- **Học phần:** An toàn và Bảo mật Thông tin

---

## Cấu trúc thư mục nộp bài (`LAB10/`)
```text
LAB10/
├── LAB1_MaHoaCoDien/                                    # Mã nguồn Maven Java Swing & SQL Server
│   ├── pom.xml                                          # Cấu hình Maven & dependency mssql-jdbc
│   └── src/main/java/week_01/
│       ├── FileTextIO.java                              # Tiện ích đọc/ghi tệp văn bản UTF-8
│       ├── CaesarCipher.java & frm_Caesar.java          # Thuật toán & giao diện Caesar
│       ├── VigenereCipher.java & frm_Vigenere.java      # Thuật toán & giao diện Vigenère
│       ├── RailFenceCipher.java                         # Thuật toán Rail Fence (Hàng rào)
│       ├── PlayfairCipher.java                          # Thuật toán Playfair (Ma trận 5x5)
│       ├── TranspositionCipher.java                     # Thuật toán Hoán vị cột
│       ├── AutokeyCipher.java                           # Thuật toán Autokey
│       ├── CipherTongHop.java                           # Bộ điều phối chung 6 thuật toán
│       ├── DbConfig.java & HistoryDao.java              # Kết nối & truy vấn lịch sử SQL Server
│       └── AttackDemos.java                             # Demo thám mã (Brute Force, Tần suất, Known Plaintext)
├── Lab10_11DHCNPM1_1150080078_NguyenLeAnhTruc.docx      # Báo cáo thực hành chi tiết
└── README.md                                            # Tài liệu mô tả tổng quan
```

---

## Công nghệ sử dụng
- **Ngôn ngữ & Giao diện:** Java (JDK 17+), Java Swing (NetBeans GUI Builder)
- **Quản lý thư viện:** Apache Maven (`mssql-jdbc` v12.8.1.jre11)
- **Cơ sở dữ liệu:** Microsoft SQL Server Express & SSMS (Port `14333`, bảng `dbo.history`)

---

## Các chức năng chính đã cài đặt
1. **6 Thuật toán mã hóa cổ điển:**
   - **Caesar:** Dịch chuyển ký tự theo khóa $k \pmod{26}$.
   - **Vigenère:** Mã hóa đa bảng thay thế theo chu kỳ từ khóa `A–Z`.
   - **Rail Fence:** Mã hóa đổi chỗ theo đường zíc zắc trên $k$ hàng.
   - **Playfair:** Mã hóa theo cặp ký tự trên ma trận khóa $5 \times 5$ (gộp `I/J`).
   - **Transposition:** Hoán vị cột theo thứ tự khóa chỉ định.
   - **Autokey:** Dòng khóa nối tiếp bản rõ nhằm triệt tiêu tính lặp chu kỳ.
2. **Tích hợp SQL Server:** Lưu nhật ký thao tác `ENCRYPT`/`DECRYPT` vào bảng `dbo.history` qua `PreparedStatement` chống SQL Injection.
3. **Thám mã cổ điển (`AttackDemos`):** Vét cạn 26 khóa Caesar, thống kê tần suất ký tự và khôi phục khóa Vigenère từ cặp bản rõ – bản mã đã biết.