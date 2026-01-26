'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { useTranslations } from 'next-intl';
import {
    BarChart3, TrendingUp, Users, Package, BrainCircuit,
    ArrowUpRight, ArrowDownRight, Activity, Zap
} from 'lucide-react';
import { motion } from 'framer-motion';

export default function AnalyticsPage() {
    const navT = useTranslations('navigation');

    const stats = [
        { label: 'Total Revenue', value: '$84,230', change: '+12.5%', icon: TrendingUp, color: 'text-green-500' },
        { label: 'Active Users', value: '4,284', change: '+8.2%', icon: Users, color: 'text-gold' },
        { label: 'AI Acceptance', value: '94.2%', change: '-2.1%', icon: BrainCircuit, color: 'text-ai' },
        { label: 'Inventory Health', value: '88%', change: '+0.5%', icon: Package, color: 'text-zinc-500' },
    ];

    return (
        <AuthGuard allowedRoles={['admin']}>
            <main className="p-8 pb-20">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient uppercase tracking-tighter">{navT('admin.analytics')}</h1>
                    <p className="text-muted-foreground font-body text-xs uppercase tracking-[0.3em] mt-2">Neural Ecosystem Telemetry</p>
                </header>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
                    {stats.map((stat, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.1 }}
                            className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group"
                        >
                            <div className="flex justify-between items-start mb-6">
                                <div className={`p-4 rounded-2xl bg-secondary/50 ${stat.color} group-hover:scale-110 transition-transform`}>
                                    <stat.icon className="w-6 h-6" />
                                </div>
                                <div className={cn(
                                    "flex items-center gap-1 text-[9px] font-heading px-3 py-1.5 rounded-full glass border-border",
                                    stat.change.startsWith('+') ? "text-green-500" : "text-red-500"
                                )}>
                                    {stat.change.startsWith('+') ? <ArrowUpRight className="w-3 h-3" /> : <ArrowDownRight className="w-3 h-3" />}
                                    {stat.change}
                                </div>
                            </div>
                            <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading mb-2">{stat.label}</h3>
                            <p className="text-3xl font-heading text-foreground">{stat.value}</p>
                        </motion.div>
                    ))}
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div className="lg:col-span-2 glass p-10 rounded-[3rem] border-border relative overflow-hidden group">
                        <h3 className="text-lg font-heading mb-12 uppercase tracking-[0.2em] flex items-center gap-3">
                            <BarChart3 className="w-5 h-5 text-gold" />
                            Performance Metrics
                        </h3>
                        <div className="h-[300px] w-full border-b border-l border-border relative flex items-end justify-between px-8">
                            {[60, 45, 75, 50, 90, 65, 80, 55, 70, 40, 85, 95].map((h, i) => (
                                <motion.div
                                    key={i}
                                    initial={{ height: 0 }}
                                    animate={{ height: `${h}%` }}
                                    transition={{ duration: 1.5, delay: i * 0.05, ease: "circOut" }}
                                    className="w-8 sm:w-10 group/bar relative"
                                >
                                    <div className="h-full w-full bg-gradient-to-t from-gold/40 to-gold rounded-t-xl group-hover/bar:brightness-125 transition-all" />
                                </motion.div>
                            ))}
                        </div>
                    </div>

                    <div className="glass p-10 rounded-[3rem] border-border">
                        <h3 className="text-lg font-heading mb-8 uppercase tracking-[0.2em]">Live Feed</h3>
                        <div className="space-y-6">
                            {[1, 2, 3, 4].map(i => (
                                <div key={i} className="flex gap-4 items-start pb-6 border-b border-border last:border-0">
                                    <div className="w-10 h-10 rounded-xl bg-secondary flex items-center justify-center shrink-0 border border-border">
                                        <BrainCircuit className="w-4 h-4 text-gold" />
                                    </div>
                                    <div>
                                        <p className="text-[11px] font-body text-foreground leading-relaxed">
                                            <span className="text-gold font-heading uppercase mr-1">EVENT:</span>
                                            User #4932 sync complete
                                        </p>
                                        <p className="text-[9px] text-muted-foreground mt-1 uppercase tracking-widest font-heading">Active Now</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </main>
        </AuthGuard>
    );
}

function cn(...classes: any[]) {
    return classes.filter(Boolean).join(' ');
}
