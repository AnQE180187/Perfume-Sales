import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { InventoryLogType } from '@prisma/client';
import { StoresService } from '../stores/stores.service';

@Injectable()
export class StaffInventoryService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storesService: StoresService,
  ) {}

  /** List inventory overview for a store (StoreStock). storeId required for staff. */
  async listOverview(storeId: string, userId: string, role: string) {
    await this.storesService.ensureStaffCanAccessStore(userId, storeId, role);

    const storeStocks = await this.prisma.storeStock.findMany({
      where: { storeId },
      include: {
        variant: {
          include: {
            product: {
              include: { brand: true },
            },
          },
        },
      },
      orderBy: [{ quantity: 'asc' }, { updatedAt: 'desc' }],
      take: 200,
    });

    const totalUnits = storeStocks.reduce((s, ss) => s + ss.quantity, 0);
    const lowStockThreshold = 5;
    const lowStockCount = storeStocks.filter(
      (ss) => ss.quantity > 0 && ss.quantity <= lowStockThreshold,
    ).length;

    const latestImport = await this.prisma.inventoryLog.findFirst({
      where: { storeId, type: InventoryLogType.IMPORT },
      orderBy: { createdAt: 'desc' },
    });

    return {
      storeId,
      stats: {
        totalUnits,
        lowStockCount,
        latestImportAt: latestImport?.createdAt ?? null,
      },
      variants: storeStocks.map((ss) => ({
        id: ss.variantId,
        name: ss.variant.product.name,
        brand: ss.variant.product.brand?.name ?? null,
        variantName: ss.variant.name,
        stock: ss.quantity,
        updatedAt: ss.updatedAt,
      })),
    };
  }

  async importStock(
    storeId: string,
    staffId: string,
    variantId: string,
    quantity: number,
    userId: string,
    role: string,
    reason?: string,
  ) {
    await this.storesService.ensureStaffCanAccessStore(userId, storeId, role);
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
      await tx.storeStock.upsert({
        where: { storeId_variantId: { storeId, variantId } },
        create: { storeId, variantId, quantity },
        update: { quantity: { increment: quantity }, updatedAt: new Date() },
      });
      await tx.inventoryLog.create({
        data: {
          variantId,
          staffId,
          storeId,
          type: InventoryLogType.IMPORT,
          quantity,
          reason,
        },
      });
    });

    return this.listOverview(storeId, userId, role);
  }

  async adjustStock(
    storeId: string,
    staffId: string,
    variantId: string,
    delta: number,
    userId: string,
    role: string,
    reason: string,
  ) {
    await this.storesService.ensureStaffCanAccessStore(userId, storeId, role);
    if (delta === 0) {
      throw new BadRequestException('Delta must be non-zero');
    }

    const current = await this.prisma.storeStock.findUnique({
      where: { storeId_variantId: { storeId, variantId } },
    });
    const currentQty = current?.quantity ?? 0;
    const newQty = currentQty + delta;
    if (newQty < 0) {
      throw new BadRequestException('Resulting stock cannot be negative');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.storeStock.upsert({
        where: { storeId_variantId: { storeId, variantId } },
        create: { storeId, variantId, quantity: newQty },
        update: { quantity: newQty, updatedAt: new Date() },
      });
      await tx.inventoryLog.create({
        data: {
          variantId,
          staffId,
          storeId,
          type: InventoryLogType.ADJUST,
          quantity: delta,
          reason: reason || 'Adjustment',
        },
      });
    });

    return this.listOverview(storeId, userId, role);
  }

  async getLogs(params: {
    storeId?: string;
    variantId?: string;
    from?: string;
    to?: string;
  }, userId: string, role: string) {
    const where: any = {};
    if (params.storeId) {
      await this.storesService.ensureStaffCanAccessStore(userId, params.storeId, role);
      where.storeId = params.storeId;
    }
    if (params.variantId) where.variantId = params.variantId;
    if (params.from || params.to) {
      where.createdAt = {};
      if (params.from) where.createdAt.gte = new Date(params.from);
      if (params.to) where.createdAt.lte = new Date(params.to);
    }

    const logs = await this.prisma.inventoryLog.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: 200,
      include: {
        variant: { include: { product: true } },
        staff: true,
        store: true,
      },
    });
    return logs;
  }
}

