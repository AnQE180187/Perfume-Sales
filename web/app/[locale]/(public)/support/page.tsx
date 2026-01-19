"use client";

import React from "react";
import { InfoPageLayout } from "@/components/layout/InfoPageLayout";
import { Mail, Phone, MessageSquare, ChevronRight, HelpCircle, Sparkles } from "lucide-react";
import Link from "next/link";
import { motion } from "framer-motion";

const faqs = [
    {
        q: "How does the AI determine my olfactory DNA?",
        a: "Our neural synthesizer processes your environmental, psychological, and sensory preferences through a proprietary high-dimensional latent space to find the perfect molecular alignment."
    },
    {
        q: "Can I restabilize a bespoke scent if I move climates?",
        a: "Yes. Our concierge can adjust your formula's concentration to maintain identical sillage in varying humidity and temperature zones."
    },
    {
        q: "What is the provenance of your base spirits?",
        a: "We only use certified organic grape spirits from the Grasse region, aged for 12 months in stone vats before infusion."
    }
];

export default function SupportPage() {
    return (
        <InfoPageLayout
            title="The Concierge"
            subtitle="Request assistance from our digital artisans and olfactory guides."
        >
            <div className="flex flex-col gap-24">
                {/* Contact Channels */}
                <div className="grid md:grid-cols-3 gap-8">
                    {[
                        { icon: Mail, label: "Registry Inquiries", val: "concierge@lumina.com" },
                        { icon: Phone, label: "Direct Dialogue", val: "+33 (0) 1 45 67 89 00" },
                        { icon: MessageSquare, label: "Neural Chat", val: "Active 24/7" }
                    ].map((item, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.1 }}
                            className="p-10 bg-white dark:bg-white/2 border border-stone-100 dark:border-white/5 rounded-[2.5rem] text-center space-y-6 group hover:border-accent transition-all duration-500 shadow-sm"
                        >
                            <div className="w-16 h-16 rounded-3xl bg-stone-50 dark:bg-white/5 mx-auto flex items-center justify-center text-stone-400 group-hover:text-accent group-hover:bg-accent/10 transition-all duration-500">
                                <item.icon size={28} strokeWidth={1} />
                            </div>
                            <div className="space-y-2">
                                <h3 className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-400">{item.label}</h3>
                                <p className="text-luxury-black dark:text-white font-serif italic text-xl group-hover:text-accent transition-colors">{item.val}</p>
                            </div>
                        </motion.div>
                    ))}
                </div>

                {/* AI Consultant CTA */}
                <Link href="/consultation">
                    <div className="relative group overflow-hidden rounded-[3rem] p-12 bg-luxury-black dark:bg-accent/5 border border-white/10 text-white flex flex-col md:flex-row items-center justify-between gap-12 cursor-pointer shadow-2xl">
                        <div className="absolute top-0 right-0 w-1/2 h-full bg-accent/20 blur-[130px] opacity-50 group-hover:opacity-100 transition-opacity" />
                        <div className="relative z-10 flex flex-col md:flex-row items-center gap-10">
                            <div className="w-20 h-20 rounded-[2rem] bg-white text-accent flex items-center justify-center shadow-2xl group-hover:scale-110 transition-transform duration-500">
                                <Sparkles size={40} />
                            </div>
                            <div className="text-center md:text-left">
                                <h3 className="text-3xl font-serif mb-3 italic">Seeking a signature?</h3>
                                <p className="text-stone-400 text-sm max-w-sm font-light leading-relaxed">
                                    Initiate a private session with our Neural Consultant to decode your olfactory profile.
                                </p>
                            </div>
                        </div>
                        <div className="relative z-10">
                            <button className="px-10 py-5 bg-white text-luxury-black rounded-full text-[10px] font-bold tracking-[.4em] uppercase group-hover:bg-accent group-hover:text-white transition-all shadow-xl flex items-center gap-4">
                                START CONSULTATION <ChevronRight size={16} />
                            </button>
                        </div>
                    </div>
                </Link>

                {/* FAQs */}
                <div className="max-w-4xl mx-auto w-full space-y-12">
                    <div className="text-center space-y-4">
                        <div className="inline-flex items-center gap-3 text-accent mb-2">
                            <HelpCircle size={20} />
                            <span className="text-[10px] font-bold tracking-[.4em] uppercase">Intelligence Base</span>
                        </div>
                        <h2 className="text-4xl font-serif text-luxury-black dark:text-white italic">Common Disclosures</h2>
                    </div>

                    <div className="grid gap-6">
                        {faqs.map((faq, i) => (
                            <motion.div
                                key={i}
                                initial={{ opacity: 0, x: -20 }}
                                whileInView={{ opacity: 1, x: 0 }}
                                viewport={{ once: true }}
                                className="p-10 bg-stone-50/50 dark:bg-white/2 border border-stone-100 dark:border-white/5 rounded-[2.5rem] hover:bg-white dark:hover:bg-white/5 transition-all duration-500 group"
                            >
                                <h4 className="text-lg font-serif font-bold text-luxury-black dark:text-white mb-4 group-hover:text-accent transition-colors">
                                    {faq.q}
                                </h4>
                                <p className="text-sm text-stone-500 dark:text-stone-400 leading-relaxed max-w-2xl font-light">
                                    {faq.a}
                                </p>
                            </motion.div>
                        ))}
                    </div>
                </div>
            </div>
        </InfoPageLayout>
    );
}
