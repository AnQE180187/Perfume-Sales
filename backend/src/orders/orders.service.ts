import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { PromotionsService } from '../promotions/promotions.service';

@Injectable()
export class OrdersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly promotionsService: PromotionsService
  ) { }

  async createFromCart(userId: string, dto: CreateOrderDto) {
    const cart = await this.prisma.cart.findFirst({
      where: { userId },
      include: {
        items: {
          include: {
            variant: {
              include: { product: true },
            },
          },
        },
      },
    });

    if (!cart || cart.items.length === 0) {
      throw new BadRequestException('Cart is empty');
    }

    const totalAmount = cart.items.reduce(
      (sum, item) => sum + item.quantity * item.variant.price,
      0,
    );

    let discountAmount = 0;
    let promoData: any = null;

    if (dto.promotionCode) {
      try {
        promoData = await this.promotionsService.validate({
          code: dto.promotionCode,
          amount: totalAmount,
        }, userId);
        discountAmount = promoData.discountAmount;
      } catch (e) {
        throw e;
      }
    }

    const finalAmount = totalAmount - discountAmount;

    const order = await this.prisma.$transaction(async (tx) => {
      const created = await tx.order.create({
        data: {
          code: `ORD-${Date.now()}`,
          userId,
          totalAmount,
          discountAmount,
          finalAmount,
          shippingAddress: dto.shippingAddress,
          phone: dto.phone,
          items: {
            create: cart.items.map((item) => ({
              variantId: item.variantId,
              unitPrice: item.variant.price,
              quantity: item.quantity,
              totalPrice: item.quantity * item.variant.price,
            })),
          },
          promotions: promoData ? {
            create: {
              promotionCodeId: promoData.promoId,
              discountAmount: promoData.discountAmount,
            }
          } : undefined
        },
        include: {
          items: true,
          promotions: {
            include: { promotionCode: true }
          }
        },
      });

      if (promoData) {
        await tx.promotionCode.update({
          where: { id: promoData.promoId },
          data: { usedCount: { increment: 1 } }
        });
      }

      await tx.cartItem.deleteMany({ where: { cartId: cart.id } });

      return created;
    });

    return order;
  }

  async listMyOrders(userId: string) {
    const orders = await this.prisma.order.findMany({
      where: { userId },
      include: { items: { include: { variant: { include: { product: true } } } }, promotions: true },
      orderBy: { createdAt: 'desc' },
    });

    return orders.map(order => ({
      ...order,
      items: order.items.map(item => ({
        ...item,
        product: item.variant.product
      }))
    }));
  }

  async listAllOrders(skip: number, take: number) {
    const [rawData, total] = await Promise.all([
      this.prisma.order.findMany({
        skip,
        take,
        include: {
          items: { include: { variant: { include: { product: true } } } },
          user: true,
          promotions: { include: { promotionCode: true } }
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.order.count(),
    ]);

    const data = rawData.map(order => ({
      ...order,
      items: order.items.map(item => ({
        ...item,
        product: item.variant.product
      }))
    }));

    return {
      data,
      total,
      skip,
      take,
      pages: Math.ceil(total / take),
    };
  }

  async getMyOrderById(userId: string, id: string) {
    const order = await this.prisma.order.findFirst({
      where: { id, userId },
      include: {
        items: {
          include: { variant: { include: { product: true } } }
        },
        promotions: { include: { promotionCode: true } }
      },
    });
    if (!order) throw new NotFoundException('Order not found');

    return {
      ...order,
      items: order.items.map(item => ({
        ...item,
        product: item.variant.product
      }))
    };
  }

  async getOrderById(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        items: {
          include: { variant: { include: { product: true } } }
        },
        user: true,
        promotions: { include: { promotionCode: true } }
      },
    });
    if (!order) throw new NotFoundException('Order not found');

    return {
      ...order,
      items: order.items.map(item => ({
        ...item,
        product: item.variant.product
      }))
    };
  }

  async updateStatus(id: string, status?: any, paymentStatus?: any) {
    return this.prisma.order.update({
      where: { id },
      data: {
        ...(status && { status }),
        ...(paymentStatus && { paymentStatus }),
      },
    });
  }
}
