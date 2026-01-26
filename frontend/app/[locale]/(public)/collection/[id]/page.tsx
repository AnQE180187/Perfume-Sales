'use client';

import { useState, useEffect } from 'react';
import Image from 'next/image';
import { motion } from 'framer-motion';
import { ArrowLeft, ShoppingBag, Plus, Minus, Heart, Share2, Droplet, ShieldCheck, Zap, Loader2 } from 'lucide-react';
import { Link } from '@/lib/i18n';
import { useParams } from 'next/navigation';
import { catalogService, Product } from '@/services/catalog.service';
import { useCartStore } from '@/store/cart.store';
import { toast } from 'sonner';

export default function ProductDetailPage() {
    const params = useParams();
    const { addItem } = useCartStore();
    const [product, setProduct] = useState<Product | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [quantity, setQuantity] = useState(1);
    const [selectedSize, setSelectedSize] = useState('100ml');
    const [activeImage, setActiveImage] = useState(0);

    const handleAddToCart = () => {
        if (!product) return;

        addItem({
            id: `${product.id}-${selectedSize}`,
            productId: product.id,
            name: product.name,
            price: product.price,
            image: product.images[0]?.url || '/luxury_perfume_hero_cinematic.png',
            quantity: quantity,
            size: selectedSize,
            brand: product.brand.name
        });
        toast.success(`Synthesized ${quantity}x ${product.name} to your collection`, {
            description: "View your collection to proceed to checkout",
            action: {
                label: "View Collection",
                onClick: () => window.location.href = '/cart'
            },
        });
    };

    useEffect(() => {
        if (params.id) {
            fetchProduct(params.id as string);
        }
    }, [params.id]);

    const fetchProduct = async (id: string) => {
        setIsLoading(true);
        try {
            const data = await catalogService.getProduct(id);
            setProduct(data);
        } catch (error) {
            console.error('Failed to fetch product:', error);
        } finally {
            setIsLoading(false);
        }
    };

    if (isLoading) {
        return (
            <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex flex-col items-center justify-center p-6">
                <Loader2 className="w-12 h-12 text-gold animate-spin mb-6" />
                <p className="text-[10px] font-bold tracking-[.4em] uppercase text-stone-400">Synthesizing Olfactory Data...</p>
            </div>
        );
    }

    if (!product) {
        return (
            <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex flex-col items-center justify-center p-6">
                <h1 className="text-2xl font-serif text-luxury-black dark:text-white mb-4">Essence Not Found</h1>
                <Link href="/collection" className="text-gold hover:underline">Return to Collection</Link>
            </div>
        );
    }

    // Helper to group notes
    const getNotesByType = (type: string) => {
        return product.notes
            ?.filter((n: any) => n.note.type === type)
            ?.map((n: any) => n.note.name)
            ?.join(', ') || 'Archival Secret';
    };

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors pt-32">
            <main className="container mx-auto px-6 py-12">
                {/* Back Button */}
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
                            <Image
                                src={product.images[activeImage]?.url || '/luxury_perfume_hero_cinematic.png'}
                                alt={product.name}
                                fill
                                className="object-cover"
                                priority
                            />
                            {/* Action Buttons */}
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
                        {product.images.length > 1 && (
                            <div className="grid grid-cols-4 gap-6">
                                {product.images.map((image: any, i: number) => (
                                    <div
                                        key={image.id}
                                        onClick={() => setActiveImage(i)}
                                        className={`relative aspect-square rounded-3xl overflow-hidden cursor-pointer border-2 transition-all bg-white dark:bg-zinc-900 shadow-sm ${activeImage === i ? 'border-gold' : 'border-transparent'
                                            }`}
                                    >
                                        <Image
                                            src={image.url}
                                            alt={`Preview ${i + 1}`}
                                            fill
                                            className={`object-cover transition-opacity ${activeImage === i ? 'opacity-100' : 'opacity-60 hover:opacity-100'
                                                }`}
                                        />
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Details */}
                    <div className="flex flex-col">
                        <div className="mb-8">
                            {product.category && (
                                <span className="inline-block px-3 py-1 bg-gold/10 rounded-full text-[10px] font-bold tracking-wider uppercase text-gold mb-4">
                                    {product.category.name}
                                </span>
                            )}
                            <h1 className="text-5xl md:text-6xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">
                                {product.name}
                            </h1>
                            <p className="text-xl text-stone-400 dark:text-stone-500 italic transition-colors">
                                {product.brand.name}
                            </p>
                        </div>

                        <div className="flex items-center gap-4 mb-8">
                            <span className="text-3xl font-medium text-luxury-black dark:text-white transition-colors">
                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: product.currency || 'VND' }).format(product.price)}
                            </span>
                        </div>

                        <p className="text-stone-600 dark:text-stone-400 leading-relaxed mb-10 text-lg transition-colors">
                            {product.description}
                        </p>

                        {/* Size Selection */}
                        <div className="space-y-8 mb-12">
                            <div>
                                <h4 className="text-xs font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white mb-4 transition-colors">
                                    Bottle Size
                                </h4>
                                <div className="flex gap-4">
                                    {['50ml', '100ml', '200ml'].map((size) => (
                                        <button
                                            key={size}
                                            onClick={() => setSelectedSize(size)}
                                            className={`px-8 py-3 rounded-full text-xs font-bold tracking-widest uppercase transition-all border ${selectedSize === size
                                                ? 'bg-luxury-black dark:bg-gold text-white border-luxury-black dark:border-gold shadow-lg'
                                                : 'border-stone-200 dark:border-white/10 text-stone-400 hover:border-luxury-black dark:hover:border-white'
                                                }`}
                                        >
                                            {size}
                                        </button>
                                    ))}
                                </div>
                            </div>

                            {/* Quantity */}
                            <div>
                                <h4 className="text-xs font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white mb-4 transition-colors">
                                    Quantity
                                </h4>
                                <div className="inline-flex items-center gap-6 glass dark:bg-white/5 px-6 py-3 rounded-full border border-stone-200 dark:border-white/10 transition-colors">
                                    <button
                                        onClick={() => setQuantity(Math.max(1, quantity - 1))}
                                        className="text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors"
                                    >
                                        <Minus size={18} />
                                    </button>
                                    <span className="text-sm font-bold w-4 text-center text-luxury-black dark:text-white transition-colors">
                                        {quantity}
                                    </span>
                                    <button
                                        onClick={() => setQuantity(quantity + 1)}
                                        className="text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors"
                                    >
                                        <Plus size={18} />
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div className="flex flex-col sm:flex-row gap-4 mb-16">
                            <button
                                onClick={handleAddToCart}
                                className="flex-1 bg-luxury-black dark:bg-gold text-white py-5 rounded-full font-bold tracking-widest uppercase flex items-center justify-center gap-3 hover:bg-stone-800 dark:hover:bg-gold/80 transition-all shadow-xl"
                            >
                                <ShoppingBag size={20} /> Add to Cart
                            </button>
                            <button className="flex-1 border border-luxury-black dark:border-white/20 text-luxury-black dark:text-white py-5 rounded-full font-bold tracking-widest uppercase hover:bg-luxury-black dark:hover:bg-white/5 hover:text-white transition-all">
                                Personalize Gift
                            </button>
                        </div>

                        {/* Fragrance Notes */}
                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pt-12 border-t border-stone-200 dark:border-white/10 transition-colors">
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-gold transition-colors">
                                    <Droplet size={18} />
                                </div>
                                <div className="flex-1 overflow-hidden">
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">
                                        Top Notes
                                    </h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors truncate">
                                        {getNotesByType('TOP')}
                                    </p>
                                </div>
                            </div>
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-gold transition-colors">
                                    <ShieldCheck size={18} />
                                </div>
                                <div className="flex-1 overflow-hidden">
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">
                                        Heart Notes
                                    </h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors truncate">
                                        {getNotesByType('MIDDLE')}
                                    </p>
                                </div>
                            </div>
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-gold transition-colors">
                                    <Zap size={18} />
                                </div>
                                <div className="flex-1 overflow-hidden">
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">
                                        Base Notes
                                    </h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors truncate">
                                        {getNotesByType('BASE')}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Related Products Section could be added here later with real data */}
            </main>
        </div>
    );
}
