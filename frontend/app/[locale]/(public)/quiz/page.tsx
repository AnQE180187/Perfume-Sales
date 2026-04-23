'use client';

import { useMemo, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { useLocale, useTranslations } from 'next-intl';
import {
  ArrowRight,
  BadgeCheck,
  CheckCircle2,
  Clock3,
  FlaskConical,
  Gem,
  LogIn,
  ScanSearch,
  ShieldCheck,
  Sparkles,
} from 'lucide-react';

import { QuizForm } from '@/components/quiz/QuizForm';
import { RecommendationCards } from '@/components/quiz/RecommendationCards';
import { QuizHistory } from '@/components/quiz/QuizHistory';
import { useAuth } from '@/hooks/use-auth';
import { Link } from '@/lib/i18n';
import { quizService, type QuizAnswers, type QuizRecommendation } from '@/services/quiz.service';

type QuizState = 'intro' | 'quiz' | 'analyzing' | 'results' | 'history';

export default function QuizPage() {
  const t = useTranslations('quiz');
  const locale = useLocale();
  const { isAuthenticated } = useAuth();
  const [state, setState] = useState<QuizState>('intro');
  const [recommendations, setRecommendations] = useState<QuizRecommendation[]>([]);
  const [analysis, setAnalysis] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const pageCopy = useMemo(
    () =>
      locale === 'vi'
        ? {
            introPanelTitle: 'Quy trình gợi ý',
            introPanelHeading: 'Giám tuyển bởi Perfume GPT',
            introPanelText:
              'Trả lời 5 câu hỏi ngắn để hệ thống chắt lọc nhóm hương, dịp dùng và mức chi phù hợp với bạn.',
            introSummaryTitle: 'Bạn sẽ nhận được gì',
            introSummaryText:
              'Một shortlist rõ ràng, dễ so sánh và đủ thông tin để đi thẳng tới sản phẩm phù hợp.',
            introAssuranceTitle: 'Trải nghiệm dễ tiếp cận',
            introAssurance:
              'Không cần kiến thức chuyên sâu về nước hoa, chỉ cần chọn theo cảm nhận và nhu cầu thật của bạn.',
            heroMetrics: [
              { value: '05', label: 'Câu hỏi tinh gọn' },
              { value: '~02', label: 'Phút để hoàn tất' },
              { value: '01', label: 'Hồ sơ mùi hương rõ ràng' },
            ],
            analyzeTitle: 'Đang xây dựng hồ sơ mùi hương của bạn',
            analyzeText:
              'Hệ thống đang ghép câu trả lời với nhóm hương, độ lưu hương, dịp dùng và mức giá phù hợp nhất.',
            analyzeBadge: 'Đang phân tích',
            analyzePanelTitle: 'Tiến trình xử lý',
            analyzePanelText:
              'Mọi lựa chọn của bạn vẫn được giữ nguyên. Chúng tôi chỉ đang tinh chỉnh thứ tự gợi ý để danh sách cuối cùng rõ ràng và dễ chọn hơn.',
          }
        : {
            introPanelTitle: 'Recommendation flow',
            introPanelHeading: 'Curated by Perfume GPT',
            introPanelText:
              'Answer 5 short questions so we can narrow down scent family, occasion, longevity, and budget.',
            introSummaryTitle: 'What you will get',
            introSummaryText:
              'A clean shortlist that is easy to compare and detailed enough to move straight into product pages.',
            introAssuranceTitle: 'Easy to use',
            introAssurance:
              'No fragrance expertise required. Just answer based on your instinct, style, and daily routine.',
            heroMetrics: [
              { value: '05', label: 'Focused questions' },
              { value: '~02', label: 'Minutes to finish' },
              { value: '01', label: 'Refined scent profile' },
            ],
            analyzeTitle: 'Building your scent profile',
            analyzeText:
              'We are matching your answers against scent family, longevity, occasion, and budget signals.',
            analyzeBadge: 'Analyzing',
            analyzePanelTitle: 'Processing flow',
            analyzePanelText:
              'Your answers remain intact. We are only refining the shortlist so the final result feels clearer and easier to act on.',
          },
    [locale],
  );

  const ritualHighlights = [
    {
      icon: Sparkles,
      title: t('steps.gender.title'),
      description: t('steps.gender.subtitle'),
    },
    {
      icon: FlaskConical,
      title: t('steps.scent_family.title'),
      description: t('steps.scent_family.subtitle'),
    },
    {
      icon: Clock3,
      title: t('steps.longevity.title'),
      description: t('intro.time_estimate'),
    },
  ];

  const introBenefits = [
    {
      icon: ShieldCheck,
      title: pageCopy.introSummaryTitle,
      description: pageCopy.introSummaryText,
    },
    {
      icon: BadgeCheck,
      title: pageCopy.introAssuranceTitle,
      description: pageCopy.introAssurance,
    },
  ];

  const analysisSteps = [
    t('analyzing.step1'),
    t('analyzing.step2'),
    t('analyzing.step3'),
    t('analyzing.step4'),
  ];

  const handleStart = () => {
    setState('quiz');
  };

  const handleViewHistory = () => {
    setState('history');
  };

  const handleShowResultFromHistory = (recs: QuizRecommendation[], analysisText?: string) => {
    setRecommendations(recs);
    setAnalysis(analysisText || null);
    setState('results');
  };

  const handleSubmit = async (answers: QuizAnswers) => {
    setIsSubmitting(true);
    setError(null);
    setState('analyzing');

    try {
      const result = await quizService.submitQuiz(answers);
      setRecommendations(result.recommendations);
      setAnalysis(result.analysis);
      await new Promise((resolve) => setTimeout(resolve, 3000));
      setState('results');
    } catch (err: any) {
      console.error('Quiz submission failed:', err);
      setError(err.message || t('error.generic'));
      setState('quiz');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleRetake = () => {
    setRecommendations([]);
    setAnalysis(null);
    setError(null);
    setState('quiz');
  };

  return (
    <div className="relative isolate min-h-screen overflow-hidden bg-background text-foreground">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(197,160,89,0.08),transparent_24%),radial-gradient(circle_at_85%_18%,rgba(164,122,69,0.1),transparent_18%)] dark:bg-[radial-gradient(circle_at_top_left,rgba(197,160,89,0.16),transparent_24%),radial-gradient(circle_at_85%_18%,rgba(164,122,69,0.18),transparent_18%)]" />
      <div className="absolute inset-0 opacity-[0.03] dark:opacity-[0.06] [background-image:linear-gradient(rgba(128,128,128,0.08)_1px,transparent_1px),linear-gradient(90deg,rgba(128,128,128,0.08)_1px,transparent_1px)] [background-size:88px_88px]" />
      <div className="pointer-events-none absolute left-[-12rem] top-24 h-[24rem] w-[24rem] rounded-full bg-gold/5 dark:bg-[#c5a059]/10 blur-[120px]" />
      <div className="pointer-events-none absolute bottom-[-10rem] right-[-8rem] h-[26rem] w-[26rem] rounded-full bg-gold/5 dark:bg-[#8f6b3f]/10 blur-[140px]" />

      <main className="container-responsive relative z-10 pb-16 pt-16 sm:pt-20 lg:pb-24 lg:pt-28">
        <AnimatePresence mode="wait">
          {state === 'intro' && (
            <motion.section
              key="intro"
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -30 }}
              transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
              className="w-full"
            >
              <div className="grid gap-12 lg:grid-cols-[1.1fr_0.9fr] items-start lg:gap-16">
                <div className="relative">
                  {/* Decorative background depth */}
                  <div className="absolute -left-24 -top-24 h-80 w-80 rounded-full bg-gold/10 blur-[120px] pointer-events-none" />
                  
                  <div className="relative">
                    <div className="inline-flex items-center gap-2.5 rounded-full border border-gold/20 bg-gold/5 px-5 py-2.5 text-[11px] font-bold uppercase tracking-[0.3em] text-gold-dark dark:text-[#ccac66] mb-8">
                      <Sparkles size={14} className="animate-pulse" />
                      {t('intro.label')}
                    </div>

                    <h1 className="font-heading text-[clamp(2.25rem,6.5vw,3.5rem)] leading-[1.05] tracking-[-0.05em] text-foreground mb-8">
                       {t('intro.title')}
                    </h1>
                    
                    <p className="max-w-2xl text-lg md:text-xl leading-relaxed text-muted-foreground/70 mb-8">
                      {t('intro.description')}
                    </p>

                    <div className="flex flex-wrap items-center gap-6 mb-8">
                      <button
                        onClick={handleStart}
                        className="group relative h-14 md:h-16 px-12 flex items-center justify-center gap-3 rounded-full bg-gold-btn-gradient border border-white/20 dark:border-white/40 text-sm font-bold text-[#121212] dark:text-white shadow-[0_20px_40px_-12px_rgba(197,160,89,0.4)] transition-all duration-500 hover:-translate-y-1.5 hover:shadow-[0_30px_60px_-15px_rgba(197,160,89,0.5)] active:scale-95"
                      >
                        <span className="relative z-10">{t('intro.start_btn')}</span>
                        <ArrowRight size={18} className="relative z-10 transition-transform duration-300 group-hover:translate-x-1.5" />
                        <div className="absolute inset-0 bg-white/10 opacity-0 group-hover:opacity-100 transition-opacity" />
                      </button>

                      {isAuthenticated ? (
                        <button
                          onClick={handleViewHistory}
                          className="h-14 md:h-16 px-10 flex items-center justify-center gap-3 rounded-full border border-border/80 bg-card/40 text-sm font-bold text-foreground backdrop-blur-md transition-all duration-500 hover:border-gold/30 hover:bg-muted/30 hover:shadow-lg"
                        >
                          <Clock3 size={18} />
                          {locale === 'vi' ? 'Xem Lịch Sử' : 'View History'}
                        </button>
                      ) : (
                        <Link
                          href="/login"
                          className="h-14 md:h-16 px-10 flex items-center justify-center gap-3 rounded-full border border-border/80 bg-card/40 text-sm font-bold text-foreground backdrop-blur-md transition-all duration-500 hover:border-gold/30 hover:bg-muted/30 hover:shadow-lg"
                        >
                          <LogIn size={18} />
                          {t('intro.login_btn')}
                        </Link>
                      )}
                    </div>

                    {!isAuthenticated && (
                      <div className="flex items-start gap-3 p-5 rounded-2xl border border-border/40 bg-muted/5 max-w-lg mb-8">
                        <BadgeCheck size={18} className="text-gold/60 shrink-0 mt-0.5" />
                        <p className="text-xs leading-relaxed text-muted-foreground/60 font-medium italic">
                          {locale === 'vi' 
                            ? 'Lưu ý: Bạn có thể thực hiện Quiz với tư cách khách, nhưng đăng nhập sẽ giúp bạn lưu lại hồ sơ mùi hương vĩnh viễn.' 
                            : 'Note: You can take the quiz as a guest, but logging in will help you save your scent profile permanently.'}
                        </p>
                      </div>
                    )}

                    <div className="pt-12 border-t border-border/40 grid grid-cols-2 lg:grid-cols-3 gap-10">
                       {pageCopy.heroMetrics.map((item) => (
                        <div key={item.label} className="group">
                           <div className="font-heading text-5xl tracking-tighter text-foreground group-hover:text-gold-dark transition-colors duration-500">{item.value}+</div>
                           <div className="mt-2 text-[11px] font-bold uppercase tracking-widest text-muted-foreground/40 group-hover:text-muted-foreground/60 transition-colors">{item.label}</div>
                        </div>
                       ))}
                    </div>
                  </div>
                </div>

                <div className="relative">
                   {/* Layered Cards for Visual Depth */}
                   <div className="absolute -inset-4 bg-gold/5 blur-3xl opacity-50 rounded-[3rem] pointer-events-none" />
                   
                   <div className="relative overflow-hidden rounded-[3rem] border border-border bg-card/30 p-10 lg:p-14 backdrop-blur-3xl shadow-2xl">
                     <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(197,160,89,0.15),transparent_40%)]" />
                     <div className="absolute inset-0 opacity-5 noise-panel pointer-events-none" />
                     
                     <div className="relative">
                        <div className="flex items-center justify-between mb-10">
                           <div className="flex items-center gap-3">
                              <div className="h-10 w-10 flex items-center justify-center rounded-2xl bg-gold/10 text-gold-dark">
                                 <ScanSearch size={22} />
                              </div>
                              <span className="text-[11px] font-bold uppercase tracking-[0.2em] text-muted-foreground/50">{pageCopy.introPanelTitle}</span>
                           </div>
                           <div className="h-px flex-1 mx-6 bg-border/40" />
                        </div>

                        <h2 className="font-heading text-4xl leading-[1.1] tracking-tighter text-foreground mb-8 pr-12">
                           {pageCopy.introPanelHeading}
                        </h2>
                        
                        <p className="text-base leading-relaxed text-muted-foreground/60 mb-12">
                           {pageCopy.introPanelText}
                        </p>

                        <div className="space-y-5">
                           {analysisSteps.map((step, idx) => (
                             <div key={idx} className="group/step flex items-start gap-5 p-6 rounded-[2rem] border border-border/40 bg-muted/10 transition-all duration-500 hover:bg-gold/[0.04] hover:shadow-xl">
                                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-[1.2rem] bg-background border border-border text-xs font-bold text-gold-dark group-hover/step:bg-gold group-hover/step:text-[#121212] dark:group-hover/step:text-cream group-hover/step:border-gold transition-all duration-500 shadow-sm">
                                  {(idx + 1).toString().padStart(2, '0')}
                                </div>
                                <p className="pt-2.5 text-sm font-medium text-foreground/70 leading-relaxed group-hover/step:text-foreground transition-colors">{step}</p>
                             </div>
                           ))}
                        </div>

                        <div className="mt-12 pt-10 border-t border-border/40 flex items-center gap-5">
                            <div className="h-14 w-14 rounded-full border border-emerald-500/20 bg-emerald-500/5 flex items-center justify-center text-emerald-500 shadow-[0_0_20px_rgba(16,185,129,0.1)]">
                               <ShieldCheck size={28} strokeWidth={1.5} />
                            </div>
                            <div className="flex flex-col">
                               <div className="text-[11px] font-bold uppercase tracking-widest text-emerald-600/80 mb-1">{pageCopy.introAssuranceTitle}</div>
                               <p className="text-xs text-muted-foreground/40 font-medium italic">{pageCopy.introAssurance}</p>
                            </div>
                        </div>
                     </div>
                   </div>
                </div>
              </div>
            </motion.section>
          )}

          {state === 'quiz' && (
            <motion.section
              key="quiz"
              initial={{ opacity: 0, y: 18 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -18 }}
              transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
              className="w-full"
            >
              {error ? (
                <motion.div
                  initial={{ opacity: 0, y: -10 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="mx-auto mb-6 max-w-4xl rounded-[1.5rem] border border-red-500/20 bg-red-500/10 px-5 py-4 text-sm leading-7 text-red-100 shadow-[0_26px_60px_-40px_rgba(239,68,68,0.5)]"
                >
                  {error}
                </motion.div>
              ) : null}

              <QuizForm onSubmit={handleSubmit} isSubmitting={isSubmitting} />
            </motion.section>
          )}

          {state === 'analyzing' && (
            <motion.section
              key="analyzing"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.4 }}
              className="mx-auto w-full max-w-[1440px]"
            >
              <div className="grid gap-6 xl:grid-cols-[0.92fr_1.08fr]">
                <motion.div
                  initial={{ opacity: 0, y: 18 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.42 }}
                  className="relative overflow-hidden rounded-[2.2rem] border border-border bg-card/60 p-7 shadow-xl backdrop-blur-xl lg:p-10"
                >
                  <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(197,160,89,0.08),transparent_30%)] dark:bg-[radial-gradient(circle_at_top_left,rgba(197,160,89,0.16),transparent_30%)]" />
                  <div className="pointer-events-none absolute right-8 top-8 h-32 w-32 rounded-full bg-gold/5 dark:bg-[#c5a059]/10 blur-[70px]" />

                  <div className="relative">
                    <div className="inline-flex items-center gap-2 rounded-full border border-gold/20 bg-gold/10 px-4 py-2 text-sm font-medium text-gold-dark dark:text-[#d7b168]">
                      <Sparkles size={15} />
                      {pageCopy.analyzeBadge}
                    </div>

                    <h2 className="mt-6 max-w-2xl font-heading text-[clamp(2.35rem,4vw,4rem)] leading-[0.96] tracking-[-0.04em] text-foreground">
                      {pageCopy.analyzeTitle}
                    </h2>
                    <p className="mt-5 max-w-xl text-base leading-8 text-muted-foreground">
                      {pageCopy.analyzeText}
                    </p>

                    <div className="mt-8 h-2 overflow-hidden rounded-full bg-muted">
                      <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: '100%' }}
                        transition={{ duration: 2.8, ease: 'easeInOut' }}
                        className="h-full rounded-full bg-gold-btn-gradient"
                      />
                    </div>

                    <div className="mt-8 grid gap-4 sm:grid-cols-3">
                      {pageCopy.heroMetrics.map((item, index) => (
                        <motion.div
                          key={item.label}
                          initial={{ opacity: 0, y: 12 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: 0.12 + index * 0.08, duration: 0.3 }}
                          className="rounded-[1.4rem] border border-border bg-muted/20 px-4 py-4"
                        >
                          <p className="text-[11px] uppercase tracking-[0.24em] text-muted-foreground">
                            {item.label}
                          </p>
                          <p className="mt-3 font-heading text-2xl text-foreground">{item.value}</p>
                        </motion.div>
                      ))}
                    </div>

                    <div className="mt-8 rounded-[1.5rem] border border-border bg-muted/10 px-5 py-5">
                      <p className="text-[11px] uppercase tracking-[0.28em] text-muted-foreground">
                        {pageCopy.analyzePanelTitle}
                      </p>
                      <p className="mt-3 text-sm leading-7 text-muted-foreground">{pageCopy.analyzePanelText}</p>
                    </div>
                  </div>
                </motion.div>

                <motion.div
                  initial={{ opacity: 0, y: 18 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.42, delay: 0.06 }}
                  className="relative overflow-hidden rounded-[2.2rem] border border-border bg-card/60 p-7 shadow-xl backdrop-blur-xl lg:p-10"
                >
                  <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(255,255,255,0.03),transparent_36%)]" />

                  <div className="relative">
                    <div className="flex items-start justify-between gap-4">
                      <div>
                        <p className="text-sm font-medium text-gold-dark dark:text-[#d7b168]">{pageCopy.analyzePanelTitle}</p>
                        <h3 className="mt-3 font-heading text-3xl leading-tight tracking-[-0.03em] text-foreground">
                          {t('results.ai_picked')}
                        </h3>
                      </div>
                      <div className="flex h-12 w-12 items-center justify-center rounded-[1rem] border border-border bg-card/40 text-gold-dark dark:text-[#d7b168]">
                        <Gem size={20} />
                      </div>
                    </div>

                    <div className="mt-8 space-y-4">
                      {analysisSteps.map((item, index) => (
                        <motion.div
                          key={item}
                          initial={{ opacity: 0, x: -16 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.2 + index * 0.16, duration: 0.35 }}
                          className="flex items-start gap-4 rounded-[1.5rem] border border-border bg-muted/20 px-5 py-5"
                        >
                          <div className="mt-0.5 flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-gold text-sm font-semibold text-[#121212] dark:text-cream">
                            {String(index + 1).padStart(2, '0')}
                          </div>
                          <div className="flex-1">
                            <div className="flex items-center gap-3">
                              <span className="h-2.5 w-2.5 rounded-full bg-emerald-500 shadow-[0_0_12px_rgba(34,197,94,0.4)]" />
                              <p className="text-sm leading-7 text-foreground/90">{item}</p>
                            </div>
                          </div>
                        </motion.div>
                      ))}
                    </div>

                    <div className="mt-7 rounded-[1.5rem] border border-gold/14 bg-gold/5 px-5 py-5">
                      <div className="flex items-center gap-3">
                        <CheckCircle2 size={18} className="text-gold-dark dark:text-[#d7b168]" />
                        <p className="text-sm leading-7 text-foreground/80">{t('analyzing.message')}</p>
                      </div>
                    </div>
                  </div>
                </motion.div>
              </div>
            </motion.section>
          )}

          {state === 'results' && (
            <motion.section
              key="results"
              initial={{ opacity: 0, y: 18 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -18 }}
              transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
              className="w-full"
            >
              <RecommendationCards 
                recommendations={recommendations} 
                analysis={analysis}
                onRetake={handleRetake} 
              />
            </motion.section>
          )}

          {state === 'history' && (
            <motion.section
              key="history"
              initial={{ opacity: 0, y: 18 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -18 }}
              transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
              className="w-full"
            >
              <QuizHistory onViewResult={handleShowResultFromHistory} onBack={() => setState('intro')} />
            </motion.section>
          )}
        </AnimatePresence>
      </main>
    </div>
  );
}
