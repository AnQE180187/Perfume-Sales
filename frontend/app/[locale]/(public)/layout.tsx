'use client';

import { Header } from '@/components/common/header';
import { Footer } from '@/components/sections/footer';

export default function PublicLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <div className="min-h-screen bg-background">
            <Header />
            <main>{children}</main>
            <Footer />
        </div>
    );
}
