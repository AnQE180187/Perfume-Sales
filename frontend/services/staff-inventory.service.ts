import api from '@/lib/axios';

export type StaffInventoryVariant = {
  id: string;
  name: string;
  brand: string | null;
  variantName: string;
  stock: number;
  updatedAt: string;
};

export type StaffInventoryOverview = {
  storeId?: string;
  stats: {
    totalUnits: number;
    lowStockCount: number;
    latestImportAt: string | null;
  };
  variants: StaffInventoryVariant[];
};

export type StaffInventoryLog = {
  id: number;
  variantId: string;
  staffId?: string | null;
  type: 'IMPORT' | 'ADJUST' | 'SALE_POS';
  quantity: number;
  reason?: string | null;
  createdAt: string;
  variant: {
    id: string;
    name: string;
    productId: string;
    product: {
      id: string;
      name: string;
    };
  };
  staff?: {
    id: string;
    fullName?: string | null;
    email: string;
  } | null;
};

export const staffInventoryService = {
  getOverview(storeId: string): Promise<StaffInventoryOverview> {
    return api
      .get<StaffInventoryOverview>('/staff/inventory', { params: { storeId } })
      .then((r) => r.data);
  },
  importStock(
    storeId: string,
    variantId: string,
    quantity: number,
    reason?: string,
  ): Promise<StaffInventoryOverview> {
    return api
      .post<StaffInventoryOverview>('/staff/inventory/import', {
        storeId,
        variantId,
        quantity,
        reason,
      })
      .then((r) => r.data);
  },
  adjustStock(
    storeId: string,
    variantId: string,
    delta: number,
    reason: string,
  ): Promise<StaffInventoryOverview> {
    return api
      .post<StaffInventoryOverview>('/staff/inventory/adjust', {
        storeId,
        variantId,
        delta,
        reason,
      })
      .then((r) => r.data);
  },
  getLogs(params?: {
    storeId?: string;
    variantId?: string;
    from?: string;
    to?: string;
  }): Promise<StaffInventoryLog[]> {
    return api
      .get<StaffInventoryLog[]>('/staff/inventory/logs', { params })
      .then((r) => r.data);
  },
};

