"use client";

import React, { createContext, useContext, useEffect, useState } from "react";
import { useParams } from "next/navigation";
import { supabase } from "@/lib/supabase";
import { User } from "@supabase/supabase-js";

interface AuthContextType {
    user: User | null;
    profile: any | null;
    isLoading: boolean;
    signOut: () => Promise<void>;
    refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);
export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
    const { locale } = useParams();
    const [user, setUser] = useState<User | null>(null);
    const [profile, setProfile] = useState<any | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    const fetchProfile = async (userId: string) => {
        try {
            const { data, error } = await supabase
                .from("profiles")
                .select(`
                    *,
                    user_roles (
                        roles (
                            code
                        )
                    ),
                    loyalty_accounts (
                        current_points
                    )
                `)
                .eq("id", userId)
                .maybeSingle();

            if (error) {
                console.error("Supabase error fetching profile details:", {
                    message: error.message,
                    details: error.details,
                    hint: error.hint,
                    code: error.code,
                    userId
                });

                // Fallback: Try to fetch profile WITHOUT joins to see if it's a join/RLS issue
                const { data: simpleData } = await supabase
                    .from("profiles")
                    .select("*")
                    .eq("id", userId)
                    .maybeSingle();

                if (simpleData) {
                    console.warn("Recovered by fetching simple profile without roles.");
                    setProfile({ ...simpleData, roles: [] });
                }
                return;
            }

            if (data) {
                const roles = (data as any)?.user_roles?.map((ur: any) => ur.roles?.code) || [];
                const loyalty_points = (data as any)?.loyalty_accounts?.current_points || 0;
                setProfile({ ...data, roles, loyalty_points });
            }
        } catch (err) {
            console.error("Unexpected error fetching profile:", err);
        }
    };


    const refreshProfile = async () => {
        if (user) {
            await fetchProfile(user.id);
        }
    };

    useEffect(() => {
        // 1. Get initial session
        const initAuth = async () => {
            const { data: { session } } = await supabase.auth.getSession();
            if (session?.user) {
                setUser(session.user);
                await fetchProfile(session.user.id);
            }
            setIsLoading(false);
        };

        initAuth();

        // 2. Listen for auth changes
        const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
            if (session?.user) {
                setUser(session.user);
                await fetchProfile(session.user.id);
            } else {
                setUser(null);
                setProfile(null);
            }
            setIsLoading(false);
        });

        return () => {
            subscription.unsubscribe();
        };
    }, []);

    const signOut = async () => {
        try {
            // 1. Clear server-side session
            await fetch("/api/auth/logout", { method: "POST" });

            // 2. Clear client-side session via Supabase
            // The onAuthStateChange listener above will handle setUser(null), setProfile(null) 
            // and redirection when it detects the session is gone.
            const { error } = await supabase.auth.signOut();
            if (error) throw error;

            // 3. Fallback: If for some reason the listener doesn't trigger a redirect
            setTimeout(() => {
                if (window.location.pathname !== `/${locale}`) {
                    window.location.href = `/${locale}`;
                }
            }, 500);

        } catch (err) {
            console.error("Error signing out:", err);
            // Force reload if everything fails
            window.location.href = `/${locale}`;
        }
    };

    return (
        <AuthContext.Provider value={{ user, profile, isLoading, signOut, refreshProfile }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (context === undefined) {
        throw new Error("useAuth must be used within an AuthProvider");
    }
    return context;
};
