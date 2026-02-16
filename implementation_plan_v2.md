# Kế hoạch chi tiết triển khai theo nhánh (Branch-by-Branch Plan)

Dưới đây là lộ trình cụ thể cho từng nhánh tính năng. Chúng ta sẽ làm lần lượt, xong nhánh này mới chuyển sang nhánh kia để đảm bảo tính ổn định.

---

## 1. Nhánh: `feat/product-variants`
**Mục tiêu:** Chuyển đổi từ sản phẩm đơn lẻ sang sản phẩm có nhiều định dạng (5ml, 10ml, 50ml, 100ml).

### Bước 1: Database & Core logic (Backend)
- [ ] **Prisma:**
    - Thêm model `ProductVariant` { id, productId, name, price, stock, sku }.
    - Cập nhật `CartItem`: đổi `productId` thành `variantId` (quan trọng!).
    - Cập nhật `OrderItem`: đổi `productId` thành `variantId`.
- [ ] **DTOs:**
    - Hoàn thiện `create-product-variant.dto.ts`.
    - Cập nhật `create-product.dto.ts` để nhận list `variants`.
- [ ] **Services:**
    - `ProductsService`: Logic tạo Product kèm mảng Variants (dùng transaction).
    - `CartService`: Chỉnh sửa logic `addItem` để nhận diện theo Biến thể.
    - `OrdersService`: Lấy giá từ Biến thể khi tính tổng tiền.

### Bước 2: Giao diện (Frontend)
- [ ] **Admin Dashboard:**
    - Nâng cấp form thêm sản phẩm: Thay vì 1 giá/1 kho, cho phép nhấn "+" để thêm các dòng Biến thể.
- [ ] **Product Page:**
    - Thêm bộ chọn Size (Size Selector).
    - Logic: Khi click vào size 10ml -> Giá hiển thị tự động nhảy theo giá của 10ml.

---

## 2. Nhánh: `feat/discount-system`
**Mục tiêu:** Vận hành hệ thống mã giảm giá (Coupon).

### Bước 1: API & Logic xử lý (Backend)
- [ ] **PromotionsService:**
    - Viết hàm `validate(code, currentOrderValue)`: kiểm tra ngày, số lượng, điều kiện giá tối thiểu.
- [ ] **Orders integration:**
    - Cập nhật `Order.create`: Nếu có mã, tính toán `discountAmount` và update `finalAmount`.
- [ ] **Admin Controller:**
    - Viết các API CRUD cho `PromotionCode`.

### Bước 2: Trải nghiệm người dùng (Frontend)
- [ ] **Checkout Page:**
    - Thêm khu vực "Apply Coupon". Hiển thị chi tiết số tiền được giảm ngay sau khi áp dụng thành công.
- [ ] **Admin Promotions:**
    - Xây dựng màn hình quản lý mã giảm giá (danh sách mã, thống kê đã dùng bao nhiêu lần).

---

## 3. Nhánh: `feat/loyalty-points`
**Mục tiêu:** Kích thích mua hàng qua tích điểm và tiêu điểm.

### Bước 1: Quy trình tích/tiêu (Backend)
- [ ] **Cơ chế Tích điểm (Earning):**
    - Hook vào sự kiện Order chuyển sang trạng thái `COMPLETED`.
    - Tính điểm: `finalAmount * 0.01` (1%). Cộng vào `User.loyaltyPoints`.
- [ ] **Cơ chế Tiêu điểm (Redeeming):**
    - Cập nhật API Checkout: cho phép user chọn `usePoints`.
    - Trừ điểm tương ứng với số tiền được giảm.

### Bước 2: Hiển thị & Tương tác (Frontend)
- [ ] **User Profile:**
    - Thiết kế Widget "Aura Points" hiển thị số điểm hiện có và lịch sử tích điểm.
- [ ] **Checkout Integration:**
    - Thêm Checkbox: "Sử dụng [X] điểm Aura để giảm [Y] VNĐ cho đơn hàng này?".

---

## 🛠 Cách thực hiện (Dành cho Dev):
1.  **Tạo nhánh:** `git checkout -b feat/product-variants`
2.  **Làm theo từng checklist** ở trên.
3.  **Kiểm tra (Test):** Đảm bảo luồng "Add to cart -> Checkout" vẫn chạy đúng với cấu trúc dữ liệu mới.
4.  **Merge:** Gộp vào `main` và tiếp tục nhánh tiếp theo.
