"use client";

import React from "react";
import { InfoPageLayout } from "@/components/layout/InfoPageLayout";
import { Gift, Mail, Heart } from "lucide-react";

export default function GiftingPage() {
    return (
        <InfoPageLayout
            title="The Art of Giving"
            subtitle="Bestow the luxury of a personal olfactory journey upon another."
        >
            <div className="grid md:grid-cols-2 gap-12">
                <div className="p-12 bg-white dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-[3rem] space-y-8 flex flex-col justify-between">
                    <div className="space-y-6">
                        <Gift size={48} strokeWidth={1} className="text-accent" />
                        <h3 className="text-3xl font-serif text-luxury-black dark:text-white transition-colors uppercase tracking-widest leading-none">The Physical <br /><span className="italic">Discovery Set</span></h3>
                        <p className="text-stone-400 dark:text-stone-500 text-sm font-light leading-relaxed italic">
                            A hand-packaged selection of our permanent collection, allowing them to find their initial resonance before the AI synthesis.
                        </p>
                    </div>
                    <button className="w-full py-5 border border-luxury-black dark:border-accent text-luxury-black dark:text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] hover:bg-luxury-black hover:text-white transition-all">
                        Buy Physical Set • $85
                    </button>
                </div>

                <div className="p-12 bg-luxury-black text-white rounded-[3rem] space-y-8 flex flex-col justify-between shadow-2xl">
                    <div className="space-y-6">
                        <Mail size={48} strokeWidth={1} className="text-accent" />
                        <h3 className="text-3xl font-serif text-white transition-colors uppercase tracking-widest leading-none italic">The Digital <br />Atelier Pass</h3>
                        <p className="text-stone-400 text-sm font-light leading-relaxed italic">
                            An invitation to our AI-powered consultation. The gift of a bespoke molecular signature delivered instantly via the digital registry.
                        </p>
                    </div>
                    <button className="w-full py-5 bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] hover:bg-white hover:text-luxury-black transition-all shadow-xl">
                        Send Digital Pass • $240
                    </button>
                </div>
            </div>
        </InfoPageLayout>
    );
}
