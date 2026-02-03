'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { motion } from 'framer-motion';
import {
    MapPin,
    Truck,
    PackageCheck,
    Calendar,
    ChevronRight,
    Loader2,
    Clock,
    XCircle,
    Receipt
} from 'lucide-react';
import { orderService, type Order } from '@/services/order.service';
import { AuthGuard } from '@/components/auth/auth-guard';
import { cn } from '@/lib/utils';

const STATUS_CONFIG = {
    PENDING: { label: 'Chờ xác nhận', color: 'bg-amber-500/10 text-amber-600 border-amber-500/20', icon: Clock },
    CONFIRMED: { label: 'Đã xác nhận', color: 'bg-blue-500/10 text-blue-600 border-blue-500/20', icon: PackageCheck },
    PROCESSING: { label: 'Đang chuẩn bị', color: 'bg-purple-500/10 text-purple-600 border-purple-500/20', icon: PackageCheck },
    SHIPPED: { label: 'Đang giao hàng', color: 'bg-orange-500/10 text-orange-600 border-orange-500/20', icon: Truck },
    COMPLETED: { label: 'Hoàn thành', color: 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20', icon: PackageCheck },
    CANCELLED: { label: 'Đã hủy', color: 'bg-red-500/10 text-red-600 border-red-500/20', icon: XCircle },
};

export default function CustomerOrdersPage() {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchOrders = useCallback(async () => {
        try {
            const data = await orderService.listMy();
            setOrders(data);
        } catch (error) {
            console.error('Failed to fetch my orders:', error);
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchOrders();
    }, [fetchOrders]);

    return (
        <AuthGuard allowedRoles={['customer', 'staff', 'admin']}>
            <div className="flex flex-col gap-10 py-10 px-8">
                <header className="mb-2">
                    <h1 className="text-4xl md:text-5xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">
                        My <span className="italic">Acquisitions</span>
                    </h1>
                    <p className="text-[10px] text-stone-500 uppercase tracking-[.4em] font-bold">
                        Registry of your unique olfactory journey.
                    </p>
                </header>

                <div className="space-y-8">
                    {loading ? (
                        <div className="py-20 flex justify-center">
                            <Loader2 className="animate-spin text-gold" size={40} />
                        </div>
                    ) : orders.length === 0 ? (
                        <div className="py-20 text-center space-y-6 glass rounded-[3rem] border border-stone-100 dark:border-white/5 bg-white dark:bg-zinc-900">
                            <Receipt className="mx-auto text-stone-200 dark:text-white/5" size={80} strokeWidth={1} />
                            <div className="space-y-2">
                                <h3 className="text-xl font-serif text-luxury-black dark:text-white">The Archival Registry is Empty</h3>
                                <p className="text-[10px] font-bold tracking-widest uppercase text-stone-400">Start your journey into luxury scents today.</p>
                            </div>
                        </div>
                    ) : (
                        orders.map((order, i) => {
                            const style = STATUS_CONFIG[order.status as keyof typeof STATUS_CONFIG] || STATUS_CONFIG.PENDING;
                            const StatusIcon = style.icon;

                            return (
                                <motion.div
                                    key={order.id}
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ delay: i * 0.1 }}
                                    className="glass bg-white dark:bg-zinc-900 rounded-[3rem] p-8 border border-stone-100 dark:border-white/5 shadow-sm hover:shadow-xl transition-all"
                                >
                                    <div className="flex flex-col lg:flex-row gap-8">
                                        {/* Order Brief */}
                                        <div className="flex-1">
                                            <div className="flex flex-wrap justify-between items-start gap-4 mb-6">
                                                <div>
                                                    <span className="text-[9px] font-bold text-gold uppercase tracking-[.4em] mb-2 block">
                                                        Order {order.code}
                                                    </span>
                                                    <h2 className="text-2xl font-serif text-luxury-black dark:text-white mb-1 transition-colors">
                                                        {order.items?.[0]?.product?.name || 'Fragrance Acquisition'}
                                                        {order.items && order.items.length > 1 && <span className="text-sm italic text-stone-400 ml-2"> (+{order.items.length - 1} more)</span>}
                                                    </h2>
                                                    <p className="text-[9px] text-stone-400 font-bold uppercase tracking-widest flex items-center gap-2">
                                                        <Calendar size={12} />
                                                        {new Date(order.createdAt!).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                                                    </p>
                                                </div>
                                                <div className="text-right">
                                                    <span className="text-xl font-serif text-luxury-black dark:text-white block mb-2">
                                                        {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(order.finalAmount)}
                                                    </span>
                                                    <div className={cn(
                                                        "inline-flex items-center gap-2 text-[8px] px-4 py-1.5 rounded-full font-bold uppercase tracking-widest border",
                                                        style.color
                                                    )}>
                                                        <StatusIcon size={12} />
                                                        {style.label}
                                                    </div>
                                                </div>
                                            </div>

                                            <div className="grid md:grid-cols-2 gap-6 border-t border-stone-100 dark:border-white/5 pt-6">
                                                <div className="flex items-start gap-4">
                                                    <div className="p-2.5 bg-stone-50 dark:bg-white/5 rounded-2xl text-stone-400 border border-stone-100 dark:border-white/5">
                                                        <MapPin size={16} />
                                                    </div>
                                                    <div>
                                                        <h4 className="text-[8px] font-bold text-stone-400 uppercase tracking-widest mb-1">Destination</h4>
                                                        <p className="text-[10px] text-stone-500 dark:text-stone-300 font-medium leading-relaxed uppercase tracking-tight line-clamp-2">
                                                            {order.shippingAddress}
                                                        </p>
                                                    </div>
                                                </div>
                                                <div className="flex items-end justify-end">
                                                    <button className="text-[10px] font-bold uppercase tracking-widest text-luxury-black dark:text-white flex items-center gap-2 hover:text-gold transition-colors group">
                                                        View Full Manifest <ChevronRight size={14} className="group-hover:translate-x-1 transition-transform" />
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </motion.div>
                            );
                        })
                    )}
                </div>

                <footer className="mt-10 pt-10 border-t border-stone-100 dark:border-white/5 text-center">
                    <p className="text-[8px] font-bold uppercase tracking-[.4em] text-stone-400">
                        Aura AI Neural Commerce Engine v2.0
                    </p>
                </footer>
            </div>
        </AuthGuard>
    );
}
