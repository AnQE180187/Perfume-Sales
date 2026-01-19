"use client";

import React, { useEffect } from "react";
import { Navbar } from "@/components/layout/Navbar";
import { AuthForm } from "@/features/auth/AuthForm";
import { useAuth } from "@/features/auth/AuthContext";
import { useRouter } from "@/i18n/routing";

export default function AuthPage() {
    const { user, isLoading } = useAuth();
    const router = useRouter();

    useEffect(() => {
        if (!isLoading && user) {
            router.push("/");
        }
    }, [user, isLoading, router]);

    if (isLoading) return null; // Or a loading spinner

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors flex flex-col">
            <Navbar />
            <main className="flex-1 flex items-center justify-center p-6 py-32">
                <AuthForm />
            </main>
        </div>
    );
}

