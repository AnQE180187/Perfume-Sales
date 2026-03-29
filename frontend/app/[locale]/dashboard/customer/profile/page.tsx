'use client';

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { motion, AnimatePresence } from 'framer-motion';
import { Header } from '@/components/common/header';
import {
    Sparkles, History, Heart, Award, Settings, ShoppingBag,
    Crown, TrendingUp, ChevronRight, Camera, X, CheckCircle2
} from 'lucide-react';

// Mock user data (Should come from Auth Context)
const MOCK_USER = {
    id: '1',
    email: 'alexander@auraai.com',
    full_name: 'Alexander Dupont',
    phone: '+84 912 345 678',
    avatar_url: '/luxury_perfume_hero_cinematic.png',
    role: 'CUSTOMER',
    account_status: 'active',
    loyalty_points: 2450,
    scent_preferences: {
        families: ['Floral', 'Woody'],
        notes: ['Rose', 'Sandalwood', 'Vanilla'],
        intensity: 'moderate',
        emotion: 'Balanced',
        environment: 'Elegant'
    }
};

const MOCK_ORDERS = [
    { id: '1', date: '2026-01-20', status: 'delivered', amount: 5900000, items: 2 },
    { id: '2', date: '2026-01-15', status: 'processing', amount: 8500000, items: 1 },
];

