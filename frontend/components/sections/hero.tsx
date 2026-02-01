'use client';

import { useTranslations } from 'next-intl';
import Image from 'next/image';
import { ArrowRight } from 'lucide-react';
import { motion, useScroll, useTransform, MotionValue } from 'framer-motion';
import { Link } from '@/lib/i18n';
import { useRef, useEffect, useState } from 'react';

interface HeroProps {
    heroY?: MotionValue<string>;
    heroScale?: MotionValue<number>;
    heroOpacity?: MotionValue<number>;
}

export const Hero = ({ heroY: parentHeroY, heroScale: parentHeroScale, heroOpacity: parentHeroOpacity }: HeroProps) => {
    const t = useTranslations('hero');
    const containerRef = useRef<HTMLDivElement>(null);
    const [isMounted, setIsMounted] = useState(false);

    useEffect(() => {
        setIsMounted(true);
    }, []);

    // Use parent props if provided, otherwise create own scroll transforms
    const { scrollYProgress } = useScroll({
        target: isMounted && !parentHeroY ? containerRef : undefined,
        offset: ["start start", "end start"]
    });

    const localHeroY = useTransform(scrollYProgress, [0, 1], ["0%", "50%"]);
    const localHeroScale = useTransform(scrollYProgress, [0, 1], [1, 1.2]);
    const localHeroOpacity = useTransform(scrollYProgress, [0, 0.5], [1, 0]);

    const heroY = parentHeroY || localHeroY;
    const heroScale = parentHeroScale || localHeroScale;
    const heroOpacity = parentHeroOpacity || localHeroOpacity;

    return (
        <section
            ref={containerRef}
            className="relative h-screen flex items-center overflow-hidden"
        >
            {/* Parallax Background */}
            <motion.div
                style={{ y: heroY, scale: heroScale }}
                className="absolute inset-0 z-0"
            >
                <Image
                    src="/luxury_perfume_hero_cinematic.png"
                    alt="Luxury Fragrance"
                    fill
                    className="object-cover"
                    priority
                />
                <div className="absolute inset-0 bg-black/30 dark:bg-black/50 transition-colors" />
            </motion.div>

            {/* Content */}
            <div className="container mx-auto px-6 relative z-10">
                <motion.div
                    style={{ opacity: heroOpacity }}
                    initial={{ opacity: 0, x: -50 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 1.2, ease: [0.33, 1, 0.68, 1] }}
                    className="max-w-2xl text-white"
                >
                    {/* Badge */}
                    <motion.span
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.5 }}
                        className="inline-block px-4 py-1.5 glass rounded-full text-[10px] font-bold tracking-[.4em] uppercase mb-8"
                    >
                        {t('badge')}
                    </motion.span>

                    {/* Headline */}
                    <h1 className="text-7xl md:text-9xl font-serif mb-8 leading-[0.9] tracking-tighter">
                        {t('title')}
                    </h1>

                    {/* Subtitle */}
                    <p className="text-xl md:text-2xl text-stone-200 mb-12 font-light leading-relaxed max-w-lg italic">
                        {t('subtitle')}
                    </p>

                    {/* CTAs */}
                    <div className="flex flex-wrap gap-6 mt-8">
                        <Link
                            href="/customer/consultation"
                            className="group px-10 py-5 bg-gold hover:bg-yellow-600 text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] flex items-center gap-4 transition-all shadow-xl"
                        >
                            {t('cta')}
                            <ArrowRight size={18} className="group-hover:translate-x-2 transition-transform" />
                        </Link>
                        <Link
                            href="/collection"
                            className="px-10 py-5 glass hover:bg-white/20 text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] transition-all"
                        >
                            {t('explore')}
                        </Link>
                    </div>
                </motion.div>
            </div>

            {/* Scroll Indicator */}
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 1.5, duration: 1 }}
                className="absolute bottom-10 left-1/2 -translate-x-1/2 flex flex-col items-center gap-4 pointer-events-none"
            >
                <span className="text-[10px] uppercase tracking-[0.5em] text-white/40 font-bold">
                    Scroll to Discover
                </span>
                <motion.div
                    animate={{ y: [0, 10, 0] }}
                    transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
                    className="w-px h-16 bg-gradient-to-b from-white/60 to-transparent"
                />
            </motion.div>
        </section>
    );
};
