'use client';

import { useState, useRef, useEffect } from 'react';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { motion, useScroll, useTransform } from 'framer-motion';
import { Filter, ChevronDown, ShoppingBag, Sparkles, Loader2 } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { catalogService, Product, Category } from '@/services/catalog.service';
import { useCartStore } from '@/store/cart.store';
import { toast } from 'sonner';

export default function CollectionPage() {
    const t = useTranslations('collection');
    const { addItem } = useCartStore();
    const [activeCategory, setActiveCategory] = useState<number | 'All'>('All');
    const [products, setProducts] = useState<Product[]>([]);
    const [categories, setCategories] = useState<Category[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [isMounted, setIsMounted] = useState(false);
    const containerRef = useRef<HTMLDivElement>(null);

    const handleAddToCart = (e: React.MouseEvent, product: Product) => {
        e.preventDefault();
        e.stopPropagation();

        addItem({
            id: `${product.id}-100ml`,
            productId: product.id,
            name: product.name,
            price: product.price,
            image: product.images[0]?.url || '/luxury_perfume_hero_cinematic.png',
            quantity: 1,
            size: '100ml',
            brand: product.brand.name
        });

        toast.success(`${product.name} added to collection`, {
            description: "View your cart to checkout",
            action: {
                label: "View Cart",
                onClick: () => window.location.href = '/cart'
            },
        });
    };

    useEffect(() => {
        setIsMounted(true);
        fetchInitialData();
    }, []);

    useEffect(() => {
        fetchProducts();
    }, [activeCategory]);

    const fetchInitialData = async () => {
        try {
            const categoriesData = await catalogService.getCategories();
            setCategories(categoriesData);
        } catch (error) {
            console.error('Failed to fetch categories:', error);
        }
    };

    const fetchProducts = async () => {
        setIsLoading(true);
        try {
            const params: any = { take: 20 };
            if (activeCategory !== 'All') {
                params.categoryId = activeCategory;
            }
            const data = await catalogService.getProducts(params);
            setProducts(data.items || []);
        } catch (error) {
            console.error('Failed to fetch products:', error);
        } finally {
            setIsLoading(false);
        }
    };

    const { scrollYProgress } = useScroll({
        target: isMounted ? containerRef : undefined,
        offset: ['start start', 'end start']
    });

    const bannerY = useTransform(scrollYProgress, [0, 0.4], ['0%', '30%']);
    const bannerOpacity = useTransform(scrollYProgress, [0, 0.4], [1, 0.5]);

    return (
        <div className="min-h-screen bg-white dark:bg-zinc-950 transition-colors" ref={containerRef}>
            {/* Header Banner */}
            <section className="relative h-[60vh] overflow-hidden flex items-center justify-center mt-24">
                <motion.div
                    style={{ y: bannerY, opacity: bannerOpacity }}
                    className="absolute inset-0 z-0"
                >
                    <Image
                        src="/luxury_perfume_hero_cinematic.png"
                        alt="Collection Banner"
                        fill
                        className="object-cover contrast-110"
                        priority
                    />
                    <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-black/10 to-transparent" />
                </motion.div>

                <div className="relative z-10 text-center px-6">
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 1, ease: [0.33, 1, 0.68, 1] }}
                    >
                        <span className="text-white text-[10px] font-bold tracking-[.5em] uppercase mb-8 block font-serif italic">
                            {t('badge')}
                        </span>
                        <h1 className="text-7xl md:text-9xl font-serif text-white mb-6 leading-none tracking-tighter">
                            {t('title')}
                        </h1>
                        <div className="w-16 h-px bg-gold mx-auto" />
                    </motion.div>
                </div>
            </section>

            {/* Filter Bar */}
            <section className="sticky top-24 z-20 bg-white/95 dark:bg-zinc-950/95 backdrop-blur-xl border-y border-stone-100 dark:border-white/5 transition-all py-6">
                <div className="container mx-auto px-6 flex flex-wrap items-center justify-between gap-8">
                    {/* Categories */}
                    <div className="flex items-center gap-10 overflow-x-auto pb-2 md:pb-0 scrollbar-hide">
                        <button
                            onClick={() => setActiveCategory('All')}
                            className={`text-[10px] font-bold tracking-[.3em] uppercase transition-all whitespace-nowrap cursor-pointer ${activeCategory === 'All'
                                ? 'text-gold'
                                : 'text-stone-400 hover:text-luxury-black dark:hover:text-white'
                                }`}
                        >
                            All
                        </button>
                        {categories.map((cat) => (
                            <button
                                key={cat.id}
                                onClick={() => setActiveCategory(cat.id)}
                                className={`text-[10px] font-bold tracking-[.3em] uppercase transition-all whitespace-nowrap cursor-pointer ${activeCategory === cat.id
                                    ? 'text-gold'
                                    : 'text-stone-400 hover:text-luxury-black dark:hover:text-white'
                                    }`}
                            >
                                {cat.name}
                            </button>
                        ))}
                    </div>

                    {/* Filter/Sort */}
                    <div className="flex items-center gap-10">
                        <button className="flex items-center gap-3 text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white group transition-colors cursor-pointer">
                            <Filter size={14} className="group-hover:text-gold transition-colors" />
                            {t('refine')}
                        </button>
                        <button className="flex items-center gap-3 text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white group transition-colors cursor-pointer">
                            {t('sortBy')}
                            <ChevronDown size={14} className="group-hover:text-gold transition-colors" />
                        </button>
                    </div>
                </div>
            </section>

            {/* Products Grid */}
            <section className="py-24">
                {/* Count */}
                <div className="container mx-auto px-6 mb-20 flex justify-between items-center bg-stone-50 dark:bg-white/5 p-8 rounded-full transition-colors border border-stone-100 dark:border-white/5 shadow-sm">
                    <div className="flex items-center gap-3">
                        <Sparkles size={16} className="text-gold" />
                        <p className="text-[10px] text-stone-500 dark:text-stone-400 font-bold tracking-[.3em] uppercase">
                            {t('showing', { count: products.length })}
                        </p>
                    </div>
                </div>

                {/* Grid */}
                {isLoading ? (
                    <div className="flex flex-col items-center justify-center py-40">
                        <Loader2 className="w-12 h-12 text-gold animate-spin mb-6" />
                        <p className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-400">Archiving Essences...</p>
                    </div>
                ) : products.length > 0 ? (
                    <div className="container mx-auto px-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-16 gap-y-24">
                        {products.map((product, i) => (
                            <motion.div
                                key={product.id}
                                initial={{ opacity: 0, y: 30 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ duration: 0.8, delay: i * 0.1 }}
                                className="group"
                            >
                                <Link href={`/collection/${product.id}`}>
                                    <div className="relative aspect-[3/4] bg-stone-50 dark:bg-zinc-900 rounded-[3.5rem] overflow-hidden mb-10 border border-stone-100 dark:border-white/5 shadow-sm group-hover:shadow-[0_40px_80px_-20px_rgba(0,0,0,0.1)] group-hover:-translate-y-4 transition-all duration-700 ease-out">
                                        <Image
                                            src={product.images[0]?.url || '/luxury_perfume_hero_cinematic.png'}
                                            alt={product.name}
                                            fill
                                            className="object-cover transition-transform duration-[1.5s] ease-out group-hover:scale-110"
                                        />
                                        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/5 transition-colors duration-500" />

                                        {/* Category Badge */}
                                        {product.category && (
                                            <div className="absolute top-10 left-10">
                                                <span className="glass px-5 py-2 rounded-full text-[9px] font-bold tracking-[.3em] uppercase text-white shadow-xl">
                                                    {product.category.name}
                                                </span>
                                            </div>
                                        )}

                                        {/* Quick Add */}
                                        <div className="absolute bottom-10 left-10 right-10 translate-y-8 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-700">
                                            <button
                                                onClick={(e) => handleAddToCart(e, product)}
                                                className="w-full glass py-4 rounded-full text-[10px] font-bold tracking-[.3em] uppercase text-white hover:bg-white hover:text-luxury-black transition-all flex items-center justify-center gap-3 shadow-2xl cursor-pointer"
                                            >
                                                <ShoppingBag size={14} /> Add to Cart
                                            </button>
                                        </div>
                                    </div>
                                </Link>

                                <div className="text-center">
                                    <Link href={`/collection/${product.id}`}>
                                        <h3 className="text-3xl font-serif text-luxury-black dark:text-white mb-2 group-hover:italic transition-all duration-500">
                                            {product.name}
                                        </h3>
                                    </Link>
                                    <p className="text-[10px] text-stone-500 dark:text-stone-400 font-bold uppercase tracking-[.4em] mb-4 transition-colors font-serif italic">
                                        {product.brand.name}
                                    </p>
                                    <div className="w-8 h-px bg-stone-100 dark:bg-gold/20 mx-auto mb-6 transition-colors" />
                                    <span className="text-xl font-serif italic text-luxury-black dark:text-white transition-colors tracking-widest">
                                        {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: product.currency || 'VND' }).format(product.price)}
                                    </span>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                ) : (
                    <div className="flex flex-col items-center justify-center py-40">
                        <p className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-400">No Essences Found in this Collection</p>
                    </div>
                )}
            </section>
        </div>
    );
}
