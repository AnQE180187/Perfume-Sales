import type { ReactNode } from 'react';
import { Roboto, Playfair_Display, JetBrains_Mono } from 'next/font/google';
import './globals.css';

const roboto = Roboto({
  variable: '--font-roboto',
  subsets: ['latin', 'latin-ext', 'vietnamese'],
  display: 'swap',
  weight: ['400', '500', '700'],
});

const jetbrainsMono = JetBrains_Mono({
  variable: '--font-jetbrains-mono',
  subsets: ['latin'],
  display: 'swap',
});

const playfairDisplay = Playfair_Display({
  variable: '--font-playfair',
  subsets: ['latin', 'latin-ext'],
  display: 'swap',
  weight: ['400', '500', '600', '700', '800', '900'],
});

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <meta charSet="utf-8" />
      </head>
      <body className={`${roboto.variable} ${jetbrainsMono.variable} ${playfairDisplay.variable} antialiased bg-white dark:bg-zinc-950 transition-colors duration-500 font-sans`}>
        {children}
      </body>
    </html>
  );
}
