"use client";

import React, { useState } from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { FileText, Edit3, Trash2, Eye, Plus, Search, Filter, Calendar, Tag, ChevronRight, BookOpen } from "lucide-react";

const mockContent = [
    {
        id: 1,
        title: "The Alchemy of Amber: A Winter Tale",
        type: "Journal",
        author: "Sarah Jenkins",
        status: "Published",
        date: "Jan 12, 2026",
        image: "/images/hero.png",
        tags: ["Ingredients", "Seasonal"]
    },
    {
        id: 2,
        title: "Behind the Scent: No. 01 Origins",
        type: "Story",
        author: "Alexander Dupont",
        status: "Draft",
        date: "Jan 10, 2026",
        image: "/images/hero.png",
        tags: ["Heritage", "Process"]
    },
    {
        id: 3,
        title: "Sustainable Luxury: The Green Essence",
        type: "Journal",
        author: "Elena Gilbert",
        status: "Scheduled",
        date: "Jan 15, 2026",
        image: "/images/hero.png",
        tags: ["Eco-Luxury", "Future"]
    }
];

export default function ContentCMSPage() {
    return (
        <div className="space-y-8 pb-20">
            {/* Header */}
            <div className="flex justify-between items-end">
                <div>
                    <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-2">Content <span className="italic">Manifest</span></h1>
                    <p className="text-stone-400 text-sm">Curate and publish luxury narratives across the Lumina digital ecosystem.</p>
                </div>
                <button className="bg-luxury-black dark:bg-accent text-white px-8 py-4 rounded-full text-[10px] font-bold tracking-widest uppercase flex items-center gap-3 hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-xl">
                    <Plus size={16} /> Create Narrative
                </button>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {[
                    { label: "Active Narratives", value: "48", icon: FileText, color: "text-blue-500" },
                    { label: "Drafts in Progress", value: "12", icon: Edit3, color: "text-amber-500" },
                    { label: "Total Readers", value: "12.4k", icon: BookOpen, color: "text-purple-500" },
                ].map((stat, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="glass dark:bg-stone-900/50 p-6 rounded-[2rem] border border-stone-100 dark:border-white/5"
                    >
                        <div className="flex items-center gap-6">
                            <div className={`p-4 rounded-2xl bg-stone-50 dark:bg-white/5 ${stat.color}`}>
                                <stat.icon size={22} />
                            </div>
                            <div>
                                <h3 className="text-2xl font-serif text-stone-900 dark:text-white mb-1 transition-colors">{stat.value}</h3>
                                <p className="text-[10px] text-stone-400 font-bold tracking-widest uppercase">{stat.label}</p>
                            </div>
                        </div>
                    </motion.div>
                ))}
            </div>

            {/* Filter & Search */}
            <div className="flex flex-col md:flex-row gap-4 items-center justify-between bg-white dark:bg-stone-900/40 p-4 rounded-[2rem] border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                <div className="flex items-center gap-4 bg-stone-50 dark:bg-white/5 px-6 py-3 rounded-full w-full md:w-96 border border-stone-100 dark:border-white/5 transition-colors">
                    <Search size={18} className="text-stone-400" />
                    <input type="text" placeholder="Search content archive..." className="bg-transparent border-none outline-none text-sm w-full text-stone-900 dark:text-stone-100" />
                </div>
                <div className="flex gap-3">
                    <button className="flex items-center gap-2 px-6 py-3 rounded-full border border-stone-100 dark:border-white/5 text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all">
                        <Filter size={14} /> Type
                    </button>
                    <button className="flex items-center gap-2 px-6 py-3 rounded-full border border-stone-100 dark:border-white/5 text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all">
                        Status
                    </button>
                </div>
            </div>

            {/* Content List */}
            <div className="grid grid-cols-1 gap-6">
                {mockContent.map((item, i) => (
                    <motion.div
                        key={item.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="bg-white dark:bg-stone-900/40 p-6 rounded-[2.5rem] border border-stone-100 dark:border-white/5 hover:border-accent transition-all group flex flex-col md:flex-row gap-8 items-center"
                    >
                        <div className="relative w-full md:w-48 h-32 rounded-3xl overflow-hidden shadow-lg flex-shrink-0">
                            <Image src={item.image} alt={item.title} fill className="object-cover group-hover:scale-110 transition-transform duration-700" />
                            <div className="absolute top-4 left-4">
                                <span className={`text-[8px] font-bold tracking-widest uppercase px-3 py-1 rounded-full ${item.status === 'Published' ? 'bg-green-500 text-white' :
                                        item.status === 'Draft' ? 'bg-amber-500 text-white' :
                                            'bg-purple-500 text-white'
                                    }`}>
                                    {item.status}
                                </span>
                            </div>
                        </div>

                        <div className="flex-1 space-y-4 text-center md:text-left">
                            <div className="flex flex-wrap justify-center md:justify-start gap-4 mb-2">
                                <span className="text-[10px] text-accent font-bold tracking-[.3em] uppercase italic">{item.type}</span>
                                <div className="flex gap-2">
                                    {item.tags.map(tag => (
                                        <span key={tag} className="text-[8px] text-stone-400 font-bold uppercase tracking-widest flex items-center gap-1">
                                            <Tag size={10} /> {tag}
                                        </span>
                                    ))}
                                </div>
                            </div>
                            <h3 className="text-xl md:text-2xl font-serif text-luxury-black dark:text-white transition-colors tracking-tight">
                                {item.title}
                            </h3>
                            <div className="flex flex-wrap justify-center md:justify-start items-center gap-6 text-[10px] font-bold tracking-widest uppercase text-stone-500">
                                <div className="flex items-center gap-2 transition-colors">
                                    <Edit3 size={14} className="text-stone-300" /> {item.author}
                                </div>
                                <div className="flex items-center gap-2 transition-colors">
                                    <Calendar size={14} className="text-stone-300" /> {item.date}
                                </div>
                            </div>
                        </div>

                        <div className="flex gap-4 md:flex-col lg:flex-row">
                            <button className="p-4 rounded-2xl bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 text-stone-400 hover:text-accent hover:border-accent transition-all">
                                <Eye size={18} />
                            </button>
                            <button className="p-4 rounded-2xl bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 text-stone-400 hover:text-luxury-black dark:hover:text-white hover:border-stone-200 transition-all">
                                <Edit3 size={18} />
                            </button>
                            <button className="p-4 rounded-2xl bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 text-stone-400 hover:text-red-500 hover:border-red-500 transition-all">
                                <Trash2 size={18} />
                            </button>
                        </div>
                    </motion.div>
                ))}
            </div>

            {/* Content Analytics Tip */}
            <div className="p-8 bg-stone-900 dark:bg-black rounded-[2.5rem] text-white flex flex-col md:flex-row justify-between items-center gap-8">
                <div className="flex items-center gap-6">
                    <div className="w-16 h-16 rounded-full bg-accent flex items-center justify-center shadow-lg">
                        <BookOpen size={24} className="text-white" />
                    </div>
                    <div>
                        <h4 className="text-lg font-serif mb-1">Curation Intelligence</h4>
                        <p className="text-xs text-stone-400 uppercase tracking-widest italic">AI suggests "Oceanic Sustainability" as the next high-engagement topic.</p>
                    </div>
                </div>
                <button className="px-8 py-4 bg-white/5 hover:bg-white/10 rounded-full text-[10px] font-bold tracking-[.3em] uppercase text-white transition-all border border-white/10 flex items-center gap-3">
                    Generate Draft with AI <ChevronRight size={16} />
                </button>
            </div>
        </div>
    );
}
