"use client";

import React, { useRef } from "react";
import Image from "next/image";
import { Link } from "@/i18n/routing";
import { motion, useScroll, useTransform } from "framer-motion";
import { Navbar } from "@/components/layout/Navbar";
import { ArrowRight, Sparkles, Droplets, Wind, Shield } from "lucide-react";
import { useTranslations } from "next-intl";

export default function Home() {
  const t = useTranslations("Home");
  const f = useTranslations("Footer");
  const n = useTranslations("Navbar");
  const a = useTranslations("Auth");
  const containerRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end start"]
  });

  const heroY = useTransform(scrollYProgress, [0, 1], ["0%", "50%"]);
  const heroScale = useTransform(scrollYProgress, [0, 1], [1, 1.2]);
  const heroOpacity = useTransform(scrollYProgress, [0, 0.5], [1, 0]);

  return (
    <div className="relative min-h-screen bg-white dark:bg-zinc-950 transition-colors" ref={containerRef}>
      <Navbar />

      {/* Hero Section */}
      <section className="relative h-screen flex items-center overflow-hidden">
        <motion.div
          style={{ y: heroY, scale: heroScale }}
          className="absolute inset-0 z-0"
        >
          <Image
            src="/images/hero.png"
            alt="Luxury Fragrance"
            fill
            className="object-cover"
            priority
          />
          <div className="absolute inset-0 bg-black/30" />
        </motion.div>

        <div className="container mx-auto px-6 relative z-10">
          <motion.div
            style={{ opacity: heroOpacity }}
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 1.2, ease: [0.33, 1, 0.68, 1] }}
            className="max-w-2xl text-white"
          >
            <motion.span
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5 }}
              className="inline-block px-4 py-1.5 glass rounded-full text-[10px] font-bold tracking-[.4em] uppercase mb-8"
            >
              {t("hero.span")}
            </motion.span>
            <h1 className="text-7xl md:text-9xl font-serif mb-8 leading-[0.9] tracking-tighter">
              {t("hero.h1_1")} <br />
              <span className="italic font-light">{t("hero.h1_2")}</span>
            </h1>
            <p className="text-xl md:text-2xl text-stone-200 mb-12 font-light leading-relaxed max-w-lg italic">
              {t("hero.p")}
            </p>
            <div className="flex flex-wrap gap-6 mt-8">
              <Link href="/consultation" className="group px-10 py-5 bg-accent hover:bg-yellow-600 text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] flex items-center gap-4 transition-all shadow-xl">
                {t("hero.cta1")} <ArrowRight size={18} className="group-hover:translate-x-2 transition-transform" />
              </Link>
              <Link href="/collection" className="px-10 py-5 glass hover:bg-white/20 text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] transition-all">
                {t("hero.cta2")}
              </Link>
            </div>
          </motion.div>
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.5, duration: 1 }}
          className="absolute bottom-10 left-1/2 -translate-x-1/2 flex flex-col items-center gap-4 pointer-events-none"
        >
          <span className="text-[10px] uppercase tracking-[0.5em] text-white/40 font-bold">{t("hero.scroll")}</span>
          <motion.div
            animate={{ y: [0, 10, 0] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            className="w-px h-16 bg-gradient-to-b from-white/60 to-transparent"
          />
        </motion.div>
      </section>

      {/* AI Personalization Section */}
      <section className="py-40 bg-stone-50 dark:bg-zinc-900/40 overflow-hidden transition-colors" id="ai-concierge">
        <div className="container mx-auto px-6">
          <div className="grid md:grid-cols-2 gap-24 items-center">
            <motion.div
              initial={{ opacity: 0, x: -30 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true, margin: "-100px" }}
              transition={{ duration: 1 }}
            >
              <div className="flex items-center gap-3 text-accent mb-8">
                <Sparkles size={20} />
                <span className="text-[10px] font-bold tracking-[.4em] uppercase italic">{t("aiSection.span")}</span>
              </div>
              <h2 className="text-5xl md:text-7xl font-serif mb-10 leading-[1.1] text-luxury-black dark:text-white transition-colors">
                {t("aiSection.h2_1")} <br />
                <span className="italic">{t("aiSection.h2_2")}</span>
              </h2>
              <p className="text-xl text-stone-500 dark:text-stone-400 mb-14 leading-relaxed font-light transition-colors">
                {t("aiSection.p")}
              </p>

              <div className="space-y-10 mb-16">
                {[
                  { icon: Droplets, title: t("aiSection.feature1_title"), desc: t("aiSection.feature1_desc") },
                  { icon: Wind, title: t("aiSection.feature2_title"), desc: t("aiSection.feature2_desc") },
                  { icon: Shield, title: t("aiSection.feature3_title"), desc: t("aiSection.feature3_desc") }
                ].map((feature, i) => (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ delay: i * 0.2 }}
                    className="flex gap-6 group cursor-default"
                  >
                    <div className="w-16 h-16 rounded-[1.5rem] bg-white dark:bg-zinc-800 shadow-sm border border-stone-100 dark:border-white/5 flex items-center justify-center text-accent group-hover:scale-110 group-hover:bg-accent group-hover:text-white transition-all duration-500">
                      <feature.icon size={28} strokeWidth={1} />
                    </div>
                    <div className="flex-1">
                      <h4 className="text-lg font-serif text-luxury-black dark:text-white mb-2 transition-colors uppercase tracking-widest">{feature.title}</h4>
                      <p className="text-stone-400 dark:text-stone-500 text-sm leading-relaxed transition-colors font-light italic">{feature.desc}</p>
                    </div>
                  </motion.div>
                ))}
              </div>

              <Link href="/consultation" className="group px-12 py-5 border-2 border-luxury-black dark:border-accent text-luxury-black dark:text-white hover:bg-luxury-black dark:hover:bg-accent hover:text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] transition-all inline-flex items-center gap-4">
                {t("aiSection.cta")} <ArrowRight size={16} className="group-hover:translate-x-2 transition-transform" />
              </Link>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 1.2, ease: [0.33, 1, 0.68, 1] }}
              className="relative aspect-[4/5] md:aspect-[3/4] rounded-[4rem] overflow-hidden shadow-[0_50px_100px_-20px_rgba(0,0,0,0.3)]"
            >
              <Image
                src="/images/ai-consultation.png"
                alt="AI Consultation Interface"
                fill
                className="object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-luxury-black/60 to-transparent" />
              <div className="absolute bottom-12 left-12 right-12 p-10 glass-dark backdrop-blur-xl rounded-[2.5rem] border border-white/10">
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-12 h-12 rounded-full bg-accent/20 flex items-center justify-center">
                    <Sparkles className="text-accent" size={24} />
                  </div>
                  <div>
                    <h5 className="text-white font-serif text-lg">{t("aiSection.analysis_h")}</h5>
                    <p className="text-[9px] uppercase tracking-[.3em] text-white/50">{t("aiSection.analysis_p")}</p>
                  </div>
                </div>
                <div className="space-y-4">
                  <div className="h-1 w-full bg-white/10 rounded-full overflow-hidden">
                    <motion.div
                      initial={{ width: 0 }}
                      whileInView={{ width: "92%" }}
                      transition={{ duration: 2.5, ease: "easeOut" }}
                      className="h-full bg-accent shadow-[0_0_15px_rgba(202,138,4,0.8)]"
                    />
                  </div>
                  <div className="flex justify-between text-[10px] text-white/80 tracking-[.4em] uppercase font-bold">
                    <span>{t("aiSection.affinity")}</span>
                    <span className="text-accent">92.4%</span>
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Product Grid */}
      <section className="py-40 bg-white dark:bg-zinc-950 transition-colors" id="collections">
        <div className="container mx-auto px-6">
          <div className="flex flex-col md:flex-row justify-between items-end mb-24 gap-12">
            <div className="max-w-2xl">
              <p className="text-[10px] text-stone-400 dark:text-stone-500 font-bold tracking-[.5em] uppercase mb-6 transition-colors font-serif italic">{t("collectionSection.span")}</p>
              <h2 className="text-6xl md:text-8xl font-serif text-luxury-black dark:text-white transition-colors leading-none tracking-tighter">{t("collectionSection.h2_1")} <br /><span className="italic">{t("collectionSection.h2_2")}</span></h2>
            </div>
            <Link href="/collection" className="group text-[10px] font-bold tracking-[.4em] uppercase border-b-2 border-accent pb-2 text-luxury-black dark:text-white transition-colors flex items-center gap-4">
              {t("collectionSection.cta")} <ArrowRight size={16} className="group-hover:translate-x-2 transition-transform" />
            </Link>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-16 xl:gap-24">
            {[
              { name: "Lumina No. 01", price: "240", type: "Extrait de Parfum", img: "/images/hero.png", accent: "Floral" },
              { name: "Oud Mystère", price: "380", type: "Pure Essence", img: "/images/hero.png", accent: "Oriental" },
              { name: "Santal Bloom", price: "195", type: "Eau de Parfum", img: "/images/hero.png", accent: "Woody" }
            ].map((perfume, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 40 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: i * 0.2 }}
                className="group cursor-pointer"
              >
                <div className="relative aspect-[3/4] bg-stone-50 dark:bg-zinc-900 mb-10 overflow-hidden rounded-[3.5rem] transition-all border border-stone-100 dark:border-white/5 shadow-sm group-hover:shadow-[0_40px_80px_-20px_rgba(0,0,0,0.15)] group-hover:-translate-y-4">
                  <Image
                    src={perfume.img}
                    alt={perfume.name}
                    fill
                    className="object-cover transition-transform duration-[1.5s] ease-out group-hover:scale-110"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />

                  <div className="absolute top-8 left-8">
                    <span className="glass px-4 py-2 rounded-full text-[9px] font-bold tracking-widest uppercase text-white shadow-xl opacity-0 group-hover:opacity-100 transition-all duration-500 -translate-y-4 group-hover:translate-y-0">
                      {perfume.accent}
                    </span>
                  </div>

                  <div className="absolute bottom-8 left-8 right-8 translate-y-8 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-700">
                    <button className="w-full py-4 glass text-white text-[10px] font-bold tracking-[.4em] uppercase rounded-full hover:bg-white hover:text-luxury-black transition-all">
                      {t("collectionSection.add_to_collection")}
                    </button>
                  </div>
                </div>
                <div className="flex flex-col items-center text-center">
                  <p className="text-[9px] text-stone-400 dark:text-stone-500 font-bold tracking-[.4em] uppercase mb-2 transition-colors">{perfume.type}</p>
                  <h4 className="text-3xl font-serif text-luxury-black dark:text-white mb-4 group-hover:italic transition-all duration-500">{perfume.name}</h4>
                  <div className="w-8 h-px bg-stone-200 dark:bg-accent/30 mb-4 transition-colors" />
                  <p className="text-lg font-serif italic text-luxury-black dark:text-white transition-colors tracking-widest">${perfume.price}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-luxury-black text-stone-500 py-32">
        <div className="container mx-auto px-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-24 mb-32">
            <div className="col-span-1 md:col-span-1">
              <Link href="/">
                <h2 className="text-4xl font-serif text-white tracking-[.3em] font-bold mb-10 uppercase">Lumina</h2>
              </Link>
              <p className="text-sm leading-relaxed mb-10 font-light italic">
                {f("desc")}
              </p>
              <div className="flex gap-6 mt-12">
                {["Instagram", "Pinterest", "LinkedIn"].map(social => (
                  <a key={social} href="#" className="text-[10px] uppercase tracking-[.3em] text-stone-600 hover:text-white transition-colors">{social}</a>
                ))}
              </div>
            </div>
            <div>
              <h4 className="text-white font-bold mb-10 uppercase text-[10px] tracking-[.4em]">{f("nav_h")}</h4>
              <ul className="space-y-6 text-[11px] uppercase tracking-[.2em] font-medium">
                <li><Link href="/story" className="hover:text-accent transition-colors">{n("boutiques")}</Link></li>
                <li><Link href="/consultation" className="hover:text-accent transition-colors">{n("consultation")}</Link></li>
                <li><Link href="/subscription" className="hover:text-accent transition-colors">{n("subscription")}</Link></li>
                <li><Link href="/boutiques" className="hover:text-accent transition-colors">{n("boutiques")}</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-bold mb-10 uppercase text-[10px] tracking-[.4em]">{f("services_h")}</h4>
              <ul className="space-y-6 text-[11px] uppercase tracking-[.2em] font-medium">
                <li><Link href="/shipping" className="hover:text-accent transition-colors">Shipping & Returns</Link></li>
                <li><Link href="/terms" className="hover:text-accent transition-colors">{a("termsPart2")}</Link></li>
                <li><Link href="/privacy" className="hover:text-accent transition-colors">{a("termsPart4")}</Link></li>
                <li><Link href="/support" className="hover:text-accent transition-colors">Concierge Contact</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-bold mb-10 uppercase text-[10px] tracking-[.4em]">{f("anthology_h")}</h4>
              <p className="text-xs mb-8 italic">{f("anthology_p")}</p>
              <div className="flex border-b border-stone-800 pb-4 group focus-within:border-accent transition-colors">
                <input
                  type="email"
                  placeholder={f("email_placeholder")}
                  className="bg-transparent text-xs w-full outline-none placeholder:text-stone-700 text-white transition-all uppercase tracking-widest"
                />
                <button className="text-stone-600 hover:text-accent transition-colors">
                  <ArrowRight size={20} strokeWidth={1} />
                </button>
              </div>
            </div>
          </div>
          <div className="flex flex-col md:flex-row justify-between items-center pt-12 border-t border-stone-900 text-[9px] tracking-[.4em] uppercase font-bold text-stone-700">
            <span>{f("rights")}</span>
            <div className="flex gap-12 mt-8 md:mt-0 italic">
              <span>{f("engine")}</span>
              <span>{f("stabilized")}</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
