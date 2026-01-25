'use client';

import { useTranslations } from 'next-intl';
import { Link } from '@/lib/i18n';
import { ArrowRight } from 'lucide-react';

export const Footer = () => {
    const t = useTranslations('footer');
    const commonT = useTranslations('common');

    const navigation = [
        { label: 'Products', href: '/products' },
        { label: 'AI Consultation', href: '/customer/consultation' },
        { label: 'Journal', href: '/journal' },
        { label: 'The Anthology Club', href: '/customer/subscription' },
        { label: 'Boutiques', href: '/boutiques' },
        { label: 'Gifting', href: '/gifting' }
    ];

    const support = [
        { label: 'Story', href: '/story' },
        { label: 'Ingredients', href: '/ingredients' },
        { label: 'Terms of Service', href: '/terms' },
        { label: 'Privacy Policy', href: '/privacy' },
        { label: 'Customer Support', href: '/support' }
    ];

    const social = ['Instagram', 'Pinterest', 'LinkedIn', 'YouTube'];

    return (
        <footer className="bg-luxury-black text-stone-500 py-32">
            <div className="container mx-auto px-6">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-16 lg:gap-24 mb-32">
                    {/* Brand Column */}
                    <div className="col-span-1 md:col-span-1">
                        <Link href="/">
                            <h2 className="text-3xl font-serif text-white tracking-[.3em] font-bold mb-10 uppercase">
                                AURA
                            </h2>
                        </Link>
                        <p className="text-sm leading-relaxed mb-10 font-light italic">
                            {t('desc') || 'Merging the ancient art of perfumery with the predictive power of neural intelligence.'}
                        </p>
                        <div className="flex flex-wrap gap-x-6 gap-y-3 mt-12">
                            {social.map(name => (
                                <a
                                    key={name}
                                    href="#"
                                    className="text-[9px] uppercase tracking-[.3em] text-stone-600 hover:text-gold transition-colors font-bold"
                                >
                                    {name}
                                </a>
                            ))}
                        </div>
                    </div>

                    {/* Navigation Column */}
                    <div>
                        <h4 className="text-white font-bold mb-10 uppercase text-[10px] tracking-[.4em]">
                            Exploration
                        </h4>
                        <ul className="space-y-6 text-[10px] uppercase tracking-[.2em] font-bold">
                            {navigation.map(item => (
                                <li key={item.href}>
                                    <Link
                                        href={item.href}
                                        className="hover:text-gold transition-colors"
                                    >
                                        {item.label}
                                    </Link>
                                </li>
                            ))}
                        </ul>
                    </div>

                    {/* Support Column */}
                    <div>
                        <h4 className="text-white font-bold mb-10 uppercase text-[10px] tracking-[.4em]">
                            The House
                        </h4>
                        <ul className="space-y-6 text-[10px] uppercase tracking-[.2em] font-bold">
                            {support.map(item => (
                                <li key={item.href}>
                                    <Link
                                        href={item.href}
                                        className="hover:text-gold transition-colors"
                                    >
                                        {item.label}
                                    </Link>
                                </li>
                            ))}
                        </ul>
                    </div>

                    {/* Newsletter Column */}
                    <div>
                        <h4 className="text-white font-bold mb-10 uppercase text-[10px] tracking-[.4em]">
                            Concierge News
                        </h4>
                        <p className="text-xs mb-8 italic">
                            {t('newsletter_desc') || 'Join the inner circle for archival releases and AI insights.'}
                        </p>
                        <div className="flex border-b border-stone-800 pb-4 group focus-within:border-gold transition-colors">
                            <input
                                type="email"
                                placeholder={t('email_placeholder') || 'YOUR EMAIL'}
                                className="bg-transparent text-xs w-full outline-none placeholder:text-stone-700 text-white transition-all uppercase tracking-widest"
                            />
                            <button className="text-stone-600 hover:text-gold transition-colors">
                                <ArrowRight size={20} strokeWidth={1} />
                            </button>
                        </div>
                    </div>
                </div>

                {/* Bottom Bar */}
                <div className="flex flex-col md:flex-row justify-between items-center pt-12 border-t border-stone-900 text-[9px] tracking-[.4em] uppercase font-bold text-stone-700">
                    <span>{t('copyright') || '© 2026 AURA HOUSE. ALL RIGHTS RESERVED.'}</span>
                    <div className="flex gap-12 mt-8 md:mt-0 italic">
                        <span>{t('engine') || 'Aura AI v4.2 Engine'}</span>
                        <span>{t('location') || 'Grasse • Paris • Tokyo'}</span>
                    </div>
                </div>
            </div>
        </footer>
    );
};
