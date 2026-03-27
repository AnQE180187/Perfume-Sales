'use client';
 
import React from 'react';
import { motion } from 'framer-motion';
import { useTranslations } from 'next-intl';
import {
    Sparkles,
    TrendingUp,
    Award,
    Clock,
    Search,
    ArrowUpRight,
    Package,
    Receipt,
    Tag,
    Users,
    FolderTree
} from 'lucide-react';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { AuthGuard } from '@/components/auth/auth-guard';
 
export default function AdminDashboard() {
    const t = useTranslations('dashboard.admin.home');
 
    return (
        <AuthGuard allowedRoles={['admin']}>
            <div className="flex flex-col gap-10 py-10 px-8">
                {/* Header Section */}
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
                    <div>
                        <h1 className="text-4xl font-heading text-foreground mb-2 transition-colors uppercase tracking-tighter">
                            {t('title').split(' ')[0]} <span className="italic gold-gradient">{t('title').split(' ')[1]}</span>
                        </h1>
                        <p className="text-[10px] text-muted-foreground uppercase tracking-[.4em] font-bold">
                            {t('subtitle')}
                        </p>
                    </div>
                    <div className="flex items-center gap-4">
                        <div className="relative group">
                            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground/50 group-hover:text-gold transition-colors" size={16} />
                            <input
                                type="text"
                                placeholder={t('search_placeholder')}
                                className="glass bg-background/50 border border-border rounded-2xl py-3 pl-12 pr-6 text-xs outline-none focus:border-gold transition-all w-64 shadow-sm"
                            />
                        </div>
                    </div>
                </div>
 
                {/* Stats Grid */}
                <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
                    {[
                        { key: "revenue", value: "2.4B đ", icon: TrendingUp, color: "bg-emerald-500/10 text-emerald-600", delay: 0.1 },
                        { key: "consultations", value: "842", icon: Sparkles, color: "bg-gold/10 text-gold", delay: 0.2 },
                        { key: "members", value: "2.1k", icon: Award, color: "bg-blue-500/10 text-blue-600", delay: 0.3 },
                        { key: "delivery", value: "1.2d", icon: Clock, color: "bg-secondary text-muted-foreground", delay: 0.4 }
                    ].map((stat, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: stat.delay }}
                            className="glass bg-background/40 p-8 rounded-[2.5rem] border border-border shadow-sm hover:shadow-xl transition-all group"
                        >
                            <div className="flex justify-between items-start mb-6">
                                <div className={`p-4 rounded-2xl ${stat.color} group-hover:scale-110 transition-transform`}>
                                    <stat.icon size={24} strokeWidth={2} />
                                </div>
                                <div className="p-2 border border-border rounded-full text-muted-foreground hover:text-gold cursor-pointer transition-colors">
                                    <ArrowUpRight size={14} />
                                </div>
                            </div>
                            <h3 className="text-3xl font-heading mb-2 text-foreground transition-colors tracking-tighter">{stat.value}</h3>
                            <p className="text-[10px] text-muted-foreground tracking-[.2em] uppercase font-bold transition-colors">{t(`stats.${stat.key}`)}</p>
                        </motion.div>
                    ))}
                </section>
 
                {/* Management Consoles */}
                <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
                    {[
                        { key: "products", icon: Package, href: "/dashboard/admin/products" },
                        { key: "catalog", icon: FolderTree, href: "/dashboard/admin/catalog" },
                        { key: "orders", icon: Receipt, href: "/dashboard/admin/orders" },
                        { key: "discounts", icon: Tag, href: "/dashboard/admin/marketing/promotions" },
                        { key: "users", icon: Users, href: "/dashboard/admin/users" }
                    ].map((item, i) => (
                        <Link key={i} href={item.href}>
                            <div className="glass bg-background/40 px-6 py-5 rounded-3xl border border-border hover:border-gold/50 transition-all cursor-pointer group flex items-center gap-4 shadow-sm hover:shadow-lg">
                                <div className="w-12 h-12 rounded-2xl bg-secondary flex items-center justify-center text-muted-foreground group-hover:bg-gold group-hover:text-primary-foreground transition-all">
                                    <item.icon size={20} />
                                </div>
                                <div className="flex-1 min-w-0">
                                    <h4 className="text-[10px] font-bold uppercase tracking-widest text-foreground truncate">{t(`management.${item.key}`)}</h4>
                                    <p className="text-[8px] text-muted-foreground uppercase tracking-tighter font-bold mt-0.5 truncate">{t(`management.${item.key}_desc`)}</p>
                                </div>
                            </div>
                        </Link>
                    ))}
                </section>
 
                {/* Main Area */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
                    {/* Real-time Feed */}
                    <section className="lg:col-span-2 glass bg-background/40 rounded-[3rem] border border-border p-10 shadow-sm flex flex-col transition-colors">
                        <div className="flex justify-between items-center mb-10">
                            <div className="flex items-center gap-3">
                                <h2 className="text-2xl font-heading text-foreground transition-colors uppercase tracking-widest">{t('feed.title')}</h2>
                                <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                            </div>
                            <button className="text-[10px] font-bold text-gold tracking-widest uppercase hover:underline cursor-pointer">
                                {t('feed.cta')}
                            </button>
                        </div>
 
                        <div className="space-y-6">
                            {[
                                { client: "Elena Gilbert", goal: "Evening Signature", status: "Matching", match: "89%", time: "Just now" },
                                { client: "Marco V.", goal: "Fresh Aquatic", status: "Completed", match: "94%", time: "2m ago" },
                                { client: "Sophia R.", goal: "Warm Woody", status: "Processing", match: "72%", time: "5m ago" },
                                { client: "James T.", goal: "Oriental Mystique", status: "Completed", match: "91%", time: "12m ago" }
                            ].map((c, i) => (
                                <div key={i} className="flex items-center justify-between p-6 rounded-3xl border border-border hover:bg-white/[0.02] transition-all cursor-pointer group">
                                    <div className="flex items-center gap-6">
                                        <div className="relative w-14 h-14 rounded-2xl overflow-hidden border-2 border-border shadow-sm transition-all group-hover:scale-105">
                                            <Image src="/luxury_perfume_hero_cinematic.png" alt="Profile" fill className="object-cover opacity-50 grayscale group-hover:grayscale-0 group-hover:opacity-100 transition-all duration-700" />
                                        </div>
                                        <div>
                                            <h4 className="text-sm font-bold text-foreground transition-colors uppercase tracking-widest">{c.client}</h4>
                                            <p className="text-[10px] text-muted-foreground transition-colors uppercase tracking-widest">{c.goal}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-10">
                                        <div className="hidden md:block text-right">
                                            <span className={`text-[8px] px-3 py-1 rounded-full uppercase font-bold tracking-widest transition-all ${c.status === "Completed"
                                                ? "bg-emerald-500/10 text-emerald-500"
                                                : "bg-gold/10 text-gold"
                                                }`}>
                                                {c.status}
                                            </span>
                                            <p className="text-[8px] mt-1 text-muted-foreground font-bold uppercase tracking-widest">{c.time}</p>
                                        </div>
                                        <div className="w-24 text-right">
                                            <span className="font-heading gold-gradient text-xl transition-colors">{c.match}</span>
                                            <p className="text-[8px] text-gold font-bold uppercase tracking-widest">{t('feed.match_score')}</p>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </section>
 
                    {/* Intelligence Card */}
                    <section className="glass rounded-[3rem] p-10 bg-foreground text-background shadow-2xl relative overflow-hidden flex flex-col justify-between">
                        <div className="relative z-10">
                            <div className="flex items-center gap-3 mb-12">
                                <Sparkles size={24} className="text-gold" />
                                <h2 className="text-xl font-heading uppercase tracking-widest">{t('intelligence.title')}</h2>
                            </div>
 
                            <div className="space-y-10">
                                <div>
                                    <h4 className="text-[10px] uppercase tracking-[.3em] text-muted-foreground/60 mb-6">{t('intelligence.trending_notes')}</h4>
                                    <div className="flex flex-wrap gap-3">
                                        {["Ambroxan", "Saffron", "Rose Abs.", "Oud"].map(n => (
                                            <span key={n} className="px-4 py-2 rounded-xl border border-background/10 text-[10px] font-bold uppercase tracking-widest bg-background/5 hover:bg-gold hover:text-white transition-all cursor-pointer">
                                                {n}
                                            </span>
                                        ))}
                                    </div>
                                </div>
 
                                <div className="space-y-6">
                                    <h4 className="text-[10px] uppercase tracking-[.3em] text-muted-foreground/60">{t('intelligence.market_absorption')}</h4>
                                    <div className="space-y-6">
                                        <div className="space-y-3">
                                            <div className="flex justify-between text-[10px] font-bold uppercase tracking-[.2em]">
                                                <span>{t('intelligence.tier_platinum')}</span>
                                                <span className="text-gold">75%</span>
                                            </div>
                                            <div className="h-1 bg-background/10 rounded-full overflow-hidden">
                                                <motion.div
                                                    initial={{ width: 0 }}
                                                    animate={{ width: "75%" }}
                                                    transition={{ duration: 1.5, ease: "easeOut" }}
                                                    className="h-full bg-gold shadow-[0_0_10px_#C5A059]"
                                                />
                                            </div>
                                        </div>
                                        <div className="space-y-3">
                                            <div className="flex justify-between text-[10px] font-bold uppercase tracking-[.2em]">
                                                <span>{t('intelligence.tier_niche')}</span>
                                                <span className="text-gold">45%</span>
                                            </div>
                                            <div className="h-1 bg-background/10 rounded-full overflow-hidden">
                                                <motion.div
                                                    initial={{ width: 0 }}
                                                    animate={{ width: "45%" }}
                                                    transition={{ duration: 1.5, ease: "easeOut", delay: 0.3 }}
                                                    className="h-full bg-gold shadow-[0_0_10px_#C5A059]"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
 
                        <div className="relative z-10 pt-12">
                            <button className="w-full py-5 bg-background/5 hover:bg-gold hover:text-primary-foreground transition-all text-[10px] font-bold tracking-[.4em] uppercase rounded-[2rem] border border-background/10 shadow-lg cursor-pointer">
                                {t('intelligence.report_btn')}
                            </button>
                        </div>
 
                        {/* Gradient Effects */}
                        <div className="absolute top-0 right-0 w-48 h-48 bg-gold opacity-10 blur-[100px]" />
                        <div className="absolute bottom-0 left-0 w-48 h-48 bg-gold opacity-5 blur-[80px]" />
                    </section>
                </div>
            </div>
        </AuthGuard>
    );
}
