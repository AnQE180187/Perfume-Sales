"use client";

import React from "react";
import { useParams } from "next/navigation";
import { motion } from "framer-motion";
import { ArrowRight, Mail, Sparkles, MoveLeft } from "lucide-react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { useTranslations } from "next-intl";
import { Navbar } from "@/components/layout/Navbar";
import { apiClient } from "@/lib/api-client";

export default function ForgotPasswordPage() {
    const t = useTranslations("Auth");
    const { locale } = useParams();
    const [email, setEmail] = React.useState("");
    const [isLoading, setIsLoading] = React.useState(false);
    const [error, setError] = React.useState<string | null>(null);
    const [status, setStatus] = React.useState<"idle" | "success">("idle");

    const handleReset = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);
        setError(null);

        try {
            // TODO: Implement forgot password endpoint in backend
            // For now, show error
            setError("Password reset email is not yet implemented. Please contact support.");
            setIsLoading(false);
        } catch (err: any) {
            setError(err.message);
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors flex flex-col">
            <Navbar />
            <main className="flex-1 flex items-center justify-center p-6 py-32">
                <div className="max-w-6xl w-full grid md:grid-cols-2 gap-12 bg-white dark:bg-zinc-900 rounded-[4rem] overflow-hidden shadow-2xl border border-stone-100 dark:border-white/5 transition-colors">
                    {/* Visual Side */}
                    <div className="relative hidden md:block overflow-hidden min-h-[600px]">
                        <Image
                            src="/images/ai-consultation.png"
                            alt="Recovery"
                            fill
                            className="object-cover contrast-110 grayscale-[0.2]"
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-luxury-black/90 via-luxury-black/20 to-transparent flex flex-col justify-end p-16">
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 0.5 }}
                            >
                                <div className="flex items-center gap-3 text-accent mb-6">
                                    <Sparkles size={24} />
                                    <span className="text-[10px] font-bold tracking-[.4em] uppercase">{t("privateAccess")}</span>
                                </div>
                                <h2 className="text-5xl font-serif text-white mb-6 leading-tight italic">{t("forgotPasswordTitle")}</h2>
                                <p className="text-stone-300 text-sm font-light leading-relaxed max-w-sm">
                                    {t("forgotPasswordDesc")}
                                </p>
                            </motion.div>
                        </div>
                    </div>

                    {/* Form Side */}
                    <div className="p-12 md:p-20 flex flex-col justify-center">
                        <motion.div
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ duration: 0.5 }}
                        >
                            <Link
                                href="/login"
                                className="inline-flex items-center gap-2 text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-accent transition-colors mb-12 group"
                            >
                                <MoveLeft size={14} className="group-hover:-translate-x-1 transition-transform" />
                                {t("backToLogin")}
                            </Link>

                            <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">
                                {t("forgotPasswordTitle")}
                            </h1>
                            <p className="text-[10px] text-stone-400 font-bold tracking-[.4em] uppercase mb-12">
                                {t("securityProtocol")}
                            </p>

                            {status === "success" ? (
                                <motion.div
                                    initial={{ opacity: 0, y: 10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    className="bg-accent/10 border border-accent/20 rounded-3xl p-8 text-center"
                                >
                                    <Sparkles className="mx-auto text-accent mb-4" size={32} />
                                    <h3 className="text-lg font-serif mb-2">{t("emailSent")}</h3>
                                    <p className="text-xs text-stone-500 leading-relaxed">
                                        {t("resetLinkSentDesc")}
                                    </p>
                                </motion.div>
                            ) : (
                                <form onSubmit={handleReset} className="space-y-6">
                                    {error && (
                                        <div className="p-4 bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-500/20 rounded-2xl text-red-500 text-xs font-bold tracking-widest uppercase">
                                            {error}
                                        </div>
                                    )}
                                    <div className="space-y-2">
                                        <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t("email")}</label>
                                        <div className="relative">
                                            <Mail className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300" size={18} />
                                            <input
                                                type="email"
                                                required
                                                value={email}
                                                onChange={(e) => setEmail(e.target.value)}
                                                className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-14 py-4 outline-none focus:border-accent transition-all text-sm"
                                                placeholder="alexander@lumina.com"
                                            />
                                        </div>
                                    </div>

                                    <button
                                        type="submit"
                                        disabled={isLoading}
                                        className="w-full py-5 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all flex items-center justify-center gap-4 group disabled:opacity-50"
                                    >
                                        {isLoading ? t("processing") : t("sendResetCode")}
                                        {!isLoading && <ArrowRight size={16} className="group-hover:translate-x-2 transition-transform" />}
                                    </button>
                                </form>
                            )}
                        </motion.div>
                    </div>
                </div>
            </main>
        </div>
    );
}
