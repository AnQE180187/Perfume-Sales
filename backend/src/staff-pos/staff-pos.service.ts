import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  PaymentProvider,
  PaymentStatus,
  OrderStatus,
  OrderChannel,
} from '@prisma/client';
import { InventoryLogType } from '@prisma/client';
import { PaymentsService } from '../payments/payments.service';
import { StoresService } from '../stores/stores.service';

@Injectable()
export class StaffPosService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly paymentsService: PaymentsService,
    private readonly storesService: StoresService,
  ) {}

  async searchProducts(query: string) {
    const where: any = {};
    if (query) {
      where.OR = [
        { name: { contains: query, mode: 'insensitive' } },
        { slug: { contains: query, mode: 'insensitive' } },
        {
          variants: {
            some: {
              OR: [
                { name: { contains: query, mode: 'insensitive' } },
                { sku: { contains: query, mode: 'insensitive' } },
              ],
            },
          },
        },
      ];
    }

    const products = await this.prisma.product.findMany({
      where,
      include: {
        variants: true,
        brand: true,
      },
      take: 50,
      orderBy: { createdAt: 'desc' },
    });

    return products;
  }

  async createDraftOrder(staffUserId: string, storeId: string | null, role: string) {
    if (storeId) {
      await this.storesService.ensureStaffCanAccessStore(staffUserId, storeId, role);
    }
    const order = await this.prisma.order.create({
      data: {
        code: `POS-${Date.now()}`,
        staffId: staffUserId,
        storeId: storeId ?? undefined,
        channel: OrderChannel.POS,
        totalAmount: 0,
        discountAmount: 0,
        finalAmount: 0,
        status: OrderStatus.PENDING,
        paymentStatus: PaymentStatus.PENDING,
      },
      include: {
        items: true,
        store: true,
      },
    });

    return order;
  }

  private async getStaffOrderOrThrow(staffUserId: string, orderId: string) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: {
        items: {
          include: { variant: { include: { product: true } } },
        },
        store: true,
      },
    });

    if (!order) throw new NotFoundException('Order not found');
    if (order.channel !== OrderChannel.POS) {
      throw new ForbiddenException('Not a POS order');
    }
    if (order.staffId !== staffUserId) {
      throw new ForbiddenException('Order does not belong to this staff');
    }
    if (order.paymentStatus !== PaymentStatus.PENDING) {
      throw new BadRequestException('Order is already paid');
    }

    return order;
  }

  async upsertItem(
    staffUserId: string,
    orderId: string,
    variantId: string,
    quantity: number,
  ) {
    if (quantity < 0) {
      throw new BadRequestException('Quantity must be >= 0');
    }

    const order = await this.getStaffOrderOrThrow(staffUserId, orderId);

    const variant = await this.prisma.productVariant.findUnique({
      where: { id: variantId },
    });
    if (!variant) throw new NotFoundException('Variant not found');

    let availableStock = variant.stock;
    if (order.storeId) {
      const storeStock = await this.prisma.storeStock.findUnique({
        where: { storeId_variantId: { storeId: order.storeId, variantId } },
      });
      availableStock = storeStock?.quantity ?? 0;
    }

    if (quantity === 0) {
      await this.prisma.orderItem.deleteMany({
        where: { orderId: order.id, variantId },
      });
    } else {
      if (quantity > availableStock) {
        throw new BadRequestException('Quantity exceeds store stock');
      }

      const existing = order.items.find((i) => i.variantId === variantId);
      const totalPrice = variant.price * quantity;

      if (existing) {
        await this.prisma.orderItem.update({
          where: { id: existing.id },
          data: {
            quantity,
            unitPrice: variant.price,
            totalPrice,
          },
        });
      } else {
        await this.prisma.orderItem.create({
          data: {
            orderId: order.id,
            variantId,
            quantity,
            unitPrice: variant.price,
            totalPrice,
          },
        });
      }
    }

    const updatedItems = await this.prisma.orderItem.findMany({
      where: { orderId: order.id },
      include: { variant: { include: { product: true } } },
    });

    const totalAmount = updatedItems.reduce(
      (sum, item) => sum + item.totalPrice,
      0,
    );

    const updatedOrder = await this.prisma.order.update({
      where: { id: order.id },
      data: {
        totalAmount,
        discountAmount: 0,
        finalAmount: totalAmount,
      },
      include: {
        items: {
          include: { variant: { include: { product: true } } },
        },
        store: true,
      },
    });

    return updatedOrder;
  }

  async payCash(staffUserId: string, orderId: string) {
    const order = await this.getStaffOrderOrThrow(staffUserId, orderId);

    if (order.items.length === 0) {
      throw new BadRequestException('Order has no items');
    }

    await this.prisma.$transaction(async (tx) => {
      if (order.storeId) {
        for (const item of order.items) {
          const current = await tx.storeStock.findUnique({
            where: { storeId_variantId: { storeId: order.storeId, variantId: item.variantId } },
          });
          const qty = current?.quantity ?? 0;
          if (qty < item.quantity) {
            throw new BadRequestException(
              `Insufficient store stock for variant ${item.variantId}`,
            );
          }
          await tx.storeStock.upsert({
            where: { storeId_variantId: { storeId: order.storeId, variantId: item.variantId } },
            create: { storeId: order.storeId, variantId: item.variantId, quantity: -item.quantity },
            update: { quantity: { decrement: item.quantity }, updatedAt: new Date() },
          });
          await tx.inventoryLog.create({
            data: {
              variantId: item.variantId,
              staffId: staffUserId,
              storeId: order.storeId,
              type: InventoryLogType.SALE_POS,
              quantity: -item.quantity,
              reason: `POS order ${order.code}`,
            },
          });
        }
      } else {
        for (const item of order.items) {
          await tx.productVariant.update({
            where: { id: item.variantId },
            data: { stock: { decrement: item.quantity } },
          });
        }
      }

      await tx.payment.create({
        data: {
          orderId: order.id,
          provider: PaymentProvider.COD,
          amount: order.finalAmount,
          status: PaymentStatus.PAID,
        },
      });

      await tx.order.update({
        where: { id: order.id },
        data: {
          paymentStatus: PaymentStatus.PAID,
          status: OrderStatus.COMPLETED,
        },
      });
    });

    const refreshed = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: {
        items: {
          include: { variant: { include: { product: true } } },
        },
        payments: true,
        store: true,
      },
    });

    return refreshed;
  }

  async createQrPayment(staffUserId: string, orderId: string) {
    const order = await this.getStaffOrderOrThrow(staffUserId, orderId);

    if (order.items.length === 0) {
      throw new BadRequestException('Order has no items');
    }

    const numericCode = parseInt(order.code.replace(/\D/g, ''), 10);
    const orderCode = Number.isFinite(numericCode) ? numericCode : Date.now();

    return this.paymentsService.createPayOSPaymentLink(
      order.id,
      orderCode,
      order.finalAmount,
      order.items,
    );
  }
}
