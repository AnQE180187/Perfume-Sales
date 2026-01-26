'use client';

import { useTranslations } from 'next-intl';
import {
    LayoutDashboard, Users, User, Settings, LogOut, Package,
    MessageSquare, BrainCircuit, Heart, History, Coins, Tag,
    Monitor, Box, ClipboardList, BarChart3, ShieldCheck,
    Globe, Mail, FileText, Settings2, Smartphone, Receipt, FolderTree
} from 'lucide-react';
import { Link, usePathname } from '@/lib/i18n';
import { useAuth } from '@/hooks/use-auth';
import { cn } from '@/lib/utils';
import { motion } from 'framer-motion';
import { ThemeToggle } from './theme-toggle';
import { LanguageSwitch } from './language-switch';

export const Sidebar = () => {
    const commonT = useTranslations('common');
    const navT = useTranslations('navigation');
    const { user, logout } = useAuth();
    const pathname = usePathname();

    const role = user?.role || 'customer';

    const getMenuItems = () => {
        const publicPages = [
            { icon: Globe, label: commonT('home'), href: '/' },
            { icon: Package, label: commonT('collection'), href: '/collection' },
        ];

        const shared = [
            { icon: LayoutDashboard, label: commonT('dashboard'), href: `/dashboard/${role.toLowerCase()}` },
            { icon: User, label: commonT('profile'), href: '/dashboard/profile' },
        ];

        const customer = [
            { icon: MessageSquare, label: navT('customer.ai_chat'), href: '/dashboard/customer/ai-chat' },
            { icon: BrainCircuit, label: navT('customer.quiz'), href: '/dashboard/customer/quiz' },
            { icon: Heart, label: commonT('favorites'), href: '/favorite' },
            { icon: ClipboardList, label: commonT('orders'), href: '/dashboard/customer/orders' },
            { icon: Coins, label: navT('customer.loyalty'), href: '/dashboard/customer/loyalty' },
            { icon: Tag, label: navT('customer.promotions'), href: '/dashboard/customer/promotions' },
        ];

        const staff = [
            { icon: Smartphone, label: navT('staff.pos'), href: '/dashboard/staff/pos' },
            { icon: Box, label: navT('staff.inventory'), href: '/dashboard/staff/inventory' },
            { icon: ClipboardList, label: navT('staff.orders'), href: '/dashboard/staff/orders' },
            { icon: BarChart3, label: navT('staff.kpi'), href: '/dashboard/staff/kpi' },
        ];

        const admin = [
            { icon: Users, label: navT('admin.users'), href: '/dashboard/admin/users' },
            { icon: ShieldCheck, label: navT('admin.rbac'), href: '/dashboard/admin/rbac' },
            { icon: Package, label: navT('admin.products'), href: '/dashboard/admin/products' },
            { icon: FolderTree, label: 'Catalog', href: '/dashboard/admin/catalog' },
            { icon: Receipt, label: commonT('orders'), href: '/dashboard/admin/orders' },
            { icon: BarChart3, label: navT('admin.analytics'), href: '/dashboard/admin/analytics' },
            { icon: Mail, label: navT('admin.marketing'), href: '/dashboard/admin/marketing' },
            { icon: Settings2, label: commonT('settings'), href: '/dashboard/admin/settings' },
        ];

        if (role === 'ADMIN') return [...publicPages, ...shared, ...admin];
        if (role === 'STAFF') return [...publicPages, ...shared, ...staff];
        return [...publicPages, ...shared, ...customer];
    };

    const items = getMenuItems();

    return (
        <aside className="w-72 h-screen glass border-r border-border flex flex-col p-6 sticky top-0 overflow-y-auto custom-scrollbar">
            <div className="flex items-center gap-3 mb-12 px-2">
                <div className="w-8 h-8 rounded-lg bg-gold flex items-center justify-center">
                    <BrainCircuit className="text-primary w-5 h-5" />
                </div>
                <span className="font-heading text-xl gold-gradient tracking-widest uppercase">Aura AI</span>
            </div>

            <nav className="flex-1 space-y-1">
                {items.map((item, index) => {
                    const isActive = pathname === item.href || pathname.startsWith(item.href + '/');
                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={cn(
                                "group flex items-center gap-4 px-4 py-3.5 rounded-2xl transition-all duration-300 relative overflow-hidden",
                                isActive
                                    ? "bg-gold text-primary-foreground shadow-lg shadow-gold/20"
                                    : "text-muted-foreground hover:text-foreground hover:bg-secondary/50"
                            )}
                        >
                            <item.icon className={cn(
                                "w-5 h-5 transition-transform duration-300 group-hover:scale-110",
                                isActive ? "text-primary-foreground" : "text-gold"
                            )} />
                            <span className="font-heading text-xs uppercase tracking-widest font-medium">
                                {item.label}
                            </span>
                            {isActive && (
                                <motion.div
                                    layoutId="sidebar-active"
                                    className="absolute left-0 w-1 h-6 bg-primary-foreground rounded-r-full"
                                />
                            )}
                        </Link>
                    )
                })}
            </nav>

            <div className="mt-8 pt-6 border-t border-border space-y-4">
                <div className="px-4 py-3 rounded-2xl glass border-gold/10 flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-secondary flex items-center justify-center text-xs font-heading border border-white/5 uppercase">
                        {user?.name?.substring(0, 2) || 'AI'}
                    </div>
                    <div className="flex-1 overflow-hidden">
                        <p className="text-xs font-heading text-foreground truncate uppercase tracking-tighter">{user?.name || 'Explorer'}</p>
                        <p className="text-[10px] text-gold uppercase tracking-widest font-bold">{role}</p>
                    </div>
                </div>

                {/* Theme and Language Controls */}
                <div className="flex items-center justify-center gap-3 px-2">
                    <ThemeToggle />
                    <LanguageSwitch />
                </div>

                <button
                    onClick={logout}
                    className="flex items-center gap-4 px-4 py-3.5 w-full text-muted-foreground hover:text-gold hover:bg-gold/5 transition-all rounded-2xl font-heading text-[10px] uppercase tracking-[0.2em] group"
                >
                    <LogOut className="w-4 h-4 transition-transform group-hover:translate-x-1" />
                    {commonT('logout')}
                </button>
            </div>
        </aside>
    );
};
