import type { Metadata } from "next";
import { Cormorant_Garamond, Inter } from "next/font/google";
import "@/app/globals.css";
import { getMessages } from "next-intl/server";
import { NextIntlClientProvider } from "next-intl";
import { ThemeProvider } from "@/components/common/ThemeProvider";
import { NewsletterModal } from "@/components/common/NewsletterModal";
import { CartProvider } from "@/features/cart/CartContext";
import { AuthProvider } from "@/features/auth/AuthContext";
import { ReactNode } from "react";
import { Toaster } from "react-hot-toast";

const cormorant = Cormorant_Garamond({
  variable: "--font-serif",
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
});

const inter = Inter({
  variable: "--font-sans",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "LUMINA | AI-Powered Luxury Perfume House",
  description: "Experience the future of fragrance with personalized AI-driven perfume consultations.",
};

export default async function RootLayout({
  children,
  params,
}: {
  children: ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const messages = await getMessages();

  return (
    <html lang={locale} suppressHydrationWarning>
      <body className={`${inter.variable} ${cormorant.variable} antialiased min-h-screen`}>
        <NextIntlClientProvider messages={messages}>
          <ThemeProvider
            attribute="class"
            defaultTheme="light"
            enableSystem
            disableTransitionOnChange
          >
            <AuthProvider>
              <CartProvider>
                {children}
                <NewsletterModal />
              </CartProvider>
            </AuthProvider>
          </ThemeProvider>
        </NextIntlClientProvider>
        <Toaster />
      </body>
    </html>
  );
}
