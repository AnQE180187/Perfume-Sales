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
  Zap,
  Bot,
  BrainCircuit,
  Loader2,
  ChevronRight,
  ChevronLeft,
  X
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
          introPanelHeading: 'Khám Phá Mùi Hương Phù Hợp Với Bạn',
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

  const handleShowResultFromHistory = (recs: QuizRecommendation[], analysisText?: string) => {
    setRecommendations(recs);
    setAnalysis(analysisText || null);
    setState('results');
  };

  return (
    <div className="relative isolate min-h-screen overflow-hidden bg-[#020617] text-[#F8FAFC]">
      {/* Cinematic Background */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_-20%,#1e293b,transparent)]" />
      <div className="absolute inset-0 opacity-[0.03] [background-image:radial-gradient(#ffffff_1px,transparent_1px)] [background-size:40px_40px]" />
      <div className="pointer-events-none absolute left-0 top-0 h-full w-full bg-[radial-gradient(circle_at_0%_0%,rgba(197,160,89,0.05),transparent_50%),radial-gradient(circle_at_100%_100%,rgba(197,160,89,0.05),transparent_50%)]" />

      <main className="container relative z-10 mx-auto px-4 py-20 sm:px-6 lg:px-8">
        <AnimatePresence mode="wait">
          {state === 'intro' && (
            <motion.div
              key="intro"
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 1.05 }}
              className="mx-auto max-w-5xl"
            >
              <div className="relative overflow-hidden rounded-[3rem] border border-white/5 bg-zinc-900/40 p-8 backdrop-blur-3xl md:p-20">
                <div className="absolute -right-20 -top-20 h-64 w-64 rounded-full bg-gold/10 blur-3xl" />
                <div className="absolute -bottom-20 -left-20 h-64 w-64 rounded-full bg-gold/5 blur-3xl" />

                <div className="relative space-y-12">
                  <div className="space-y-6 text-center">
                    <motion.div 
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="inline-flex items-center gap-2 rounded-full border border-gold/20 bg-gold/5 px-4 py-2 text-[10px] font-bold uppercase tracking-[0.3em] text-gold"
                    >
                      <Sparkles size={14} />
                      {t('intro.label')}
                    </motion.div>
                    
                    <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-8xl">
                        The <span className="gold-gradient">Ritual</span>
                    </h1>
                    
                    <p className="mx-auto max-w-2xl font-body text-base leading-relaxed text-stone-400 md:text-xl">
                        {t('intro.description')}
                    </p>
                  </div>

                  <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
                    {pageCopy.heroMetrics.map((item, i) => (
                      <div key={i} className="rounded-3xl border border-white/5 bg-white/[0.02] p-6 text-center transition-all hover:bg-white/[0.05]">
                        <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-stone-500">{item.label}</p>
                        <p className="font-heading text-4xl text-gold">{item.value}</p>
                      </div>
                    ))}
                  </div>

                  <div className="flex flex-col items-center justify-center gap-6 md:flex-row">
                    {isAuthenticated ? (
                      <>
                        <button
                          onClick={() => setState('quiz')}
                          className="group relative flex h-16 items-center gap-4 overflow-hidden rounded-full bg-gold px-12 font-heading text-xs font-bold uppercase tracking-[0.2em] text-black transition-all hover:scale-105"
                        >
                          <FlaskConical size={18} />
                          <span>{locale === 'vi' ? 'Bắt Đầu Nghi Lễ' : 'Begin Ritual'}</span>
                          <ChevronRight size={18} className="transition-transform group-hover:translate-x-1" />
                        </button>
                        <button
                          onClick={() => setState('history')}
                          className="flex h-16 items-center gap-4 rounded-full border border-white/10 bg-white/5 px-10 font-heading text-xs font-bold uppercase tracking-[0.2em] text-foreground transition-all hover:bg-white/10"
                        >
                          <Clock3 size={18} />
                          <span>{locale === 'vi' ? 'Lịch Sử Cảm Quan' : 'Olfactory History'}</span>
                        </button>
                      </>
                    ) : (
                      <Link
                        href="/login"
                        className="group relative flex h-16 items-center gap-4 overflow-hidden rounded-full bg-gold px-12 font-heading text-xs font-bold uppercase tracking-[0.2em] text-black transition-all hover:scale-105"
                      >
                        <LogIn size={18} />
                        <span>{t('intro.login_btn')}</span>
                        <ChevronRight size={18} className="transition-transform group-hover:translate-x-1" />
                      </Link>
                    )}
                  </div>

                  {!isAuthenticated && (
                    <p className="text-center text-xs font-medium uppercase tracking-widest text-stone-500">
                      {t('intro.login_required')}
                    </p>
                  )}
                </div>
              </div>
            </motion.div>
          )}

          {state === 'quiz' && (
            <motion.div
              key="quiz"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="mx-auto max-w-4xl"
            >
                <div className="mb-12 flex items-center justify-between px-4">
                    <button 
                        onClick={() => setState('intro')}
                        className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-stone-500 transition-colors hover:text-gold"
                    >
                        <ChevronLeft size={16} />
                        Abort Ritual
                    </button>
                    <div className="flex items-center gap-3">
                        <div className="h-1 w-12 rounded-full bg-gold" />
                        <div className="h-1 w-12 rounded-full bg-white/10" />
                        <div className="h-1 w-12 rounded-full bg-white/10" />
                    </div>
                </div>
                {error && (
                    <div className="mb-8 rounded-2xl border border-red-500/20 bg-red-500/10 p-4 text-center text-xs font-bold uppercase tracking-widest text-red-500">
                        {error}
                    </div>
                )}
                <QuizForm onSubmit={handleSubmit} isSubmitting={isSubmitting} />
            </motion.div>
          )}

          {state === 'analyzing' && (
            <motion.div
              key="analyzing"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="flex min-h-[60vh] flex-col items-center justify-center text-center"
            >
                <div className="relative mb-12">
                    <div className="absolute inset-0 animate-ping rounded-full bg-gold/20" />
                    <div className="relative flex h-32 w-32 items-center justify-center rounded-full border border-gold/30 bg-gold/5 backdrop-blur-2xl shadow-[0_0_50px_rgba(197,160,89,0.1)]">
                        <BrainCircuit size={48} className="animate-pulse text-gold" />
                    </div>
                </div>
                
                <h2 className="mb-4 font-heading text-4xl font-bold uppercase tracking-widest text-foreground">
                    {pageCopy.analyzeTitle}
                </h2>
                <p className="mx-auto max-w-lg font-body text-stone-400">
                    {pageCopy.analyzeText}
                </p>

                <div className="mt-12 flex gap-4">
                    {[0, 0.5, 1].map((delay, i) => (
                        <div key={i} className="h-1 w-24 overflow-hidden rounded-full bg-white/5">
                            <motion.div 
                                initial={{ x: '-100%' }}
                                animate={{ x: '100%' }}
                                transition={{ repeat: Infinity, duration: 2, ease: "linear", delay }}
                                className="h-full w-full bg-gold"
                            />
                        </div>
                    ))}
                </div>
            </motion.div>
          )}

          {state === 'results' && (
            <motion.div
              key="results"
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              className="w-full"
            >
              <RecommendationCards 
                recommendations={recommendations} 
                analysis={analysis}
                onRetake={handleRetake} 
              />
            </motion.div>
          )}

          {state === 'history' && (
            <motion.div
              key="history"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="mx-auto max-w-5xl"
            >
                <div className="mb-12 flex items-center justify-between px-4">
                    <div className="space-y-1">
                        <h2 className="font-heading text-3xl font-bold uppercase tracking-widest text-gold">Archives</h2>
                        <p className="text-[10px] font-medium uppercase tracking-[0.2em] text-stone-500">Your olfactory journey history</p>
                    </div>
                    <button 
                        onClick={() => setState('intro')}
                        className="flex h-12 w-12 items-center justify-center rounded-full border border-white/10 bg-white/5 transition-all hover:bg-white/10 hover:rotate-90"
                    >
                        <X size={20} />
                    </button>
                </div>
                <QuizHistory onViewResult={handleShowResultFromHistory} onBack={() => setState('intro')} />
            </motion.div>
          )}
        </AnimatePresence>
      </main>
    </div>
  );
}
