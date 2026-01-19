"use client";

import React from "react";
import { InfoPageLayout } from "@/components/layout/InfoPageLayout";
import { CircleDollarSign, Trophy, Sparkles } from "lucide-react";

export default function RewardsPage() {
    return (
        <InfoPageLayout
            title="Aura Tiers"
            subtitle="The more you explore, the deeper your connection to the House becomes."
        >
            <div className="grid md:grid-cols-2 gap-12">
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
                    <div key={i} className="p-10 bg-white dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-[2.5rem] space-y-4 hover:border-accent transition-all group">
                        <div className="flex justify-between items-start">
                            <h3 className="text-2xl font-serif text-luxury-black dark:text-white transition-colors group-hover:italic">{tier.tier}</h3>
                            <Trophy size={20} className="text-stone-300 group-hover:text-accent transition-colors" />
                        </div>
                        <p className="text-[10px] font-bold tracking-widest uppercase text-accent">{tier.req}</p>
                        <p className="text-sm text-stone-400 dark:text-stone-500 italic leading-relaxed">
                            {tier.perk}
                        </p>
                    </div>
                ))}
            </div>
        </InfoPageLayout>
    );
}
