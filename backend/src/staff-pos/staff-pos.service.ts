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
import { PaymentsService } from '../payments/payments.service';

@Injectable()
export class StaffPosService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly paymentsService: PaymentsService,
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

  async createDraftOrder(staffUserId: string) {
    const order = await this.prisma.order.create({
      data: {
        code: `POS-${Date.now()}`,
        staffId: staffUserId,
        channel: OrderChannel.POS,
        totalAmount: 0,
        discountAmount: 0,
        finalAmount: 0,
        status: OrderStatus.PENDING,
        paymentStatus: PaymentStatus.PENDING,
      },
      include: {
        items: true,
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

    if (quantity === 0) {
      await this.prisma.orderItem.deleteMany({
        where: { orderId: order.id, variantId },
      });
    } else {
      if (quantity > variant.stock) {
        throw new BadRequestException('Quantity exceeds stock');
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
      // Deduct stock
      for (const item of order.items) {
        await tx.productVariant.update({
          where: { id: item.variantId },
          data: {
            stock: {
              decrement: item.quantity,
            },
          },
        });
      }

      // Create payment record
      await tx.payment.create({
        data: {
          orderId: order.id,
          provider: PaymentProvider.COD,
          amount: order.finalAmount,
          status: PaymentStatus.PAID,
        },
      });

      // Update order status
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
