"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { ArrowRight, Lock, Eye, EyeOff, Sparkles } from "lucide-react";
import { useTranslations } from "next-intl";
import { Navbar } from "@/components/layout/Navbar";
import { supabase } from "@/lib/supabase";
import { useRouter } from "@/i18n/routing";

export default function ResetPasswordPage() {
    const t = useTranslations("Auth");
    const router = useRouter();
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [status, setStatus] = useState<"idle" | "success">("idle");

    const handleUpdatePassword = async (e: React.FormEvent) => {
        e.preventDefault();
        if (password !== confirmPassword) {
            setError(t("passwordsDoNotMatch") || "Passwords do not match");
            return;
        }

        setIsLoading(true);
        setError(null);

        try {
            const { error } = await supabase.auth.updateUser({
                password: password,
            });
            if (error) throw error;
            setStatus("success");
            setTimeout(() => {
                router.push("/login");
            }, 3000);
        } catch (err: any) {
            setError(err.message);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors flex flex-col">
            <Navbar />
            <main className="flex-1 flex items-center justify-center p-6 py-32">
                <div className="max-w-md w-full bg-white dark:bg-zinc-900 rounded-[3rem] p-12 shadow-2xl border border-stone-100 dark:border-white/5">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                    >
                        <h1 className="text-3xl font-serif text-luxury-black dark:text-white mb-2 text-center">
                            {t("resetPasswordTitle")}
                        </h1>
                        <p className="text-[10px] text-stone-400 font-bold tracking-[.4em] uppercase mb-12 text-center">
                            {t("secureEnvironment")}
                        </p>

                        {status === "success" ? (
                            <div className="text-center space-y-6">
                                <div className="w-20 h-20 bg-accent/10 rounded-full flex items-center justify-center mx-auto">
                                    <Sparkles className="text-accent" size={40} />
                                </div>
                                <h3 className="text-xl font-serif">{t("passwordUpdated")}</h3>
                                <p className="text-xs text-stone-500">
                                    {t("redirectingToLogin")}
                                </p>
                            </div>
                        ) : (
                            <form onSubmit={handleUpdatePassword} className="space-y-6">
                                {error && (
                                    <div className="p-4 bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-500/20 rounded-2xl text-red-500 text-xs font-bold tracking-widest uppercase">
                                        {error}
                                    </div>
                                )}

                                <div className="space-y-2">
                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t("newPassword")}</label>
                                    <div className="relative">
                                        <Lock className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300" size={18} />
                                        <input
                                            type={showPassword ? "text" : "password"}
                                            required
                                            value={password}
                                            onChange={(e) => setPassword(e.target.value)}
                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-14 py-4 outline-none focus:border-accent transition-all text-sm pr-16"
                                            placeholder="••••••••"
                                        />
                                        <button
                                            type="button"
                                            onClick={() => setShowPassword(!showPassword)}
                                            className="absolute right-6 top-1/2 -translate-y-1/2 text-stone-300 hover:text-accent transition-colors"
                                        >
                                            {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                        </button>
                                    </div>
                                </div>

                                <div className="space-y-2">
                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t("confirmNewPassword")}</label>
                                    <div className="relative">
                                        <Lock className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300" size={18} />
                                        <input
                                            type={showConfirmPassword ? "text" : "password"}
                                            required
                                            value={confirmPassword}
                                            onChange={(e) => setConfirmPassword(e.target.value)}
                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-14 py-4 outline-none focus:border-accent transition-all text-sm pr-16"
                                            placeholder="••••••••"
                                        />
                                        <button
                                            type="button"
                                            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                                            className="absolute right-6 top-1/2 -translate-y-1/2 text-stone-300 hover:text-accent transition-colors"
                                        >
                                            {showConfirmPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                        </button>
                                    </div>
                                </div>

                                <button
                                    type="submit"
                                    disabled={isLoading}
                                    className="w-full py-5 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all flex items-center justify-center gap-4 group disabled:opacity-50"
                                >
                                    {isLoading ? t("processing") : t("updatePassword")}
                                    {!isLoading && <ArrowRight size={16} className="group-hover:translate-x-2 transition-transform" />}
                                </button>
                            </form>
                        )}
                    </motion.div>
                </div>
            </main>
        </div>
    );
}
