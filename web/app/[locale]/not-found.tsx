"use client";

import React from "react";
import { Link } from "@/i18n/routing";
import { motion } from "framer-motion";
import { Compass, ArrowLeft } from "lucide-react";
import { Navbar } from "@/components/layout/Navbar";
import { useTranslations } from "next-intl";

export default function NotFound() {
    const t = useTranslations("NotFound");
    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors flex flex-col">
            <Navbar />
            <main className="flex-1 flex items-center justify-center p-6 py-32">
                <div className="text-center space-y-12">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.8 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ duration: 1, ease: "easeOut" }}
                        className="relative inline-block"
                    >
                        <div className="w-48 h-48 rounded-full border border-stone-100 dark:border-white/5 flex items-center justify-center bg-white dark:bg-zinc-900 shadow-xl transition-colors">
                            <Compass size={64} strokeWidth={1} className="text-accent animate-spin-slow" />
                        </div>
                        <div className="absolute -top-4 -right-4 bg-luxury-black dark:bg-accent text-white px-4 py-2 rounded-full text-[10px] font-bold tracking-widest uppercase">
                            Error 404
                        </div>
                    </motion.div>

                    <div className="space-y-6">
                        <h1 className="text-6xl md:text-8xl font-serif text-luxury-black dark:text-white transition-colors leading-[0.9] tracking-tighter">
                            {t("h1_1")} <br />
                            <span className="italic font-light">{t("h1_2")}</span>
                        </h1>
                        <p className="text-stone-400 dark:text-stone-500 text-sm max-w-sm mx-auto font-light leading-relaxed italic">
                            {t("p")}
                        </p>
                    </div>

                    <Link href="/" className="inline-flex items-center gap-4 px-10 py-5 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all group lg:mt-12">
                        <ArrowLeft size={18} className="group-hover:-translate-x-2 transition-transform" />
                        {t("cta")}
                    </Link>
                </div>
            </main>

            <style jsx global>{`
                @keyframes spin-slow {
                    from { transform: rotate(0deg); }
                    to { transform: rotate(360deg); }
                }
                .animate-spin-slow {
                    animation: spin-slow 12s linear infinite;
                }
            `}</style>
        </div>
    );
}
