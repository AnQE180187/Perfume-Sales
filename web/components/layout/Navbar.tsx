"use client";

import React, { useState, useEffect } from "react";
import { Link } from "@/i18n/routing";
import { usePathname } from "@/i18n/routing";
import {
    ShoppingBag,
    Search,
    Menu,
    X,
    ChevronRight,
    User,
    LogOut,
    Heart,
    Globe,
    Monitor
} from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { ThemeToggle } from "@/components/common/ThemeToggle";
import { CartDrawer } from "@/components/layout/CartDrawer";
import { SearchOverlay } from "@/components/layout/SearchOverlay";
import { useCart } from "@/features/cart/CartContext";
import { useAuth } from "@/features/auth/AuthContext";
import { useTranslations } from "next-intl";

export const Navbar = () => {
    const t = useTranslations("Navbar");
    const { cartCount } = useCart();
    const { user, profile, signOut } = useAuth();

    const menuItems = [
        { name: t("collection"), href: "/collection" },
        { name: t("consultation"), href: "/consultation" },
        { name: t("journal"), href: "/journal" },
        { name: t("subscription"), href: "/subscription" },
        { name: t("boutiques"), href: "/boutiques" },
    ];

    const [isScrolled, setIsScrolled] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
    const [isCartOpen, setIsCartOpen] = useState(false);
    const [isSearchOpen, setIsSearchOpen] = useState(false);
    const pathname = usePathname();

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 50);
        };
        window.addEventListener("scroll", handleScroll);
        return () => window.removeEventListener("scroll", handleScroll);
    }, []);

    return (
        <>
            <nav
                className={`fixed top-0 left-0 right-0 z-50 transition-all duration-700 ${isScrolled
                    ? "py-4 bg-white/80 dark:bg-zinc-950/80 backdrop-blur-xl border-b border-stone-100 dark:border-white/5 shadow-sm"
                    : "py-8 bg-transparent"
                    }`}
            >
                <div className="container mx-auto px-6">
                    <div className="flex items-center justify-between">
                        {/* Logo */}
                        <Link href="/" className="relative z-50 group">
                            <h1 className="text-2xl md:text-3xl font-serif tracking-[0.3em] font-bold text-luxury-black dark:text-white transition-colors">
                                LUMINA
                            </h1>
                            <div className="absolute -bottom-1 left-0 w-0 h-px bg-accent group-hover:w-full transition-all duration-500" />
                        </Link>

                        {/* Desktop Menu */}
                        <div className="hidden lg:flex items-center gap-10">
                            {menuItems.map((item) => (
                                <Link
                                    key={item.name}
                                    href={item.href}
                                    className={`text-[10px] font-bold tracking-[.3em] uppercase transition-all cursor-pointer relative group ${pathname === item.href ? "text-accent" : "text-luxury-black dark:text-white hover:text-accent"
                                        }`}
                                >
                                    {item.name}
                                    <span className={`absolute -bottom-1 left-0 h-px bg-accent transition-all duration-500 ${pathname === item.href ? "w-full" : "w-0 group-hover:w-full"}`} />
                                </Link>
                            ))}
                        </div>

                        {/* Actions */}
                        <div className="flex items-center gap-4 md:gap-8">
                            <div className="flex items-center gap-3">
                                <button
                                    onClick={() => setIsSearchOpen(true)}
                                    className="p-2 text-luxury-black dark:text-white hover:text-accent transition-colors cursor-pointer"
                                >
                                    <Search size={20} strokeWidth={1.5} />
                                </button>
                                <ThemeToggle />
                                <button
                                    onClick={() => setIsCartOpen(true)}
                                    className="p-2 text-luxury-black dark:text-white hover:text-accent transition-colors relative cursor-pointer"
                                >
                                    <ShoppingBag size={20} strokeWidth={1.5} />
                                    {cartCount > 0 && (
                                        <motion.span
                                            initial={{ scale: 0 }}
                                            animate={{ scale: 1 }}
                                            className="absolute top-0 right-0 w-4 h-4 bg-accent text-white text-[8px] flex items-center justify-center rounded-full shadow-lg"
                                        >
                                            {cartCount}
                                        </motion.span>
                                    )}
                                </button>
                                {user ? (
                                    <div className="flex items-center gap-4 pl-4 border-l border-stone-100 dark:border-white/10 transition-colors">
                                        {(profile?.roles?.includes('admin') || profile?.roles?.includes('staff')) && (
                                            <Link
                                                href="/dashboard"
                                                className="hidden xl:block text-[9px] font-bold text-accent uppercase tracking-widest hover:underline"
                                            >
                                                {t("dashboard")}
                                            </Link>
                                        )}
                                        <Link
                                            href="/profile"
                                            className="hidden md:flex flex-col items-end group"
                                        >
                                            <span className="text-[9px] font-bold text-luxury-black dark:text-white uppercase tracking-widest">{profile?.full_name?.split(' ')[0] || 'Member'}</span>
                                            <span className="text-[8px] text-accent font-bold uppercase tracking-tighter opacity-0 group-hover:opacity-100 transition-opacity">View Profile</span>
                                        </Link>
                                        <button
                                            onClick={() => signOut()}
                                            className="p-2 text-stone-400 hover:text-red-500 transition-colors cursor-pointer"
                                            title={t("signOut")}
                                        >
                                            <LogOut size={18} strokeWidth={1.5} />
                                        </button>
                                    </div>
                                ) : (
                                    <Link
                                        href="/auth"
                                        className="ml-4 px-6 py-2.5 border border-stone-200 dark:border-white/10 rounded-full text-[9px] font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white hover:bg-luxury-black hover:text-white dark:hover:bg-white dark:hover:text-black transition-all shadow-sm"
                                    >
                                        {t("login")}
                                    </Link>
                                )}
                                <button
                                    className="lg:hidden p-2 text-luxury-black dark:text-white cursor-pointer"
                                    onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                                >
                                    {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Mobile Menu */}
                <AnimatePresence>
                    {isMobileMenuOpen && (
                        <motion.div
                            initial={{ opacity: 0, y: -20 }}
                            animate={{ opacity: 1, y: 0 }}
                            exit={{ opacity: 0, y: -20 }}
                            className="absolute top-full left-0 right-0 bg-white dark:bg-zinc-950 border-b border-stone-100 dark:border-white/10 p-8 flex flex-col gap-6 lg:hidden shadow-2xl transition-colors"
                        >
                            {menuItems.map((item) => (
                                <Link
                                    key={item.name}
                                    href={item.href}
                                    className="text-xs font-bold tracking-[.3em] uppercase text-luxury-black dark:text-white hover:text-accent transition-colors flex items-center justify-between group"
                                    onClick={() => setIsMobileMenuOpen(false)}
                                >
                                    {item.name}
                                    <ChevronRight size={14} className="opacity-0 group-hover:opacity-100 transition-all -translate-x-2 group-hover:translate-x-0" />
                                </Link>
                            ))}
                            {!user && (
                                <Link
                                    href="/auth"
                                    className="mt-4 px-8 py-4 bg-luxury-black dark:bg-accent text-white rounded-full text-[10px] font-bold tracking-widest uppercase text-center shadow-xl"
                                    onClick={() => setIsMobileMenuOpen(false)}
                                >
                                    {t("login")}
                                </Link>
                            )}
                            {user && (
                                <>
                                    <Link
                                        href="/profile"
                                        className="text-xs font-bold tracking-[.3em] uppercase text-luxury-black dark:text-white hover:text-accent transition-colors flex items-center justify-between group pt-4 border-t border-stone-100 dark:border-white/10"
                                        onClick={() => setIsMobileMenuOpen(false)}
                                    >
                                        {profile?.full_name || t("profile")}
                                        <ChevronRight size={14} />
                                    </Link>
                                    <button
                                        onClick={() => {
                                            signOut();
                                            setIsMobileMenuOpen(false);
                                        }}
                                        className="text-xs font-bold tracking-[.3em] uppercase text-red-500 hover:text-red-600 transition-colors flex items-center justify-between group"
                                    >
                                        {t("signOut")}
                                        <LogOut size={14} />
                                    </button>
                                </>
                            )}
                        </motion.div>
                    )}
                </AnimatePresence>
            </nav>

            {/* Cart Drawer */}
            <CartDrawer isOpen={isCartOpen} onClose={() => setIsCartOpen(false)} />

            {/* Search Overlay */}
            <SearchOverlay isOpen={isSearchOpen} onClose={() => setIsSearchOpen(false)} />
        </>
    );
};
