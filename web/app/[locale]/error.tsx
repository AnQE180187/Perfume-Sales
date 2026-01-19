"use client";

import React, { useEffect } from "react";
import { motion } from "framer-motion";
import { AlertCircle, RefreshCcw, Home } from "lucide-react";
import { Link } from "@/i18n/routing";
import { Navbar } from "@/components/layout/Navbar";
import { useTranslations } from "next-intl";

export default function Error({
    error,
    reset,
}: {
    error: Error & { digest?: string };
    reset: () => void;
}) {
    const t = useTranslations("Error");
    useEffect(() => {
        console.error("System Malfunction:", error);
    }, [error]);

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors flex flex-col">
            <Navbar />
            <main className="flex-1 flex items-center justify-center p-6 py-32">
                <div className="text-center space-y-12">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="relative inline-block"
                    >
                        <div className="w-48 h-48 rounded-[3rem] border border-stone-100 dark:border-white/5 flex items-center justify-center bg-white dark:bg-zinc-900 shadow-xl transition-colors">
                            <AlertCircle size={64} strokeWidth={1} className="text-red-500 animate-pulse" />
                        </div>
                        <div className="absolute -top-4 -right-4 bg-red-500 text-white px-4 py-2 rounded-full text-[10px] font-bold tracking-widest uppercase">
                            System Error
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

                    <div className="flex flex-wrap justify-center gap-6 mt-12">
                        <button
                            onClick={() => reset()}
                            className="inline-flex items-center gap-4 px-10 py-5 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all group"
                        >
                            <RefreshCcw size={18} className="group-hover:rotate-180 transition-transform duration-700" />
                            {t("retry")}
                        </button>
                        <Link href="/" className="inline-flex items-center gap-4 px-10 py-5 glass dark:bg-white/5 text-luxury-black dark:text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] hover:bg-white transition-all shadow-sm">
                            <Home size={18} />
                            {t("cta")}
                        </Link>
                    </div>
                </div>
            </main>
        </div>
    );
}
