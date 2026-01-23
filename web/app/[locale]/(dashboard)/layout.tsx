"use client";

import React, { useEffect } from "react";
import { useRouter, useParams } from "next/navigation";
import { AdminSidebar } from "@/components/layout/AdminSidebar";
import { Search, Bell, LogOut } from "lucide-react";
import { ThemeToggle } from "@/components/common/ThemeToggle";
import { useAuth } from "@/features/auth/AuthContext";
import { isAdminOrStaff } from "@/lib/auth-utils";

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const { user, profile, isLoading, signOut } = useAuth();
    const router = useRouter();
    const { locale } = useParams();

    useEffect(() => {
        if (!isLoading) {
            // Check if user is authenticated
            if (!user) {
                router.push(`/${locale}/auth`);
                return;
            }

            // Check if user has admin or staff role
            const userRole = user.role || profile?.role || profile?.roles?.[0];
            if (!isAdminOrStaff(userRole)) {
                // Redirect to home if not admin/staff
                router.push(`/${locale}`);
                return;
            }
        }
    }, [user, profile, isLoading, router, locale]);

    // Show loading state
    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-stone-50 dark:bg-zinc-950">
                <div className="animate-pulse flex flex-col items-center gap-4">
                    <div className="w-16 h-16 border-4 border-accent border-t-transparent rounded-full animate-spin" />
                    <span className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-500">Verifying Access...</span>
                </div>
            </div>
        );
    }

    // Don't render if user is not authenticated or doesn't have permission
    const userRole = user?.role || profile?.role || profile?.roles?.[0];
    if (!user || !isAdminOrStaff(userRole)) {
        return null;
    }

    return (
        <div className="flex min-h-screen bg-stone-100 dark:bg-black text-stone-900 dark:text-stone-100 overflow-hidden">
            <AdminSidebar />

            <main className="flex-1 p-8 flex flex-col gap-8 h-screen overflow-y-auto bg-stone-50 dark:bg-zinc-950">
                {/* Header duplicated from the original dashboard for consistency */}
                <header className="flex items-center justify-between flex-shrink-0">
                    <div className="flex items-center gap-4 glass dark:bg-stone-900/50 px-6 py-2.5 rounded-full border border-stone-200 dark:border-white/10 shadow-sm w-96">
                        <Search size={18} className="text-stone-400" />
                        <input
                            type="text"
                            placeholder="Search intelligence..."
                            className="bg-transparent border-none outline-none text-sm w-full text-stone-900 dark:text-stone-100 placeholder:text-stone-400"
                        />
                    </div>

                    <div className="flex items-center gap-4">
                        <ThemeToggle />
                        <button className="p-2.5 glass dark:bg-stone-900/50 rounded-full border border-stone-200 dark:border-white/10 hover:bg-stone-50 dark:hover:bg-white/5 transition-colors text-stone-900 dark:text-stone-100">
                            <Bell size={20} strokeWidth={1.5} />
                        </button>
                        <div className="flex items-center gap-3 glass dark:bg-stone-900/50 pl-2 pr-2 py-1.5 rounded-full border border-stone-200 dark:border-white/10 group relative">
                            <div className="w-10 h-10 rounded-full bg-accent flex items-center justify-center text-white font-serif overflow-hidden border-2 border-white dark:border-zinc-800">
                                {profile?.avatar_url ? (
                                    <img src={profile.avatar_url} alt="Avatar" className="w-full h-full object-cover" />
                                ) : (
                                    <span>{profile?.full_name?.charAt(0) || 'A'}</span>
                                )}
                            </div>
                            <div className="flex flex-col pr-4">
                                <span className="text-xs font-bold text-stone-900 dark:text-stone-100">{profile?.full_name?.split(' ')[0] || 'Admin'}</span>
                                <span className="text-[10px] text-stone-500 dark:text-stone-500 uppercase tracking-tighter">
                                    {profile?.role || profile?.roles?.[0] || 'Staff'}
                                </span>
                            </div>

                            {/* Hover Logout Option */}
                            <button
                                onClick={() => signOut()}
                                className="ml-2 p-2 text-stone-400 hover:text-red-500 transition-colors cursor-pointer"
                                title="Sign Out"
                            >
                                <LogOut size={16} />
                            </button>
                        </div>
                    </div>
                </header>

                <div className="flex-1">
                    {children}
                </div>
            </main>
        </div>
    );
}
