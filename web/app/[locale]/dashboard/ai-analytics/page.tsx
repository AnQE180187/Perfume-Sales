"use client";

import React from "react";
import { motion } from "framer-motion";
import { Link } from "@/i18n/routing";
import { Sparkles, TrendingUp, Users, ShoppingCart, ArrowUpRight, ArrowDownRight, Brain, Zap, MessageSquare } from "lucide-react";

export default function AIAnalyticsPage() {
    return (
        <div className="space-y-10">
            <div className="flex justify-between items-end">
                <div>
                    <div className="flex items-center gap-2 text-accent mb-2">
                        <Brain size={18} />
                        <span className="text-[10px] font-bold tracking-[.4em] uppercase">Neural Engine Insights</span>
                    </div>
                    <h1 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors">AI Intelligence</h1>
                </div>
                <div className="flex gap-4">
                    <button className="px-6 py-2 glass dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-full text-[10px] font-bold tracking-widest uppercase text-stone-500 hover:text-luxury-black dark:hover:text-white transition-all">Export Report</button>
                    <button className="px-6 py-2 bg-luxury-black dark:bg-accent text-white rounded-full text-[10px] font-bold tracking-widest uppercase shadow-lg">Retrain Model</button>
                </div>
            </div>

            {/* Top Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                {[
                    { label: "AI Acceptance Rate", value: "92.4%", change: "+4.2%", up: true, icon: Brain },
                    { label: "Recommendation Vol.", value: "1,240", change: "+12%", up: true, icon: Zap },
                    { label: "Review Sentiment", value: "Positive", change: "98/100", up: true, icon: MessageSquare },
                    { label: "DNA Profiles", value: "8,432", change: "-2.1%", up: false, icon: Users },
                ].map((stat, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="p-8 glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-100 dark:border-white/5 shadow-sm transition-colors"
                    >
                        <div className="flex justify-between items-start mb-6">
                            <div className="p-3 rounded-2xl bg-stone-50 dark:bg-white/5 text-accent">
                                <stat.icon size={20} />
                            </div>
                            <div className={`flex items-center gap-1 text-[10px] font-bold ${stat.up ? "text-green-500" : "text-red-500"}`}>
                                {stat.change} {stat.up ? <ArrowUpRight size={12} /> : <ArrowDownRight size={12} />}
                            </div>
                        </div>
                        <h3 className="text-3xl font-serif text-luxury-black dark:text-white mb-1">{stat.value}</h3>
                        <p className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{stat.label}</p>
                    </motion.div>
                ))}
            </div>

            <div className="grid md:grid-cols-3 gap-10">
                {/* Trend Forecasting */}
                <div className="md:col-span-2 p-10 glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                    <div className="flex justify-between items-center mb-12">
                        <h3 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest">Olfactory Trend Forecast</h3>
                        <div className="flex gap-4">
                            {["Weekly", "Monthly", "Quarterly"].map(t => (
                                <button key={t} className={`text-[9px] font-bold tracking-widest uppercase ${t === "Monthly" ? "text-accent" : "text-stone-400"}`}>{t}</button>
                            ))}
                        </div>
                    </div>

                    <div className="h-64 flex items-end justify-between gap-4">
                        {[45, 60, 40, 80, 55, 90, 70, 85, 65, 50, 75, 95].map((val, i) => (
                            <div key={i} className="flex-1 flex flex-col items-center gap-4 group">
                                <div className="w-full relative">
                                    <motion.div
                                        initial={{ height: 0 }}
                                        animate={{ height: `${val}%` }}
                                        transition={{ duration: 1, delay: i * 0.05 }}
                                        className="w-full rounded-t-xl bg-stone-100 dark:bg-white/5 group-hover:bg-accent transition-all duration-500 shadow-sm"
                                    />
                                </div>
                                <span className="text-[8px] font-bold text-stone-300 dark:text-stone-700 tracking-tighter uppercase">JAN {i + 1}</span>
                            </div>
                        ))}
                    </div>

                    <div className="mt-12 p-6 rounded-3xl bg-accent/5 border border-accent/10 flex items-center gap-6">
                        <div className="p-4 rounded-2xl bg-accent text-white shadow-lg">
                            <TrendingUp size={24} />
                        </div>
                        <div>
                            <h4 className="text-xs font-bold text-luxury-black dark:text-white uppercase tracking-widest mb-1">AI Prediction</h4>
                            <p className="text-[10px] text-stone-500 leading-relaxed italic uppercase tracking-tighter">
                                42% increase in <span className="text-accent font-bold">Oud-based</span> inquiries expected for Spring 2026 due to regional weather shifts.
                            </p>
                        </div>
                    </div>
                </div>

                {/* Review Summarization */}
                <div className="p-10 glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                    <h3 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest mb-10">Review Intelligence</h3>

                    <div className="space-y-8">
                        <div>
                            <div className="flex justify-between items-center mb-4">
                                <span className="text-[10px] font-bold tracking-widest uppercase text-stone-400">Common Themes</span>
                                <span className="text-[10px] font-bold text-accent px-2 py-1 bg-accent/10 rounded-full">Updated 1h ago</span>
                            </div>
                            <div className="flex flex-wrap gap-2">
                                {["Long-lasting", "Elegant Packaging", "Subtle Oud", "Perfect for Night", "Fast Shipping", "AI Match Exact"].map(tag => (
                                    <span key={tag} className="px-4 py-2 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-full text-[9px] font-bold uppercase tracking-widest text-stone-500">
                                        {tag}
                                    </span>
                                ))}
                            </div>
                        </div>

                        <div className="pt-8 border-t border-stone-100 dark:border-white/5">
                            <h4 className="text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white mb-6">Semantic Summary</h4>
                            <div className="space-y-4">
                                <div className="p-4 rounded-2xl bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10">
                                    <p className="text-[11px] text-stone-500 leading-relaxed italic">
                                        "Users consistently praise the <span className="text-luxury-black dark:text-white font-bold">Lumina No. 01</span> for its transition from citrus to woody notes, though 12% suggest the sillage could be stronger in humid climates."
                                    </p>
                                </div>
                                <div className="p-4 rounded-2xl bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10">
                                    <p className="text-[11px] text-stone-500 leading-relaxed italic">
                                        "General consensus on <span className="text-luxury-black dark:text-white font-bold">Oud Mystère</span>: High prestige value, often purchased as a gift after AI consultation."
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Semantic Search Log */}
            <div className="p-10 glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                <div className="flex justify-between items-center mb-10">
                    <h3 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest">Recent Semantic Queries</h3>
                    <Link href="#" className="text-[10px] font-bold tracking-widest uppercase text-accent border-b border-accent">View All Logs</Link>
                </div>
                <div className="space-y-4">
                    {[
                        { query: "Sweet women's perfume under 1.5 million VND", time: "2 mins ago", match: "Bergamot Sky" },
                        { query: "Intense woody scent for black-tie event", time: "15 mins ago", match: "Oud Mystère" },
                        { query: "Fragrance that smells like rain on concrete", time: "1h ago", match: "Urban Oasis (Beta)" },
                        { query: "Subtle jasmine for office wear", time: "3h ago", match: "Velvet Jasmine" }
                    ].map((log, i) => (
                        <div key={i} className="flex items-center justify-between p-6 rounded-[2rem] hover:bg-stone-50 dark:hover:bg-white/5 transition-colors group">
                            <div className="flex items-center gap-6">
                                <div className="w-10 h-10 rounded-full bg-stone-100 dark:bg-white/5 flex items-center justify-center text-stone-400 group-hover:text-accent transition-colors">
                                    <MessageSquare size={18} />
                                </div>
                                <div>
                                    <p className="text-sm font-medium text-luxury-black dark:text-white italic">"{log.query}"</p>
                                    <span className="text-[9px] text-stone-400 uppercase tracking-widest">{log.time}</span>
                                </div>
                            </div>
                            <div className="flex items-center gap-4">
                                <span className="text-[10px] font-bold tracking-widest uppercase text-stone-300">Resolved to:</span>
                                <span className="px-4 py-2 bg-accent text-white rounded-full text-[9px] font-bold tracking-widest uppercase shadow-sm">{log.match}</span>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}
