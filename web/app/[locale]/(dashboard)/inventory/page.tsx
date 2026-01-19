"use client";

import React, { useState } from "react";
import Image from "next/image";
import { motion, AnimatePresence } from "framer-motion";
import {
    Plus,
    Search,
    Filter,
    MoreVertical,
    AlertCircle,
    ArrowUpDown,
    BarChart3,
    RefreshCcw,
    Edit3,
    Trash2,
    CheckCircle2,
    ChevronDown,
    Layers,
    Activity,
    Package
} from "lucide-react";

const inventory = [
    { id: "1", name: "Lumina No. 01", sku: "LMN-001", stock: 142, status: "Healthy", category: "Niche", price: 240, expiry: "2027-12", platform: "Omnichannel" },
    { id: "2", name: "Oud Mystère", sku: "LMN-008", stock: 12, status: "Low Stock", category: "Prestige", price: 380, expiry: "2026-06", platform: "E-commerce" },
    { id: "3", name: "Santal Bloom", sku: "LMN-015", stock: 0, status: "Out of Stock", category: "Botanical", price: 195, expiry: "2026-01", platform: "Retail Only" },
    { id: "4", name: "Amber Noir", sku: "LMN-022", stock: 85, status: "Healthy", category: "Extraits", price: 290, expiry: "2028-03", platform: "Omnichannel" },
    { id: "5", name: "Bergamot Sky", sku: "LMN-042", stock: 210, status: "Overstock", category: "Cologne", price: 180, expiry: "2025-11", platform: "Shopee Sync" },
];

