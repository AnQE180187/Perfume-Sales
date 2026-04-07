import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class LoyaltyService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  // Calculation constants
  private readonly EARN_RATE = 10000; // 10,000đ = 1 point
  private readonly REDEEM_VALUE = 500; // 1 point = 500đ discount (100 pts = 50,000đ)

  async getLoyaltyInfo(userId: string) {
    try {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: { loyaltyPoints: true },
      });

      const history = await this.prisma.loyaltyTransaction.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 20,
      });

      return {
        points: user?.loyaltyPoints || 0,
        history,
      };
    } catch (error) {
      console.error('Error in getLoyaltyInfo:', error);
      throw error;
    }
  }

  async earnPoints(userId: string, amount: number, orderId: string) {
    const points = Math.floor(amount / this.EARN_RATE);
    if (points <= 0) return;

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { loyaltyPoints: { increment: points } },
      }),
      this.prisma.loyaltyTransaction.create({
        data: {
          userId,
          orderId,
          points,
          reason: `EARNED_FROM_ORDER_${orderId}`,
        },
      }),
    ]);

    // Notify user about earned points
    this.notificationsService
      .create({
        userId,
        type: 'LOYALTY',
        title: 'Nhận điểm thưởng',
        content: `Bạn nhận được ${points} điểm thưởng từ đơn hàng.`,
        data: { points, orderId },
      })
      .catch(() => {});
  }

  async redeemPoints(userId: string, points: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || user.loyaltyPoints < points) {
      throw new BadRequestException('Insufficient loyalty points');
    }

    const discountAmount = points * this.REDEEM_VALUE;

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { loyaltyPoints: { decrement: points } },
      }),
      this.prisma.loyaltyTransaction.create({
        data: {
          userId,
          points: -points,
          reason: `REDEEMED_FOR_DISCOUNT`,
        },
      }),
    ]);

    return {
      pointsRedeemed: points,
      discountAmount,
    };
  }

  async exchangePointsForVoucher(userId: string, points: number) {
    // Proposed packages: 100, 200, 500
    const packages: Record<number, { discount: number; label: string }> = {
      100: { discount: 50000, label: '50k VND Voucher' },
      200: { discount: 100000, label: '100k VND Voucher' },
      500: { discount: 250000, label: '250k VND Voucher' },
    };

    const pkg = packages[points];
    if (!pkg) {
      throw new BadRequestException('Gói đổi điểm không hợp lệ');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || user.loyaltyPoints < points) {
      throw new BadRequestException('Bạn không đủ điểm để thực hiện giao dịch này');
    }

    const code = `LOY-${Math.random().toString(36).substring(2, 10).toUpperCase()}`;
    const now = new Date();
    const expiry = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000); // 30 days

    return await this.prisma.$transaction(async (tx) => {
      // 1. Update User Points
      await tx.user.update({
        where: { id: userId },
        data: { loyaltyPoints: { decrement: points } },
      });

      // 2. Create Loyalty Transaction
      await tx.loyaltyTransaction.create({
        data: {
          userId,
          points: -points,
          reason: `EXCHANGED_FOR_VOUCHER_${code}`,
        },
      });

      // 3. Create Promotion Code
      const promo = await tx.promotionCode.create({
        data: {
          code,
          description: `Voucher đổi từ ${points} điểm loyalty`,
          discountType: 'FIXED_AMOUNT',
          discountValue: pkg.discount,
          minOrderAmount: pkg.discount * 2, // 2x value min order to avoid abuse
          startDate: now,
          endDate: expiry,
          usageLimit: 1,
          isActive: true,
        },
      });

      // 4. Notify user about exchange
      this.notificationsService
        .create({
          userId,
          type: 'LOYALTY',
          title: 'Đổi điểm lấy quà thành công',
          content: `Bạn đã đổi ${points} điểm lấy mã giảm giá ${code} giảm ${pkg.discount.toLocaleString()}đ.`,
          data: { code, points, discountValue: pkg.discount },
        })
        .catch(() => {});

      return promo;
    });
  }
}
