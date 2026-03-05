'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { Tag, Zap, Timer, Sparkles, Copy, CheckCircle2 } from 'lucide-react';
import { useEffect, useState } from 'react';
import { promotionService } from '@/services/promotion.service';
import { motion, AnimatePresence } from 'framer-motion';

export default function CustomerPromotions() {
    const [promos, setPromos] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [copiedCode, setCopiedCode] = useState<string | null>(null);

    useEffect(() => {
        promotionService.getActive()
            .then(setPromos)
            .finally(() => setLoading(false));
    }, []);

    const copyToClipboard = (code: string) => {
        navigator.clipboard.writeText(code);
        setCopiedCode(code);
        setTimeout(() => setCopiedCode(null), 2000);
    };

    const formatTimeRemaining = (endDate: string) => {
        const remaining = new Date(endDate).getTime() - new Date().getTime();
        if (remaining <= 0) return 'Expired';

        const hours = Math.floor(remaining / (1000 * 60 * 60));
        const minutes = Math.floor((remaining % (1000 * 60 * 60)) / (1000 * 60));
        return `${hours}h ${minutes}m left`;
    };

    return (
        <AuthGuard allowedRoles={['customer']}>
            <main className="p-8 max-w-7xl mx-auto">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Olfactory Incentives</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Exclusive mathematical benefits for your next discovery.</p>
                </header>

                {loading ? (
                    <div className="py-20 flex justify-center">
                        <div className="w-8 h-8 border-2 border-gold border-t-transparent rounded-full animate-spin" />
                    </div>
                ) : promos.length > 0 ? (
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                        {promos.map((promo, i) => (
                            <motion.div
                                key={promo.id}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: i * 0.1 }}
                                className="glass p-1 bg-gradient-to-br from-gold/20 via-transparent to-gold/5 rounded-[2.5rem] group"
                            >
                                <div className="bg-background/40 backdrop-blur-3xl p-8 rounded-[2.4rem] h-full flex flex-col relative overflow-hidden">
                                    <div className="flex justify-between items-start mb-6">
                                        <div className="w-14 h-14 glass rounded-2xl border-gold/20 flex items-center justify-center">
                                            <Tag className="text-gold w-6 h-6" />
                                        </div>
                                        <div className="text-right">
                                            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-gold/10 border border-gold/20 text-gold text-[8px] uppercase tracking-widest font-bold">
                                                <Timer className="w-3 h-3" />
                                                {formatTimeRemaining(promo.endDate)}
                                            </div>
                                        </div>
                                    </div>

                                    <h2 className="text-2xl font-heading text-foreground uppercase tracking-wider mb-2">{promo.code}</h2>
                                    <p className="text-sm text-muted-foreground font-body leading-relaxed mb-6 flex-1">
                                        {promo.description || `Get ${promo.discountType === 'PERCENTAGE' ? `${promo.discountValue}%` : `${new Intl.NumberFormat('vi-VN').format(promo.discountValue)} VND`} off your next order.`}
                                    </p>

                                    <div className="flex items-center justify-between pt-6 border-t border-border/50">
                                        <div className="space-y-1">
                                            <p className="text-[10px] text-muted-foreground uppercase tracking-widest">Benefit</p>
                                            <p className="text-lg font-heading text-gold">
                                                {promo.discountType === 'PERCENTAGE' ? `${promo.discountValue}% OFF` : `-${new Intl.NumberFormat('vi-VN').format(promo.discountValue)} VND`}
                                            </p>
                                        </div>
                                        <button
                                            onClick={() => copyToClipboard(promo.code)}
                                            className="h-12 px-6 rounded-2xl glass border-gold/20 text-gold font-heading text-[10px] uppercase tracking-widest font-bold hover:bg-gold/5 transition-all flex items-center gap-3 active:scale-95"
                                        >
                                            {copiedCode === promo.code ? (
                                                <>
                                                    <CheckCircle2 size={14} className="animate-in zoom-in" />
                                                    Copied
                                                </>
                                            ) : (
                                                <>
                                                    <Copy size={14} />
                                                    Copy Code
                                                </>
                                            )}
                                        </button>
                                    </div>

                                    {/* Decor */}
                                    <div className="absolute top-[-10%] right-[-10%] w-[40%] h-[40%] bg-gold/5 rounded-full blur-3xl pointer-events-none group-hover:bg-gold/10 transition-colors" />
                                </div>
                            </motion.div>
                        ))}
                    </div>
                ) : (
                    <div className="glass p-20 rounded-[3rem] text-center">
                        <Sparkles className="w-12 h-12 text-gold/20 mx-auto mb-6" />
                        <h2 className="text-xl font-heading text-muted-foreground uppercase tracking-widest">No Active Synthesis</h2>
                        <p className="text-sm text-muted-foreground font-body mt-2">Check back later for exclusive AI-predicted opportunities.</p>
                    </div>
                )}

                {/* Fixed Referral Card */}
                <div className="mt-12 glass p-10 rounded-[3rem] border-gold/10 bg-gradient-to-r from-background to-secondary/20 flex flex-col md:flex-row items-center gap-8">
                    <div className="p-6 rounded-[2rem] bg-gold flex items-center justify-center shadow-xl shadow-gold/20">
                        <Zap className="text-primary-foreground w-8 h-8" />
                    </div>
                    <div className="flex-1 text-center md:text-left">
                        <h3 className="text-xl font-heading uppercase tracking-widest mb-2">Artisan Referral Program</h3>
                        <p className="text-sm text-muted-foreground font-body">Share the Aura experience with a fellow connoisseur and unlock a 10ml rare decant once they complete their first synthesis.</p>
                    </div>
                    <button className="bg-foreground text-background px-8 py-4 rounded-full font-heading text-[10px] uppercase tracking-widest font-bold hover:scale-105 transition-all">
                        Invite Friends
                    </button>
                </div>
            </main>
        </AuthGuard>
    );
}
