# Lab 8: Local DNS Attack trên mô hình pfSense

## 📌 Giới thiệu tổng quan
Bài thực hành phân tích cơ chế phân giải tên miền (DNS) và việc giả mạo phản hồi DNS (DNS cache poisoning) trong một môi trường ảo cô lập. Bài tập tách biệt các lớp phân giải (file `/etc/hosts`, truy vấn DNS trực tiếp, cache của resolver), dùng pfSense để cô lập mạng DNSLAB, và tập trung vào biện pháp phòng thủ sau khi hoàn thành.

- **Sinh viên:** Nguyễn Lê Anh Trúc – MSSV 1150080078 – Lớp 11ĐHCNPM1

---

## 🏗️ Mô hình mạng
| Máy | Vai trò | Ghi chú |
| :--- | :--- | :--- |
| pfSense | Cô lập mạng DNSLAB `10.9.0.1/24` | Ruleset giới hạn lưu lượng DNS |
| DNS-SERVER | BIND9, authoritative/recursive cho zone `lab9.test` | `named-checkconf`, `named-checkzone` |
| Victim | Máy trạm phân giải tên miền | Dùng DNS-SERVER làm resolver |
| Kali | Quan sát bằng Wireshark, máy giả mạo phản hồi | Promiscuous Mode = Allow VMs (chỉ trong bài) |
| APP-TEST (`172.16.6.20`) | Máy chủ DNS có trễ 1.5 s | Mô phỏng cuộc đua phản hồi |

---

## 🧪 Các bước thực hiện
1. **Chuẩn bị mạng:** tạo mạng DNSLAB, gán interface pfSense, kiểm tra ruleset cô lập.
2. **Baseline:** xác nhận `www.external.lab9.test` trả về `172.16.6.10`.
3. **Task 1 (cục bộ):** sửa `/etc/hosts` trên Victim để chứng minh trình duyệt bị ảnh hưởng, trong khi `dig @DNS-SERVER` vẫn trả kết quả gốc.
4. **Task 2 và Task 3:** quan sát truy vấn và phản hồi bằng Wireshark, kiểm tra cache của resolver.
5. **Khôi phục:** flush cache, kiểm tra lại kết quả, đưa Promiscuous Mode về Deny.

---

## 📝 Nội dung báo cáo
File `11DHCNPM1-Lab8_1150080078-NguyenLeAnhTruc.docx` gồm:
- **Phần L:** trả lời 10 câu hỏi phân tích (phân biệt `/etc/hosts` và truy vấn DNS, các trường phải khớp của DNS/UDP, vai trò TTL, lý do cần Promiscuous Mode và mạng DNSLAB riêng, các loại máy chủ DNS, DNSSEC và tên miền `.test`, vì sao không chỉ chặn UDP/53, bốn biện pháp hardening).
- **Phần M:** danh sách ảnh minh chứng cần chụp từ VM của sinh viên (baseline, attack result, restore result).

---

## 📂 Cấu trúc thư mục

```text
LAB8/
├── README.md                                          # Tài liệu tổng quan bài thực hành
├── 11DHCNPM1-Lab8_1150080078-NguyenLeAnhTruc.docx     # Báo cáo, câu trả lời và danh sách ảnh minh chứng
├── LAB8_Local_DNS_Attack_pfSense_2026.docx            # Đề bài
└── LAB8_Local_DNS_Attack_pfSense_2026_FINAL/          # Bộ tài nguyên của giảng viên
```
