import createMiddleware from 'next-intl/middleware';
import { routing } from '@/lib/i18n';

export default createMiddleware(routing);

export const config = {
    // Match all pathnames except for
    // - API routes
    // - Public assets (images, etc)
    // - Internal files (_next, etc)
    matcher: ['/((?!api|auth/callback|_next|_vercel|.*\\..*).*)']
};
