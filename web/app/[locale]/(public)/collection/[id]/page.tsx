"use client";

import React, { useState } from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { ArrowLeft, ShoppingBag, Plus, Minus, Heart, Share2, Sparkles, Droplet, ShieldCheck, Zap } from "lucide-react";
import { Link } from "@/i18n/routing";

export default function ProductDetailPage({ params }: { params: { id: string } }) {
    const [product, setProduct] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [quantity, setQuantity] = useState(1);
    const [selectedSize, setSelectedSize] = useState("");

    React.useEffect(() => {
        const fetchProduct = async () => {
            try {
                const res = await fetch(`/api/products/${params.id}`);
                const data = await res.json();
                setProduct(data);
                if (data.variants?.length > 0) {
                    setSelectedSize(`${data.variants[0].volume_ml}ml`);
                }
            } catch (error) {
                console.error("Failed to fetch product:", error);
            } finally {
                setLoading(false);
            }
        };
        fetchProduct();
    }, [params.id]);

    if (loading) return <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex items-center justify-center text-luxury-black dark:text-white">Loading...</div>;
    if (!product) return <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex items-center justify-center text-luxury-black dark:text-white">Product not found.</div>;

    const currentVariant = product.variants?.find((v: any) => `${v.volume_ml}ml` === selectedSize) || product.variants?.[0];

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <Navbar />

            <main className="container mx-auto px-6 py-32">
                <Link href="/collection" className="inline-flex items-center gap-2 text-xs font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors mb-12">
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
                                src={product.images?.[0]?.image_url || "/images/hero.png"}
                                alt={product.name}
                                fill
                                className="object-cover"
                            />
                            <div className="absolute top-8 right-8 flex flex-col gap-4">
                                <button className="p-3 glass rounded-full text-luxury-black hover:bg-white transition-colors cursor-pointer">
                                    <Heart size={20} />
                                </button>
                                <button className="p-3 glass rounded-full text-luxury-black hover:bg-white transition-colors cursor-pointer">
                                    <Share2 size={20} />
                                </button>
                            </div>
                        </motion.div>

                        <div className="grid grid-cols-3 gap-6">
                            {product.images?.slice(1, 4).map((img: any, i: number) => (
                                <div key={i} className="relative aspect-square rounded-3xl overflow-hidden cursor-pointer border-2 border-transparent hover:border-accent transition-all bg-white dark:bg-zinc-900 shadow-sm">
                                    <Image src={img.image_url} alt="Preview" fill className="object-cover opacity-60 hover:opacity-100 transition-opacity" />
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Details */}
                    <div className="flex flex-col">
                        <div className="mb-8">
                            <span className="inline-block px-3 py-1 bg-accent/10 rounded-full text-[10px] font-bold tracking-wider uppercase text-accent mb-4">
                                {product.category?.name || "Premium Scent"}
                            </span>
                            <h1 className="text-5xl md:text-6xl font-serif text-luxury-black dark:text-white mb-2 transition-colors">{product.name}</h1>
                            <p className="text-xl text-stone-400 dark:text-stone-500 italic transition-colors">
                                {currentVariant?.concentration || product.variants?.[0]?.concentration || "Extrait de Parfum"}
                            </p>
                        </div>

                        <div className="flex items-center gap-4 mb-8">
                            <span className="text-3xl font-medium text-luxury-black dark:text-white transition-colors">
                                ${currentVariant?.price || product.variants?.[0]?.price || 0}
                            </span>
                            <div className="w-px h-6 bg-stone-200 dark:bg-white/10" />
                            <div className="flex items-center gap-1 text-accent">
                                <Sparkles size={16} />
                                <span className="text-xs font-bold tracking-widest uppercase">98% AI Match</span>
                            </div>
                        </div>

                        <p className="text-stone-600 dark:text-stone-400 leading-relaxed mb-10 text-lg transition-colors">
                            {product.description || "A celestial composition that defies boundaries. Opening with ethereal brightness and descending into a heart of pure essence."}
                        </p>

                        <div className="space-y-8 mb-12">
                            <div>
                                <h4 className="text-xs font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white mb-4 transition-colors">Bottle Size</h4>
                                <div className="flex gap-4">
                                    {product.variants?.map((v: any) => (
                                        <button
                                            key={v.id}
                                            onClick={() => setSelectedSize(`${v.volume_ml}ml`)}
                                            className={`px-8 py-3 rounded-full text-xs font-bold tracking-widest uppercase transition-all border cursor-pointer ${selectedSize === `${v.volume_ml}ml`
                                                ? "bg-luxury-black dark:bg-accent text-white border-luxury-black dark:border-accent shadow-lg"
                                                : "border-stone-200 dark:border-white/10 text-stone-400 hover:border-luxury-black dark:hover:border-white"
                                                }`}
                                        >
                                            {v.volume_ml}ml
                                        </button>
                                    ))}
                                </div>
                            </div>

                            <div>
                                <h4 className="text-xs font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white mb-4 transition-colors">Quantity</h4>
                                <div className="inline-flex items-center gap-6 glass dark:bg-white/5 px-6 py-3 rounded-full border border-stone-200 dark:border-white/10 transition-colors">
                                    <button onClick={() => setQuantity(Math.max(1, quantity - 1))} className="text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors cursor-pointer">
                                        <Minus size={18} />
                                    </button>
                                    <span className="text-sm font-bold w-4 text-center text-luxury-black dark:text-white transition-colors">{quantity}</span>
                                    <button onClick={() => setQuantity(quantity + 1)} className="text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors cursor-pointer">
                                        <Plus size={18} />
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div className="flex flex-col sm:flex-row gap-4 mb-16">
                            <button className="flex-1 bg-luxury-black dark:bg-accent text-white py-5 rounded-full font-bold tracking-widest uppercase flex items-center justify-center gap-3 hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-xl cursor-pointer">
                                <ShoppingBag size={20} /> Add to Cart
                            </button>
                            <button className="flex-1 border border-luxury-black dark:border-white/20 text-luxury-black dark:text-white py-5 rounded-full font-bold tracking-widest uppercase hover:bg-luxury-black dark:hover:bg-white/5 hover:text-white transition-all transition-colors cursor-pointer">
                                Personalize This Gift
                            </button>
                        </div>

                        {/* Note Indicators */}
                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pt-12 border-t border-stone-200 dark:border-white/10 transition-colors">
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-accent transition-colors">
                                    <Droplet size={18} />
                                </div>
                                <div>
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">Top Notes</h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">{product.scent_notes?.top || "Bergamot, Tea"}</p>
                                </div>
                            </div>
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-accent transition-colors">
                                    <ShieldCheck size={18} />
                                </div>
                                <div>
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">Heart Notes</h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">{product.scent_notes?.heart || "Jasmine, Iris"}</p>
                                </div>
                            </div>
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-full bg-white dark:bg-zinc-900 shadow-sm flex items-center justify-center text-accent transition-colors">
                                    <Zap size={18} />
                                </div>
                                <div>
                                    <h5 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 mb-1 transition-colors">Base Notes</h5>
                                    <p className="text-xs font-medium text-luxury-black dark:text-white transition-colors">{product.scent_notes?.base || "Sandalwood, Amber"}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Related Products */}
                <section className="mt-32 pt-24 border-t border-stone-200 dark:border-white/10 transition-colors">
                    <div className="flex justify-between items-end mb-16 gap-6">
                        <div>
                            <p className="text-[10px] text-stone-500 dark:text-stone-400 font-bold tracking-[.3em] uppercase mb-4 transition-colors">Curated Pairings</p>
                            <h2 className="text-3xl font-serif text-luxury-black dark:text-white transition-colors">Complementary Works</h2>
                        </div>
                        <Link href="/collection" className="text-[10px] font-bold tracking-widest uppercase border-b-2 border-accent pb-1 text-luxury-black dark:text-white transition-colors">
                            Explore All
                        </Link>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                        {[
                            { name: "Oud Mystère", price: "$380", type: "Pure Essence", img: "/images/hero.png" },
                            { name: "Santal Bloom", price: "$195", type: "Eau de Parfum", img: "/images/hero.png" },
                            { name: "Midnight Jasmine", price: "$210", type: "Floral", img: "/images/hero.png" },
                            { name: "White Sandalwood", price: "$225", type: "Woody", img: "/images/hero.png" }
                        ].map((perfume, i) => (
                            <motion.div
                                key={i}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ duration: 0.5, delay: i * 0.1 }}
                                className="group cursor-pointer text-center"
                            >
                                <div className="relative aspect-[3/4] bg-white dark:bg-zinc-900 mb-6 overflow-hidden rounded-2xl transition-colors border border-stone-200 dark:border-zinc-800 shadow-sm">
                                    <Image
                                        src={perfume.img}
                                        alt={perfume.name}
                                        fill
                                        className="object-cover transition-transform duration-700 group-hover:scale-110 opacity-80 group-hover:opacity-100"
                                    />
                                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/5 transition-colors duration-500" />
                                </div>
                                <p className="text-[9px] text-stone-500 dark:text-stone-400 font-bold tracking-widest uppercase mb-1 transition-colors">{perfume.type}</p>
                                <h4 className="text-lg font-serif text-luxury-black dark:text-white transition-colors">{perfume.name}</h4>
                                <p className="text-xs font-medium text-accent mt-2 transition-colors">{perfume.price}</p>
                            </motion.div>
                        ))}
                    </div>
                </section>
            </main>
        </div>
    );
}
