"use client";

import React from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Search as SearchIcon, ArrowRight, Sparkles } from "lucide-react";

interface SearchOverlayProps {
    isOpen: boolean;
    onClose: () => void;
}

const recentSearches = ["Sandalwood", "Night Jasmine", "Limited Edition 2026", "AI Scent DNA"];
const suggestions = [
    { name: "Lumina No. 01", category: "Niche" },
    { name: "Oud Mystère", category: "Prestige" },
    { name: "Santal Bloom", category: "Botanical" }
];

export const SearchOverlay = ({ isOpen, onClose }: SearchOverlayProps) => {
    return (
        <AnimatePresence>
            {isOpen && (
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    className="fixed inset-0 z-[200] bg-white dark:bg-zinc-950 flex flex-col transition-colors"
                >
                    <div className="container mx-auto px-6 pt-10 pb-32 flex flex-col h-full">
                        <div className="flex justify-end mb-20">
                            <button
                                onClick={onClose}
                                className="p-4 hover:rotate-90 transition-transform duration-500 text-stone-400 hover:text-luxury-black dark:hover:text-white"
                            >
                                <X size={40} strokeWidth={1} />
                            </button>
                        </div>

                        <div className="max-w-4xl mx-auto w-full flex-1">
                            <div className="relative mb-20 group">
                                <SearchIcon className="absolute left-0 top-1/2 -translate-y-1/2 text-stone-300 dark:text-stone-700 group-focus-within:text-accent transition-colors" size={32} strokeWidth={1} />
                                <input
                                    autoFocus
                                    type="text"
                                    placeholder="Search the Atelier..."
                                    className="w-full bg-transparent border-b border-stone-200 dark:border-white/10 py-8 pl-14 text-4xl md:text-6xl font-serif text-luxury-black dark:text-white outline-none placeholder:text-stone-100 dark:placeholder:text-stone-900 transition-colors"
                                />
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-20">
                                <div>
                                    <h3 className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-400 dark:text-stone-500 mb-8 flex items-center gap-3 transition-colors">
                                        <Sparkles size={14} /> Neural Suggestions
                                    </h3>
                                    <div className="space-y-6">
                                        {suggestions.map((item) => (
                                            <div key={item.name} className="flex items-center justify-between group cursor-pointer">
                                                <div className="flex flex-col">
                                                    <span className="text-2xl font-serif text-luxury-black dark:text-white group-hover:italic transition-all">{item.name}</span>
                                                    <span className="text-[9px] uppercase tracking-widest text-stone-400">{item.category}</span>
                                                </div>
                                                <ArrowRight size={20} className="text-stone-200 dark:text-stone-800 opacity-0 group-hover:opacity-100 -translate-x-4 group-hover:translate-x-0 transition-all text-accent" />
                                            </div>
                                        ))}
                                    </div>
                                </div>

                                <div>
                                    <h3 className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-400 dark:text-stone-500 mb-8 transition-colors">Recent Archives</h3>
                                    <div className="flex flex-wrap gap-3">
                                        {recentSearches.map((tag) => (
                                            <button key={tag} className="px-6 py-2 border border-stone-100 dark:border-white/5 rounded-full text-xs text-stone-500 hover:bg-luxury-black dark:hover:bg-accent hover:text-white hover:border-luxury-black dark:hover:border-accent transition-all uppercase tracking-widest font-bold">
                                                {tag}
                                            </button>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        </div>

                        <footer className="mt-auto text-center py-12">
                            <p className="text-[10px] tracking-[.3em] uppercase text-stone-400 dark:text-stone-600">
                                House of Lumina Digital Archive v1.2
                            </p>
                        </footer>
                    </div>
                </motion.div>
            )}
        </AnimatePresence>
    );
};
