'use client';

import React from 'react';
import { motion } from 'framer-motion';
import {
    Package,
    Search,
    Filter,
    Eye,
    MoreHorizontal,
    CheckCircle2,
    Clock,
    Truck,
    AlertCircle
} from 'lucide-react';

const orders = [
    {
        id: "AURA-8420",
        client: "Elena Gilbert",
        product: "Lumina No. 01 (Extrait)",
        date: "Today, 14:20",
        amount: "5.400.000đ",
        status: "Processing",
        type: "Standard"
    },
    {
        id: "AURA-8419",
        client: "Marcus Thorne",
        product: "Bespoke AI Blend #102",
        date: "Oct 24, 10:15",
        amount: "8.200.000đ",
        status: "Shipped",
        type: "Priority"
    },
    {
        id: "AURA-8418",
        client: "Sophia Rossi",
        product: "Oud Mystère",
        date: "Oct 23, 16:45",
        amount: "6.800.000đ",
        status: "Delivered",
        type: "Complimentary"
    },
    {
        id: "AURA-8417",
        client: "Julian Vane",
        product: "Discovery Set Vol. 1",
        date: "Oct 23, 09:12",
        amount: "2.000.000đ",
        status: "Cancelled",
        type: "Standard"
    }
];

const statusStyles = {
    "Processing": "bg-blue-50 dark:bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-100 dark:border-blue-500/20",
    "Shipped": "bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 border-indigo-100 dark:border-indigo-500/20",
    "Delivered": "bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-100 dark:border-emerald-500/20",
    "Cancelled": "bg-stone-50 dark:bg-white/5 text-stone-400 dark:text-stone-500 border-stone-100 dark:border-white/10"
};

const StatusIcon = ({ status }: { status: string }) => {
    switch (status) {
        case "Processing": return <Clock size={12} />;
        case "Shipped": return <Truck size={12} />;
        case "Delivered": return <CheckCircle2 size={12} />;
        case "Cancelled": return <AlertCircle size={12} />;
        default: return null;
    }
};

