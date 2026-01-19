"use client";

import React from "react";
import { InfoPageLayout } from "@/components/layout/InfoPageLayout";
import { Bookmark, Calendar, Zap } from "lucide-react";

export default function SubscriptionPage() {
    return (
        <InfoPageLayout
            title="The Anthology Club"
            subtitle="Curation delivered with monastic precision every solstice."
        >
            <div className="max-w-3xl mx-auto space-y-12">
                <div className="p-12 bg-luxury-black text-white rounded-[3rem] text-center space-y-8 shadow-2xl relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-64 h-64 bg-accent/20 blur-[100px]" />
                    <h3 className="text-3xl font-serif italic">Seasonal Synthesis</h3>
                    <p className="text-stone-400 text-sm italic font-light">
                        "A masterclass in curation. Every box feels like a personal letter from Grasse."
                    </p>
                    <div className="text-5xl font-serif text-accent">$85 <span className="text-lg text-stone-500 not-italic">/ month</span></div>
                    <button className="px-12 py-5 bg-white text-luxury-black rounded-full font-bold tracking-[.3em] uppercase text-[10px] hover:bg-accent hover:text-white transition-all">
                        Initialize Membership
                    </button>
                </div>

                <div className="grid md:grid-cols-3 gap-8 text-center pt-12">
                    {[
                        { icon: Bookmark, title: "Curated Drops", desc: "Hand-picked by our AI Lead" },
                        { icon: Calendar, title: "Solstice Sync", desc: "Arrives exactly every quarter" },
                        { icon: Zap, title: "Priority Retraining", desc: "Update your profile monthly" }
                    ].map((item, i) => (
                        <div key={i} className="space-y-4">
                            <div className="w-12 h-12 rounded-full border border-stone-100 dark:border-white/5 mx-auto flex items-center justify-center text-accent">
                                <item.icon size={20} strokeWidth={1} />
                            </div>
                            <h4 className="text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white">{item.title}</h4>
                            <p className="text-[10px] text-stone-400 uppercase tracking-tighter italic">{item.desc}</p>
                        </div>
                    ))}
                </div>
            </div>
        </InfoPageLayout>
    );
}
