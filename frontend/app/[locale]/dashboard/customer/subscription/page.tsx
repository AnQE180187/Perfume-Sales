'use client';

import React from 'react';
import { Bookmark, Calendar, Zap } from 'lucide-react';
import { motion } from 'framer-motion';
import { useTranslations, useLocale, useFormatter } from 'next-intl';

export default function SubscriptionPage() {
    const t = useTranslations('subscription_page');
    const tFeatured = useTranslations('featured');
    const locale = useLocale();
    const format = useFormatter();

    const priceAmount = locale === 'vi' ? 2000000 : 85;
    const formattedPrice = format.number(priceAmount, {
        style: 'currency',
        currency: tFeatured('currency_code') || 'VND',
        maximumFractionDigits: 0
    });

    return (
        <div className="relative pb-12">
            <header className="max-w-4xl mx-auto text-center mb-24 space-y-8">
                <div className="flex items-center justify-center gap-4 mb-4">
                  <div className="h-[1px] w-12 bg-gold/50" />
                  <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Exclusive Membership</span>
                </div>
                <motion.h1
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-5xl md:text-8xl font-heading font-bold text-foreground uppercase tracking-tighter leading-none"
                >
                    {t.rich('title', {
                        club: (chunks) => <span className="gold-gradient italic">{chunks}</span>
                    })}
                </motion.h1>
                <motion.p
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                    className="text-stone-500 font-body text-[10px] md:text-sm uppercase tracking-[0.5em] font-bold max-w-2xl mx-auto opacity-70"
                >
                    {t('subtitle')}
                </motion.p>
            </header>

            <div className="max-w-4xl mx-auto space-y-24">
                <motion.div
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="relative group p-1 rounded-[4rem] glass overflow-hidden shadow-[0_50px_100px_-20px_rgba(0,0,0,0.5)] dark:shadow-[0_50px_100px_-20px_rgba(0,0,0,0.8)]"
                >
                    <div className="absolute inset-0 bg-gradient-to-br from-gold/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-[1500ms]" />
                    
                    <div className="bg-luxury-black dark:bg-black p-12 md:p-20 rounded-[3.9rem] text-center space-y-12 relative overflow-hidden">
                        <div className="absolute top-0 right-0 w-64 h-64 md:w-96 md:h-96 bg-gold/10 blur-[100px] md:blur-[150px] animate-pulse" />
                        <div className="absolute bottom-0 left-0 w-64 h-64 md:w-96 md:h-96 bg-gold/5 blur-[100px] md:blur-[150px] animate-pulse" />

                        <div className="relative z-10 space-y-10">
                            <h3 className="text-3xl md:text-4xl font-heading italic text-white font-bold uppercase tracking-widest">{t('card.title')}</h3>
                            <p className="text-stone-400 text-[10px] md:text-xs italic font-bold uppercase tracking-[0.4em] max-w-sm mx-auto leading-loose opacity-60">
                                {t('card.quote')}
                            </p>
                            <div className="text-6xl md:text-8xl font-heading font-bold text-gold italic tracking-tighter leading-none py-4">
                                {t('card.price', { amount: formattedPrice })} <span className="text-xs md:text-lg text-stone-500 not-italic uppercase tracking-widest block mt-4">{t('card.per_month')}</span>
                            </div>
                            <button className="h-20 px-16 bg-white text-black rounded-full font-bold tracking-[.5em] uppercase text-[10px] hover:scale-105 transition-all shadow-2xl shadow-white/10 cursor-pointer">
                                {t('card.cta')}
                            </button>
                        </div>
                    </div>
                </motion.div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-16 md:gap-12">
                    {[
                        { icon: Bookmark, title: t('perks.drops.title'), desc: t('perks.drops.desc') },
                        { icon: Calendar, title: t('perks.sync.title'), desc: t('perks.sync.desc') },
                        { icon: Zap, title: t('perks.retraining.title'), desc: t('perks.retraining.desc') }
                    ].map((item, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 30 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.1, duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
                            viewport={{ once: true }}
                            className="text-center space-y-8 group"
                        >
                            <div className="w-20 h-20 rounded-3xl glass border-black/5 dark:border-white/5 mx-auto flex items-center justify-center text-gold shadow-2xl group-hover:scale-110 group-hover:rotate-12 transition-all duration-700">
                                <item.icon className="w-8 h-8" strokeWidth={1} />
                            </div>
                            <div className="space-y-4">
                                <h4 className="text-[10px] font-black tracking-[0.4em] uppercase text-foreground group-hover:text-gold transition-colors">
                                    {item.title}
                                </h4>
                                <p className="text-[10px] text-stone-500 uppercase tracking-[0.3em] italic font-bold leading-relaxed opacity-60 group-hover:opacity-100 transition-opacity">
                                    {item.desc}
                                </p>
                            </div>
                        </motion.div>
                    ))}
                </div>
            </div>
        </div>
    );
}
