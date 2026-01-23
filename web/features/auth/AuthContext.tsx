"use client";

import React, { createContext, useContext, useEffect, useState } from "react";
import { useParams } from "next/navigation";
import { apiClient } from "@/lib/api-client";

interface User {
    id: string;
    email: string;
    role?: string;
    fullName?: string;
    phone?: string;
    avatarUrl?: string;
    loyaltyPoints?: number;
}

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

    const fetchProfile = async () => {
        try {
            const response = await apiClient.getMe();
            if (response.data) {
                const userData = response.data as any;
                setUser({
                    id: userData.id,
                    email: userData.email,
                    role: userData.role,
                    fullName: userData.fullName,
                    phone: userData.phone,
                    avatarUrl: userData.avatarUrl,
                    loyaltyPoints: userData.loyaltyPoints,
                });
                setProfile({
                    ...userData,
                    role: userData.role, // Keep original role
                    roles: userData.role ? [userData.role] : [],
                    loyalty_points: userData.loyaltyPoints || 0,
                    // Map camelCase to snake_case for backward compatibility with existing UI
                    full_name: userData.fullName,
                    avatar_url: userData.avatarUrl,
                    budget_range: userData.budgetMin && userData.budgetMax ? {
                        min: userData.budgetMin,
                        max: userData.budgetMax
                    } : undefined,
                });
            } else {
                setUser(null);
                setProfile(null);
            }
        } catch (err) {
            console.error("Unexpected error fetching profile:", err);
            setUser(null);
            setProfile(null);
        }
    };

    const refreshProfile = async () => {
        await fetchProfile();
    };

    useEffect(() => {
        // Check if user is authenticated by trying to fetch profile
        const initAuth = async () => {
            const token = apiClient.getToken();
            if (token) {
                await fetchProfile();
            }
            setIsLoading(false);
        };

        initAuth();

        // Listen for storage changes (when token is set/removed)
        const handleStorageChange = (e: StorageEvent) => {
            if (e.key === 'accessToken') {
                if (e.newValue) {
                    fetchProfile();
                } else {
                    setUser(null);
                    setProfile(null);
                }
            }
        };

        window.addEventListener('storage', handleStorageChange);
        return () => {
            window.removeEventListener('storage', handleStorageChange);
        };
    }, []);

    const signOut = async () => {
        try {
            // 1. Call backend logout
            await apiClient.logout();

            // 2. Clear local state
            setUser(null);
            setProfile(null);

            // 3. Redirect to home
            setTimeout(() => {
                if (window.location.pathname !== `/${locale}`) {
                    window.location.href = `/${locale}`;
                }
            }, 100);
        } catch (err) {
            console.error("Error signing out:", err);
            // Force clear and reload
            apiClient.clearTokens();
            setUser(null);
            setProfile(null);
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
