'use client';

import { useState } from 'react';
import Image from 'next/image';
import { motion } from 'framer-motion';
import { ArrowLeft, ShoppingBag, Plus, Minus, Heart, Share2, Droplet, ShieldCheck, Zap } from 'lucide-react';
import { Link } from '@/lib/i18n';
import { useParams } from 'next/navigation';

// Mock product data
const MOCK_PRODUCT = {
    id: '1',
    name: 'Lumina No. 01',
    brand: 'Aura AI',
    category: 'Floral',
    price: 5900000,
    description: 'A luminous floral composition that captures the essence of dawn. Crafted with AI-guided precision, blending rare Bulgarian rose with Indonesian patchouli and white musk. Notes evolve throughout the day, revealing new dimensions of elegance.',
    images: [
        '/luxury_perfume_hero_cinematic.png',
        '/luxury_ai_scent_lab.png',
        '/luxury_perfume_auth_aesthetic.png'
    ],
    notes: {
        top: 'Bergamot, Pink Pepper, Mandarin',
        heart: 'Bulgarian Rose, Jasmine, Iris',
        base: 'Patchouli, White Musk, Sandalwood'
    },
    stock: 12
};

const RELATED_PRODUCTS = [
    { id: '2', name: 'Oud Mystère', category: 'Oriental', price: 8500000, image: '/luxury_ai_scent_lab.png' },
    { id: '3', name: 'Santal Bloom', category: 'Woody', price: 4500000, image: '/luxury_perfume_auth_aesthetic.png' },
    { id: '4', name: 'Nuit de Rose', category: 'Floral', price: 6200000, image: '/luxury_perfume_hero_cinematic.png' },
    { id: '5', name: 'Amber Noir', category: 'Oriental', price: 7800000, image: '/luxury_ai_scent_lab.png' },
];

export default function ProductDetailPage() {
    const params = useParams();
    const [quantity, setQuantity] = useState(1);
    const [selectedSize, setSelectedSize] = useState('100ml');

    const product = MOCK_PRODUCT; // In real app: fetch by params.id

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
                                src={product.images[0]}
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
                        <div className="grid grid-cols-3 gap-6">
                            {product.images.slice(1).map((image, i) => (
                                <div
                                    key={i}
                                    className="relative aspect-square rounded-3xl overflow-hidden cursor-pointer border-2 border-transparent hover:border-gold transition-all bg-white dark:bg-zinc-900 shadow-sm"
                                >
                                    <Image
                                        src={image}
                                        alt={`Preview ${i + 1}`}
                                        fill
                                        className="object-cover opacity-60 hover:opacity-100 transition-opacity"
                                    />
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Details */}
                    <div className="flex flex-col">
                        <div className="mb-8">
                            <span className="inline-block px-3 py-1 bg-gold/10 rounded-full text-[10px] font-bold tracking-wider uppercase text-gold mb-4">
                                {product.category}
                            </span>
                            <h1 className="text-5xl md:text-6xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">
                                {product.name}
                            </h1>
                            <p className="text-xl text-stone-400 dark:text-stone-500 italic transition-colors">
                                {product.brand}
                            </p>
                        </div>

                        <div className="flex items-center gap-4 mb-8">
                            <span className="text-3xl font-medium text-luxury-black dark:text-white transition-colors">
                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(product.price)}
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
                                        className="text-stone-400 hover:text-luxury-black dark:text-white transition-colors"
                                    >
                                        <Plus size={18} />
                                    </button>
                                </div>
                            </div>
                        </div>

                        {/* CTA Buttons */}
                        <div className="flex flex-col sm:flex-row gap-4 mb-16">
                            <button className="flex-1 bg-luxury-black dark:bg-gold text-white py-5 rounded-full font-bold tracking-widest uppercase flex items-center justify-center gap-3 hover:bg-stone-800 dark:hover:bg-gold/80 transition-all shadow-xl">
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
                                <div>
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">
                                        Top Notes
                                    </h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">
                                        {product.notes.top}
                                    </p>
                                </div>
                            </div>
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-gold transition-colors">
                                    <ShieldCheck size={18} />
                                </div>
                                <div>
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">
                                        Heart Notes
                                    </h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">
                                        {product.notes.heart}
                                    </p>
                                </div>
                            </div>
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-gold transition-colors">
                                    <Zap size={18} />
                                </div>
                                <div>
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">
                                        Base Notes
                                    </h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">
                                        {product.notes.base}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Related Products */}
                <section className="mt-32 pt-24 border-t border-stone-200 dark:border-white/10 transition-colors">
                    <div className="flex justify-between items-end mb-16 gap-6">
                        <div>
                            <p className="text-[10px] text-stone-500 dark:text-stone-400 font-bold tracking-[.3em] uppercase mb-4 transition-colors">
                                Curated Pairings
                            </p>
                            <h2 className="text-3xl font-serif text-luxury-black dark:text-white transition-colors">
                                Complementary Works
                            </h2>
                        </div>
                        <Link
                            href="/collection"
                            className="text-[10px] font-bold tracking-widest uppercase border-b-2 border-gold pb-1 text-luxury-black dark:text-white transition-colors"
                        >
                            Explore All
                        </Link>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                        {RELATED_PRODUCTS.map((related, i) => (
                            <motion.div
                                key={related.id}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ duration: 0.5, delay: i * 0.1 }}
                                className="group cursor-pointer text-center"
                            >
                                <Link href={`/collection/${related.id}`}>
                                    <div className="relative aspect-[3/4] bg-white dark:bg-zinc-900 mb-6 overflow-hidden rounded-2xl transition-colors border border-stone-200 dark:border-zinc-800 shadow-sm">
                                        <Image
                                            src={related.image}
                                            alt={related.name}
                                            fill
                                            className="object-cover transition-transform duration-700 group-hover:scale-110 opacity-80 group-hover:opacity-100"
                                        />
                                        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/5 transition-colors duration-500" />
                                    </div>
                                    <p className="text-[9px] text-stone-500 dark:text-stone-400 font-bold tracking-widest uppercase mb-1 transition-colors">
                                        {related.category}
                                    </p>
                                    <h4 className="text-lg font-serif text-luxury-black dark:text-white transition-colors">
                                        {related.name}
                                    </h4>
                                    <p className="text-xs font-medium text-gold mt-2 transition-colors">
                                        {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(related.price)}
                                    </p>
                                </Link>
                            </motion.div>
                        ))}
                    </div>
                </section>
            </main>
        </div>
    );
}
