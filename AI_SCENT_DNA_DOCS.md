# Tài liệu Tính năng: AI Scent DNA (Hệ thống Tương thích Mùi hương)

## 1. Tổng quan
Tính năng **AI Scent DNA** giúp cá nhân hóa trải nghiệm người dùng bằng cách tính toán mức độ tương thích giữa sở thích cá nhân (Nốt hương yêu thích/muốn tránh) và đặc tính của từng sản phẩm nước hoa.

---

## 2. Luồng dữ liệu (Architecture Flow)
1.  **Thiết lập (Mobile):** Người dùng chọn nốt hương yêu thích (Preferred Notes) và nốt hương muốn tránh (Avoided Notes) tại màn hình AI Preferences.
2.  **Lưu trữ (Backend):** Dữ liệu DNA được lưu vào Database. Backend đã được cấu hình **Permissive Filtering** (Cho phép trả về cả sản phẩm dính nốt hương bị ghét nhưng điểm thấp, thay vì ẩn hoàn toàn).
3.  **Tính toán & Hiển thị (Mobile):** Ứng dụng Mobile nhận dữ liệu sản phẩm và DNA, thực hiện tính toán tỷ lệ % theo thời gian thực để hiển thị trên giao diện.

---

## 3. Thuật toán Tính điểm (Penalty System)
Thuật toán được chuẩn hóa trong `perfume_utils.dart` với các quy tắc sau:

*   **Chuẩn hóa dữ liệu:** Xử lý chuỗi nốt hương (xóa dấu ngoặc, trim khoảng trắng, chuyển chữ thường) để đảm bảo so sánh chính xác tuyệt đối.
*   **Điểm cơ sở (Base Score):** **70%** nếu có ít nhất 1 nốt hương yêu thích.
*   **Điểm thưởng (Bonus):** Cộng thêm **+10%** cho mỗi nốt hương yêu thích tiếp theo.
*   **Hệ số phạt (Penalty):** Trừ thẳng **-40%** cho mỗi nốt hương nằm trong danh sách **Muốn tránh**.
*   **Giới hạn (Clamping):**
    *   Tối đa: **99%**.
    *   Tối thiểu: **5%**.
    *   Trường hợp đặc biệt: Nếu sản phẩm **chỉ có nốt hương ghét** mà không có nốt thích => Trả về **10%** (Cảnh báo mức độ rủi ro cao).

---

## 4. Trải nghiệm Người dùng & Giao diện (UI/UX)

### A. Hiệu ứng Lưu DNA thành công
*   **Biểu tượng:** Thiên thần nước hoa (Perfume Angel).
*   **Animation:** 
    *   **Pulse:** Nhịp đập phóng to/thu nhỏ nhẹ nhàng (1.1x).
    *   **Glow:** Hào quang vàng tỏa sáng phía sau biểu tượng tạo cảm giác linh thiêng.

### B. Badge Tỷ lệ trên Card sản phẩm
*   **Màu sắc:** 
    *   **Vàng Kim (Gold):** Tương thích tốt (> 70%).
    *   **Hổ phách (Amber):** Cần lưu ý (50% - 70%).
    *   **Đỏ/Cam (Red):** Cảnh báo ( < 50%).

### C. Hộp thoại Giải thích (Long Press)
*   Hiển thị danh sách các nốt hương khớp với sở thích.
*   **Cảnh báo đỏ:** Nếu sản phẩm dính nốt hương muốn tránh, AI sẽ hiển thị dòng thông báo in nghiêng: *"(Tuy nhiên, có chứa nốt hương bạn muốn tránh: ...)"*.

### D. Trang Chi tiết sản phẩm
*   Đồng bộ badge DNA với thẻ bên ngoài.
*   Biểu tượng thay đổi từ "Lấp lánh" (Sparkles) sang "Cảnh báo" (Warning) nếu có nốt hương bị ghét.

---

## 5. Các tệp tin quan trọng
*   **Logic:** `mobile/lib/core/utils/perfume_utils.dart`
*   **UI Component:** `mobile/lib/core/widgets/product_card.dart`
*   **Backend logic:** `backend/src/products/products.service.ts`
*   **Detail Screen:** `mobile/lib/features/product/presentation/product_detail_screen.dart`

---

## 6. Ghi chú Kỹ thuật
*   Backend đã được cập nhật để không lọc cứng (comment out `NOT` block).
*   Mobile cập nhật tất cả call sites (`Search`, `Home`, `Explore`, `Wishlist`) để truyền `avoidedNotes`.
