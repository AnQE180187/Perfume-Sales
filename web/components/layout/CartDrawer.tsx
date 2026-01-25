"use client";

import React from "react";
import Image from "next/image";
import { motion, AnimatePresence } from "framer-motion";
import { Link } from "@/i18n/routing";
import { X, Minus, Plus, ShoppingBag, ArrowRight, Trash2 } from "lucide-react";
import { useCart } from "@/features/cart/CartContext";
import { useTranslations } from "next-intl";

interface CartDrawerProps {
    isOpen: boolean;
    onClose: () => void;
}

export const CartDrawer = ({ isOpen, onClose }: CartDrawerProps) => {
    const t = useTranslations("Cart");
    const { cartItems, removeFromCart, updateQuantity, cartTotal, loading } = useCart();

    const handleUpdateQuantity = async (id: string, currentQuantity: number, delta: number) => {
        const newQuantity = currentQuantity + delta;
        if (newQuantity > 0) {
            await updateQuantity(id, newQuantity);
        } else {
            await removeFromCart(id);
        }
    };


    return (
        <AnimatePresence>
            {isOpen && (
                <>
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[100]"
                    />
                    <motion.div
                        initial={{ x: "100%" }}
                        animate={{ x: 0 }}
                        exit={{ x: "100%" }}
                        transition={{ type: "spring", damping: 25, stiffness: 200 }}
                        className="fixed top-0 right-0 h-full w-full max-w-md bg-white dark:bg-zinc-950 z-[101] shadow-2xl flex flex-col transition-colors"
                    >
                        {/* Header */}
                        <div className="p-8 border-b border-stone-100 dark:border-white/5 flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <ShoppingBag size={20} className="text-accent" />
                                <h2 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest">{t("title")}</h2>
                            </div>
                            <button
                                onClick={onClose}
                                className="p-2 hover:bg-stone-50 dark:hover:bg-white/5 rounded-full transition-colors text-stone-400 hover:text-luxury-black dark:hover:text-white cursor-pointer"
                            >
                                <X size={24} />
                            </button>
                        </div>

                        {/* Items */}
                        <div className="flex-1 overflow-y-auto p-8 space-y-8 scrollbar-hide">
                            <AnimatePresence mode="popLayout">
                                {loading ? (
                                    <div className="h-full flex flex-col items-center justify-center text-center space-y-6 opacity-40 py-20">
                                        <p className="text-[10px] font-bold tracking-[.3em] uppercase">Loading cart...</p>
                                    </div>
                                ) : cartItems.length > 0 ? (
                                    cartItems.map((item) => (
                                        <motion.div
                                            key={item.id}
                                            layout
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            exit={{ opacity: 0, scale: 0.95 }}
                                            className="flex gap-6 group"
                                        >
                                            <div className="relative w-24 h-32 rounded-2xl overflow-hidden bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 transition-colors">
                                                <Image src={item.product.images.length > 0 ? item.product.images[0].url : ''} alt={item.product.name} fill className="object-cover group-hover:scale-110 transition-transform duration-500" />
                                            </div>
                                            <div className="flex-1 py-1">
                                                <div className="flex justify-between mb-2">
                                                    <h3 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-wider">{item.product.name}</h3>
                                                    <span className="text-sm font-medium text-luxury-black dark:text-white">
                                                        {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.product.price * item.quantity)}
                                                    </span>
                                                </div>

                                                <div className="flex items-center justify-between">
                                                    <div className="flex items-center gap-4 bg-stone-50 dark:bg-white/5 px-3 py-1.5 rounded-full border border-stone-100 dark:border-white/5 transition-colors">
                                                        <button
                                                            onClick={() => handleUpdateQuantity(item.id, item.quantity, -1)}
                                                            className="text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors cursor-pointer"
                                                            disabled={item.quantity <= 1}
                                                        >
                                                            <Minus size={14} />
                                                        </button>
                                                        <span className="text-[10px] font-bold w-4 text-center dark:text-white">{item.quantity}</span>
                                                        <button
                                                            onClick={() => handleUpdateQuantity(item.id, item.quantity, 1)}
                                                            className="text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors cursor-pointer"
                                                        >
                                                            <Plus size={14} />
</button>
                                                    </div>
                                                    <button
                                                        onClick={() => removeFromCart(item.id)}
                                                        className="flex items-center gap-2 text-[9px] font-bold tracking-widest uppercase text-stone-400 hover:text-red-500 transition-colors group cursor-pointer"
                                                    >
                                                        <Trash2 size={12} className="group-hover:rotate-12 transition-transform" />
                                                        {t("remove")}
                                                    </button>
                                                </div>
                                            </div>
                                        </motion.div>
                                    ))
                                ) : (
                                    <div className="h-full flex flex-col items-center justify-center text-center space-y-6 opacity-40 py-20">
                                        <ShoppingBag size={48} strokeWidth={1} />
                                        <p className="text-[10px] font-bold tracking-[.3em] uppercase">{t("empty")}</p>
                                    </div>
                                )}
                            </AnimatePresence>
                        </div>

                        {/* Footer */}
                        <div className="p-8 bg-stone-50 dark:bg-zinc-900 border-t border-stone-100 dark:border-white/5 transition-colors space-y-6">
                            <div className="flex justify-between items-center">
                                <span className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-400">{t("total")}</span>
                                <span className="text-2xl font-serif text-luxury-black dark:text-white transition-all">
                                    {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(cartTotal)}
                                </span>
                            </div>
                            <div className="space-y-3">
                                <Link
                                    href={cartItems.length > 0 ? "/checkout" : "#"}
                                    onClick={cartItems.length > 0 ? onClose : (e) => e.preventDefault()}
                                    className={`w-full py-5 rounded-full font-bold tracking-[.3em] uppercase text-[10px] transition-all shadow-xl flex items-center justify-center gap-3 ${cartItems.length > 0
                                        ? "bg-luxury-black dark:bg-accent text-white hover:bg-stone-800 dark:hover:bg-accent/80"
                                        : "bg-stone-200 dark:bg-white/5 text-stone-400 cursor-not-allowed shadow-none"
                                        }`}
                                >
                                    {t("checkout")} <ArrowRight size={16} />
                                </Link>
                                <p className="text-[9px] text-stone-400 text-center uppercase tracking-tighter">
                                    {t("shipping_note")}
                                </p>
                            </div>
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
};
