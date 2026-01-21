"use client";

import React, { useState, useRef } from "react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { motion, useScroll, useTransform } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { Filter, ChevronDown, ShoppingBag, Sparkles, ArrowRight } from "lucide-react";
import { useCart } from "@/features/cart/CartContext";
import { useTranslations } from "next-intl";

export default function CollectionPage() {
    const t = useTranslations("Collection");
    const h = useTranslations("Home");
    const { addToCart } = useCart();
    const [activeCategory, setActiveCategory] = useState("All");
    const [products, setProducts] = useState<any[]>([]);
    const [collections, setCollections] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const containerRef = useRef(null);
    const { scrollYProgress } = useScroll({
        target: containerRef,
        offset: ["start start", "end start"]
    });

    const bannerY = useTransform(scrollYProgress, [0, 0.4], ["0%", "30%"]);
    const bannerOpacity = useTransform(scrollYProgress, [0, 0.4], [1, 0.5]);

    React.useEffect(() => {
        const fetchData = async () => {
            try {
                const [productsRes, collectionsRes] = await Promise.all([
                    fetch('/api/products'),
                    fetch('/api/collections')
                ]);

                let productsData = [];
                let collectionsData = [];

                if (productsRes.ok) {
                    const json = await productsRes.json();
                    productsData = Array.isArray(json) ? json : [];
                }

                if (collectionsRes.ok) {
                    const json = await collectionsRes.json();
                    collectionsData = Array.isArray(json) ? json : [];
                }

                setProducts(productsData);
                setCollections(collectionsData);
            } catch (error) {
                console.error("Failed to fetch data:", error);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    const filteredPerfumes = activeCategory === "All"
        ? products
        : products.filter(p => p.category?.name === activeCategory);

    return (
        <div className="min-h-screen bg-white dark:bg-zinc-950 transition-colors" ref={containerRef}>
            <Navbar />

            {/* Header Visual */}
            <section className="relative h-[60vh] overflow-hidden flex items-center justify-center">
                <motion.div
                    style={{ y: bannerY, opacity: bannerOpacity }}
                    className="absolute inset-0 z-0"
                >
                    <Image
                        src="/images/collection-banner.png"
                        alt="Collection Banner"
                        fill
                        className="object-cover contrast-110 grayscale-[0.2]"
                    />
                    <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-black/10 to-transparent" />
                </motion.div>

                <div className="relative z-10 text-center px-6">
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 1, ease: [0.33, 1, 0.68, 1] }}
                    >
                        <span className="text-white text-[10px] font-bold tracking-[.5em] uppercase mb-8 block font-serif italic">{t("span")}</span>
                        <h1 className="text-7xl md:text-9xl font-serif text-white mb-6 leading-none tracking-tighter">{t("h1_1")}<span className="italic">{t("h1_2")}</span></h1>
                        <div className="w-16 h-px bg-accent mx-auto" />
                    </motion.div>
                </div>
            </section>

            {/* Curated Collections Slider */}
            <section className="py-20 bg-stone-50 dark:bg-zinc-900/50 transition-colors">
                <div className="container mx-auto px-6">
                    <div className="flex justify-between items-end mb-12">
                        <div>
                            <span className="text-[10px] font-bold tracking-[.3em] uppercase text-accent mb-4 block">{t("curated_span")}</span>
                            <h2 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors">{t("curated_h")}</h2>
                        </div>
                    </div>

                    <div className="flex gap-8 overflow-x-auto pb-10 scrollbar-hide">
                        {Array.isArray(collections) && collections.map((col: any) => (
                            <Link key={col.id} href={`/collections/${col.slug}`} className="group flex-shrink-0 w-80">
                                <div className="relative aspect-[4/5] rounded-[2rem] overflow-hidden mb-6 shadow-lg group-hover:shadow-2xl transition-all duration-500">
                                    <Image src={col.image_url || "/images/collection-banner.png"} alt={col.name} fill className="object-cover transition-transform duration-700 group-hover:scale-110" />
                                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />
                                    <div className="absolute bottom-8 left-8 right-8">
                                        <h3 className="text-2xl font-serif text-white mb-2">{col.name}</h3>
                                        <p className="text-[10px] text-stone-300 font-bold tracking-widest uppercase opacity-0 group-hover:opacity-100 transition-opacity duration-300">{t("explore")}</p>
                                    </div>
                                </div>
                            </Link>
                        ))}
                    </div>
                </div>
            </section>

            {/* Filter Bar */}
            <section className="sticky top-24 z-20 bg-white/95 dark:bg-zinc-950/95 backdrop-blur-xl border-y border-stone-100 dark:border-white/5 transition-all py-6">
                <div className="container mx-auto px-6 flex flex-wrap items-center justify-between gap-8">
                    <div className="flex items-center gap-10 overflow-x-auto pb-2 md:pb-0 scrollbar-hide">
                        {["All", "Floral", "Woody", "Amber", "Citrus"].map((cat) => (
                            <button
                                key={cat}
                                onClick={() => setActiveCategory(cat)}
                                className={`text-[10px] font-bold tracking-[.3em] uppercase transition-all whitespace-nowrap cursor-pointer ${activeCategory === cat ? "text-accent" : "text-stone-400 hover:text-luxury-black dark:hover:text-white"
                                    }`}
                            >
                                {cat}
                            </button>
                        ))}
                    </div>

                    <div className="flex items-center gap-10">
                        <button className="flex items-center gap-3 text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white group transition-colors cursor-pointer">
                            <Filter size={14} className="group-hover:text-accent transition-colors" /> {t("refine")}
                        </button>
                        <button className="flex items-center gap-3 text-[10px] font-bold tracking-widest uppercase text-luxury-black dark:text-white group transition-colors cursor-pointer">
                            {t("sortBy")} <ChevronDown size={14} className="group-hover:text-accent transition-colors" />
                        </button>
                    </div>
                </div>
            </section>

            {/* Grid */}
            <section className="py-24">
                <div className="container mx-auto px-6 mb-20 flex justify-between items-center bg-stone-50 dark:bg-white/5 p-8 rounded-full transition-colors border border-stone-100 dark:border-white/5 shadow-sm">
                    <div className="flex items-center gap-3">
                        <Sparkles size={16} className="text-accent" />
                        <p className="text-[10px] text-stone-500 font-bold tracking-[.3em] uppercase">{t("showing", { count: filteredPerfumes.length })}</p>
                    </div>
                </div>

                <div className="container mx-auto px-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-16 gap-y-24">
                    {filteredPerfumes.map((perfume, i) => (
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

                                    {/* Quick Add Button */}
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

                                    {/* Tag */}
                                    <div className="absolute top-10 left-10">
                                        <span className="glass px-5 py-2 rounded-full text-[9px] font-bold tracking-[.3em] uppercase text-white shadow-xl">
                                            {perfume.category?.name || "Original"}
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

            {/* Call to Action */}
            <section className="py-40 bg-luxury-black text-white relative overflow-hidden">
                <div className="absolute top-0 left-0 w-full h-full bg-accent/5 blur-[150px] pointer-events-none" />
                <div className="container mx-auto px-6 max-w-4xl text-center relative z-10">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.9 }}
                        whileInView={{ opacity: 1, scale: 1 }}
                        viewport={{ once: true }}
                    >
                        <h2 className="text-5xl md:text-7xl font-serif mb-10 leading-tight italic">{t("cta_h")}</h2>
                        <p className="text-stone-500 text-xl mb-16 font-light transition-colors max-w-xl mx-auto italic">
                            {t("cta_p")}
                        </p>
                        <Link href="/consultation" className="group inline-flex items-center gap-6 px-12 py-5 bg-accent hover:bg-yellow-600 text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] transition-all shadow-[0_0_50px_rgba(202,138,4,0.3)]">
                            {t("cta_button")} <ArrowRight size={18} className="group-hover:translate-x-3 transition-transform duration-500" />
                        </Link>
                    </motion.div>
                </div>
            </section>
        </div>
    );
}
