"use client";

import React from "react";
import { motion } from "framer-motion";
import {
    Bell,
    Package,
    Sparkles,
    AlertCircle,
    CheckCircle2,
    Trash2,
    Eye,
    ChevronRight,
    Circle
} from "lucide-react";
import { useTranslations } from "next-intl";

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
        color: "text-accent",
        bg: "bg-accent/10"
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
    const t = useTranslations("CustomerNotifications");

    return (
        <div className="max-w-4xl mx-auto px-6 py-12">
            <header className="flex justify-between items-end mb-12">
                <div>
                    <h1 className="text-4xl font-serif font-bold text-luxury-black dark:text-white mb-2">{t("title")}</h1>
                    <p className="text-sm text-stone-500 uppercase tracking-widest font-medium">Monitoring your neural frequencies.</p>
                </div>
                <div className="flex gap-4">
                    <button className="text-[10px] font-bold uppercase tracking-widest text-stone-400 hover:text-accent transition-colors flex items-center gap-2">
                        {t("clearAll")} <Trash2 size={14} />
                    </button>
                    <button className="text-[10px] font-bold uppercase tracking-widest text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors flex items-center gap-2">
                        {t("markAsRead")} <CheckCircle2 size={14} />
                    </button>
                </div>
            </header>

            <div className="flex flex-col gap-4">
                {notifications.length > 0 ? (
                    notifications.map((notif, i) => (
                        <motion.div
                            key={notif.id}
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: i * 0.1 }}
                            className={`group relative glass rounded-[2rem] p-6 border transition-all cursor-pointer ${notif.read
                                    ? 'bg-white/40 dark:bg-white/2 border-stone-100 dark:border-white/5 opacity-70'
                                    : 'bg-white dark:bg-zinc-900 border-stone-200 dark:border-white/10 shadow-sm hover:shadow-md'
                                }`}
                        >
                            {!notif.read && (
                                <div className="absolute top-6 right-8">
                                    <Circle size={8} className="fill-accent text-accent animate-pulse" />
                                </div>
                            )}

                            <div className="flex gap-6 items-start">
                                <div className={`w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0 transition-transform group-hover:scale-110 ${notif.bg}`}>
                                    <notif.icon className={notif.color} size={24} strokeWidth={1.5} />
                                </div>
                                <div className="flex-1 flex flex-col gap-1 pr-6">
                                    <div className="flex justify-between items-start">
                                        <h3 className={`text-base font-bold transition-colors ${notif.read ? 'text-stone-600 dark:text-stone-400' : 'text-luxury-black dark:text-white'}`}>
                                            {notif.title}
                                        </h3>
                                        <span className="text-[10px] font-bold text-stone-400 uppercase tracking-tighter whitespace-nowrap">
                                            {notif.time}
                                        </span>
                                    </div>
                                    <p className={`text-sm leading-relaxed max-w-xl transition-colors ${notif.read ? 'text-stone-500' : 'text-stone-600 dark:text-stone-300'}`}>
                                        {notif.message}
                                    </p>
                                    <div className="flex gap-4 mt-4 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button className="text-[10px] font-bold uppercase tracking-widest text-accent flex items-center gap-1 hover:underline underline-offset-4">
                                            View Essence <ChevronRight size={12} />
                                        </button>
                                        {!notif.read && (
                                            <button className="text-[10px] font-bold uppercase tracking-widest text-stone-400 flex items-center gap-1 hover:text-stone-600 dark:hover:text-stone-200">
                                                Acknowledge
                                            </button>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </motion.div>
                    ))
                ) : (
                    <div className="flex flex-col items-center justify-center py-24 text-center">
                        <div className="w-20 h-20 rounded-full bg-stone-50 dark:bg-white/5 flex items-center justify-center mb-6 border border-stone-100 dark:border-white/5">
                            <Bell size={32} className="text-stone-300 dark:text-stone-700" strokeWidth={1} />
                        </div>
                        <h3 className="text-xl font-serif font-bold text-stone-400 dark:text-stone-600">{t("empty")}</h3>
                        <p className="text-sm text-stone-500 mt-2 max-w-xs uppercase tracking-widest font-medium">All neural pathways are currently silent.</p>
                    </div>
                )}
            </div>

            <footer className="mt-16 pt-8 border-t border-stone-100 dark:border-white/5 text-center">
                <button className="text-[10px] font-bold uppercase tracking-widest text-stone-400 hover:text-accent transition-colors">
                    Load archival frequencies
                </button>
            </footer>
        </div>
    );
}
