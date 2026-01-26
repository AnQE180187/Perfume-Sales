'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { Trophy } from 'lucide-react';
export default function RewardsPage() {
    return (
        <div className="p-8 lg:p-12 overflow-x-hidden">
            <main>
                <div className="max-w-4xl mx-auto text-center mb-20">
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-5xl md:text-6xl font-serif text-luxury-black dark:text-white mb-6"
                    >
                        Aura <span className="italic">Tiers</span>
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-stone-500 dark:text-stone-400 text-lg font-light max-w-2xl mx-auto"
                    >
                        The more you explore, the deeper your connection to the House becomes.
                    </motion.p>
                </div>

                <div className="grid md:grid-cols-2 gap-12 max-w-6xl mx-auto">
                    {[
                        {
                            tier: "Silver Mist",
                            req: "100 Aura Points",
                            perk: "Access to Seasonal Releases • Priority Shipping"
                        },
                        {
                            tier: "Golden Sillage",
                            req: "500 Aura Points",
                            perk: "Bespoke AI Retraining • Exclusive Archival Previews"
                        },
                        {
                            tier: "Platinum Essence",
                            req: "1000 Aura Points",
                            perk: "Invitations to Grasse Guest House • Unlimited Consultations"
                        },
                        {
                            tier: "Obsidian Absolute",
                            req: "Invitation Only",
                            perk: "Private Extraction Commission • Lifetime Maintenance"
                        }
                    ].map((tier, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 30 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.1 }}
                            viewport={{ once: true }}
                            className="p-10 bg-white dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-[2.5rem] space-y-4 hover:border-gold transition-all group"
                        >
                            <div className="flex justify-between items-start">
                                <h3 className="text-2xl font-serif text-luxury-black dark:text-white transition-colors group-hover:italic">
                                    {tier.tier}
                                </h3>
                                <div className="p-3 bg-stone-50 dark:bg-zinc-800 rounded-2xl group-hover:bg-gold/10 transition-colors">
                                    <Trophy size={20} className="text-stone-300 group-hover:text-gold transition-colors" />
                                </div>
                            </div>
                            <p className="text-[10px] font-bold tracking-widest uppercase text-gold">
                                {tier.req}
                            </p>
                            <p className="text-sm text-stone-400 dark:text-stone-500 italic leading-relaxed">
                                {tier.perk}
                            </p>
                        </motion.div>
                    ))}
                </div>
            </main>
        </div>
    );
}
