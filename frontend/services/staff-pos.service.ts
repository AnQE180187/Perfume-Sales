import api from '@/lib/axios';
import type { Product, ProductVariant } from './product.service';

export type PosOrderItem = {
  id: number;
  orderId: string;
  variantId: string;
  unitPrice: number;
  quantity: number;
  totalPrice: number;
  variant: ProductVariant & {
    product?: Pick<Product, 'id' | 'name'>;
  };
};

export type PosOrder = {
  id: string;
  code: string;
  staffId?: string | null;
  totalAmount: number;
  discountAmount: number;
  finalAmount: number;
  status: string;
  paymentStatus: string;
  channel: string;
  items: PosOrderItem[];
};

export const staffPosService = {
  searchProducts(q: string) {
    return api
      .get<Product[]>('/staff/pos/products', { params: { q } })
      .then((r) => r.data);
  },

  createDraft(): Promise<PosOrder> {
    return api.post<PosOrder>('/staff/pos/orders').then((r) => r.data);
  },

  upsertItem(
    orderId: string,
    variantId: string,
    quantity: number,
  ): Promise<PosOrder> {
    return api
      .patch<PosOrder>(`/staff/pos/orders/${orderId}/items`, {
        variantId,
        quantity,
      })
      .then((r) => r.data);
  },

  payCash(orderId: string): Promise<PosOrder> {
    return api
      .post<PosOrder>(`/staff/pos/orders/${orderId}/pay/cash`)
      .then((r) => r.data);
  },
};

