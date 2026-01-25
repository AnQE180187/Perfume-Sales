"use client";

import React, { useState } from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import {
    Search,
    Filter,
    Crown,
    Star,
    MessageSquare,
    History,
    Mail,
    Phone,
    MoreVertical,
    Sparkles,
    UserCircle,
    ShoppingBag
} from "lucide-react";

const clients = [
    { id: "1", name: "Alexander Dupont", email: "a.dupont@lumina.com", tier: "L'Héritage", points: 15400, lastVisit: "2h ago", preference: "Woody / Oud", match: "98%", status: "High Value" },
    { id: "2", name: "Elena Vostok", email: "elena.v@archive.ru", tier: "Prestige", points: 8200, lastVisit: "Yesterday", preference: "Floral / Jasmine", match: "92%", status: "Active" },
    { id: "3", name: "Julian Thorne", email: "jthorne@niche.co.uk", tier: "Essentiel", points: 1200, lastVisit: "3 days ago", preference: "Citrus / Bergamot", match: "85%", status: "New Member" },
    { id: "4", name: "Sienna Miller", email: "s.miller@hautecouture.it", tier: "Prestige", points: 9100, lastVisit: "1 week ago", preference: "Amber / Spice", match: "95%", status: "Steady" },
    { id: "5", name: "Marcus Reid", email: "mreid@luxury.sg", tier: "L'Héritage", points: 22000, lastVisit: "1h ago", preference: "Experimental", match: "99%", status: "VIP" },
];

