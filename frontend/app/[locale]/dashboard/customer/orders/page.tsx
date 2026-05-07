'use client';
 
import React, { useEffect, useState, useCallback } from 'react';
import { Link } from '@/lib/i18n';
import { motion } from 'framer-motion';
import { useTranslations, useLocale, useFormatter } from 'next-intl';
import {
    MapPin,
    Truck,
    PackageCheck,
    Calendar,
    ChevronRight,
    Loader2,
    Clock,
    XCircle,
    Receipt,
    ChevronLeft,
    Zap
} from 'lucide-react';
import { orderService, type Order } from '@/services/order.service';
import { cn } from '@/lib/utils';
 
export default function CustomerOrdersPage() {
    const t = useTranslations('dashboard.customer.orders');
    const tFeatured = useTranslations('featured');
    const locale = useLocale();
    const format = useFormatter();
    const [orders, setOrders] = useState<Order[]>([]);
    const [total, setTotal] = useState(0);
    const [skip, setSkip] = useState(0);
    const [take, setTake] = useState(10);
    const [loading, setLoading] = useState(true);
    const [refundModalOrderId, setRefundModalOrderId] = useState<string | null>(null);
    const [loadingRefundInfo, setLoadingRefundInfo] = useState(false);
    const [savingRefundInfo, setSavingRefundInfo] = useState(false);
    const [refundInfo, setRefundInfo] = useState({
        bankName: '',
        accountNumber: '',
        accountHolder: '',
        note: '',
    });

    const STATUS_CONFIG = {
        PENDING: { label: t('status.pending'), color: 'bg-amber-500/10 text-amber-600 dark:text-amber-500 border-amber-500/20', icon: Clock },
        CONFIRMED: { label: t('status.confirmed'), color: 'bg-blue-500/10 text-blue-600 dark:text-blue-500 border-blue-500/20', icon: PackageCheck },
        PROCESSING: { label: t('status.processing'), color: 'bg-purple-500/10 text-purple-600 dark:text-purple-500 border-purple-500/20', icon: PackageCheck },
        SHIPPED: { label: t('status.shipped'), color: 'bg-orange-500/10 text-orange-600 dark:text-orange-500 border-orange-500/20', icon: Truck },
        COMPLETED: { label: t('status.completed'), color: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-500 border-emerald-500/20', icon: PackageCheck },
        CANCELLED: { label: t('status.cancelled'), color: 'bg-red-500/10 text-red-600 dark:text-red-500 border-red-500/20', icon: XCircle },
    };

    const fetchOrders = useCallback(async () => {
        setLoading(true);
        try {
            const res = await orderService.listMy({ skip, take });
            setOrders(res.data);
            setTotal(res.total);
        } catch (error) {
            console.error('Failed to fetch my orders:', error);
        } finally {
            setLoading(false);
        }
    }, [skip, take]);

    useEffect(() => {
        fetchOrders();
    }, [fetchOrders]);

    const currentPage = Math.floor(skip / take) + 1;
    const totalPages = Math.max(1, Math.ceil(total / take));

    const formatCurrency = (amount: number) => {
        return format.number(amount, {
            style: 'currency',
            currency: tFeatured('currency_code') || 'VND',
            maximumFractionDigits: 0
        });
    };

    const openRefundModal = async (orderId: string) => {
        setRefundModalOrderId(orderId);
        setLoadingRefundInfo(true);
        setRefundInfo({ bankName: '', accountNumber: '', accountHolder: '', note: '' });
        try {
            const existing = await orderService.getRefundBankInfo(orderId);
            if (existing) {
                setRefundInfo({
                    bankName: existing.bankName || '',
                    accountNumber: existing.accountNumber || '',
                    accountHolder: existing.accountHolder || '',
                    note: existing.note || '',
                });
            }
        } catch { /* keep empty */ } finally { setLoadingRefundInfo(false); }
    };

    return (
        <div className="space-y-12 pb-12">
            <header>
                <div className="flex items-center gap-4 mb-4">
                    <div className="h-[1px] w-12 bg-gold/50" />
                    <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry</span>
                </div>
                <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
                    Acquisition <span className="gold-gradient">Archives</span>
                </h1>
                <p className="mt-4 font-body text-base text-stone-500 max-w-2xl">{t('subtitle')}</p>
            </header>

            <div className="space-y-6">
                {loading ? (
                    Array.from({ length: 3 }).map((_, i) => (
                        <div key={i} className="h-48 animate-pulse rounded-[2.5rem] bg-stone-100 dark:bg-white/5" />
                    ))
                ) : orders.length === 0 ? (
                    <div className="py-32 text-center rounded-[3rem] glass">
                        <Receipt className="mx-auto text-stone-300 dark:text-stone-800 mb-8" size={80} strokeWidth={1} />
                        <h3 className="font-heading text-2xl uppercase tracking-widest text-foreground">{t('empty_title')}</h3>
                        <p className="mt-4 text-[10px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-600">{t('empty_desc')}</p>
                    </div>
                ) : (
                    orders.map((order, i) => {
                        const config = STATUS_CONFIG[order.status as keyof typeof STATUS_CONFIG] || STATUS_CONFIG.PENDING;
                        const Icon = config.icon;

                        return (
                            <motion.div
                                key={order.id}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: i * 0.1 }}
                                className="glass group relative overflow-hidden rounded-[2.5rem] p-8 transition-all duration-500 hover:border-gold/30"
                            >
                                <div className="relative flex flex-col lg:flex-row lg:items-center justify-between gap-8">
                                    <div className="flex-1 space-y-6">
                                        <div className="flex flex-wrap items-center gap-4">
                                            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-stone-100 dark:bg-white/5 text-gold group-hover:bg-gold group-hover:text-black transition-all duration-500">
                                                <Icon size={24} />
                                            </div>
                                            <div>
                                                <p className="text-[10px] font-bold uppercase tracking-widest text-gold/60">ID: {order.code}</p>
                                                <h3 className="font-heading text-xl font-bold uppercase tracking-widest text-foreground">
                                                    {order.items?.[0]?.product?.name || t('fragrance_acquisition')}
                                                    {order.items && order.items.length > 1 && (
                                                        <span className="ml-3 text-[10px] font-bold text-stone-400 dark:text-stone-600">
                                                            + {order.items.length - 1} OTHERS
                                                        </span>
                                                    )}
                                                </h3>
                                            </div>
                                        </div>

                                        <div className="flex flex-wrap gap-8 pt-4">
                                            <div className="space-y-1">
                                                <p className="text-[9px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-700">Date Initiated</p>
                                                <div className="flex items-center gap-2 text-xs font-medium text-stone-600 dark:text-stone-300">
                                                    <Calendar size={12} className="text-gold" />
                                                    {format.dateTime(new Date(order.createdAt!), { day: 'numeric', month: 'long', year: 'numeric' })}
                                                </div>
                                            </div>
                                            <div className="space-y-1">
                                                <p className="text-[9px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-700">Total Value</p>
                                                <p className="font-heading text-lg font-bold text-foreground tracking-tighter">{formatCurrency(order.finalAmount)}</p>
                                            </div>
                                            <div className="space-y-1">
                                                <p className="text-[9px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-700">Status</p>
                                                <div className={cn("inline-flex items-center gap-2 rounded-full border px-4 py-1 text-[10px] font-bold uppercase tracking-widest", config.color)}>
                                                    <div className="h-1 w-1 rounded-full bg-current" />
                                                    {config.label}
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div className="flex flex-col lg:items-end gap-6 pt-6 lg:pt-0 lg:border-l lg:border-black/5 dark:lg:border-white/5 lg:pl-10">
                                        <div className="space-y-2 lg:text-right">
                                            <div className="flex lg:justify-end items-center gap-2 text-stone-400 dark:text-stone-600">
                                                <MapPin size={12} />
                                                <span className="text-[9px] font-bold uppercase tracking-widest">Destination</span>
                                            </div>
                                            <p className="text-[10px] font-medium text-stone-500 dark:text-stone-500 uppercase leading-relaxed max-w-[200px]">{order.shippingAddress}</p>
                                        </div>
                                        <div className="flex items-center gap-4">
                                            {order.status === 'CANCELLED' && order.paymentStatus === 'PAID' && (
                                                <button onClick={() => openRefundModal(order.id)} className="flex h-12 items-center px-6 rounded-full border border-red-500/20 bg-red-500/5 text-[10px] font-bold uppercase tracking-widest text-red-600 dark:text-red-500 hover:bg-red-500/10 transition-all cursor-pointer">
                                                    Refund Portal
                                                </button>
                                            )}
                                            <Link href={`/dashboard/customer/orders/${order.id}`} className="flex h-12 items-center gap-3 rounded-full bg-stone-100 dark:bg-white/5 border border-black/5 dark:border-white/10 px-6 text-[10px] font-bold uppercase tracking-widest text-stone-600 dark:text-stone-300 transition-all hover:bg-gold hover:text-black hover:border-gold hover:shadow-[0_0_20px_rgba(197,160,89,0.3)]">
                                                Details <ChevronRight size={14} />
                                            </Link>
                                        </div>
                                    </div>
                                </div>
                                <div className="absolute inset-0 -z-10 bg-gradient-to-br from-gold/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
                            </motion.div>
                        );
                    })
                )}
            </div>

            {!loading && total > 0 && (
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-8 pt-8 border-t border-black/5 dark:border-white/5">
                    <div className="flex items-center gap-4">
                        <span className="text-[10px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-700">Displaying</span>
                        <div className="h-10 px-4 rounded-xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] flex items-center text-xs font-bold text-foreground">
                            {skip + 1} - {Math.min(skip + take, total)} of {total}
                        </div>
                    </div>
                    <div className="flex items-center gap-2">
                         <button
                            onClick={() => setSkip(Math.max(0, skip - take))}
                            disabled={skip === 0}
                            className="h-12 w-12 flex items-center justify-center rounded-full border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] text-stone-400 hover:text-gold disabled:opacity-20 transition-all cursor-pointer"
                        >
                            <ChevronLeft size={20} />
                        </button>
                        <div className="h-12 px-6 rounded-full border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] flex items-center font-heading text-xs font-bold text-foreground">
                            {currentPage} / {totalPages}
                        </div>
                        <button
                            onClick={() => setSkip(skip + take < total ? skip + take : skip)}
                            disabled={skip + take >= total}
                            className="h-12 w-12 flex items-center justify-center rounded-full border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] text-stone-400 hover:text-gold disabled:opacity-20 transition-all cursor-pointer"
                        >
                            <ChevronRight size={20} />
                        </button>
                    </div>
                </div>
            )}

            {/* Refund Modal */}
            {refundModalOrderId && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
                    <div className="absolute inset-0 bg-black/60 dark:bg-black/80 backdrop-blur-md" onClick={() => setRefundModalOrderId(null)} />
                    <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="glass relative w-full max-w-xl rounded-[3rem] p-12 shadow-2xl">
                        <div className="mb-10 space-y-4">
                            <div className="flex items-center gap-3 rounded-full border border-red-500/20 bg-red-500/5 px-4 py-2 text-[10px] font-bold uppercase tracking-widest text-red-600 dark:text-red-500 w-fit">
                                <Zap size={14} /> Refund Sync Request
                            </div>
                            <h3 className="font-heading text-3xl font-bold uppercase tracking-widest text-foreground">Account Registry</h3>
                            <p className="text-xs text-stone-500">Please provide the financial coordinates for the reversal process.</p>
                        </div>

                        {loadingRefundInfo ? (
                            <div className="py-12 flex justify-center"><Loader2 className="animate-spin text-gold" size={32} /></div>
                        ) : (
                            <div className="space-y-4">
                                {[
                                    { label: 'Institution', key: 'bankName', placeholder: 'Bank Name' },
                                    { label: 'Identifier', key: 'accountNumber', placeholder: 'Account Number' },
                                    { label: 'Holder', key: 'accountHolder', placeholder: 'Full Name' }
                                ].map((field) => (
                                    <div key={field.key} className="space-y-2">
                                        <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 px-4">{field.label}</p>
                                        <input
                                            value={(refundInfo as any)[field.key]}
                                            onChange={(e) => setRefundInfo(p => ({ ...p, [field.key]: e.target.value }))}
                                            placeholder={field.placeholder}
                                            className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] text-foreground"
                                        />
                                    </div>
                                ))}
                                <div className="space-y-2">
                                    <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 px-4">Encryption Note</p>
                                    <textarea
                                        value={refundInfo.note}
                                        onChange={(e) => setRefundInfo(p => ({ ...p, note: e.target.value }))}
                                        placeholder="Optional metadata..."
                                        className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] min-h-[120px] text-foreground"
                                    />
                                </div>
                            </div>
                        )}

                        <div className="mt-10 flex gap-4">
                            <button onClick={() => setRefundModalOrderId(null)} className="flex-1 h-16 rounded-full border border-black/5 dark:border-white/10 text-[10px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-500 hover:bg-black/5 cursor-pointer">Cancel</button>
                            <button
                                disabled={loadingRefundInfo || savingRefundInfo || !refundInfo.bankName || !refundInfo.accountNumber || !refundInfo.accountHolder}
                                onClick={async () => {
                                    setSavingRefundInfo(true);
                                    try {
                                        await orderService.submitRefundBankInfo(refundModalOrderId, refundInfo);
                                        setRefundModalOrderId(null);
                                    } catch (e: any) {
                                        alert(e?.response?.data?.message || 'Synchronization failed');
                                    } finally { setSavingRefundInfo(false); }
                                }}
                                className="flex-1 h-16 rounded-full bg-gold text-[10px] font-bold uppercase tracking-widest text-black shadow-lg shadow-gold/20 disabled:opacity-20 cursor-pointer"
                            >
                                {savingRefundInfo ? 'Transmitting...' : 'Commit Protocol'}
                            </button>
                        </div>
                    </motion.div>
                </div>
            )}
        </div>
    );
}
