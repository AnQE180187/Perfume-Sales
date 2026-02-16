'use client';

import React from 'react';
import { motion } from 'framer-motion';
import {
    Sparkles,
    TrendingUp,
    Award,
    Clock,
    Search,
    ArrowUpRight,
    Package,
    Receipt,
    Tag,
    Users
} from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { AuthGuard } from '@/components/auth/auth-guard';

export default function AdminDashboard() {
    return (
        <AuthGuard allowedRoles={['admin']}>
            <div className="flex flex-col gap-10 py-10 px-8">
                {/* Header Section */}
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
                    <div>
                        <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">
                            Central <span className="italic">Command</span>
                        </h1>
                        <p className="text-[10px] text-stone-500 uppercase tracking-[.4em] font-bold">
                            Neural Intelligence Dashboard v4.2
                        </p>
                    </div>
                    <div className="flex items-center gap-4">
                        <div className="relative group">
                            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400 group-hover:text-gold transition-colors" size={16} />
                            <input
                                type="text"
                                placeholder="Universal registry search..."
                                className="bg-white dark:bg-zinc-900 border border-stone-200 dark:border-white/10 rounded-2xl py-3 pl-12 pr-6 text-xs outline-none focus:border-gold transition-all w-64 shadow-sm"
                            />
                        </div>
                    </div>
                </div>

                {/* Stats Grid */}
                <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
                    {[
                        { label: "Total Revenue", value: "2.4B đ", icon: TrendingUp, color: "bg-emerald-500/10 text-emerald-600", delay: 0.1 },
                        { label: "Active Consultations", value: "842", icon: Sparkles, color: "bg-gold/10 text-gold", delay: 0.2 },
                        { label: "Prestige Members", value: "2.1k", icon: Award, color: "bg-blue-500/10 text-blue-600", delay: 0.3 },
                        { label: "Avg. Delivery", value: "1.2d", icon: Clock, color: "bg-stone-500/10 text-stone-600", delay: 0.4 }
                    ].map((stat, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: stat.delay }}
                            className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm hover:shadow-xl transition-all group"
                        >
                            <div className="flex justify-between items-start mb-6">
                                <div className={`p-4 rounded-2xl ${stat.color} group-hover:scale-110 transition-transform`}>
                                    <stat.icon size={24} strokeWidth={2} />
                                </div>
                                <div className="p-2 border border-stone-100 dark:border-white/5 rounded-full text-stone-400 hover:text-gold cursor-pointer transition-colors">
                                    <ArrowUpRight size={14} />
                                </div>
                            </div>
                            <h3 className="text-3xl font-bold mb-2 text-luxury-black dark:text-white transition-colors">{stat.value}</h3>
                            <p className="text-[10px] text-stone-500 dark:text-stone-400 tracking-[.2em] uppercase font-bold transition-colors">{stat.label}</p>
                        </motion.div>
                    ))}
                </section>

                {/* Management Consoles */}
                <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    {[
                        { label: "Products", desc: "Manage collection", icon: Package, href: "/dashboard/admin/products" },
                        { label: "Orders", desc: "Fulfillment registry", icon: Receipt, href: "/dashboard/admin/orders" },
                        { label: "Discounts", desc: "Campaign rewards", icon: Tag, href: "/dashboard/admin/marketing/promotions" },
                        { label: "Users", desc: "Member accounts", icon: Users, href: "/dashboard/admin/users" }
                    ].map((item, i) => (
                        <Link key={i} href={item.href}>
                            <div className="glass bg-white dark:bg-zinc-900 px-6 py-5 rounded-3xl border border-stone-200 dark:border-white/10 hover:border-gold transition-all cursor-pointer group flex items-center gap-4 shadow-sm hover:shadow-lg">
                                <div className="w-12 h-12 rounded-2xl bg-stone-100 dark:bg-white/5 flex items-center justify-center text-stone-500 group-hover:bg-gold group-hover:text-white transition-all">
                                    <item.icon size={20} />
                                </div>
                                <div className="flex-1 min-w-0">
                                    <h4 className="text-[10px] font-bold uppercase tracking-widest text-luxury-black dark:text-white truncate">{item.label}</h4>
                                    <p className="text-[8px] text-stone-400 uppercase tracking-tighter font-bold mt-0.5 truncate">{item.desc}</p>
                                </div>
                            </div>
                        </Link>
                    ))}
                </section>

                {/* Main Area */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
                    {/* Real-time Feed */}
                    <section className="lg:col-span-2 glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-200 dark:border-white/10 p-10 shadow-sm flex flex-col transition-colors">
                        <div className="flex justify-between items-center mb-10">
                            <div className="flex items-center gap-3">
                                <h2 className="text-2xl font-serif text-luxury-black dark:text-white transition-colors">Live AI Consultations</h2>
                                <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                            </div>
                            <button className="text-[10px] font-bold text-gold tracking-widest uppercase hover:underline cursor-pointer">
                                View Monitor Matrix
                            </button>
                        </div>

                        <div className="space-y-6">
                            {[
                                { client: "Elena Gilbert", goal: "Evening Signature", status: "Matching", match: "89%", time: "Just now" },
                                { client: "Marco V.", goal: "Fresh Aquatic", status: "Completed", match: "94%", time: "2m ago" },
                                { client: "Sophia R.", goal: "Warm Woody", status: "Processing", match: "72%", time: "5m ago" },
                                { client: "James T.", goal: "Oriental Mystique", status: "Completed", match: "91%", time: "12m ago" }
                            ].map((c, i) => (
                                <div key={i} className="flex items-center justify-between p-6 rounded-3xl border border-stone-100 dark:border-white/5 hover:bg-stone-50 dark:hover:bg-white/5 transition-all cursor-pointer group">
                                    <div className="flex items-center gap-6">
                                        <div className="relative w-14 h-14 rounded-2xl overflow-hidden border-2 border-white dark:border-zinc-800 shadow-sm transition-all group-hover:scale-105">
                                            <Image src="/luxury_perfume_hero_cinematic.png" alt="Profile" fill className="object-cover" />
                                        </div>
                                        <div>
                                            <h4 className="text-base font-bold text-luxury-black dark:text-white transition-colors">{c.client}</h4>
                                            <p className="text-xs text-stone-500 transition-colors uppercase tracking-widest">{c.goal}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-10">
                                        <div className="hidden md:block text-right">
                                            <span className={`text-[9px] px-3 py-1 rounded-full uppercase font-bold tracking-widest transition-all ${c.status === "Completed"
                                                ? "bg-emerald-100 dark:bg-emerald-500/10 text-emerald-700 dark:text-emerald-400"
                                                : "bg-gold/10 dark:bg-gold/20 text-gold"
                                                }`}>
                                                {c.status}
                                            </span>
                                            <p className="text-[8px] mt-1 text-stone-400 font-bold uppercase tracking-widest">{c.time}</p>
                                        </div>
                                        <div className="w-24 text-right">
                                            <span className="font-serif italic text-xl text-luxury-black dark:text-white transition-colors">{c.match}</span>
                                            <p className="text-[8px] text-gold font-bold uppercase tracking-widest">Match Score</p>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </section>

                    {/* Intelligence Card */}
                    <section className="glass rounded-[3rem] p-10 bg-luxury-black text-white shadow-2xl relative overflow-hidden flex flex-col justify-between">
                        <div className="relative z-10">
                            <div className="flex items-center gap-3 mb-12">
                                <Sparkles size={24} className="text-gold" />
                                <h2 className="text-xl font-serif">Scent Intelligence</h2>
                            </div>

                            <div className="space-y-10">
                                <div>
                                    <h4 className="text-[10px] uppercase tracking-[.3em] text-stone-500 mb-6">Trending Molecular Notes</h4>
                                    <div className="flex flex-wrap gap-3">
                                        {["Ambroxan", "Saffron", "Rose Abs.", "Oud"].map(n => (
                                            <span key={n} className="px-4 py-2 rounded-xl border border-white/10 text-[10px] font-bold uppercase tracking-widest bg-white/5 hover:bg-gold hover:text-white transition-all cursor-pointer">
                                                {n}
                                            </span>
                                        ))}
                                    </div>
                                </div>

                                <div className="space-y-6">
                                    <h4 className="text-[10px] uppercase tracking-[.3em] text-stone-500">Market Absorption</h4>
                                    <div className="space-y-6">
                                        <div className="space-y-3">
                                            <div className="flex justify-between text-[10px] font-bold uppercase tracking-[.2em]">
                                                <span>Luxury Platinum Tier</span>
                                                <span className="text-gold">75%</span>
                                            </div>
                                            <div className="h-1 bg-white/10 rounded-full overflow-hidden">
                                                <motion.div
                                                    initial={{ width: 0 }}
                                                    animate={{ width: "75%" }}
                                                    transition={{ duration: 1.5, ease: "easeOut" }}
                                                    className="h-full bg-gold shadow-[0_0_10px_#C5A059]"
                                                />
                                            </div>
                                        </div>
                                        <div className="space-y-3">
                                            <div className="flex justify-between text-[10px] font-bold uppercase tracking-[.2em]">
                                                <span>Artisanal Niche</span>
                                                <span className="text-gold">45%</span>
                                            </div>
                                            <div className="h-1 bg-white/10 rounded-full overflow-hidden">
                                                <motion.div
                                                    initial={{ width: 0 }}
                                                    animate={{ width: "45%" }}
                                                    transition={{ duration: 1.5, ease: "easeOut", delay: 0.3 }}
                                                    className="h-full bg-gold shadow-[0_0_10px_#C5A059]"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div className="relative z-10 pt-12">
                            <button className="w-full py-5 bg-white/5 hover:bg-gold hover:text-white transition-all text-[10px] font-bold tracking-[.4em] uppercase rounded-[2rem] border border-white/10 shadow-lg cursor-pointer">
                                Generate Full Report
                            </button>
                        </div>

                        {/* Gradient Effects */}
                        <div className="absolute top-0 right-0 w-48 h-48 bg-gold opacity-10 blur-[100px]" />
                        <div className="absolute bottom-0 left-0 w-48 h-48 bg-gold opacity-5 blur-[80px]" />
                    </section>
                </div>
            </div>
        </AuthGuard>
    );
}
