# Danh sách các Page cần thiết cho PerfumeGPT

## 📋 Tổng quan
Dựa trên SEP490.txt và backend hiện tại, đây là danh sách đầy đủ các page cần thiết cho dự án.

---

## ✅ CÁC PAGE ĐÃ CÓ

### 🔐 Authentication (Auth)
- ✅ `/auth` - Trang đăng nhập/đăng ký
- ✅ `/login` - Trang đăng nhập
- ✅ `/register` - Trang đăng ký
- ✅ `/forgot-password` - Quên mật khẩu (chưa implement backend)
- ✅ `/reset-password` - Đặt lại mật khẩu (chưa implement backend)

### 👤 Customer Pages
- ✅ `/profile` - Quản lý profile
- ✅ `/cart` - Giỏ hàng
- ✅ `/checkout` - Thanh toán
- ✅ `/checkout/success` - Xác nhận đơn hàng
- ✅ `/consultation` - Tư vấn AI (chatbot)
- ✅ `/notifications` - Thông báo
- ✅ `/rewards` - Điểm thưởng/loyalty
- ✅ `/subscription` - Đăng ký (có thể không cần)

### 🛍️ Public Pages
- ✅ `/` - Trang chủ
- ✅ `/collection` - Danh sách sản phẩm
- ✅ `/collection/[id]` - Chi tiết sản phẩm
- ✅ `/boutiques` - Cửa hàng
- ✅ `/story` - Câu chuyện
- ✅ `/ingredients` - Nguyên liệu
- ✅ `/gifting` - Quà tặng
- ✅ `/journal` - Tạp chí
- ✅ `/support` - Hỗ trợ
- ✅ `/privacy` - Chính sách bảo mật
- ✅ `/terms` - Điều khoản

### 👨‍💼 Dashboard (Admin/Staff)
- ✅ `/dashboard` - Dashboard chính
- ✅ `/dashboard/orders` - Quản lý đơn hàng
- ✅ `/dashboard/orders/[id]` - Chi tiết đơn hàng
- ✅ `/dashboard/inventory` - Quản lý kho
- ✅ `/dashboard/users` - Quản lý người dùng
- ✅ `/dashboard/clients` - Quản lý khách hàng
- ✅ `/dashboard/pos` - Hệ thống POS
- ✅ `/dashboard/refunds` - Hoàn tiền
- ✅ `/dashboard/content` - Quản lý nội dung
- ✅ `/dashboard/settings` - Cài đặt
- ✅ `/dashboard/ai-analytics` - Phân tích AI
- ✅ `/dashboard/ai-ops` - Vận hành AI

---

## ❌ CÁC PAGE CÒN THIẾU

### 👤 Customer Pages (Thiếu)
1. ❌ `/orders` hoặc `/orders/history` - **Lịch sử đơn hàng** (UC-C06)
   - Xem danh sách đơn hàng đã mua
   - Backend: `GET /api/v1/orders` ✅

2. ❌ `/orders/[id]` - **Chi tiết đơn hàng** (UC-C27)
   - Xem thông tin chi tiết đơn hàng
   - Backend: `GET /api/v1/orders/:id` ✅

3. ❌ `/orders/[id]/tracking` - **Theo dõi đơn hàng** (UC-C28)
   - Xem trạng thái vận chuyển
   - Backend: Cần implement `GET /api/v1/orders/:id/tracking`

4. ❌ `/products/[id]/reviews` - **Xem đánh giá sản phẩm** (UC-C12)
   - Xem reviews và ratings
   - Backend: Cần implement `GET /api/v1/products/:id/reviews`

5. ❌ `/favorites` hoặc `/wishlist` - **Sản phẩm yêu thích** (UC-C13)
   - Thêm/xóa sản phẩm yêu thích
   - Backend: Cần implement endpoints cho favorites

6. ❌ `/quiz` - **AI Perfume Quiz** (UC-C16)
   - Quiz 5 câu hỏi để nhận gợi ý
   - Backend: Cần implement `POST /api/v1/ai/quiz/*`

7. ❌ `/recommendations` - **Gợi ý cá nhân hóa** (UC-C15, UC-C18)
   - Xem gợi ý từ AI
   - Backend: Cần implement `GET /api/v1/ai/recommendations`

8. ❌ `/recommendations/[id]/explanation` - **Giải thích gợi ý** (UC-C17)
   - Xem lý do tại sao sản phẩm được gợi ý
   - Backend: Cần implement `GET /api/v1/ai/recommendations/:id/explanation`

9. ❌ `/checkout/payment` - **Chọn phương thức thanh toán** (UC-C24)
   - Chọn VNPay/Momo/COD
   - Backend: Cần implement payment endpoints

10. ❌ `/checkout/payment/[method]` - **Thanh toán online** (UC-C25)
    - Xử lý thanh toán VNPay/Momo
    - Backend: Cần implement `POST /api/v1/payments/*`

### 🛍️ Public Pages (Thiếu)
11. ❌ `/promotions` - **Xem khuyến mãi công khai** (UC-G04)
    - Xem các chương trình khuyến mãi
    - Backend: Cần implement `GET /api/v1/promotions/public`

### 👨‍💼 Dashboard Pages (Thiếu)
12. ❌ `/dashboard/products` - **Quản lý sản phẩm** (UC-A04, UC-A05, UC-A06)
    - Tạo/sửa/xóa sản phẩm
    - Backend: `GET/POST/PATCH/DELETE /api/v1/admin/products` ✅

13. ❌ `/dashboard/products/create` - **Tạo sản phẩm mới** (UC-A04)
    - Form tạo sản phẩm
    - Backend: `POST /api/v1/admin/products` ✅

