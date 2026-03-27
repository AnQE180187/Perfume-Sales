import { NextIntlClientProvider, useMessages } from 'next-intl';
import { getMessages, getTranslations } from 'next-intl/server';
import { notFound } from 'next/navigation';
import { routing } from '@/lib/i18n';
import { ThemeProvider } from '@/components/common/theme-provider';
import { SetHtmlLang } from '@/components/common/set-html-lang';
import type { Metadata } from 'next';

export async function generateMetadata({ 
    params 
}: { 
    params: Promise<{ locale: string }> 
}): Promise<Metadata> {
    const { locale } = await params;
    const t = await getTranslations({ locale, namespace: 'common' });

    return {
        title: t('title'),
        description: t('description'),
        keywords: t('keywords'),
        authors: [{ name: 'Aura AI Atelier' }],
        creator: 'Aura AI',
        publisher: 'Aura AI Atelier',
        formatDetection: {
            email: false,
            address: false,
            telephone: false,
        },
        openGraph: {
            title: t('title'),
            description: t('description'),
            url: 'https://aura-ai.com',
            siteName: 'Aura AI',
            locale: locale === 'vi' ? 'vi_VN' : 'en_US',
            type: 'website',
        },
    };
}

export const viewport = {
    themeColor: [
        { media: '(prefers-color-scheme: light)', color: '#ffffff' },
        { media: '(prefers-color-scheme: dark)', color: '#09090b' },
    ],
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
};

export default async function LocaleLayout({
    children,
    params
}: {
    children: React.ReactNode;
    params: Promise<{ locale: string }>;
}) {
    const { locale } = await params;

    if (!routing.locales.includes(locale as 'en' | 'vi')) {
        notFound();
    }

    const messages = await getMessages();

    return (
        <NextIntlClientProvider messages={messages}>
            <SetHtmlLang locale={locale} />
            <ThemeProvider
                attribute="class"
                defaultTheme="dark"
                enableSystem
                disableTransitionOnChange
            >
                {children}
            </ThemeProvider>
        </NextIntlClientProvider>
    );
}
