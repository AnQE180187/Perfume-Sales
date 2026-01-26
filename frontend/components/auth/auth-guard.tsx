'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/use-auth';

interface AuthGuardProps {
    children: React.ReactNode;
    allowedRoles?: ('admin' | 'staff' | 'customer' | 'ADMIN' | 'STAFF' | 'CUSTOMER')[];
}

export const AuthGuard = ({ children, allowedRoles }: AuthGuardProps) => {
    const { user, isAuthenticated } = useAuth();
    const router = useRouter();

    useEffect(() => {
        const normalizedUserRole = user?.role?.toLowerCase();
        const normalizedAllowedRoles = allowedRoles?.map(r => r.toLowerCase());

        if (!isAuthenticated) {
            router.push('/login');
        } else if (normalizedAllowedRoles && normalizedUserRole && !normalizedAllowedRoles.includes(normalizedUserRole)) {
            router.push('/');
        }
    }, [isAuthenticated, user, allowedRoles, router]);

    const normalizedUserRole = user?.role?.toLowerCase();
    const normalizedAllowedRoles = allowedRoles?.map(r => r.toLowerCase());

    if (!isAuthenticated || (normalizedAllowedRoles && normalizedUserRole && !normalizedAllowedRoles.includes(normalizedUserRole))) {
        return <div className="flex items-center justify-center min-h-screen">Loading...</div>;
    }

    return <>{children}</>;
};
