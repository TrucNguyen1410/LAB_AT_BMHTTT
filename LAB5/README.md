# Lab 5: Cấu hình Tường lửa pfSense trong mô hình mạng Doanh nghiệp

## 📌 Giới thiệu tổng quan
Bài thực hành triển khai và cấu hình giải pháp tường lửa mã nguồn mở **pfSense (phiên bản 2.7.2-RELEASE)** trên nền tảng ảo hóa VMware Workstation. Mô hình phân tách hệ thống thành 3 vùng mạng riêng biệt nhằm kiểm soát luồng dữ liệu, bảo vệ tài nguyên nội bộ và thiết lập chính sách an ninh theo mô hình phòng thủ theo chiều sâu.

---

## 🏗️ Kiến trúc & Mô hình mạng

| Vùng mạng | Interface | Chế độ VMware | Dải IP mạng / Subnet | IP pfSense Gateway | Vai trò & Mục đích |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **WAN** | `em0` | Bridged | DHCP từ Router ngoài | Nhận qua DHCP | Kết nối ra môi trường Internet công cộng |
| **LAN** | `em1` | Host-Only (VMnet1) | `10.0.0.0/8` | `10.0.0.1` | Vùng mạng nội bộ (Domain Controller, Client) |
| **DMZ** | `em2` | LAN Segment (`dmz-net`) | `172.16.0.0/16` | `172.16.0.1` | Vùng đệm chứa các máy chủ công khai (Web/DNS) |

---

## ⚙️ Các bước triển khai chính

1. **Khởi tạo máy ảo pfSense:** Cấu hình phần cứng (2 vCPU, 2GB RAM, 20GB Disk ZFS) với đủ 3 Network Adapters theo đúng thiết kế mạng.
2. **Cấu hình IP LAN qua Console:** Gán địa chỉ `10.0.0.1/8` cho interface LAN, tắt DHCP server mặc định.
3. **Cấu hình WebGUI & Wizard:** Thiết lập múi giờ (`Asia/Ho_Chi_Minh`), đổi mật khẩu quản trị và gán interface DMZ (`172.16.0.1/16`).
4. **Chuyển đổi Outbound NAT:** Kích hoạt chế độ **Hybrid Outbound NAT** để hỗ trợ sinh luật NAT tự động cho cả 2 dải mạng LAN và DMZ.
5. **Chuẩn hóa Ruleset LAN:** Vô hiệu hóa (Disable) các rule `Default allow LAN to any` mặc định, thiết lập rule nền tảng `LAN to Internet` và thực hiện **Reset States**.

---

## 🧪 Các kịch bản kiểm thử Firewall (Scenarios)

* **Tình huống 1: Kiểm soát giao thức (Lọc gói tin)**
  * *Chính sách:* Chặn toàn bộ gói tin ICMP (Ping), chỉ cho phép phân giải tên miền (DNS port 53 UDP/TCP) và duyệt web (HTTP 80, HTTPS 443).
  * *Kết quả:* Máy client `ping 8.8.8.8` bị timeout, truy cập trang web qua trình duyệt thành công.

* **Tình huống 2: Phân quyền theo máy nguồn (Source IP Filtering)**
  * *Chính sách:* Chỉ duy nhất máy Domain Controller (`10.0.0.2`) được phép ra Internet, tất cả các IP khác trong dải LAN đều bị chặn.
  * *Kết quả:* Máy `10.0.0.2` ping thành công; đổi IP client sang `10.0.0.5` kết nối bị chặn ngay lập tức.

* **Tình huống 3: Cô lập vùng mạng DMZ (DMZ Isolation)**
  * *Chính sách:* Máy chủ DMZ được phép đi ra Internet nhưng bị chặn hoàn toàn chiều kết nối ngược vào vùng LAN nội bộ (`10.0.0.0/8`).
  * *Kết quả:* Có ảnh baseline chứng minh kết nối trước khi áp rule (ping thông sang DC) và ảnh sau khi áp rule (ping sang DC thất bại, ping Internet `8.8.8.8` vẫn thành công).

* **Tình huống 4: Chuyển tiếp cổng (NAT Port Forwarding)**
  * *Chính sách:* Public dịch vụ Web từ DMZ ra ngoài bằng cách map cổng WAN `8080` về cổng `80` của máy chủ Web trong DMZ (`172.16.0.2`).
  * *Kết quả:* Máy thật ở mạng ngoài truy cập qua `http://<WAN_IP>:8080` mở thành công trang Web IIS.

* **Tình huống 5: Giám sát nhật ký (Firewall Logging)**
  * Kiểm tra bảng log tường lửa tại `Status -> System Logs -> Firewall` để phân tích các gói tin bị Drop/Reject theo thời gian thực.

---

## 📂 Cấu trúc thư mục

```text
LAB5/
├── README.md               # Tài liệu tổng quan bài thực hành
├── BaoCao_Lab5_pfSense.docx # Báo cáo chi tiết và câu trả lời lý thuyết
├── screenshots/            # Toàn bộ hình ảnh minh chứng bắt buộc
│   ├── Anh1_CauHinh_3CardMang_pfSense.png
│   ├── Anh2_Console_Dat_IP_LAN.png
│   ├── Anh3_Dashboard_pfSense.png
│   ├── Anh4_CauHinh_DMZ.png
│   ├── Anh5_Outbound_NAT_Hybrid.png
│   ├── Anh6_LAN_Rules.png
│   └── ... (các ảnh kiểm thử tình huống)
└── .gitignore              # Loại trừ các file đĩa ISO/nén nặng