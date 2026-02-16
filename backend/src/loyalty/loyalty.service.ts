import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class LoyaltyService {
    constructor(private prisma: PrismaService) { }

    // Calculation constants
    private readonly EARN_RATE = 10000; // 10,000đ = 1 point
    private readonly REDEEM_VALUE = 500; // 1 point = 500đ discount (100 pts = 50,000đ)

    async getLoyaltyInfo(userId: string) {
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
}
