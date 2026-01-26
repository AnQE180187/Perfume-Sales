'use client';

import React from 'react';
import { motion } from 'framer-motion';
import {
    Package,
    ArrowRight,
    MapPin,
    Truck,
    PackageCheck,
    Calendar,
    ChevronRight
} from 'lucide-react';
import { Header } from '@/components/common/header';
import Image from 'next/image';

const myOrders = [
    {
        id: "AURA-8420",
        product: "Lumina No. 01 (Extrait)",
        price: "5.400.000đ",
        date: "Ordered Oct 26, 2025",
        status: "Processing",
        statusDesc: "Stabilizing molecular balance",
        image: "/luxury_perfume_hero_cinematic.png"
    },
    {
        id: "AURA-7912",
        product: "Discovery Set Vol. 1",
        price: "2.000.000đ",
        date: "Delivered Oct 12, 2025",
        status: "Delivered",
        statusDesc: "Hand-delivered by Courier",
        image: "/luxury_ai_scent_lab.png"
    }
];

export default function CustomerOrdersPage() {
    return (
        <div className="p-8 lg:p-12">
            <main>
                <div className="max-w-5xl mx-auto">
                    <header className="mb-20">
                        <h1 className="text-5xl md:text-6xl font-serif text-luxury-black dark:text-white mb-6">
                            My <span className="italic">Acquisitions</span>
                        </h1>
                        <p className="text-[10px] text-stone-500 uppercase tracking-[.4em] font-bold">
                            Registry of your unique olfactory journey.
                        </p>
                    </header>

                    <div className="space-y-10">
                        {myOrders.map((order, i) => (
                            <motion.div
                                key={order.id}
                                initial={{ opacity: 0, y: 30 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: i * 0.1 }}
                                className="glass bg-white dark:bg-zinc-900 rounded-[3.5rem] p-10 border border-stone-100 dark:border-white/5 shadow-sm hover:shadow-xl transition-all"
                            >
                                <div className="flex flex-col lg:flex-row gap-12">
                                    {/* Order Visual */}
                                    <div className="relative w-full lg:w-56 aspect-[3/4] rounded-3xl overflow-hidden shadow-2xl flex-shrink-0">
                                        <Image src={order.image} alt={order.product} fill className="object-cover" />
                                        <div className="absolute inset-0 bg-black/10" />
                                    </div>

                                    {/* Order Details */}
                                    <div className="flex-1 flex flex-col justify-between py-2">
                                        <div>
                                            <div className="flex flex-wrap justify-between items-start gap-4 mb-8">
                                                <div>
                                                    <span className="text-[10px] font-bold text-gold uppercase tracking-widest mb-2 block">
                                                        Order {order.id}
                                                    </span>
                                                    <h2 className="text-3xl font-serif text-luxury-black dark:text-white mb-2">
                                                        {order.product}
                                                    </h2>
                                                    <p className="text-xs text-stone-400 font-bold uppercase tracking-widest">
                                                        {order.date}
                                                    </p>
                                                </div>
                                                <div className="text-right">
                                                    <span className="text-2xl font-serif text-luxury-black dark:text-white block mb-2">
                                                        {order.price}
                                                    </span>
                                                    <span className={`inline-flex items-center gap-2 text-[10px] px-4 py-1.5 rounded-full font-bold uppercase ${order.status === 'Delivered'
                                                        ? 'bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600'
                                                        : 'bg-gold/10 text-gold'
                                                        }`}>
                                                        {order.status === 'Delivered' ? <PackageCheck size={12} /> : <Truck size={12} />}
                                                        {order.status}
                                                    </span>
                                                </div>
                                            </div>

                                            <div className="grid md:grid-cols-2 gap-8 border-t border-stone-100 dark:border-white/5 pt-8">
                                                <div className="flex items-start gap-4">
                                                    <div className="p-3 bg-stone-50 dark:bg-white/5 rounded-2xl text-stone-400">
                                                        <MapPin size={18} />
                                                    </div>
                                                    <div>
                                                        <h4 className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1">Shipping Address</h4>
                                                        <p className="text-xs text-luxury-black dark:text-stone-300 font-medium leading-relaxed">
                                                            123 Nguyen Hue St, District 1<br />Ho Chi Minh City, VN
                                                        </p>
                                                    </div>
                                                </div>
                                                <div className="flex items-start gap-4">
                                                    <div className="p-3 bg-stone-50 dark:bg-white/5 rounded-2xl text-stone-400">
                                                        <Calendar size={18} />
                                                    </div>
                                                    <div>
                                                        <h4 className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1">Latest Update</h4>
                                                        <p className="text-xs text-luxury-black dark:text-stone-300 font-bold tracking-widest italic">
                                                            {order.statusDesc}
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div className="mt-12 flex flex-wrap gap-4">
                                            <button className="px-8 py-4 bg-luxury-black dark:bg-gold text-white rounded-full font-bold tracking-widest uppercase text-[10px] flex items-center gap-3 hover:bg-stone-800 dark:hover:bg-gold/80 transition-all shadow-xl cursor-pointer">
                                                Track Shipment <ArrowRight size={14} />
                                            </button>
                                            <button className="px-8 py-4 border border-stone-200 dark:border-white/10 text-stone-400 hover:text-luxury-black dark:hover:text-white rounded-full font-bold tracking-widest uppercase text-[10px] flex items-center gap-3 transition-all cursor-pointer">
                                                Order Details <ChevronRight size={14} />
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </div>

                    <footer className="mt-20 pt-10 border-t border-stone-100 dark:border-white/5 text-center">
                        <button className="text-[10px] font-bold uppercase tracking-[.3em] text-stone-400 hover:text-gold transition-colors cursor-pointer">
                            View Archival Order Manifests
                        </button>
                    </footer>
                </div>
            </main>
        </div>
    );
}
