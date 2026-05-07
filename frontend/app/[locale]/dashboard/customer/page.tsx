'use client';

import { useEffect, useState } from 'react';
import { useLocale, useTranslations } from 'next-intl';
import { 
    ArrowUpRight, 
    Inbox, 
    Loader2, 
    MapPinned, 
    Sparkles, 
    User, 
    Zap, 
    Dna, 
    Bot, 
    Bell, 
    ChevronRight,
    Heart,
    ShieldCheck
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '@/lib/utils';

import { Link } from '@/lib/i18n';
import { quizService, type QuizRecommendation } from '@/services/quiz.service';

interface LatestQuizResult {
    id: string;
    createdAt: string;
    recommendation?: QuizRecommendation[];
    recommendations?: QuizRecommendation[];
    gender?: string;
    occasion?: string;
    preferredFamily?: string;
    longevity?: string;
    analysis?: string;
}

export default function CustomerDashboard() {
    const t = useTranslations('dashboard.customer.home');
    const locale = useLocale();

    const [quizLoading, setQuizLoading] = useState(true);
    const [latestQuiz, setLatestQuiz] = useState<LatestQuizResult | null>(null);

    useEffect(() => {
        quizService.getHistory()
            .then((data) => {
                if (Array.isArray(data) && data.length > 0) {
                    setLatestQuiz(data[0]);
                }
            })
            .catch(console.error)
            .finally(() => setQuizLoading(false));
    }, []);

    const latestRecommendations = latestQuiz?.recommendation ?? latestQuiz?.recommendations ?? [];
    const featuredRecommendation = latestRecommendations[0];

    const modules = [
        { key: 'profile', icon: User, href: '/dashboard/customer/profile', color: 'text-stone-400 dark:text-stone-500' },
        { key: 'orders', icon: Inbox, href: '/dashboard/customer/orders', color: 'text-stone-400 dark:text-stone-500' },
        { key: 'loyalty', icon: Zap, href: '/dashboard/customer/loyalty', color: 'text-gold' },
        { key: 'scent_dna', icon: Dna, href: '/dashboard/customer/scent-dna', color: 'text-gold' },
        { key: 'consultation', icon: Bot, href: '/dashboard/customer/consultation', color: 'text-gold' },
        { key: 'favorite', icon: Heart, href: '/dashboard/customer/favorite', color: 'text-stone-400 dark:text-stone-500' },
        { key: 'addresses', icon: MapPinned, href: '/dashboard/customer/addresses', color: 'text-stone-400 dark:text-stone-500' },
        { key: 'notifications', icon: Bell, href: '/dashboard/customer/notifications', color: 'text-stone-400 dark:text-stone-500' },
    ];

    return (
        <div className="mx-auto max-w-7xl">
            <motion.header 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="mb-12 flex flex-col items-start justify-between gap-6 md:flex-row md:items-end"
            >
                <div className="space-y-2">
                    <div className="flex items-center gap-2">
                        <div className="h-[1px] w-8 bg-gold/50" />
                        <span className="text-[10px] font-bold uppercase tracking-[0.3em] text-gold/80">{t('title')}</span>
                    </div>
                    <h1 className="text-4xl font-heading uppercase tracking-tighter text-foreground md:text-6xl">
                        The <span className="gold-gradient">Sanctum</span>
                    </h1>
                </div>
            </motion.header>

            <div className="grid grid-cols-1 gap-8 lg:grid-cols-12">
                {/* Featured Intelligence Section */}
                <motion.div 
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.1 }}
                    className="lg:col-span-8"
                >
                    <div className="glass group relative overflow-hidden rounded-[2.5rem] p-1 transition-all duration-500 hover:border-gold/30">
                        <div className="absolute inset-0 bg-gradient-to-br from-gold/5 via-transparent to-transparent opacity-50" />
                        
                        <div className="relative flex h-full flex-col gap-8 rounded-[2.4rem] p-8 md:flex-row md:p-12">
                            <div className="relative aspect-square w-full shrink-0 overflow-hidden rounded-3xl border border-black/5 dark:border-white/10 md:w-[320px]">
                                <AnimatePresence mode="wait">
                                    {quizLoading ? (
                                        <motion.div 
                                            key="loading"
                                            initial={{ opacity: 0 }}
                                            animate={{ opacity: 1 }}
                                            exit={{ opacity: 0 }}
                                            className="flex h-full items-center justify-center bg-stone-100 dark:bg-zinc-900"
                                        >
                                            <div className="text-center">
                                                <Loader2 size={32} className="mx-auto mb-4 animate-spin text-gold" />
                                                <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-gold/60">{t('analyzing')}</p>
                                            </div>
                                        </motion.div>
                                    ) : featuredRecommendation ? (
                                        <motion.div
                                            key="result"
                                            initial={{ opacity: 0 }}
                                            animate={{ opacity: 1 }}
                                            className="h-full"
                                        >
                                            <img
                                                src={featuredRecommendation.imageUrl || '/hero-bottle.png'}
                                                alt={featuredRecommendation.name}
                                                className="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110"
                                            />
                                            <div className="absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent" />
                                        </motion.div>
                                    ) : (
                                        <motion.div 
                                            key="empty"
                                            initial={{ opacity: 0 }}
                                            animate={{ opacity: 1 }}
                                            className="flex h-full items-center justify-center bg-stone-100 dark:bg-zinc-900"
                                        >
                                            <Sparkles size={48} className="text-gold/20" />
                                        </motion.div>
                                    )}
                                </AnimatePresence>
                            </div>

                            <div className="flex flex-1 flex-col justify-center">
                                <div className="mb-6 space-y-4">
                                    <div className="flex items-center gap-3">
                                        <span className="flex h-6 items-center rounded-full bg-gold/10 px-3 text-[10px] font-bold uppercase tracking-widest text-gold">
                                            AI Synthesis
                                        </span>
                                        {latestQuiz?.preferredFamily && (
                                            <span className="text-[10px] font-medium uppercase tracking-widest text-stone-400 dark:text-stone-500">
                                                {latestQuiz.preferredFamily}
                                            </span>
                                        )}
                                    </div>
                                    
                                    <h2 className="text-3xl font-heading uppercase tracking-widest text-foreground md:text-4xl">
                                        {featuredRecommendation ? featuredRecommendation.name : t('evolving_title')}
                                    </h2>
                                    
                                    <p className="line-clamp-4 font-body text-sm leading-relaxed text-stone-600 dark:text-stone-400">
                                        {featuredRecommendation?.reason || latestQuiz?.analysis || t('evolving_desc')}
                                    </p>
                                </div>

                                <div className="flex flex-wrap gap-4">
                                    <Link
                                        href="/quiz"
                                        className="group/btn relative flex items-center gap-3 overflow-hidden rounded-full bg-gold px-8 py-4 text-[11px] font-bold uppercase tracking-widest text-black transition-all hover:pr-10"
                                    >
                                        <span className="relative z-10">{featuredRecommendation ? (locale === 'vi' ? 'Xem Kết Quả' : 'View Results') : t('refresh_btn')}</span>
                                        <ChevronRight size={16} className="relative z-10 transition-transform group-hover/btn:translate-x-1" />
                                        <div className="absolute inset-0 -translate-x-full bg-white/20 transition-transform group-hover:translate-x-0" />
                                    </Link>
                                </div>
                            </div>
                        </div>
                    </div>
                </motion.div>

                {/* Quick Actions / Stats Section */}
                <motion.div 
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.2 }}
                    className="space-y-6 lg:col-span-4"
                >
                    <div className="glass rounded-[2.5rem] p-8">
                        <h3 className="mb-6 text-[10px] font-bold uppercase tracking-[0.3em] text-gold/60">Registry Status</h3>
                        <div className="space-y-6">
                            <div className="flex items-center justify-between border-b border-black/5 dark:border-white/5 pb-4">
                                <div className="flex items-center gap-3">
                                    <div className="h-2 w-2 rounded-full bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.5)]" />
                                    <span className="text-xs text-stone-500">Neural Sync</span>
                                </div>
                                <span className="text-xs font-bold text-emerald-600 dark:text-emerald-500">ACTIVE</span>
                            </div>
                            <div className="flex items-center justify-between border-b border-black/5 dark:border-white/5 pb-4">
                                <div className="flex items-center gap-3">
                                    <ShieldCheck size={14} className="text-gold" />
                                    <span className="text-xs text-stone-500">Encryption</span>
                                </div>
                                <span className="text-xs font-bold text-foreground">AES-256</span>
                            </div>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-3">
                                    <User size={14} className="text-stone-400 dark:text-stone-500" />
                                    <span className="text-xs text-stone-500">Identity</span>
                                </div>
                                <span className="text-xs font-bold text-foreground uppercase tracking-widest">Guest</span>
                            </div>
                        </div>
                    </div>

                    <Link href="/dashboard/chat">
                        <div className="group relative flex items-center justify-between overflow-hidden rounded-[2rem] border border-gold/10 bg-gold/5 p-6 transition-all hover:bg-gold/10">
                            <div className="relative z-10 flex items-center gap-4">
                                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-gold text-black transition-transform duration-500 group-hover:rotate-12">
                                    <Zap size={20} />
                                </div>
                                <div>
                                    <p className="text-[10px] font-bold uppercase tracking-widest text-gold">Priority Access</p>
                                    <p className="text-sm font-semibold text-foreground uppercase tracking-wider">AI Consultation</p>
                                </div>
                            </div>
                            <ArrowUpRight size={20} className="relative z-10 text-gold opacity-0 transition-all duration-300 group-hover:translate-x-1 group-hover:-translate-y-1 group-hover:opacity-100" />
                            <div className="absolute -right-4 -top-4 h-24 w-24 rounded-full bg-gold/5 blur-2xl transition-all group-hover:bg-gold/10" />
                        </div>
                    </Link>
                </motion.div>
            </div>

            {/* Grid Modules */}
            <motion.div 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className="mt-12"
            >
                <div className="mb-8 flex items-center gap-4">
                    <h3 className="text-[11px] font-bold uppercase tracking-[0.5em] text-stone-400 dark:text-stone-500">Navigation Matrix</h3>
                    <div className="h-[1px] flex-1 bg-gradient-to-r from-black/10 to-transparent dark:from-white/10" />
                </div>

                <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4">
                    {modules.map((item, i) => (
                        <Link key={i} href={item.href}>
                            <motion.div 
                                whileHover={{ y: -5, scale: 1.02 }}
                                className="glass group relative overflow-hidden rounded-[2rem] p-6 transition-all duration-300 hover:border-gold/30"
                            >
                                <div className={cn("mb-4 flex h-14 w-14 items-center justify-center rounded-[1.25rem] bg-stone-100 dark:bg-zinc-800/50 transition-all duration-500 group-hover:bg-gold group-hover:text-black group-hover:shadow-[0_0_30px_rgba(197,160,89,0.3)]", item.color)}>
                                    <item.icon size={24} />
                                </div>
                                <div className="space-y-1">
                                    <h4 className="text-[11px] font-bold uppercase tracking-[0.15em] text-foreground transition-colors group-hover:text-gold">{t(`modules.${item.key}`)}</h4>
                                    <p className="text-[9px] uppercase tracking-[0.2em] text-stone-500 font-medium">{t('modules.explore')}</p>
                                </div>
                                <ArrowUpRight size={14} className="absolute right-6 top-6 text-stone-400 dark:text-stone-600 opacity-0 transition-all group-hover:opacity-100 group-hover:text-gold" />
                            </motion.div>
                        </Link>
                    ))}
                </div>
            </motion.div>
        </div>
    );
}
