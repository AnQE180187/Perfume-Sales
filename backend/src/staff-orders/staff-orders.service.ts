import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { OrderChannel } from '@prisma/client';

@Injectable()
export class StaffOrdersService {
  constructor(private readonly prisma: PrismaService) {}

  async listStaffPosOrders(
    userId: string,
    role: 'STAFF' | 'ADMIN',
    skip = 0,
    take = 20,
  ) {
    const where: any = {
      channel: OrderChannel.POS,
    };

    if (role === 'STAFF') {
      where.staffId = userId;
    }

    const [rawData, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        skip,
        take,
        include: {
          items: {
            include: {
              variant: {
                include: { product: true },
              },
            },
          },
          staff: true,
          payments: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.order.count({ where }),
    ]);

    const data = rawData.map((order) => ({
      ...order,
      items: order.items.map((item) => ({
        ...item,
        product: item.variant.product,
      })),
    }));

    return {
      data,
      total,
      skip,
      take,
      pages: Math.ceil(total / take),
    };
  }
}

