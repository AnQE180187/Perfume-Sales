"use client";

import React from "react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { motion } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { Trash2, ArrowRight, ShieldCheck, Truck, RotateCcw } from "lucide-react";

export default function CartPage() {
    const cartItems = [
        { id: 1, name: "Lumina No. 01", price: 240, size: "100ml", quantity: 1, image: "/images/hero.png" },
        { id: 2, name: "Oud Mystère", price: 380, size: "50ml", quantity: 1, image: "/images/hero.png" }
    ];

    const subtotal = cartItems.reduce((acc, item) => acc + (item.price * item.quantity), 0);

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Navbar />

            <main className="container mx-auto px-6 py-32">
                <h1 className="text-4xl md:text-5xl font-serif text-luxury-black dark:text-white mb-12 transition-colors">Your Collection</h1>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-16">
                    {/* Cart List */}
                    <div className="lg:col-span-2 space-y-8">
                        {cartItems.map((item) => (
                            <motion.div
                                key={item.id}
                                layout
                                className="flex flex-col sm:flex-row gap-8 p-8 glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-100 dark:border-white/10 shadow-sm items-center transition-colors"
                            >
                                <div className="relative w-32 h-32 rounded-2xl overflow-hidden bg-stone-100 dark:bg-stone-800 flex-shrink-0 transition-colors">
                                    <Image src={item.image} alt={item.name} fill className="object-cover" />
                                </div>

                                <div className="flex-1 text-center sm:text-left">
                                    <h3 className="text-xl font-serif text-luxury-black dark:text-white mb-1 transition-colors">{item.name}</h3>
                                    <p className="text-sm text-stone-400 mb-4">{item.size} • Extrait de Parfum</p>

                                    <div className="flex items-center justify-center sm:justify-start gap-6">
                                        <div className="flex items-center gap-4 bg-stone-50 dark:bg-stone-800 px-4 py-2 rounded-full border border-stone-100 dark:border-white/10 transition-colors">
                                            <button className="text-stone-400 hover:text-luxury-black dark:hover:text-white text-xs font-bold">-</button>
                                            <span className="text-xs font-bold text-stone-900 dark:text-stone-100">{item.quantity}</span>
                                            <button className="text-stone-400 hover:text-luxury-black dark:hover:text-white text-xs font-bold">+</button>
                                        </div>
                                        <button className="text-stone-300 hover:text-red-500 transition-colors">
                                            <Trash2 size={18} />
                                        </button>
                                    </div>
                                </div>

                                <div className="text-xl font-medium text-luxury-black dark:text-stone-100 transition-colors">
                                    ${item.price.toFixed(2)}
                                </div>
                            </motion.div>
                        ))}

                        {/* Guarantees */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-8">
                            {[
                                { icon: Truck, title: "White-Glove Delivery", desc: "Complimentary on all orders." },
                                { icon: ShieldCheck, title: "Authenticity Guaranteed", desc: "Sealed with our digital seal." },
                                { icon: RotateCcw, title: "Refill Service", desc: "Sustainability in every bottle." }
                            ].map((g, i) => (
                                <div key={i} className="flex flex-col items-center text-center p-6 bg-white/40 dark:bg-zinc-900/40 rounded-3xl transition-colors">
                                    <g.icon className="text-accent mb-4" size={24} strokeWidth={1} />
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase mb-2 text-luxury-black dark:text-white">{g.title}</h5>
                                    <p className="text-[10px] text-stone-400 leading-relaxed uppercase tracking-tighter">{g.desc}</p>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Summary */}
                    <div className="lg:col-span-1">
                        <div className="glass bg-white dark:bg-zinc-900 p-10 rounded-[2.5rem] border border-stone-100 dark:border-white/10 shadow-xl sticky top-32 transition-colors">
                            <h2 className="text-2xl font-serif text-luxury-black dark:text-white mb-8">Summary</h2>

                            <div className="space-y-4 mb-8">
                                <div className="flex justify-between text-sm">
                                    <span className="text-stone-400 uppercase tracking-widest text-[10px] font-bold">Subtotal</span>
                                    <span className="font-medium font-serif">${subtotal.toFixed(2)}</span>
                                </div>
                                <div className="flex justify-between text-sm">
                                    <span className="text-stone-400 uppercase tracking-widest text-[10px] font-bold">Shipping</span>
                                    <span className="text-accent text-[10px] font-bold uppercase tracking-widest">Complimentary</span>
                                </div>
                                <div className="h-px bg-stone-100 dark:bg-stone-800 my-4 transition-colors" />
                                <div className="flex justify-between items-baseline">
                                    <span className="text-luxury-black dark:text-white font-bold uppercase tracking-widest text-xs">Total</span>
                                    <span className="text-3xl font-serif text-luxury-black dark:text-white">${subtotal.toFixed(2)}</span>
                                </div>
                            </div>

                            <div className="space-y-4">
                                <button className="w-full bg-luxury-black dark:bg-accent text-white py-5 rounded-full font-bold tracking-widest uppercase flex items-center justify-center gap-3 hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-xl">
                                    Proceed to Checkout <ArrowRight size={18} />
                                </button>
                                <Link href="/collection" className="block w-full border border-stone-200 dark:border-stone-800 text-stone-400 dark:text-stone-500 py-5 rounded-full font-bold tracking-widest uppercase text-center text-xs hover:border-luxury-black dark:hover:border-white hover:text-luxury-black dark:hover:text-white transition-all">
                                    Continue Shopping
                                </Link>
                            </div>

                            <div className="mt-8 text-center">
                                <p className="text-[10px] text-stone-400 uppercase tracking-widest leading-relaxed">
                                    SECURE CHECKOUT POWERED BY <br />
                                    <span className="text-luxury-black dark:text-white font-bold">LUMINA INTELLIGENCE</span>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
