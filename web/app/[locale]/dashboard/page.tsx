"use client";

import React from "react";
import { motion } from "framer-motion";
import {
    Sparkles,
    TrendingUp,
    Award,
    Clock
} from "lucide-react";
import Image from "next/image";

export default function Dashboard() {
    return (
        <div className="flex flex-col gap-8">
            {/* Stats Grid */}
            <section className="grid grid-cols-1 md:grid-cols-4 gap-6">
                {[
                    { label: "Total Revenue", value: "$124.5k", icon: TrendingUp, color: "bg-emerald-500/10 text-emerald-600" },
                    { label: "Active Consultations", value: "842", icon: Sparkles, color: "bg-accent/10 text-accent" },
                    { label: "Prestige Members", value: "2.1k", icon: Award, color: "bg-blue-500/10 text-blue-600" },
                    { label: "Avg. Delivery", value: "1.2d", icon: Clock, color: "bg-stone-500/10 text-stone-600" }
                ].map((stat, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="glass bg-white dark:bg-zinc-900 p-6 rounded-3xl border border-white/50 dark:border-white/10 shadow-sm transition-colors"
                    >
                        <div className="flex justify-between items-start mb-4">
                            <div className={`p-3 rounded-2xl ${stat.color}`}>
                                <stat.icon size={20} strokeWidth={2} />
                            </div>
                        </div>
                        <h3 className="text-2xl font-bold mb-1 text-luxury-black dark:text-white transition-colors">{stat.value}</h3>
                        <p className="text-xs text-stone-600 dark:text-stone-400 tracking-wide uppercase font-medium transition-colors">{stat.label}</p>
                    </motion.div>
                ))}
            </section>

            {/* Main Dashboard Area */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 flex-1">
                {/* Recent Consultations */}
                <section className="lg:col-span-2 glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-white/50 dark:border-white/10 p-8 shadow-sm flex flex-col transition-colors">
                    <div className="flex justify-between items-center mb-8">
                        <h2 className="text-xl font-serif font-bold text-luxury-black dark:text-white transition-colors">Live AI Consultations</h2>
                        <button className="text-xs font-bold text-accent tracking-widest uppercase hover:underline">Real-time Stream</button>
                    </div>

                    <div className="space-y-4">
                        {[
                            { client: "Elena Gilbert", goal: "Evening Signature", status: "Matching", match: "89%" },
                            { client: "Marco V.", goal: "Fresh Aquatic", status: "Completed", match: "94%" },
                            { client: "Sophia R.", goal: "Warm Woody", status: "Processing", match: "72%" }
                        ].map((c, i) => (
                            <div key={i} className="flex items-center justify-between p-4 rounded-2xl border border-stone-100 dark:border-white/5 hover:bg-stone-50 dark:hover:bg-white/5 transition-colors cursor-pointer group">
                                <div className="flex items-center gap-4">
                                    <div className="w-12 h-12 rounded-full bg-stone-200 dark:bg-zinc-800 overflow-hidden relative border border-white dark:border-zinc-700 transition-colors">
                                        <Image src="/images/hero.png" alt="Profile" fill className="object-cover" />
                                    </div>
                                    <div>
                                        <h4 className="text-sm font-bold text-luxury-black dark:text-white transition-colors">{c.client}</h4>
                                        <p className="text-xs text-stone-600 dark:text-stone-400 transition-colors">{c.goal}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-6">
                                    <div className="text-right">
                                        <span className={`text-[10px] px-2 py-1 rounded-full uppercase font-bold tracking-tight transition-colors ${c.status === "Completed" ? "bg-emerald-100 dark:bg-emerald-500/10 text-emerald-700 dark:text-emerald-400" : "bg-accent/10 dark:bg-accent/20 text-accent"
                                            }`}>
                                            {c.status}
                                        </span>
                                    </div>
                                    <div className="w-24 text-right">
                                        <span className="font-serif italic text-lg text-luxury-black dark:text-white transition-colors">{c.match} Match</span>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </section>

                {/* AI Insights Card */}
                <section className="glass rounded-[2.5rem] border border-white/50 p-8 bg-luxury-black text-white shadow-xl relative overflow-hidden">
                    <div className="relative z-10">
                        <div className="flex items-center gap-2 mb-8">
                            <Sparkles size={20} className="text-accent" />
                            <h2 className="text-lg font-serif">Scent Intelligence</h2>
                        </div>

                        <div className="space-y-8">
                            <div>
                                <h4 className="text-xs uppercase tracking-widest text-stone-500 dark:text-stone-400 mb-4 transition-colors">Trending Notes</h4>
                                <div className="flex flex-wrap gap-2">
                                    {["Ambroxan", "Saffron", "White Musk", "Bergamot"].map(n => (
                                        <span key={n} className="px-3 py-1.5 rounded-full border border-white/10 text-xs bg-white/5 hover:bg-white/20 transition-colors cursor-default">
                                            {n}
                                        </span>
                                    ))}
                                </div>
                            </div>

                            <div>
                                <h4 className="text-xs uppercase tracking-widest text-stone-500 dark:text-stone-400 mb-4 transition-colors">Market Sentiment</h4>
                                <div className="space-y-4">
                                    <div className="space-y-2">
                                        <div className="flex justify-between text-xs">
                                            <span>Luxury Tier</span>
                                            <span className="text-accent">+12%</span>
                                        </div>
                                        <div className="h-1 bg-white/10 rounded-full overflow-hidden">
                                            <motion.div
                                                initial={{ width: 0 }}
                                                animate={{ width: "75%" }}
                                                transition={{ duration: 1, ease: "easeOut" }}
                                                className="h-full bg-accent"
                                            />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <div className="flex justify-between text-xs">
                                            <span>Niche Artisanal</span>
                                            <span className="text-accent">+08%</span>
                                        </div>
                                        <div className="h-1 bg-white/10 rounded-full overflow-hidden">
                                            <motion.div
                                                initial={{ width: 0 }}
                                                animate={{ width: "45%" }}
                                                transition={{ duration: 1, ease: "easeOut", delay: 0.2 }}
                                                className="h-full bg-accent"
                                            />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <button className="w-full py-4 glass text-xs font-bold tracking-widest uppercase rounded-2xl border border-white/10 hover:bg-white/10 transition-colors">
                                Generate Full Report
                            </button>
                        </div>
                    </div>
                    {/* Decoration */}
                    <div className="absolute top-0 right-0 w-32 h-32 bg-accent opacity-20 blur-[100px]" />
                    <div className="absolute bottom-0 left-0 w-32 h-32 bg-accent opacity-10 blur-[80px]" />
                </section>
            </div>
        </div>
    );
}
