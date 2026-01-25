'use client';

import React from 'react';
import { motion } from 'framer-motion';
import {
    Bell,
    Package,
    Sparkles,
    AlertCircle,
    CheckCircle2,
    Trash2,
    ChevronRight,
    Circle
} from 'lucide-react';
import { Header } from '@/components/common/header';

const notifications = [
    {
        id: 1,
        type: "order",
        title: "Logistics Update",
        message: "Your acquisition LM-8420 has entered the molecular stabilization phase.",
        time: "14 mins ago",
        read: false,
        icon: Package,
        color: "text-blue-500",
        bg: "bg-blue-500/10"
    },
    {
        id: 2,
        type: "ai",
        title: "Neural Synthesis Complete",
        message: "The AI has finished processing your summer olfactory DNA. View your new recommendations.",
        time: "2 hours ago",
        read: false,
        icon: Sparkles,
        color: "text-gold",
        bg: "bg-gold/10"
    },
    {
        id: 3,
        type: "system",
        title: "Membership Privilege",
        message: "Your Platinum status has been renewed. Experience the new archival drops.",
        time: "1 day ago",
        read: true,
        icon: CheckCircle2,
        color: "text-emerald-500",
        bg: "bg-emerald-500/10"
    },
    {
        id: 4,
        type: "alert",
        title: "Stabilization Alert",
        message: "One of your items requires environmental restabilization before shipping. Delay: 24h.",
        time: "2 days ago",
        read: true,
        icon: AlertCircle,
        color: "text-amber-500",
        bg: "bg-amber-500/10"
    }
];

export default function NotificationsPage() {
    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Header />

            <main className="container mx-auto px-6 py-32 lg:py-40">
                <div className="max-w-4xl mx-auto">
                    <header className="flex justify-between items-end mb-16 px-4">
                        <div>
                            <h1 className="text-4xl md:text-5xl font-serif text-luxury-black dark:text-white mb-4">
                                Notifi<span className="italic">cations</span>
                            </h1>
                            <p className="text-[10px] text-stone-500 uppercase tracking-[.3em] font-bold">
                                Monitoring your neural frequencies.
                            </p>
                        </div>
                        <div className="flex gap-6">
                            <button className="text-[10px] font-bold uppercase tracking-widest text-stone-400 hover:text-gold transition-colors flex items-center gap-2 cursor-pointer">
                                Clear All <Trash2 size={14} />
                            </button>
                            <button className="text-[10px] font-bold uppercase tracking-widest text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors flex items-center gap-2 cursor-pointer">
                                Mark Read <CheckCircle2 size={14} />
                            </button>
                        </div>
                    </header>

                    <div className="flex flex-col gap-6">
                        {notifications.map((notif, i) => (
                            <motion.div
                                key={notif.id}
                                initial={{ opacity: 0, x: -20 }}
                                animate={{ opacity: 1, x: 0 }}
                                transition={{ delay: i * 0.1 }}
                                className={`group relative glass rounded-[2.5rem] p-8 border transition-all cursor-pointer ${notif.read
                                        ? 'bg-white/40 dark:bg-white/2 border-stone-100 dark:border-white/5 opacity-70'
                                        : 'bg-white dark:bg-zinc-900 border-stone-200 dark:border-white/10 shadow-sm hover:shadow-xl'
                                    }`}
                            >
                                {!notif.read && (
                                    <div className="absolute top-8 right-10">
                                        <Circle size={8} className="fill-gold text-gold animate-pulse" />
                                    </div>
                                )}

                                <div className="flex gap-8 items-start">
                                    <div className={`w-16 h-16 rounded-2xl flex items-center justify-center flex-shrink-0 transition-transform group-hover:scale-110 ${notif.bg}`}>
                                        <notif.icon className={notif.color} size={28} strokeWidth={1.5} />
                                    </div>
                                    <div className="flex-1 flex flex-col gap-2 pr-8">
                                        <div className="flex justify-between items-center">
                                            <h3 className={`text-lg font-bold transition-colors ${notif.read ? 'text-stone-600 dark:text-stone-400' : 'text-metropolis-black dark:text-white'}`}>
                                                {notif.title}
                                            </h3>
                                            <span className="text-[10px] font-bold text-stone-400 uppercase tracking-tighter">
                                                {notif.time}
                                            </span>
                                        </div>
                                        <p className={`text-sm leading-relaxed max-w-2xl transition-colors ${notif.read ? 'text-stone-400' : 'text-stone-600 dark:text-stone-300'}`}>
                                            {notif.message}
                                        </p>
                                        <div className="flex gap-6 mt-6 opacity-0 group-hover:opacity-100 transition-opacity">
                                            <button className="text-[10px] font-bold uppercase tracking-widest text-gold flex items-center gap-2 hover:underline underline-offset-4 cursor-pointer">
                                                View Essence <ChevronRight size={12} />
                                            </button>
                                            {!notif.read && (
                                                <button className="text-[10px] font-bold uppercase tracking-widest text-stone-400 flex items-center gap-2 hover:text-stone-600 dark:hover:text-stone-200 cursor-pointer">
                                                    Acknowledge
                                                </button>
                                            )}
                                        </div>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </div>

                    <footer className="mt-20 pt-10 border-t border-stone-100 dark:border-white/5 text-center">
                        <button className="text-[10px] font-bold uppercase tracking-widest text-stone-400 hover:text-gold transition-colors cursor-pointer">
                            Load archival frequencies
                        </button>
                    </footer>
                </div>
            </main>
        </div>
    );
}
