'use client';
 
import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Coins, Trophy, History, ArrowUpRight, Zap, Gift, ShieldCheck } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { loyaltyService } from '@/services/loyalty.service';
import { AuthGuard } from '@/components/auth/auth-guard';
import { format } from 'date-fns';
import { vi, enUS } from 'date-fns/locale';
import { useParams } from 'next/navigation';
 
export default function LoyaltyDashboard() {
    const t = useTranslations('dashboard.customer.loyalty');
    const { locale } = useParams();
    const dateLocale = locale === 'vi' ? vi : enUS;
    const [data, setData] = useState<{ points: number; history: any[] }>({ points: 0, history: [] });
    const [loading, setLoading] = useState(true);
    const [isExchanging, setIsExchanging] = useState(false);

    const packages = [
        { points: 100, discount: 50000 },
        { points: 200, discount: 100000 },
        { points: 500, discount: 250000 },
    ];

    useEffect(() => {
        loyaltyService.getStatus()
            .then(setData)
            .finally(() => setLoading(false));
    }, []);

    const handleExchange = async (points: number, amount: number) => {
        if (data.points < points) return;
        if (!confirm(t('exchange.confirm', { points, amount: amount.toLocaleString() }))) return;

        try {
            setIsExchanging(true);
            await loyaltyService.exchangePoints(points);
            // We don't have toast imported, let's see if we can use window.alert if not available
            // but the layout has Sonner so we should use it if possible.
            // I'll add the import soon or just use alert for now to be safe if I can't find the exact 'sonner' path.
            // Actually, let's try to import it.
            alert(t('exchange.success'));
            const res = await loyaltyService.getStatus();
            setData(res);
        } catch (error) {
            alert(t('exchange.error'));
        } finally {
            setIsExchanging(false);
        }
    };

    const tiers = [
        { name: t('tiers.bronze'), min: 0, color: 'text-orange-400', bg: 'bg-orange-400/10' },
        { name: t('tiers.silver'), min: 500, color: 'text-stone-300', bg: 'bg-stone-300/10' },
        { name: t('tiers.gold'), min: 2000, color: 'text-gold', bg: 'bg-gold/10' },
        { name: t('tiers.platinum'), min: 5000, color: 'text-blue-400', bg: 'bg-blue-400/10' },
    ];
 
    const currentTier = [...tiers].reverse().find(t => data.points >= t.min) || tiers[0];
    const nextTier = tiers[tiers.indexOf(currentTier) + 1];
    const progress = nextTier ? (data.points / nextTier.min) * 100 : 100;
 
    return (
        <AuthGuard allowedRoles={['customer']}>
            <main className="p-8 max-w-7xl mx-auto">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">{t('title')}</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">{t('subtitle')}</p>
                </header>
 
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Points Card */}
                    <div className="lg:col-span-2 space-y-8">
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="glass p-1 bg-gradient-to-br from-gold/30 via-transparent to-gold/5 rounded-[3rem]"
                        >
                            <div className="bg-background/60 backdrop-blur-3xl p-10 rounded-[2.9rem] flex flex-col md:flex-row items-center gap-10">
                                <div className="relative">
                                    <div className="w-32 h-32 rounded-full border-4 border-gold/20 flex items-center justify-center relative">
                                        <Coins size={48} className="text-gold animate-pulse" />
                                        <svg className="absolute inset-0 w-full h-full -rotate-90">
                                            <circle
                                                cx="64" cy="64" r="60"
                                                fill="transparent"
                                                stroke="currentColor"
                                                strokeWidth="4"
                                                className="text-gold"
                                                strokeDasharray={377}
                                                strokeDashoffset={377 - (377 * Math.min(progress, 100)) / 100}
                                            />
                                        </svg>
                                    </div>
                                </div>
                                <div className="flex-1 text-center md:text-left">
                                    <h2 className="text-5xl font-heading text-foreground mb-2">
                                        {data.points} <span className="text-sm font-body text-muted-foreground tracking-[0.3em] uppercase">{t('credits_suffix')}</span>
                                    </h2>
                                    <div className="flex items-center gap-3 justify-center md:justify-start">
                                        <span className={`px-4 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest ${currentTier.bg} ${currentTier.color} border border-current/20`}>
                                            {currentTier.name} {t('member_suffix')}
                                        </span>
                                        {nextTier && (
                                            <p className="text-[10px] text-muted-foreground uppercase tracking-widest">
                                                {t('to_next_tier', { count: nextTier.min - data.points, name: nextTier.name })}
                                            </p>
                                        )}
                                    </div>
                                </div>
                                <button className="bg-gold text-primary-foreground px-8 py-4 rounded-full font-heading text-[10px] uppercase tracking-widest font-bold hover:scale-105 transition-all shadow-xl shadow-gold/20">
                                    {t('redeem_btn')}
                                </button>
                            </div>
                        </motion.div>

                        {/* EXCHANGE SECTION */}
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.1 }}
                            className="glass p-8 rounded-[2.5rem] border-gold/10 overflow-hidden"
                        >
                            <header className="mb-8 font-body">
                                <h3 className="font-heading text-lg uppercase tracking-widest gold-gradient">{t('exchange.title')}</h3>
                                <p className="text-[10px] text-muted-foreground uppercase mt-1 tracking-widest">{t('exchange.subtitle')}</p>
                            </header>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                {packages.map((pkg, i) => (
                                    <div key={i} className={`p-6 rounded-3xl border ${data.points >= pkg.points ? 'border-gold/30 bg-gold/5' : 'border-border bg-white/[0.02] opacity-60'} transition-all flex flex-col justify-between h-full group`}>
                                        <div>
                                            <div className="p-3 bg-gold/10 text-gold rounded-2xl w-fit mb-4 group-hover:scale-110 transition-transform">
                                                <Gift size={20} />
                                            </div>
                                            <h4 className="font-heading text-sm uppercase tracking-wider mb-1">{t('exchange.package_label', { amount: (pkg.discount / 1000).toString() + 'k' })}</h4>
                                            <p className="text-[10px] text-muted-foreground uppercase tracking-widest">{t('exchange.min_order', { amount: (pkg.discount * 2 / 1000).toString() + 'k' })}</p>
                                        </div>
                                        <div className="mt-8 font-body">
                                            <div className="flex justify-between items-end mb-4">
                                                <span className="text-[10px] text-muted-foreground uppercase tracking-widest">{t('exchange.cost')}</span>
                                                <span className="font-heading text-gold">{pkg.points} PTS</span>
                                            </div>
                                            <button
                                                onClick={() => handleExchange(pkg.points, pkg.discount)}
                                                disabled={data.points < pkg.points || isExchanging}
                                                className={`w-full py-3 rounded-2xl font-heading text-[10px] uppercase tracking-widest transition-all ${data.points >= pkg.points ? 'bg-gold text-primary-foreground hover:scale-[1.02] shadow-lg shadow-gold/20' : 'bg-border text-muted-foreground cursor-not-allowed'}`}
                                            >
                                                {isExchanging ? '...' : (data.points >= pkg.points ? t('exchange.exchange_now') : t('exchange.insufficient'))}
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </motion.div>

                        {/* History */}
                        <div className="glass bg-white/5 rounded-[2.5rem] border-border overflow-hidden">
                            <div className="p-8 border-b border-border flex justify-between items-center">
                                <div className="flex items-center gap-3">
                                    <History size={18} className="text-gold" />
                                    <h3 className="font-heading uppercase tracking-widest">{t('history_title')}</h3>
                                </div>
                            </div>
                            <div className="divide-y divide-border">
                                {loading ? (
                                    <div className="p-10 text-center text-muted-foreground uppercase text-[10px] tracking-widest">{t('syncing')}</div>
                                ) : data.history.length > 0 ? (
                                    data.history.map((tx, i) => (
                                        <div key={tx.id} className="p-6 flex items-center justify-between hover:bg-white/[0.02] transition-colors">
                                            <div className="flex items-center gap-4">
                                                <div className={`p-3 rounded-xl ${tx.points > 0 ? 'bg-emerald-500/10 text-emerald-500' : 'bg-red-500/10 text-red-500'}`}>
                                                    {tx.points > 0 ? <Zap size={16} /> : <Gift size={16} />}
                                                </div>
                                                <div>
                                                    <p className="text-xs font-bold uppercase tracking-widest text-foreground">
                                                        {(() => {
                                                            const r = tx.reason.toLowerCase();
                                                            if (r.startsWith('earned_from_order')) {
                                                                const id = tx.reason.split('_').pop();
                                                                return t('reasons.earned_from_order', { id });
                                                            }
                                                            return t(`reasons.${r}`);
                                                        })()}
                                                    </p>
                                                    <p className="text-[10px] text-muted-foreground uppercase mt-0.5">
                                                        {format(new Date(tx.createdAt), 'MMM dd, yyyy • HH:mm', { locale: dateLocale })}
                                                    </p>
                                                </div>
                                            </div>
                                            <span className={`font-heading ${tx.points > 0 ? 'text-emerald-500' : 'text-red-500'}`}>
                                                {tx.points > 0 ? '+' : ''}{tx.points}
                                            </span>
                                        </div>
                                    ))
                                ) : (
                                    <div className="p-20 text-center">
                                        <p className="text-muted-foreground uppercase text-[10px] tracking-widest">{t('empty')}</p>
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
 
                    {/* Sidebar Rewards */}
                    <div className="space-y-6">
                        <div className="glass p-8 rounded-[2.5rem] border-gold/10">
                            <h3 className="font-heading text-sm uppercase tracking-widest mb-6 flex items-center gap-2">
                                <Trophy size={16} className="text-gold" /> {t('perks_title')}
                            </h3>
                            <div className="space-y-4">
                                {[
                                    { key: 'free_shipping', points: 500, icon: ArrowUpRight },
                                    { key: 'discount_10', points: 1000, icon: Gift },
                                    { key: 'rare_case', points: 2500, icon: ShieldCheck },
                                ].map((perk, i) => (
                                    <div key={i} className="p-4 rounded-2xl border border-border bg-white/[0.02] group cursor-pointer hover:border-gold/30 transition-all">
                                        <div className="flex justify-between items-center">
                                            <div>
                                                <p className="text-xs font-bold uppercase tracking-wider text-foreground">{t(`perks_list.${perk.key}`)}</p>
                                                <p className="text-[10px] text-gold uppercase font-bold mt-1">{perk.points} {t('credits_suffix')}</p>
                                            </div>
                                            <perk.icon size={14} className="text-muted-foreground group-hover:text-gold transition-colors" />
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
 
                        <div className="glass p-8 rounded-[2.5rem] border-ai/10 bg-ai/5">
                            <h3 className="font-heading text-[10px] text-ai uppercase tracking-[.4em] mb-4">{t('ai_insight_title')}</h3>
                            <p className="text-xs text-muted-foreground font-body leading-relaxed">
                                {t('ai_insight_desc')}
                            </p>
                        </div>
                    </div>
                </div>
            </main>
        </AuthGuard>
    );
}
