# 🚀 UTE EXPRESS — HỆ THỐNG QUẢN LÝ VẬN CHUYỂN & GIAO NHẬN LOGISTICS

> **Phiên bản tích hợp**: Spring Boot 4.x + Spring Security + JWT + PostgreSQL + Thymeleaf  
> **Trạng thái**: Đã hợp nhất đầy đủ tất cả các phân hệ: **Xác thực (Auth)**, **Bưu cục (Post Office)**, **Tài chính & Thanh toán**, **Điều phối (Dispatcher)**, **Tài xế (Driver)**, và **Quản trị hệ thống (Admin)**.

---

## 🔑 1. DANH SÁCH TÀI KHOẢN & MẬT KHẨU ĐĂNG NHẬP THEO TỪNG ROLE

> 💡 **Mật khẩu dùng chung cho tất cả các tài khoản thử nghiệm**: `123456`  
> *(Toàn bộ mật khẩu đã được mã hóa bằng chuẩn BCrypt trong cơ sở dữ liệu PostgreSQL).*

| STT | Vai trò (Role) | Mã Vai trò | Tên đăng nhập | Mật khẩu | Họ và tên | Chức vụ / Đơn vị | Trang Dashboard chuyển hướng |
| :---: | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| **1** | **Quản trị viên** | `ADMIN` | `admin` | `123456` | Quản trị viên hệ thống | Ban Quản trị UTE Express | `/admin/dashboard` |
| **2** | **Nhân viên Bưu cục** | `NVBC` | `nvbc01` | `123456` | Phạm Hoàng Nam | Bưu cục Thủ Đức (`KHO01`) | `/post-office/dashboard` |
| **3** | **Nhân viên Bưu cục** | `NVBC` | `nvbc02` | `123456` | Võ Thị Lan | Bưu cục Đà Nẵng (`KHO03`) | `/post-office/dashboard` |
| **4** | **Nhân viên Điều phối** | `NVDP` | `nvdp01` | `123456` | Đặng Quốc Huy | Trung tâm Điều phối (`KHO01`) | `/dispatcher/dashboard` |
| **5** | **Tài xế Giao nhận** | `TAI_XE` | `tx01` | `123456` | Huỳnh Văn Tài | Bằng lái hạng C - Xe tải | `/driver/dashboard` |
| **6** | **Tài xế Giao nhận** | `TAI_XE` | `tx02` | `123456` | Ngô Minh Đức | Bằng lái hạng E - Xe tải lớn | `/driver/dashboard` |
| **7** | **Khách hàng** | `KHACH_HANG` | `0901000001` | `123456` | Nguyễn Văn An | Khách hàng cá nhân (TP.HCM) | `/customer/dashboard` |
| **8** | **Khách hàng** | `KHACH_HANG` | `0901000002` | `123456` | Trần Thị Bích | Khách hàng cá nhân (Hà Nội) | `/customer/dashboard` |

---

## 🛡️ 2. KIẾN TRÚC BẢO MẬT & XÁC THỰC (SECURITY)

Hệ thống được bảo vệ bằng mô hình **Stateless JWT Authentication** kết hợp **Role-Based Access Control (RBAC)** của Spring Security:

1. **Cơ chế Đăng nhập (`POST /api/auth/login`)**:
   - Client gửi `tenDangNhap` và `matKhau`.
   - `CustomUserDetailsService` tải thông tin người dùng từ bảng `nguoi_dung`, xác thực mật khẩu qua `BCryptPasswordEncoder`.
   - Nếu tài khoản có trạng thái `"Bị khóa"`, hệ thống từ chối đăng nhập (`LockedException`).
   - Nếu xác thực thành công, hệ thống phát sinh chuỗi **JWT Token** (thuật toán HS256/HS512) chứa Subject, Roles và thời hạn hiệu lực.
   - Frontend lưu trữ token vào `localStorage` (`accessToken` & `token`) và tự động chuyển hướng người dùng đến đúng trang Dashboard tương ứng với vai trò của họ.

2. **Bảo vệ REST API theo Role**:
   - `JwtAuthFilter` tự động trích xuất token từ Header `Authorization: Bearer <token>`, giải mã và gán quyền (`SecurityContextHolder`) cho từng request.
   - Các API được phân quyền nghiêm ngặt:
     - `/api/admin/**`, `/api/v1/admin/**`: Chỉ dành cho `ADMIN`.
     - `/api/v1/post-office/**`, `/api/v1/payments/**`: Dành cho `NVBC` và `ADMIN`.
     - `/api/dieu-phoi/**`: Dành cho `NVDP` và `ADMIN`.
     - `/api/tai-xe/**`: Dành cho `TAI_XE` và `ADMIN`.
     - `/api/khach-hang/**`, `/api/don-hang/**`: Dành cho `KHACH_HANG` và `ADMIN`.
     - `/api/auth/**`, `/api/tra-cuu/**`: Công khai (`permitAll`).

