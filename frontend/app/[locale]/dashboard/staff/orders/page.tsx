'use client';

import React, { useEffect, useState, useCallback, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
    Package, Search, Eye, CheckCircle2, Clock, AlertCircle,
    Loader2, X, CreditCard, User, Calendar
} from 'lucide-react';
import { staffOrdersService, type StaffPosOrder } from '@/services/staff-orders.service';
import { AuthGuard } from '@/components/auth/auth-guard';

const formatMoney = (n: number) =>
    new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(n);

function getStatusBadge(order: StaffPosOrder) {
    if (order.status === 'COMPLETED') return { label: 'Completed', color: 'bg-emerald-500/10 border-emerald-500/20 text-emerald-500', icon: CheckCircle2 };
    if (order.paymentStatus === 'PAID') return { label: 'Paid', color: 'bg-blue-500/10 border-blue-500/20 text-blue-500', icon: CreditCard };
    if (order.status === 'CANCELLED') return { label: 'Cancelled', color: 'bg-stone-500/10 border-stone-500/20 text-stone-500', icon: AlertCircle };
    return { label: 'Pending', color: 'bg-amber-500/10 border-amber-500/20 text-amber-500', icon: Clock };
}

export default function StaffOrdersPage() {
    const [orders, setOrders] = useState<StaffPosOrder[]>([]);
    const [total, setTotal] = useState(0);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedOrder, setSelectedOrder] = useState<StaffPosOrder | null>(null);
    const [loadingDetail, setLoadingDetail] = useState(false);
    const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

    const loadOrders = useCallback(async (search?: string) => {
        setLoading(true);
        setError(null);
        try {
            const res = await staffOrdersService.list({ take: 50, search: search || undefined });
            setOrders(res.data);
            setTotal(res.total);
        } catch (e: any) {
            setError(e.message || 'Failed to load staff orders');
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        void loadOrders();
    }, [loadOrders]);

    const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const value = e.target.value;
        setSearchTerm(value);
        if (debounceRef.current) clearTimeout(debounceRef.current);
        debounceRef.current = setTimeout(() => {
            void loadOrders(value);
        }, 400);
    };

    const handleViewDetail = async (orderId: string) => {
        setLoadingDetail(true);
        try {
            const detail = await staffOrdersService.getDetail(orderId);
            setSelectedOrder(detail);
        } catch {
            // fallback to the inline data
            const found = orders.find(o => o.id === orderId);
            if (found) setSelectedOrder(found);
        } finally {
            setLoadingDetail(false);
        }
    };

    return (
        <AuthGuard allowedRoles={['staff', 'admin']}>
            <div className="flex flex-col gap-10 py-10 px-8">
                <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                    <div>
                        <h1 className="text-3xl font-heading uppercase tracking-tighter gold-gradient">POS Orders</h1>
                        <p className="text-sm text-muted-foreground uppercase tracking-widest">Orders created at the boutique counter.</p>
                    </div>
                </header>

                {error && (
                    <div className="text-xs text-red-500 bg-red-500/5 border border-red-500/20 rounded-xl px-3 py-2">
                        {error}
                    </div>
                )}

                {/* Orders Table Section */}
                <section className="glass rounded-[3rem] border border-border shadow-sm overflow-hidden transition-all">
                    <div className="p-10 border-b border-border/50 flex gap-6 items-center">
                        <div className="flex-1 relative">
                            <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-muted-foreground" size={18} />
                            <input
                                type="text"
                                value={searchTerm}
                                onChange={handleSearchChange}
                                placeholder="Search by order code, phone number, or customer name…"
                                className="w-full pl-16 pr-8 py-4 bg-secondary/30 border border-border rounded-2xl text-xs outline-none focus:border-gold/50 transition-all"
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
                                    <tr className="text-[10px] font-bold tracking-[.3em] uppercase text-muted-foreground border-b border-border/50 transition-colors">
                                        <th className="p-10 pb-6">Order Code</th>
                                        <th className="pb-6">Created At</th>
                                        <th className="pb-6">Items</th>
                                        <th className="pb-6 text-center">Status</th>
                                        <th className="pb-6">Total</th>
                                        <th className="p-10 pb-6 text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-border/30 transition-colors">
                                    {orders.map((order) => {
                                        const firstItem = order.items[0];
                                        const itemSummary = firstItem
                                            ? `${firstItem.product?.name ?? 'Product'} x${firstItem.quantity}${order.items.length > 1 ? ` +${order.items.length - 1} more` : ''
                                            }`
                                            : '—';
                                        const badge = getStatusBadge(order);
                                        const BadgeIcon = badge.icon;

                                        return (
                                            <tr key={order.id} className="group hover:bg-secondary/20 transition-all">
                                                <td className="p-10">
                                                    <div className="flex flex-col">
                                                        <span className="text-sm font-bold tracking-widest font-heading">
                                                            {order.code}
                                                        </span>
                                                        <span className="text-[10px] text-muted-foreground font-bold tracking-tight mt-1 uppercase">
                                                            POS
                                                        </span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span className="text-sm font-heading">
                                                        {new Date(order.createdAt).toLocaleString('vi-VN')}
                                                    </span>
                                                </td>
                                                <td>
                                                    <span className="text-sm text-muted-foreground italic">
                                                        {itemSummary}
                                                    </span>
                                                </td>
                                                <td className="text-center">
                                                    <span className={`inline-flex items-center gap-2 text-[9px] px-4 py-1.5 rounded-full font-bold uppercase border transition-all ${badge.color}`}>
                                                        <BadgeIcon size={12} />
                                                        {badge.label}
                                                    </span>
                                                </td>
                                                <td>
                                                    <span className="text-sm font-bold font-heading tracking-wider">
                                                        {formatMoney(order.finalAmount)}
                                                    </span>
                                                </td>
                                                <td className="p-10 text-right">
                                                    <button
                                                        onClick={() => handleViewDetail(order.id)}
                                                        className="p-3 text-muted-foreground hover:text-gold hover:bg-gold/5 rounded-2xl transition-all cursor-pointer"
                                                    >
                                                        <Eye size={18} />
                                                    </button>
                                                </td>
                                            </tr>
                                        );
                                    })}
                                </tbody>
                            </table>
                        )}
                    </div>

                    <footer className="p-10 pt-8 border-t border-border/50 flex justify-between items-center text-[10px] font-bold uppercase tracking-[.3em] text-muted-foreground">
                        <span className="tracking-widest">
                            Showing {orders.length} of {total} POS orders
                        </span>
                    </footer>
                </section>

                {/* Order Detail Modal */}
                <AnimatePresence>
                    {selectedOrder && (
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm"
                            onClick={() => setSelectedOrder(null)}
                        >
                            <motion.div
                                initial={{ scale: 0.9, opacity: 0 }}
                                animate={{ scale: 1, opacity: 1 }}
                                exit={{ scale: 0.9, opacity: 0 }}
                                onClick={(e) => e.stopPropagation()}
                                className="bg-background border border-border rounded-[2.5rem] p-10 max-w-lg w-full shadow-2xl relative max-h-[90vh] overflow-y-auto custom-scrollbar"
                            >
                                <button
                                    onClick={() => setSelectedOrder(null)}
                                    className="absolute top-6 right-6 p-2 rounded-full hover:bg-secondary transition-colors"
                                >
                                    <X className="w-4 h-4 text-muted-foreground" />
                                </button>

                                {loadingDetail ? (
                                    <div className="flex items-center justify-center py-10">
                                        <Loader2 className="w-6 h-6 animate-spin text-gold" />
                                    </div>
                                ) : (
                                    <>
                                        <div className="mb-8">
                                            <h2 className="font-heading text-2xl uppercase tracking-tighter mb-1">
                                                Order {selectedOrder.code}
                                            </h2>
                                            <div className="flex items-center gap-3">
                                                {(() => {
                                                    const badge = getStatusBadge(selectedOrder);
                                                    const BadgeIcon = badge.icon;
                                                    return (
                                                        <span className={`inline-flex items-center gap-1.5 text-[9px] px-3 py-1 rounded-full font-bold uppercase border ${badge.color}`}>
                                                            <BadgeIcon size={10} />
                                                            {badge.label}
                                                        </span>
                                                    );
                                                })()}
                                                <span className="text-[10px] text-muted-foreground uppercase tracking-widest">
                                                    {new Date(selectedOrder.createdAt).toLocaleString('vi-VN')}
                                                </span>
                                            </div>
                                        </div>

                                        {/* Customer / Staff Info */}
                                        <div className="grid grid-cols-2 gap-4 mb-6">
                                            {selectedOrder.staff && (
                                                <div className="glass rounded-2xl p-4 border-border">
                                                    <div className="flex items-center gap-2 mb-2">
                                                        <User className="w-3 h-3 text-gold" />
                                                        <span className="text-[9px] uppercase tracking-widest text-muted-foreground font-heading">Staff</span>
                                                    </div>
                                                    <p className="text-xs font-heading">{selectedOrder.staff.fullName ?? selectedOrder.staff.email}</p>
                                                </div>
                                            )}
                                            {selectedOrder.store && (
                                                <div className="glass rounded-2xl p-4 border-border">
                                                    <div className="flex items-center gap-2 mb-2">
                                                        <Package className="w-3 h-3 text-gold" />
                                                        <span className="text-[9px] uppercase tracking-widest text-muted-foreground font-heading">Store</span>
                                                    </div>
                                                    <p className="text-xs font-heading">{selectedOrder.store.name}</p>
                                                </div>
                                            )}
                                        </div>

                                        {/* Items */}
                                        <div className="mb-6">
                                            <h3 className="font-heading text-[10px] uppercase tracking-[0.3em] text-muted-foreground mb-3">Items</h3>
                                            <div className="space-y-2">
                                                {selectedOrder.items.map((item) => (
                                                    <div key={item.id} className="flex justify-between items-center text-sm border-b border-border/20 pb-2">
                                                        <div>
                                                            <span className="font-heading text-[10px] uppercase tracking-widest">
                                                                {item.product?.name ?? item.variant?.product?.name ?? 'Product'}
                                                            </span>
                                                            {item.variant && (
                                                                <span className="text-muted-foreground text-[10px]"> — {item.variant.name}</span>
                                                            )}
                                                            <span className="text-muted-foreground text-[10px]"> x{item.quantity}</span>
                                                        </div>
                                                        <span className="font-heading text-gold text-sm">{formatMoney(item.totalPrice)}</span>
                                                    </div>
                                                ))}
                                            </div>
                                        </div>

                                        {/* Totals */}
                                        <div className="border-t border-border pt-4 mb-6 space-y-2">
                                            <div className="flex justify-between text-[10px] uppercase tracking-widest text-muted-foreground font-heading">
                                                <span>Subtotal</span>
                                                <span>{formatMoney(selectedOrder.totalAmount)}</span>
                                            </div>
                                            {selectedOrder.discountAmount > 0 && (
                                                <div className="flex justify-between text-[10px] uppercase tracking-widest text-emerald-500 font-heading">
                                                    <span>Discount</span>
                                                    <span>-{formatMoney(selectedOrder.discountAmount)}</span>
                                                </div>
                                            )}
                                            <div className="flex justify-between text-lg font-heading pt-2">
                                                <span className="uppercase tracking-tighter">Total</span>
                                                <span className="text-gold">{formatMoney(selectedOrder.finalAmount)}</span>
                                            </div>
                                        </div>

                                        {/* Payments */}
                                        {selectedOrder.payments && selectedOrder.payments.length > 0 && (
                                            <div className="mb-4">
                                                <h3 className="font-heading text-[10px] uppercase tracking-[0.3em] text-muted-foreground mb-3">Payments</h3>
                                                <div className="space-y-2">
                                                    {selectedOrder.payments.map((p) => (
                                                        <div key={p.id} className="flex justify-between items-center text-xs glass rounded-xl p-3 border-border">
                                                            <div className="flex items-center gap-2">
                                                                <CreditCard className="w-3 h-3 text-gold" />
                                                                <span className="font-heading uppercase tracking-widest text-[10px]">{p.provider}</span>
                                                            </div>
                                                            <div className="flex items-center gap-4">
                                                                <span className={`text-[9px] uppercase font-bold ${p.status === 'PAID' ? 'text-emerald-500' : 'text-amber-500'
                                                                    }`}>{p.status}</span>
                                                                <span className="font-heading">{formatMoney(p.amount)}</span>
                                                            </div>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        )}
                                    </>
                                )}
                            </motion.div>
                        </motion.div>
                    )}
                </AnimatePresence>
            </div>
        </AuthGuard>
    );
}
