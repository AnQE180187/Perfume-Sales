import api from '@/lib/axios';

export type StaffPosOrderItem = {
  id: number;
  orderId: string;
  variantId: string;
  unitPrice: number;
  quantity: number;
  totalPrice: number;
  product: {
    id: string;
    name: string;
  };
};

export type StaffPosOrder = {
  id: string;
  code: string;
  staffId?: string | null;
  totalAmount: number;
  discountAmount: number;
  finalAmount: number;
  status: string;
  paymentStatus: string;
  channel: string;
  createdAt: string;
  items: StaffPosOrderItem[];
};

export type StaffPosOrderListRes = {
  data: StaffPosOrder[];
  total: number;
  skip: number;
  take: number;
  pages: number;
};

export const staffOrdersService = {
  list(params?: { skip?: number; take?: number }): Promise<StaffPosOrderListRes> {
    return api
      .get<StaffPosOrderListRes>('/staff/orders', { params })
      .then((r) => r.data);
  },
};

