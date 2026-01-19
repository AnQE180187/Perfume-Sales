"use client";

import React, { useState } from "react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { motion, AnimatePresence } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { ArrowLeft, ArrowRight, CreditCard, Truck, ShieldCheck, CheckCircle2, ChevronRight, MapPin, Ticket, Minus, Plus, Trash2, ShoppingBag } from "lucide-react";
import { useCart } from "@/features/cart/CartContext";

export default function CheckoutPage() {
    const { cartItems, updateQuantity, removeFromCart, cartTotal } = useCart();
    const [step, setStep] = useState(1);

    const subtotal = cartTotal;
    const shipping = cartItems.length > 0 ? 15 : 0;
    const tax = cartItems.length > 0 ? (subtotal * 0.1) : 0;
    const total = subtotal + shipping + tax;

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Navbar />

            <main className="container mx-auto px-6 py-32 lg:py-40">
                <div className="max-w-7xl mx-auto">
                    <div className="flex flex-col lg:flex-row justify-between items-start gap-16 lg:gap-24">
                        {/* Main Flow */}
                        <div className="flex-1 w-full order-2 lg:order-1">
                            <Link href="/collection" className="inline-flex items-center gap-3 text-[10px] font-bold tracking-[.4em] uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors mb-16 group">
                                <ArrowLeft size={16} className="group-hover:-translate-x-2 transition-transform" /> Back to Collection
                            </Link>

                            <h1 className="text-5xl md:text-7xl font-serif text-luxury-black dark:text-white mb-16 transition-colors tracking-tighter">Check<span className="italic">out</span></h1>

                            {/* Steps Progress */}
                            <div className="flex items-center gap-8 mb-20 overflow-x-auto pb-4 scrollbar-hide">
                                {[
                                    { id: 1, name: "Identity & Shipping", icon: MapPin },
                                    { id: 2, name: "Delivery Protocol", icon: Truck },
                                    { id: 3, name: "Secure Payment", icon: CreditCard }
                                ].map((s) => (
                                    <div key={s.id} className="flex items-center gap-6 flex-shrink-0">
                                        <div
                                            onClick={() => step > s.id && setStep(s.id)}
                                            className={`p-4 pl-6 pr-8 rounded-full flex items-center gap-4 transition-all cursor-pointer ${step >= s.id
                                                    ? "bg-luxury-black dark:bg-accent text-white shadow-2xl shadow-accent/20"
                                                    : "bg-white dark:bg-white/5 text-stone-300 border border-stone-100 dark:border-white/5"
                                                }`}
                                        >
                                            <s.icon size={18} />
                                            <span className="text-[10px] font-bold tracking-[.2em] uppercase whitespace-nowrap">{s.name}</span>
                                        </div>
                                        {s.id < 3 && <ChevronRight size={14} className="text-stone-300" />}
                                    </div>
                                ))}
                            </div>

                            <AnimatePresence mode="wait">
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
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">First Name</label>
                                                <input type="text" className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm shadow-sm" placeholder="Alexander" />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Last Name</label>
                                                <input type="text" className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm shadow-sm" placeholder="Dupont" />
                                            </div>
                                        </div>
                                        <div className="space-y-3">
                                            <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Email Address</label>
                                            <input type="email" className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm shadow-sm" placeholder="a.dupont@lumina.com" />
                                        </div>
                                        <div className="space-y-3">
                                            <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Shipping Address</label>
                                            <input type="text" className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm shadow-sm" placeholder="12 Rue de la Paix, Seventh Floor" />
                                        </div>
                                        <div className="grid md:grid-cols-3 gap-10">
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">City</label>
                                                <input type="text" className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm shadow-sm" placeholder="Paris" />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Postal Code</label>
                                                <input type="text" className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm shadow-sm font-mono" placeholder="75001" />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Country</label>
                                                <div className="relative">
                                                    <select className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm shadow-sm appearance-none cursor-pointer">
                                                        <option>France</option>
                                                        <option>USA (Federal)</option>
                                                        <option>Vietnam (HCMC)</option>
                                                        <option>Singapore</option>
                                                    </select>
                                                    <ChevronRight className="absolute right-6 top-1/2 -translate-y-1/2 rotate-90 text-stone-300 pointer-events-none" size={16} />
                                                </div>
                                            </div>
                                        </div>

                                        <button
                                            onClick={() => setStep(2)}
                                            className="w-full py-6 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.4em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all group"
                                            disabled={cartItems.length === 0}
                                        >
                                            Continue to Shipping <ArrowRight size={16} className="inline ml-4 group-hover:translate-x-2 transition-transform" />
                                        </button>
                                    </motion.div>
                                )}

                                {step === 2 && (
                                    <motion.div
                                        key="step2"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-8"
                                    >
                                        {[
                                            { id: 'gnt', name: 'GHN Express', time: '2-3 Business Days', price: 15, desc: "Standard continental transit." },
                                            { id: 'ghtk', name: 'GHTK Premium', time: '1-2 Business Days', price: 25, desc: "Climate-controlled delivery." },
                                            { id: 'intl', name: 'DEX International', time: '5-7 Business Days', price: 45, desc: "Fully insured archival shipping." }
                                        ].map((method) => (
                                            <div key={method.id} className="p-8 rounded-[3rem] border border-stone-100 dark:border-white/5 bg-white dark:bg-zinc-900 flex items-center justify-between cursor-pointer hover:border-accent transition-all group shadow-sm hover:shadow-xl">
                                                <div className="flex items-center gap-8">
                                                    <div className="w-8 h-8 rounded-full border-2 border-stone-200 dark:border-white/10 flex items-center justify-center p-1.5 group-hover:border-accent transition-colors">
                                                        <div className="w-full h-full rounded-full bg-accent scale-0 group-hover:scale-100 transition-transform" />
                                                    </div>
                                                    <div>
                                                        <h4 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-widest">{method.name}</h4>
                                                        <p className="text-[10px] text-stone-400 mt-2 uppercase tracking-tighter">{method.time} • {method.desc}</p>
                                                    </div>
                                                </div>
                                                <span className="text-lg font-serif italic text-luxury-black dark:text-white">${method.price}</span>
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
                                                className="flex-[2] py-6 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all group"
                                            >
                                                Continue to Payment <ArrowRight size={16} className="inline ml-4 group-hover:translate-x-2 transition-transform" />
                                            </button>
                                        </div>
                                    </motion.div>
                                )}

                                {step === 3 && (
                                    <motion.div
                                        key="step3"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-12"
                                    >
                                        <div className="grid grid-cols-2 gap-8">
                                            <div className="p-10 rounded-[3.5rem] border-2 border-accent bg-accent/5 flex flex-col items-center gap-6 text-center shadow-xl">
                                                <CreditCard className="text-accent" size={40} strokeWidth={1} />
                                                <span className="text-[10px] font-bold tracking-[.4em] uppercase text-luxury-black dark:text-white">Authorized Card</span>
                                            </div>
                                            <div className="p-10 rounded-[3.5rem] border border-stone-100 dark:border-white/5 bg-white dark:bg-zinc-900 flex flex-col items-center gap-6 text-center opacity-30 grayscale cursor-not-allowed transition-all">
                                                <div className="w-10 h-10 rounded-full bg-stone-200" />
                                                <span className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-400">Loyalty Redemption</span>
                                            </div>
                                        </div>

                                        <div className="space-y-8 bg-white dark:bg-zinc-900 p-12 rounded-[3.5rem] border border-stone-100 dark:border-white/10 shadow-sm transition-colors">
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Cardholder Identification</label>
                                                <input type="text" className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm" placeholder="ALEXANDER DUPONT" />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Security Encrypted Card Number</label>
                                                <input type="text" className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm font-mono tracking-widest" placeholder="•••• •••• •••• 4242" />
                                            </div>
                                            <div className="grid grid-cols-2 gap-10">
                                                <div className="space-y-3">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Expiration</label>
                                                    <input type="text" className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm" placeholder="MM / YY" />
                                                </div>
                                                <div className="space-y-3">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">CVV Source Code</label>
                                                    <input type="text" className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-accent transition-all text-sm" placeholder="•••" />
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
                                            <button
                                                className="flex-[2] py-6 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.4em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all flex items-center justify-center gap-4 group"
                                            >
                                                Secure Purchase Total <ShieldCheck size={18} className="group-hover:scale-110 transition-transform" />
                                            </button>
                                        </div>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>

                        {/* Order Summary Sidebar */}
                        <div className="w-full lg:w-[450px] sticky top-40 order-1 lg:order-2">
                            <div className="bg-white dark:bg-zinc-900 rounded-[4rem] p-12 border border-stone-100 dark:border-white/5 shadow-2xl transition-all">
                                <h3 className="text-2xl font-serif text-luxury-black dark:text-white uppercase tracking-[.2em] mb-12 pb-8 border-b border-stone-100 dark:border-white/5 italic transition-colors">Manifest Summary</h3>

                                <div className="space-y-10 mb-12 max-h-[50vh] overflow-y-auto pr-4 scrollbar-hide">
                                    <AnimatePresence mode="popLayout">
                                        {cartItems.length > 0 ? cartItems.map((item) => (
                                            <motion.div
                                                key={item.id}
                                                layout
                                                initial={{ opacity: 0, scale: 0.95 }}
                                                animate={{ opacity: 1, scale: 1 }}
                                                exit={{ opacity: 0, x: -20 }}
                                                className="flex gap-6 group"
                                            >
                                                <div className="relative w-24 h-32 rounded-2xl overflow-hidden bg-stone-50 dark:bg-zinc-800 flex-shrink-0 border border-stone-100 dark:border-white/5">
                                                    <Image src={item.image} alt={item.name} fill className="object-cover group-hover:scale-110 transition-transform duration-700" />
                                                </div>
                                                <div className="flex-1 py-1">
                                                    <div className="flex justify-between items-start mb-2">
                                                        <h4 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-wider">{item.name}</h4>
                                                        <span className="text-sm font-medium text-luxury-black dark:text-white transition-colors">${item.price * item.quantity}</span>
                                                    </div>
                                                    <p className="text-[10px] text-stone-400 uppercase tracking-widest italic mb-6">{item.type}</p>

                                                    <div className="flex items-center justify-between">
                                                        <div className="flex items-center gap-4 bg-stone-50 dark:bg-white/5 px-3 py-1.5 rounded-full border border-stone-100 dark:border-white/5 transition-colors">
                                                            <button
                                                                onClick={() => updateQuantity(item.id, -1)}
                                                                className="text-stone-300 hover:text-luxury-black dark:hover:text-white transition-colors cursor-pointer"
                                                            >
                                                                <Minus size={12} />
                                                            </button>
                                                            <span className="text-[10px] font-bold w-4 text-center dark:text-white transition-colors">{item.quantity}</span>
                                                            <button
                                                                onClick={() => updateQuantity(item.id, 1)}
                                                                className="text-stone-300 hover:text-luxury-black dark:hover:text-white transition-colors cursor-pointer"
                                                            >
                                                                <Plus size={12} />
                                                            </button>
                                                        </div>
                                                        <button
                                                            onClick={() => removeFromCart(item.id)}
                                                            className="text-stone-300 hover:text-red-500 transition-colors opacity-0 group-hover:opacity-100 cursor-pointer"
                                                        >
                                                            <Trash2 size={16} />
                                                        </button>
                                                    </div>
                                                </div>
                                            </motion.div>
                                        )) : (
                                            <div className="py-20 text-center space-y-4 opacity-30 flex flex-col items-center">
                                                <ShoppingBag size={48} strokeWidth={1} />
                                                <p className="text-[10px] font-bold tracking-widest uppercase italic">The Requisition is Empty</p>
                                                <Link href="/collection" className="text-[10px] text-accent font-bold uppercase tracking-widest hover:underline pt-4">Return to collection</Link>
                                            </div>
                                        )}
                                    </AnimatePresence>
                                </div>

                                <div className="space-y-6 pt-12 border-t border-stone-100 dark:border-white/5 transition-colors">
                                    <div className="flex items-center gap-4 mb-8 p-5 bg-stone-50 dark:bg-white/5 rounded-3xl border border-dashed border-stone-200 dark:border-white/20 transition-all">
                                        <Ticket size={18} className="text-stone-400" />
                                        <input type="text" placeholder="Promo / Archive Code" className="bg-transparent text-[10px] uppercase font-bold tracking-[.3em] outline-none flex-1 placeholder:text-stone-300 transition-colors" />
                                        <button className="text-[10px] font-bold text-accent uppercase tracking-widest hover:text-yellow-600 transition-colors">Apply</button>
                                    </div>

                                    <div className="space-y-4">
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>Subtotal Protocol</span>
                                            <span className="text-luxury-black dark:text-white transition-colors">${subtotal.toFixed(2)}</span>
                                        </div>
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>Luxury Freight</span>
                                            <span className="text-luxury-black dark:text-white transition-colors">${shipping.toFixed(2)}</span>
                                        </div>
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>Tax & Digital Rights</span>
                                            <span className="text-luxury-black dark:text-white transition-colors">${tax.toFixed(2)}</span>
                                        </div>
                                    </div>

                                    <div className="pt-8 mt-6 flex justify-between items-center border-t border-stone-100 dark:border-white/10 transition-all">
                                        <span className="text-[10px] font-bold tracking-[.5em] uppercase text-stone-400">Final Total</span>
                                        <span className="text-4xl font-serif text-luxury-black dark:text-white italic transition-colors">${total.toFixed(2)}</span>
                                    </div>
                                </div>

                                <div className="mt-12 flex items-center gap-6 p-6 glass-dark bg-accent/10 border border-accent/20 rounded-[2.5rem] transition-colors">
                                    <div className="p-3 bg-accent text-white rounded-2xl shadow-lg">
                                        <CheckCircle2 size={24} />
                                    </div>
                                    <div>
                                        <p className="text-[10px] leading-relaxed text-stone-500 dark:text-stone-400 uppercase tracking-tighter font-medium transition-colors">
                                            You will receive <span className="text-accent font-bold">{(subtotal * 10).toLocaleString()} Loyalty Points</span>
                                        </p>
                                        <p className="text-[8px] text-accent uppercase tracking-[.2em] font-bold mt-1">Status: High-Priority Fulfillment</p>
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
