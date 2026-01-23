import { NextResponse, type NextRequest } from 'next/server'
import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

const intlMiddleware = createMiddleware(routing);

export default async function proxy(request: NextRequest) {
    // Run i18n middleware
    const response = intlMiddleware(request);

    // JWT tokens are handled client-side, no server-side session refresh needed
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
