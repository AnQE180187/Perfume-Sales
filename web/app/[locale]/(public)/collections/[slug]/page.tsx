"use client";

import React, { useState, useRef, useEffect } from "react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { motion, useScroll, useTransform } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { ShoppingBag, Sparkles, ArrowLeft } from "lucide-react";
import { useCart } from "@/features/cart/CartContext";
import { useTranslations } from "next-intl";

export default function CollectionDetailPage({ params }: { params: { slug: string } }) {
    const t = useTranslations("Collection");
    const h = useTranslations("Home");
    const { addToCart } = useCart();
    const [collection, setCollection] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const containerRef = useRef(null);
    const { scrollYProgress } = useScroll({
        target: containerRef,
        offset: ["start start", "end start"]
    });

    const bannerY = useTransform(scrollYProgress, [0, 0.4], ["0%", "20%"]);
    const bannerOpacity = useTransform(scrollYProgress, [0, 0.4], [1, 0.3]);

    useEffect(() => {
        const fetchCollection = async () => {
            try {
                const res = await fetch(`/api/collections/${params.slug}`);
                const data = await res.json();
                setCollection(data);
            } catch (error) {
                console.error("Failed to fetch collection:", error);
            } finally {
                setLoading(false);
            }
        };
        fetchCollection();
    }, [params.slug]);

    if (loading) return <div className="min-h-screen bg-white dark:bg-zinc-950 flex items-center justify-center">Loading...</div>;
    if (!collection) return <div className="min-h-screen bg-white dark:bg-zinc-950 flex items-center justify-center">Collection not found.</div>;

    const products = collection.products?.map((p: any) => p.product) || [];

    return (
        <div className="min-h-screen bg-white dark:bg-zinc-950 transition-colors" ref={containerRef}>
            <Navbar />

            {/* Header Visual */}
            <section className="relative h-[70vh] overflow-hidden flex items-center justify-center">
                <motion.div
                    style={{ y: bannerY, opacity: bannerOpacity }}
                    className="absolute inset-0 z-0"
                >
                    <Image
                        src={collection.image_url || "/images/collection-banner.png"}
                        alt={collection.name}
                        fill
                        className="object-cover contrast-110"
                    />
                    <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-black/20 to-transparent" />
                </motion.div>

                <div className="relative z-10 text-center px-6 max-w-4xl">
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 1, ease: [0.33, 1, 0.68, 1] }}
                    >
                        <Link href="/collection" className="inline-flex items-center gap-2 text-[10px] font-bold tracking-[.3em] uppercase text-white/70 hover:text-white transition-colors mb-12">
                            <ArrowLeft size={14} /> Back to Catalog
                        </Link>
                        <h1 className="text-6xl md:text-8xl font-serif text-white mb-8 leading-none italic">{collection.name}</h1>
                        <p className="text-white/80 text-xl font-light italic max-w-2xl mx-auto leading-relaxed">
                            {collection.description}
                        </p>
                    </motion.div>
                </div>
            </section>

            {/* Grid */}
            <section className="py-24">
                <div className="container mx-auto px-6 mb-20 flex justify-between items-center bg-stone-50 dark:bg-white/5 p-8 rounded-full transition-colors border border-stone-100 dark:border-white/5 shadow-sm">
                    <div className="flex items-center gap-3">
                        <Sparkles size={16} className="text-accent" />
                        <p className="text-[10px] text-stone-500 font-bold tracking-[.3em] uppercase">{t("showing", { count: products.length })}</p>
                    </div>
                </div>

                <div className="container mx-auto px-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-16 gap-y-24">
                    {products.map((perfume: any, i: number) => (
                        <motion.div
                            key={perfume.id}
                            initial={{ opacity: 0, y: 30 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.8, delay: i * 0.1 }}
                            className="group"
                        >
                            <Link href={`/collection/${perfume.slug || perfume.id}`}>
                                <div className="relative aspect-[3/4] bg-stone-50 dark:bg-zinc-900 rounded-[3.5rem] overflow-hidden mb-10 border border-stone-100 dark:border-white/5 shadow-sm group-hover:shadow-[0_40px_80px_-20px_rgba(0,0,0,0.1)] group-hover:-translate-y-4 transition-all duration-700 ease-out">
                                    <Image
                                        src={perfume.images?.[0]?.image_url || "/images/hero.png"}
                                        alt={perfume.name}
                                        fill
                                        className="object-cover transition-transform duration-[1.5s] ease-out group-hover:scale-110 grayscale-[0.1] group-hover:grayscale-0"
                                    />
                                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/5 transition-colors duration-500" />

                                    <div className="absolute bottom-10 left-10 right-10 translate-y-8 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-700">
                                        <button
                                            onClick={(e) => {
                                                e.preventDefault();
                                                e.stopPropagation();
                                                const variant = perfume.variants?.[0];
                                                addToCart({
                                                    id: perfume.id,
                                                    name: perfume.name,
                                                    price: variant?.price || 0,
                                                    type: variant?.concentration || "Eau de Parfum",
                                                    quantity: 1,
                                                    image: perfume.images?.[0]?.image_url || "/images/hero.png"
                                                });
                                            }}
                                            className="w-full glass py-4 rounded-full text-[10px] font-bold tracking-[.3em] uppercase text-white hover:bg-white hover:text-luxury-black transition-all flex items-center justify-center gap-3 shadow-2xl cursor-pointer"
                                        >
                                            <ShoppingBag size={14} /> {h("collectionSection.add_to_collection")}
                                        </button>
                                    </div>

                                    <div className="absolute top-10 left-10">
                                        <span className="glass px-5 py-2 rounded-full text-[9px] font-bold tracking-[.3em] uppercase text-white shadow-xl">
                                            {perfume.category?.name || "Premium"}
                                        </span>
                                    </div>
                                </div>
                            </Link>

                            <div className="text-center">
                                <Link href={`/collection/${perfume.slug || perfume.id}`}>
                                    <h3 className="text-3xl font-serif text-luxury-black dark:text-white mb-2 group-hover:italic transition-all duration-500">
                                        {perfume.name}
                                    </h3>
                                </Link>
                                <p className="text-[10px] text-stone-500 dark:text-stone-400 font-bold uppercase tracking-[.4em] mb-4 transition-colors font-serif italic">{perfume.variants?.[0]?.concentration || "Eau de Parfum"}</p>
                                <div className="w-8 h-px bg-stone-100 dark:bg-accent/20 mx-auto mb-6 transition-colors" />
                                <span className="text-xl font-serif italic text-luxury-black dark:text-white transition-colors tracking-widest">${perfume.variants?.[0]?.price || 0}</span>
                            </div>
                        </motion.div>
                    ))}
                </div>
            </section>
        </div>
    );
}
