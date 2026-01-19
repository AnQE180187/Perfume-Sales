import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

const intlMiddleware = createMiddleware(routing);

export default async function proxy(request: NextRequest) {
    // Run i18n middleware first to get the response
    const response = intlMiddleware(request);

    // Create a Supabase client to refresh the session
    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return request.cookies.get(name)?.value
                },
                set(name: string, value: string, options: CookieOptions) {
                    // Update request cookies for downstream
                    request.cookies.set({ name, value, ...options })
                    // Update response cookies for the browser
                    response.cookies.set({ name, value, ...options })
                },
                remove(name: string, options: CookieOptions) {
                    request.cookies.set({ name, value: '', ...options })
                    response.cookies.set({ name, value: '', ...options })
                },
            },
        }
    )

    // Refresh session if expired
    await supabase.auth.getUser()

    return response
}

export const config = {
    matcher: [
        // Match all pathnames except for
        // - … if they start with /api, /_next or /_static
        // - … the ones containing a dot (e.g. favicon.ico)
        '/((?!api|_next|_static|_vercel|.*\\..*).*)',
    ]
};
