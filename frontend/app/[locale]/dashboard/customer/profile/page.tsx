'use client';

import { useState } from 'react';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { motion, AnimatePresence } from 'framer-motion';
import { Header } from '@/components/common/header';
import {
    Sparkles, History, Heart, Award, Settings, ShoppingBag,
    Crown, TrendingUp, ChevronRight, Camera, Edit2
} from 'lucide-react';

// Mock user data
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
    const [activeTab, setActiveTab] = useState('dna');
    const user = MOCK_USER;

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Header />

            <main className="container mx-auto px-6 py-32 lg:py-40">
                <div className="max-w-7xl mx-auto">
                    <div className="flex flex-col lg:flex-row gap-16 items-start">
                        {/* Sidebar - Identity Card */}
                        <aside className="w-full lg:w-96 sticky top-32">
                            <div className="bg-white dark:bg-zinc-900 rounded-[4rem] p-12 border border-stone-100 dark:border-white/5 shadow-2xl text-center transition-colors">
                                {/* Avatar */}
                                <div className="relative w-40 h-40 mx-auto mb-10">
                                    <div className="w-full h-full rounded-full bg-stone-100 dark:bg-white/5 overflow-hidden relative border-8 border-white dark:border-zinc-900 shadow-2xl">
                                        <Image
                                            src={user.avatar_url}
                                            alt="Profile"
                                            fill
                                            className="object-cover scale-110"
                                        />
                                    </div>
                                    <button className="absolute bottom-2 right-2 p-3 bg-luxury-black dark:bg-gold text-white rounded-full shadow-xl border-4 border-white dark:border-zinc-900 hover:scale-110 transition-transform">
                                        <Camera size={20} />
                                    </button>
                                </div>

                                {/* User Info */}
                                <div className="mb-12">
                                    <h1 className="text-3xl font-serif text-luxury-black dark:text-white mb-2 italic">
                                        {user.full_name}
                                    </h1>
                                    <div className="flex items-center justify-center gap-3">
                                        <Crown size={14} className="text-gold" />
                                        <span className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-500 italic">
                                            Premium Member
                                        </span>
                                    </div>
                                    <p className="text-[9px] text-stone-400 mt-2 tracking-widest uppercase">
                                        {user.email}
                                    </p>
                                    <div className="mt-4 flex justify-center">
                                        <span className="text-[8px] font-bold tracking-[.3em] uppercase px-4 py-1.5 rounded-full border bg-green-500/10 border-green-500/20 text-green-500">
                                            Active
                                        </span>
                                    </div>
                                </div>

                                {/* Navigation Tabs */}
                                <nav className="space-y-3">
                                    {[
                                        { id: 'dna', icon: Sparkles, label: 'Scent DNA' },
                                        { id: 'history', icon: History, label: 'Order History' },
                                        { id: 'favorites', icon: Heart, label: 'Favorites' },
                                        { id: 'rewards', icon: Award, label: 'Rewards' },
                                        { id: 'settings', icon: Settings, label: 'Settings' },
                                    ].map((item) => (
                                        <button
                                            key={item.id}
                                            onClick={() => setActiveTab(item.id)}
                                            className={`w-full flex items-center justify-between px-8 py-5 rounded-[2rem] text-[10px] font-bold tracking-[.2em] uppercase transition-all ${activeTab === item.id
                                                    ? 'bg-luxury-black dark:bg-gold text-white shadow-2xl translate-x-2'
                                                    : 'text-stone-400 hover:bg-stone-50 dark:hover:bg-white/5 hover:text-luxury-black dark:hover:text-white'
                                                }`}
                                        >
                                            <div className="flex items-center gap-5">
                                                <item.icon size={18} strokeWidth={activeTab === item.id ? 2 : 1.5} />
                                                {item.label}
                                            </div>
                                            {activeTab === item.id && <ChevronRight size={14} />}
                                        </button>
                                    ))}
                                </nav>

                                {/* Loyalty Points */}
                                <div className="mt-12 pt-10 border-t border-stone-100 dark:border-white/5">
                                    <div className="flex justify-between items-center px-4">
                                        <div className="text-left">
                                            <p className="text-[9px] font-bold text-stone-400 uppercase tracking-widest mb-1">
                                                Loyalty Points
                                            </p>
                                            <span className="text-2xl font-serif text-luxury-black dark:text-white">
                                                {user.loyalty_points.toLocaleString()}
                                            </span>
                                        </div>
                                        <div className="p-3 bg-gold/10 rounded-2xl">
                                            <TrendingUp size={24} className="text-gold" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        {/* Main Content Area */}
                        <div className="flex-1 w-full space-y-12">
                            <AnimatePresence mode="wait">
                                {/* Scent DNA Tab */}
                                {activeTab === 'dna' && (
                                    <motion.div
                                        key="dna"
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="space-y-12"
                                    >
                                        <div className="relative rounded-[4rem] overflow-hidden bg-luxury-black p-12 md:p-16 text-white shadow-2xl">
                                            <div className="absolute top-0 right-0 w-2/3 h-full bg-gold/10 blur-[150px] pointer-events-none" />

                                            <div className="relative z-10">
                                                <div className="flex justify-between items-start mb-16">
                                                    <div className="max-w-xl">
                                                        <div className="flex items-center gap-3 text-gold mb-6">
                                                            <Sparkles size={20} />
                                                            <span className="text-[10px] font-bold tracking-[.4em] uppercase italic">
                                                                AI-Generated Profile
                                                            </span>
                                                        </div>
                                                        <h2 className="text-5xl md:text-7xl font-serif tracking-tighter italic capitalize">
                                                            {user.scent_preferences.environment} <br />
                                                            <span className="font-light not-italic text-gold">
                                                                {user.scent_preferences.emotion}
                                                            </span>
                                                        </h2>
                                                    </div>
                                                    <div className="text-right">
                                                        <span className="text-6xl font-serif text-gold">98.4%</span>
                                                        <p className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-500 mt-2">
                                                            Match Score
                                                        </p>
                                                    </div>
                                                </div>

                                                <div className="grid grid-cols-1 md:grid-cols-3 gap-12 border-t border-white/10 pt-16">
                                                    <div>
                                                        <p className="text-[9px] font-bold tracking-widest uppercase text-stone-400 mb-2">
                                                            Preferred Families
                                                        </p>
                                                        <p className="text-sm font-medium">
                                                            {user.scent_preferences.families.join(', ')}
                                                        </p>
                                                    </div>
                                                    <div>
                                                        <p className="text-[9px] font-bold tracking-widest uppercase text-stone-400 mb-2">
                                                            Intensity
                                                        </p>
                                                        <p className="text-sm font-medium capitalize">
                                                            {user.scent_preferences.intensity}
                                                        </p>
                                                    </div>
                                                    <div>
                                                        <p className="text-[9px] font-bold tracking-widest uppercase text-stone-400 mb-2">
                                                            Top Notes
                                                        </p>
                                                        <p className="text-sm font-medium">
                                                            {user.scent_preferences.notes.slice(0, 2).join(', ')}
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <Link
                                            href="/customer/consultation"
                                            className="block p-12 rounded-[3.5rem] bg-stone-100 dark:bg-white/5 border border-stone-100 dark:border-white/5 flex items-center justify-between hover:border-gold transition-all"
                                        >
                                            <div className="flex items-center gap-8">
                                                <div className="w-14 h-14 rounded-2xl bg-white dark:bg-zinc-800 flex items-center justify-center text-gold shadow-sm">
                                                    <Sparkles size={24} />
                                                </div>
                                                <div>
                                                    <h4 className="text-lg font-serif text-luxury-black dark:text-white italic">
                                                        Refresh Your DNA
                                                    </h4>
                                                    <p className="text-[10px] text-stone-400 font-bold tracking-widest uppercase">
                                                        Retake consultation
                                                    </p>
                                                </div>
                                            </div>
                                            <ChevronRight className="text-stone-400" size={24} />
                                        </Link>
                                    </motion.div>
                                )}

                                {/* Order History Tab */}
                                {activeTab === 'history' && (
                                    <motion.div
                                        key="history"
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="space-y-8"
                                    >
                                        <h2 className="text-4xl font-serif text-luxury-black dark:text-white">
                                            Order History
                                        </h2>

                                        <div className="space-y-4">
                                            {MOCK_ORDERS.map((order) => (
                                                <div
                                                    key={order.id}
                                                    className="bg-white dark:bg-zinc-900 p-8 rounded-[3rem] border border-stone-100 dark:border-white/5 flex justify-between items-center group hover:border-gold transition-all"
                                                >
                                                    <div className="flex items-center gap-8">
                                                        <div className="w-20 h-20 rounded-3xl bg-stone-50 dark:bg-white/5 flex items-center justify-center border border-stone-100 dark:border-white/10">
                                                            <ShoppingBag size={24} className="text-stone-300" />
                                                        </div>
                                                        <div>
                                                            <h4 className="text-lg font-serif italic text-luxury-black dark:text-white mb-1 group-hover:text-gold transition-colors">
                                                                Order #{order.id.toUpperCase()}
                                                            </h4>
                                                            <p className="text-[9px] font-bold text-stone-400 uppercase tracking-widest">
                                                                {new Date(order.date).toLocaleDateString('vi-VN')} • {order.items} items
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div className="flex items-center gap-10">
                                                        <div className="text-right">
                                                            <p className="text-[9px] font-bold text-stone-400 uppercase tracking-widest mb-1">
                                                                Status
                                                            </p>
                                                            <span className="text-[10px] px-4 py-1.5 rounded-full font-bold uppercase tracking-widest bg-stone-50 dark:bg-white/10 text-luxury-black dark:text-white border border-stone-100 dark:border-white/5">
                                                                {order.status}
                                                            </span>
                                                        </div>
                                                        <div className="text-right min-w-[120px]">
                                                            <p className="text-[9px] font-bold text-stone-400 uppercase tracking-widest mb-1">
                                                                Total
                                                            </p>
                                                            <span className="text-xl font-serif text-luxury-black dark:text-white">
                                                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(order.amount)}
                                                            </span>
                                                        </div>
                                                        <ChevronRight className="text-stone-300 group-hover:text-gold group-hover:translate-x-2 transition-all" size={20} />
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </motion.div>
                                )}

                                {/* Settings Tab */}
                                {activeTab === 'settings' && (
                                    <motion.div
                                        key="settings"
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="space-y-12"
                                    >
                                        <h2 className="text-4xl font-serif text-luxury-black dark:text-white">
                                            Account <span className="italic">Settings</span>
                                        </h2>

                                        <div className="bg-white dark:bg-zinc-900 rounded-[4rem] p-12 md:p-16 border border-stone-100 dark:border-white/5 shadow-sm space-y-10">
                                            <div className="grid md:grid-cols-2 gap-10">
                                                <div className="space-y-4">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">
                                                        Full Name
                                                    </label>
                                                    <input
                                                        type="text"
                                                        defaultValue={user.full_name}
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl py-5 px-8 text-sm outline-none focus:border-gold transition-all text-luxury-black dark:text-white"
                                                    />
                                                </div>
                                                <div className="space-y-4">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">
                                                        Phone Number
                                                    </label>
                                                    <input
                                                        type="text"
                                                        defaultValue={user.phone}
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl py-5 px-8 text-sm outline-none focus:border-gold transition-all text-luxury-black dark:text-white"
                                                    />
                                                </div>
                                            </div>

                                            <div className="space-y-4">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">
                                                    Email Address
                                                </label>
                                                <div className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl py-5 px-8 text-sm text-stone-400 cursor-not-allowed">
                                                    {user.email}
                                                </div>
                                            </div>

                                            <button className="px-12 py-5 bg-luxury-black dark:bg-gold text-white rounded-full text-[10px] font-bold tracking-widest uppercase shadow-xl hover:bg-stone-800 dark:hover:bg-gold/80 transition-all">
                                                Save Changes
                                            </button>
                                        </div>
                                    </motion.div>
                                )}

                                {/* Other tabs with placeholder */}
                                {(activeTab === 'favorites' || activeTab === 'rewards') && (
                                    <motion.div
                                        key={activeTab}
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="p-24 text-center bg-white dark:bg-zinc-900 rounded-[4rem] border border-stone-100 dark:border-white/5"
                                    >
                                        <h2 className="text-3xl font-serif mb-4 italic text-stone-300">
                                            Coming Soon
                                        </h2>
                                        <p className="text-[10px] uppercase font-bold tracking-[.3em] text-stone-500">
                                            This feature is under development
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
