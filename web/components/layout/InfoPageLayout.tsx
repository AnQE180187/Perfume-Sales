"use client";

import React from "react";
import { motion } from "framer-motion";
import { Navbar } from "./Navbar";

interface InfoPageLayoutProps {
    title: string;
    subtitle: string;
    children: React.ReactNode;
}

export const InfoPageLayout = ({ title, subtitle, children }: InfoPageLayoutProps) => {
    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors flex flex-col">
            <Navbar />

            <main className="flex-1">
                {/* Header Section */}
                <section className="pt-48 pb-24 border-b border-stone-100 dark:border-white/5 bg-white dark:bg-zinc-900/40 transition-colors">
                    <div className="container mx-auto px-6">
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.8 }}
                            className="max-w-4xl"
                        >
                            <span className="text-[10px] text-accent font-bold tracking-[.4em] uppercase mb-6 block">Lumina Monograph</span>
                            <h1 className="text-6xl md:text-8xl font-serif text-luxury-black dark:text-white mb-8 leading-none tracking-tighter">
                                {title}
                            </h1>
                            <p className="text-xl text-stone-400 dark:text-stone-500 font-light italic max-w-2xl leading-relaxed">
                                {subtitle}
                            </p>
                        </motion.div>
                    </div>
                </section>

                {/* Content Section */}
                <section className="py-24">
                    <div className="container mx-auto px-6">
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            transition={{ delay: 0.3, duration: 1 }}
                            className="max-w-4xl prose prose-stone dark:prose-invert prose-headings:font-serif prose-headings:font-normal prose-p:text-stone-500 dark:prose-p:text-stone-400 prose-p:leading-relaxed"
                        >
                            {children}
                        </motion.div>
                    </div>
                </section>
            </main>

            <footer className="py-12 border-t border-stone-100 dark:border-white/5 text-center transition-colors">
                <p className="text-[9px] text-stone-400 font-bold tracking-[.4em] uppercase">
                    Document stabilized in Grasse • © 2026 Lumina
                </p>
            </footer>
        </div>
    );
};
