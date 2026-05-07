'use client';

import { motion } from 'framer-motion';
import { useLocale, useTranslations } from 'next-intl';
import {
  ArrowUpRight,
  CheckCircle2,
  ExternalLink,
  Gem,
  RotateCcw,
  Sparkles,
  Tag,
  ChevronRight,
  Heart,
  ShoppingCart,
  BrainCircuit
} from 'lucide-react';

import { Link } from '@/lib/i18n';
import { type QuizRecommendation } from '@/services/quiz.service';
import { cn } from '@/lib/utils';

interface RecommendationCardsProps {
  recommendations: QuizRecommendation[];
  analysis?: string | null;
  onRetake: () => void;
}

export function RecommendationCards({ recommendations, analysis, onRetake }: RecommendationCardsProps) {
  const t = useTranslations('quiz');
  const locale = useLocale();

  const copy =
    locale === 'vi'
      ? {
          matchingLabel: 'Mức độ phù hợp',
          matchingDetail: 'Độ khớp ước tính dựa trên hồ sơ hiện tại.',
          featuredLabel: 'Lựa chọn nổi bật',
          featuredDetail: 'Gợi ý dẫn đầu trong shortlist dành cho bạn.',
          summaryLabel: 'Số gợi ý',
          summaryDetail: 'Danh sách đã được tinh lọc để dễ so sánh.',
          collectionLabel: 'Các lựa chọn tiếp theo',
          collectionDetail: 'Những gợi ý còn lại vẫn bám sát gu mùi và nhu cầu sử dụng của bạn.',
          featuredReasonLabel: 'Vì sao phù hợp',
          fallbackPriceSuffix: 'đ',
        }
      : {
          matchingLabel: 'Match level',
          matchingDetail: 'Estimated alignment based on the current profile.',
          featuredLabel: 'Featured selection',
          featuredDetail: 'The leading recommendation inside your shortlist.',
          summaryLabel: 'Recommendations',
          summaryDetail: 'The list has been refined for easier comparison.',
          collectionLabel: 'More curated matches',
          collectionDetail: 'The remaining recommendations still stay close to your taste and intended use.',
          featuredReasonLabel: 'Why it fits',
          fallbackPriceSuffix: 'VND',
        };

  const formatPrice = (price: number | string) => {
    const amount = Number(price || 0);

    return `${new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', {
      maximumFractionDigits: 0,
    }).format(amount)} ${copy.fallbackPriceSuffix}`;
  };

  if (!recommendations || recommendations.length === 0) {
    return (
      <div className="mx-auto max-w-3xl">
        <div className="overflow-hidden rounded-[3rem] border border-white/5 bg-zinc-900/40 p-12 text-center backdrop-blur-3xl">
          <div className="mx-auto flex h-24 w-24 items-center justify-center rounded-[2rem] bg-gold/10 text-gold shadow-[0_0_40px_rgba(197,160,89,0.1)]">
            <Sparkles size={40} />
          </div>
          <h3 className="mt-8 font-heading text-4xl font-bold uppercase tracking-widest text-foreground">{t('results.no_results_title')}</h3>
          <p className="mx-auto mt-4 max-w-xl font-body text-base leading-relaxed text-stone-400">{t('results.no_results_desc')}</p>
          <button
            onClick={onRetake}
            className="mt-10 group relative inline-flex h-16 items-center justify-center gap-4 overflow-hidden rounded-full bg-gold px-12 font-heading text-xs font-bold uppercase tracking-[0.2em] text-black transition-all hover:scale-105"
          >
            <RotateCcw size={18} className="transition-transform group-hover:rotate-180 duration-500" />
            {t('results.retake')}
          </button>
        </div>
      </div>
    );
  }

  const [featured, ...rest] = recommendations;

  return (
    <div className="space-y-12 pb-12">
      {/* Header Summary */}
      <motion.section
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="relative overflow-hidden rounded-[3rem] border border-white/5 bg-zinc-900/40 p-8 backdrop-blur-xl md:p-16"
      >
        <div className="absolute -right-24 -top-24 h-96 w-96 rounded-full bg-gold/5 blur-[120px]" />
        
        <div className="relative flex flex-col gap-8 lg:flex-row lg:items-end lg:justify-between">
          <div className="max-w-3xl space-y-4">
            <div className="inline-flex items-center gap-3 rounded-full border border-gold/20 bg-gold/5 px-4 py-2 text-[10px] font-bold uppercase tracking-[0.3em] text-gold">
              <Sparkles size={14} />
              AI Synthesis Complete
            </div>
            <h2 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-8xl">
                The <span className="gold-gradient">Shortlist</span>
            </h2>
            <p className="font-body text-lg leading-relaxed text-stone-400">{t('results.subtitle')}</p>
          </div>

          <button
            onClick={onRetake}
            className="flex h-14 items-center gap-3 rounded-full border border-white/10 bg-white/5 px-8 font-heading text-[10px] font-bold uppercase tracking-widest text-stone-300 transition-all hover:bg-white/10 hover:text-white"
          >
            <RotateCcw size={16} />
            {t('results.retake')}
          </button>
        </div>

        <div className="mt-16 grid grid-cols-1 gap-6 md:grid-cols-3">
            {[
                { label: copy.summaryLabel, value: recommendations.length.toString().padStart(2, '0'), desc: copy.summaryDetail },
                { label: copy.featuredLabel, value: featured.name, isText: true, desc: copy.featuredDetail },
                { label: copy.matchingLabel, value: `${featured.matchScore ? Math.min(99.9, Math.round((featured.matchScore / 120) * 100 * 10) / 10) : 98.4}%`, desc: copy.matchingDetail, highlight: true }
            ].map((stat, i) => (
                <div key={i} className={cn(
                    "rounded-[2rem] border p-8 transition-all duration-500",
                    stat.highlight ? "border-gold/30 bg-gold/5 shadow-[0_0_30px_rgba(197,160,89,0.1)]" : "border-white/5 bg-white/[0.02] hover:bg-white/[0.04]"
                )}>
                    <p className={cn("mb-4 text-[10px] font-bold uppercase tracking-widest", stat.highlight ? "text-gold" : "text-stone-500")}>{stat.label}</p>
                    <p className={cn("font-heading leading-tight tracking-tighter text-foreground", stat.isText ? "text-2xl uppercase" : "text-5xl")}>{stat.value}</p>
                    <p className="mt-4 text-xs leading-relaxed text-stone-500">{stat.desc}</p>
                </div>
            ))}
        </div>
      </motion.section>

      {/* Featured Recommendation */}
      <motion.article
        initial={{ opacity: 0, scale: 0.98 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.1 }}
        className="group relative overflow-hidden rounded-[3rem] border border-white/10 bg-zinc-950 p-1 transition-all duration-700 hover:border-gold/30 shadow-2xl"
      >
        <div className="grid h-full gap-0 lg:grid-cols-12">
            <div className="relative min-h-[400px] overflow-hidden lg:col-span-5 lg:min-h-[600px]">
                {featured.imageUrl ? (
                    <img
                        src={featured.imageUrl}
                        alt={featured.name}
                        className="h-full w-full object-cover transition-transform duration-1000 group-hover:scale-110"
                    />
                ) : (
                    <div className="flex h-full items-center justify-center bg-zinc-900 text-gold/20">
                        <Sparkles size={120} />
                    </div>
                )}
                <div className="absolute inset-0 bg-gradient-to-t from-zinc-950 via-zinc-950/20 to-transparent" />
                
                <div className="absolute left-8 top-8">
                    <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-gold text-black shadow-[0_0_30px_rgba(197,160,89,0.5)]">
                        <Gem size={24} />
                    </div>
                </div>

                <div className="absolute bottom-12 left-12 right-12 space-y-2">
                    {featured.brand && <p className="text-xs font-bold uppercase tracking-[0.4em] text-gold">{featured.brand}</p>}
                    <h3 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
                        {featured.name}
                    </h3>
                </div>
            </div>

            <div className="flex flex-col justify-center p-8 lg:col-span-7 lg:p-20">
                <div className="mb-12 space-y-6">
                    <div className="flex items-end justify-between border-b border-white/5 pb-8">
                        <div>
                            <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-stone-500">{t('results.ai_picked')}</p>
                            <p className="font-heading text-5xl font-bold tracking-tighter text-foreground">{formatPrice(featured.price)}</p>
                        </div>
                        <Link
                            href={`/products/${featured.productId}`}
                            className="flex h-16 w-16 items-center justify-center rounded-full border border-white/10 bg-white/5 text-stone-300 transition-all hover:bg-gold hover:text-black hover:shadow-[0_0_30px_rgba(197,160,89,0.5)]"
                        >
                            <ArrowUpRight size={32} />
                        </Link>
                    </div>

                    <div className="rounded-[2rem] border border-white/5 bg-white/[0.02] p-8">
                        <div className="mb-4 flex items-center gap-3">
                            <BrainCircuit size={18} className="text-gold" />
                            <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-gold/80">{copy.featuredReasonLabel}</p>
                        </div>
                        <p className="font-body text-base leading-relaxed text-stone-300 italic">
                            "{featured.reason}"
                        </p>
                    </div>

                    {featured.tags && (
                        <div className="flex flex-wrap gap-3">
                            {featured.tags.map(tag => (
                                <span key={tag} className="flex items-center gap-2 rounded-full border border-white/5 bg-white/5 px-4 py-2 text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                    <Tag size={12} className="text-gold" />
                                    {tag}
                                </span>
                            ))}
                        </div>
                    )}
                </div>

                <div className="flex flex-wrap gap-4 pt-8">
                    <Link
                        href={`/products/${featured.productId}`}
                        className="group relative flex h-16 items-center gap-4 overflow-hidden rounded-full bg-gold px-12 font-heading text-xs font-bold uppercase tracking-[0.2em] text-black transition-all hover:scale-105"
                    >
                        <ShoppingCart size={18} />
                        <span>{t('results.view_detail')}</span>
                        <ChevronRight size={18} className="transition-transform group-hover:translate-x-1" />
                    </Link>
                    
                    <button className="flex h-16 items-center gap-4 rounded-full border border-white/10 bg-white/5 px-10 font-heading text-xs font-bold uppercase tracking-[0.2em] text-foreground transition-all hover:bg-white/10">
                        <Heart size={18} />
                        <span>Add to Collection</span>
                    </button>
                </div>
            </div>
        </div>
      </motion.article>

      {/* Secondary Recommendations */}
      {rest.length > 0 && (
          <section className="space-y-8">
            <div className="flex items-center gap-4">
                <h3 className="text-[11px] font-bold uppercase tracking-[0.5em] text-stone-500">More Resonances</h3>
                <div className="h-[1px] flex-1 bg-gradient-to-r from-white/10 to-transparent" />
            </div>

            <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
                {rest.map((rec, i) => (
                    <motion.article
                        key={rec.productId}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 + i * 0.1 }}
                        whileHover={{ y: -8 }}
                        className="group relative overflow-hidden rounded-[2.5rem] border border-white/5 bg-zinc-900/40 p-1 transition-all duration-500 hover:border-gold/30 shadow-xl"
                    >
                        <div className="relative aspect-[4/5] overflow-hidden rounded-[2.4rem]">
                            {rec.imageUrl ? (
                                <img src={rec.imageUrl} alt={rec.name} className="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110" />
                            ) : (
                                <div className="flex h-full items-center justify-center bg-zinc-800 text-gold/10">
                                    <Sparkles size={64} />
                                </div>
                            )}
                            <div className="absolute inset-0 bg-gradient-to-t from-zinc-950 via-zinc-950/20 to-transparent" />
                            
                            {rec.matchScore && (
                                <div className="absolute right-6 top-6 rounded-full border border-gold/30 bg-black/60 px-3 py-1.5 text-[10px] font-bold text-gold backdrop-blur-xl">
                                    {Math.min(99, Math.round((rec.matchScore / 120) * 100))}% Match
                                </div>
                            )}

                            <div className="absolute bottom-8 left-8 right-8">
                                {rec.brand && <p className="mb-1 text-[8px] font-bold uppercase tracking-[0.3em] text-gold">{rec.brand}</p>}
                                <h4 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground">{rec.name}</h4>
                            </div>
                        </div>

                        <div className="p-8 space-y-6">
                            <p className="line-clamp-3 font-body text-sm leading-relaxed text-stone-400">
                                {rec.reason}
                            </p>
                            <div className="flex items-center justify-between gap-4 border-t border-white/5 pt-6">
                                <span className="font-heading text-xl font-bold text-foreground">{formatPrice(rec.price)}</span>
                                <Link 
                                    href={`/products/${rec.productId}`}
                                    className="flex h-10 w-10 items-center justify-center rounded-full border border-white/10 bg-white/5 text-stone-500 transition-all group-hover:bg-gold group-hover:text-black group-hover:shadow-[0_0_20px_rgba(197,160,89,0.3)]"
                                >
                                    <ArrowUpRight size={20} />
                                </Link>
                            </div>
                        </div>
                    </motion.article>
                ))}
            </div>
          </section>
      )}
    </div>
  );
}