export default function InventoryPage() {
    const [searchTerm, setSearchTerm] = useState("");
    const [activeTab, setActiveTab] = useState("Warehouse Registry");

    return (
        <div className="space-y-10 pb-20">
            {/* Header Area */}
            <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
                <div>
                    <h1 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors tracking-tight">Digital <span className="italic">Warehouse</span></h1>
                    <p className="text-[10px] text-stone-400 font-bold tracking-[.4em] uppercase mt-2">Managing the physical manifestation of scent.</p>
                </div>
                <div className="flex gap-4 w-full md:w-auto">
                    <button className="flex-1 md:flex-none px-6 py-3 border border-stone-200 dark:border-white/10 rounded-full text-[10px] font-bold tracking-widest uppercase text-stone-500 hover:text-luxury-black dark:hover:text-white transition-all flex items-center justify-center gap-3">
                        <RefreshCcw size={14} /> Global Sync
                    </button>
                    <button className="flex-1 md:flex-none px-8 py-3 bg-luxury-black dark:bg-accent text-white rounded-full text-[10px] font-bold tracking-widest uppercase shadow-xl flex items-center justify-center gap-3 group">
                        <Plus size={16} className="group-hover:rotate-90 transition-transform" /> Add New Essence
                    </button>
                </div>
            </div>

            {/* Sub Navigation */}
            <div className="flex gap-10 border-b border-stone-100 dark:border-white/5 pb-1">
                {["Warehouse Registry", "Channel Distribution", "Critical Alerts"].map((tab) => (
                    <button
                        key={tab}
                        onClick={() => setActiveTab(tab)}
                        className={`pb-4 text-[10px] font-bold uppercase tracking-[.2em] transition-all relative ${activeTab === tab ? "text-accent" : "text-stone-400 hover:text-stone-600 dark:hover:text-stone-200"
                            }`}
                    >
                        {tab}
                        {activeTab === tab && (
                            <motion.div layoutId="invTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-accent" />
                        )}
                    </button>
                ))}
            </div>

            {activeTab === "Warehouse Registry" && (
                <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="space-y-8"
                >
                    {/* Inventory Table Controls */}
                    <div className="flex flex-col md:flex-row justify-between items-center gap-6 p-4 glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                        <div className="relative w-full md:w-96 group">
                            <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300 dark:text-stone-700 group-focus-within:text-accent transition-colors" size={18} />
                            <input
                                type="text"
                                placeholder="Search SKU, name, or category..."
                                className="w-full bg-stone-50 dark:bg-white/5 border border-transparent focus:border-accent rounded-full py-3.5 pl-14 pr-6 text-xs outline-none transition-all placeholder:text-stone-400"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                            />
                        </div>
                        <div className="flex items-center gap-6 w-full md:w-auto overflow-x-auto pb-2 md:pb-0 px-4">
                            <button className="flex items-center gap-2 text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors">
                                <Filter size={14} /> Category <ChevronDown size={14} />
                            </button>
                            <button className="flex items-center gap-2 text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors">
                                <ArrowUpDown size={14} /> Sort By
                            </button>
                        </div>
                    </div>

                    {/* Inventory List */}
                    <div className="overflow-x-auto border border-stone-100 dark:border-white/5 rounded-[2.5rem] bg-white dark:bg-zinc-900 shadow-sm transition-colors">
                        <table className="w-full text-left">
                            <thead className="bg-stone-50/50 dark:bg-white/2 border-b border-stone-100 dark:border-white/5 transition-colors">
                                <tr className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-400">
                                    <th className="px-8 py-6">Essence / SKU</th>
                                    <th className="px-8 py-6">Category</th>
                                    <th className="px-8 py-6 text-center">In Stock</th>
                                    <th className="px-8 py-6 text-center">Status</th>
                                    <th className="px-8 py-6 text-right pr-12">Action</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-stone-50 dark:divide-white/5 transition-colors">
                                {inventory.map((item) => (
                                    <tr key={item.id} className="group hover:bg-stone-50/80 dark:hover:bg-white/5 transition-all">
                                        <td className="px-8 py-6">
                                            <div className="flex items-center gap-4">
                                                <div className="w-12 h-16 relative rounded-2xl overflow-hidden bg-stone-100 dark:bg-zinc-800 flex-shrink-0 border border-stone-100 dark:border-white/10">
                                                    <Image src="/images/hero.png" alt={item.name} fill className="object-cover group-hover:scale-110 transition-transform duration-500" />
                                                </div>
                                                <div>
                                                    <h4 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-wider">{item.name}</h4>
                                                    <p className="text-[10px] text-accent font-mono mt-1 uppercase">{item.sku}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{item.category}</span>
                                        </td>
                                        <td className="px-8 py-6 text-center">
                                            <span className={`text-sm font-bold ${item.stock <= 12 ? "text-red-500" : "text-luxury-black dark:text-white"}`}>{item.stock}</span>
                                            <p className="text-[8px] text-stone-500 uppercase tracking-widest mt-1">Units</p>
                                        </td>
                                        <td className="px-8 py-6 text-center">
                                            <div className={`inline-flex items-center gap-2 px-3 py-1 rounded-full text-[9px] font-bold uppercase tracking-widest border transition-colors ${item.status === 'Healthy' ? 'bg-green-500/10 text-green-500 border-green-500/20' :
                                                item.status === 'Low Stock' ? 'bg-orange-500/10 text-orange-500 border-orange-500/20' :
                                                    item.status === 'Out of Stock' ? 'bg-red-500/10 text-red-500 border-red-500/20' :
                                                        'bg-blue-500/10 text-blue-500 border-blue-500/20'
                                                }`}>
                                                {item.status}
                                            </div>
                                        </td>
                                        <td className="px-8 py-6 text-right pr-12">
                                            <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                <button className="p-3 bg-stone-50 dark:bg-white/5 hover:bg-black dark:hover:bg-accent hover:text-white rounded-xl transition-all border border-stone-100 dark:border-white/10 shadow-sm">
                                                    <Edit3 size={16} />
                                                </button>
                                                <button className="p-3 bg-stone-50 dark:bg-white/5 hover:bg-red-500 hover:text-white rounded-xl transition-all border border-stone-100 dark:border-white/10 shadow-sm">
                                                    <Trash2 size={16} />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </motion.div>
            )}

            {activeTab === "Channel Distribution" && (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                    {[
                        { label: "Shopee Integration", status: "Active", sync: "2 mins ago", health: 98, icon: Activity },
                        { label: "Retail POS Nodes", status: "Connected", sync: "Real-time", health: 100, icon: Package },
                        { label: "Lumina Direct", status: "Healthy", sync: "Live", health: 100, icon: Layers }
                    ].map((p, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ delay: i * 0.1 }}
                            className="p-10 rounded-[3rem] bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 flex flex-col gap-8 shadow-sm group hover:border-accent transition-all"
                        >
                            <div className="flex justify-between items-start">
                                <div className="w-14 h-14 rounded-2xl bg-stone-50 dark:bg-white/5 flex items-center justify-center text-stone-400 group-hover:text-accent transition-colors">
                                    <p.icon size={26} strokeWidth={1} />
                                </div>
                                <div className="flex items-center gap-1.5 px-3 py-1 bg-green-500/10 text-green-500 rounded-full text-[9px] font-bold uppercase tracking-widest border border-green-500/20">
                                    <div className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" /> {p.status}
                                </div>
                            </div>
                            <div>
                                <h3 className="text-lg font-serif italic mb-1 text-luxury-black dark:text-white">{p.label}</h3>
                                <p className="text-[10px] text-stone-400 font-bold uppercase tracking-widest underline underline-offset-4 decoration-stone-200">Last Pulse: {p.sync}</p>
                            </div>
                            <div className="flex items-end justify-between pt-6 border-t border-stone-50 dark:border-white/5">
                                <div className="text-left">
                                    <span className="text-3xl font-serif text-luxury-black dark:text-white">{p.health}%</span>
                                    <p className="text-[10px] text-stone-500 uppercase tracking-widest font-bold">Integrity</p>
                                </div>
                                <button className="p-3 rounded-xl border border-stone-100 dark:border-white/10 text-stone-400 hover:text-accent hover:bg-accent/5 transition-all">
                                    <RefreshCcw size={16} />
                                </button>
                            </div>
                        </motion.div>
                    ))}
                </div>
            )}

            {activeTab === "Critical Alerts" && (
                <div className="space-y-6">
                    {inventory.filter(i => i.stock <= 12).map((item, idx) => (
                        <motion.div
                            key={item.id}
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: idx * 0.1 }}
                            className="p-8 bg-red-50 dark:bg-red-500/5 border border-red-100 dark:border-red-500/20 rounded-[2.5rem] flex items-center justify-between gap-8 group"
                        >
                            <div className="flex items-center gap-6">
                                <div className="w-14 h-14 rounded-full bg-red-100 dark:bg-red-500/10 flex items-center justify-center text-red-500 flex-shrink-0">
                                    <AlertCircle size={24} />
                                </div>
                                <div>
                                    <h3 className="text-lg font-bold text-red-600 dark:text-red-400 uppercase tracking-wide italic">{item.name}</h3>
                                    <p className="text-xs text-red-500/70 uppercase tracking-widest font-bold">Critical Scarcity: {item.stock} Units Remaining</p>
                                </div>
                            </div>
                            <button className="px-8 py-3 bg-red-600 text-white rounded-full text-[10px] font-bold tracking-[.3em] uppercase hover:bg-black transition-all shadow-lg group-hover:scale-105 duration-300">
                                REPLENISH NOW
                            </button>
                        </motion.div>
                    ))}
                </div>
            )}

            {/* Bottom Insight */}
            <div className="p-12 bg-luxury-black dark:bg-stone-900/50 rounded-[4rem] text-white flex flex-col lg:flex-row items-center justify-between gap-12 overflow-hidden relative shadow-2xl border border-white/5">
                <div className="absolute top-0 right-0 w-1/2 h-full bg-accent/15 blur-[140px] pointer-events-none" />
                <div className="relative z-10 flex items-center gap-10">
                    <div className="w-20 h-20 rounded-[2rem] bg-white text-accent flex items-center justify-center shadow-[0_0_50px_rgba(202,138,4,0.3)] group">
                        <BarChart3 size={38} className="group-hover:scale-110 transition-transform duration-500" />
                    </div>
                    <div>
                        <h3 className="text-3xl font-serif mb-3 italic tracking-tight">Stock Intelligence</h3>
                        <p className="text-stone-400 text-sm font-light max-w-sm leading-relaxed">
                            Predictive analytics suggest <span className="text-white font-bold underline decoration-accent underline-offset-4">Oud Mystère</span> demand will surge by 15% next weekend.
                        </p>
                    </div>
                </div>
                <div className="relative z-10">
                    <button className="px-10 py-5 bg-white text-luxury-black rounded-full text-[10px] font-bold tracking-[.4em] uppercase hover:bg-accent hover:text-white transition-all shadow-xl hover:-translate-y-1">
                        VIEW DETAILED PROJECTIONS
                    </button>
                </div>
            </div>
        </div>
    );
}