export default function StaffOrdersPage() {
    return (
        <div className="flex flex-col gap-10 py-10 px-8">
            <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                <div>
                    <h1 className="text-3xl font-serif font-bold text-luxury-black dark:text-white transition-colors">Manifest Logs</h1>
                    <p className="text-sm text-stone-500 dark:text-stone-500 tracking-wide">Track and manage global olfactory acquisitions.</p>
                </div>
                <div className="flex gap-4">
                    <button className="flex items-center gap-2 px-6 py-4 glass dark:bg-zinc-900 border border-stone-200 dark:border-white/10 rounded-2xl text-[10px] font-bold uppercase tracking-[.2em] hover:bg-stone-50 dark:hover:bg-white/5 transition-all text-luxury-black dark:text-white cursor-pointer">
                        <Filter size={14} /> Refine Search
                    </button>
                    <button className="bg-luxury-black dark:bg-gold text-white px-8 py-4 rounded-2xl text-[10px] font-bold tracking-[.2em] uppercase hover:bg-stone-800 dark:hover:bg-gold/80 transition-all shadow-xl flex items-center gap-2 cursor-pointer">
                        <Package size={14} /> New Manual Entry
                    </button>
                </div>
            </header>

            {/* Performance Stats */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
                {[
                    { label: "Daily Revenue", value: "24.5M đ", change: "+12.5%", color: "text-gold" },
                    { label: "Pending Shipments", value: "24", change: "6 Critical", color: "text-blue-500" },
                    { label: "Active Subscriptions", value: "1,204", change: "+84 this month", color: "text-emerald-500" },
                    { label: "Fulfilment Rate", value: "99.8%", change: "Near perfect", color: "text-indigo-500" }
                ].map((stat, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm transition-all hover:shadow-md"
                    >
                        <p className="text-[10px] uppercase tracking-[.3em] text-stone-500 dark:text-stone-500 font-bold mb-4">{stat.label}</p>
                        <h4 className="text-2xl font-bold text-luxury-black dark:text-white mb-2 transition-colors">{stat.value}</h4>
                        <span className={`text-[10px] font-bold tracking-widest uppercase ${stat.color}`}>{stat.change}</span>
                    </motion.div>
                ))}
            </div>

            {/* Orders Table Section */}
            <section className="glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-200 dark:border-white/10 shadow-sm overflow-hidden transition-all">
                <div className="p-10 border-b border-stone-100 dark:border-white/5 flex gap-6 items-center">
                    <div className="flex-1 relative">
                        <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-400" size={18} />
                        <input
                            type="text"
                            placeholder="Find acquisitions by client or tracking ID..."
                            className="w-full pl-16 pr-8 py-4 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl text-xs outline-none focus:border-gold transition-all shadow-inner"
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead>
                            <tr className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-400 border-b border-stone-100 dark:border-white/5 transition-colors">
                                <th className="p-10 pb-6">Acquisition ID</th>
                                <th className="pb-6">Client</th>
                                <th className="pb-6">Selection</th>
                                <th className="pb-6 text-center">Status</th>
                                <th className="pb-6">Settlement</th>
                                <th className="p-10 pb-6 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-stone-50 dark:divide-white/5 transition-colors">
                            {orders.map((order, i) => (
                                <tr key={i} className="group hover:bg-stone-50 dark:hover:bg-white/5 transition-all">
                                    <td className="p-10">
                                        <div className="flex flex-col">
                                            <span className="text-sm font-bold text-luxury-black dark:text-white tracking-widest">{order.id}</span>
                                            <span className="text-[10px] text-stone-400 font-bold tracking-tight mt-1 uppercase">{order.date}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <div className="flex flex-col">
                                            <span className="text-sm font-bold text-luxury-black dark:text-white">{order.client}</span>
                                            <span className="text-[10px] text-stone-500 uppercase tracking-[.2em] font-bold mt-1">{order.type} Class</span>
                                        </div>
                                    </td>
                                    <td>
                                        <span className="text-sm text-stone-600 dark:text-stone-400 italic font-serif">{order.product}</span>
                                    </td>
                                    <td className="text-center">
                                        <span className={`inline-flex items-center gap-2 text-[9px] px-4 py-1.5 rounded-full font-bold uppercase border transition-all ${statusStyles[order.status as keyof typeof statusStyles]}`}>
                                            <StatusIcon status={order.status} />
                                            {order.status}
                                        </span>
                                    </td>
                                    <td>
                                        <span className="text-sm font-bold text-metropolis-black dark:text-white tracking-wider">{order.amount}</span>
                                    </td>
                                    <td className="p-10 text-right">
                                        <div className="flex justify-end gap-3">
                                            <button className="p-3 text-stone-400 hover:text-gold hover:bg-gold/5 rounded-2xl transition-all cursor-pointer">
                                                <Eye size={18} />
                                            </button>
                                            <button className="p-3 text-stone-400 hover:text-luxury-black dark:hover:text-white hover:bg-stone-100 dark:hover:bg-white/5 rounded-2xl transition-all cursor-pointer">
                                                <MoreHorizontal size={18} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                <footer className="p-10 pt-8 border-t border-stone-100 dark:border-white/5 bg-stone-50/30 dark:bg-white/2 transition-colors flex flex-col md:flex-row justify-between items-center gap-6 text-[10px] font-bold uppercase tracking-[.3em] text-stone-500">
                    <span className="tracking-widest">Registry shows 4 of 1,240 Acquisition Logs</span>
                    <div className="flex gap-8">
                        <button className="hover:text-gold transition-colors cursor-pointer tracking-[.4em]">Previous Page</button>
                        <button className="text-luxury-black dark:text-white hover:text-gold dark:hover:text-gold transition-colors cursor-pointer tracking-[.4em]">Next Page Matrix</button>
                    </div>
                </footer>
            </section>
        </div>
    );
}
