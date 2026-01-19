"use client";

import React from "react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { motion } from "framer-motion";
import { CheckCircle, Truck, Package, Calendar, ArrowRight } from "lucide-react";

export default function OrderSuccessPage() {
    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex items-center justify-center p-6 py-24 transition-colors">
            <div className="max-w-4xl w-full">
                <div className="glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-200 dark:border-white/10 shadow-2xl overflow-hidden grid grid-cols-1 lg:grid-cols-2 transition-colors">

                    <div className="p-12 md:p-16 flex flex-col justify-center">
                        <motion.div
                            initial={{ opacity: 0, scale: 0.5 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ type: "spring", damping: 12 }}
                            className="w-16 h-16 bg-emerald-50 dark:bg-emerald-500/10 text-emerald-500 rounded-2xl flex items-center justify-center mb-10 transition-colors"
                        >
                            <CheckCircle size={32} />
                        </motion.div>

                        <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-6 transition-colors">Gratitude, Your Selection is Confirmed.</h1>
                        <p className="text-stone-500 dark:text-stone-400 text-lg font-light leading-relaxed mb-10 transition-colors">
                            An email confirmation has been dispatched. Our artisans are now preparing your selection for its journey.
                        </p>

                        <div className="space-y-6 mb-12">
                            <div className="flex items-center gap-4 text-stone-600 dark:text-stone-400 transition-colors">
                                <Package size={20} className="text-stone-300 dark:text-stone-600 transition-colors" />
                                <span className="text-sm font-medium">Order Number: <span className="text-luxury-black dark:text-white font-bold transition-colors">#LM-284910</span></span>
                            </div>
                            <div className="flex items-center gap-4 text-stone-600 dark:text-stone-400 transition-colors">
                                <Calendar size={20} className="text-stone-300 dark:text-stone-600 transition-colors" />
                                <span className="text-sm font-medium">Estimated Arrival: <span className="text-luxury-black dark:text-white font-bold transition-colors">Oct 28 - Oct 30</span></span>
                            </div>
                            <div className="flex items-center gap-4 text-stone-600 dark:text-stone-400 transition-colors">
                                <Truck size={20} className="text-stone-300 dark:text-stone-600 transition-colors" />
                                <span className="text-sm font-medium">Method: <span className="text-luxury-black dark:text-white font-bold italic tracking-wide transition-colors">Concierge White-Glove</span></span>
                            </div>
                        </div>

                        <div className="flex flex-col sm:flex-row gap-4">
                            <Link href="/profile" className="flex-1 bg-luxury-black dark:bg-accent text-white py-4 rounded-full font-bold tracking-widest uppercase text-center text-xs hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-xl">
                                Track Order
                            </Link>
                            <Link href="/" className="flex-1 border border-stone-200 dark:border-stone-800 text-stone-400 dark:text-stone-500 py-4 rounded-full font-bold tracking-widest uppercase text-center text-xs hover:border-luxury-black dark:hover:border-white hover:text-luxury-black dark:hover:text-white transition-all">
                                The House
                            </Link>
                        </div>
                    </div>

                    <div className="relative hidden lg:block bg-stone-100 dark:bg-zinc-800 transition-colors p-16">
                        <div className="h-full w-full rounded-[2rem] overflow-hidden relative shadow-2xl">
                            <Image src="/images/order-success.png" alt="Success" fill className="object-cover" />
                            <div className="absolute inset-x-0 bottom-0 p-10 bg-gradient-to-t from-black/80 to-transparent text-white">
                                <p className="italic font-serif text-xl mb-4 leading-relaxed">"The wait is the most exquisite part of the ceremony."</p>
                                <div className="flex items-center gap-4">
                                    <div className="w-8 h-px bg-accent" />
                                    <span className="text-[10px] font-bold tracking-widest uppercase text-stone-300">LUMINA ATELIER</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="mt-12 text-center">
                    <p className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-300">Securely processed by Lumina Intelligence</p>
                </div>
            </div>
        </div>
    );
}
