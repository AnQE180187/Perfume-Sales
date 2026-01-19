"use client";

import React, { useState } from "react";
import Image from "next/image";
import { motion, AnimatePresence } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import {
    Sparkles,
    History,
    ShoppingBag,
    Settings,
    Award,
    MapPin,
    Edit2,
    Camera,
    Crown,
    Star,
    TrendingUp,
    Heart,
    ChevronRight,
    Zap,
    Briefcase,
    Sun,
    Moon
} from "lucide-react";
import { useAuth } from "@/features/auth/AuthContext";
import { useTranslations } from "next-intl";
import { Link } from "@/i18n/routing";

export default function ProfilePage() {
    const { user, profile, isLoading, refreshProfile } = useAuth();
    const t = useTranslations("Profile");
    const [activeTab, setActiveTab] = useState("dna");
    const [orders, setOrders] = useState<any[]>([]);
    const [isLoadingOrders, setIsLoadingOrders] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [uploading, setUploading] = useState(false);
    const [msg, setMsg] = useState<{ type: "success" | "error", text: string } | null>(null);

    const [editData, setEditData] = useState({
        full_name: "",
        phone: "",
        scent_preferences: {
            families: [] as string[],
            notes: [] as string[],
            disliked_notes: [] as string[],
            intensity: "moderate"
        },
        budget_range: {
            min: 500000,
            max: 2000000
        },
        style_preferences: [] as string[]
    });

    const fileInputRef = React.useRef<HTMLInputElement>(null);

    React.useEffect(() => {
        if (profile) {
            setEditData({
                full_name: profile.full_name || "",
                phone: profile.phone || "",
                scent_preferences: profile.scent_preferences || {
                    families: [],
                    notes: [],
                    disliked_notes: [],
                    intensity: "moderate"
                },
                budget_range: profile.budget_range || {
                    min: 500000,
                    max: 2000000
                },
                style_preferences: profile.style_preferences || []
            });
        }
    }, [profile]);
    React.useEffect(() => {
        if (user && activeTab === "history") {
            const fetchOrders = async () => {
                setIsLoadingOrders(true);
                try {
                    const response = await fetch(`/api/orders?userId=${user.id}`);
                    const data = await response.json();
                    if (Array.isArray(data)) {
                        setOrders(data);
                    }
                } catch (error) {
                    console.error("Error fetching orders:", error);
                } finally {
                    setIsLoadingOrders(false);
                }
            };
            fetchOrders();
        }
    }, [user, activeTab]);

    const handleSaveProfile = async () => {
        if (!user) return;
        setIsSaving(true);
        setMsg(null);
        try {
            const response = await fetch("/api/profile", {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    id: user.id,
                    ...editData
                })
            });

            if (!response.ok) throw new Error("Failed to update profile");

            setMsg({ type: "success", text: t("identityUpdated") });
            // Refresh local auth context
            await refreshProfile();
        } catch (error: any) {
            setMsg({ type: "error", text: t("errorUpdating") });
        } finally {
            setIsSaving(false);
        }
    };

    const handleAvatarUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
        try {
            setUploading(true);
            setMsg(null);

            if (!event.target.files || event.target.files.length === 0) {
                throw new Error("You must select an image to upload.");
            }

            const file = event.target.files[0];
            const fileExt = file.name.split(".").pop();
            const filePath = `${user!.id}/${Date.now()}.${fileExt}`;

            const { supabase } = await import("@/lib/supabase");

            // Upload to 'avatars' bucket
            const { error: uploadError } = await supabase.storage
                .from("avatars")
                .upload(filePath, file);

            if (uploadError) throw uploadError;

            // Get public URL
            const { data: { publicUrl } } = supabase.storage
                .from("avatars")
                .getPublicUrl(filePath);

            // Update profile with new avatar URL
            const response = await fetch("/api/profile", {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    id: user!.id,
                    avatar_url: publicUrl
                })
            });

            if (!response.ok) throw new Error("Failed to update profile avatar");

            setMsg({ type: "success", text: t("identityUpdated") });
            // Refreshing profile will sync the UI
            await refreshProfile();
        } catch (error: any) {
            alert(error.message);
        } finally {
            setUploading(false);
        }
    };

    const togglePreference = (type: 'families' | 'notes' | 'disliked_notes', item: string) => {
        setEditData(prev => {
            const current = (prev.scent_preferences as any)[type] || [];
            const updated = current.includes(item)
                ? current.filter((i: string) => i !== item)
                : [...current, item];
            return {
                ...prev,
                scent_preferences: {
                    ...prev.scent_preferences,
                    [type]: updated
                }
            };
        });
    };

    const toggleStyle = (style: string) => {
        setEditData(prev => {
            const current = prev.style_preferences || [];
            const updated = current.includes(style)
                ? current.filter(s => s !== style)
                : [...current, style];
            return { ...prev, style_preferences: updated };
        });
    };

    const SCENT_FAMILIES = ["Floral", "Woody", "Oriental", "Fresh", "Citrus", "Gourmand", "Fougère"];
    const SCENT_NOTES = ["Rose", "Sandalwood", "Vanilla", "Bergamot", "Oud", "Musk", "Jasmine", "Amber"];
    const STYLE_OPTIONS = ["Minimalist", "Elegant", "Classic", "Bold", "Modern", "Vintage", "Natural"];

    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-stone-50 dark:bg-zinc-950">
                <div className="animate-pulse flex flex-col items-center gap-4">
                    <Sparkles className="text-accent animate-spin" size={40} />
                    <span className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-500">{t("decryptingIdent")}</span>
                </div>
            </div>
        );
    }

    if (!user) {
        window.location.href = "/auth";
        return null;
    }

    // Role display mapping
    const getRoleLabel = (roles: string[]) => {
        if (roles?.includes("admin")) return t("roleAdmin");
        if (roles?.includes("staff")) return t("roleStaff");
        return t("roleMember");
    };

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Navbar />

            <main className="container mx-auto px-6 py-32 lg:py-40">
                <div className="max-w-7xl mx-auto">
                    <div className="flex flex-col lg:flex-row gap-16 items-start">
                        {/* Sidebar: Identity Card */}
                        <aside className="w-full lg:w-96 sticky top-32">
                            <div className="bg-white dark:bg-zinc-900 rounded-[4rem] p-12 border border-stone-100 dark:border-white/5 shadow-2xl text-center transition-all">
                                <div className="relative w-40 h-40 mx-auto mb-10">
                                    <div className="w-full h-full rounded-full bg-stone-100 dark:bg-white/5 overflow-hidden relative border-8 border-white dark:border-zinc-900 shadow-2xl transition-all">
                                        <Image
                                            src={profile?.avatar_url || "/images/hero.png"}
                                            alt="Profile"
                                            fill
                                            className="object-cover scale-110"
                                        />
                                    </div>
                                    <button
                                        onClick={() => fileInputRef.current?.click()}
                                        disabled={uploading}
                                        className="absolute bottom-2 right-2 p-3 bg-luxury-black dark:bg-accent text-white rounded-full shadow-xl border-4 border-white dark:border-zinc-900 hover:scale-110 transition-transform disabled:opacity-50"
                                    >
                                        <Camera size={20} className={uploading ? "animate-pulse" : ""} />
                                    </button>
                                    <input
                                        type="file"
                                        ref={fileInputRef}
                                        onChange={handleAvatarUpload}
                                        accept="image/*"
                                        className="hidden"
                                    />
                                </div>

                                <div className="mb-12">
                                    <h1 className="text-3xl font-serif text-luxury-black dark:text-white mb-2 transition-colors italic">
                                        {profile?.full_name || "Anonymous Member"}
                                    </h1>
                                    <div className="flex items-center justify-center gap-3">
                                        <Crown size={14} className="text-accent" />
                                        <span className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-500 italic">
                                            {getRoleLabel(profile?.roles || [])}
                                        </span>
                                    </div>
                                    <p className="text-[9px] text-stone-400 mt-2 tracking-widest uppercase">{user.email}</p>
                                    <div className="mt-4 flex justify-center">
                                        <span className={`text-[8px] font-bold tracking-[.3em] uppercase px-4 py-1.5 rounded-full border ${profile?.account_status === 'active'
                                            ? 'bg-green-500/10 border-green-500/20 text-green-500'
                                            : 'bg-red-500/10 border-red-500/20 text-red-500'
                                            }`}>
                                            {profile?.account_status === 'active' ? t('statusActive') :
                                                profile?.account_status === 'suspended' ? t('statusSuspended') :
                                                    profile?.account_status === 'banned' ? t('statusBanned') : (profile?.account_status || 'Unknown')}
                                        </span>
                                    </div>
                                </div>

                                <nav className="space-y-3">
                                    {[
                                        { id: "dna", icon: Sparkles, label: t("neuralDna") },
                                        { id: "history", icon: History, label: t("acquisitions") },
                                        { id: "vault", icon: Heart, label: t("scentVault") },
                                        { id: "tier", icon: Award, label: t("privileges") },
                                        { id: "settings", icon: Settings, label: t("settings") },
                                    ].map((item) => (
                                        <button
                                            key={item.id}
                                            onClick={() => setActiveTab(item.id)}
                                            className={`w-full flex items-center justify-between px-8 py-5 rounded-[2rem] text-[10px] font-bold tracking-[.2em] uppercase transition-all ${activeTab === item.id
                                                ? "bg-luxury-black dark:bg-accent text-white shadow-2xl shadow-accent/20 translate-x-2"
                                                : "text-stone-400 hover:bg-stone-50 dark:hover:bg-white/5 hover:text-luxury-black dark:hover:text-white"
                                                }`}
                                        >
                                            <div className="flex items-center gap-5">
                                                <item.icon size={18} strokeWidth={activeTab === item.id ? 2 : 1.5} />
                                                {item.label}
                                            </div>
                                            {activeTab === item.id && <ChevronRight size={14} />}
                                        </button>
                                    ))}
                                </nav>

                                <div className="mt-12 pt-10 border-t border-stone-100 dark:border-white/5">
                                    <div className="flex justify-between items-center px-4">
                                        <div className="text-left">
                                            <p className="text-[9px] font-bold text-stone-400 uppercase tracking-widest mb-1">{t("loyaltyPoints")}</p>
                                            <span className="text-2xl font-serif text-luxury-black dark:text-white">
                                                {profile?.loyalty_points || 0}
                                            </span>
                                        </div>
                                        <div className="p-3 bg-accent/10 rounded-2xl">
                                            <TrendingUp size={24} className="text-accent" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        {/* Main Content Area */}
                        <div className="flex-1 w-full space-y-12">
                            <AnimatePresence mode="wait">
                                {activeTab === "dna" && (
                                    <motion.div
                                        key="dna"
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="space-y-12"
                                    >
                                        {/* Scent DNA Master Card */}
                                        <div className="relative rounded-[4rem] overflow-hidden bg-luxury-black p-12 md:p-16 text-white shadow-2xl transition-all">
                                            <div className="absolute top-0 right-0 w-2/3 h-full bg-accent/10 blur-[150px] pointer-events-none" />
                                            <div className="absolute -bottom-20 -left-20 w-1/3 h-full bg-stone-500/5 blur-[100px] pointer-events-none" />

                                            <div className="relative z-10">
                                                {profile?.scent_preferences ? (
                                                    <>
                                                        <div className="flex justify-between items-start mb-16">
                                                            <div className="max-w-xl">
                                                                <div className="flex items-center gap-3 text-accent mb-6">
                                                                    <Sparkles size={20} />
                                                                    <span className="text-[10px] font-bold tracking-[.4em] uppercase italic">{t("syntheticMatch")}</span>
                                                                </div>
                                                                <h2 className="text-5xl md:text-7xl font-serif text-white tracking-tighter italic capitalize">
                                                                    {profile.scent_preferences.environment || "Celestial"} <br />
                                                                    <span className="font-light not-italic text-accent">
                                                                        {profile.scent_preferences.emotion || "Essence"}
                                                                    </span>
                                                                </h2>
                                                            </div>
                                                            <div className="text-right">
                                                                <span className="text-6xl font-serif text-accent">98.4%</span>
                                                                <p className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-500 mt-2">{t("synergy")}</p>
                                                            </div>
                                                        </div>

                                                        <div className="grid grid-cols-1 md:grid-cols-3 gap-12 border-t border-white/10 pt-16 transition-colors">
                                                            {[
                                                                {
                                                                    label: "Vibe",
                                                                    val: profile.scent_preferences.emotion || "Balanced",
                                                                    icon: Moon,
                                                                    level: "95%"
                                                                },
                                                                {
                                                                    label: "Intensity",
                                                                    val: profile.scent_preferences.intensity || "Moderate",
                                                                    icon: Zap,
                                                                    level: profile.scent_preferences.intensity === 'intense' ? "100%" : profile.scent_preferences.intensity === 'balanced' ? "75%" : "40%"
                                                                },
                                                                {
                                                                    label: "Domain",
                                                                    val: profile.scent_preferences.environment || "Global",
                                                                    icon: Briefcase,
                                                                    level: "88%"
                                                                }
                                                            ].map((attr, i) => (
                                                                <div key={i} className="space-y-6">
                                                                    <div className="flex items-center gap-4">
                                                                        <div className="p-3 rounded-2xl bg-white/5 border border-white/10">
                                                                            <attr.icon size={20} className="text-accent" />
                                                                        </div>
                                                                        <div>
                                                                            <p className="text-[9px] font-bold tracking-widest uppercase text-stone-400">{attr.label}</p>
                                                                            <h4 className="text-sm font-medium tracking-wide capitalize">{attr.val}</h4>
                                                                        </div>
                                                                    </div>
                                                                    <div className="h-1 w-full bg-white/5 rounded-full overflow-hidden">
                                                                        <motion.div
                                                                            initial={{ width: 0 }}
                                                                            animate={{ width: attr.level }}
                                                                            transition={{ duration: 1.5, delay: 0.5 + (i * 0.2) }}
                                                                            className="h-full bg-accent"
                                                                        />
                                                                    </div>
                                                                </div>
                                                            ))}
                                                        </div>
                                                    </>
                                                ) : (
                                                    <div className="py-12 text-center space-y-8">
                                                        <div className="w-24 h-24 bg-white/5 rounded-full flex items-center justify-center mx-auto border border-white/10">
                                                            <Sparkles size={40} className="text-accent/30" />
                                                        </div>
                                                        <div>
                                                            <h2 className="text-3xl font-serif mb-4 italic">{t("neuralIdentityPending")}</h2>
                                                            <p className="text-stone-400 text-sm max-w-sm mx-auto font-light leading-relaxed mb-10">
                                                                {t("orderEmpty")}
                                                            </p>
                                                            <Link href="/consultation" className="inline-flex px-10 py-5 bg-accent text-white rounded-full text-[10px] font-bold tracking-[.4em] uppercase hover:bg-yellow-600 transition-all shadow-xl">
                                                                {t("startConsultation")}
                                                            </Link>
                                                        </div>
                                                    </div>
                                                )}
                                            </div>
                                        </div>

                                        {/* Preference Breakdown */}
                                        <div className="grid md:grid-cols-2 gap-10">
                                            <div className="bg-white dark:bg-zinc-900 rounded-[3rem] p-12 border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                                                <h3 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest mb-10 flex items-center gap-4 transition-colors">
                                                    <Briefcase size={20} className="text-accent" /> {t("scentOccasions")}
                                                </h3>
                                                <div className="space-y-8">
                                                    {[
                                                        { label: "Global Boardroom", match: "High Match", p: "88%" },
                                                        { label: "Gala & Black-tie", match: "Primary Usage", p: "100%" },
                                                        { label: "Private Atelier", match: "Comfort Choice", p: "72%" }
                                                    ].map((item, i) => (
                                                        <div key={i} className="flex justify-between items-center group cursor-pointer">
                                                            <div>
                                                                <h5 className="text-[11px] font-bold text-luxury-black dark:text-white uppercase tracking-widest transition-colors">{item.label}</h5>
                                                                <p className="text-[9px] text-stone-400 uppercase tracking-widest mt-1">{item.match}</p>
                                                            </div>
                                                            <span className="text-sm font-serif text-accent">{item.p}</span>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>

                                            <div className="bg-white dark:bg-zinc-900 rounded-[3rem] p-12 border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                                                <h3 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest mb-10 flex items-center gap-4 transition-colors">
                                                    <Heart size={20} className="text-accent" /> Layering Preferences
                                                </h3>
                                                <div className="flex flex-wrap gap-3">
                                                    {["Saffron Base", "Ambergris Overlay", "Vanilla Bourbon", "Smoky Vetiver", "Bergamot Zest", "Iso E Super"].map(note => (
                                                        <span key={note} className="px-5 py-3 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-full text-[10px] font-bold uppercase tracking-widest text-stone-500 hover:text-accent hover:border-accent transition-all cursor-pointer">
                                                            {note}
                                                        </span>
                                                    ))}
                                                </div>
                                            </div>
                                        </div>

                                        {/* Bottom Action */}
                                        <div className="p-12 rounded-[3.5rem] bg-stone-100 dark:bg-white/5 border border-stone-100 dark:border-white/5 flex flex-col md:flex-row items-center justify-between gap-12 transition-colors">
                                            <div className="flex items-center gap-8">
                                                <div className="w-14 h-14 rounded-2xl bg-white dark:bg-zinc-800 flex items-center justify-center text-accent shadow-sm transition-colors">
                                                    <Sparkles size={24} />
                                                </div>
                                                <div>
                                                    <h4 className="text-lg font-serif text-luxury-black dark:text-white transition-colors italic">{t("refreshDna")}</h4>
                                                    <p className="text-[10px] text-stone-400 font-bold tracking-widest uppercase">{t("neuralIdentityPending")}</p>
                                                </div>
                                            </div>
                                            <button className="px-10 py-5 bg-luxury-black dark:bg-accent text-white rounded-full text-[10px] font-bold tracking-[.3em] uppercase shadow-xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all">
                                                {t("retakeConsultation")}
                                            </button>
                                        </div>
                                    </motion.div>
                                )}

                                {activeTab === "history" && (
                                    <motion.div
                                        key="history"
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="space-y-8"
                                    >
                                        <h2 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors">{t("acquisitions")}</h2>

                                        {isLoadingOrders ? (
                                            <div className="py-20 flex flex-col items-center justify-center gap-4 bg-white dark:bg-zinc-900 rounded-[4rem] border border-stone-100 dark:border-white/5">
                                                <div className="w-8 h-8 border-2 border-accent border-t-transparent rounded-full animate-spin" />
                                                <span className="text-[10px] font-bold tracking-[.3em] uppercase text-stone-400">{t("accessingArchives")}</span>
                                            </div>
                                        ) : orders.length > 0 ? (
                                            <div className="space-y-4">
                                                {orders.map((order) => (
                                                    <div key={order.id} className="bg-white dark:bg-zinc-900 p-8 rounded-[3rem] border border-stone-100 dark:border-white/5 flex flex-col md:flex-row justify-between items-center gap-8 group hover:border-accent transition-all duration-500">
                                                        <div className="flex items-center gap-8">
                                                            <div className="w-20 h-20 rounded-3xl bg-stone-50 dark:bg-white/5 flex items-center justify-center relative overflow-hidden border border-stone-100 dark:border-white/10">
                                                                {order.items?.[0]?.variant?.product?.main_image_url ? (
                                                                    <Image
                                                                        src={order.items[0].variant.product.main_image_url}
                                                                        alt="Product"
                                                                        fill
                                                                        className="object-cover transition-transform duration-700 group-hover:scale-110"
                                                                    />
                                                                ) : (
                                                                    <ShoppingBag size={24} className="text-stone-300" />
                                                                )}
                                                            </div>
                                                            <div>
                                                                <h4 className="text-lg font-serif italic text-luxury-black dark:text-white mb-1 group-hover:text-accent transition-colors">
                                                                    {t("orderNo")} #{order.id.split('-')[0].toUpperCase()}
                                                                </h4>
                                                                <p className="text-[9px] font-bold text-stone-400 uppercase tracking-widest">{new Date(order.created_at).toLocaleDateString()}</p>
                                                            </div>
                                                        </div>
                                                        <div className="flex flex-wrap items-center gap-10">
                                                            <div className="text-center md:text-right">
                                                                <p className="text-[9px] font-bold text-stone-400 uppercase tracking-widest mb-1">{t("status")}</p>
                                                                <span className="text-[10px] px-4 py-1.5 rounded-full font-bold uppercase tracking-widest bg-stone-50 dark:bg-white/10 text-luxury-black dark:text-white border border-stone-100 dark:border-white/5">
                                                                    {order.status}
                                                                </span>
                                                            </div>
                                                            <div className="text-center md:text-right min-w-[100px]">
                                                                <p className="text-[9px] font-bold text-stone-400 uppercase tracking-widest mb-1">{t("amount")}</p>
                                                                <span className="text-xl font-serif text-luxury-black dark:text-white">${order.final_amount}</span>
                                                            </div>
                                                            <ChevronRight className="text-stone-300 group-hover:text-accent group-hover:translate-x-2 transition-all" size={20} />
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>
                                        ) : (
                                            <div className="p-24 text-center bg-white dark:bg-zinc-900 rounded-[4rem] border border-stone-100 dark:border-white/5 transition-colors">
                                                <div className="w-16 h-16 bg-stone-50 dark:bg-white/5 rounded-full flex items-center justify-center mx-auto mb-8">
                                                    <ShoppingBag size={24} className="text-stone-300" />
                                                </div>
                                                <h3 className="text-xl font-serif mb-2 italic text-stone-300">{t("noOrders")}</h3>
                                                <p className="text-[10px] uppercase font-bold tracking-[.3em] text-stone-500">{t("orderEmpty")}</p>
                                            </div>
                                        )}
                                    </motion.div>
                                )}

                                {activeTab === "vault" && (
                                    <motion.div
                                        key="vault"
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="space-y-8"
                                    >
                                        <h2 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors">{t("scentVault").split(' ')[0]} <span className="italic">{t("scentVault").split(' ')[1] || "Vault"}</span></h2>
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                                            <div className="p-12 text-center bg-white dark:bg-zinc-900 rounded-[4rem] border border-stone-100 dark:border-white/5 transition-colors flex flex-col items-center justify-center gap-6">
                                                <Heart className="text-stone-200 dark:text-white/5" size={60} />
                                                <div>
                                                    <p className="text-[10px] uppercase font-bold tracking-[.3em] text-stone-500">{t("orderEmpty")}</p>
                                                    <Link href="/collection" className="text-accent text-[10px] font-bold tracking-widest uppercase mt-4 block hover:underline">{t("viewRecommendations")} —</Link>
                                                </div>
                                            </div>
                                            <div className="p-12 bg-accent/5 rounded-[4rem] border border-accent/10 flex flex-col justify-between">
                                                <div className="space-y-4">
                                                    <Sparkles className="text-accent" size={24} />
                                                    <h3 className="text-2xl font-serif italic text-luxury-black dark:text-white">{t("aiSuggestion")}</h3>
                                                    <p className="text-stone-500 text-sm leading-relaxed capitalize">
                                                        Based on your {profile?.scent_preferences?.emotion || "balanced"} essence, we recommend exploring the "Absolute Oud" collection.
                                                    </p>
                                                </div>
                                                <Link href="/collection" className="px-8 py-4 bg-luxury-black dark:bg-accent text-white rounded-full text-[10px] font-bold tracking-widest uppercase text-center mt-8">{t("viewRecommendations")}</Link>
                                            </div>
                                        </div>
                                    </motion.div>
                                )}

                                {activeTab === "tier" && (
                                    <motion.div
                                        key="tier"
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="space-y-12"
                                    >
                                        <h2 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors">{t("membership")} <span className="italic">{t("privileges")}</span></h2>
                                        <div className="bg-luxury-black rounded-[4rem] p-16 text-white relative overflow-hidden">
                                            <div className="absolute top-0 right-0 w-2/3 h-full bg-accent/20 blur-[150px] pointer-events-none" />
                                            <div className="relative z-10 grid md:grid-cols-2 gap-16 items-center">
                                                <div className="space-y-8">
                                                    <div>
                                                        <span className="text-accent text-[10px] font-bold tracking-[.4em] uppercase mb-4 block">{t("currentStatus")}</span>
                                                        <h3 className="text-5xl font-serif italic">{t("membershipSilver")}</h3>
                                                    </div>
                                                    <div className="space-y-4">
                                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest">
                                                            <span>{t("progressTo", { tier: t("membershipGold") })}</span>
                                                            <span className="text-accent">{profile?.loyalty_points || 0} / 1000 PV</span>
                                                        </div>
                                                        <div className="h-1 bg-white/10 rounded-full overflow-hidden">
                                                            <motion.div
                                                                initial={{ width: 0 }}
                                                                animate={{ width: `${Math.min(((profile?.loyalty_points || 0) / 1000) * 100, 100)}%` }}
                                                                className="h-full bg-accent"
                                                            />
                                                        </div>
                                                    </div>
                                                </div>
                                                <div className="grid grid-cols-2 gap-4">
                                                    {[
                                                        { label: t("benefactiveSillage"), status: t("active"), isActive: true },
                                                        { label: t("preAccess"), status: t("goldTier"), isActive: false },
                                                        { label: t("concierge"), status: t("goldTier"), isActive: false },
                                                        { label: t("molecular"), status: t("platinumTier"), isActive: false }
                                                    ].map((benefit, i) => (
                                                        <div key={i} className="p-6 bg-white/5 border border-white/10 rounded-3xl">
                                                            <p className="text-[9px] font-bold tracking-widest uppercase text-stone-400 mb-2">{benefit.label}</p>
                                                            <span className={`text-[10px] font-bold uppercase ${benefit.isActive ? 'text-accent' : 'text-white/20'}`}>{benefit.status}</span>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        </div>
                                    </motion.div>
                                )}

                                {activeTab === "settings" && (
                                    <motion.div
                                        key="settings"
                                        initial={{ opacity: 0, x: 20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -20 }}
                                        className="space-y-12"
                                    >
                                        <h2 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors">Atelier <span className="italic">{t("settings")}</span></h2>
                                        <div className="bg-white dark:bg-zinc-900 rounded-[4rem] p-12 md:p-16 border border-stone-100 dark:border-white/5 shadow-sm space-y-12">
                                            {msg && (
                                                <div className={`p-6 rounded-3xl text-[10px] font-bold tracking-widest uppercase border ${msg.type === "success" ? "bg-green-500/10 border-green-500/20 text-green-500" : "bg-red-500/10 border-red-500/20 text-red-500"}`}>
                                                    {msg.text}
                                                </div>
                                            )}
                                            <div className="grid md:grid-cols-2 gap-10">
                                                <div className="space-y-4">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("fullSignature")}</label>
                                                    <input
                                                        type="text"
                                                        value={editData.full_name}
                                                        onChange={(e) => setEditData({ ...editData, full_name: e.target.value })}
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl py-5 px-8 text-sm outline-none focus:border-accent transition-all"
                                                        placeholder="Your full name"
                                                    />
                                                </div>
                                                <div className="space-y-4">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("commLink")}</label>
                                                    <input
                                                        type="text"
                                                        value={editData.phone}
                                                        onChange={(e) => setEditData({ ...editData, phone: e.target.value })}
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl py-5 px-8 text-sm outline-none focus:border-accent transition-all"
                                                        placeholder="Phone number"
                                                    />
                                                </div>
                                            </div>
                                            <div className="space-y-4">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("electronicMail")}</label>
                                                <div className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl py-5 px-8 text-sm text-stone-400 cursor-not-allowed">
                                                    {user.email}
                                                </div>
                                            </div>

                                            {/* Scent DNA Configuration */}
                                            <div className="pt-10 border-t border-stone-100 dark:border-white/5 space-y-10">
                                                <div className="flex items-center gap-4 text-accent">
                                                    <Sparkles size={20} />
                                                    <h3 className="text-xl font-serif italic text-luxury-black dark:text-white transition-colors">{t("dnaConfig") || "Scent DNA Configuration"}</h3>
                                                </div>

                                                <div className="space-y-6">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("preferredFamilies") || "Preferred Families"}</label>
                                                    <div className="flex flex-wrap gap-2">
                                                        {SCENT_FAMILIES.map(family => (
                                                            <button
                                                                key={family}
                                                                type="button"
                                                                onClick={() => togglePreference('families', family)}
                                                                className={`px-4 py-2 rounded-full text-[10px] font-bold uppercase tracking-widest transition-all border ${editData.scent_preferences.families.includes(family)
                                                                    ? "bg-accent border-accent text-white"
                                                                    : "bg-transparent border-stone-200 dark:border-white/10 text-stone-400 hover:border-accent"
                                                                    }`}
                                                            >
                                                                {family}
                                                            </button>
                                                        ))}
                                                    </div>
                                                </div>

                                                <div className="space-y-6">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("coreNotes") || "Core Notes"}</label>
                                                    <div className="flex flex-wrap gap-2">
                                                        {SCENT_NOTES.map(note => (
                                                            <button
                                                                key={note}
                                                                type="button"
                                                                onClick={() => togglePreference('notes', note)}
                                                                className={`px-4 py-2 rounded-full text-[10px] font-bold uppercase tracking-widest transition-all border ${editData.scent_preferences.notes.includes(note)
                                                                    ? "bg-accent border-accent text-white"
                                                                    : "bg-transparent border-stone-200 dark:border-white/10 text-stone-400 hover:border-accent"
                                                                    }`}
                                                            >
                                                                {note}
                                                            </button>
                                                        ))}
                                                    </div>
                                                </div>

                                                <div className="space-y-6">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("styles") || "Personal Style Preferences"}</label>
                                                    <div className="flex flex-wrap gap-2">
                                                        {STYLE_OPTIONS.map(style => (
                                                            <button
                                                                key={style}
                                                                type="button"
                                                                onClick={() => toggleStyle(style)}
                                                                className={`px-4 py-2 rounded-full text-[10px] font-bold uppercase tracking-widest transition-all border ${editData.style_preferences.includes(style)
                                                                    ? "bg-accent border-accent text-white"
                                                                    : "bg-transparent border-stone-200 dark:border-white/10 text-stone-400 hover:border-accent"
                                                                    }`}
                                                            >
                                                                {style}
                                                            </button>
                                                        ))}
                                                    </div>
                                                </div>

                                                <div className="grid md:grid-cols-2 gap-10">
                                                    <div className="space-y-4">
                                                        <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("budgetMin") || "Budget Minimum (VND)"}</label>
                                                        <input
                                                            type="number"
                                                            value={editData.budget_range.min}
                                                            onChange={(e) => setEditData({ ...editData, budget_range: { ...editData.budget_range, min: parseInt(e.target.value) || 0 } })}
                                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl py-5 px-8 text-sm outline-none focus:border-accent transition-all text-luxury-black dark:text-white"
                                                        />
                                                    </div>
                                                    <div className="space-y-4">
                                                        <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">{t("budgetMax") || "Budget Maximum (VND)"}</label>
                                                        <input
                                                            type="number"
                                                            value={editData.budget_range.max}
                                                            onChange={(e) => setEditData({ ...editData, budget_range: { ...editData.budget_range, max: parseInt(e.target.value) || 0 } })}
                                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl py-5 px-8 text-sm outline-none focus:border-accent transition-all text-luxury-black dark:text-white"
                                                        />
                                                    </div>
                                                </div>
                                            </div>

                                            <button
                                                onClick={handleSaveProfile}
                                                disabled={isSaving}
                                                className="px-12 py-5 bg-luxury-black dark:bg-accent text-white rounded-full text-[10px] font-bold tracking-widest uppercase shadow-xl hover:bg-stone-800 dark:hover:bg-accent/80 transition-all disabled:opacity-50"
                                            >
                                                {isSaving ? t("processing") : t("syncRegistry")}
                                            </button>
                                        </div>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