---

## 🗄️ 3. HƯỚNG DẪN KHỞI TẠO & CHẠY LẠI CƠ SỞ DỮ LIỆU POSTGRESQL

Cơ sở dữ liệu: `ute_express` trên cổng `5432`.  
Thứ tự thực thi các script SQL trong thư mục `database/`:

```
database/
├── 1. schema.sql          # Khởi tạo bảng, khóa chính, khóa ngoại, sequence, ràng buộc
├── 2. logic.sql           # Cài đặt Stored Procedures, Functions tính cước, Trigger kiểm tra
├── 3. seed_and_test.sql   # Nạp dữ liệu mẫu ban đầu (Vai trò, Kho, Tuyến, Người dùng,...)
└── 4. seed_extra.sql      # Dữ liệu mở rộng cho các chuyến xe, kiện hàng và kịch bản test
```

### Lệnh chạy nhanh qua terminal (PostgreSQL 16/17/18):

```powershell
$env:PGPASSWORD='123456'
$PSQL='C:\Program Files\PostgreSQL\18\bin\psql.exe'

& $PSQL -U postgres -d ute_express -f database/schema.sql
& $PSQL -U postgres -d ute_express -f database/logic.sql
& $PSQL -U postgres -d ute_express -f database/seed_and_test.sql
& $PSQL -U postgres -d ute_express -f database/seed_extra.sql
```

---

## 💻 4. HƯỚNG DẪN KHỞI CHẠY ỨNG DỤNG BACKEND

### Yêu cầu môi trường:
- **Java**: OpenJDK 17 trở lên (đã kiểm thử tương thích Java 17, 21, 25).
- **Maven**: Tích hợp sẵn qua Maven Wrapper (`./mvnw`).
- **PostgreSQL**: Đang chạy tại `localhost:5432` với Database `ute_express`.

### Khởi động ứng dụng:
```powershell
# Chạy ứng dụng qua Maven Wrapper
./mvnw spring-boot:run
```
Ứng dụng sẽ khởi chạy tại cổng: `http://localhost:8080`.

---

## 🌐 5. DANH MỤC TRANG WEB & TÀI LIỆU API

### 5.1. Trang Giao diện Web (Thymeleaf Views):
- **Trang chủ công khai**: [http://localhost:8080/](http://localhost:8080/)
- **Đăng nhập**: [http://localhost:8080/login](http://localhost:8080/login)
- **Đăng ký tài khoản**: [http://localhost:8080/register](http://localhost:8080/register)
- **Tra cứu vận đơn**: [http://localhost:8080/tracking](http://localhost:8080/tracking)
- **Khách hàng**:
  - Dashboard: `/customer/dashboard`
  - Tạo đơn hàng: `/customer/create-order`
  - Chi tiết đơn: `/customer/order-detail`
  - Thanh toán: `/customer/payment`
- **Nhân viên Bưu cục**:
  - Dashboard bưu cục: `/post-office/dashboard`
  - Quản lý kiện hàng tại kho: `/post-office/packages`
  - Cập nhật trạng thái: `/post-office/update-status`
- **Nhân viên Điều phối**:
  - Dashboard điều phối: `/dispatcher/12-dashboard.html` (hoặc `/dispatcher/dashboard`)
  - Quản lý tuyến vận chuyển: `/dispatcher/13-routes.html`
  - Quản lý chuyến giao & tải trọng: `/dispatcher/14-trips.html`
- **Tài xế**:
  - Dashboard tài xế: `/driver/15-dashboard.html` (hoặc `/driver/dashboard`)
  - Chi tiết chuyến giao: `/driver/16-trip-detail.html`
  - Quét kiện & Kết quả giao hàng: `/driver/17-delivery-update.html`
- **Quản trị viên (Admin)**:
  - Dashboard tổng quan: `/admin/dashboard`
  - Quản lý người dùng: `/admin/users`
  - Quản lý kho / bưu cục: `/admin/warehouses`
  - Quản lý phương tiện: `/admin/vehicles`
  - Giám sát đơn hàng: `/admin/orders`
  - Doanh thu & COD: `/admin/payments`
  - Báo cáo & Thống kê: `/admin/reports`
  - Cấu hình hệ thống: `/admin/settings`

### 5.2. Tài liệu API Swagger:
- **Swagger UI**: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **OpenAPI JSON**: [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)
