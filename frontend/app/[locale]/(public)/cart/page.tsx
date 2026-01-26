'use client';

import { useState, useEffect } from 'react';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { motion, AnimatePresence } from 'framer-motion';
import { Trash2, ArrowRight, ShieldCheck, Truck, RotateCcw, ShoppingBag } from 'lucide-react';
import { Header } from '@/components/common/header';
import { useCartStore } from '@/store/cart.store';

export default function CartPage() {
    const { items: cartItems, updateQuantity, removeItem, getTotal } = useCartStore();
    const [isMounted, setIsMounted] = useState(false);

    useEffect(() => {
        setIsMounted(true);
    }, []);

    const subtotal = getTotal();

    if (!isMounted) return null;

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Header />

            <main className="container mx-auto px-6 py-32">
                <div className="flex items-center gap-4 mb-12">
                    <h1 className="text-4xl md:text-5xl font-serif text-luxury-black dark:text-white transition-colors">
                        Your Collection
                    </h1>
                    <span className="px-4 py-1.5 glass rounded-full text-[10px] font-bold tracking-widest text-gold border border-gold/10">
                        {cartItems.length} Essences
                    </span>
                </div>

                {cartItems.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-40 glass rounded-[4rem] border-dashed border-2 border-stone-200 dark:border-white/5 space-y-8">
                        <div className="w-24 h-24 rounded-full bg-stone-50 dark:bg-zinc-900 flex items-center justify-center text-stone-200 dark:text-white/5">
                            <ShoppingBag size={48} />
                        </div>
                        <div className="text-center">
                            <h2 className="text-2xl font-serif text-luxury-black dark:text-white mb-2">The collection is currently empty</h2>
                            <p className="text-stone-400 text-sm uppercase tracking-widest leading-relaxed">Your olfactory journey awaits inspiration</p>
                        </div>
                        <Link
                            href="/collection"
                            className="bg-luxury-black dark:bg-gold text-white px-12 py-5 rounded-full font-bold tracking-widest uppercase text-[10px] shadow-xl hover:scale-105 transition-all"
                        >
                            Explore Collection
                        </Link>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-16">
                        {/* Cart Items List */}
                        <div className="lg:col-span-2 space-y-8">
                            <AnimatePresence mode="popLayout">
                                {cartItems.map((item) => (
                                    <motion.div
                                        key={`${item.productId}-${item.size}`}
                                        layout
                                        initial={{ opacity: 0, scale: 0.95 }}
                                        animate={{ opacity: 1, scale: 1 }}
                                        exit={{ opacity: 0, scale: 0.95 }}
                                        className="flex flex-col sm:flex-row gap-8 p-8 glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-100 dark:border-white/10 shadow-sm items-center transition-colors relative"
                                    >
                                        {/* Product Image */}
                                        <div className="relative w-32 h-32 rounded-2xl overflow-hidden bg-stone-100 dark:bg-stone-800 flex-shrink-0 transition-colors">
                                            <Image
                                                src={item.image}
                                                alt={item.name}
                                                fill
                                                className="object-cover"
                                            />
                                        </div>

                                        {/* Product Info */}
                                        <div className="flex-1 text-center sm:text-left">
                                            <p className="text-[9px] text-gold font-bold uppercase tracking-[0.3em] mb-1">{item.brand}</p>
                                            <h3 className="text-xl font-serif text-luxury-black dark:text-white mb-1 transition-colors">
                                                {item.name}
                                            </h3>
                                            <p className="text-xs text-stone-400 mb-6 uppercase tracking-widest">
                                                {item.size} • Extrait de Parfum
                                            </p>

                                            {/* Quantity & Remove */}
                                            <div className="flex items-center justify-center sm:justify-start gap-8">
                                                <div className="flex items-center gap-6 bg-stone-50 dark:bg-zinc-800 px-6 py-2.5 rounded-full border border-stone-100 dark:border-white/10 transition-colors">
                                                    <button
                                                        onClick={() => updateQuantity(item.productId, item.size, item.quantity - 1)}
                                                        className="text-stone-400 hover:text-gold transition-colors"
                                                    >
                                                        <Minus size={14} />
                                                    </button>
                                                    <span className="text-xs font-bold text-luxury-black dark:text-white w-4 text-center">
                                                        {item.quantity}
                                                    </span>
                                                    <button
                                                        onClick={() => updateQuantity(item.productId, item.size, item.quantity + 1)}
                                                        className="text-stone-400 hover:text-gold transition-colors"
                                                    >
                                                        <Plus size={14} />
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        {/* Price & Actions */}
                                        <div className="flex flex-col items-center sm:items-end gap-4">
                                            <div className="text-xl font-serif text-luxury-black dark:text-stone-100 transition-colors">
                                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.price * item.quantity)}
                                            </div>
                                            <button
                                                onClick={() => removeItem(item.productId, item.size)}
                                                className="text-stone-300 hover:text-red-500 transition-colors p-2"
                                            >
                                                <Trash2 size={18} />
                                            </button>
                                        </div>
                                    </motion.div>
                                ))}
                            </AnimatePresence>

                            {/* Guarantees */}
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-12">
                                {[
                                    { icon: Truck, title: 'White-Glove Delivery', desc: 'Complimentary on all orders.' },
                                    { icon: ShieldCheck, title: 'Authenticity Guaranteed', desc: 'Sealed with our digital seal.' },
                                    { icon: RotateCcw, title: 'Refill Service', desc: 'Sustainability in every bottle.' }
                                ].map((g, i) => (
                                    <div
                                        key={i}
                                        className="flex flex-col items-center text-center p-8 bg-white/40 dark:bg-zinc-900/40 rounded-[2rem] border border-transparent hover:border-gold/10 transition-all duration-500"
                                    >
                                        <g.icon className="text-gold mb-4" size={24} strokeWidth={1} />
                                        <h5 className="text-[10px] font-bold tracking-widest uppercase mb-3 text-luxury-black dark:text-white">
                                            {g.title}
                                        </h5>
                                        <p className="text-[10px] text-stone-400 leading-relaxed uppercase tracking-tighter max-w-[150px]">
                                            {g.desc}
                                        </p>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Order Summary */}
                        <div className="lg:col-span-1">
                            <div className="glass bg-white dark:bg-zinc-900 p-12 rounded-[3rem] border border-stone-100 dark:border-white/10 shadow-xl sticky top-32 transition-colors">
                                <h2 className="text-3xl font-serif text-luxury-black dark:text-white mb-10 italic">
                                    Summary
                                </h2>

                                <div className="space-y-6 mb-10">
                                    <div className="flex justify-between text-sm">
                                        <span className="text-stone-400 uppercase tracking-[0.2em] text-[10px] font-bold">
                                            Subtotal
                                        </span>
                                        <span className="font-medium font-serif text-luxury-black dark:text-white text-lg">
                                            {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                                        </span>
                                    </div>
                                    <div className="flex justify-between text-sm">
                                        <span className="text-stone-400 uppercase tracking-[0.2em] text-[10px] font-bold">
                                            Shipping
                                        </span>
                                        <span className="text-gold text-[10px] font-bold uppercase tracking-widest">
                                            Complimentary
                                        </span>
                                    </div>
                                    <div className="h-px bg-stone-100 dark:bg-stone-800 my-4 transition-colors" />
                                    <div className="flex justify-between items-baseline">
                                        <span className="text-luxury-black dark:text-white font-bold uppercase tracking-widest text-xs">
                                            Total
                                        </span>
                                        <span className="text-4xl font-serif text-luxury-black dark:text-white">
                                            {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                                        </span>
                                    </div>
                                </div>

                                <div className="space-y-6">
                                    <Link
                                        href="/checkout"
                                        className="block w-full bg-luxury-black dark:bg-gold text-white py-6 rounded-full font-bold tracking-[0.3em] uppercase text-[10px] flex items-center justify-center gap-4 hover:bg-stone-800 dark:hover:bg-gold/80 transition-all shadow-2xl active:scale-[0.98]"
                                    >
                                        Proceed to Checkout <ArrowRight size={18} />
                                    </Link>
                                    <Link
                                        href="/collection"
                                        className="block w-full border border-stone-200 dark:border-white/10 text-stone-400 dark:text-stone-500 py-6 rounded-full font-bold tracking-[0.3em] uppercase text-center text-[10px] hover:border-luxury-black dark:hover:border-white hover:text-luxury-black dark:hover:text-white transition-all"
                                    >
                                        Back to Collection
                                    </Link>
                                </div>

                                <div className="mt-12 text-center">
                                    <p className="text-[9px] text-stone-400 uppercase tracking-[0.4em] leading-relaxed">
                                        SECURE TRANSACTION ENCRYPTED BY <br />
                                        <span className="text-gold font-bold">AURA NEURAL NETWORK</span>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
}

import { Plus, Minus } from 'lucide-react';