14. ❌ `/dashboard/products/[id]/edit` - **Sửa sản phẩm** (UC-A05)
    - Form sửa sản phẩm
    - Backend: `PATCH /api/v1/admin/products/:id` ✅

15. ❌ `/dashboard/brands` - **Quản lý thương hiệu** (UC-A07)
    - Quản lý brands
    - Backend: `GET/POST/PATCH/DELETE /api/v1/admin/brands` ✅

16. ❌ `/dashboard/categories` - **Quản lý danh mục** (UC-A07)
    - Quản lý categories
    - Backend: `GET/POST/PATCH/DELETE /api/v1/admin/categories` ✅

17. ❌ `/dashboard/scent-families` - **Quản lý scent families** (UC-A07)
    - Quản lý scent families và notes
    - Backend: Cần implement

18. ❌ `/dashboard/promotions` - **Quản lý khuyến mãi** (UC-A13)
    - Tạo và quản lý campaigns
    - Backend: Cần implement

19. ❌ `/dashboard/promotions/create` - **Tạo khuyến mãi** (UC-A13)
    - Form tạo promotion campaign
    - Backend: Cần implement

20. ❌ `/dashboard/loyalty` - **Cấu hình loyalty program** (UC-A12)
    - Cấu hình chương trình tích điểm
    - Backend: Cần implement

21. ❌ `/dashboard/analytics` - **Analytics dashboard** (UC-A15)
    - Revenue, top products, customer behavior
    - Backend: Cần implement `GET /api/v1/admin/analytics/*`

22. ❌ `/dashboard/ai-settings` - **Cấu hình AI** (UC-A14)
    - Cấu hình AI settings
    - Backend: Cần implement

23. ❌ `/dashboard/stores` - **Quản lý cửa hàng** (nếu có nhiều store)
    - Quản lý các cửa hàng
    - Backend: Cần implement

### 👨‍💼 Staff Pages (Thiếu - có thể dùng chung với dashboard)
24. ❌ `/dashboard/pos/scan` - **Quét barcode** (UC-S03)
    - Quét barcode sản phẩm
    - Backend: Cần implement `POST /api/v1/pos/scan-barcode`

25. ❌ `/dashboard/pos/daily-summary` - **Tóm tắt bán hàng hàng ngày** (UC-S09)
    - Xem daily sales summary
    - Backend: Cần implement `GET /api/v1/pos/daily-summary`

---

## 📊 TÓM TẮT

### Theo Actor:

**Guest (4/4) ✅**
- ✅ View products
- ✅ Search/Filter
- ✅ View product details
- ✅ View promotions (thiếu page riêng)

**Customer (15/28) ⚠️**
- ✅ Register/Login
- ✅ Profile
- ✅ Cart/Checkout
- ✅ Consultation
- ❌ Order history (thiếu)
- ❌ Order details (thiếu)
- ❌ Order tracking (thiếu)
- ❌ Product reviews (thiếu)
- ❌ Favorites/Wishlist (thiếu)
- ❌ AI Quiz (thiếu)
- ❌ Recommendations (thiếu)
- ❌ Payment selection (thiếu)

**Staff (2/9) ⚠️**
- ✅ POS (có page nhưng chưa đầy đủ)
- ✅ Daily summary (có trong dashboard)
- ❌ Scan barcode (thiếu)
- ❌ Quick consultation (có thể dùng chung)

**Admin (8/16) ⚠️**
- ✅ Users management
- ✅ Orders management
- ✅ Inventory
- ✅ Analytics (có page nhưng chưa đầy đủ)
- ❌ Products management (thiếu)
- ❌ Brands/Categories (thiếu)
- ❌ Promotions (thiếu)
- ❌ Loyalty config (thiếu)
- ❌ AI settings (thiếu)

---

## 🔧 BACKEND APIs CẦN IMPLEMENT

### Priority High:
1. `GET /api/v1/orders` - List orders (✅ có)
2. `GET /api/v1/orders/:id` - Order details (✅ có)
3. `GET /api/v1/products/:id/reviews` - Product reviews
4. `POST /api/v1/ai/quiz/start` - Start quiz
5. `POST /api/v1/ai/quiz/answer` - Answer quiz
6. `GET /api/v1/ai/recommendations` - Get recommendations
7. `POST /api/v1/payments/create` - Create payment
8. `GET /api/v1/promotions/public` - Public promotions

### Priority Medium:
9. `GET /api/v1/orders/:id/tracking` - Order tracking
10. `GET/POST/DELETE /api/v1/favorites` - Favorites management
11. `GET /api/v1/admin/products` - Admin products list
12. `POST /api/v1/admin/products` - Create product
13. `PATCH /api/v1/admin/products/:id` - Update product
14. `DELETE /api/v1/admin/products/:id` - Delete product
15. `GET /api/v1/admin/analytics/*` - Analytics endpoints

### Priority Low:
16. `GET /api/v1/admin/promotions` - Promotions management
17. `GET /api/v1/admin/loyalty` - Loyalty config
18. `GET /api/v1/admin/ai-settings` - AI settings

---

## 📝 GHI CHÚ

1. **Email Verification**: Đã loại bỏ - user đăng ký xong sẽ tự động đăng nhập
2. **OAuth**: Chưa implement (Google/Facebook login)
3. **Payment**: Chưa implement (VNPay/Momo integration)
4. **Shipping**: Chưa implement (GHN/GHTK integration)
5. **Reviews**: Chưa có page riêng để xem reviews
6. **Quiz**: Chưa có page quiz
7. **Recommendations**: Chưa có page hiển thị recommendations
