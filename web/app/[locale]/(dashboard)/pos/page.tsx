"use client";

import React, { useState } from "react";
import Image from "next/image";
import { motion, AnimatePresence } from "framer-motion";
import {
    Search,
    ScanLine,
    User,
    CreditCard,
    Banknote,
    Minus,
    Plus,
    Trash2,
    Sparkles,
    ChevronRight,
    CheckCircle2,
    X
} from "lucide-react";

interface POSItem {
    id: string;
    name: string;
    price: number;
    quantity: number;
    sku: string;
}

export default function POSPage() {
    const [cart, setCart] = useState<POSItem[]>([
        { id: "1", name: "Lumina No. 01", price: 240, quantity: 1, sku: "LMN-001" },
        { id: "2", name: "Oud Mystère", price: 380, quantity: 1, sku: "LMN-008" }
    ]);
    const [paymentModal, setPaymentModal] = useState(false);

    const subtotal = cart.reduce((acc, item) => acc + item.price * item.quantity, 0);
    const tax = subtotal * 0.1;
    const total = subtotal + tax;

    return (
        <div className="flex h-[calc(100vh-8rem)] gap-8 overflow-hidden">
            {/* Left: Product Selection & Search */}
            <div className="flex-[2] flex flex-col gap-8 overflow-hidden">
                <div className="flex gap-4">
                    <div className="relative flex-1 group">
                        <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300 dark:text-stone-700 group-focus-within:text-accent transition-colors" size={20} />
                        <input
                            type="text"
                            placeholder="Scan barcode or manual search..."
                            className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 focus:border-accent rounded-2xl py-5 pl-16 pr-6 text-sm outline-none transition-all shadow-sm"
                        />
                    </div>
                    <button className="px-8 py-5 bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl text-accent hover:bg-accent hover:text-white transition-all flex items-center gap-3">
                        <ScanLine size={20} />
                        <span className="text-[10px] font-bold tracking-widest uppercase">Scanner</span>
                    </button>
                </div>

                <div className="flex-1 overflow-y-auto pr-4 scrollbar-hide">
                    <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-6 pb-8">
                        {[
                            { name: "Lumina No. 01", price: 240, stock: 142 },
                            { name: "Oud Mystère", price: 380, stock: 12 },
                            { name: "Santal Bloom", price: 195, stock: 45 },
                            { name: "Amber Noir", price: 290, stock: 85 },
                            { name: "Bergamot Sky", price: 180, stock: 210 },
                            { name: "Velvet Jasmine", price: 310, stock: 32 },
                            { name: "Midnight Rain", price: 220, stock: 15 },
                            { name: "White Petals", price: 165, stock: 110 }
                        ].map((p, i) => (
                            <motion.button
                                key={i}
                                initial={{ opacity: 0, scale: 0.95 }}
                                animate={{ opacity: 1, scale: 1 }}
                                transition={{ delay: i * 0.05 }}
                                className="bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-[2.5rem] p-6 text-left hover:shadow-2xl hover:border-accent transition-all group"
                            >
                                <div className="relative aspect-square rounded-2xl overflow-hidden mb-6 bg-stone-50 dark:bg-white/5">
                                    <Image src="/images/hero.png" alt={p.name} fill className="object-cover group-hover:scale-110 transition-transform duration-500" />
                                </div>
                                <h4 className="text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white mb-2 line-clamp-1">{p.name}</h4>
                                <div className="flex justify-between items-center">
                                    <span className="text-sm font-medium text-accent">${p.price}</span>
                                    <span className="text-[9px] text-stone-400 uppercase tracking-tighter">{p.stock} in stock</span>
                                </div>
                            </motion.button>
                        ))}
                    </div>
                </div>
            </div>

            {/* Right: Checkout Sidebar */}
            <div className="flex-1 w-full max-w-md bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-100 dark:border-white/5 shadow-2xl flex flex-col overflow-hidden transition-colors">
                {/* User Selector */}
                <div className="p-8 border-b border-stone-100 dark:border-white/5 transition-colors">
                    <button className="w-full flex items-center justify-between p-4 bg-stone-50 dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-2xl group hover:border-accent transition-all">
                        <div className="flex items-center gap-4 text-left">
                            <div className="w-10 h-10 rounded-full bg-accent text-white flex items-center justify-center font-serif text-lg">A</div>
                            <div>
                                <h5 className="text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white">Alexander Dupont</h5>
                                <p className="text-[9px] text-accent uppercase tracking-tighter">L'Héritage Member • 15.4k Pts</p>
                            </div>
                        </div>
                        <ChevronRight size={16} className="text-stone-300 group-hover:text-accent transition-all" />
                    </button>
                    <div className="mt-6 p-4 rounded-xl bg-accent/5 border border-accent/10 flex items-center gap-4">
                        <Sparkles size={16} className="text-accent" />
                        <p className="text-[9px] leading-relaxed text-stone-500 uppercase tracking-tighter font-medium italic">
                            AI Suggestion: <span className="text-accent font-bold">Oud Mystère</span> complements his past purchases.
                        </p>
                    </div>
                </div>

                {/* Cart Items */}
                <div className="flex-1 overflow-y-auto p-8 space-y-8 scrollbar-hide">
                    {cart.map((item) => (
                        <div key={item.id} className="flex gap-6 group">
                            <div className="relative w-16 h-20 rounded-xl overflow-hidden bg-stone-50 dark:bg-zinc-800 flex-shrink-0">
                                <Image src="/images/hero.png" alt={item.name} fill className="object-cover" />
                            </div>
                            <div className="flex-1">
                                <div className="flex justify-between mb-2">
                                    <h4 className="text-[10px] font-bold text-luxury-black dark:text-white uppercase tracking-widest">{item.name}</h4>
                                    <span className="text-xs font-medium text-luxury-black dark:text-white">${item.price * item.quantity}</span>
                                </div>
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-4 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-full px-3 py-1">
                                        <button className="text-stone-400 hover:text-luxury-black transition-colors"><Minus size={12} /></button>
                                        <span className="text-[10px] font-bold text-luxury-black dark:text-white">{item.quantity}</span>
                                        <button className="text-stone-400 hover:text-luxury-black transition-colors"><Plus size={12} /></button>
                                    </div>
                                    <button className="text-stone-300 hover:text-red-500 transition-colors opacity-0 group-hover:opacity-100"><Trash2 size={14} /></button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Totals */}
                <div className="p-10 bg-stone-50 dark:bg-white/5 border-t border-stone-100 dark:border-white/5 transition-colors space-y-6">
                    <div className="space-y-3">
                        <div className="flex justify-between text-[10px] font-bold tracking-widest uppercase text-stone-400">
                            <span>Subtotal</span>
                            <span>${subtotal.toFixed(2)}</span>
                        </div>
                        <div className="flex justify-between text-[10px] font-bold tracking-widest uppercase text-stone-400">
                            <span>VAT (10%)</span>
                            <span>${tax.toFixed(2)}</span>
                        </div>
                    </div>
                    <div className="pt-6 border-t border-stone-200 dark:border-white/5 flex justify-between items-center transition-colors">
                        <span className="text-[10px] font-bold tracking-[.3em] uppercase text-luxury-black dark:text-white">Purchase Total</span>
                        <span className="text-4xl font-serif text-luxury-black dark:text-white transition-colors">${total.toFixed(2)}</span>
                    </div>
                    <button
                        onClick={() => setPaymentModal(true)}
                        className="w-full py-5 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all"
                    >
                        Initialize Payment
                    </button>
                </div>
            </div>

            {/* Payment Modal */}
            <AnimatePresence>
                {paymentModal && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-6">
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            onClick={() => setPaymentModal(false)}
                            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
                        />
                        <motion.div
                            initial={{ opacity: 0, scale: 0.9, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            exit={{ opacity: 0, scale: 0.9, y: 20 }}
                            className="relative w-full max-w-2xl bg-white dark:bg-zinc-950 rounded-[4rem] p-12 overflow-hidden shadow-2xl transition-colors"
                        >
                            <button onClick={() => setPaymentModal(false)} className="absolute top-10 right-10 text-stone-400 hover:text-black dark:hover:text-white"><X size={24} /></button>

                            <div className="text-center mb-16">
                                <h2 className="text-4xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">Finalize Requisition</h2>
                                <p className="text-[10px] text-stone-400 font-bold tracking-[.4em] uppercase">Select Payment Protocol</p>
                            </div>

                            <div className="grid grid-cols-2 gap-8 mb-12">
                                <button className="p-10 rounded-[3rem] border-2 border-accent bg-accent/5 flex flex-col items-center gap-6 group hover:shadow-2xl transition-all">
                                    <div className="w-16 h-16 rounded-full bg-accent text-white flex items-center justify-center shadow-lg"><CreditCard size={32} strokeWidth={1} /></div>
                                    <span className="text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white">Credit / POS Terminal</span>
                                </button>
                                <button className="p-10 rounded-[3rem] border border-stone-100 dark:border-white/5 bg-stone-50 dark:bg-white/5 flex flex-col items-center gap-6 group hover:border-accent transition-all">
                                    <div className="w-16 h-16 rounded-full bg-white dark:bg-zinc-800 text-stone-400 group-hover:text-accent flex items-center justify-center transition-colors"><Banknote size={32} strokeWidth={1} /></div>
                                    <span className="text-[10px] font-bold tracking-widest uppercase text-stone-400 group-hover:text-luxury-black transition-colors">Cash Payment</span>
                                </button>
                            </div>

                            <div className="p-8 bg-stone-50 dark:bg-white/5 rounded-[2.5rem] border border-stone-100 dark:border-white/5 mb-12 transition-colors">
                                <div className="flex justify-between items-end">
                                    <div className="space-y-2">
                                        <p className="text-[10px] text-stone-400 font-bold tracking-widest uppercase">Member Reward Integration</p>
                                        <h4 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-wider">Redeem 5,000 Points?</h4>
                                        <p className="text-[9px] text-accent uppercase tracking-tighter">Value: -$5.00 Off current requisition</p>
                                    </div>
                                    <button className="px-6 py-2 bg-luxury-black dark:bg-accent text-white rounded-full text-[9px] font-bold uppercase tracking-widest">Apply Now</button>
                                </div>
                            </div>

                            <button className="w-full py-6 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl flex items-center justify-center gap-4 group">
                                Confirm & Print Receipt <CheckCircle2 size={18} className="group-hover:scale-125 transition-transform" />
                            </button>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>
        </div>
    );
}
