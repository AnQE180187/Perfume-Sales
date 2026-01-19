"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Sparkles, ArrowRight } from "lucide-react";

export const NewsletterModal = () => {
    const [isOpen, setIsOpen] = useState(false);

    useEffect(() => {
        const timer = setTimeout(() => {
            const hasSeen = localStorage.getItem("newsletter_seen");
            if (!hasSeen) {
                setIsOpen(true);
            }
        }, 8000);

        return () => clearTimeout(timer);
    }, []);

    const handleClose = () => {
        setIsOpen(false);
        localStorage.setItem("newsletter_seen", "true");
    };

    return (
        <AnimatePresence>
            {isOpen && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center p-6">
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={handleClose}
                        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
                    />

                    <motion.div
                        initial={{ opacity: 0, scale: 0.9, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        exit={{ opacity: 0, scale: 0.9, y: 20 }}
                        transition={{ type: "spring", damping: 25, stiffness: 300 }}
                        className="relative w-full max-w-2xl bg-white dark:bg-zinc-950 rounded-[3rem] overflow-hidden shadow-2xl flex flex-col md:flex-row shadow-[0_0_50px_rgba(0,0,0,0.3)] transition-colors"
                    >
                        <button
                            onClick={handleClose}
                            className="absolute top-6 right-6 z-10 p-2 text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors"
                        >
                            <X size={20} />
                        </button>

                        <div className="w-full md:w-1/2 h-48 md:h-auto bg-stone-100 dark:bg-zinc-900 overflow-hidden">
                            <img
                                src="/images/hero.png"
                                alt="Newsletter"
                                className="w-full h-full object-cover"
                            />
                        </div>

                        <div className="w-full md:w-1/2 p-10 md:p-14 flex flex-col justify-center">
                            <div className="flex items-center gap-2 text-accent mb-4">
                                <Sparkles size={16} />
                                <span className="text-[10px] font-bold tracking-[.3em] uppercase italic">Exclusivity Awaits</span>
                            </div>

                            <h2 className="text-3xl font-serif text-luxury-black dark:text-white mb-6">Join the House of <span className="italic">Lumina</span></h2>
                            <p className="text-stone-500 dark:text-stone-400 text-sm font-light leading-relaxed mb-8">
                                Receive private invitations to limited drops and a complimentary AI DNA analysis update monthly.
                            </p>

                            <div className="space-y-4">
                                <div className="border-b border-stone-200 dark:border-white/10 pb-2">
                                    <input
                                        type="email"
                                        placeholder="Your Email Address"
                                        className="w-full bg-transparent text-sm outline-none placeholder:text-stone-400 text-luxury-black dark:text-white"
                                    />
                                </div>
                                <button className="w-full py-4 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-widest uppercase text-[10px] hover:bg-stone-800 dark:hover:bg-accent/80 transition-all flex items-center justify-center gap-3 shadow-lg">
                                    Unlock Access <ArrowRight size={14} />
                                </button>
                                <p className="text-[9px] text-stone-400 text-center uppercase tracking-tighter">
                                    Your data is encrypted by Lumina Neural Trust.
                                </p>
                            </div>
                        </div>
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
    );
};
