# Hướng Dẫn Sử Dụng Product Variants (Dung Tích Nước Hoa)

## Mô Tả Tính Năng

Hệ thống đã được cập nhật để hỗ trợ các dung tích khác nhau cho mỗi sản phẩm nước hoa. Khi tạo sản phẩm mới, bạn có thể chỉ định các dung tích có sẵn (5ml, 10ml, 20ml, 30ml, 50ml, 100ml) hoặc tùy chỉnh.

## Database Schema

### Model ProductVariant
```prisma
model ProductVariant {
  id          String      @id @default(cuid())
  productId   String
  size        Int         // dung tích (5, 10, 20, 30, 50, 100 ml)
  unit        String      @default("ml")
  priceOffset Int         @default(0)  // giá tăng/giảm so với base price
  sku         String?     @unique      // Stock Keeping Unit
  stock       Int         @default(0)
  isActive    Boolean     @default(true)
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt

  product     Product     @relation(fields: [productId], references: [id], onDelete: Cascade)

  @@unique([productId, size])
  @@index([productId])
}
```

## API Endpoints

### 1. Tạo Sản Phẩm Với Variants Mặc Định (Recommended)

**Endpoint:** `POST /api/v1/admin/products/with-variants`

**Request Body:**
```json
{
  "name": "Dior Sauvage",
  "slug": "dior-sauvage",
  "brandId": 1,
  "categoryId": 2,
  "scentFamilyId": 3,
  "description": "Mùi hương lâu lâu, phù hợp cho nam",
  "gender": "MALE",
  "longevity": "long",
  "concentration": "eau_de_parfum",
  "price": 800000,
  "currency": "VND"
}
```

**Response:**
```json
{
  "id": "product-123",
  "name": "Dior Sauvage",
  "slug": "dior-sauvage",
  "price": 800000,
  "variants": [
    {
      "id": "variant-1",
      "size": 5,
      "unit": "ml",
      "priceOffset": 0,
      "sku": "product-123-5ml",
      "stock": 0
    },
    {
      "id": "variant-2",
      "size": 10,
      "unit": "ml",
      "priceOffset": 50000,
      "sku": "product-123-10ml",
      "stock": 0
    },
    {
      "id": "variant-3",
      "size": 20,
      "unit": "ml",
      "priceOffset": 150000,
      "sku": "product-123-20ml",
      "stock": 0
    },
    {
      "id": "variant-4",
      "size": 30,
      "unit": "ml",
      "priceOffset": 200000,
      "sku": "product-123-30ml",
      "stock": 0
    },
    {
      "id": "variant-5",
      "size": 50,
      "unit": "ml",
      "priceOffset": 350000,
      "sku": "product-123-50ml",
      "stock": 0
    },
    {
      "id": "variant-6",
      "size": 100,
      "unit": "ml",
      "priceOffset": 600000,
      "sku": "product-123-100ml",
      "stock": 0
    }
  ]
}
```

### 2. Tạo Sản Phẩm Với Variants Tùy Chỉnh

**Endpoint:** `POST /api/v1/admin/products/with-variants`

**Request Body:**
```json
{
  "name": "Chanel No. 5",
  "slug": "chanel-no5",
  "brandId": 2,
  "categoryId": 1,
  "price": 1200000,
  "variants": [
    {
      "size": 15,
      "unit": "ml",
      "priceOffset": 100000,
      "sku": "chanel-no5-15ml",
      "stock": 50
    },
    {
      "size": 50,
      "unit": "ml",
      "priceOffset": 400000,
      "sku": "chanel-no5-50ml",
      "stock": 100
    },
    {
      "size": 100,
      "unit": "ml",
      "priceOffset": 700000,
      "sku": "chanel-no5-100ml",
      "stock": 75
    }
  ]
}
```

## Giá Mặc Định Cho Dung Tích

Khi không chỉ định priceOffset, hệ thống sẽ tự động sử dụng giá này:

| Dung Tích | Tính Giá |
|-----------|---------|
| 5ml | Base Price |
| 10ml | Base Price + 50,000 VND |
| 20ml | Base Price + 150,000 VND |
| 30ml | Base Price + 200,000 VND |
| 50ml | Base Price + 350,000 VND |
| 100ml | Base Price + 600,000 VND |

## Lấy Chi Tiết Sản Phẩm Với Variants

**Endpoint:** `GET /api/v1/products/:id`

**Response sẽ include:**
```json
{
  "id": "product-123",
  "name": "Dior Sauvage",
  "price": 800000,
  "variants": [
    {
      "id": "variant-1",
      "size": 5,
      "unit": "ml",
      "priceOffset": 0,
      "stock": 10,
      "isActive": true
    },
    ...
  ]
}
```

## Thêm Variants Vào Sản Phẩm Hiện Có

Hiện tại chưa có endpoint riêng. Nếu cần, bạn có thể:

1. Tạo sản phẩm mới với variants bằng endpoint `/with-variants`
2. Hoặc liên hệ để thêm endpoint `POST /admin/products/:id/variants`

## Sử Dụng Variants Trong Cart & Orders

Khi thêm sản phẩm vào giỏ hàng, cần thêm `variantId`:

```json
{
  "productId": "product-123",
  "variantId": "variant-3",  // 20ml variant
  "quantity": 2
}
```

Giá sẽ tự động tính toán: `800000 + 150000 = 950000 VND` (base price + offset)

## Notes

- Mỗi sản phẩm chỉ có 1 size duy nhất cho mỗi giá trị `size`
- `sku` là unique ID để tracking inventory
- Variants có thể deactivate bằng cách set `isActive: false`
- Khi xóa sản phẩm, tất cả variants sẽ bị xóa (cascade delete)
