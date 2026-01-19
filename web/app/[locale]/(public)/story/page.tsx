"use client";

import React from "react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { motion } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { Sparkles, Wind, Droplets, Heart } from "lucide-react";

export default function StoryPage() {
    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Navbar />

            <main>
                {/* Intro */}
                <section className="relative h-screen flex items-center justify-center text-center px-6">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ duration: 1.5 }}
                        className="absolute inset-0 z-0"
                    >
                        <Image
                            src="/images/story-perfumer.png"
                            alt="The Art of Scent"
                            fill
                            className="object-cover brightness-50"
                        />
                    </motion.div>

                    <div className="relative z-10 max-w-4xl">
                        <motion.span
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.5 }}
                            className="inline-block px-4 py-1.5 glass text-white text-xs font-bold tracking-[.3em] uppercase mb-8"
                        >
                            Since 2026
                        </motion.span>
                        <motion.h1
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.7 }}
                            className="text-6xl md:text-8xl font-serif text-white mb-12 leading-tight"
                        >
                            The Intersection of <br />
                            <span className="italic">Nature & Intellect</span>
                        </motion.h1>
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            transition={{ delay: 1.2 }}
                            className="w-px h-24 bg-gradient-to-b from-white to-transparent mx-auto"
                        />
                    </div>
                </section>

                {/* Philosophy */}
                <section className="py-32 bg-white dark:bg-zinc-900 transition-colors">
                    <div className="container mx-auto px-6">
                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-24 items-center">
                            <div>
                                <span className="text-xs font-bold tracking-[.2em] uppercase text-accent mb-6 block">Our Philosophy</span>
                                <h2 className="text-4xl md:text-5xl font-serif text-luxury-black dark:text-white mb-10 italic transition-colors">"Scent is the most intense form of memory."</h2>
                                <div className="space-y-6 text-stone-600 dark:text-stone-400 leading-[1.8] text-lg font-light transition-colors">
                                    <p>
                                        LUMINA was founded on a simple yet radical idea: that the ancient art of perfumery should be personal, precise, and profoundly intelligent.
                                    </p>
                                    <p>
                                        We combined the sensitivity of world-class "noses" with the analytical power of advanced AI to bridge the gap between human emotion and chemical composition.
                                    </p>
                                </div>
                            </div>
                            <div className="relative aspect-[4/5] rounded-[3rem] overflow-hidden shadow-2xl">
                                <Image src="/images/ingredients.png" alt="Ingredients" fill className="object-cover" />
                            </div>
                        </div>
                    </div>
                </section>

                {/* Steps */}
                <section className="py-32 bg-stone-100 dark:bg-black/50 transition-colors">
                    <div className="container mx-auto px-6">
                        <div className="text-center mb-24">
                            <h2 className="text-4xl md:text-5xl font-serif text-luxury-black dark:text-white transition-colors">The Lumina Method</h2>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-3 gap-16">
                            {[
                                { icon: Wind, title: "Sourcing", desc: "We travel the globe to source the highest quality raw materials from sustainable estates." },
                                { icon: Sparkles, title: "Analysis", desc: "Our AI engine analyzes millions of sensory data points to understand human olfactory resonance." },
                                { icon: Heart, title: "Crafting", desc: "Each bottle is finished by hand in our atelier, ensuring the human touch remains at our core." }
                            ].map((step, i) => {
                                const Icon = step.icon;
                                return (
                                    <div key={i} className="text-center group">
                                        <div className="w-20 h-20 rounded-[2rem] bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-accent mx-auto mb-8 group-hover:bg-accent group-hover:text-white transition-all duration-500">
                                            <Icon size={32} strokeWidth={1} />
                                        </div>
                                        <h4 className="text-xl font-serif mb-4 text-luxury-black dark:text-white transition-colors">{step.title}</h4>
                                        <p className="text-stone-500 dark:text-stone-400 text-sm leading-relaxed transition-colors">{step.desc}</p>
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                </section>

                {/* CTA */}
                <section className="py-48 relative overflow-hidden bg-luxury-black text-white text-center">
                    <div className="container mx-auto px-6 relative z-10">
                        <h2 className="text-5xl md:text-7xl font-serif mb-12">Experience the Future <br /> of Fragrance.</h2>
                        <Link href="/consultation" className="inline-block px-12 py-5 bg-white text-luxury-black rounded-full font-bold tracking-widest uppercase hover:bg-stone-200 transition-all">
                            Discover My Scent
                        </Link>
                    </div>
                    <div className="absolute inset-0 opacity-20">
                        <Image src="/images/hero.png" alt="Overlay" fill className="object-cover" />
                    </div>
                </section>
            </main>
        </div>
    );
}
