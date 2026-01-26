import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface CartItem {
    id: string;
    productId: string;
    name: string;
    price: number;
    image: string;
    quantity: number;
    size: string;
    brand: string;
}

interface CartState {
    items: CartItem[];
    addItem: (item: CartItem) => void;
    removeItem: (productId: string, size: string) => void;
    updateQuantity: (productId: string, size: string, quantity: number) => void;
    clearCart: () => void;
    getTotal: () => number;
    getItemCount: () => number;
}

export const useCartStore = create<CartState>()(
    persist(
        (set, get) => ({
            items: [],
            addItem: (item) => {
                const currentItems = get().items;
                const existingItem = currentItems.find(
                    (i) => i.productId === item.productId && i.size === item.size
                );

                if (existingItem) {
                    set({
                        items: currentItems.map((i) =>
                            i.productId === item.productId && i.size === item.size
                                ? { ...i, quantity: i.quantity + item.quantity }
                                : i
                        ),
                    });
                } else {
                    set({ items: [...currentItems, item] });
                }
            },
            removeItem: (productId, size) => {
                set({
                    items: get().items.filter(
                        (i) => !(i.productId === productId && i.size === size)
                    ),
                });
            },
            updateQuantity: (productId, size, quantity) => {
                set({
                    items: get().items.map((i) =>
                        i.productId === productId && i.size === size
                            ? { ...i, quantity: Math.max(1, quantity) }
                            : i
                    ),
                });
            },
            clearCart: () => set({ items: [] }),
            getTotal: () => {
                return get().items.reduce(
                    (total, item) => total + item.price * item.quantity,
                    0
                );
            },
            getItemCount: () => {
                return get().items.reduce((count, item) => count + item.quantity, 0);
            },
        }),
        {
            name: 'aura-cart-storage',
        }
    )
);
