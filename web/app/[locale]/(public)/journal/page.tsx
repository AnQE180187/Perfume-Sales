"use client";

import React from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { ArrowUpRight, BookOpen } from "lucide-react";

const articles = [
    {
        category: "Olfactory Science",
        title: "The Neural Mapping of Memory",
        excerpt: "How our AI engine decodes the link between nostalgia and scent molecules to create deeply personal fragrances.",
        date: "Jan 12, 2026",
        image: "/images/hero.png"
    },
    {
        category: "Mastery",
        title: "Grasse: The Heart of Extraction",
        excerpt: "A look inside our solar-powered laboratories where traditional distillation meets computational precision.",
        date: "Dec 15, 2025",
        image: "/images/ingredients-botanical.png"
    },
    {
        category: "Trends",
        title: "The Rise of Nocturnal Florals",
        excerpt: "Why the global shift towards deep, animalic jasmine and ink notes is defining the current generation of prestige scents.",
        date: "Nov 28, 2025",
        image: "/images/ai-consultation.png"
    },
    {
        category: "Experience",
        title: "The Architecture of Sillage",
        excerpt: "Understanding projection and how AI optimizes the volume of your scent based on your environment.",
        date: "Nov 02, 2025",
        image: "/images/hero.png"
    }
];

export default function JournalPage() {
    return (
        <div className="min-h-screen bg-white dark:bg-zinc-950 transition-colors">
            <Navbar />

            <main className="container mx-auto px-6 py-32">
                <header className="mb-24 flex flex-col md:flex-row md:items-end justify-between gap-8">
                    <div className="max-w-2xl">
                        <motion.div
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            className="flex items-center gap-2 text-accent mb-4"
                        >
                            <BookOpen size={18} />
                            <span className="text-xs font-bold tracking-[.3em] uppercase italic transition-colors">Digital Anthology</span>
                        </motion.div>
                        <motion.h1
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.1 }}
                            className="text-5xl md:text-7xl font-serif text-luxury-black dark:text-white mb-8 transition-colors"
                        >
                            Lumina <span className="italic">Journal</span>
                        </motion.h1>
                        <motion.p
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.2 }}
                            className="text-stone-500 dark:text-stone-400 text-lg font-light leading-relaxed transition-colors"
                        >
                            Exploring the intersection of tradition, neural science, and luxury perfumery.
                        </motion.p>
                    </div>

                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="flex gap-4"
                    >
                        {["All", "Science", "Philosophy", "Artistry"].map(cat => (
                            <button key={cat} className="text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors">
                                {cat}
                            </button>
                        ))}
                    </motion.div>
                </header>

                {/* Featured Article */}
                <motion.section
                    initial={{ opacity: 0, y: 30 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.3 }}
                    className="group relative h-[600px] mb-24 rounded-[3rem] overflow-hidden shadow-2xl cursor-pointer"
                >
                    <Image
                        src="/images/hero.png"
                        alt="Featured Article"
                        fill
                        className="object-cover transition-transform duration-1000 group-hover:scale-105"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />
                    <div className="absolute bottom-16 left-16 right-16">
                        <span className="text-accent text-[10px] font-bold tracking-widest uppercase mb-4 block">Special Release</span>
                        <h2 className="text-4xl md:text-6xl font-serif text-white max-w-3xl mb-6">Sustainable Synthesis: The Future of Raw Materials</h2>
                        <p className="text-stone-300 max-w-xl mb-8 font-light text-lg">How neural AI is predicting the next century of botanical rarity and how we're preserving it today.</p>
                        <button className="flex items-center gap-3 text-white text-[10px] font-bold tracking-[.3em] uppercase">
                            Consume the Story <ArrowUpRight size={18} />
                        </button>
                    </div>
                </motion.section>

                {/* Article Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-24">
                    {articles.map((article, i) => (
                        <motion.article
                            key={article.title}
                            initial={{ opacity: 0, y: 30 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true }}
                            transition={{ delay: i * 0.1 }}
                            className="group cursor-pointer"
                        >
                            <div className="relative aspect-video mb-8 rounded-[2rem] overflow-hidden transition-colors border border-stone-100 dark:border-white/5">
                                <Image
                                    src={article.image}
                                    alt={article.title}
                                    fill
                                    className="object-cover transition-transform duration-700 group-hover:scale-110"
                                />
                                <div className="absolute top-6 left-6 px-4 py-1.5 glass rounded-full text-[10px] text-white font-bold tracking-widest uppercase">
                                    {article.category}
                                </div>
                            </div>
                            <div className="flex justify-between items-start mb-4">
                                <span className="text-[10px] text-stone-400 font-bold tracking-widest uppercase transition-colors">{article.date}</span>
                                <div className="p-2 border border-stone-200 dark:border-white/10 rounded-full text-stone-900 dark:text-white group-hover:bg-luxury-black group-hover:text-white dark:group-hover:bg-accent transition-all">
                                    <ArrowUpRight size={14} />
                                </div>
                            </div>
                            <h3 className="text-3xl font-serif text-luxury-black dark:text-white mb-4 group-hover:italic transition-all duration-500">{article.title}</h3>
                            <p className="text-stone-500 dark:text-stone-400 font-light leading-relaxed transition-colors">
                                {article.excerpt}
                            </p>
                        </motion.article>
                    ))}
                </div>

                <motion.div
                    initial={{ opacity: 0 }}
                    whileInView={{ opacity: 1 }}
                    className="mt-32 pt-24 border-t border-stone-100 dark:border-white/10 text-center"
                >
                    <button className="px-12 py-5 bg-luxury-black dark:bg-white text-white dark:text-luxury-black rounded-full font-bold tracking-[.2em] uppercase hover:scale-105 transition-all">
                        Load Older Transcripts
                    </button>
                </motion.div>
            </main>
        </div>
    );
}
