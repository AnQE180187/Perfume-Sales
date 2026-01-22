import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { QueryProductsDto } from './dto/query-products.dto';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(private readonly prisma: PrismaService) {}

  async listPublic(query: QueryProductsDto) {
    const { search, skip = 0, take = 20, brandId, categoryId } = query;

    const where: any = {
      isActive: true,
    };

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }
    if (brandId) {
      where.brandId = brandId;
    }
    if (categoryId) {
      where.categoryId = categoryId;
    }

    const [items, total] = await this.prisma.$transaction([
      this.prisma.product.findMany({
        where,
        skip,
        take,
        include: {
          brand: true,
          category: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.product.count({ where }),
    ]);

    return {
      items,
      total,
      skip,
      take,
    };
  }

  async getPublicById(id: string) {
    const product = await this.prisma.product.findUnique({
      where: { id },
      include: {
        brand: true,
        category: true,
        reviews: true,
      },
    });

    if (!product || !product.isActive) {
      throw new NotFoundException('Product not found');
    }

    return product;
  }

  // Admin operations

  create(dto: CreateProductDto) {
    return this.prisma.product.create({
      data: {
        name: dto.name,
        slug: dto.slug,
        brandId: dto.brandId,
        categoryId: dto.categoryId,
        description: dto.description,
        gender: dto.gender,
        longevity: dto.longevity,
        concentration: dto.concentration,
        price: dto.price,
        currency: dto.currency ?? 'VND',
        isActive: dto.isActive ?? true,
      },
    });
  }

  update(id: string, dto: UpdateProductDto) {
    return this.prisma.product.update({
      where: { id },
      data: {
        name: dto.name,
        slug: dto.slug,
        brandId: dto.brandId,
        categoryId: dto.categoryId,
        description: dto.description,
        gender: dto.gender,
        longevity: dto.longevity,
        concentration: dto.concentration,
        price: dto.price,
        currency: dto.currency,
        isActive: dto.isActive,
      },
    });
  }

  async remove(id: string) {
    await this.prisma.product.delete({
      where: { id },
    });
    return { success: true };
  }
}


