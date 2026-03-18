# Inventory & User Profile Redesign - Backend Integration Guide

Tài liệu này tóm tắt các thay đổi về giao diện người dùng (UI/UX) đã thực hiện và các yêu cầu kỹ thuật tương ứng đối với hệ thống Backend để hoàn thiện tính năng.

---
    
## 1. Quản lý Người dùng & Loyalty (User & Loyalty)

### Thay đổi UI:
- **Trang Đăng ký:** Thêm trường `phone` (Optional).
- **Trang Hồ sơ (Profile):** Cho phép xem và chỉnh sửa trường `phone`.
- **Hệ thống POS:** Hiển thị thông tin Loyalty dựa trên Số điện thoại.

### Yêu cầu Backend:
- **Database (Prisma):** Đảm bảo model `User` có trường `phone: String?`.
- **Auth Service:** Cập nhật logic `register` và `updateProfile` để xử lý lưu trữ/cập nhật số điện thoại.
- **Loyalty API:** Cập nhật endpoint tra cứu khách hàng theo số điện thoại (`/stores/loyalty/lookup?phone=...`) để trả về thông tin thành viên hoặc khách vãng lai.

---

## 2. Cải thiện Nhập liệu (Input UX)

### Thay đổi UI:
- Toàn bộ các ô nhập **Số lượng (Quantity)** và **Đơn giá (Price)** trong Dashboard (Admin & Staff) đã được:
    - Ẩn nút tăng giảm mặc định (spinners).
    - Cho phép xóa trắng (empty string) để nhập số mới từ bàn phím.
    - Không tự động ép về `0` khi người dùng đang thao tác xóa.

### Yêu cầu Backend:
- **Validation:** Đảm bảo các API nhận dữ liệu kiểu `Int` hoặc `Float` có logic xử lý linh hoạt, tránh lỗi `400 Bad Request` khi nhận dữ liệu rỗng hoặc không hợp lệ từ các phiên làm việc hàng loạt.

---

## 3. Hệ thống Quản lý Tồn kho Hàng loạt (Batch Inventory Control)

Đây là thay đổi lớn nhất, chuyển từ nhập lẻ từng sản phẩm sang cơ chế **Phiên làm việc (Session-based)**.

### Thay đổi UI:
- **Tab Overview Grid:** Hiển thị ma trận tồn kho toàn cục.
- **Tab Batch Import:** Cho phép chọn 1 quầy và thêm danh sách N sản phẩm, sau đó nhập số lượng đồng thời.
- **Tab Transfer Session:** Cho phép chọn Nguồn -> Đích và điều chuyển danh sách N sản phẩm.

### Yêu cầu Backend (QUAN TRỌNG):
Hiện tại Frontend đang phải thực hiện vòng lặp gọi API đơn lẻ (Sequential Requests). Để tối ưu hiệu năng và đảm bảo tính toàn vẹn dữ liệu (Atomic Transactions), Backend cần bổ sung các endpoint sau:

#### A. Batch Import API
- **Endpoint:** `POST /api/v1/stores/stock/batch-import`
- **Payload:**
  ```json
  {
    "storeId": "string",
    "reason": "string",
    "items": [
      { "variantId": "string", "quantity": number },
      { "variantId": "string", "quantity": number }
    ]
  }
  ```
- **Logic:** Xử lý tất cả item trong một Transaction duy nhất.

#### B. Batch Transfer API
- **Endpoint:** `POST /api/v1/stores/stock/batch-transfer`
- **Payload:**
  ```json
  {
    "fromStoreId": "string",
    "toStoreId": "string",
    "reason": "string",
    "items": [
      { "variantId": "string", "quantity": number }
    ]
  }
  ```
- **Logic:** Kiểm tra tồn kho tại nguồn cho tất cả item trước khi thực hiện điều chuyển hàng loạt.

---

## 4. Danh sách File Frontend đã thay đổi
- `frontend/app/globals.css`: Ẩn spinners cho toàn bộ input number.
- `frontend/app/[locale]/(auth)/register/page.tsx`: Thêm input Phone.
- `frontend/app/[locale]/dashboard/profile/page.tsx`: Cập nhật UI chỉnh sửa Phone.
- `frontend/app/[locale]/dashboard/staff/pos/page.tsx`: Thay đổi input số lượng linh hoạt.
- `frontend/app/[locale]/dashboard/admin/products/page.tsx`: Cải thiện UX nhập Price/Stock.
- `frontend/app/[locale]/dashboard/admin/stores/stock/page.tsx`: **Re-design hoàn toàn** giao diện quản lý kho 3 Tab.
