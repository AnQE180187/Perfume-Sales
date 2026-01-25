import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  async createFromCart(userId: string, dto: CreateOrderDto) {
    const cart = await this.prisma.cart.findFirst({
      where: { userId },
      include: {
        items: {
          include: { product: true },
        },
      },
    });

    if (!cart || cart.items.length === 0) {
      throw new BadRequestException('Cart is empty');
    }

    const totalAmount = cart.items.reduce(
      (sum, item) => sum + item.quantity * item.product.price,
      0,
    );

    const order = await this.prisma.$transaction(async (tx) => {
      const created = await tx.order.create({
        data: {
          code: `ORD-${Date.now()}`,
          userId,
          totalAmount,
          discountAmount: 0,
          finalAmount: totalAmount,
          shippingAddress: dto.shippingAddress,
          phone: dto.phone,
          items: {
            create: cart.items.map((item) => ({
              productId: item.productId,
              unitPrice: item.product.price,
              quantity: item.quantity,
              totalPrice: item.quantity * item.product.price,
            })),
          },
        },
        include: {
          items: true,
        },
      });

      await tx.cartItem.deleteMany({ where: { cartId: cart.id } });

      return created;
    });

    return order;
  }

  listMyOrders(userId: string) {
    return this.prisma.order.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getMyOrderById(userId: string, orderId: string) {
    const order = await this.prisma.order.findFirst({
      where: { id: orderId, userId },
      include: {
        items: {
          include: { product: true },
        },
      },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    return order;
  }
}
