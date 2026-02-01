import api from '@/lib/axios';

export type CartItem = {
  id: number;
  cartId: string;
  productId: string;
  quantity: number;
  product: {
    id: string;
    name: string;
    price: number;
    images?: { id: number; url: string; order: number }[];
  };
};

export type Cart = {
  id: string;
  userId: string;
  items: CartItem[];
};

export const cartService = {
  getCart() {
    return api.get<Cart>('/cart').then((r) => r.data);
  },
  addItem(productId: string, quantity: number) {
    return api.post<Cart>('/cart/items', { productId, quantity }).then((r) => r.data);
  },
  updateItem(itemId: number, quantity: number) {
    return api.patch<Cart>('/cart/items/' + itemId, { quantity }).then((r) => r.data);
  },
  removeItem(itemId: number) {
    return api.delete<Cart>('/cart/items/' + itemId).then((r) => r.data);
  },
};
