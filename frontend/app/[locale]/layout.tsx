import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';
import { notFound } from 'next/navigation';
import { routing } from '@/lib/i18n';
import { ThemeProvider } from '@/components/common/theme-provider';
import { Toaster } from '@/components/ui/sonner';
import { beVietnamPro } from '@/lib/fonts';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: {
        default: 'PerfumeGPT | Luxury Fragrance & AI Scent Consultant',
        template: '%s | PerfumeGPT'
    },
    description: 'Discover your signature scent with PerfumeGPT. Our AI-powered fragrance consultant analyzes your preferences to find the perfect luxury perfume for every occasion.',
    keywords: ['perfume', 'fragrance', 'luxury perfume', 'AI fragrance consultant', 'scent recommendation', 'niche perfume', 'perfume shop'],
    metadataBase: new URL('https://perfumegpt.site'),
    alternates: {
        canonical: '/',
        languages: {
            'en-US': '/en',
            'vi-VN': '/vi',
        },
    },
    openGraph: {
        type: 'website',
        locale: 'en_US',
        url: 'https://perfumegpt.site',
        siteName: 'PerfumeGPT',
        title: 'PerfumeGPT | Luxury Fragrance & AI Scent Consultant',
        description: 'Explore our curated collection of luxury fragrances and experience our AI Scent Consultant.',
        images: [
            {
                url: '/og-image.png',
                width: 1200,
                height: 630,
                alt: 'PerfumeGPT Luxury Fragrance',
            },
        ],
    },
    twitter: {
        card: 'summary_large_image',
        title: 'PerfumeGPT | Luxury Fragrance & AI Scent Consultant',
        description: 'Find your perfect scent with our AI Scent Consultant.',
        images: ['/og-image.png'],
    },
    icons: {
        icon: '/logo-dark.png',
        shortcut: '/logo-dark.png',
        apple: '/logo-dark.png',
    },
};

/**
 * Root Layout for Locale-based routes
 * Ensures lang={locale} is passed. Forced Be Vietnam Pro for Vietnamese stability.
 */
export default async function LocaleLayout({
    children,
    params
}: {
    children: React.ReactNode;
    params: Promise<{ locale: string }>;
}) {
    const { locale } = await params;

    if (!routing.locales.includes(locale as any)) {
        notFound();
    }

    const messages = await getMessages();

    return (
        <html
            lang={locale}
            suppressHydrationWarning
            className={beVietnamPro.variable}
        >
            <body 
                className="antialiased bg-white dark:bg-zinc-950 transition-colors duration-500 font-sans"
                style={{ 
                    fontFeatureSettings: "'liga' 1, 'calt' 1, 'kern' 1",
                    fontVariantLigatures: "common-ligatures"
                }}
            >
                <NextIntlClientProvider messages={messages}>
                    <ThemeProvider
                        attribute="class"
                        defaultTheme="dark"
                        enableSystem
                        disableTransitionOnChange
                    >
                        {children}
                        <Toaster />
                    </ThemeProvider>
                </NextIntlClientProvider>
            </body>
        </html>
    );
}
