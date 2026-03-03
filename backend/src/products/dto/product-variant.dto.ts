import { IsInt, IsOptional, IsString, Min } from 'class-validator';

export class ProductVariantDto {
  @IsInt()
  @Min(1)
  size: number; // 5, 10, 20, 30, 50, 100

  @IsOptional()
  @IsString()
  unit?: string; // ml (default)

  @IsOptional()
  @IsInt()
  priceOffset?: number; // giá tăng/giảm so với base price

  @IsOptional()
  @IsString()
  sku?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  stock?: number;
}

export class CreateProductWithVariantsDto {
  @IsString()
  name: string;

  @IsString()
  slug: string;

  @IsInt()
  brandId: number;

  @IsOptional()
  @IsInt()
  categoryId?: number | null;

  @IsOptional()
  @IsInt()
  scentFamilyId?: number | null;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsString()
  longevity?: string;

  @IsOptional()
  @IsString()
  concentration?: string;

  @IsInt()
  @Min(0)
  price: number;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  variants?: ProductVariantDto[]; // Dung tích variants
}
