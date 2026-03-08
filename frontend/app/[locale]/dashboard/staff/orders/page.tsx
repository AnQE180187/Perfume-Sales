'use client';

import React, { useEffect, useState } from 'react';
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
    AlertCircle,
    Loader2
} from 'lucide-react';
import { staffOrdersService, type StaffPosOrder } from '@/services/staff-orders.service';

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
    const [orders, setOrders] = useState<StaffPosOrder[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const load = async () => {
            setLoading(true);
            setError(null);
            try {
                const res = await staffOrdersService.list({ take: 50 });
                setOrders(res.data);
            } catch (e: any) {
                setError(e.message || 'Failed to load staff orders');
            } finally {
                setLoading(false);
            }
        };
        void load();
    }, []);

    const formatMoney = (n: number) =>
        new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(n);

    return (
        <div className="flex flex-col gap-10 py-10 px-8">
            <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                <div>
                    <h1 className="text-3xl font-serif font-bold text-luxury-black dark:text-white transition-colors">POS Orders</h1>
                    <p className="text-sm text-stone-500 dark:text-stone-500 tracking-wide">Orders created at the boutique counter.</p>
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

            {error && (
                <div className="text-xs text-red-500">
                    {error}
                </div>
            )}

            {/* Orders Table Section */}
            <section className="glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-200 dark:border-white/10 shadow-sm overflow-hidden transition-all">
                <div className="p-10 border-b border-stone-100 dark:border-white/5 flex gap-6 items-center">
                    <div className="flex-1 relative">
                        <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-400" size={18} />
                        <input
                            type="text"
                            placeholder="Find orders by code or product..."
                            className="w-full pl-16 pr-8 py-4 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl text-xs outline-none focus:border-gold transition-all shadow-inner"
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    {loading ? (
                        <div className="flex items-center justify-center py-10 text-sm text-muted-foreground">
                            <Loader2 className="w-4 h-4 mr-2 animate-spin" /> Loading orders…
                        </div>
                    ) : orders.length === 0 ? (
                        <div className="flex items-center justify-center py-10 text-sm text-muted-foreground">
                            No POS orders found.
                        </div>
                    ) : (
                        <table className="w-full text-left">
                            <thead>
                                <tr className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-400 border-b border-stone-100 dark:border-white/5 transition-colors">
                                    <th className="p-10 pb-6">Order Code</th>
                                    <th className="pb-6">Created At</th>
                                    <th className="pb-6">Items</th>
                                    <th className="pb-6 text-center">Status</th>
                                    <th className="pb-6">Total</th>
                                    <th className="p-10 pb-6 text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-stone-50 dark:divide-white/5 transition-colors">
                                {orders.map((order) => {
                                    const firstItem = order.items[0];
                                    const itemSummary = firstItem
                                        ? `${firstItem.product.name} x${firstItem.quantity}${
                                              order.items.length > 1 ? ` +${order.items.length - 1} more` : ''
                                          }`
                                        : '—';
                                    const statusLabel =
                                        order.status === 'COMPLETED'
                                            ? 'Completed'
                                            : order.paymentStatus === 'PAID'
                                            ? 'Paid'
                                            : 'Pending';
                                    const statusKey =
                                        statusLabel === 'Completed'
                                            ? 'Delivered'
                                            : statusLabel === 'Paid'
                                            ? 'Shipped'
                                            : 'Processing';

                                    return (
                                        <tr key={order.id} className="group hover:bg-stone-50 dark:hover:bg-white/5 transition-all">
                                            <td className="p-10">
                                                <div className="flex flex-col">
                                                    <span className="text-sm font-bold text-luxury-black dark:text-white tracking-widest">
                                                        {order.code}
                                                    </span>
                                                    <span className="text-[10px] text-stone-400 font-bold tracking-tight mt-1 uppercase">
                                                        POS
                                                    </span>
                                                </div>
                                            </td>
                                            <td>
                                                <div className="flex flex-col">
                                                    <span className="text-sm font-bold text-luxury-black dark:text-white">
                                                        {new Date(order.createdAt).toLocaleString('vi-VN')}
                                                    </span>
                                                </div>
                                            </td>
                                            <td>
                                                <span className="text-sm text-stone-600 dark:text-stone-400 italic font-serif">
                                                    {itemSummary}
                                                </span>
                                            </td>
                                            <td className="text-center">
                                                <span
                                                    className={`inline-flex items-center gap-2 text-[9px] px-4 py-1.5 rounded-full font-bold uppercase border transition-all ${
                                                        statusStyles[statusKey as keyof typeof statusStyles]
                                                    }`}
                                                >
                                                    <StatusIcon status={statusKey} />
                                                    {statusLabel}
                                                </span>
                                            </td>
                                            <td>
                                                <span className="text-sm font-bold text-metropolis-black dark:text-white tracking-wider">
                                                    {formatMoney(order.finalAmount)}
                                                </span>
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
                                    );
                                })}
                            </tbody>
                        </table>
                    )}
                </div>

                <footer className="p-10 pt-8 border-t border-stone-100 dark:border-white/5 bg-stone-50/30 dark:bg-white/2 transition-colors flex flex-col md:flex-row justify-between items-center gap-6 text-[10px] font-bold uppercase tracking-[.3em] text-stone-500">
                    <span className="tracking-widest">
                        Registry shows {orders.length} POS orders
                    </span>
                    <div className="flex gap-8">
                        <button className="hover:text-gold transition-colors cursor-pointer tracking-[.4em]">Previous Page</button>
                        <button className="text-luxury-black dark:text-white hover:text-gold dark:hover:text-gold transition-colors cursor-pointer tracking-[.4em]">Next Page Matrix</button>
                    </div>
                </footer>
            </section>
        </div>
    );
}
