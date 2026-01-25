'use client';

import { useState } from 'react';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { motion, AnimatePresence } from 'framer-motion';
import { Header } from '@/components/common/header';
import {
    ArrowLeft, ArrowRight, CreditCard, Truck, ShieldCheck,
    MapPin, ChevronRight, Minus, Plus, Trash2, ShoppingBag, Ticket
} from 'lucide-react';

// Mock cart data
const MOCK_CART = [
    { id: 1, name: 'Lumina No. 01', price: 5900000, quantity: 1, image: '/luxury_perfume_hero_cinematic.png', type: '100ml Extrait' },
    { id: 2, name: 'Oud Mystère', price: 8500000, quantity: 1, image: '/luxury_ai_scent_lab.png', type: '50ml Parfum' },
];

export default function CheckoutPage() {
    const [step, setStep] = useState(1);
    const [cartItems, setCartItems] = useState(MOCK_CART);

    const subtotal = cartItems.reduce((acc, item) => acc + (item.price * item.quantity), 0);
    const shipping = 0; // Free shipping
    const tax = subtotal * 0.1;
    const total = subtotal + shipping + tax;

    const updateQuantity = (id: number, delta: number) => {
        setCartItems(items =>
            items.map(item =>
                item.id === id
                    ? { ...item, quantity: Math.max(1, item.quantity + delta) }
                    : item
            )
        );
    };

    const removeItem = (id: number) => {
        setCartItems(items => items.filter(item => item.id !== id));
    };

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Header />

            <main className="container mx-auto px-6 py-32 lg:py-40">
                <div className="max-w-7xl mx-auto">
                    <div className="flex flex-col lg:flex-row justify-between items-start gap-16 lg:gap-24">
                        {/* Main Checkout Flow */}
                        <div className="flex-1 w-full order-2 lg:order-1">
                            <Link
                                href="/cart"
                                className="inline-flex items-center gap-3 text-[10px] font-bold tracking-[.4em] uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors mb-16 group"
                            >
                                <ArrowLeft size={16} className="group-hover:-translate-x-2 transition-transform" />
                                Back to Cart
                            </Link>

                            <h1 className="text-5xl md:text-7xl font-serif text-luxury-black dark:text-white mb-16 tracking-tighter">
                                Check<span className="italic">out</span>
                            </h1>

                            {/* Progress Steps */}
                            <div className="flex items-center gap-8 mb-20 overflow-x-auto pb-4">
                                {[
                                    { id: 1, name: 'Shipping Info', icon: MapPin },
                                    { id: 2, name: 'Delivery Method', icon: Truck },
                                    { id: 3, name: 'Payment', icon: CreditCard }
                                ].map((s) => (
                                    <div key={s.id} className="flex items-center gap-6 flex-shrink-0">
                                        <div
                                            onClick={() => step > s.id && setStep(s.id)}
                                            className={`p-4 pl-6 pr-8 rounded-full flex items-center gap-4 transition-all cursor-pointer ${step >= s.id
                                                    ? 'bg-luxury-black dark:bg-gold text-white shadow-2xl'
                                                    : 'bg-white dark:bg-white/5 text-stone-300 border border-stone-100 dark:border-white/5'
                                                }`}
                                        >
                                            <s.icon size={18} />
                                            <span className="text-[10px] font-bold tracking-[.2em] uppercase whitespace-nowrap">
                                                {s.name}
                                            </span>
                                        </div>
                                        {s.id < 3 && <ChevronRight size={14} className="text-stone-300" />}
                                    </div>
                                ))}
                            </div>

                            <AnimatePresence mode="wait">
                                {/* Step 1: Shipping Information */}
                                {step === 1 && (
                                    <motion.div
                                        key="step1"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-12"
                                    >
                                        <div className="grid md:grid-cols-2 gap-10">
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                    First Name
                                                </label>
                                                <input
                                                    type="text"
                                                    className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                    placeholder="Alexander"
                                                />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                    Last Name
                                                </label>
                                                <input
                                                    type="text"
                                                    className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                    placeholder="Dupont"
                                                />
                                            </div>
                                        </div>

                                        <div className="space-y-3">
                                            <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                Email Address
                                            </label>
                                            <input
                                                type="email"
                                                className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                placeholder="alexander@auraai.com"
                                            />
                                        </div>

                                        <div className="space-y-3">
                                            <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                Shipping Address
                                            </label>
                                            <input
                                                type="text"
                                                className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                placeholder="123 Nguyen Hue, District 1"
                                            />
                                        </div>

                                        <div className="grid md:grid-cols-3 gap-10">
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                    City
                                                </label>
                                                <input
                                                    type="text"
                                                    className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                    placeholder="Ho Chi Minh"
                                                />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                    Postal Code
                                                </label>
                                                <input
                                                    type="text"
                                                    className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm font-mono text-luxury-black dark:text-white"
                                                    placeholder="700000"
                                                />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                    Country
                                                </label>
                                                <select className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm appearance-none cursor-pointer text-luxury-black dark:text-white">
                                                    <option>Vietnam</option>
                                                    <option>Singapore</option>
                                                    <option>Thailand</option>
                                                </select>
                                            </div>
                                        </div>

                                        <button
                                            onClick={() => setStep(2)}
                                            className="w-full py-6 bg-luxury-black dark:bg-gold text-white rounded-full font-bold tracking-[.4em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-gold/80 transition-all group"
                                        >
                                            Continue to Shipping
                                            <ArrowRight size={16} className="inline ml-4 group-hover:translate-x-2 transition-transform" />
                                        </button>
                                    </motion.div>
                                )}

                                {/* Step 2: Delivery Method */}
                                {step === 2 && (
                                    <motion.div
                                        key="step2"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-8"
                                    >
                                        {[
                                            { id: 'ghn', name: 'GHN Express', time: '2-3 Days', price: 0, desc: 'Standard shipping' },
                                            { id: 'ghtk', name: 'GHTK Premium', time: '1-2 Days', price: 50000, desc: 'Climate-controlled' },
                                            { id: 'vtp', name: 'VTP International', time: '3-5 Days', price: 100000, desc: 'Fully insured' }
                                        ].map((method) => (
                                            <div
                                                key={method.id}
                                                className="p-8 rounded-[3rem] border border-stone-100 dark:border-white/5 bg-white dark:bg-zinc-900 flex items-center justify-between cursor-pointer hover:border-gold transition-all group shadow-sm hover:shadow-xl"
                                            >
                                                <div className="flex items-center gap-8">
                                                    <div className="w-8 h-8 rounded-full border-2 border-stone-200 dark:border-white/10 flex items-center justify-center p-1.5 group-hover:border-gold transition-colors">
                                                        <div className="w-full h-full rounded-full bg-gold scale-0 group-hover:scale-100 transition-transform" />
                                                    </div>
                                                    <div>
                                                        <h4 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-widest">
                                                            {method.name}
                                                        </h4>
                                                        <p className="text-[10px] text-stone-400 mt-2 uppercase tracking-tighter">
                                                            {method.time} • {method.desc}
                                                        </p>
                                                    </div>
                                                </div>
                                                <span className="text-lg font-serif italic text-luxury-black dark:text-white">
                                                    {method.price === 0
                                                        ? 'Free'
                                                        : new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(method.price)
                                                    }
                                                </span>
                                            </div>
                                        ))}

                                        <div className="flex gap-6 pt-12">
                                            <button
                                                onClick={() => setStep(1)}
                                                className="flex-1 py-6 border border-stone-200 dark:border-white/10 rounded-full font-bold tracking-[.3em] uppercase text-[10px] text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all"
                                            >
                                                Back
                                            </button>
                                            <button
                                                onClick={() => setStep(3)}
                                                className="flex-[2] py-6 bg-luxury-black dark:bg-gold text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-gold/80 transition-all group"
                                            >
                                                Continue to Payment
                                                <ArrowRight size={16} className="inline ml-4 group-hover:translate-x-2 transition-transform" />
                                            </button>
                                        </div>
                                    </motion.div>
                                )}

                                {/* Step 3: Payment */}
                                {step === 3 && (
                                    <motion.div
                                        key="step3"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-12"
                                    >
                                        <div className="grid grid-cols-2 gap-8">
                                            <div className="p-10 rounded-[3.5rem] border-2 border-gold bg-gold/5 flex flex-col items-center gap-6 text-center shadow-xl">
                                                <CreditCard className="text-gold" size={40} strokeWidth={1} />
                                                <span className="text-[10px] font-bold tracking-[.4em] uppercase text-luxury-black dark:text-white">
                                                    Credit Card
                                                </span>
                                            </div>
                                            <div className="p-10 rounded-[3.5rem] border border-stone-100 dark:border-white/5 bg-white dark:bg-zinc-900 flex flex-col items-center gap-6 text-center opacity-30 grayscale cursor-not-allowed">
                                                <div className="w-10 h-10 rounded-full bg-stone-200" />
                                                <span className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-400">
                                                    Bank Transfer
                                                </span>
                                            </div>
                                        </div>

                                        <div className="space-y-8 bg-white dark:bg-zinc-900 p-12 rounded-[3.5rem] border border-stone-100 dark:border-white/10 shadow-sm">
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                    Cardholder Name
                                                </label>
                                                <input
                                                    type="text"
                                                    className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                    placeholder="ALEXANDER DUPONT"
                                                />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                    Card Number
                                                </label>
                                                <input
                                                    type="text"
                                                    className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm font-mono tracking-widest text-luxury-black dark:text-white"
                                                    placeholder="•••• •••• •••• 4242"
                                                />
                                            </div>
                                            <div className="grid grid-cols-2 gap-10">
                                                <div className="space-y-3">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                        Expiration
                                                    </label>
                                                    <input
                                                        type="text"
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                        placeholder="MM / YY"
                                                    />
                                                </div>
                                                <div className="space-y-3">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">
                                                        CVV
                                                    </label>
                                                    <input
                                                        type="text"
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                        placeholder="•••"
                                                    />
                                                </div>
                                            </div>
                                        </div>

                                        <div className="flex gap-6">
                                            <button
                                                onClick={() => setStep(2)}
                                                className="flex-1 py-6 border border-stone-200 dark:border-white/10 rounded-full font-bold tracking-[.3em] uppercase text-[10px] text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all shadow-sm"
                                            >
                                                Back
                                            </button>
                                            <button className="flex-[2] py-6 bg-luxury-black dark:bg-gold text-white rounded-full font-bold tracking-[.4em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-gold/80 transition-all flex items-center justify-center gap-4 group">
                                                Complete Purchase
                                                <ShieldCheck size={18} className="group-hover:scale-110 transition-transform" />
                                            </button>
                                        </div>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>

                        {/* Order Summary Sidebar */}
                        <div className="w-full lg:w-[450px] sticky top-40 order-1 lg:order-2">
                            <div className="bg-white dark:bg-zinc-900 rounded-[4rem] p-12 border border-stone-100 dark:border-white/5 shadow-2xl">
                                <h3 className="text-2xl font-serif text-luxury-black dark:text-white uppercase tracking-[.2em] mb-12 pb-8 border-b border-stone-100 dark:border-white/5 italic">
                                    Order Summary
                                </h3>

                                <div className="space-y-10 mb-12 max-h-[50vh] overflow-y-auto">
                                    {cartItems.length > 0 ? (
                                        cartItems.map((item) => (
                                            <div key={item.id} className="flex gap-6 group">
                                                <div className="relative w-24 h-32 rounded-2xl overflow-hidden bg-stone-50 dark:bg-zinc-800 flex-shrink-0 border border-stone-100 dark:border-white/5">
                                                    <Image
                                                        src={item.image}
                                                        alt={item.name}
                                                        fill
                                                        className="object-cover group-hover:scale-110 transition-transform duration-700"
                                                    />
                                                </div>
                                                <div className="flex-1">
                                                    <div className="flex justify-between items-start mb-2">
                                                        <h4 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-wider">
                                                            {item.name}
                                                        </h4>
                                                        <span className="text-sm font-medium text-luxury-black dark:text-white">
                                                            {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.price * item.quantity)}
                                                        </span>
                                                    </div>
                                                    <p className="text-[10px] text-stone-400 uppercase tracking-widest italic mb-6">
                                                        {item.type}
                                                    </p>

                                                    <div className="flex items-center justify-between">
                                                        <div className="flex items-center gap-4 bg-stone-50 dark:bg-white/5 px-3 py-1.5 rounded-full border border-stone-100 dark:border-white/5">
                                                            <button
                                                                onClick={() => updateQuantity(item.id, -1)}
                                                                className="text-stone-300 hover:text-luxury-black dark:hover:text-white transition-colors"
                                                            >
                                                                <Minus size={12} />
                                                            </button>
                                                            <span className="text-[10px] font-bold w-4 text-center dark:text-white">
                                                                {item.quantity}
                                                            </span>
                                                            <button
                                                                onClick={() => updateQuantity(item.id, 1)}
                                                                className="text-stone-300 hover:text-luxury-black dark:hover:text-white transition-colors"
                                                            >
                                                                <Plus size={12} />
                                                            </button>
                                                        </div>
                                                        <button
                                                            onClick={() => removeItem(item.id)}
                                                            className="text-stone-300 hover:text-red-500 transition-colors opacity-0 group-hover:opacity-100"
                                                        >
                                                            <Trash2 size={16} />
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        ))
                                    ) : (
                                        <div className="py-20 text-center space-y-4 opacity-30">
                                            <ShoppingBag size={48} strokeWidth={1} />
                                            <p className="text-[10px] font-bold tracking-widest uppercase italic">
                                                Cart is Empty
                                            </p>
                                        </div>
                                    )}
                                </div>

                                <div className="space-y-6 pt-12 border-t border-stone-100 dark:border-white/5">
                                    <div className="flex items-center gap-4 mb-8 p-5 bg-stone-50 dark:bg-white/5 rounded-3xl border border-dashed border-stone-200 dark:border-white/20">
                                        <Ticket size={18} className="text-stone-400" />
                                        <input
                                            type="text"
                                            placeholder="Promo Code"
                                            className="bg-transparent text-[10px] uppercase font-bold tracking-[.3em] outline-none flex-1 placeholder:text-stone-300 text-luxury-black dark:text-white"
                                        />
                                        <button className="text-[10px] font-bold text-gold uppercase tracking-widest hover:text-yellow-600 transition-colors">
                                            Apply
                                        </button>
                                    </div>

                                    <div className="space-y-4">
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>Subtotal</span>
                                            <span className="text-luxury-black dark:text-white">
                                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                                            </span>
                                        </div>
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>Shipping</span>
                                            <span className="text-gold">Free</span>
                                        </div>
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>Tax (10%)</span>
                                            <span className="text-luxury-black dark:text-white">
                                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(tax)}
                                            </span>
                                        </div>
                                    </div>

                                    <div className="pt-8 mt-6 flex justify-between items-center border-t border-stone-100 dark:border-white/10">
                                        <span className="text-[10px] font-bold tracking-[.5em] uppercase text-stone-400">
                                            Total
                                        </span>
                                        <span className="text-4xl font-serif text-luxury-black dark:text-white italic">
                                            {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total)}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
