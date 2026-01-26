import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface User {
    id: string;
    fullName?: string;
    name?: string; // Keep for compatibility
    email: string;
    role: 'admin' | 'staff' | 'customer' | 'ADMIN' | 'STAFF' | 'CUSTOMER';
    avatarUrl?: string;
    points?: number;
    phoneNumber?: string;
    status?: string;
}

interface AuthState {
    user: User | null;
    token: string | null;
    setAuth: (user: User, token: string) => void;
    logout: () => void;
}

export const useAuthStore = create<AuthState>()(
    persist(
        (set) => ({
            user: null,
            token: null,
            setAuth: (user, token) => set({ user, token }),
            logout: () => {
                if (typeof window !== 'undefined') {
                    localStorage.removeItem('token');
                }
                set({ user: null, token: null });
            },
        }),
        {
            name: 'auth-storage',
        }
    )
);
