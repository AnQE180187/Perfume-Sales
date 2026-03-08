STAFF DEVELOPMENT PLAN – IN-STORE OPERATIONS
Tổng quan vai trò Staff

Staff là người:

Bán hàng trực tiếp tại cửa hàng (POS)

Quản lý tồn kho thực tế

Hỗ trợ khách hàng bằng AI tư vấn

Không cấu hình hệ thống (không phải Admin)

LUỒNG 1 – STAFF ĐĂNG NHẬP & PHIÊN LÀM VIỆC
Mục tiêu

Đảm bảo chỉ Staff hợp lệ mới thao tác POS

Tính năng

Đăng nhập bằng tài khoản staff

Tự động gán role = STAFF

Logout / hết hạn phiên

Backend

JWT Auth

RoleGuard(STAFF)

Session metadata (storeId, staffId)

Frontend (POS Web / Mobile)

Login screen

Auto redirect → POS

Ràng buộc

Staff không truy cập Admin APIs

LUỒNG 2 – TRA CỨU & TƯ VẤN SẢN PHẨM CHO KHÁCH
2.1 Tra cứu nhanh sản phẩm (tại quầy)
Mục tiêu

Staff tìm sản phẩm nhanh khi khách hỏi

Tính năng

Search theo:

Tên

Barcode / SKU

Hiển thị:

Giá

Dung tích

Mùi hương chính

Tồn kho hiện tại

Backend

POS Product Search API

Join Product + Inventory

Frontend

Search bar

Product quick card

2.2 AI tư vấn hỗ trợ Staff (Assisted Sale)
Mục tiêu

Staff dùng AI để gợi ý nhanh cho khách

Tính năng

Staff nhập:

Giới tính khách

Dịp sử dụng

Ngân sách

AI trả về:

Top 3 sản phẩm

Lý do gợi ý

Add trực tiếp vào bill

Backend

AI Consultation API (staff mode)

Log staff-assisted consultation

Frontend

Mini AI panel trong POS

LUỒNG 3 – TẠO HOÁ ĐƠN BÁN HÀNG (POS CORE)
3.1 Tạo hoá đơn nháp (DRAFT)
Mục tiêu

Bắt đầu phiên bán hàng

Tính năng

Tạo POS Order:

staffId

storeId

status = DRAFT

Backend

POSOrder entity

Transaction-safe create

3.2 Thêm / sửa sản phẩm trong bill
Tính năng

Add product

Update quantity

Remove product

Auto tính:

Subtotal

Discount (placeholder)

Total

Backend

Validate stock realtime

Snapshot giá

Frontend

Bill panel

Quantity control

Ràng buộc

quantity ≤ stock

Không chỉnh giá thủ công

3.3 Kiểm tra tồn kho realtime
Mục tiêu

Tránh bán quá số lượng

Tính năng

Re-check tồn kho khi:

Thêm sản phẩm

Tăng số lượng

Warning UI

Backend

Inventory lock / atomic update

LUỒNG 4 – THANH TOÁN TẠI QUẦY
4.1 Chọn phương thức thanh toán
Tính năng

Tiền mặt

QR (VNPay / PayOS sandbox)

Backend

Payment intent

Payment record (PENDING)

4.2 Xác nhận thanh toán
Tiền mặt

Staff xác nhận thủ công

QR

Chờ webhook xác nhận

Backend

Update order:

PAID

Deduct inventory (final)

Ràng buộc

Idempotency

LUỒNG 5 – HOÀN TẤT HOÁ ĐƠN
Mục tiêu

Kết thúc phiên bán

Tính năng

Mark order COMPLETED

Ghi nhận:

Doanh thu

Điểm loyalty (future)

In / hiển thị hoá đơn (mock)

LUỒNG 6 – QUẢN LÝ TỒN KHO (STAFF LEVEL)
6.1 Nhập hàng
Tính năng

Nhập số lượng theo sản phẩm

Ghi chú nguồn nhập

Backend

Inventory update

InventoryLog(type=IMPORT)

6.2 Điều chỉnh tồn kho
Tính năng

Tăng / giảm tồn

Bắt buộc reason

Backend

InventoryLog(type=ADJUST)

Ràng buộc

Không cho âm tồn

6.3 Xem lịch sử tồn kho
Tính năng

Lọc theo:

Sản phẩm

Thời gian

Xem ai thao tác

LUỒNG 7 – TRA CỨU ĐƠN HÀNG & HẬU BÁN
Mục tiêu

Hỗ trợ khách tại quầy

Tính năng

Tìm đơn theo:

Mã đơn

SĐT khách

Xem trạng thái

Xem chi tiết sản phẩm

LUỒNG 8 – BÁO CÁO CƠ BẢN CHO STAFF
Tính năng

Doanh thu ca làm

Số đơn đã xử lý

Top sản phẩm bán trong ngày

Backend

Aggregate theo staffId + date

PHỤ THUỘC & THỨ TỰ PHÁT TRIỂN (RẤT QUAN TRỌNG)
Thứ tự build bắt buộc

Auth (Staff)

Product + Inventory read

POS draft order

Add/remove item

Payment cash

Inventory deduction

AI assisted sale

Reporting

CHECKLIST HOÀN THÀNH STAFF FLOW

 Staff login + role guard

 POS search usable < 1s

 Không bán quá tồn

 POS order end-to-end

 Cash payment hoàn chỉnh

 Inventory log đầy đủ

 Demo được luồng bán hàng thật