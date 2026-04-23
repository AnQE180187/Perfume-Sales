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
} from 'lucide-react';

import { Link } from '@/lib/i18n';
import { type QuizRecommendation } from '@/services/quiz.service';

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
        <div className="overflow-hidden rounded-[2.2rem] border border-border bg-card/60 p-8 text-center shadow-xl backdrop-blur-xl lg:p-12">
          <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-[1.75rem] bg-gold/10 text-gold-dark dark:text-[#d7b168]">
            <Sparkles size={32} />
          </div>
          <h3 className="mt-8 font-heading text-3xl tracking-[-0.03em] text-foreground">{t('results.no_results_title')}</h3>
          <p className="mx-auto mt-4 max-w-xl text-base leading-8 text-muted-foreground">{t('results.no_results_desc')}</p>
          <button
            onClick={onRetake}
            className="mt-8 inline-flex min-h-12 items-center justify-center gap-2 rounded-full border border-gold/30 bg-gold/10 px-8 text-sm font-semibold text-gold-dark dark:text-[#e1bf7a] transition-all duration-300 hover:-translate-y-0.5 hover:bg-gold/20"
          >
            <RotateCcw size={16} />
            {t('results.retake')}
          </button>
        </div>
      </div>
    );
  }

  const [featured, ...rest] = recommendations;

  return (
    <div className="mx-auto w-full max-w-[1440px]">
      <motion.section
        initial={{ opacity: 0, scale: 0.98 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
        className="relative overflow-hidden rounded-[2.5rem] border border-border bg-card/40 p-8 shadow-2xl backdrop-blur-3xl lg:p-12"
      >
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(197,160,89,0.08),transparent_40%)]" />
        <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-gold/40 to-transparent" />

        <div className="relative flex flex-col gap-10 xl:flex-row xl:items-end xl:justify-between">
          <div className="max-w-4xl">
            <div className="inline-flex items-center gap-2.5 rounded-full border border-gold/20 bg-gold/5 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.15em] text-gold-dark dark:text-[#ccac66]">
              <Sparkles size={14} className="animate-pulse" />
              {t('results.ai_picked')}
            </div>
            <h2 className="mt-8 font-heading text-[clamp(1.75rem,4vw,3rem)] leading-none tracking-[-0.04em] text-foreground dark:text-white">
              {t('results.title')}
            </h2>
            <p className="mt-6 max-w-2xl text-lg leading-relaxed text-muted-foreground/80">
              {analysis || t('results.subtitle')}
            </p>
          </div>

          <button
            onClick={onRetake}
            className="inline-flex min-h-[3.5rem] items-center justify-center gap-3 rounded-full border border-border/80 bg-background/50 px-8 text-sm font-bold text-foreground backdrop-blur shadow-xl transition-all duration-500 hover:-translate-y-1 hover:border-gold/40 hover:bg-gold/5 hover:text-gold-dark"
          >
            <RotateCcw size={16} />
            {t('results.retake')}
          </button>
        </div>

        <div className="relative mt-12 grid gap-6 md:grid-cols-3">
          <div className="group rounded-[2rem] border border-border/60 bg-muted/20 px-6 py-8 transition-colors duration-500 hover:bg-muted/30">
            <p className="text-[11px] font-bold uppercase tracking-[0.2em] text-muted-foreground/50 group-hover:text-gold/40">{copy.summaryLabel}</p>
            <div className="mt-4 flex items-baseline gap-2">
              <p className="font-heading text-6xl leading-none tracking-tighter text-foreground">
                {recommendations.length.toString().padStart(2, '0')}
              </p>
              <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
            </div>
            <p className="mt-5 text-sm leading-relaxed text-muted-foreground/70">{copy.summaryDetail}</p>
          </div>

          <div className="group rounded-[2rem] border border-border/60 bg-muted/20 px-6 py-8 transition-colors duration-500 hover:bg-muted/30">
            <p className="text-[11px] font-bold uppercase tracking-[0.2em] text-muted-foreground/50 group-hover:text-gold/40">{copy.featuredLabel}</p>
            <p className="mt-4 font-heading text-3xl leading-tight text-foreground transition-colors duration-300 group-hover:text-gold-dark">{featured.name}</p>
            <p className="mt-5 text-sm leading-relaxed text-muted-foreground/70">{copy.featuredDetail}</p>
          </div>

          <div className="group relative overflow-hidden rounded-[2rem] border border-gold/30 bg-gold/[0.03] px-6 py-8 shadow-[0_32px_64px_-16px_rgba(197,160,89,0.1)]">
            <div className="absolute inset-0 bg-gradient-to-br from-gold/[0.05] to-transparent" />
            <p className="relative text-[10px] font-bold uppercase tracking-[0.2em] text-gold-dark dark:text-[#ccac66]">{copy.matchingLabel}</p>
            <p className="relative mt-4 font-heading text-6xl leading-none tracking-tighter text-foreground drop-shadow-[0_0_12px_rgba(197,160,89,0.3)]">
              98.4%
            </p>
            <p className="relative mt-5 text-sm leading-relaxed text-gold-dark dark:text-[#d1b57a] font-medium opacity-80">{copy.matchingDetail}</p>
          </div>
        </div>
      </motion.section>

      <motion.article
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.7, delay: 0.1, ease: [0.22, 1, 0.36, 1] }}
        className="mt-8 overflow-hidden rounded-[2.5rem] border border-border bg-card/40 shadow-2xl backdrop-blur-3xl group"
      >
        <div className="grid h-full gap-0 lg:grid-cols-[1fr_1.1fr]">
          <div className="relative min-h-[380px] overflow-hidden bg-muted lg:min-h-[520px]">
            {featured.imageUrl ? (
              <img
                src={featured.imageUrl}
                alt={featured.name}
                className="h-full w-full object-cover transition-transform duration-1000 group-hover:scale-[1.05]"
              />
            ) : (
              <div className="flex h-full items-center justify-center bg-[radial-gradient(circle_at_top,rgba(197,160,89,0.12),transparent_40%)] dark:bg-[radial-gradient(circle_at_top,rgba(197,160,89,0.25),transparent_40%)] text-gold">
                <Sparkles size={64} className="opacity-20 animate-pulse" />
              </div>
            )}

            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />

            <div className="absolute left-8 top-8">
              <div className="inline-flex items-center gap-2.5 rounded-full border border-white/20 bg-black/40 px-5 py-2.5 text-[11px] font-bold uppercase tracking-[0.15em] text-white backdrop-blur-md">
                <div className="h-1.5 w-1.5 rounded-full bg-gold animate-pulse" />
                {copy.featuredLabel}
              </div>
            </div>

            <div className="absolute bottom-8 left-8 right-8">
              {featured.brand ? <p className="text-sm font-bold uppercase tracking-[0.25em] text-white/60 mb-3">{featured.brand}</p> : null}
              <h3 className="font-heading text-4xl leading-[0.95] tracking-[-0.05em] text-white lg:text-5xl">
                {featured.name}
              </h3>
            </div>
          </div>

          <div className="flex flex-col p-8 lg:p-12 xl:p-14">
            <div className="flex flex-col gap-8 border-b border-border pb-10 sm:flex-row sm:items-start sm:justify-between">
              <div>
                <p className="text-[11px] font-bold uppercase tracking-[0.25em] text-gold-dark dark:text-[#ccac66]">{t('results.ai_picked')}</p>
                <p className="mt-3 font-heading text-3xl md:text-4xl tracking-[-0.04em] text-foreground leading-none">{formatPrice(featured.price)}</p>
              </div>

              <Link
                href={`/products/${featured.productId}`}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex h-16 w-16 items-center justify-center rounded-full border border-gold/40 bg-[#121212] dark:bg-zinc-900 text-white transition-all duration-500 hover:-translate-y-1.5 hover:border-gold hover:shadow-[0_15px_30px_-10px_rgba(197,160,89,0.3)] shadow-lg"
              >
                <ArrowUpRight size={24} />
              </Link>
            </div>

            <div className="mt-10 rounded-[2rem] border border-border/60 bg-muted/20 px-6 py-8">
              <div className="flex items-center gap-3">
                <div className="h-8 w-8 rounded-full bg-gold/10 flex items-center justify-center">
                  <Gem size={16} className="text-gold-dark dark:text-[#ccac66]" />
                </div>
                <p className="text-[11px] font-bold uppercase tracking-[0.25em] text-muted-foreground/60">{copy.featuredReasonLabel}</p>
              </div>
              <p className="mt-6 text-lg leading-relaxed text-foreground/80 italic">"{featured.reason}"</p>
            </div>

            {featured.tags && featured.tags.length > 0 ? (
              <div className="mt-8 flex flex-wrap gap-2.5">
                {featured.tags.map((tag) => (
                  <span
                    key={tag}
                    className="inline-flex items-center gap-2.5 rounded-full border border-border/80 bg-background/50 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.1em] text-muted-foreground/80 transition-colors duration-300 hover:border-gold/30 hover:text-gold-dark"
                  >
                    <Tag size={12} className="text-gold/40" />
                    {tag}
                  </span>
                ))}
              </div>
            ) : null}

            <div className="mt-auto flex flex-col gap-8 pt-12 sm:flex-row sm:items-center sm:justify-between">
              <p className="max-w-md text-sm leading-relaxed text-muted-foreground/60">{copy.collectionDetail}</p>

              <Link
                href={`/products/${featured.productId}`}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex min-h-[3.5rem] items-center justify-center gap-3 rounded-full bg-gold-btn-gradient px-10 text-[13px] font-bold uppercase tracking-[0.2em] text-[#121212] shadow-[0_20px_40px_-10px_rgba(197,160,89,0.4)] transition-all duration-500 hover:-translate-y-1.5 hover:shadow-[0_25px_50px_-12px_rgba(197,160,89,0.5)] active:scale-95"
              >
                <ExternalLink size={16} />
                {t('results.view_detail')}
              </Link>
            </div>
          </div>
        </div>
      </motion.article>

      {rest.length > 0 ? (
        <section className="mt-8">
          <div className="mb-5 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between px-2">
            <div>
              <p className="text-[11px] uppercase tracking-[0.28em] text-muted-foreground">{copy.collectionLabel}</p>
              <h3 className="mt-2 font-heading text-3xl tracking-[-0.03em] text-foreground">{copy.collectionLabel}</h3>
            </div>
            <p className="max-w-2xl text-sm leading-7 text-muted-foreground">{copy.collectionDetail}</p>
          </div>

          <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
            {rest.map((rec, index) => (
              <motion.article
                key={rec.productId}
                initial={{ opacity: 0, y: 22 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.08, duration: 0.35 }}
                whileHover={{ y: -6 }}
                className="overflow-hidden rounded-[2rem] border border-border bg-card/60 shadow-xl backdrop-blur-sm"
              >
                <div className="relative min-h-[220px] overflow-hidden bg-muted">
                  {rec.imageUrl ? (
                    <img
                      src={rec.imageUrl}
                      alt={rec.name}
                      className="h-full w-full object-cover transition-transform duration-700 hover:scale-[1.04]"
                    />
                  ) : (
                    <div className="flex h-full items-center justify-center text-gold">
                      <Sparkles size={30} />
                    </div>
                  )}

                  <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent" />
                  {rec.brand ? (
                    <div className="absolute left-4 top-4 rounded-full border border-white/20 bg-black/30 px-3 py-1.5 text-sm text-white backdrop-blur">
                      {rec.brand}
                    </div>
                  ) : null}
                </div>

                <div className="p-5">
                  <h4 className="font-heading text-2xl leading-tight tracking-[-0.03em] text-foreground">{rec.name}</h4>
                  <p className="mt-3 line-clamp-4 text-sm leading-7 text-muted-foreground">{rec.reason}</p>

                  {rec.tags && rec.tags.length > 0 ? (
                    <div className="mt-4 flex flex-wrap gap-2">
                      {rec.tags.slice(0, 3).map((tag) => (
                        <span
                          key={tag}
                          className="inline-flex items-center gap-1.5 rounded-full border border-border bg-muted/40 px-3 py-1 text-xs text-muted-foreground"
                        >
                          <Tag size={10} className="text-gold" />
                          {tag}
                        </span>
                      ))}
                    </div>
                  ) : null}

                  <div className="mt-6 flex items-center justify-between gap-3 border-t border-border pt-4">
                    <p className="text-lg font-semibold text-foreground">{formatPrice(rec.price)}</p>
                    <Link
                      href={`/products/${rec.productId}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex min-h-10 items-center gap-2 rounded-full border border-gold/30 bg-[#121212] dark:bg-zinc-800 px-4 text-sm font-medium text-white transition-all duration-300 hover:border-gold hover:text-gold shadow-md"
                    >
                      {t('results.view_detail')}
                    </Link>
                  </div>
                </div>
              </motion.article>
            ))}
          </div>
        </section>
      ) : null}
    </div>
  );
}
