'use client';

import { useState, useEffect } from 'react';
import { useTranslations } from 'next-intl';
import {
    ShoppingBag,
    Search,
    Menu,
    X,
    ChevronRight,
    User,
    LogOut,
    Globe
} from 'lucide-react';
import { Link, usePathname } from '@/lib/i18n';
import { ThemeToggle } from './theme-toggle';
import { LanguageSwitch } from './language-switch';
import { cn } from '@/lib/utils';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '@/hooks/use-auth';

export const Header = () => {
    const t = useTranslations('common');
    const [isScrolled, setIsScrolled] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
    const { isAuthenticated, user, logout } = useAuth();
    const pathname = usePathname();

    // Mock cart count - in real app would come from a cart context
    const cartCount = 2;

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 50);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const menuItems = [
        { name: 'Products', href: '/products' },
        { name: 'Consultation', href: '/customer/consultation' },
        { name: 'Journal', href: '/journal' },
        { name: 'Subscription', href: '/customer/subscription' },
        { name: 'Boutiques', href: '/boutiques' },
    ];

    const role = user?.role || 'customer';

    return (
        <>
            <nav
                className={cn(
                    "fixed top-0 left-0 right-0 z-50 transition-all duration-700",
                    isScrolled
                        ? "py-4 bg-white/80 dark:bg-zinc-950/80 backdrop-blur-xl border-b border-stone-100 dark:border-white/5 shadow-sm"
                        : "py-8 bg-transparent"
                )}
            >
                <div className="container mx-auto px-6">
                    <div className="flex items-center justify-between">
                        {/* Logo */}
                        <Link href="/" className="relative z-50 group">
                            <h1 className="text-2xl md:text-3xl font-serif tracking-[0.3em] font-bold text-luxury-black dark:text-white transition-colors">
                                AURA
                            </h1>
                            <div className={cn(
                                "absolute -bottom-1 left-0 w-0 h-px bg-gold group-hover:w-full transition-all duration-500",
                                pathname === '/' && "w-full"
                            )} />
                        </Link>

                        {/* Desktop Menu */}
                        <div className="hidden lg:flex items-center gap-10">
                            {menuItems.map((item) => (
                                <Link
                                    key={item.name}
                                    href={item.href}
                                    className={cn(
                                        "text-[10px] font-bold tracking-[.3em] uppercase transition-all cursor-pointer relative group",
                                        pathname === item.href
                                            ? "text-gold"
                                            : "text-luxury-black dark:text-white hover:text-gold"
                                    )}
                                >
                                    {item.name}
                                    <span className={cn(
                                        "absolute -bottom-1 left-0 h-px bg-gold transition-all duration-500",
                                        pathname === item.href ? "w-full" : "w-0 group-hover:w-full"
                                    )} />
                                </Link>
                            ))}
                        </div>

                        {/* Actions */}
                        <div className="flex items-center gap-2 md:gap-4">
                            <div className="flex items-center gap-1 md:gap-2">
                                <Link
                                    href="/search"
                                    className="p-2 text-luxury-black dark:text-white hover:text-gold transition-colors cursor-pointer"
                                >
                                    <Search size={20} strokeWidth={1.5} />
                                </Link>

                                <ThemeToggle />
                                <LanguageSwitch />

                                <Link
                                    href="/cart"
                                    className="p-2 text-luxury-black dark:text-white hover:text-gold transition-colors relative cursor-pointer"
                                >
                                    <ShoppingBag size={20} strokeWidth={1.5} />
                                    {cartCount > 0 && (
                                        <motion.span
                                            initial={{ scale: 0 }}
                                            animate={{ scale: 1 }}
                                            className="absolute top-0 right-0 w-4 h-4 bg-gold text-white text-[8px] flex items-center justify-center rounded-full shadow-lg font-bold"
                                        >
                                            {cartCount}
                                        </motion.span>
                                    )}
                                </Link>

                                {isAuthenticated ? (
                                    <div className="flex items-center gap-2 md:gap-4 pl-2 md:pl-4 border-l border-stone-100 dark:border-white/10 transition-colors ml-2">
                                        <Link
                                            href={`/${role}/profile`}
                                            className="hidden md:flex flex-col items-end group"
                                        >
                                            <span className="text-[9px] font-bold text-luxury-black dark:text-white uppercase tracking-widest">
                                                {user?.name?.split(' ')[0] || 'Member'}
                                            </span>
                                            <span className="text-[8px] text-gold font-bold uppercase tracking-tighter opacity-0 group-hover:opacity-100 transition-opacity">
                                                View Profile
                                            </span>
                                        </Link>
                                        <button
                                            onClick={() => logout()}
                                            className="p-2 text-stone-400 hover:text-red-500 transition-colors cursor-pointer"
                                            title="Sign Out"
                                        >
                                            <LogOut size={18} strokeWidth={1.5} />
                                        </button>
                                    </div>
                                ) : (
                                    <Link
                                        href="/login"
                                        className="ml-2 md:ml-4 px-4 md:px-6 py-2 md:py-2.5 border border-stone-200 dark:border-white/10 rounded-full text-[9px] font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white hover:bg-luxury-black hover:text-white dark:hover:bg-white dark:hover:text-black transition-all shadow-sm"
                                    >
                                        Login
                                    </Link>
                                )}

                                <button
                                    className="lg:hidden p-2 text-luxury-black dark:text-white cursor-pointer ml-2"
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
                                    className="text-xs font-bold tracking-[.3em] uppercase text-luxury-black dark:text-white hover:text-gold transition-colors flex items-center justify-between group"
                                    onClick={() => setIsMobileMenuOpen(false)}
                                >
                                    {item.name}
                                    <ChevronRight size={14} className="opacity-0 group-hover:opacity-100 transition-all -translate-x-2 group-hover:translate-x-0" />
                                </Link>
                            ))}
                            {!isAuthenticated && (
                                <Link
                                    href="/login"
                                    className="mt-4 px-8 py-4 bg-luxury-black dark:bg-gold text-white rounded-full text-[10px] font-bold tracking-widest uppercase text-center shadow-xl"
                                    onClick={() => setIsMobileMenuOpen(false)}
                                >
                                    Login / Register
                                </Link>
                            )}
                            {isAuthenticated && (
                                <>
                                    <Link
                                        href={`/${role}/profile`}
                                        className="text-xs font-bold tracking-[.3em] uppercase text-luxury-black dark:text-white hover:text-gold transition-colors flex items-center justify-between group pt-4 border-t border-stone-100 dark:border-white/10"
                                        onClick={() => setIsMobileMenuOpen(false)}
                                    >
                                        {user?.name || 'My Profile'}
                                        <ChevronRight size={14} />
                                    </Link>
                                    <button
                                        onClick={() => {
                                            logout();
                                            setIsMobileMenuOpen(false);
                                        }}
                                        className="text-xs font-bold tracking-[.3em] uppercase text-red-500 hover:text-red-600 transition-colors flex items-center justify-between group"
                                    >
                                        Sign Out
                                        <LogOut size={14} />
                                    </button>
                                </>
                            )}
                        </motion.div>
                    )}
                </AnimatePresence>
            </nav>
        </>
    );
};
