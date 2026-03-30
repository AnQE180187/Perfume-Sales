'use client';

import { useEffect, useState } from 'react';
import { ShoppingBag, Heart, ShieldCheck, Sparkles, BrainCircuit } from 'lucide-react';
import { type Product, type ProductVariant } from '@/services/product.service';
import { cartService } from '@/services/cart.service';
import { favoriteService } from '@/services/favorite.service';
import { useAuth } from '@/hooks/use-auth';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import ReviewList from '../review/review-list';
import ReviewSummaryView from '../review/review-summary';
import StarRating from '../review/star-rating';
import { useTranslations } from 'next-intl';

export default function ProductDetail({ product }: { product: Product }) {
    const t = useTranslations('product_detail');
    const tCommon = useTranslations('common');
    const { isAuthenticated } = useAuth();
    const router = useRouter();
    const [selectedVariant, setSelectedVariant] = useState<ProductVariant | null>(
        product.variants?.[0] || null
    );
    const [loading, setLoading] = useState(false);
    const [favoriteLoading, setFavoriteLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [success, setSuccess] = useState(false);
    const [isFavorite, setIsFavorite] = useState(false);

    useEffect(() => {
        if (!isAuthenticated) return;

        let mounted = true;
        favoriteService
            .isFavorite(product.id)
            .then((value) => {
                if (mounted) setIsFavorite(value);
            })
            .catch(() => {
                if (mounted) setIsFavorite(false);
            });

        return () => {
            mounted = false;
        };
    }, [isAuthenticated, product.id]);

    const handleAddToCart = async () => {
        if (!isAuthenticated) {
            router.push('/login');
            return;
        }
        if (!selectedVariant) return;

        setLoading(true);
        setError(null);
        setSuccess(false);
        try {
            await cartService.addItem(selectedVariant.id, 1);
            setSuccess(true);
            setTimeout(() => setSuccess(false), 3000);
        } catch (e: unknown) {
            setError((e as Error).message);
        } finally {
            setLoading(false);
        }
    };

    const fmt = (n: number) =>
        new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(n);

    const handleToggleFavorite = async () => {
        if (!isAuthenticated) {
            toast.error('Vui long dang nhap de luu san pham yeu thich');
            router.push('/login');
            return;
        }

        if (favoriteLoading) return;
        if (!selectedVariant && !isFavorite) {
            toast.error('Vui long chon dung tich truoc khi them yeu thich');
            return;
        }

        setFavoriteLoading(true);
        try {
            const nextFavorite = await favoriteService.toggleProduct(product.id, isFavorite, selectedVariant?.id);
            setIsFavorite(nextFavorite);
            if (nextFavorite) {
                toast.success('Đã thêm sản phẩm vào mục yêu thích');
            } else {
                toast.success('Đã xóa sản phẩm khỏi mục yêu thích');
            }
        } catch (e: unknown) {
            toast.error((e as Error).message || 'Khong the cap nhat muc yeu thich');
        } finally {
            setFavoriteLoading(false);
        }
    };

    return (
        <div className="space-y-24">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-20">
                {/* Visual Section */}
                <div className="space-y-6">
                    <div className="aspect-4/5 glass rounded-[3rem] border-border overflow-hidden relative group">
                        {product.images?.length ? (
                            <img
                                src={product.images[0].url}
                                alt={product.name}
                                className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110"
                            />
                        ) : (
                            <div className="w-full h-full bg-secondary/20 flex items-center justify-center font-heading text-gold/30">
                                {t('visual_data_unavailable')}
                            </div>
                        )}
                        <div className="absolute inset-0 bg-linear-to-tr from-gold/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-1000" />
                        <div className="absolute inset-x-0 bottom-0 p-12 text-center bg-linear-to-t from-background/80 to-transparent">
                            <span className="text-gold font-heading tracking-[0.5em] uppercase text-[10px] animate-pulse inline-flex items-center gap-3">
                                <Sparkles className="w-4 h-4" /> {t('neural_scanning_active')}
                            </span>
                        </div>
                    </div>
                    <div className="grid grid-cols-4 gap-4">
                        {product.images?.map((img) => (
                            <div
                                key={img.id}
                                className="aspect-square glass rounded-2xl border-border cursor-pointer hover:border-gold/30 transition-all overflow-hidden"
                            >
                                <img src={img.url} alt="" className="w-full h-full object-cover" />
                            </div>
                        ))}
                    </div>
                </div>

                {/* Intellectual Section */}
                <div className="flex flex-col justify-center">
                    <div className="space-y-2 mb-8">
                        <div className="flex items-center gap-3">
                            <span className="px-3 py-1 rounded-full glass border-gold/20 text-gold text-[8px] uppercase tracking-widest font-bold">
                                {product.brand?.name || t('elite_series')}
                            </span>
                            <span className="text-[10px] text-muted-foreground uppercase tracking-widest font-heading">
                                {t('archived_hash')}{product.slug.toUpperCase().slice(0, 8)}
                            </span>
                        </div>
                        <h1 className="text-5xl lg:text-7xl font-heading text-foreground uppercase tracking-tighter leading-none mb-2">
                            {product.name}
                        </h1>
                        <div className="flex items-center gap-2 mb-4">
                            <StarRating rating={4.5} readOnly size={14} />
                            <span className="text-[10px] text-muted-foreground uppercase tracking-widest">{t('rating_label', { rating: 4.5 })}</span>
                        </div>
                        <p className="text-3xl font-heading text-gold">
                            {selectedVariant ? fmt(selectedVariant.price) : t('select_size')}
                        </p>
                    </div>

                    <div className="space-y-8 mb-12">
                        <p className="text-sm text-muted-foreground font-body leading-relaxed max-w-xl">
                            {product.description ||
                                "A masterfully curated essence that captures the intersection of urban neon and raw botanical power. Engineered to resonate with the wearer's unique olfactive signature."}
                        </p>

                        <div className="space-y-6">
                            <h3 className="text-[10px] uppercase tracking-[0.3em] font-heading text-foreground border-b border-border/50 pb-4">
                                {t('select_olfactory_volume')}
                            </h3>
                            <div className="flex flex-wrap gap-4">
                                {product.variants?.map((v) => (
                                    <button
                                        key={v.id}
                                        onClick={() => setSelectedVariant(v)}
                                        className={`p-4 rounded-2xl border transition-all flex flex-col items-center min-w-[80px] ${selectedVariant?.id === v.id
                                            ? 'bg-gold/10 border-gold text-gold scale-105'
                                            : 'glass border-border text-muted-foreground hover:border-gold/30'
                                            }`}
                                    >
                                        <span className="text-[10px] font-heading uppercase tracking-widest mb-1">
                                            {v.name}
                                        </span>
                                        <span className="text-[8px] opacity-60 font-body">{fmt(v.price)}</span>
                                    </button>
                                ))}
                            </div>
                        </div>

                        {product.notes && product.notes.length > 0 && (
                            <div className="space-y-6">
                                <h3 className="text-[10px] uppercase tracking-[0.3em] font-heading text-foreground border-b border-border/50 pb-4">
                                {t('olfactory_structure')}
                                </h3>
                                <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
                                    {[
                                        { type: 'TOP', label: t('top_notes') },
                                        { type: 'MIDDLE', label: t('heart_notes') },
                                        { type: 'BASE', label: t('base_notes') },
                                    ].map((group) => {
                                        const notes = product.notes!
                                            .filter((n) => n.note?.type === group.type)
                                            .map((n) => n.note?.name)
                                            .filter(Boolean);
                                        if (notes.length === 0) return null;
                                        return (
                                            <div key={group.type}>
                                                <p className="text-[8px] text-muted-foreground uppercase tracking-widest mb-1">
                                                    {group.label}
                                                </p>
                                                <p className="text-[10px] font-heading text-gold uppercase tracking-wider leading-relaxed">
                                                    {notes.join(', ')}
                                                </p>
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>
                        )}

                        <div className="space-y-6">
                            <h3 className="text-[10px] uppercase tracking-[0.3em] font-heading text-foreground border-b border-border/50 pb-4">
                                {t('technical_specifications')}
                            </h3>
                            <div className="grid grid-cols-2 gap-8">
                                <div>
                                    <p className="text-[8px] text-muted-foreground uppercase tracking-widest mb-1">
                                        {t('concentration')}
                                    </p>
                                    <p className="text-xs font-heading text-gold uppercase tracking-widest">
                                        {product.concentration || 'Eau de Parfum'}
                                    </p>
                                </div>
                                <div>
                                    <p className="text-[8px] text-muted-foreground uppercase tracking-widest mb-1">
                                        {t('longevity')}
                                    </p>
                                    <p className="text-xs font-heading text-gold uppercase tracking-widest">
                                        {product.longevity || 'Persistent'}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    {error && (
                        <p className="text-red-500 text-[10px] uppercase tracking-widest mb-4">{error}</p>
                    )}

                    {success && (
                        <p className="text-green-500 text-[10px] uppercase tracking-widest mb-4">{t('unit_added_queue')}</p>
                    )}

                    <div className="flex flex-col sm:flex-row gap-4 mb-12">
                        <button
                            onClick={handleAddToCart}
                            disabled={loading || !selectedVariant}
                            className="flex-1 bg-gold text-primary-foreground h-16 rounded-full font-heading text-[10px] uppercase font-bold tracking-[0.3em] hover:scale-[1.02] active:scale-95 transition-all shadow-xl shadow-gold/20 flex items-center justify-center gap-3 disabled:opacity-50"
                        >
                            {loading ? (
                                tCommon('processing')
                            ) : (
                                <>
                                    <ShoppingBag className="w-4 h-4" /> {t('assemble_acquisition')}
                                </>
                            )}
                        </button>
                        <button
                            onClick={handleToggleFavorite}
                            disabled={favoriteLoading}
                            className={`w-16 h-16 glass border-border rounded-full flex items-center justify-center group transition-all ${isFavorite ? 'text-red-700 bg-red-500/10 border-red-400/50' : 'text-muted-foreground hover:text-red-400'
                                }`}
                            aria-label={isFavorite ? 'Remove from favorites' : 'Add to favorites'}
                        >
                            <Heart className={`w-5 h-5 transition-all ${isFavorite ? 'fill-red-700/60' : 'group-hover:fill-red-400/20'}`} />
                        </button>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-10 border-t border-border/50">
                        <div className="flex gap-4">
                            <div className="w-10 h-10 rounded-xl glass border-gold/10 flex items-center justify-center shrink-0">
                                <BrainCircuit className="w-5 h-5 text-gold" />
                            </div>
                            <div>
                                <h4 className="text-[10px] uppercase font-heading tracking-widest text-foreground mb-1">
                                    {t('pattern_matching')}
                                </h4>
                                <p className="text-[8px] text-muted-foreground uppercase tracking-widest leading-relaxed">
                                    {t('pattern_matching_desc')}
                                </p>
                            </div>
                        </div>
                        <div className="flex gap-4">
                            <div className="w-10 h-10 rounded-xl glass border-gold/10 flex items-center justify-center shrink-0">
                                <ShieldCheck className="w-5 h-5 text-gold" />
                            </div>
                            <div>
                                <h4 className="text-[10px] uppercase font-heading tracking-widest text-foreground mb-1">
                                    {t('authenticity_shield')}
                                </h4>
                                <p className="text-[8px] text-muted-foreground uppercase tracking-widest leading-relaxed">
                                    {t('authenticity_shield_desc')}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Review Section */}
            <div className="space-y-12 max-w-4xl mx-auto">
                <ReviewSummaryView productId={product.id} />
                <ReviewList productId={product.id} />
            </div>
        </div>
    );
}