export default function ClientsPage() {
    const [searchTerm, setSearchTerm] = useState("");

    return (
        <div className="space-y-10">
            {/* Header */}
            <div className="flex justify-between items-end">
                <div>
                    <h1 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors">Client Archive</h1>
                    <p className="text-[10px] text-stone-400 font-bold tracking-[.4em] uppercase mt-2">Manage customer identity & olfactory DNA</p>
                </div>
                <div className="flex gap-4">
                    <button className="px-8 py-3 bg-luxury-black dark:bg-accent text-white rounded-full text-[10px] font-bold tracking-widest uppercase shadow-xl flex items-center gap-3">
                        Export CRM Data
                    </button>
                </div>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                {[
                    { label: "Total Active House Members", value: "8,432", icon: UserCircle, accent: "stone-400" },
                    { label: "VIP (L'Héritage) Count", value: "482", icon: Crown, accent: "accent" },
                    { label: "Avg. AI Recommendation Match", value: "91%", icon: Sparkles, accent: "accent" },
                    { label: "Retention Rate (Q4)", value: "78%", icon: History, accent: "stone-400" },
                ].map((stat, i) => (
                    <div key={i} className="p-8 glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                        <div className={`p-3 w-fit rounded-2xl bg-stone-50 dark:bg-white/5 text-${stat.accent} mb-6`}>
                            <stat.icon size={20} />
                        </div>
                        <h3 className="text-3xl font-serif text-luxury-black dark:text-white mb-1">{stat.value}</h3>
                        <p className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{stat.label}</p>
                    </div>
                ))}
            </div>

            {/* Filter & Search */}
            <div className="flex flex-col md:flex-row gap-6">
                <div className="relative flex-1 group">
                    <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300 dark:text-stone-700 group-focus-within:text-accent transition-colors" size={18} />
                    <input
                        type="text"
                        placeholder="Search by name, email, or olfactory profile..."
                        className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 focus:border-accent rounded-full py-4 pl-14 pr-6 text-xs outline-none transition-all placeholder:text-stone-400 shadow-sm"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
                <div className="flex items-center gap-4">
                    <button className="p-4 bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl text-stone-400 hover:text-accent transition-colors">
                        <Filter size={20} />
                    </button>
                    <button className="px-8 py-4 bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl text-[10px] font-bold tracking-widest uppercase text-stone-500 hover:text-luxury-black dark:hover:text-white transition-all">
                        Segment: High Value
                    </button>
                </div>
            </div>

            {/* Client List */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                {clients.map((client, i) => (
                    <motion.div
                        key={client.id}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="bg-white dark:bg-zinc-900 rounded-[3rem] p-10 border border-stone-100 dark:border-white/5 shadow-sm hover:shadow-2xl hover:-translate-y-2 transition-all group"
                    >
                        <div className="flex justify-between items-start mb-10">
                            <div className="flex items-center gap-6">
                                <div className="w-16 h-16 rounded-full bg-stone-100 dark:bg-white/5 flex items-center justify-center text-luxury-black dark:text-white font-serif text-2xl border border-stone-100 dark:border-white/10">
                                    {client.name.charAt(0)}
                                </div>
                                <div>
                                    <h4 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest">{client.name}</h4>
                                    <div className="flex items-center gap-2 mt-1">
                                        <Star size={10} className="text-accent" />
                                        <span className="text-[10px] font-bold tracking-widest uppercase text-accent">{client.tier}</span>
                                    </div>
                                </div>
                            </div>
                            <button className="text-stone-300 hover:text-luxury-black dark:hover:text-white transition-colors">
                                <MoreVertical size={20} />
                            </button>
                        </div>

                        <div className="space-y-6 mb-10">
                            <div className="flex items-center justify-between p-4 bg-stone-50 dark:bg-white/5 rounded-2xl border border-stone-100 dark:border-white/10">
                                <div className="flex items-center gap-3">
                                    <Sparkles size={14} className="text-accent" />
                                    <span className="text-[9px] font-bold tracking-widest uppercase text-stone-400">AI Match Score</span>
                                </div>
                                <span className="text-lg font-serif text-accent">{client.match}</span>
                            </div>

                            <div className="grid grid-cols-1 gap-4">
                                <div className="flex items-center gap-3 text-stone-500">
                                    <Mail size={14} strokeWidth={1.5} />
                                    <span className="text-[10px] uppercase tracking-tighter">{client.email}</span>
                                </div>
                                <div className="flex items-center gap-3 text-stone-500">
                                    <History size={14} strokeWidth={1.5} />
                                    <span className="text-[10px] uppercase tracking-tighter">Last Active: {client.lastVisit}</span>
                                </div>
                            </div>
                        </div>

                        <div className="grid grid-cols-2 gap-4 pt-10 border-t border-stone-100 dark:border-white/5">
                            <button className="flex items-center justify-center gap-2 py-3 bg-stone-50 dark:bg-white/5 hover:bg-luxury-black dark:hover:bg-accent hover:text-white rounded-xl text-[9px] font-bold uppercase tracking-widest transition-all">
                                <MessageSquare size={14} /> Compose
                            </button>
                            <button className="flex items-center justify-center gap-2 py-3 bg-stone-50 dark:bg-white/5 hover:bg-luxury-black dark:hover:bg-accent hover:text-white rounded-xl text-[9px] font-bold uppercase tracking-widest transition-all">
                                <ShoppingBag size={14} /> History
                            </button>
                        </div>
                    </motion.div>
                ))}
            </div>

            {/* CRM Insights */}
            <div className="p-12 rounded-[4rem] bg-luxury-black text-white relative overflow-hidden transition-all shadow-2xl">
                <div className="absolute top-0 right-0 w-1/3 h-full bg-accent/20 blur-[120px] pointer-events-none" />
                <div className="relative z-10 flex flex-col md:flex-row items-center gap-16">
                    <div className="flex-1">
                        <h3 className="text-4xl font-serif mb-6 italic">Member Retention Protocol</h3>
                        <p className="text-stone-400 text-sm leading-relaxed font-light italic max-w-lg mb-8">
                            Our AI has identified <span className="text-white font-bold">12 High-Value clients</span> who haven't requisitioned in 30+ days. We recommend a personalized 'Essence Refill' campaign for the Spring Collection.
                        </p>
                        <button className="px-10 py-4 bg-accent text-white rounded-full text-[10px] font-bold tracking-[.3em] uppercase hover:bg-yellow-600 transition-all shadow-xl">
                            Automate Campaign
                        </button>
                    </div>
                    <div className="w-full md:w-auto flex gap-10">
                        <div className="text-center">
                            <span className="text-4xl font-serif text-accent">1.2m</span>
                            <p className="text-[10px] tracking-widest text-stone-500 uppercase mt-2">Loyalty Points Circulating</p>
                        </div>
                        <div className="text-center">
                            <span className="text-4xl font-serif text-accent">15%</span>
                            <p className="text-[10px] tracking-widest text-stone-500 uppercase mt-2">Conversion Lift from AI</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
