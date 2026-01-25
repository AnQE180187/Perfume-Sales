"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { apiClient } from "@/lib/api-client";
import { useAuth } from "@/features/auth/AuthContext";

interface CartItem {
    id: string;
    productId: string;
    quantity: number;
    product: {
        name: string;
        price: number;
        images: { url: string }[];
    };
}

interface AddToCartPayload {
    productId: string;
    quantity: number;
}

interface CartContextType {
    cartItems: CartItem[];
    addToCart: (item: AddToCartPayload) => Promise<void>;
    removeFromCart: (id: string) => Promise<void>;
    updateQuantity: (id: string, quantity: number) => Promise<void>;
    cartCount: number;
    cartTotal: number;
    clearCart: () => void;
    loading: boolean;
    error: string | null;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

export const CartProvider = ({ children }: { children: React.ReactNode }) => {
    const { user } = useAuth();
    const [cartItems, setCartItems] = useState<CartItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const fetchCart = async () => {
        if (!user) {
            setLoading(false);
            setCartItems([]);
            return;
        }

        setLoading(true);
        try {
            const response = await apiClient.getCart();
            if (response.data) {
                setCartItems(response.data.items || []);
            } else {
                setError(response.error || "Failed to fetch cart.");
                setCartItems([]);
            }
        } catch (err: any) {
            setError(err.message || "An unexpected error occurred.");
            setCartItems([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchCart();
    }, [user]);

    const addToCart = async (payload: AddToCartPayload) => {
        if (!user) {
            // Handle guest cart logic or prompt login
            alert("Please log in to add items to your cart.");
            return;
        }
        try {
            const response = await apiClient.addToCart(payload.productId, payload.quantity);
            if (response.data) {
                await fetchCart(); // Refetch cart to get the updated state
            } else {
                setError(response.error || "Failed to add item to cart.");
            }
        } catch (err: any) {
            setError(err.message || "An unexpected error occurred.");
        }
    };

    const removeFromCart = async (id: string) => {
        try {
            const response = await apiClient.removeCartItem(id);
            if (response.data !== undefined) { // Check for any successful response
                setCartItems(prev => prev.filter(item => item.id !== id));
            } else {
                setError(response.error || "Failed to remove item from cart.");
            }
        } catch (err: any) {
            setError(err.message || "An unexpected error occurred.");
        }
    };

    const updateQuantity = async (id: string, quantity: number) => {
        if (quantity <= 0) {
            await removeFromCart(id);
            return;
        }
        try {
            const response = await apiClient.updateCartItem(id, quantity);
            if (response.data) {
                setCartItems(prev => prev.map(item =>
                    item.id === id ? { ...item, quantity } : item
                ));
            } else {
                setError(response.error || "Failed to update item quantity.");
            }
        } catch (err: any) {
            setError(err.message || "An unexpected error occurred.");
        }
    };

    const clearCart = async () => {
        // This would require a backend endpoint to clear the entire cart
        // For now, we can remove items one by one.
        setLoading(true);
        try {
            await Promise.all(cartItems.map(item => apiClient.removeCartItem(item.id)));
            setCartItems([]);
        } catch (err: any) {
             setError(err.message || "An unexpected error occurred during cart clearing.");
        } finally {
            setLoading(false);
        }
    };

    const cartCount = cartItems.reduce((acc, item) => acc + item.quantity, 0);
    const cartTotal = cartItems.reduce((acc, item) => acc + item.product.price * item.quantity, 0);

    return (
        <CartContext.Provider value={{ cartItems, addToCart, removeFromCart, updateQuantity, cartCount, cartTotal, clearCart, loading, error }}>
            {children}
        </CartContext.Provider>
    );
};

export const useCart = () => {
    const context = useContext(CartContext);
    if (!context) {
        throw new Error("useCart must be used within a CartProvider");
    }
    return context;
};
