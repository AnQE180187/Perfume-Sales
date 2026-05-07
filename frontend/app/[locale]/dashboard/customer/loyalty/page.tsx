'use client';
 
import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Coins, Trophy, History, ArrowUpRight, Zap, Gift, ShieldCheck, Tag, Plus, Loader2, Wallet, Copy, CheckCircle2, Timer } from 'lucide-react';
import { useTranslations, useFormatter } from 'next-intl';
import { loyaltyService } from '@/services/loyalty.service';
import { promotionService } from '@/services/promotion.service';
import { format } from 'date-fns';
import { vi, enUS } from 'date-fns/locale';
import { useParams } from 'next/navigation';
import { toast } from 'sonner';
import { Link } from '@/lib/i18n';
 
export default function LoyaltyDashboard() {
    const t = useTranslations('dashboard.customer.loyalty');
    const tMarket = useTranslations('vouchers');
    const tPromo = useTranslations('dashboard.customer.promotions');
    const nf = useFormatter();
    const { locale } = useParams();
    const dateLocale = locale === 'vi' ? vi : enUS;
    const [data, setData] = useState<{ points: number; history: any[] }>({ points: 0, history: [] });
    const [myPromos, setMyPromos] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [copiedCode, setCopiedCode] = useState<string | null>(null);


    const fetchData = async () => {
        setLoading(true);
        try {
            const [status, my] = await Promise.all([
                loyaltyService.getStatus(),
                promotionService.getMyPromotions(),
            ]);
            setData(status);
            setMyPromos(my);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

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
        if (remaining <= 0) return tPromo('expired') || 'Expired';

        const hours = Math.floor(remaining / (1000 * 60 * 60));
        const minutes = Math.floor((remaining % (1000 * 60 * 60)) / (1000 * 60));
        return tPromo('time_left', { time: `${hours}h ${minutes}m` }) || `${hours}h ${minutes}m left`;
    };


    return (
        <div className="relative pb-12">
            <header className="mb-12">
                <div className="flex items-center gap-4 mb-4">
                  <div className="h-[1px] w-12 bg-gold/50" />
                  <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Privilege Program</span>
                </div>
                <h1 className="font-heading text-4xl font-bold uppercase tracking-tighter text-foreground md:text-5xl">
                  {t('title')} <span className="gold-gradient">Rewards</span>
                </h1>
                <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest text-stone-500 max-w-xl">
                  {t('subtitle')}
                </p>
            </header>

            <div className="space-y-12">
                {/* Points Card */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="glass rounded-[3rem] p-1 overflow-hidden shadow-2xl"
                >
                    <div className="bg-stone-100/40 dark:bg-zinc-900/40 backdrop-blur-3xl p-8 md:p-12 rounded-[2.9rem] flex flex-col md:flex-row items-center gap-10">
                        <div className="relative shrink-0">
                            <div className="w-32 h-32 md:w-40 md:h-40 rounded-[2.5rem] border border-gold/20 flex items-center justify-center glass bg-white shadow-2xl">
                                <div className="absolute inset-2 rounded-[2rem] border border-gold/10 animate-pulse" />
                                <Coins className="text-gold w-12 h-12 md:w-16 md:h-16" strokeWidth={1} />
                            </div>
                        </div>
                        <div className="flex-1 text-center md:text-left space-y-4">
                            <h2 className="text-6xl md:text-8xl font-heading font-bold text-foreground tracking-tighter">
                                {data.points} <span className="text-[10px] md:text-sm font-body text-stone-400 dark:text-stone-700 tracking-[0.5em] uppercase font-bold ml-2">{t('credits_suffix')}</span>
                            </h2>
                            <p className="text-[10px] md:text-xs text-stone-500 uppercase tracking-widest leading-relaxed max-w-xl italic opacity-80">
                                {t('ai_insight_desc')}
                            </p>
                        </div>
                        <div className="flex w-full md:w-auto">
                             <Link href="/dashboard/customer/promotions" className="w-full md:w-auto h-16 flex items-center justify-center px-10 rounded-full bg-gold text-black font-heading text-[10px] uppercase tracking-widest hover:scale-105 transition-all shadow-xl shadow-gold/20">
                                {t('discover_market')}
                            </Link>
                        </div>
                    </div>
                </motion.div>

                {/* Olfactory Incentives (Owned Vouchers) */}
                <div className="space-y-8">
                    <div className="flex items-center justify-between px-4">
                        <div className="flex items-center gap-4">
                            <div className="h-2 w-2 rounded-full bg-gold animate-pulse" />
                            <h3 className="font-heading text-xl font-bold uppercase tracking-widest">{t('my_vouchers')}</h3>
                        </div>
                    </div>
                    
                    {loading ? (
                        <div className="py-20 glass rounded-[3rem] text-center flex flex-col items-center gap-6">
                            <div className="relative w-16 h-16">
                                <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 4, ease: "linear" }} className="absolute inset-0 border-t-2 border-gold rounded-full" />
                                <div className="absolute inset-0 flex items-center justify-center">
                                    <Wallet className="text-gold opacity-20" size={24} />
                                </div>
                            </div>
                            <p className="text-[10px] text-stone-400 uppercase tracking-widest font-bold animate-pulse">{tMarket('loading')}</p>
                        </div>
                    ) : myPromos.length > 0 ? (
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                            {myPromos.map((userPromo, i) => {
                                const promo = userPromo.promotion || {};
                                return (
                                    <motion.div 
                                        key={userPromo.id} 
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        transition={{ delay: i * 0.1 }}
                                        className="group relative glass rounded-[2.5rem] p-8 flex flex-col h-full bg-stone-50/50 dark:bg-zinc-900/50 hover:border-gold/30 transition-all duration-500 shadow-xl overflow-hidden"
                                    >
                                        <div className="absolute inset-0 bg-gradient-to-br from-gold/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
                                        
                                        <div className="flex justify-between items-start mb-8 relative z-10">
                                            <div className="h-12 w-12 glass rounded-2xl flex items-center justify-center text-gold shadow-lg group-hover:scale-110 transition-transform">
                                                <Tag size={20} strokeWidth={1.5} />
                                            </div>
                                            {promo.endDate && (
                                                <div className="px-4 py-2 rounded-full glass border-gold/10 text-gold text-[8px] uppercase tracking-[0.2em] font-black flex items-center gap-2">
                                                    <Timer size={10} />
                                                    {formatTimeRemaining(promo.endDate)}
                                                </div>
                                            )}
                                        </div>

                                        <h4 className="text-2xl font-heading font-bold text-foreground uppercase tracking-tight mb-3 group-hover:text-gold transition-colors">{promo.code}</h4>
                                        <p className="text-[10px] text-stone-500 uppercase mt-1 mb-10 flex-1 line-clamp-3 italic tracking-widest leading-loose">
                                            {promo.description || tPromo('fallback_desc')}
                                        </p>

                                        <div className="flex items-center justify-between pt-6 border-t border-black/5 dark:border-white/5 relative z-10">
                                            <div>
                                                <p className="text-[8px] text-stone-400 dark:text-stone-700 uppercase tracking-widest font-bold mb-2">{tPromo('benefit_label')}</p>
                                                <p className="text-2xl font-heading gold-gradient font-bold italic">
                                                    {promo.discountType === 'PERCENTAGE' 
                                                        ? `${promo.discountValue}% OFF`
                                                        : `-${nf.number(promo.discountValue)} đ`}
                                                </p>
                                            </div>
                                            <button
                                                onClick={() => copyToClipboard(promo.code)}
                                                className="h-14 w-14 rounded-2xl glass border-black/5 dark:border-white/5 text-gold hover:bg-gold hover:text-black transition-all shadow-lg flex items-center justify-center cursor-pointer"
                                                title={tPromo('copy_btn')}
                                            >
                                                {copiedCode === promo.code ? <CheckCircle2 size={20} /> : <Copy size={20} />}
                                            </button>
                                        </div>
                                    </motion.div>
                                );
                            })}
                        </div>
                    ) : (
                        <div className="py-24 glass rounded-[3rem] text-center opacity-40">
                            <Wallet className="w-16 h-16 text-stone-300 dark:text-stone-800 mx-auto mb-6" strokeWidth={1} />
                            <p className="text-[10px] text-stone-500 uppercase tracking-widest font-bold">{tPromo('no_promos')}</p>
                        </div>
                    )}
                </div>

                {/* History */}
                <div className="space-y-8">
                    <div className="flex items-center gap-4 px-4">
                        <div className="h-2 w-2 rounded-full bg-gold" />
                        <h3 className="font-heading text-xl font-bold uppercase tracking-widest">{t('history_title')}</h3>
                    </div>
                    
                    <div className="glass rounded-[3rem] overflow-hidden shadow-2xl">
                        {loading ? (
                            <div className="p-20 text-center text-stone-400 uppercase text-[10px] tracking-[0.4em] font-bold animate-pulse">{t('syncing')}</div>
                        ) : data.history.length > 0 ? (
                            <div className="divide-y divide-black/5 dark:divide-white/5">
                                {data.history.map((tx, i) => (
                                    <div key={tx.id} className="p-8 md:p-10 flex items-center justify-between hover:bg-stone-50/50 dark:hover:bg-zinc-900/50 transition-all group">
                                        <div className="flex items-center gap-6 flex-1 min-w-0">
                                            <div className={cn(
                                                "h-14 w-14 rounded-2xl shrink-0 flex items-center justify-center shadow-lg transition-transform group-hover:scale-110",
                                                tx.points > 0 ? 'bg-emerald-500/10 text-emerald-500 border border-emerald-500/20' : 'bg-red-500/10 text-red-500 border border-red-500/20'
                                            )}>
                                                {tx.points > 0 ? <Zap size={20} strokeWidth={1.5} /> : <Gift size={20} strokeWidth={1.5} />}
                                            </div>
                                            <div className="min-w-0 space-y-1">
                                                <p className="text-[10px] md:text-xs font-bold uppercase tracking-widest text-foreground truncate group-hover:text-gold transition-colors">
                                                    {(() => {
                                                        const r = tx.reason.toLowerCase();
                                                        if (r.startsWith('earned_from_order')) {
                                                            const id = tx.reason.split('_').pop();
                                                            return t('reasons.earned_from_order', { id });
                                                        }
                                                        if (r.startsWith('exchanged_for_voucher')) {
                                                            const code = tx.reason.split('_').pop()?.toUpperCase();
                                                            return t('reasons.exchanged_for_voucher_generic', { code });
                                                        }
                                                        if (r.startsWith('redeemed_for_order_voucher_redeem')) {
                                                            const code = tx.reason.split('_').pop()?.toUpperCase();
                                                            if (code === 'MAX') return t('reasons.redeemed_for_order_voucher_redeem_freeship_max');
                                                            return t('reasons.redeemed_for_order_voucher_redeem_generic', { code });
                                                        }
                                                        try {
                                                            return t(`reasons.${r}`);
                                                        } catch (e) {
                                                            return r.replace(/_/g, ' ').toUpperCase();
                                                        }
                                                    })()}
                                                </p>
                                                <p className="text-[8px] md:text-[9px] text-stone-400 dark:text-stone-700 uppercase font-bold tracking-widest">
                                                    {format(new Date(tx.createdAt), 'MMM dd, yyyy • HH:mm', { locale: dateLocale })}
                                                </p>
                                            </div>
                                        </div>
                                        <div className="text-right">
                                            <span className={cn(
                                                "font-heading text-2xl md:text-3xl italic font-bold",
                                                tx.points > 0 ? 'text-emerald-500' : 'text-red-500'
                                            )}>
                                                {tx.points > 0 ? '+' : ''}{tx.points}
                                            </span>
                                            <p className="text-[8px] text-stone-400 uppercase font-black tracking-widest mt-1">Credits</p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ) : (
                            <div className="py-32 text-center opacity-30 space-y-6">
                                <History className="w-20 h-20 mx-auto text-stone-300 dark:text-stone-800" strokeWidth={1} />
                                <p className="text-stone-500 uppercase text-[10px] tracking-[0.5em] font-black">{t('empty')}</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
}
