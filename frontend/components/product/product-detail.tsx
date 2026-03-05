'use client';

import { useState } from 'react';
import { ShoppingBag, Heart, ShieldCheck, Sparkles, BrainCircuit } from 'lucide-react';
import { type Product, type ProductVariant } from '@/services/product.service';
import { cartService } from '@/services/cart.service';
import { useAuth } from '@/hooks/use-auth';
import { useRouter } from 'next/navigation';

export default function ProductDetail({ product }: { product: Product }) {
    const { isAuthenticated } = useAuth();
    const router = useRouter();
    const [selectedVariant, setSelectedVariant] = useState<ProductVariant | null>(
        product.variants?.[0] || null
    );
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [success, setSuccess] = useState(false);

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

    return (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-20">
            {/* Visual Section */}
            <div className="space-y-6">
                <div className="aspect-[4/5] glass rounded-[3rem] border-border overflow-hidden relative group">
                    {product.images?.length ? (
                        <img
                            src={product.images[0].url}
                            alt={product.name}
                            className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110"
                        />
                    ) : (
                        <div className="w-full h-full bg-secondary/20 flex items-center justify-center font-heading text-gold/30">
                            Visual Data Unavailable
                        </div>
                    )}
                    <div className="absolute inset-0 bg-gradient-to-tr from-gold/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-1000" />
                    <div className="absolute inset-x-0 bottom-0 p-12 text-center bg-gradient-to-t from-background/80 to-transparent">
                        <span className="text-gold font-heading tracking-[0.5em] uppercase text-[10px] animate-pulse inline-flex items-center gap-3">
                            <Sparkles className="w-4 h-4" /> Neural Scanning Active
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
                            {product.brand?.name || 'Elite Series'}
                        </span>
                        <span className="text-[10px] text-muted-foreground uppercase tracking-widest font-heading">
                            Archived #{product.slug.toUpperCase().slice(0, 8)}
                        </span>
                    </div>
                    <h1 className="text-5xl lg:text-7xl font-heading text-foreground uppercase tracking-tighter leading-none mb-4">
                        {product.name}
                    </h1>
                    <p className="text-3xl font-heading text-gold">
                        {selectedVariant ? fmt(selectedVariant.price) : 'Select Size'}
                    </p>
                </div>

                <div className="space-y-8 mb-12">
                    <p className="text-sm text-muted-foreground font-body leading-relaxed max-w-xl">
                        {product.description ||
                            "A masterfully curated essence that captures the intersection of urban neon and raw botanical power. Engineered to resonate with the wearer's unique olfactive signature."}
                    </p>

                    <div className="space-y-6">
                        <h3 className="text-[10px] uppercase tracking-[0.3em] font-heading text-foreground border-b border-border/50 pb-4">
                            Select Olfactory Volume (Size)
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
                                olfactory structure
                            </h3>
                            <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
                                {[
                                    { type: 'TOP', label: 'Top Notes' },
                                    { type: 'MIDDLE', label: 'Heart Notes' },
                                    { type: 'BASE', label: 'Base Notes' },
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
                            Technical Specifications
                        </h3>
                        <div className="grid grid-cols-2 gap-8">
                            <div>
                                <p className="text-[8px] text-muted-foreground uppercase tracking-widest mb-1">
                                    Concentration
                                </p>
                                <p className="text-xs font-heading text-gold uppercase tracking-widest">
                                    {product.concentration || 'Eau de Parfum'}
                                </p>
                            </div>
                            <div>
                                <p className="text-[8px] text-muted-foreground uppercase tracking-widest mb-1">
                                    Longevity
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
                    <p className="text-green-500 text-[10px] uppercase tracking-widest mb-4">Unit added to acquisition queue</p>
                )}

                <div className="flex flex-col sm:flex-row gap-4 mb-12">
                    <button
                        onClick={handleAddToCart}
                        disabled={loading || !selectedVariant}
                        className="flex-1 bg-gold text-primary-foreground h-16 rounded-full font-heading text-[10px] uppercase font-bold tracking-[0.3em] hover:scale-[1.02] active:scale-95 transition-all shadow-xl shadow-gold/20 flex items-center justify-center gap-3 disabled:opacity-50"
                    >
                        {loading ? (
                            'Processing...'
                        ) : (
                            <>
                                <ShoppingBag className="w-4 h-4" /> Assemble Acquisition
                            </>
                        )}
                    </button>
                    <button className="w-16 h-16 glass border-border rounded-full flex items-center justify-center text-muted-foreground hover:text-red-400 group transition-all">
                        <Heart className="w-5 h-5 group-hover:fill-red-400/20" />
                    </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-10 border-t border-border/50">
                    <div className="flex gap-4">
                        <div className="w-10 h-10 rounded-xl glass border-gold/10 flex items-center justify-center shrink-0">
                            <BrainCircuit className="w-5 h-5 text-gold" />
                        </div>
                        <div>
                            <h4 className="text-[10px] uppercase font-heading tracking-widest text-foreground mb-1">
                                Pattern Matching
                            </h4>
                            <p className="text-[8px] text-muted-foreground uppercase tracking-widest leading-relaxed">
                                Matches your bio-profile with 98.4% precision.
                            </p>
                        </div>
                    </div>
                    <div className="flex gap-4">
                        <div className="w-10 h-10 rounded-xl glass border-gold/10 flex items-center justify-center shrink-0">
                            <ShieldCheck className="w-5 h-5 text-gold" />
                        </div>
                        <div>
                            <h4 className="text-[10px] uppercase font-heading tracking-widest text-foreground mb-1">
                                Authenticity Shield
                            </h4>
                            <p className="text-[8px] text-muted-foreground uppercase tracking-widest leading-relaxed">
                                Indelible molecular signature for certification.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
