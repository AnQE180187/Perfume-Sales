import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRoleEnum } from '@prisma/client';
import { InventoryLogType } from '@prisma/client';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';

@Injectable()
export class StoresService {
  constructor(private readonly prisma: PrismaService) {}

  /** Admin: list all stores */
  async list() {
    return this.prisma.store.findMany({
      orderBy: { name: 'asc' },
      include: {
        users: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
                fullName: true,
                role: true,
              },
            },
          },
        },
        _count: { select: { storeStocks: true, orders: true } },
      },
    });
  }

  /** Admin: create store */
  async create(dto: CreateStoreDto) {
    if (dto.code) {
      const existing = await this.prisma.store.findUnique({
        where: { code: dto.code },
      });
      if (existing) {
        throw new BadRequestException('Store code already exists');
      }
    }
    return this.prisma.store.create({
      data: {
        name: dto.name,
        code: dto.code ?? undefined,
        address: dto.address,
        isActive: dto.isActive ?? true,
      },
    });
  }

  /** Admin: get one store */
  async getById(id: string) {
    const store = await this.prisma.store.findUnique({
      where: { id },
      include: {
        users: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
                fullName: true,
                role: true,
              },
            },
          },
        },
        storeStocks: {
          include: {
            variant: {
              include: {
                product: { select: { name: true, slug: true } },
              },
            },
          },
        },
      },
    });
    if (!store) throw new NotFoundException('Store not found');
    return store;
  }

  /** Admin: update store */
  async update(id: string, dto: UpdateStoreDto) {
    await this.getById(id);
    if (dto.code) {
      const existing = await this.prisma.store.findFirst({
        where: { code: dto.code, NOT: { id } },
      });
      if (existing) {
        throw new BadRequestException('Store code already exists');
      }
    }
    return this.prisma.store.update({
      where: { id },
      data: {
        name: dto.name,
        code: dto.code,
        address: dto.address,
        isActive: dto.isActive,
      },
    });
  }

  /** Admin: delete store */
  async remove(id: string) {
    await this.getById(id);
    return this.prisma.store.delete({
      where: { id },
    });
  }

  /** Admin: assign staff to store */
  async assignStaff(storeId: string, userId: string) {
    const store = await this.prisma.store.findUnique({ where: { id: storeId } });
    if (!store) throw new NotFoundException('Store not found');

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });
    if (!user) throw new NotFoundException('User not found');
    if (user.role !== UserRoleEnum.STAFF) {
      throw new BadRequestException('User must have role STAFF to be assigned to a store');
    }

    await this.prisma.userStore.upsert({
      where: {
        userId_storeId: { userId, storeId },
      },
      create: { userId, storeId },
      update: {},
    });
    return this.getById(storeId);
  }

  /** Admin: unassign staff from store */
  async unassignStaff(storeId: string, userId: string) {
    await this.prisma.userStore.deleteMany({
      where: { storeId, userId },
    });
    return this.getById(storeId);
  }

  /** Staff/Admin: list stores assigned to current user (for staff: their stores only) */
  async getStoresForUser(userId: string, role: string) {
    if (role === UserRoleEnum.ADMIN) {
      return this.prisma.store.findMany({
        where: { isActive: true },
        orderBy: { name: 'asc' },
        select: {
          id: true,
          name: true,
          code: true,
          address: true,
        },
      });
    }
    return this.prisma.store.findMany({
      where: {
        isActive: true,
        users: { some: { userId } },
      },
      orderBy: { name: 'asc' },
      select: {
        id: true,
        name: true,
        code: true,
        address: true,
      },
    });
  }

  /** Ensure staff has access to store (throw if not) */
  async ensureStaffCanAccessStore(userId: string, storeId: string, role: string) {
    if (role === UserRoleEnum.ADMIN) return;
    const assigned = await this.prisma.userStore.findUnique({
      where: { userId_storeId: { userId, storeId } },
    });
    if (!assigned) {
      throw new ForbiddenException('You do not have access to this store');
    }
  }

  // ---------- Admin inventory: stock by store, import, transfer ----------

  /** Admin: overview stock by store (optional storeId to filter one store) */
  async getStockOverview(storeId?: string) {
    const where = storeId ? { storeId } : {};
    const storeStocks = await this.prisma.storeStock.findMany({
      where,
      include: {
        store: { select: { id: true, name: true, code: true } },
        variant: {
          include: {
            product: {
              select: { id: true, name: true, slug: true, brand: { select: { name: true } } },
            },
          },
        },
      },
      orderBy: [{ storeId: 'asc' }, { variantId: 'asc' }],
    });

    const byStore = new Map<
      string,
      { store: { id: string; name: string; code: string | null }; variants: any[]; totalUnits: number }
    >();
    for (const ss of storeStocks) {
      const key = ss.storeId;
      if (!byStore.has(key)) {
        byStore.set(key, {
          store: ss.store,
          variants: [],
          totalUnits: 0,
        });
      }
      const entry = byStore.get(key)!;
      entry.variants.push({
        variantId: ss.variantId,
        variantName: ss.variant.name,
        productName: ss.variant.product.name,
        brandName: ss.variant.product.brand?.name ?? null,
        quantity: ss.quantity,
        updatedAt: ss.updatedAt,
      });
      entry.totalUnits += ss.quantity;
    }

    return {
      stores: Array.from(byStore.values()),
      summary: {
        totalStores: byStore.size,
        totalUnits: storeStocks.reduce((s, ss) => s + ss.quantity, 0),
      },
    };
  }

  /** Admin: import stock into a store (create or increment StoreStock) */
  async adminImportStock(
    storeId: string,
    variantId: string,
    quantity: number,
    staffId: string,
    reason?: string,
  ) {
    if (quantity <= 0) {
      throw new BadRequestException('Quantity must be greater than 0');
    }
    const store = await this.prisma.store.findUnique({ where: { id: storeId } });
    if (!store) throw new NotFoundException('Store not found');
    const variant = await this.prisma.productVariant.findUnique({
      where: { id: variantId },
      include: { product: true },
    });
    if (!variant) throw new NotFoundException('Variant not found');

    await this.prisma.$transaction(async (tx) => {
      await tx.storeStock.upsert({
        where: {
          storeId_variantId: { storeId, variantId },
        },
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
          reason: reason ?? 'Admin import',
        },
      });
    });
    return this.getStockOverview(storeId);
  }

  /** Admin: transfer stock between two stores */
  async transferStock(
    fromStoreId: string,
    toStoreId: string,
    variantId: string,
    quantity: number,
    staffId: string,
    reason?: string,
  ) {
    if (quantity <= 0) {
      throw new BadRequestException('Quantity must be greater than 0');
    }
    if (fromStoreId === toStoreId) {
      throw new BadRequestException('From and to store must be different');
    }
    const [fromStore, toStore, variant] = await Promise.all([
      this.prisma.store.findUnique({ where: { id: fromStoreId } }),
      this.prisma.store.findUnique({ where: { id: toStoreId } }),
      this.prisma.productVariant.findUnique({ where: { id: variantId } }),
    ]);
    if (!fromStore) throw new NotFoundException('From store not found');
    if (!toStore) throw new NotFoundException('To store not found');
    if (!variant) throw new NotFoundException('Variant not found');

    const fromStock = await this.prisma.storeStock.findUnique({
      where: { storeId_variantId: { storeId: fromStoreId, variantId } },
    });
    const available = fromStock?.quantity ?? 0;
    if (available < quantity) {
      throw new BadRequestException(
        `Insufficient stock at source store. Available: ${available}, requested: ${quantity}`,
      );
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.storeStock.update({
        where: { storeId_variantId: { storeId: fromStoreId, variantId } },
        data: { quantity: { decrement: quantity }, updatedAt: new Date() },
      });
      await tx.storeStock.upsert({
        where: { storeId_variantId: { storeId: toStoreId, variantId } },
        create: { storeId: toStoreId, variantId, quantity },
        update: { quantity: { increment: quantity }, updatedAt: new Date() },
      });
      await tx.inventoryLog.create({
        data: {
          variantId,
          staffId,
          storeId: fromStoreId,
          type: InventoryLogType.ADJUST,
          quantity: -quantity,
          reason: reason ?? `Transfer to store ${toStore.name}`,
        },
      });
      await tx.inventoryLog.create({
        data: {
          variantId,
          staffId,
          storeId: toStoreId,
          type: InventoryLogType.IMPORT,
          quantity,
          reason: reason ?? `Transfer from store ${fromStore.name}`,
        },
      });
    });
    return this.getStockOverview();
  }
}
