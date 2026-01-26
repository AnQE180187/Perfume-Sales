'use client';

import { useState, useEffect } from 'react';
import Image from 'next/image';
import { motion } from 'framer-motion';
import { ArrowLeft, ShoppingBag, Plus, Minus, Heart, Share2, Droplet, ShieldCheck, Zap } from 'lucide-react';
import { Link } from '@/lib/i18n';
import { useParams } from 'next/navigation';
import { productService } from '@/services/product.service';
import { cartService } from '@/services/cart.service';
import { useAuth } from '@/hooks/use-auth';

type ProductDetail = Awaited<ReturnType<typeof productService.getById>>;

export default function ProductDetailPage() {
  const params = useParams<{ id: string }>();
  const id = params?.id;
  const [product, setProduct] = useState<ProductDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const [adding, setAdding] = useState(false);
  const { isAuthenticated } = useAuth();

  useEffect(() => {
    if (!id) {
      setLoading(false);
      return;
    }
    productService
      .getById(id)
      .then(setProduct)
      .catch(() => setProduct(null))
      .finally(() => setLoading(false));
  }, [id]);

  const handleAddToCart = async () => {
    if (!product || !isAuthenticated) {
      window.location.href = '/login';
      return;
    }
    setAdding(true);
    try {
      await cartService.addItem(product.id, quantity);
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error(err);
    } finally {
      setAdding(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 pt-32 flex items-center justify-center">
        <span className="text-stone-400 uppercase tracking-widest">Loading…</span>
      </div>
    );
  }
  if (!product) {
    return (
      <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 pt-32 flex flex-col items-center justify-center gap-6">
        <p className="text-stone-500">Product not found.</p>
        <Link href="/collection" className="text-gold hover:underline uppercase tracking-widest text-sm">
          Back to Collection
        </Link>
      </div>
    );
  }

  const mainImage = product.images?.[0]?.url;
  const notes = (product as { notes?: { note: { name: string; type: string } }[] })?.notes ?? [];
  const topNotes = notes.filter((n) => n.note?.type === 'TOP').map((n) => n.note?.name).filter(Boolean);
  const heartNotes = notes.filter((n) => n.note?.type === 'MIDDLE').map((n) => n.note?.name).filter(Boolean);
  const baseNotes = notes.filter((n) => n.note?.type === 'BASE').map((n) => n.note?.name).filter(Boolean);

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors pt-32">
      <main className="container mx-auto px-6 py-12">
        <Link
          href="/collection"
          className="inline-flex items-center gap-2 text-xs font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors mb-12"
        >
          <ArrowLeft size={16} /> Back to Collection
        </Link>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 xl:gap-24">
          {/* Gallery */}
          <div className="space-y-6">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="relative aspect-square rounded-[3rem] overflow-hidden shadow-2xl bg-white dark:bg-zinc-900 transition-colors"
            >
              {mainImage ? (
                <img src={mainImage} alt={product.name} className="w-full h-full object-cover" />
              ) : (
                <Image
                  src="/luxury_perfume_hero_cinematic.png"
                  alt={product.name}
                  fill
                  className="object-cover"
                  priority
                />
              )}
              <div className="absolute top-8 right-8 flex flex-col gap-4">
                <button className="p-3 glass rounded-full text-white hover:bg-white/20 transition-colors">
                  <Heart size={20} />
                </button>
                <button className="p-3 glass rounded-full text-white hover:bg-white/20 transition-colors">
                  <Share2 size={20} />
                </button>
              </div>
            </motion.div>

            {/* Thumbnails */}
            {(product.images?.length ?? 0) > 1 && (
              <div className="grid grid-cols-3 gap-6">
                {product.images!.slice(1).map((img: { id: number; url: string; order: number }, i: number) => (
                  <div
                    key={img.id}
                    className="relative aspect-square rounded-3xl overflow-hidden cursor-pointer border-2 border-transparent hover:border-gold transition-all bg-white dark:bg-zinc-900 shadow-sm"
                  >
                    <img src={img.url} alt={`Preview ${i + 1}`} className="w-full h-full object-cover opacity-60 hover:opacity-100 transition-opacity" />
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Details */}
          <div className="flex flex-col">
            <div className="mb-8">
              <span className="inline-block px-3 py-1 bg-gold/10 rounded-full text-[10px] font-bold tracking-wider uppercase text-gold mb-4">
                {product.category?.name ?? product.concentration ?? '—'}
              </span>
              <h1 className="text-5xl md:text-6xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">
                {product.name}
              </h1>
              <p className="text-xl text-stone-400 dark:text-stone-500 italic transition-colors">{product.brand?.name ?? '—'}</p>
            </div>

            <div className="flex items-center gap-4 mb-8">
              <span className="text-3xl font-medium text-luxury-black dark:text-white transition-colors">
                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: product.currency || 'VND' }).format(product.price)}
              </span>
            </div>

            <p className="text-stone-600 dark:text-stone-400 leading-relaxed mb-10 text-lg transition-colors">
              {product.description || 'No description.'}
            </p>

            {/* Quantity */}
            <div className="space-y-8 mb-12">
              <div>
                <h4 className="text-xs font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white mb-4 transition-colors">
                  Quantity
                </h4>
                <div className="inline-flex items-center gap-6 glass dark:bg-white/5 px-6 py-3 rounded-full border border-stone-200 dark:border-white/10 transition-colors">
                  <button
                    onClick={() => setQuantity((q) => Math.max(1, q - 1))}
                    className="text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors"
                  >
                    <Minus size={18} />
                  </button>
                  <span className="text-sm font-bold w-4 text-center text-luxury-black dark:text-white transition-colors">{quantity}</span>
                  <button
                    onClick={() => setQuantity((q) => q + 1)}
                    className="text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors"
                  >
                    <Plus size={18} />
                  </button>
                </div>
              </div>
            </div>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4 mb-16">
              <button
                onClick={handleAddToCart}
                disabled={adding}
                className="flex-1 bg-luxury-black dark:bg-gold text-white py-5 rounded-full font-bold tracking-widest uppercase flex items-center justify-center gap-3 hover:bg-stone-800 dark:hover:bg-gold/80 transition-all shadow-xl disabled:opacity-50"
              >
                <ShoppingBag size={20} /> {adding ? 'Adding…' : 'Add to Cart'}
              </button>
            </div>

            {/* Fragrance Notes */}
            {(topNotes.length > 0 || heartNotes.length > 0 || baseNotes.length > 0) && (
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pt-12 border-t border-stone-200 dark:border-white/10 transition-colors">
                <div className="flex gap-4">
                  <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-gold transition-colors">
                    <Droplet size={18} />
                  </div>
                  <div>
                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">Top Notes</h5>
                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">{topNotes.join(', ') || '—'}</p>
                  </div>
                </div>
                <div className="flex gap-4">
                  <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-gold transition-colors">
                    <ShieldCheck size={18} />
                  </div>
                  <div>
                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">Heart Notes</h5>
                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">{heartNotes.join(', ') || '—'}</p>
                  </div>
                </div>
                <div className="flex gap-4">
                  <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-gold transition-colors">
                    <Zap size={18} />
                  </div>
                  <div>
                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">Base Notes</h5>
                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">{baseNotes.join(', ') || '—'}</p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
