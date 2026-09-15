# BÀI THỰC HÀNH LAB 1: TÌM HIỂU VÀ PHÂN TÍCH AN TOÀN MẠNG VỚI TELNET VÀ SSH

## 1. Thông tin sinh viên
* **Họ và tên:** Nguyễn Lê Anh Trúc
* **Mã số sinh viên:** 1150080078
* **Lớp / Môn học:** An toàn và Bảo mật Hệ thống Thông tin

---

## 2. Tên bài Lab
* **Bài Lab 1:** So sánh tính an toàn giữa giao thức Telnet và SSH bằng kỹ thuật Packet Sniffing (Wireshark).

---

## 3. Nội dung đã thực hiện
* Cấu hình và mở dịch vụ mạng trên máy chủ **Kali Linux** (IP: `192.168.174.128`):
  * Cài đặt gói `openbsd-inetd` / `telnetd-ssl` để kích hoạt giao thức Telnet (Port 23).
  * Kích hoạt dịch vụ `ssh` (OpenSSH Server, Port 22).
  * Khởi tạo tài khoản thực hành `uitlab` với mật khẩu xác thực đặt theo MSSV.
* Sử dụng **PuTTY** trên Client (Windows 10) thực hiện kết nối điều khiển từ xa đến Server lần lượt qua hai giao thức Telnet và SSH.
* Dùng phần mềm **Wireshark** bắt và phân tích gói tin mạng (Packet Sniffing) trên card mạng ảo tương ứng.
* Phân tích luồng truyền dữ liệu (Follow TCP Stream) trên cả hai cổng 23 và 22 để đối chiếu cơ chế bảo mật.

---

## 4. Kết quả thực hiện
* **Giao thức Telnet (Cổng 23):**
  * Toàn bộ phiên làm việc, tên đăng nhập (`uitlab`), mật khẩu (`1150080078`) và các câu lệnh thực thi (`whoami`, `ls`) đều truyền đi dưới dạng văn bản rõ (cleartext).
  * Bắt trọn thông tin xác thực qua Wireshark mà không cần giải mã.
* **Giao thức SSH (Cổng 22):**
  * Ghi nhận và xác thực cảnh báo `PuTTY Security Alert` (kiểm tra Server Host Key Fingerprint).
  * Toàn bộ gói tin từ bước xác thực tài khoản đến dữ liệu lệnh truyền đi đều được mã hóa đối xứng (Payload hiển thị dưới dạng ký tự ngẫu nhiên không thể đọc được).
* Đã tổng hợp đầy đủ hình ảnh minh chứng và trả lời các câu hỏi phân tích vào file báo cáo chi tiết đính kèm trong thư mục.

---

## 5. Lưu ý để giảng viên kiểm tra / chạy lại bài làm
1. **Môi trường ảo hóa:** VMware Workstation sử dụng card mạng chế độ **NAT** (Dải mạng: `192.168.174.0/24`).
2. **Thông tin Server (Kali Linux):**
   * IP Server: `192.168.174.128`
   * User kiểm tra: `uitlab`
   * Password: Mật khẩu đặt theo MSSV (`1150080078`)
3. **Các lệnh khởi động dịch vụ (nếu kiểm tra trên Kali):**
   * Khởi động Telnet: `sudo systemctl restart openbsd-inetd`
   * Khởi động SSH: `sudo systemctl start ssh`
   * Kiểm tra cổng đang lắng nghe: `ss -ltn | grep -E ':(22|23)'`
4. **Bộ lọc Wireshark dùng để kiểm tra:**
   * Bắt gói Telnet: `tcp.port == 23` (nhấp chuột phải vào gói tin -> `Follow` -> `TCP Stream`)
   * Bắt gói SSH: `tcp.port == 22` (nhấp chuột phải vào gói tin SSHv2 -> `Follow` -> `TCP Stream`)