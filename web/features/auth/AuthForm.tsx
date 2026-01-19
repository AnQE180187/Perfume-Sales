"use client";

import React, { useState } from "react";
import { useParams } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowRight, Mail, Lock, User, Sparkles, Facebook, Globe, Eye, EyeOff } from "lucide-react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { useTranslations } from "next-intl";
import { supabase } from "@/lib/supabase";

interface AuthFormProps {
    defaultMode?: "login" | "signup";
    hideModeToggle?: boolean;
}

export const AuthForm = ({ defaultMode = "login", hideModeToggle = false }: AuthFormProps) => {
    console.log("AuthForm Component Mounted, Mode:", defaultMode); // Debug: Check if component loads
    const t = useTranslations("Auth");
    const { locale } = useParams();
    const [mode, setMode] = useState<"login" | "signup">(defaultMode);
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [termsAccepted, setTermsAccepted] = useState(false);

    // Form states
    const [formData, setFormData] = useState({
        email: "",
        password: "",
        confirmPassword: "",
        full_name: "",
        phone: ""
    });

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        // Validate terms for signup
        if (mode === "signup") {
            if (!termsAccepted) {
                setError(t("errorTermsRequired") || "You must accept the terms and conditions");
                return;
            }
            if (formData.password !== formData.confirmPassword) {
                setError(t("passwordsDoNotMatch") || "Passwords do not match");
                return;
            }
        }

        setIsLoading(true);
        setError(null);


        const endpoint = mode === "login" ? "/api/auth/login" : "/api/auth/register";

        try {
            const response = await fetch(endpoint, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(formData),
            });

            const result = await response.json();

            if (!response.ok) {
                throw new Error(result.error || "Something went wrong");
            }

            if (mode === "signup") {
                alert(t("confirmEmailAlert") || "Registration successful! Please check your email.");
                setMode("login");
            } else {
                // Login success - update global Supabase state
                if (result.session) {
                    const { error: sessionError } = await supabase.auth.setSession({
                        access_token: result.session.access_token,
                        refresh_token: result.session.refresh_token,
                    });
                    if (sessionError) throw sessionError;
                }

                // Redirect or update global state
                window.location.href = `/${locale}`;
            }
        } catch (err: any) {
            setError(err.message);
        } finally {
            setIsLoading(false);
        }
    };

    const handleGoogleLogin = async () => {
        setIsLoading(true);
        setError(null);
        try {
            // If we are currently on an auth page, redirect to home after login
            const currentPath = window.location.pathname;
            const nextParam = (currentPath.includes("/auth") || currentPath.includes("/login") || currentPath.includes("/register"))
                ? "/"
                : currentPath;

            const { error } = await supabase.auth.signInWithOAuth({
                provider: "google",
                options: {
                    redirectTo: `${window.location.origin}/${locale}/auth/callback?next=${nextParam}`,
                },
            });
            if (error) throw error;
        } catch (err: any) {
            setError(err.message);
            setIsLoading(false);
        }
    };

    const handleFacebookLogin = async () => {
        setIsLoading(true);
        setError(null);
        try {
            const currentPath = window.location.pathname;
            const nextParam = (currentPath.includes("/auth") || currentPath.includes("/login") || currentPath.includes("/register"))
                ? "/"
                : currentPath;

            const { error } = await supabase.auth.signInWithOAuth({
                provider: "facebook",
                options: {
                    redirectTo: `${window.location.origin}/${locale}/auth/callback?next=${nextParam}`,
                },
            });
            if (error) throw error;
        } catch (err: any) {
            setError(err.message);
            setIsLoading(false);
        }
    };



    return (
        <div className="max-w-6xl w-full grid md:grid-cols-2 gap-12 bg-white dark:bg-zinc-900 rounded-[4rem] overflow-hidden shadow-2xl border border-stone-100 dark:border-white/5 transition-colors">
            {/* Visual Side */}
            <div className="relative hidden md:block overflow-hidden min-h-[600px]">
                <Image
                    src="/images/collection-banner.png"
                    alt="Luxury Scent"
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
                            <ArrowRight size={24} />
                            <span className="text-[10px] font-bold tracking-[.4em] uppercase">{t("privateAccess")}</span>
                        </div>
                        <h2 className="text-5xl font-serif text-white mb-6 leading-tight italic">{t("enterHouse")}</h2>
                        <p className="text-stone-300 text-sm font-light leading-relaxed max-w-sm">
                            {t("authDesc")}
                        </p>
                    </motion.div>
                </div>
            </div>

            {/* Form Side */}
            <form onSubmit={handleSubmit} className="p-12 md:p-20 flex flex-col justify-center">
                <AnimatePresence mode="wait">
                    <motion.div
                        key={mode}
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -20 }}
                        transition={{ duration: 0.5 }}
                    >
                        <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">
                            {mode === "login" ? t("welcomeBack") : t("joinHouse")}
                        </h1>
                        <p className="text-[10px] text-stone-400 font-bold tracking-[.4em] uppercase mb-8">
                            {mode === "login" ? t("loginProtocol") : t("signupProtocol")}
                        </p>

                        {error && (
                            <div className="mb-6 p-4 bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-500/20 rounded-2xl text-red-500 text-xs font-bold tracking-widest uppercase">
                                {error}
                            </div>
                        )}

                        <div className="space-y-6 mb-10">
                            {mode === "signup" && (
                                <div className="space-y-2">
                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t("fullName")}</label>
                                    <div className="relative">
                                        <User className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300" size={18} />
                                        <input
                                            name="full_name"
                                            value={formData.full_name}
                                            onChange={handleInputChange}
                                            type="text"
                                            required
                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-14 py-4 outline-none focus:border-accent transition-all text-sm"
                                            placeholder="Alexander Dupont"
                                        />
                                    </div>
                                </div>
                            )}
                            <div className="space-y-2">
                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t("email")}</label>
                                <div className="relative">
                                    <Mail className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300" size={18} />
                                    <input
                                        name="email"
                                        value={formData.email}
                                        onChange={handleInputChange}
                                        type="email"
                                        required
                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-14 py-4 outline-none focus:border-accent transition-all text-sm"
                                        placeholder="alexander@lumina.com"
                                    />
                                </div>
                            </div>
                            <div className="space-y-2">
                                <div className="flex justify-between items-center pl-2">
                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("password")}</label>
                                    {mode === "login" && (
                                        <Link
                                            href="/forgot-password"
                                            className="text-[9px] font-bold tracking-widest uppercase text-stone-500 hover:text-accent transition-colors cursor-pointer"
                                        >
                                            {t("forgotPassword")}
                                        </Link>
                                    )}
                                </div>
                                <div className="relative">
                                    <Lock className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300 transition-colors" size={18} />
                                    <input
                                        name="password"
                                        value={formData.password}
                                        onChange={handleInputChange}
                                        type={showPassword ? "text" : "password"}
                                        required
                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-14 py-4 outline-none focus:border-accent transition-all text-sm pr-16"
                                        placeholder="••••••••"
                                    />
                                    <button
                                        type="button"
                                        onClick={() => setShowPassword(!showPassword)}
                                        className="absolute right-6 top-1/2 -translate-y-1/2 text-stone-300 hover:text-accent transition-colors cursor-pointer"
                                    >
                                        {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                    </button>
                                </div>
                            </div>

                            {mode === "signup" && (
                                <div className="space-y-2">
                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t("confirmNewPassword")}</label>
                                    <div className="relative">
                                        <Lock className="absolute left-6 top-1/2 -translate-y-1/2 text-stone-300 transition-colors" size={18} />
                                        <input
                                            name="confirmPassword"
                                            value={formData.confirmPassword}
                                            onChange={handleInputChange}
                                            type={showConfirmPassword ? "text" : "password"}
                                            required
                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-14 py-4 outline-none focus:border-accent transition-all text-sm pr-16"
                                            placeholder="••••••••"
                                        />
                                        <button
                                            type="button"
                                            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                                            className="absolute right-6 top-1/2 -translate-y-1/2 text-stone-300 hover:text-accent transition-colors cursor-pointer"
                                        >
                                            {showConfirmPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                        </button>
                                    </div>
                                </div>
                            )}

                            {mode === "signup" && (
                                <motion.div
                                    initial={{ opacity: 0, y: 10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    className="flex items-start gap-4 p-2"
                                >
                                    <div className="relative flex items-center mt-1">
                                        <input
                                            type="checkbox"
                                            id="terms"
                                            checked={termsAccepted}
                                            onChange={(e) => setTermsAccepted(e.target.checked)}
                                            className="peer h-4 w-4 rounded border-stone-200 dark:border-white/10 text-accent focus:ring-accent bg-transparent transition-all cursor-pointer"
                                        />
                                    </div>
                                    <label htmlFor="terms" className="text-[9px] text-stone-400 font-bold tracking-widest uppercase leading-[1.6] cursor-pointer select-none">
                                        {t("termsPart1")}<span className="text-luxury-black dark:text-white underline hover:text-accent transition-colors italic">{t("termsPart2")}</span>{t("termsPart3")}<span className="text-luxury-black dark:text-white underline hover:text-accent transition-colors italic">{t("termsPart4")}</span>.
                                    </label>
                                </motion.div>
                            )}
                        </div>

                        <button
                            type="submit"
                            disabled={isLoading}
                            className="w-full py-5 bg-luxury-black dark:bg-accent text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all flex items-center justify-center gap-4 group mb-10 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {isLoading ? t("processing") || "PROCESSING..." : (mode === "login" ? t("authorize") : t("registerDna"))}
                            {!isLoading && <ArrowRight size={16} className="group-hover:translate-x-2 transition-transform" />}
                        </button>

                        <div className="space-y-8">
                            <div className="relative">
                                <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-stone-100 dark:border-white/5" /></div>
                                <div className="relative flex justify-center"><span className="bg-white dark:bg-zinc-900 px-4 text-[10px] font-bold text-stone-300 uppercase tracking-widest">{t("orContinue")}</span></div>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <button
                                    type="button"
                                    onClick={handleGoogleLogin}
                                    disabled={isLoading}
                                    className="flex items-center justify-center gap-3 py-4 border border-stone-100 dark:border-white/10 rounded-2xl hover:bg-stone-50 dark:hover:bg-white/5 transition-all cursor-pointer disabled:opacity-50"
                                >
                                    <Globe size={18} className="text-stone-400" />
                                    <span className="text-[10px] font-bold tracking-widest uppercase text-stone-500">Google SSO</span>
                                </button>
                                <button
                                    type="button"
                                    onClick={handleFacebookLogin}
                                    disabled={isLoading}
                                    className="flex items-center justify-center gap-3 py-4 border border-stone-100 dark:border-white/10 rounded-2xl hover:bg-stone-50 dark:hover:bg-white/5 transition-all cursor-pointer disabled:opacity-50"
                                >
                                    <Facebook size={18} className="text-stone-400" />
                                    <span className="text-[10px] font-bold tracking-widest uppercase text-stone-500">Facebook SSO</span>
                                </button>
                            </div>
                        </div>

                        {!hideModeToggle && (
                            <div className="mt-12 pt-8 border-t border-stone-100 dark:border-white/5 text-center">
                                <button
                                    type="button"
                                    onClick={() => setMode(mode === "login" ? "signup" : "login")}
                                    className="text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-accent transition-colors cursor-pointer"
                                >
                                    {mode === "login" ? t("noAccount") : t("hasAccount")}
                                </button>
                            </div>
                        )}
                    </motion.div>
                </AnimatePresence>
            </form>
        </div >
    );
};
