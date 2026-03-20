'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { useEffect } from 'react';
import { useRouter } from '@/lib/i18n';

export default function AiChatPage() {
    const router = useRouter();

    useEffect(() => {
        router.push('/dashboard/chat');
    }, [router]);

    return (
        <AuthGuard allowedRoles={['customer']}>
            <div className="p-8 text-sm text-muted-foreground">Redirecting…</div>
        </AuthGuard>
    );
}
