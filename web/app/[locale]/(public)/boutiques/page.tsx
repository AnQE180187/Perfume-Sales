"use client";

import React from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { MapPin, Phone, Clock, ArrowRight } from "lucide-react";

export default function BoutiquesPage() {
    const boutiques = [
        { city: "Paris", address: "8 Rue du Faubourg Saint-Honoré", phone: "+33 1 42 65 31 31", hours: "10:00 - 19:00" },
        { city: "London", address: "14-15 Conduit St, Mayfair", phone: "+44 20 7493 0000", hours: "10:00 - 18:30" },
        { city: "New York", address: "712 Fifth Avenue, Manhattan", phone: "+1 212-247-1100", hours: "10:00 - 20:00" },
        { city: "Tokyo", address: "5-1-15 Jinguumae, Shibuya", phone: "+81 3-5464-3111", hours: "11:00 - 20:00" },
    ];

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Navbar />

            <main>
                {/* Hero */}
                <section className="relative h-[60vh] flex items-center justify-center overflow-hidden">
                    <Image src="/images/boutique.png" alt="Boutique Interior" fill className="object-cover contrast-125" />
                    <div className="absolute inset-0 bg-black/40 backdrop-blur-[2px]" />
                    <div className="relative z-10 text-center text-white px-6">
                        <motion.span initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-xs font-bold tracking-[.4em] uppercase mb-6 block">The Scent Ateliers</motion.span>
                        <motion.h1 initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.3 }} className="text-5xl md:text-7xl font-serif">Global Boutiques</motion.h1>
                    </div>
                </section>

                {/* Global Network */}
                <section className="py-32">
                    <div className="container mx-auto px-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
                            {boutiques.map((b, i) => (
                                <motion.div
                                    key={i}
                                    initial={{ opacity: 0, y: 20 }}
                                    whileInView={{ opacity: 1, y: 0 }}
                                    viewport={{ once: true }}
                                    transition={{ delay: i * 0.1 }}
                                    className="glass bg-white dark:bg-zinc-900 p-10 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm hover:shadow-xl transition-all group"
                                >
                                    <h3 className="text-3xl font-serif text-luxury-black dark:text-white mb-10 group-hover:text-accent dark:group-hover:text-accent transition-colors">{b.city}</h3>

                                    <div className="space-y-6">
                                        <div className="flex gap-4">
                                            <MapPin size={18} className="text-stone-300 dark:text-stone-600 flex-shrink-0 transition-colors" />
                                            <p className="text-xs text-stone-500 dark:text-stone-400 leading-relaxed font-medium uppercase tracking-widest transition-colors">{b.address}</p>
                                        </div>
                                        <div className="flex gap-4">
                                            <Phone size={18} className="text-stone-300 dark:text-stone-600 flex-shrink-0 transition-colors" />
                                            <p className="text-xs text-stone-500 dark:text-stone-400 font-medium tracking-widest transition-colors">{b.phone}</p>
                                        </div>
                                        <div className="flex gap-4">
                                            <Clock size={18} className="text-stone-300 dark:text-stone-600 flex-shrink-0 transition-colors" />
                                            <p className="text-xs text-stone-500 dark:text-stone-400 font-medium tracking-widest transition-colors">{b.hours}</p>
                                        </div>
                                    </div>

                                    <button className="mt-12 w-full py-4 border border-stone-100 dark:border-white/10 rounded-2xl flex items-center justify-center gap-3 text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 group-hover:bg-luxury-black dark:group-hover:bg-accent group-hover:text-white dark:group-hover:text-white group-hover:border-luxury-black dark:group-hover:border-accent transition-all">
                                        Book Private Discovery <ArrowRight size={14} />
                                    </button>
                                </motion.div>
                            ))}
                        </div>
                    </div>
                </section>

                {/* Client Relations */}
                <section className="py-32 bg-luxury-black text-white relative overflow-hidden">
                    <div className="container mx-auto px-6">
                        <div className="max-w-4xl mx-auto flex flex-col md:flex-row items-center gap-24">
                            <div className="flex-1">
                                <span className="text-xs font-bold tracking-[.2em] uppercase text-accent mb-6 block font-serif italic">Concierge Service</span>
                                <h2 className="text-4xl md:text-5xl font-serif mb-8 italic">Virtual Fragrance Masterclass</h2>
                                <p className="text-stone-400 text-lg font-light leading-relaxed mb-10">
                                    Can't visit our ateliers in person? Our world-class perfumers are available for 1-on-1 virtual consultations to guide you through your olfactory journey.
                                </p>
                                <div className="flex flex-wrap gap-8">
                                    <div className="flex flex-col gap-2">
                                        <span className="text-[10px] uppercase tracking-widest text-stone-500">Global Assistance</span>
                                        <span className="text-sm font-bold tracking-widest uppercase">concierge@lumina.com</span>
                                    </div>
                                    <div className="flex flex-col gap-2">
                                        <span className="text-[10px] uppercase tracking-widest text-stone-500">Bespoke Inquiries</span>
                                        <span className="text-sm font-bold tracking-widest uppercase">ateliers@lumina.com</span>
                                    </div>
                                </div>
                            </div>
                            <div className="w-full md:w-80 relative aspect-square rounded-full border border-white/10 p-12 flex items-center justify-center group overflow-hidden">
                                <div className="absolute inset-0 bg-accent/10 opacity-0 group-hover:opacity-100 transition-opacity blur-[80px]" />
                                <button className="relative z-10 w-full h-full rounded-full border border-accent flex items-center justify-center text-accent text-xs font-bold tracking-[.3em] uppercase text-center p-8 group-hover:bg-accent group-hover:text-white transition-all duration-700">
                                    Schedule Your Private Session
                                </button>
                            </div>
                        </div>
                    </div>
                </section>
            </main>
        </div>
    );
}
