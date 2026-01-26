'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { Coins, Trophy, Zap, Star } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { useAuth } from '@/hooks/use-auth';
import { motion } from 'framer-motion';

export default function CustomerLoyalty() {
    const t = useTranslations('loyalty');
    const { user } = useAuth();

    // Fallback to 0 if points don't exist yet
    const points = user?.points || 0;
    const nextTierThreshold = 5000;
    const progress = Math.min((points / nextTierThreshold) * 100, 100);

    const redeemItems = [
        { key: 'kit', points: '500', icon: Star },
        { key: 'engraving', points: '1200', icon: Zap },
        { key: 'masterclass', points: '5000', icon: Trophy },
    ];

    return (
        <AuthGuard allowedRoles={['customer']}>
            <main className="p-4 md:p-8 max-w-7xl mx-auto">
                <motion.header
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    className="mb-12"
                >
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">{t('title')}</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-[0.2em]">{t('subtitle')}</p>
                </motion.header>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-16">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="lg:col-span-2 glass p-10 md:p-14 rounded-[4rem] border-gold/20 bg-gradient-to-br from-gold/10 via-transparent to-transparent relative overflow-hidden"
                    >
                        <div className="relative z-10 flex flex-col justify-between h-full">
                            <div className="flex justify-between items-start mb-16">
                                <div>
                                    <h2 className="font-heading text-5xl md:text-6xl text-foreground mb-4 tabular-nums">
                                        {points.toLocaleString()}
                                    </h2>
                                    <p className="text-[10px] text-gold uppercase tracking-[0.4em] font-bold">
                                        {t('points')}
                                    </p>
                                </div>
                                <div className="w-16 h-16 md:w-20 md:h-20 rounded-[2rem] glass border-gold/30 flex items-center justify-center shadow-2xl shadow-gold/10">
                                    <Coins className="w-8 h-8 md:w-10 md:h-10 text-gold" />
                                </div>
                            </div>

                            <div className="space-y-6">
                                <div className="flex justify-between text-[10px] uppercase font-heading tracking-[0.3em] mb-4">
                                    <span className="text-muted-foreground">{t('progress')}</span>
                                    <span className="text-gold font-bold">{Math.round(progress)}%</span>
                                </div>
                                <div className="h-2 w-full bg-white/5 rounded-full overflow-hidden p-[1px]">
                                    <motion.div
                                        initial={{ width: 0 }}
                                        animate={{ width: `${progress}%` }}
                                        transition={{ duration: 1.5, ease: "easeOut" }}
                                        className="h-full bg-gold rounded-full shadow-[0_0_20px_rgba(212,175,55,0.4)]"
                                    />
                                </div>
                            </div>
                        </div>
                        <div className="absolute -bottom-20 -right-20 w-96 h-96 bg-gold/5 rounded-full blur-[100px]" />
                        <div className="absolute top-10 right-10 w-40 h-40 bg-pink-500/5 rounded-full blur-[80px]" />
                    </motion.div>

                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="glass p-10 rounded-[3.5rem] border-border flex flex-col justify-center text-center relative group"
                    >
                        <div className="absolute inset-0 bg-gold/5 opacity-0 group-hover:opacity-100 transition-opacity rounded-[3.5rem]" />
                        <Trophy className="w-14 h-14 text-gold mx-auto mb-8 opacity-30 group-hover:opacity-100 group-hover:scale-110 transition-all duration-500" />
                        <h3 className="font-heading text-xl text-foreground uppercase tracking-widest mb-4">{t('perks.title')}</h3>
                        <p className="text-[10px] text-muted-foreground uppercase tracking-[0.2em] leading-relaxed mb-10 px-4">
                            {t('perks.desc')}
                        </p>
                        <button className="w-full py-5 glass border-gold/20 text-gold font-heading text-[10px] uppercase tracking-[0.3em] rounded-2xl hover:bg-gold hover:text-primary-foreground transition-all duration-500">
                            {t('perks.cta')}
                        </button>
                    </motion.div>
                </div>

                <motion.h2
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.3 }}
                    className="font-heading text-2xl uppercase tracking-[0.3em] mb-10 text-center md:text-left"
                >
                    {t('redeem.title')}
                </motion.h2>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                    {redeemItems.map((item, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.4 + (i * 0.1) }}
                            className="glass p-10 rounded-[3rem] border-border hover:border-gold/30 transition-all duration-500 text-center group cursor-pointer relative overflow-hidden"
                        >
                            <div className="absolute inset-0 bg-gradient-to-t from-gold/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
                            <div className="w-16 h-16 rounded-[1.5rem] glass mb-8 mx-auto flex items-center justify-center border-gold/5 group-hover:bg-gold/10 group-hover:border-gold/20 group-hover:scale-110 transition-all duration-500">
                                <item.icon className="w-7 h-7 text-gold" />
                            </div>
                            <h4 className="font-heading text-[11px] uppercase tracking-[0.2em] mb-3 text-muted-foreground group-hover:text-foreground transition-colors">
                                {t(`redeem.items.${item.key}`)}
                            </h4>
                            <p className="font-heading text-2xl text-foreground mb-8 tabular-nums">
                                {item.points} <span className="text-xs text-gold/60 uppercase tracking-widest ml-1">pts</span>
                            </p>
                            <button className="w-full py-3.5 rounded-xl border border-border text-[9px] uppercase font-heading tracking-[0.3em] group-hover:bg-gold group-hover:text-primary-foreground group-hover:border-gold transition-all duration-500">
                                {t('redeem.cta')}
                            </button>
                        </motion.div>
                    ))}
                </div>
            </main>
        </AuthGuard>
    );
}
