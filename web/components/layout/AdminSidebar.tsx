"use client";

import { Link, usePathname } from "@/i18n/routing";
import { motion } from "framer-motion";
import { useTranslations } from "next-intl";
import {
    LayoutDashboard,
    ShoppingBag,
    Users,
    Sparkles,
    Settings,
    LogOut,
    ClipboardList,
    Shield,
    Zap,
    FileText
} from "lucide-react";
import { useAuth } from "@/features/auth/AuthContext";

export function AdminSidebar() {
    const t = useTranslations("Dashboard.sidebar");
    const pathname = usePathname();
    const { signOut } = useAuth();

    const menuItems = [
        { icon: LayoutDashboard, label: t("overview"), href: "/dashboard" },
        { icon: ClipboardList, label: t("orders"), href: "/dashboard/orders" },
        { icon: ShoppingBag, label: t("inventory"), href: "/dashboard/inventory" },
        { icon: Shield, label: t("rbac"), href: "/dashboard/users" },
        { icon: Users, label: t("clients"), href: "/dashboard/clients" },
        { icon: Sparkles, label: t("analytics"), href: "/dashboard/ai-analytics" },
        { icon: Zap, label: t("ops"), href: "/dashboard/ai-ops" },
        { icon: FileText, label: t("content"), href: "/dashboard/content" },
        { icon: Settings, label: t("settings"), href: "/dashboard/settings" },
    ];

    return (
        <aside className="w-64 glass bg-white dark:bg-stone-900/50 m-4 mr-0 rounded-3xl hidden md:flex flex-col p-6 text-stone-900 dark:text-white border border-stone-200 dark:border-none shadow-2xl h-[calc(100vh-2rem)] transition-colors">
            <div className="mb-12 px-2">
                <Link href="/">
                    <h2 className="text-2xl font-serif tracking-widest font-bold text-luxury-black dark:text-white transition-colors">LUMINA</h2>
                </Link>
                <span className="text-[10px] tracking-[0.2em] text-stone-400 dark:text-stone-500 uppercase transition-colors">Management</span>
            </div>

            <nav className="flex-1 space-y-2">
                {menuItems.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                        <Link
                            key={item.label}
                            href={item.href}
                            className={`w-full flex items-center gap-4 px-4 py-3 rounded-xl text-sm transition-all relative group ${isActive
                                ? "bg-luxury-black dark:bg-accent text-white shadow-xl shadow-accent/10"
                                : "text-stone-400 dark:text-stone-500 hover:bg-stone-100 dark:hover:bg-white/5 hover:text-luxury-black dark:hover:text-white"
                                }`}
                        >
                            <item.icon size={18} strokeWidth={isActive ? 2 : 1.5} className={isActive ? "text-accent dark:text-white" : ""} />
                            <span className={isActive ? "font-bold tracking-wide" : ""}>{item.label}</span>
                            {isActive && (
                                <motion.div
                                    layoutId="active-pill"
                                    className="absolute left-0 w-1 h-6 bg-accent rounded-r-full"
                                />
                            )}
                        </Link>
                    );
                })}
            </nav>

            <div className="pt-6 border-t border-stone-100 dark:border-white/10">
                <button
                    onClick={() => signOut()}
                    className="flex items-center gap-4 px-4 py-3 text-sm text-stone-400 hover:text-red-400 transition-colors w-full group cursor-pointer"
                >
                    <LogOut size={18} className="group-hover:rotate-12 transition-transform" />
                    {t("logout")}
                </button>
            </div>
        </aside>
    );
}
