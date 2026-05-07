'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { Tag, Zap, Timer, Sparkles, Copy, CheckCircle2, Wallet, Coins, Loader2, Plus, ShieldCheck } from 'lucide-react';
import { useEffect, useState, useCallback } from 'react';
import { promotionService } from '@/services/promotion.service';
import { loyaltyService } from '@/services/loyalty.service';
import { motion, AnimatePresence } from 'framer-motion';
import { useTranslations, useFormatter } from 'next-intl';
import { toast } from 'sonner';
import { useAuthStore } from '@/store/auth.store';
import { Link } from '@/lib/i18n';
import { cn } from '@/lib/utils';

export default function CustomerPromotions() {
    const t = useTranslations('dashboard.customer.promotions');
    const tMarket = useTranslations('vouchers');
    const tFeatured = useTranslations('featured');
    const tLoyalty = useTranslations('dashboard.customer.loyalty');
    const format = useFormatter();
    const { user } = useAuthStore();

    const [publicPromos, setPublicPromos] = useState<any[]>([]);
    const [redeemablePromos, setRedeemablePromos] = useState<any[]>([]);
    const [userPoints, setUserPoints] = useState(0);
    const [loading, setLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState<string | null>(null);
    const [copiedCode, setCopiedCode] = useState<string | null>(null);

    const fetchData = useCallback(async () => {
        setLoading(true);
        try {
            const [pub, red] = await Promise.all([
                promotionService.getPublic(),
                promotionService.getRedeemable()
            ]);
            setPublicPromos(pub);
            setRedeemablePromos(red);

            if (user) {
                const loyalty = await loyaltyService.getStatus();
                setUserPoints(loyalty.points);
            }
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    }, [user]);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    const handleClaim = async (id: string) => {
        setActionLoading(id);
        try {
            await promotionService.claim(id);
            toast.success(tMarket('claim_success'));
            fetchData();
        } catch (e: any) {
            toast.error(e.response?.data?.message || tMarket('action_failed'));
        } finally {
            setActionLoading(null);
        }
    };

    const handleRedeem = async (id: string, cost: number) => {
        if (userPoints < cost) {
            toast.error(tMarket('insufficient_points'));
            return;
        }
        
        if (!confirm(tMarket('confirm_redeem', { points: cost }))) return;

        setActionLoading(id);
        try {
            await promotionService.redeem(id);
            toast.success(tMarket('redeem_success'));
            fetchData();
        } catch (e: any) {
            toast.error(e.response?.data?.message || tMarket('action_failed'));
        } finally {
            setActionLoading(null);
        }
    };

    const copyToClipboard = (code: string) => {
        navigator.clipboard.writeText(code);
        setCopiedCode(code);
        setTimeout(() => setCopiedCode(null), 2000);
    };

    const formatTimeRemaining = (endDate: string) => {
        if (!endDate) return '';
        const date = new Date(endDate);
        if (isNaN(date.getTime())) return '';

        const remaining = date.getTime() - new Date().getTime();
        if (remaining <= 0) return t('expired');

        const hours = Math.floor(remaining / (1000 * 60 * 60));
        const minutes = Math.floor((remaining % (1000 * 60 * 60)) / (1000 * 60));
        return t('time_left', { time: `${hours}h ${minutes}m` });
    };

    return (
        <div className="space-y-12 pb-12">
            <header className="flex flex-col md:flex-row justify-between items-center gap-8">
                <div>
                    <div className="flex items-center gap-4 mb-4">
                        <div className="h-[1px] w-12 bg-gold/50" />
                        <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry</span>
                    </div>
                    <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
                        Aura <span className="gold-gradient">Privilege</span>
                    </h1>
                    <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest text-stone-500">{t('subtitle')}</p>
                </div>

                <motion.div 
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="glass px-10 py-8 rounded-[3rem] flex items-center gap-8"
                >
                    <div className="w-14 h-14 rounded-2xl border border-gold/20 flex items-center justify-center text-gold glass shadow-inner">
                        <Coins size={24} />
                    </div>
                    <div>
                        <p className="text-[10px] text-stone-400 dark:text-stone-700 uppercase tracking-[.4em] font-black mb-2">{tMarket('your_points')}</p>
                        <p className="text-4xl font-heading text-gold tracking-tighter">{format.number(userPoints)} <span className="text-xs uppercase font-body tracking-[0.3em] opacity-50 ml-1">pts</span></p>
                    </div>
                </motion.div>
            </header>

            {loading ? (
                <div className="flex h-[400px] items-center justify-center">
                    <Loader2 className="h-10 w-10 animate-spin text-gold" />
                </div>
            ) : (
                <div className="space-y-16">
                    {/* Available Marketplace Section */}
                    <section>
                        <div className="flex items-center gap-6 mb-12">
                            <h2 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground flex items-center gap-4 italic">
                                <Tag className="text-emerald-500" />
                                {t('marketplace_title')}
                            </h2>
                            <div className="h-[1px] flex-1 bg-gradient-to-r from-gold/20 to-transparent" />
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-8">
                            {publicPromos.map((promo) => (
                                <OfferCard 
                                    key={promo.id} 
                                    promo={promo} 
                                    type="public"
                                    onAction={() => handleClaim(promo.id)}
                                    loading={actionLoading === promo.id}
                                    tMarket={tMarket}
                                    t={t}
                                    tFeatured={tFeatured}
                                    format={format}
                                    formatTimeRemaining={formatTimeRemaining}
                                />
                            ))}
                            {redeemablePromos.map((promo) => (
                                <OfferCard 
                                    key={promo.id} 
                                    promo={promo} 
                                    type="redeemable"
                                    onAction={() => handleRedeem(promo.id, promo.pointsCost)}
                                    loading={actionLoading === promo.id}
                                    tMarket={tMarket}
                                    t={t}
                                    tFeatured={tFeatured}
                                    format={format}
                                    formatTimeRemaining={formatTimeRemaining}
                                />
                            ))}
                        </div>
                        {publicPromos.length === 0 && redeemablePromos.length === 0 && (
                            <div className="py-24 text-center glass rounded-[3rem]">
                                <Tag className="mx-auto text-stone-200 dark:text-stone-800 mb-6" size={64} />
                                <p className="text-[10px] uppercase font-bold tracking-[0.3em] text-stone-400 dark:text-stone-700">{tMarket('no_public')}</p>
                            </div>
                        )}
                    </section>
                </div>
            )}
        </div>
    );
}

function OfferCard({ promo, type, onAction, loading, tMarket, t, tFeatured, format, formatTimeRemaining }: any) {
    return (
        <motion.div
            whileHover={{ y: -5 }}
            className="group relative"
        >
            <div className="glass rounded-[2.5rem] overflow-hidden h-full group-hover:border-gold/30 transition-all duration-500 shadow-2xl shadow-black/5 dark:shadow-black/20">
                <div className="p-8 flex flex-col h-full space-y-8">
                    <div className="flex justify-between items-start">
                        <div className={cn(
                            "w-14 h-14 rounded-2xl flex items-center justify-center glass border",
                            type === 'public' ? 'text-emerald-500 border-emerald-500/20' : 'text-gold border-gold/20'
                        )}>
                            {type === 'public' ? <Tag size={24} /> : <Coins size={24} />}
                        </div>
                        <div className="px-4 py-2 rounded-full glass border border-black/5 dark:border-white/5 text-[9px] font-bold uppercase tracking-[.2em] text-gold shadow-lg shadow-black/5 dark:shadow-black/20">
                            {formatTimeRemaining(promo.endDate)}
                        </div>
                    </div>

                    <div className="flex-1 space-y-4">
                        <h3 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground group-hover:text-gold transition-colors duration-300">{promo.code}</h3>
                        <p className="font-body text-[10px] font-bold uppercase tracking-widest text-stone-500 line-clamp-2 leading-relaxed italic">{promo.description || t('fallback_desc')}</p>
                        
                        <div className="flex items-center gap-4">
                            <div className="flex-1 h-1.5 bg-stone-100 dark:bg-white/5 rounded-full overflow-hidden">
                                <motion.div 
                                    initial={{ width: 0 }}
                                    animate={{ width: promo.usageLimit ? `${Math.max(0, Math.min(100, ((promo.usageLimit - promo.usedCount) / promo.usageLimit) * 100))}%` : '100%' }}
                                    className="h-full bg-gold/40"
                                />
                            </div>
                            <span className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 whitespace-nowrap">
                                {promo.usageLimit 
                                    ? t('remaining_slots', { remaining: Math.max(0, promo.usageLimit - promo.usedCount), limit: promo.usageLimit })
                                    : t('unlimited')}
                            </span>
                        </div>
                    </div>

                    <div className="pt-8 border-t border-black/5 dark:border-white/5 space-y-6">
                        <div className="space-y-1">
                            <p className="text-[8px] font-bold uppercase tracking-[.4em] text-stone-400 dark:text-stone-700">{t('benefit_label')}</p>
                            <p className="font-heading text-3xl font-bold text-gold tracking-tighter">
                                {promo.discountType === 'PERCENTAGE' 
                                    ? <>{promo.discountValue}% OFF</>
                                    : <>{format.number(promo.discountValue, { maximumFractionDigits: 0 })} <span className="text-xs uppercase">đ</span></>}
                            </p>
                        </div>

                        <button
                            onClick={onAction}
                            disabled={loading}
                            className={cn(
                                "w-full h-14 rounded-2xl text-[10px] font-bold uppercase tracking-widest flex items-center justify-center gap-3 transition-all active:scale-95 shadow-xl cursor-pointer",
                                type === 'public' 
                                    ? 'bg-emerald-600 dark:bg-emerald-500 text-white hover:bg-emerald-700' 
                                    : 'bg-gold text-black hover:bg-gold/80'
                            )}
                        >
                            {loading ? (
                                <Loader2 size={16} className="animate-spin" />
                            ) : (
                                <>
                                    {type === 'public' ? <Plus size={18} strokeWidth={3} /> : <Zap size={18} strokeWidth={3} />}
                                    <span>{type === 'public' ? tMarket('claim_btn') : tMarket('redeem_btn', { points: promo.pointsCost })}</span>
                                </>
                            )}
                        </button>
                    </div>
                </div>
            </div>
        </motion.div>
    );
}

function OwnedVoucherCard({ promo: userPromo, i, copyToClipboard, copiedCode, formatTimeRemaining, t }: any) {
    const promo = userPromo.promotion || {};
    
    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            className="group"
        >
            <div className="glass rounded-[3rem] p-10 h-full relative overflow-hidden group-hover:border-gold/30 transition-all duration-500">
                <div className="flex justify-between items-start mb-8">
                    <div className="w-16 h-16 glass rounded-2xl border-gold/20 flex items-center justify-center text-gold">
                        <Tag size={24} />
                    </div>
                    {promo.endDate && (
                        <div className="inline-flex items-center gap-3 px-4 py-2 rounded-full bg-gold/10 border border-gold/10 text-gold text-[8px] font-bold uppercase tracking-[.3em]">
                            <Timer size={14} />
                            {formatTimeRemaining(promo.endDate)}
                        </div>
                    )}
                </div>

                <h2 className="font-heading text-3xl font-bold uppercase tracking-widest text-foreground mb-4 group-hover:text-gold transition-colors">
                    {promo.code || 'UNKNOWN'}
                </h2>
                <p className="font-body text-[10px] font-bold uppercase tracking-widest text-stone-500 leading-relaxed italic mb-8">
                    {promo.description || t('fallback_desc')}
                </p>

                <div className="pt-8 border-t border-black/5 dark:border-white/5 flex items-center justify-between">
                    <div className="space-y-1">
                        <p className="text-[8px] font-bold uppercase tracking-[.3em] text-stone-400 dark:text-stone-700">{t('benefit_label')}</p>
                        <p className="font-heading text-3xl font-bold text-gold tracking-tighter">
                            {promo.discountValue ? (
                                promo.discountType === 'PERCENTAGE' 
                                    ? `${promo.discountValue}% OFF`
                                    : `-${new Intl.NumberFormat().format(promo.discountValue)} đ`
                            ) : '---'}
                        </p>
                    </div>
                    <button
                        onClick={() => copyToClipboard(promo.code)}
                        className="h-14 px-8 rounded-2xl glass border-gold/20 text-gold font-bold uppercase tracking-widest text-[10px] hover:bg-gold hover:text-black transition-all flex items-center gap-3 active:scale-95 shadow-xl cursor-pointer"
                    >
                        {copiedCode === promo.code ? (
                            <>
                                <CheckCircle2 size={16} />
                                {t('copied')}
                            </>
                        ) : (
                            <>
                                <Copy size={16} />
                                {t('copy_btn')}
                            </>
                        )}
                    </button>
                </div>
            </div>
        </motion.div>
    );
}
