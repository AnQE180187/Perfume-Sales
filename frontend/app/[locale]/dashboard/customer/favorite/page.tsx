'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';
import { motion } from 'framer-motion';
import { Heart, Loader2 } from 'lucide-react';
import { Link } from '@/lib/i18n';
import { favoriteService, type FavoriteItem } from '@/services/favorite.service';
import { useTranslations, useFormatter } from 'next-intl';

export default function CustomerFavoritePage() {
  const t = useTranslations('dashboard.customer.favorite');
  const format = useFormatter();
  const [favorites, setFavorites] = useState<FavoriteItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadFavorites = async () => {
      try {
        const data = await favoriteService.getFavorites();
        setFavorites(data);
      } finally {
        setLoading(false);
      }
    };

    void loadFavorites();
    window.addEventListener(favoriteService.eventName, loadFavorites);
    return () => window.removeEventListener(favoriteService.eventName, loadFavorites);
  }, []);

  const handleRemoveFavorite = async (productId: string) => {
    await favoriteService.removeProduct(productId);
    const data = await favoriteService.getFavorites();
    setFavorites(data);
  };

  return (
    <div className="space-y-12 pb-12">
        <header>
            <div className="flex items-center gap-4 mb-4">
                <div className="h-[1px] w-12 bg-gold/50" />
                <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry</span>
            </div>
            <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
                Aesthetic <span className="gold-gradient">Curation</span>
            </h1>
            <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest text-stone-500">{t('subtitle')}</p>
        </header>

        {loading ? (
            <div className="flex h-[400px] items-center justify-center">
                <Loader2 className="h-10 w-10 animate-spin text-gold" />
            </div>
        ) : favorites.length === 0 ? (
            <div className="py-24 text-center glass rounded-[3rem]">
                <Heart className="mx-auto text-stone-200 dark:text-stone-800 mb-6" size={64} strokeWidth={1} />
                <div className="space-y-2 mb-8">
                    <h2 className="font-heading text-2xl uppercase tracking-widest text-foreground">{t('empty_title')}</h2>
                    <p className="text-[10px] uppercase font-bold tracking-[0.3em] text-stone-400 dark:text-stone-700">{t('empty_subtitle') || 'Hãy lưu giữ những mùi hương bạn yêu thích tại đây.'}</p>
                </div>
                <Link
                    href="/collection"
                    className="inline-flex h-14 items-center px-10 rounded-full bg-stone-100 dark:bg-white/5 border border-black/5 dark:border-white/10 text-[10px] font-bold uppercase tracking-widest text-stone-600 dark:text-stone-400 hover:bg-gold hover:text-black transition-all cursor-pointer"
                >
                    {t('view_collection')}
                </Link>
            </div>
        ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                {favorites.map((item) => (
                    <motion.div 
                        key={item.id} 
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="glass rounded-[2.5rem] overflow-hidden group hover:border-gold/30 transition-all shadow-2xl"
                    >
                        <div className="aspect-[4/5] bg-stone-100 dark:bg-zinc-800 relative overflow-hidden">
                            {item.imageUrl ? (
                                <Image 
                                    src={item.imageUrl} 
                                    alt={item.name} 
                                    fill 
                                    className="object-cover group-hover:scale-110 transition-transform duration-1000" 
                                />
                            ) : (
                                <div className="w-full h-full flex items-center justify-center text-stone-300 dark:text-stone-700">
                                    <Heart size={64} />
                                </div>
                            )}
                            <div className="absolute top-6 right-6 z-10">
                                <button
                                    onClick={() => void handleRemoveFavorite(item.id)}
                                    className="w-10 h-10 rounded-full glass border-black/5 dark:border-white/5 flex items-center justify-center text-red-500/40 hover:text-red-500 hover:border-red-500/50 transition-all shadow-xl cursor-pointer"
                                    title={t('remove')}
                                >
                                    <Heart size={16} fill="currentColor" />
                                </button>
                            </div>
                        </div>
                        <div className="p-8 space-y-6">
                            <div className="space-y-2">
                                <p className="text-[8px] text-gold uppercase tracking-[0.3em] font-bold">
                                    {item.brandName || t('brand_fallback')}
                                </p>
                                <h3 className="font-heading text-xl font-bold uppercase tracking-widest text-foreground leading-tight truncate">{item.name}</h3>
                                {item.variantName ? (
                                    <p className="text-[8px] text-stone-400 dark:text-stone-600 uppercase tracking-widest font-bold">
                                        {t('size_label', { name: item.variantName })}
                                    </p>
                                ) : null}
                            </div>
                            <p className="font-heading text-2xl font-bold text-foreground tracking-tighter">
                                {typeof item.price === 'number'
                                    ? format.number(item.price, { style: 'currency', currency: 'VND', maximumFractionDigits: 0 })
                                    : ''}
                            </p>
                            <Link
                                href={`/products/${item.id}`}
                                className="flex h-14 items-center justify-center rounded-2xl bg-gold text-[10px] font-bold uppercase tracking-widest text-black shadow-lg shadow-gold/20 hover:scale-[1.02] active:scale-95 transition-all"
                            >
                                {t('details')}
                            </Link>
                        </div>
                    </motion.div>
                ))}
            </div>
        )}
    </div>
  );
}
