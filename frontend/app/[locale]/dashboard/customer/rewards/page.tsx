'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { Trophy, Star, Sparkles } from 'lucide-react';
import { useTranslations } from 'next-intl';

export default function RewardsPage() {
    const t = useTranslations('rewards_page');

    const tiers = [
        {
            tier: t('tiers.silver.name'),
            req: t('tiers.silver.req'),
            perk: t('tiers.silver.perk'),
            icon: Trophy,
            color: 'text-stone-400',
            bg: 'bg-stone-500/10'
        },
        {
            tier: t('tiers.gold.name'),
            req: t('tiers.gold.req'),
            perk: t('tiers.gold.perk'),
            icon: Trophy,
            color: 'text-gold',
            bg: 'bg-gold/10'
        },
        {
            tier: t('tiers.platinum.name'),
            req: t('tiers.platinum.req'),
            perk: t('tiers.platinum.perk'),
            icon: Star,
            color: 'text-blue-400',
            bg: 'bg-blue-400/10'
        },
        {
            tier: t('tiers.obsidian.name'),
            req: t('tiers.obsidian.req'),
            perk: t('tiers.obsidian.perk'),
            icon: Sparkles,
            color: 'text-zinc-400',
            bg: 'bg-zinc-500/10'
        }
    ];

    return (
        <div className="relative pb-12">
            <header className="mb-16 md:mb-24 text-center space-y-6">
                <motion.div
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="inline-flex items-center gap-3 px-6 py-2.5 rounded-full glass border-gold/20 text-gold text-[10px] font-bold uppercase tracking-[0.4em] mb-4 shadow-xl"
                >
                    <Trophy size={14} strokeWidth={2} />
                    {t('badge') || 'Elite Rewards'}
                </motion.div>
                
                <motion.h1
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-5xl md:text-8xl font-heading font-bold uppercase tracking-tighter leading-none text-foreground"
                >
                    {t.rich('title', {
                        tiers: (chunks) => <span className="gold-gradient italic block md:inline">{chunks}</span>
                    })}
                </motion.h1>
                
                <motion.p
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.1 }}
                    className="text-stone-500 font-body text-[10px] md:text-sm uppercase tracking-[0.5em] font-bold max-w-2xl mx-auto opacity-70"
                >
                    {t('subtitle')}
                </motion.p>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-10 lg:gap-12">
                {tiers.map((tier, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, y: 40 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1, duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
                        viewport={{ once: true }}
                        className="group relative glass rounded-[4rem] p-12 md:p-14 border-black/5 dark:border-white/5 hover:border-gold/30 transition-all duration-700 shadow-2xl overflow-hidden"
                    >
                        <div className="absolute inset-0 bg-gradient-to-br from-gold/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-1000" />
                        
                        <div className="relative flex justify-between items-start mb-12">
                            <div className="space-y-3">
                                <h3 className="text-4xl md:text-5xl font-heading font-bold text-foreground group-hover:italic transition-all duration-700 uppercase tracking-tighter group-hover:text-gold">
                                    {tier.tier}
                                </h3>
                                <div className="h-1.5 w-16 bg-gold/30 rounded-full group-hover:w-32 group-hover:bg-gold transition-all duration-1000" />
                            </div>
                            <div className={cn("p-6 rounded-3xl glass border-black/5 dark:border-white/10 group-hover:scale-110 group-hover:rotate-6 transition-all duration-700 shadow-xl", tier.bg)}>
                                <tier.icon className={cn(tier.color, "w-10 h-10")} strokeWidth={1} />
                            </div>
                        </div>
                        
                        <div className="relative space-y-8">
                            <div className="space-y-2">
                                <p className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">
                                    {t('requirement_label') || 'Requirement'}
                                </p>
                                <p className="text-xl md:text-2xl font-heading font-bold text-foreground tracking-tight">
                                    {tier.req}
                                </p>
                            </div>
                            
                            <div className="pt-8 border-t border-black/5 dark:border-white/5 space-y-3">
                                <p className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">
                                    {t('perks_label') || 'Exclusive Perks'}
                                </p>
                                <p className="text-[11px] md:text-xs text-stone-500 italic leading-relaxed uppercase tracking-[0.3em] font-bold group-hover:text-foreground transition-colors">
                                    {tier.perk}
                                </p>
                            </div>
                        </div>
                    </motion.div>
                ))}
            </div>
            
            <footer className="mt-32 text-center">
               <motion.div 
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                className="inline-block p-12 rounded-[4rem] glass border-black/5 dark:border-white/5 max-w-2xl shadow-2xl"
               >
                  <div className="flex items-center justify-center gap-4 mb-6">
                    <Sparkles className="text-gold animate-pulse" size={20} />
                    <p className="text-[11px] font-black uppercase tracking-[0.4em] text-gold">{t('pro_tip') || 'Aura Membership'}</p>
                  </div>
                  <p className="text-xs text-stone-500 leading-relaxed italic uppercase tracking-widest font-bold opacity-70">
                    {t('pro_tip_desc') || 'Your tier is recalculated monthly based on your engagement and purchases.'}
                  </p>
               </motion.div>
            </footer>
        </div>
    );
}
