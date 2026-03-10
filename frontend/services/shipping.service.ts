import api from '@/lib/axios';

export type Shipment = {
  id: string;
  orderId: string;
  provider: string;
  trackingCode: string | null;
  ghnOrderCode: string | null;
  fee: number | null;
  status: string;
  address: string | null;
  createdAt: string;
  updatedAt: string;
};

export const shippingService = {
  getByOrderId(orderId: string): Promise<Shipment[]> {
    return api.get<Shipment[]>(`/shipping/orders/${orderId}`).then((r) => r.data);
  },
  createGhnShipment(orderId: string): Promise<{ shipmentId: string; orderCode: string; fee: number }> {
    return api.post<{ shipmentId: string; orderCode: string; fee: number }>(
      `/shipping/orders/${orderId}/create-ghn`,
    ).then((r) => r.data);
  },
};