export default function ProfilePage() {
    const t = useTranslations('dashboard.profile');
    const [activeTab, setActiveTab] = useState('dna');
    const user = MOCK_USER;

    return (
        <div className="min-h-screen bg-background text-foreground transition-colors selection:bg-gold/30">
            <Header />

            <main className="container mx-auto px-6 py-32 lg:py-48">
                <div className="max-w-7xl mx-auto">
                    <div className="flex flex-col lg:flex-row gap-20 items-start">
                        {/* Sidebar - Identity Card */}
                        <aside className="w-full lg:w-[400px] sticky top-32">
                            <div className="glass rounded-[4rem] p-12 border-border shadow-2xl text-center relative overflow-hidden group">
                                <div className="absolute top-0 right-0 w-32 h-32 bg-gold/5 blur-[60px] pointer-events-none" />
                                
                                {/* Avatar */}
                                <div className="relative w-44 h-44 mx-auto mb-12">
                                    <div className="w-full h-full rounded-full bg-secondary overflow-hidden relative border-8 border-background shadow-2xl transition-transform group-hover:scale-105 duration-700">
                                        <Image
                                            src={user.avatar_url}
                                            alt="Profile"
                                            fill
                                            className="object-cover scale-110"
                                        />
                                    </div>
                                    <button className="absolute bottom-3 right-3 p-4 bg-foreground dark:bg-gold text-background dark:text-foreground rounded-full shadow-2xl border-4 border-background hover:scale-110 active:scale-95 transition-all">
                                        <Camera size={22} />
                                    </button>
                                </div>

                                {/* User Info */}
                                <div className="mb-14">
                                    <h1 className="text-4xl font-heading gold-gradient mb-3 uppercase tracking-tighter italic">
                                        {user.full_name}
                                    </h1>
                                    <div className="flex items-center justify-center gap-3 text-gold mb-4">
                                        <Crown size={14} />
                                        <span className="text-[10px] font-bold tracking-[.4em] uppercase italic">
                                            {t('premium_member')}
                                        </span>
                                    </div>
                                    <p className="text-[9px] text-muted-foreground tracking-[.2em] font-mono opacity-60">
                                        {user.email}
                                    </p>
                                    <div className="mt-6 flex justify-center">
                                        <span className="text-[8px] font-bold tracking-[.3em] uppercase px-5 py-2 rounded-full border bg-emerald-500/10 border-emerald-500/20 text-emerald-500">
                                            {t('active')}
                                        </span>
                                    </div>
                                </div>

                                {/* Navigation Tabs */}
                                <nav className="space-y-4">
                                    {[
                                        { id: 'dna', icon: Sparkles, label: t('tabs.dna') },
                                        { id: 'history', icon: History, label: t('tabs.history') },
                                        { id: 'favorites', icon: Heart, label: t('tabs.favorites') },
                                        { id: 'rewards', icon: Award, label: t('tabs.rewards') },
                                        { id: 'settings', icon: Settings, label: t('tabs.settings') },
                                    ].map((item) => (
                                        <button
                                            key={item.id}
                                            onClick={() => setActiveTab(item.id)}
                                            className={`w-full flex items-center justify-between px-10 py-6 rounded-[2.2rem] text-[10px] font-bold tracking-[.3em] uppercase transition-all duration-500 relative overflow-hidden group/btn ${activeTab === item.id
                                                    ? 'bg-foreground dark:bg-gold text-background dark:text-foreground shadow-2xl translate-x-2'
                                                    : 'text-muted-foreground hover:bg-white/5 hover:text-foreground'
                                                }`}
                                        >
                                            <div className="flex items-center gap-6 relative z-10">
                                                <item.icon size={20} strokeWidth={activeTab === item.id ? 2.5 : 1.5} className={activeTab === item.id ? '' : 'text-gold/50 group-hover/btn:text-gold transition-colors'} />
                                                {item.label}
                                            </div>
                                            {activeTab === item.id && <ChevronRight size={16} className="relative z-10" />}
                                        </button>
                                    ))}
                                </nav>

                                {/* Loyalty Points */}
                                <div className="mt-14 pt-12 border-t border-white/5">
                                    <div className="flex justify-between items-center px-4">
                                        <div className="text-left">
                                            <p className="text-[9px] font-bold text-muted-foreground uppercase tracking-[.3em] mb-2">
                                                {t('loyalty_points')}
                                            </p>
                                            <span className="text-3xl font-serif text-foreground gold-gradient">
                                                {user.loyalty_points.toLocaleString()}
                                            </span>
                                        </div>
                                        <div className="w-16 h-16 glass rounded-[1.5rem] flex items-center justify-center text-gold shadow-xl rotate-12 group-hover:rotate-0 transition-transform duration-700">
                                            <TrendingUp size={28} />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        {/* Main Content Area */}
                        <div className="flex-1 w-full space-y-16">
                            <AnimatePresence mode="wait">
                                {/* Scent DNA Tab */}
                                {activeTab === 'dna' && (
                                    <motion.div
                                        key="dna"
                                        initial={{ opacity: 0, x: 30 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -30 }}
                                        className="space-y-16"
                                    >
                                        <div className="relative rounded-[5rem] overflow-hidden bg-foreground dark:bg-ebony p-16 md:p-24 text-background dark:text-white shadow-[0_50px_100px_-20px_rgba(0,0,0,0.5)] border border-white/5">
                                            <div className="absolute top-0 right-0 w-2/3 h-full bg-gold/10 blur-[180px] pointer-events-none animate-pulse" />

                                            <div className="relative z-10">
                                                <div className="flex flex-col md:flex-row justify-between items-start gap-12 mb-20">
                                                    <div className="max-w-2xl">
                                                        <div className="flex items-center gap-4 text-gold mb-8">
                                                            <Sparkles size={24} />
                                                            <span className="text-[11px] font-bold tracking-[.5em] uppercase italic">
                                                                {t('ai_profile_badge')}
                                                            </span>
                                                        </div>
                                                        <h2 className="text-6xl md:text-8xl font-heading tracking-tighter italic capitalize leading-[0.9]">
                                                            {user.scent_preferences.environment} <br />
                                                            <span className="font-light not-italic text-gold italic">
                                                                {user.scent_preferences.emotion}
                                                            </span>
                                                        </h2>
                                                    </div>
                                                    <div className="text-right md:pt-4">
                                                        <span className="text-7xl md:text-8xl font-serif text-gold leading-none italic">98.4%</span>
                                                        <p className="text-[11px] font-bold tracking-[.4em] uppercase text-gold/50 mt-4">
                                                            {t('match_score')}
                                                        </p>
                                                    </div>
                                                </div>

                                                <div className="grid grid-cols-1 md:grid-cols-3 gap-16 border-t border-white/10 pt-20">
                                                    <div className="space-y-4">
                                                        <p className="text-[10px] font-bold tracking-[.4em] uppercase text-gold/40">
                                                            {t('preferred_families')}
                                                        </p>
                                                        <p className="text-lg font-heading uppercase tracking-widest text-foreground dark:text-white">
                                                            {user.scent_preferences.families.join(' • ')}
                                                        </p>
                                                    </div>
                                                    <div className="space-y-4">
                                                        <p className="text-[10px] font-bold tracking-[.4em] uppercase text-gold/40">
                                                            {t('intensity')}
                                                        </p>
                                                        <p className="text-lg font-heading uppercase tracking-widest text-foreground dark:text-white capitalize">
                                                            {user.scent_preferences.intensity}
                                                        </p>
                                                    </div>
                                                    <div className="space-y-4">
                                                        <p className="text-[10px] font-bold tracking-[.4em] uppercase text-gold/40">
                                                            {t('top_notes')}
                                                        </p>
                                                        <p className="text-lg font-heading uppercase tracking-widest text-foreground dark:text-white italic">
                                                            {user.scent_preferences.notes.slice(0, 2).join(' / ')}
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <Link
                                            href="/customer/consultation"
                                            className="block p-16 rounded-[4rem] glass border-gold/10 flex flex-col md:flex-row items-center justify-between hover:border-gold/30 hover:bg-gold/5 transition-all group/cta relative overflow-hidden"
                                        >
                                            <div className="absolute inset-0 bg-gradient-to-r from-gold/5 via-transparent to-transparent opacity-0 group-hover/cta:opacity-100 transition-opacity" />
                                            <div className="flex items-center gap-10 relative z-10 text-center md:text-left">
                                                <div className="w-20 h-20 rounded-3xl bg-background dark:bg-ebony border border-gold/20 flex items-center justify-center text-gold shadow-2xl group-hover/cta:scale-110 transition-transform duration-700">
                                                    <Sparkles size={32} />
                                                </div>
                                                <div>
                                                    <h4 className="text-2xl font-serif text-foreground italic mb-2">
                                                        {t('refresh_dna')}
                                                    </h4>
                                                    <p className="text-[10px] text-muted-foreground font-bold tracking-[.3em] uppercase opacity-60">
                                                        {t('retake_consultation')}
                                                    </p>
                                                </div>
                                            </div>
                                            <div className="mt-8 md:mt-0 relative z-10 w-14 h-14 glass rounded-full flex items-center justify-center text-gold group-hover/cta:translate-x-4 transition-transform duration-700">
                                                <ChevronRight size={28} />
                                            </div>
                                        </Link>
                                    </motion.div>
                                )}

                                {/* Order History Tab */}
                                {activeTab === 'history' && (
                                    <motion.div
                                        key="history"
                                        initial={{ opacity: 0, x: 30 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -30 }}
                                        className="space-y-10"
                                    >
                                        <h2 className="text-5xl font-heading gold-gradient uppercase tracking-tighter italic mb-12">
                                            {t('tabs.history')}
                                        </h2>

                                        <div className="space-y-6">
                                            {MOCK_ORDERS.map((order, i) => (
                                                <motion.div
                                                    key={order.id}
                                                    initial={{ opacity: 0, y: 20 }}
                                                    animate={{ opacity: 1, y: 0 }}
                                                    transition={{ delay: i * 0.1 }}
                                                    className="glass p-10 rounded-[3.5rem] border-border flex flex-col md:flex-row justify-between items-center gap-10 group hover:border-gold/30 transition-all shadow-xl hover:shadow-gold/5"
                                                >
                                                    <div className="flex items-center gap-10 w-full md:w-auto">
                                                        <div className="w-24 h-24 rounded-[2rem] bg-secondary flex items-center justify-center border border-border group-hover:bg-gold/5 transition-colors">
                                                            <ShoppingBag size={32} className="text-gold/20 group-hover:text-gold transition-colors duration-700" />
                                                        </div>
                                                        <div>
                                                            <div className="flex items-center gap-3 mb-2">
                                                                <span className="text-[10px] font-bold text-gold uppercase tracking-widest italic font-mono opacity-50">#{order.id.padStart(4, '0')}</span>
                                                            </div>
                                                            <h4 className="text-2xl font-serif italic text-foreground group-hover:text-gold transition-colors duration-500">
                                                                Neural Signature Acquisition
                                                            </h4>
                                                            <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-[.3em] mt-2">
                                                                {new Date(order.date).toLocaleDateString(undefined, { day: '2-digit', month: 'long', year: 'numeric' })} • {order.items} Items
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div className="flex items-center justify-between md:justify-end gap-16 w-full md:w-auto pt-8 md:pt-0 border-t md:border-t-0 border-white/5">
                                                        <div className="text-center md:text-right">
                                                            <p className="text-[9px] font-bold text-muted-foreground uppercase tracking-[.3em] mb-3">
                                                                Status
                                                            </p>
                                                            <span className="text-[10px] px-6 py-2.5 rounded-full font-bold uppercase tracking-[.2em] bg-emerald-500/10 text-emerald-500 border border-emerald-500/20 shadow-lg shadow-emerald-500/5">
                                                                {order.status}
                                                            </span>
                                                        </div>
                                                        <div className="text-center md:text-right min-w-[160px]">
                                                            <p className="text-[9px] font-bold text-muted-foreground uppercase tracking-[.3em] mb-3">
                                                                Valuation
                                                            </p>
                                                            <span className="text-3xl font-serif text-foreground gold-gradient">
                                                                {new Intl.NumberFormat(undefined, { style: 'currency', currency: 'VND' }).format(order.amount)}
                                                            </span>
                                                        </div>
                                                        <div className="hidden md:flex w-12 h-12 glass rounded-full items-center justify-center text-gold group-hover:translate-x-2 transition-transform">
                                                            <ChevronRight size={20} />
                                                        </div>
                                                    </div>
                                                </motion.div>
                                            ))}
                                        </div>
                                    </motion.div>
                                )}

                                {/* Settings Tab */}
                                {activeTab === 'settings' && (
                                    <motion.div
                                        key="settings"
                                        initial={{ opacity: 0, x: 30 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -30 }}
                                        className="space-y-16"
                                    >
                                        <h2 className="text-5xl font-heading gold-gradient uppercase tracking-tighter italic mb-12">
                                            {t('account_settings')}
                                        </h2>

                                        <div className="glass rounded-[5rem] p-16 md:p-24 border-border shadow-2xl space-y-12 relative overflow-hidden bg-background/30">
                                            <div className="absolute bottom-0 left-0 w-64 h-64 bg-gold/5 blur-[120px] pointer-events-none" />
                                            
                                            <div className="grid md:grid-cols-2 gap-12">
                                                <div className="space-y-6">
                                                    <label className="text-[11px] font-bold tracking-[.4em] uppercase text-gold/60 ml-2">
                                                        {t('full_name')}
                                                    </label>
                                                    <input
                                                        type="text"
                                                        defaultValue={user.full_name}
                                                        className="w-full h-20 bg-white/5 border border-white/5 rounded-[2rem] px-10 text-sm font-bold tracking-widest outline-none focus:border-gold/50 transition-all"
                                                    />
                                                </div>
                                                <div className="space-y-6">
                                                    <label className="text-[11px] font-bold tracking-[.4em] uppercase text-gold/60 ml-2">
                                                        {t('phone_number')}
                                                    </label>
                                                    <input
                                                        type="text"
                                                        defaultValue={user.phone}
                                                        className="w-full h-20 bg-white/5 border border-white/5 rounded-[2rem] px-10 text-sm font-bold tracking-widest outline-none focus:border-gold/50 transition-all"
                                                    />
                                                </div>
                                            </div>

                                            <div className="space-y-6">
                                                <label className="text-[11px] font-bold tracking-[.4em] uppercase text-gold/60 ml-2">
                                                    Olfactory Destination (Email)
                                                </label>
                                                <div className="w-full h-20 glass border-white/5 rounded-[2rem] px-10 flex items-center text-sm font-mono text-muted-foreground opacity-50 cursor-not-allowed">
                                                    {user.email}
                                                </div>
                                            </div>

                                            <button className="h-20 px-16 bg-gold text-black rounded-full text-[11px] font-bold tracking-[.4em] uppercase shadow-2xl shadow-gold/20 hover:scale-105 active:scale-95 transition-all">
                                                {t('save_changes')}
                                            </button>
                                        </div>
                                    </motion.div>
                                )}

                                {/* Placeholder for Empty Tabs */}
                                {(activeTab === 'favorites' || activeTab === 'rewards') && (
                                    <motion.div
                                        key={activeTab}
                                        initial={{ opacity: 0, scale: 0.9 }}
                                        animate={{ opacity: 1, scale: 1 }}
                                        exit={{ opacity: 0, scale: 0.9 }}
                                        className="py-48 text-center glass rounded-[5rem] border-gold/10 relative overflow-hidden flex flex-col items-center"
                                    >
                                        <div className="absolute inset-0 bg-gradient-to-b from-gold/5 to-transparent pointer-events-none" />
                                        <div className="w-32 h-32 rounded-[3.5rem] glass border-gold/10 flex items-center justify-center text-gold/20 mb-12">
                                            {activeTab === 'favorites' ? <Heart size={48} /> : <Award size={48} />}
                                        </div>
                                        <h2 className="text-4xl font-heading gold-gradient uppercase tracking-tighter italic mb-4">
                                            {t('coming_soon')}
                                        </h2>
                                        <p className="text-[11px] uppercase font-bold tracking-[.4em] text-muted-foreground opacity-60">
                                            {t('under_development')}
                                        </p>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
