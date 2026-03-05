'use client';

import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
    Tag, Plus, Trash2, Calendar, Target,
    Zap, AlertCircle, CheckCircle2, XCircle,
    Loader2, Search, ArrowLeft, MoreHorizontal
} from 'lucide-react';
import { promotionService } from '@/services/promotion.service';
import { AuthGuard } from '@/components/auth/auth-guard';
import { cn } from '@/lib/utils';
import Link from 'next/link';

export default function PromotionsManagement() {
    const [promos, setPromos] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
    const [search, setSearch] = useState('');

    // Form state
    const [formData, setFormData] = useState({
        code: '',
        description: '',
        discountType: 'PERCENTAGE',
        discountValue: 0,
        minOrderAmount: 0,
        maxDiscount: 0,
        usageLimit: 0,
        startDate: '',
        endDate: '',
    });
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState('');

    useEffect(() => {
        fetchPromos();
    }, []);

    const fetchPromos = async () => {
        setLoading(true);
        try {
            const data = await promotionService.findAll();
            setPromos(data);
        } catch (err) {
            console.error('Failed to fetch promos:', err);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm('Are you sure you want to delete this promotion?')) return;
        try {
            await promotionService.remove(id);
            setPromos(prev => prev.filter(p => p.id !== id));
        } catch (err) {
            alert('Delete failed');
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        setError('');
        try {
            const payload = {
                ...formData,
                discountValue: Number(formData.discountValue),
                minOrderAmount: formData.minOrderAmount ? Number(formData.minOrderAmount) : undefined,
                maxDiscount: formData.maxDiscount ? Number(formData.maxDiscount) : undefined,
                usageLimit: formData.usageLimit ? Number(formData.usageLimit) : undefined,
                startDate: new Date(formData.startDate).toISOString(),
                endDate: new Date(formData.endDate).toISOString(),
            };
            await promotionService.create(payload);
            setIsCreateModalOpen(false);
            fetchPromos();
            setFormData({
                code: '',
                description: '',
                discountType: 'PERCENTAGE',
                discountValue: 0,
                minOrderAmount: 0,
                maxDiscount: 0,
                usageLimit: 0,
                startDate: '',
                endDate: '',
            });
        } catch (err: any) {
            setError(err.response?.data?.message || 'Failed to create promotion');
        } finally {
            setIsSubmitting(false);
        }
    };

    const filteredPromos = promos.filter(p =>
        p.code.toLowerCase().includes(search.toLowerCase()) ||
        p.description?.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <AuthGuard allowedRoles={['admin']}>
            <div className="flex flex-col gap-10 py-10 px-8 max-w-7xl mx-auto">
                {/* Header */}
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
                    <div className="flex items-center gap-6">
                        <Link href="/dashboard/admin/marketing" className="p-3 bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl hover:border-gold transition-all group">
                            <ArrowLeft size={18} className="text-stone-500 group-hover:text-gold" />
                        </Link>
                        <div>
                            <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-2 italic">
                                Promotions <span className="font-sans font-bold not-italic">Engine</span>
                            </h1>
                            <p className="text-[10px] text-stone-500 uppercase tracking-[.4em] font-bold">
                                Neural Rewards & Incentives Control
                            </p>
                        </div>
                    </div>

                    <div className="flex items-center gap-4">
                        <div className="relative group">
                            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400 group-hover:text-gold transition-colors" size={16} />
                            <input
                                type="text"
                                placeholder="Search codes..."
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                className="bg-white dark:bg-zinc-900 border border-stone-200 dark:border-white/10 rounded-2xl py-3 pl-12 pr-6 text-xs outline-none focus:border-gold transition-all w-64 shadow-sm"
                            />
                        </div>
                        <button
                            onClick={() => setIsCreateModalOpen(true)}
                            className="bg-luxury-black dark:bg-white text-white dark:text-luxury-black px-6 py-3 rounded-2xl text-[10px] font-bold uppercase tracking-widest flex items-center gap-3 hover:scale-[1.02] active:scale-95 transition-all shadow-xl shadow-luxury-black/10 dark:shadow-white/5"
                        >
                            <Plus size={16} />
                            Create Promo
                        </button>
                    </div>
                </div>

                {/* Stats Summary */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10">
                        <div className="flex justify-between items-start mb-4">
                            <h3 className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-400">Total Codes</h3>
                            <Tag className="text-gold" size={18} />
                        </div>
                        <p className="text-3xl font-serif italic text-luxury-black dark:text-white">{promos.length}</p>
                    </div>
                    <div className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10">
                        <div className="flex justify-between items-start mb-4">
                            <h3 className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-400">Active Now</h3>
                            <Zap className="text-emerald-500" size={18} />
                        </div>
                        <p className="text-3xl font-serif italic text-luxury-black dark:text-white">
                            {promos.filter(p => p.isActive && new Date(p.endDate) > new Date()).length}
                        </p>
                    </div>
                    <div className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10">
                        <div className="flex justify-between items-start mb-4">
                            <h3 className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-400">Total Redemptions</h3>
                            <Target className="text-blue-500" size={18} />
                        </div>
                        <p className="text-3xl font-serif italic text-luxury-black dark:text-white">
                            {promos.reduce((acc, p) => acc + p.usedCount, 0)}
                        </p>
                    </div>
                </div>

                {/* List Table */}
                <div className="glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-200 dark:border-white/10 overflow-hidden shadow-xl">
                    <div className="overflow-x-auto">
                        <table className="w-full border-collapse">
                            <thead>
                                <tr className="border-b border-stone-100 dark:border-white/5 bg-stone-50/50 dark:bg-white/[0.02]">
                                    <th className="px-8 py-6 text-left text-[10px] font-bold uppercase tracking-[0.2em] text-stone-400">Code</th>
                                    <th className="px-8 py-6 text-left text-[10px] font-bold uppercase tracking-[0.2em] text-stone-400">Discount</th>
                                    <th className="px-8 py-6 text-left text-[10px] font-bold uppercase tracking-[0.2em] text-stone-400">Conditions</th>
                                    <th className="px-8 py-6 text-left text-[10px] font-bold uppercase tracking-[0.2em] text-stone-400">Redeemed</th>
                                    <th className="px-8 py-6 text-left text-[10px] font-bold uppercase tracking-[0.2em] text-stone-400">Validity</th>
                                    <th className="px-8 py-6 text-left text-[10px] font-bold uppercase tracking-[0.2em] text-stone-400">Status</th>
                                    <th className="px-8 py-6 text-right text-[10px] font-bold uppercase tracking-[0.2em] text-stone-400">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-stone-100 dark:divide-white/5">
                                {loading ? (
                                    Array(5).fill(0).map((_, i) => (
                                        <tr key={i} className="animate-pulse">
                                            <td colSpan={7} className="px-8 py-10 h-24" />
                                        </tr>
                                    ))
                                ) : filteredPromos.map((promo) => {
                                    const isActive = promo.isActive && new Date(promo.endDate) > new Date() && new Date(promo.startDate) <= new Date();
                                    return (
                                        <motion.tr
                                            key={promo.id}
                                            initial={{ opacity: 0 }}
                                            animate={{ opacity: 1 }}
                                            className="hover:bg-stone-50/80 dark:hover:bg-white/[0.02] transition-colors group"
                                        >
                                            <td className="px-8 py-6">
                                                <div className="flex flex-col">
                                                    <span className="text-xs font-bold text-luxury-black dark:text-white uppercase tracking-widest">{promo.code}</span>
                                                    <span className="text-[10px] text-stone-400 truncate max-w-[150px]">{promo.description}</span>
                                                </div>
                                            </td>
                                            <td className="px-8 py-6">
                                                <span className="text-sm font-serif text-luxury-black dark:text-white italic">
                                                    {promo.discountType === 'PERCENTAGE'
                                                        ? `${promo.discountValue}% OFF`
                                                        : new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(promo.discountValue)}
                                                </span>
                                            </td>
                                            <td className="px-8 py-6">
                                                <div className="space-y-1">
                                                    {promo.minOrderAmount && (
                                                        <p className="text-[9px] text-stone-500 uppercase font-bold tracking-tight">Min Order: {new Intl.NumberFormat('vi-VN').format(promo.minOrderAmount)}đ</p>
                                                    )}
                                                    {promo.maxDiscount && (
                                                        <p className="text-[9px] text-stone-500 uppercase font-bold tracking-tight">Max: {new Intl.NumberFormat('vi-VN').format(promo.maxDiscount)}đ</p>
                                                    )}
                                                </div>
                                            </td>
                                            <td className="px-8 py-6">
                                                <div className="flex flex-col">
                                                    <span className="text-xs font-bold text-luxury-black dark:text-white">{promo.usedCount}</span>
                                                    <span className="text-[8px] uppercase tracking-tighter text-stone-400">Limit: {promo.usageLimit || '∞'}</span>
                                                </div>
                                            </td>
                                            <td className="px-8 py-6">
                                                <div className="flex items-center gap-2 text-stone-500">
                                                    <Calendar size={12} />
                                                    <span className="text-[9px] uppercase font-bold tracking-widest">
                                                        {new Date(promo.endDate).toLocaleDateString('vi-VN')}
                                                    </span>
                                                </div>
                                            </td>
                                            <td className="px-8 py-6">
                                                <div className={cn(
                                                    "inline-flex items-center gap-2 px-3 py-1 rounded-full border text-[9px] font-bold uppercase tracking-widest",
                                                    isActive
                                                        ? "bg-emerald-500/10 text-emerald-600 border-emerald-500/20"
                                                        : "bg-red-500/10 text-red-600 border-red-500/20"
                                                )}>
                                                    <div className={cn("w-1 h-1 rounded-full", isActive ? "bg-emerald-500" : "bg-red-500")} />
                                                    {isActive ? 'Active' : 'Expired'}
                                                </div>
                                            </td>
                                            <td className="px-8 py-6 text-right">
                                                <button
                                                    onClick={() => handleDelete(promo.id)}
                                                    className="p-2.5 rounded-xl border border-stone-200 dark:border-white/10 text-stone-400 hover:border-red-500/50 hover:text-red-500 transition-all opacity-0 group-hover:opacity-100"
                                                >
                                                    <Trash2 size={14} />
                                                </button>
                                            </td>
                                        </motion.tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>
                </div>

                {/* Create Modal */}
                <AnimatePresence>
                    {isCreateModalOpen && (
                        <div className="fixed inset-0 z-50 flex items-center justify-center p-6">
                            <motion.div
                                initial={{ opacity: 0 }}
                                animate={{ opacity: 1 }}
                                exit={{ opacity: 0 }}
                                className="absolute inset-0 bg-black/60 backdrop-blur-md"
                                onClick={() => setIsCreateModalOpen(false)}
                            />
                            <motion.div
                                initial={{ scale: 0.9, opacity: 0, y: 20 }}
                                animate={{ scale: 1, opacity: 1, y: 0 }}
                                exit={{ scale: 0.9, opacity: 0, y: 20 }}
                                className="relative w-full max-w-xl bg-white dark:bg-zinc-950 rounded-[3rem] border border-stone-200 dark:border-white/10 shadow-2xl overflow-hidden"
                            >
                                <div className="p-10">
                                    <div className="flex justify-between items-center mb-10 pb-8 border-b border-stone-100 dark:border-white/5">
                                        <div>
                                            <h3 className="text-xl font-bold uppercase tracking-widest text-luxury-black dark:text-white">Forge New Promo</h3>
                                            <p className="text-[10px] text-stone-400 uppercase tracking-[.3em] font-bold mt-1">Configure Incentive Logic</p>
                                        </div>
                                        <button onClick={() => setIsCreateModalOpen(false)} className="p-3 text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors">
                                            <XCircle size={24} strokeWidth={1.5} />
                                        </button>
                                    </div>

                                    <form onSubmit={handleSubmit} className="space-y-6">
                                        <div className="grid grid-cols-2 gap-6">
                                            <div className="space-y-2">
                                                <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 ml-1">CODE</label>
                                                <input
                                                    required
                                                    type="text"
                                                    value={formData.code}
                                                    onChange={e => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                                                    className="w-full h-14 bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl px-6 text-xs font-bold focus:ring-1 focus:ring-gold outline-none transition-all"
                                                    placeholder="AURA20"
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 ml-1">DISCOUNT TYPE</label>
                                                <select
                                                    value={formData.discountType}
                                                    onChange={e => setFormData({ ...formData, discountType: e.target.value })}
                                                    className="w-full h-14 bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl px-6 text-xs font-bold outline-none cursor-pointer"
                                                >
                                                    <option value="PERCENTAGE">PERCENTAGE (%)</option>
                                                    <option value="FIXED_AMOUNT">FIXED AMOUNT (VNĐ)</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div className="space-y-2">
                                            <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 ml-1">DESCRIPTION</label>
                                            <textarea
                                                value={formData.description}
                                                onChange={e => setFormData({ ...formData, description: e.target.value })}
                                                className="w-full h-24 bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl px-6 py-4 text-xs focus:ring-1 focus:ring-gold outline-none transition-all resize-none"
                                                placeholder="Enter promo details..."
                                            />
                                        </div>

                                        <div className="grid grid-cols-2 gap-6">
                                            <div className="space-y-2">
                                                <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 ml-1">VALUE</label>
                                                <input
                                                    required
                                                    type="number"
                                                    value={formData.discountValue}
                                                    onChange={e => setFormData({ ...formData, discountValue: Number(e.target.value) })}
                                                    className="w-full h-14 bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl px-6 text-xs font-bold outline-none"
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 ml-1">USAGE LIMIT</label>
                                                <input
                                                    type="number"
                                                    value={formData.usageLimit}
                                                    onChange={e => setFormData({ ...formData, usageLimit: Number(e.target.value) })}
                                                    className="w-full h-14 bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl px-6 text-xs font-bold outline-none"
                                                />
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-2 gap-6">
                                            <div className="space-y-2">
                                                <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 ml-1">START DATE</label>
                                                <input
                                                    required
                                                    type="date"
                                                    value={formData.startDate}
                                                    onChange={e => setFormData({ ...formData, startDate: e.target.value })}
                                                    className="w-full h-14 bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl px-6 text-xs font-bold outline-none"
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 ml-1">END DATE</label>
                                                <input
                                                    required
                                                    type="date"
                                                    value={formData.endDate}
                                                    onChange={e => setFormData({ ...formData, endDate: e.target.value })}
                                                    className="w-full h-14 bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl px-6 text-xs font-bold outline-none"
                                                />
                                            </div>
                                        </div>

                                        {error && (
                                            <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="bg-red-500/10 border border-red-500/20 p-4 rounded-xl flex items-center gap-3 text-red-500 text-[10px] font-bold uppercase tracking-widest">
                                                <AlertCircle size={16} />
                                                {error}
                                            </motion.div>
                                        )}

                                        <button
                                            type="submit"
                                            disabled={isSubmitting}
                                            className="w-full h-16 bg-luxury-black dark:bg-white text-white dark:text-luxury-black rounded-2xl font-bold uppercase tracking-[.3em] text-[10px] hover:scale-[1.01] active:scale-[0.98] transition-all disabled:opacity-50 mt-4 flex items-center justify-center gap-3"
                                        >
                                            {isSubmitting ? <Loader2 className="animate-spin" size={20} /> : <Zap size={18} />}
                                            Activate Protocol
                                        </button>
                                    </form>
                                </div>
                            </motion.div>
                        </div>
                    )}
                </AnimatePresence>
            </div>
        </AuthGuard>
    );
}
