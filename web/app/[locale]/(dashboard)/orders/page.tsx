"use client";

import React from "react";
import { motion } from "framer-motion";
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
} from "lucide-react";

const orders = [
    {
        id: "LM-8420",
        client: "Elena Gilbert",
        product: "Lumina No. 01 (Extrait)",
        date: "Today, 14:20",
        amount: "$240",
        status: "Processing",
        type: "Standard"
    },
    {
        id: "LM-8419",
        client: "Marcus Thorne",
        product: "Bespoke AI Blend #102",
        date: "Oct 24, 10:15",
        amount: "$420",
        status: "Shipped",
        type: "Priority"
    },
    {
        id: "LM-8418",
        client: "Sophia Rossi",
        product: "Oud Mystère",
        date: "Oct 23, 16:45",
        amount: "$380",
        status: "Delivered",
        type: "Complimentary"
    },
    {
        id: "LM-8417",
        client: "Julian Vane",
        product: "Discovery Set Vol. 1",
        date: "Oct 23, 09:12",
        amount: "$85",
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

export default function OrdersPage() {
    return (
        <div className="flex flex-col gap-8">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-serif font-bold text-luxury-black dark:text-white transition-colors">Manifest Logs</h1>
                    <p className="text-sm text-stone-500 dark:text-stone-500">Track and manage global olfactory acquisitions.</p>
                </div>
                <div className="flex gap-4">
                    <button className="flex items-center gap-2 px-6 py-3 glass dark:bg-zinc-900 border border-stone-200 dark:border-white/10 rounded-2xl text-[10px] font-bold uppercase tracking-widest hover:bg-stone-50 dark:hover:bg-white/5 transition-all text-luxury-black dark:text-white">
                        <Filter size={14} /> Refine Search
                    </button>
                    <button className="bg-luxury-black dark:bg-accent text-white px-8 py-3 rounded-2xl text-[10px] font-bold tracking-widest uppercase hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-lg flex items-center gap-2">
                        <Package size={14} /> New Manual Entry
                    </button>
                </div>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {[
                    { label: "Today's Revenue", value: "$4,120", change: "+12.5%", color: "text-accent" },
                    { label: "Pending Shipments", value: "24", change: "6 Critical", color: "text-blue-500" },
                    { label: "Active Subscriptions", value: "1,204", change: "+84 this month", color: "text-emerald-500" },
                    { label: "Fulfilment Rate", value: "99.8%", change: "Near perfect", color: "text-indigo-500" }
                ].map((stat, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="glass bg-white dark:bg-zinc-900 p-6 rounded-[2rem] border border-stone-200 dark:border-white/10 shadow-sm transition-colors"
                    >
                        <p className="text-[10px] uppercase tracking-widest text-stone-500 dark:text-stone-500 font-bold mb-3">{stat.label}</p>
                        <h4 className="text-2xl font-bold text-luxury-black dark:text-white mb-2 transition-colors">{stat.value}</h4>
                        <span className={`text-[10px] font-bold ${stat.color}`}>{stat.change}</span>
                    </motion.div>
                ))}
            </div>

            <section className="glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm overflow-hidden transition-colors">
                <div className="p-8 border-b border-stone-100 dark:border-white/5 flex gap-4 items-center">
                    <div className="flex-1 relative">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400" size={16} />
                        <input
                            type="text"
                            placeholder="Find acquisitions by client or tracking ID..."
                            className="w-full pl-12 pr-6 py-3 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-xl text-xs outline-none focus:border-accent transition-all"
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead>
                            <tr className="text-[10px] font-bold tracking-[.2em] uppercase text-stone-400 border-b border-stone-100 dark:border-white/5 transition-colors">
                                <th className="p-8 pb-4">Acquisition ID</th>
                                <th className="pb-4">Client</th>
                                <th className="pb-4">Selection</th>
                                <th className="pb-4 text-center">Status</th>
                                <th className="pb-4">Settlement</th>
                                <th className="p-8 pb-4 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-stone-50 dark:divide-white/5 transition-colors">
                            {orders.map((order, i) => (
                                <tr key={i} className="group hover:bg-stone-50 dark:hover:bg-white/5 transition-all">
                                    <td className="p-8">
                                        <div className="flex flex-col">
                                            <span className="text-xs font-bold text-luxury-black dark:text-white">{order.id}</span>
                                            <span className="text-[10px] text-stone-400 font-medium">{order.date}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <div className="flex flex-col">
                                            <span className="text-xs font-bold text-luxury-black dark:text-white">{order.client}</span>
                                            <span className="text-[10px] text-stone-400 uppercase tracking-tighter">{order.type} Class</span>
                                        </div>
                                    </td>
                                    <td>
                                        <span className="text-xs text-stone-600 dark:text-stone-400 italic">{order.product}</span>
                                    </td>
                                    <td className="text-center">
                                        <span className={`inline-flex items-center gap-1.5 text-[10px] px-3 py-1 rounded-full font-bold uppercase border transition-colors ${statusStyles[order.status as keyof typeof statusStyles]}`}>
                                            <StatusIcon status={order.status} />
                                            {order.status}
                                        </span>
                                    </td>
                                    <td>
                                        <span className="text-xs font-bold text-luxury-black dark:text-white">{order.amount}</span>
                                    </td>
                                    <td className="p-8 text-right">
                                        <div className="flex justify-end gap-2">
                                            <button className="p-2 text-stone-400 hover:text-accent hover:bg-accent/5 rounded-xl transition-all">
                                                <Eye size={16} />
                                            </button>
                                            <button className="p-2 text-stone-400 hover:text-luxury-black dark:hover:text-white rounded-xl transition-all">
                                                <MoreHorizontal size={16} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                <footer className="p-8 pt-6 border-t border-stone-100 dark:border-white/5 bg-stone-50/50 dark:bg-white/5 transition-colors flex justify-between items-center text-[10px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-500">
                    <span>Registry shows 4 of 1,240 Acquisition Logs</span>
                    <div className="flex gap-4">
                        <button className="hover:text-luxury-black dark:hover:text-white transition-colors cursor-pointer">Back</button>
                        <button className="text-luxury-black dark:text-white transition-colors cursor-pointer">Advance</button>
                    </div>
                </footer>
            </section>
        </div>
    );
}
