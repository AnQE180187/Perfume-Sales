# Sửa lỗi truy cập Admin Dashboard

## 🔍 Vấn đề đã phát hiện

1. **Backend trả về role là UPPERCASE**: `ADMIN`, `STAFF`, `CUSTOMER`
2. **Frontend đang check lowercase**: `'admin'`, `'staff'`
3. **Dashboard layout không có protection**: Không check role trước khi render
4. **Role mapping không đầy đủ**: Profile có thể có `role` hoặc `roles` array

## ✅ Các thay đổi đã thực hiện

### 1. Tạo Auth Utils (`lib/auth-utils.ts`)
- `isAdmin(role)` - Check admin role
- `isStaff(role)` - Check staff role  
- `isAdminOrStaff(role)` - Check admin hoặc staff
- `hasRole(userRole, allowedRoles)` - Check role trong danh sách
- `hasAnyRole(roles, allowedRoles)` - Check bất kỳ role nào

**Tất cả đều case-insensitive** - tự động convert sang uppercase để so sánh

### 2. Thêm Protection vào Dashboard Layout
- ✅ Check authentication trước khi render
- ✅ Check role (ADMIN hoặc STAFF) trước khi render
- ✅ Redirect về `/auth` nếu chưa login
- ✅ Redirect về home nếu không phải admin/staff
- ✅ Hiển thị loading state khi đang check

### 3. Sửa Navbar
- ✅ Sửa logic check role để so sánh case-insensitive
- ✅ Hiển thị link Dashboard chỉ khi user có role ADMIN hoặc STAFF

### 4. Sửa Profile Page
- ✅ Sửa `getRoleLabel()` để xử lý cả `role` string và `roles` array
- ✅ Case-insensitive comparison

### 5. Cập nhật AuthContext
- ✅ Đảm bảo `role` được lưu trong profile object

## 🧪 Cách kiểm tra

1. **Đăng nhập với tài khoản ADMIN**:
   - Role trong database: `ADMIN`
   - Sau khi login, kiểm tra console để xem role có được trả về đúng không
   - Truy cập `/dashboard` - phải vào được

2. **Đăng nhập với tài khoản CUSTOMER**:
   - Role trong database: `CUSTOMER`
   - Truy cập `/dashboard` - phải bị redirect về home

3. **Chưa đăng nhập**:
   - Truy cập `/dashboard` - phải bị redirect về `/auth`

## 🔧 Debug nếu vẫn không hoạt động

Thêm console.log vào `AuthContext.tsx` để kiểm tra:

```typescript
console.log('User data from backend:', userData);
console.log('Role:', userData.role);
console.log('Profile role:', profile?.role);
console.log('Profile roles:', profile?.roles);
```

Kiểm tra:
- Role có được trả về từ backend không?
- Role có đúng format `ADMIN` (uppercase) không?
- Token có được lưu trong localStorage không?

## 📝 Lưu ý

- Backend trả về role là enum: `CUSTOMER`, `STAFF`, `ADMIN` (uppercase)
- Frontend đã được cập nhật để xử lý cả uppercase và lowercase
- Tất cả role checks đều case-insensitive
