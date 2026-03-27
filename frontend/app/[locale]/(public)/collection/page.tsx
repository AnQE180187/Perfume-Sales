'use client';

import { useState, useRef, useEffect } from 'react';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { motion, useScroll, useTransform } from 'framer-motion';
import { Filter, ChevronDown, ShoppingBag, Sparkles } from 'lucide-react';
import { useTranslations, useLocale } from 'next-intl';
import { productService, type Product, type ProductListRes } from '@/services/product.service';
import { cartService } from '@/services/cart.service';
import { useAuth } from '@/hooks/use-auth';

export default function CollectionPage() {
    const t = useTranslations('collection');
    const tCommon = useTranslations('common');
    const locale = useLocale();
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const [activeCategory, setActiveCategory] = useState(tCommon('all'));
    const [isMounted, setIsMounted] = useState(false);
    const containerRef = useRef<HTMLDivElement>(null);
    const { isAuthenticated } = useAuth();

    useEffect(() => {
        productService.list({ take: 100 }).then((r: ProductListRes) => {
            setProducts(r.items);
            setLoading(false);
        }).catch(() => setLoading(false));
    }, []);

    useEffect(() => {
        setIsMounted(true);
    }, []);

    const { scrollYProgress } = useScroll({
        target: isMounted ? containerRef : undefined,
        offset: ['start start', 'end start']
    });

    const bannerY = useTransform(scrollYProgress, [0, 0.4], ['0%', '30%']);
    const bannerOpacity = useTransform(scrollYProgress, [0, 0.4], [1, 0.5]);

    const categories = [tCommon('all'), ...Array.from(new Set(products.map(p => p.category?.name).filter(Boolean) as string[]))];
    const filteredProducts = activeCategory === tCommon('all')
        ? products
        : products.filter(p => p.category?.name === activeCategory);

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', {
            style: 'currency',
            currency: 'VND', // Base currency is VND
            maximumFractionDigits: 0
        }).format(amount);
    };

    return (
        <div className="min-h-screen bg-background transition-colors" ref={containerRef}>
            {/* Header Banner */}
            <section className="relative h-[70vh] overflow-hidden flex items-center justify-center mt-20">
                <motion.div
                    style={{ y: bannerY, opacity: bannerOpacity }}
                    className="absolute inset-0 z-0"
                >
                    <Image
                        src="/luxury_perfume_hero_cinematic.png"
                        alt="Collection Banner"
                        fill
                        className="object-cover contrast-[1.05] brightness-90"
                        priority
                    />
                    <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-transparent to-background" />
                </motion.div>

                <div className="relative z-10 text-center px-6">
                    <motion.div
                        initial={{ opacity: 0, y: 40 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 1.2, ease: [0.22, 1, 0.36, 1] }}
                    >
                        <span className="text-white/80 text-[10px] font-bold tracking-[.6em] uppercase mb-6 block font-serif italic">
                            {t('badge')}
                        </span>
                        <h1 className="text-7xl md:text-[10rem] font-serif text-white mb-8 leading-[0.85] tracking-tighter mix-blend-plus-lighter">
                            {t('title')}
                        </h1>
                        <div className="w-24 h-px bg-gold/50 mx-auto blur-[1px]" />
                    </motion.div>
                </div>
            </section>

            {/* Filter Bar */}
            <section className="sticky top-20 z-30 bg-background/80 backdrop-blur-3xl border-y border-border/50 py-8">
                <div className="max-w-[1800px] mx-auto px-12 flex flex-wrap items-center justify-between gap-12">
                    {/* Categories */}
                    <div className="flex items-center gap-12 overflow-x-auto pb-4 md:pb-0 scrollbar-hide">
                        {categories.map((cat) => (
                            <button
                                key={cat}
                                onClick={() => setActiveCategory(cat)}
                                className={`text-[10px] font-bold tracking-[.4em] uppercase transition-all whitespace-nowrap cursor-pointer hover:tracking-[.6em] duration-500 ${activeCategory === cat
                                    ? 'text-gold'
                                    : 'text-muted-foreground hover:text-foreground'
                                    }`}
                            >
                                {cat}
                            </button>
                        ))}
                    </div>

                    {/* Filter/Sort */}
                    <div className="flex items-center gap-12">
                        <button className="flex items-center gap-4 text-[10px] font-bold tracking-[.4em] uppercase text-foreground group transition-all cursor-pointer">
                            <Filter size={14} className="group-hover:text-gold transition-all duration-500" />
                            {t('refine')}
                        </button>
                        <button className="flex items-center gap-4 text-[10px] font-bold tracking-[.4em] uppercase text-foreground group transition-all cursor-pointer">
                            {t('sortBy')}
                            <ChevronDown size={14} className="group-hover:text-gold transition-all duration-500" />
                        </button>
                    </div>
                </div>
            </section>

            {/* Products Grid */}
            <section className="py-32">
                {/* Count */}
                <div className="max-w-[1800px] mx-auto px-12 mb-24 flex justify-between items-center glass p-10 rounded-[3rem] border-gold/10">
                    <div className="flex items-center gap-4">
                        <Sparkles size={18} className="text-gold animate-pulse" />
                        <p className="text-[11px] text-muted-foreground font-bold tracking-[.4em] uppercase">
                            {t('showing', { count: filteredProducts.length })}
                        </p>
                    </div>
                </div>

                {/* Grid */}
                <div className="max-w-[1800px] mx-auto px-12 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-20 gap-y-32">
                    {loading ? (
                        <div className="col-span-full py-40 text-center text-muted-foreground text-[10px] uppercase font-bold tracking-[.8em] animate-pulse">
                            {tCommon('loading')}
                        </div>
                    ) : (
                        filteredProducts.map((product, i) => (
                            <motion.div
                                key={product.id}
                                initial={{ opacity: 0, y: 50 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true, margin: "-100px" }}
                                transition={{ duration: 1, delay: i * 0.1, ease: [0.22, 1, 0.36, 1] }}
                                className="group relative"
                            >
                                <Link href={`/collection/${product.id}`}>
                                    <div className="relative aspect-[4/5] bg-foreground/5 rounded-[4rem] overflow-hidden mb-12 border border-border/50 group-hover:border-gold/30 transition-all duration-700 ease-out shadow-sm hover:shadow-[0_80px_120px_-40px_rgba(197,160,89,0.15)] group-hover:-translate-y-6">
                                        {product.images?.[0]?.url ? (
                                            <img
                                                src={product.images[0].url}
                                                alt={product.name}
                                                className="absolute inset-0 w-full h-full object-cover transition-transform duration-[2s] ease-out group-hover:scale-110"
                                            />
                                        ) : (
                                            <div className="w-full h-full bg-gradient-to-br from-stone-100 to-stone-200 dark:from-zinc-900 dark:to-zinc-800 flex items-center justify-center">
                                                <Sparkles className="text-gold/20" size={64} />
                                            </div>
                                        )}
                                        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/5 transition-colors duration-700" />

                                        {/* Category Badge */}
                                        <div className="absolute top-12 left-12">
                                            <span className="glass px-6 py-3 rounded-full text-[9px] font-bold tracking-[.4em] uppercase text-white shadow-2xl border-white/10 backdrop-blur-xl">
                                                {product.category?.name ?? '—'}
                                            </span>
                                        </div>

                                        {/* View Details Overlay */}
                                        <div className="absolute inset-x-12 bottom-12 translate-y-12 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-700 ease-out">
                                            <div className="w-full glass py-5 rounded-full text-[10px] font-bold tracking-[.5em] uppercase text-white hover:bg-gold hover:text-white border-white/20 transition-all flex items-center justify-center gap-4 shadow-2xl">
                                                <ShoppingBag size={14} />
                                                {tCommon('view_options')}
                                            </div>
                                        </div>
                                    </div>
                                </Link>

                                <div className="text-center px-4">
                                    <Link href={`/collection/${product.id}`}>
                                        <h3 className="text-4xl font-serif text-foreground mb-4 group-hover:text-gold group-hover:italic transition-all duration-700 tracking-tight leading-tight">
                                            {product.name}
                                        </h3>
                                    </Link>
                                    <p className="text-[10px] text-muted-foreground font-bold uppercase tracking-[.6em] mb-6 transition-colors font-serif italic opacity-60">
                                        {product.brand?.name ?? '—'}
                                    </p>
                                    <div className="w-12 h-px bg-gold/20 mx-auto mb-8 group-hover:w-24 transition-all duration-700" />
                                    <span className="text-2xl font-serif italic text-foreground transition-colors tracking-[0.1em] text-gold/90">
                                        {(() => {
                                            if (!product.variants?.length) return '—';
                                            const prices = product.variants.map(v => v.price);
                                            const min = Math.min(...prices);
                                            const max = Math.max(...prices);
                                            return min === max ? formatCurrency(min) : `${formatCurrency(min)} - ${formatCurrency(max)}`;
                                        })()}
                                    </span>
                                </div>
                            </motion.div>
                        ))
                    )}
                </div>
            </section>
        </div>
    );
}
