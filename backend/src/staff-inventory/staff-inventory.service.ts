import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { InventoryLogType } from '@prisma/client';

@Injectable()
export class StaffInventoryService {
  constructor(private readonly prisma: PrismaService) {}

  async listOverview() {
    const variants = await this.prisma.productVariant.findMany({
      include: {
        product: {
          include: {
            brand: true,
          },
        },
      },
      orderBy: [
        { stock: 'asc' },
        { updatedAt: 'desc' },
      ],
      take: 200,
    });

    const totalUnits = variants.reduce((sum, v) => sum + v.stock, 0);
    const lowStockThreshold = 5;
    const lowStockCount = variants.filter((v) => v.stock > 0 && v.stock <= lowStockThreshold).length;

    const latestImport = await this.prisma.inventoryLog.findFirst({
      where: { type: InventoryLogType.IMPORT },
      orderBy: { createdAt: 'desc' },
    });

    return {
      stats: {
        totalUnits,
        lowStockCount,
        latestImportAt: latestImport?.createdAt ?? null,
      },
      variants: variants.map((v) => ({
        id: v.id,
        name: v.product.name,
        brand: v.product.brand?.name ?? null,
        variantName: v.name,
        stock: v.stock,
        updatedAt: v.updatedAt,
      })),
    };
  }

  async importStock(staffId: string, variantId: string, quantity: number, reason?: string) {
    if (quantity <= 0) {
      throw new BadRequestException('Quantity must be greater than 0');
    }

    const variant = await this.prisma.productVariant.findUnique({
      where: { id: variantId },
    });
    if (!variant) {
      throw new BadRequestException('Variant not found');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.productVariant.update({
        where: { id: variantId },
        data: {
          stock: { increment: quantity },
        },
      });

      await tx.inventoryLog.create({
        data: {
          variantId,
          staffId,
          type: InventoryLogType.IMPORT,
          quantity,
          reason,
        },
      });
    });

    return this.listOverview();
  }

  async adjustStock(staffId: string, variantId: string, delta: number, reason: string) {
    if (delta === 0) {
      throw new BadRequestException('Delta must be non-zero');
    }

    const variant = await this.prisma.productVariant.findUnique({
      where: { id: variantId },
    });
    if (!variant) {
      throw new BadRequestException('Variant not found');
    }

    const newStock = variant.stock + delta;
    if (newStock < 0) {
      throw new BadRequestException('Resulting stock cannot be negative');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.productVariant.update({
        where: { id: variantId },
        data: {
          stock: newStock,
        },
      });

      await tx.inventoryLog.create({
        data: {
          variantId,
          staffId,
          type: InventoryLogType.ADJUST,
          quantity: delta,
          reason: reason || 'Adjustment',
        },
      });
    });

    return this.listOverview();
  }

  async getLogs(params: { variantId?: string; from?: string; to?: string }) {
    const where: any = {};
    if (params.variantId) {
      where.variantId = params.variantId;
    }
    if (params.from || params.to) {
      where.createdAt = {};
      if (params.from) {
        where.createdAt.gte = new Date(params.from);
      }
      if (params.to) {
        where.createdAt.lte = new Date(params.to);
      }
    }

    const logs = await this.prisma.inventoryLog.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: 200,
      include: {
        variant: {
          include: {
            product: true,
          },
        },
        staff: true,
      },
    });

    return logs;
  }
}

