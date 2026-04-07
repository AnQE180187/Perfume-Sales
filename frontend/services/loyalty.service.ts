import api from '@/lib/axios';

export const loyaltyService = {
    getStatus() {
        return api.get<{ points: number; history: any[] }>('/loyalty/status').then((r) => r.data);
    },
    redeem(points: number) {
        return api.post<{ pointsRedeemed: number; discountAmount: number }>('/loyalty/redeem', { points }).then((r) => r.data);
    },
    exchangePoints(points: number) {
        return api.post('/loyalty/exchange', { points }).then((r) => r.data);
    }
};
