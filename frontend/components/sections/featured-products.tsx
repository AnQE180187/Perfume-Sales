'use client';

import { useTranslations } from 'next-intl';
import { motion } from 'framer-motion';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { ArrowRight } from 'lucide-react';

const products = [
    {
        name: "Lumina No. 01",
        price: "240",
        type: "Extrait de Parfum",
        img: "/luxury_perfume_hero_cinematic.png",
        accent: "Floral"
    },
    {
        name: "Oud Mystère",
        price: "380",
        type: "Pure Essence",
        img: "/luxury_ai_scent_lab.png",
        accent: "Oriental"
    },
    {
        name: "Santal Bloom",
        price: "195",
        type: "Eau de Parfum",
        img: "/luxury_perfume_auth_aesthetic.png",
        accent: "Woody"
    }
];

export const FeaturedProducts = () => {
    const t = useTranslations('featured');

    return (
        <section className="py-40 bg-white dark:bg-zinc-950 transition-colors" id="collections">
            <div className="container mx-auto px-6">
                {/* Header */}
                <div className="flex flex-col md:flex-row justify-between items-end mb-24 gap-12">
                    <div className="max-w-2xl">
                        <p className="text-[10px] text-stone-400 dark:text-stone-500 font-bold tracking-[.5em] uppercase mb-6 transition-colors font-serif italic">
                            {t('badge')}
                        </p>
                        <h2 className="text-6xl md:text-8xl font-serif text-luxury-black dark:text-white transition-colors leading-none tracking-tighter">
                            {t('title')}
                        </h2>
                    </div>
                    <Link
                        href="/collection"
                        className="group text-[10px] font-bold tracking-[.4em] uppercase border-b-2 border-gold pb-2 text-luxury-black dark:text-white transition-colors flex items-center gap-4"
                    >
                        {t('cta')}
                        <ArrowRight size={16} className="group-hover:translate-x-2 transition-transform" />
                    </Link>
                </div>

                {/* Products Grid */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-16 xl:gap-24">
                    {products.map((perfume, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 40 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.8, delay: i * 0.2 }}
                            className="group cursor-pointer"
                        >
                            {/* Image Card */}
                            <div className="relative aspect-[3/4] bg-stone-50 dark:bg-zinc-900 mb-10 overflow-hidden rounded-[3.5rem] transition-all border border-stone-100 dark:border-white/5 shadow-sm group-hover:shadow-[0_40px_80px_-20px_rgba(0,0,0,0.15)] group-hover:-translate-y-4">
                                <Image
                                    src={perfume.img}
                                    alt={perfume.name}
                                    fill
                                    className="object-cover transition-transform duration-[1.5s] ease-out group-hover:scale-110"
                                />
                                <div className="absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />

                                {/* Accent Badge */}
                                <div className="absolute top-8 left-8">
                                    <span className="glass px-4 py-2 rounded-full text-[9px] font-bold tracking-widest uppercase text-white shadow-xl opacity-0 group-hover:opacity-100 transition-all duration-500 -translate-y-4 group-hover:translate-y-0">
                                        {perfume.accent}
                                    </span>
                                </div>

                                {/* CTA Button */}
                                <div className="absolute bottom-8 left-8 right-8 translate-y-8 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-700">
                                    <button className="w-full py-4 glass text-white text-[10px] font-bold tracking-[.4em] uppercase rounded-full hover:bg-white hover:text-luxury-black transition-all">
                                        {t('add')}
                                    </button>
                                </div>
                            </div>

                            {/* Product Info */}
                            <div className="flex flex-col items-center text-center">
                                <p className="text-[9px] text-stone-400 dark:text-stone-500 font-bold tracking-[.4em] uppercase mb-2 transition-colors">
                                    {perfume.type}
                                </p>
                                <h4 className="text-3xl font-serif text-luxury-black dark:text-white mb-4 group-hover:italic transition-all duration-500">
                                    {perfume.name}
                                </h4>
                                <div className="w-8 h-px bg-stone-200 dark:bg-gold/30 mb-4 transition-colors" />
                                <p className="text-lg font-serif italic text-luxury-black dark:text-white transition-colors tracking-widest">
                                    {perfume.price}.000đ
                                </p>
                            </div>
                        </motion.div>
                    ))}
                </div>
            </div>
        </section>
    );
};
