'use client';

import { useEffect, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import { useRouter } from '@/lib/i18n';
import { useAuthStore } from '@/store/auth.store';
import { userService } from '@/services/user.service';
import { Loader2 } from 'lucide-react';

function CallbackHandler() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const { setAuth } = useAuthStore();

    useEffect(() => {
        const handleCallback = async () => {
            const accessToken = searchParams.get('accessToken');
            const refreshToken = searchParams.get('refreshToken');

            if (accessToken) {
                localStorage.setItem('token', accessToken);
                // Optionally store refresh token too if needed for client-side refresh logic

                try {
                    // Fetch profile to complete auth state
                    const userData = await userService.getMe();
                    setAuth(userData, accessToken);

                    // Redirect to home or intended destination
                    router.push('/');
                } catch (error) {
                    console.error('Failed to fetch user after OAuth:', error);
                    router.push('/login?error=oauth_failed');
                }
            } else {
                router.push('/login?error=no_token');
            }
        };

        handleCallback();
    }, [searchParams, setAuth, router]);

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex flex-col items-center justify-center p-6 transition-colors">
            <Loader2 className="w-12 h-12 text-gold animate-spin mb-6" />
            <h1 className="text-xl font-serif text-luxury-black dark:text-white mb-2 italic">
                Authenticating your Presence...
            </h1>
            <p className="text-[10px] text-stone-400 font-bold tracking-[.4em] uppercase">
                Synchronizing with the neural network
            </p>
        </div>
    );
}

export default function AuthCallbackPage() {
    return (
        <Suspense fallback={
            <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex flex-col items-center justify-center p-6">
                <Loader2 className="w-12 h-12 text-gold animate-spin" />
            </div>
        }>
            <CallbackHandler />
        </Suspense>
    );
}
