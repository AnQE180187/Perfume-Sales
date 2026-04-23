'use client';

import { useMemo, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { useLocale, useTranslations } from 'next-intl';
import {
  ArrowLeft,
  Briefcase,
  CalendarHeart,
  Check,
  Clock,
  Flame,
  Flower2,
  Heart,
  Hourglass,
  type LucideIcon,
  PartyPopper,
  Sparkles,
  Star,
  Timer,
  TreePine,
  User,
  Users,
  Wallet,
  Wind,
  Zap,
  Leaf,
} from 'lucide-react';

import { type QuizAnswers } from '@/services/quiz.service';

interface QuizOption {
  label: string;
  value: string;
  icon?: LucideIcon;
  description?: string;
}

interface QuizStep {
  id: number;
  titleKey: string;
  subtitleKey: string;
  key: keyof QuizAnswers;
  stepIcon: LucideIcon;
  options: QuizOption[];
}

interface QuizFormProps {
  onSubmit: (answers: QuizAnswers) => void;
  isSubmitting: boolean;
}

export function QuizForm({ onSubmit, isSubmitting }: QuizFormProps) {
  const t = useTranslations('quiz');
  const locale = useLocale();
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState<Record<string, string>>({});

  const helperCopy = useMemo(
    () =>
      locale === 'vi'
        ? {
          progressLabel: 'Tiến độ hồ sơ',
          currentLabel: 'Đang trả lời',
          selectionsLabel: 'Tóm tắt lựa chọn',
          pendingLabel: 'Trạng thái hiện tại',
          pickHint: 'Chọn một phương án để chuyển sang bước tiếp theo.',
          answerPlaceholder: 'Chưa chọn',
          selectedLabel: 'Đã chọn',
          nextLabel: 'Bước kế tiếp',
          nextFallback: 'Hoàn tất để nhận shortlist',
          stageLabel: 'Lộ trình gợi ý',
          summaryHint: 'Mỗi lựa chọn đều được dùng để tinh chỉnh danh sách gợi ý cuối cùng.',
          submittingLabel: 'Hệ thống đang gửi hồ sơ mùi hương của bạn...',
          durationLabel: 'Khoảng 2 phút để hoàn tất',
          backHint: 'Bạn có thể quay lại bước trước để thay đổi lựa chọn.',
          completedLabel: 'Đã hoàn thành',
        }
        : {
          progressLabel: 'Profile progress',
          currentLabel: 'Current step',
          selectionsLabel: 'Selection summary',
          pendingLabel: 'Current status',
          pickHint: 'Choose one option to move to the next step.',
          answerPlaceholder: 'Not selected',
          selectedLabel: 'Selected',
          nextLabel: 'Up next',
          nextFallback: 'Finish to receive the shortlist',
          stageLabel: 'Recommendation flow',
          summaryHint: 'Each answer is used to refine the final shortlist.',
          submittingLabel: 'Sending your scent profile to the system...',
          durationLabel: 'About 2 minutes to finish',
          backHint: 'You can return to the previous step and adjust your selection.',
          completedLabel: 'Completed',
        },
    [locale],
  );

  const optionNotes = useMemo<Record<string, Record<string, string>>>(
    () =>
      locale === 'vi'
        ? {
          gender: {
            MALE: 'Tập trung vào cảm giác nam tính, chỉn chu và lịch lãm.',
            FEMALE: 'Ưu tiên nét mềm mại, thanh lịch và nữ tính hơn.',
            UNISEX: 'Giữ sự cân bằng để dễ dùng và linh hoạt trong nhiều dịp.',
          },
          occasion: {
            daily: 'Thiên về cảm giác sạch sẽ, dễ dùng và không gây mệt.',
            office: 'Ưu tiên sự chuyên nghiệp, gọn gàng và tinh tế.',
            date: 'Nghiêng về độ cuốn hút và cảm giác gần gũi hơn.',
            party: 'Phù hợp môi trường đông người với cá tính rõ ràng.',
            special_event: 'Dành cho những dịp cần dấu ấn nổi bật hơn thường ngày.',
          },
          budgetMin: {
            '0-500000': 'Mức dễ tiếp cận, phù hợp để bắt đầu tìm đúng gu.',
            '500000-1000000': 'Khoảng giá cân bằng giữa chất lượng và độ linh hoạt.',
            '1000000-2000000': 'Phù hợp nếu bạn muốn trải nghiệm cao cấp hơn.',
            '2000000-5000000': 'Tập trung vào các lựa chọn có chiều sâu và hoàn thiện tốt.',
            '5000000-99999999': 'Dành cho trải nghiệm sưu tầm hoặc gu mùi nổi bật.',
          },
          preferredFamily: {
            Fresh: 'Sáng, sạch, dễ chịu và phù hợp nhiều hoàn cảnh sử dụng.',
            Floral: 'Mềm mại, nữ tính hoặc thanh lịch tùy cách phối tầng hương.',
            Woody: 'Ấm, sang, có chiều sâu và thường tạo cảm giác trưởng thành.',
            Oriental: 'Đậm hơn, bí ẩn hơn và để lại dấu ấn rõ ràng.',
            Aromatic: 'Thảo mộc, xanh và có cảm giác gọn gàng, hiện đại.',
          },
          longevity: {
            light: 'Phù hợp nhu cầu nhẹ nhàng, thoáng và dễ làm mới trong ngày.',
            moderate: 'Cân bằng giữa độ hiện diện và sự dễ chịu khi dùng thường xuyên.',
            long_lasting: 'Giữ mùi đủ lâu cho ngày dài hoặc các cuộc hẹn quan trọng.',
            very_long: 'Ưu tiên độ bám tỏa rõ rệt và cảm giác đậm dấu ấn hơn.',
          },
        }
        : {
          gender: {
            MALE: 'Leans into a clean, tailored, and masculine profile.',
            FEMALE: 'Prioritizes a softer, elegant, and more feminine feel.',
            UNISEX: 'Keeps the profile balanced and versatile across occasions.',
          },
          occasion: {
            daily: 'Aims for something clean, easy to wear, and never tiring.',
            office: 'Keeps the tone polished, composed, and understated.',
            date: 'Moves toward a more intimate and magnetic impression.',
            party: 'Built for energy, presence, and clearer personality.',
            special_event: 'Reserved for moments that call for extra impact.',
          },
          budgetMin: {
            '0-500000': 'Accessible options to start defining your taste.',
            '500000-1000000': 'A balanced zone between quality and flexibility.',
            '1000000-2000000': 'Ideal if you want a more premium experience.',
            '2000000-5000000': 'Focused on depth, richness, and better finish.',
            '5000000-99999999': 'Best for collectors or standout signatures.',
          },
          preferredFamily: {
            Fresh: 'Bright, clean, and easy to wear in most routines.',
            Floral: 'Soft, elegant, and expressive depending on composition.',
            Woody: 'Warm, refined, and usually more grounded in character.',
            Oriental: 'Deeper, richer, and more memorable in presence.',
            Aromatic: 'Herbal, green, and clean with a modern edge.',
          },
          longevity: {
            light: 'Best for a softer, airy presence during the day.',
            moderate: 'Balanced for comfort and steady presence.',
            long_lasting: 'Suitable for long workdays and important plans.',
            very_long: 'Prioritizes stronger projection and lasting impact.',
          },
        },
    [locale],
  );

  const steps: QuizStep[] = [
    {
      id: 1,
      titleKey: 'steps.gender.title',
      subtitleKey: 'steps.gender.subtitle',
      key: 'gender',
      stepIcon: User,
      options: [
        { label: t('steps.gender.options.male'), value: 'MALE', icon: User },
        { label: t('steps.gender.options.female'), value: 'FEMALE', icon: Heart },
        { label: t('steps.gender.options.unisex'), value: 'UNISEX', icon: Users },
      ],
    },
    {
      id: 2,
      titleKey: 'steps.occasion.title',
      subtitleKey: 'steps.occasion.subtitle',
      key: 'occasion',
      stepIcon: Briefcase,
      options: [
        { label: t('steps.occasion.options.daily'), value: 'daily', icon: Star },
        { label: t('steps.occasion.options.office'), value: 'office', icon: Briefcase },
        { label: t('steps.occasion.options.date'), value: 'date', icon: CalendarHeart },
        { label: t('steps.occasion.options.party'), value: 'party', icon: PartyPopper },
        { label: t('steps.occasion.options.special_event'), value: 'special_event', icon: Sparkles },
      ],
    },
    {
      id: 3,
      titleKey: 'steps.budget.title',
      subtitleKey: 'steps.budget.subtitle',
      key: 'budgetMin',
      stepIcon: Wallet,
      options: [
        { label: t('steps.budget.options.under_500k'), value: '0-500000', icon: Wallet },
        { label: t('steps.budget.options.500k_1m'), value: '500000-1000000', icon: Wallet },
        { label: t('steps.budget.options.1m_2m'), value: '1000000-2000000', icon: Wallet },
        { label: t('steps.budget.options.2m_5m'), value: '2000000-5000000', icon: Wallet },
        { label: t('steps.budget.options.over_5m'), value: '5000000-99999999', icon: Wallet },
      ],
    },
    {
      id: 4,
      titleKey: 'steps.scent_family.title',
      subtitleKey: 'steps.scent_family.subtitle',
      key: 'preferredFamily',
      stepIcon: Flower2,
      options: [
        { label: t('steps.scent_family.options.fresh'), value: 'Fresh', icon: Wind },
        { label: t('steps.scent_family.options.floral'), value: 'Floral', icon: Flower2 },
        { label: t('steps.scent_family.options.woody'), value: 'Woody', icon: TreePine },
        { label: t('steps.scent_family.options.oriental'), value: 'Oriental', icon: Flame },
        { label: t('steps.scent_family.options.aromatic'), value: 'Aromatic', icon: Leaf },
      ],
    },
    {
      id: 5,
      titleKey: 'steps.longevity.title',
      subtitleKey: 'steps.longevity.subtitle',
      key: 'longevity',
      stepIcon: Timer,
      options: [
        { label: t('steps.longevity.options.light'), value: 'light', icon: Clock },
        { label: t('steps.longevity.options.moderate'), value: 'moderate', icon: Timer },
        { label: t('steps.longevity.options.long_lasting'), value: 'long_lasting', icon: Hourglass },
        { label: t('steps.longevity.options.very_long'), value: 'very_long', icon: Zap },
      ],
    },
  ];

  const totalSteps = steps.length;
  const currentStep = steps[step];
  const currentChoice = answers[currentStep.key];
  const progress = ((step + 1) / totalSteps) * 100;
  const completedCount = steps.filter((item) => Boolean(answers[item.key])).length;
  const nextStep = steps[step + 1] ?? null;
  const CurrentStepIcon = currentStep.stepIcon;

  const selectionSummary = steps.map((item) => {
    const selectedValue = answers[item.key];
    const selectedOption = item.options.find((option) => option.value === selectedValue);

    return {
      id: item.id,
      title: t(item.titleKey),
      value: selectedOption?.label ?? helperCopy.answerPlaceholder,
      completed: Boolean(selectedOption),
    };
  });

  const currentSelectionLabel =
    currentStep.options.find((option) => option.value === currentChoice)?.label ??
    helperCopy.answerPlaceholder;

  const handleSelect = (value: string) => {
    const newAnswers = { ...answers, [currentStep.key]: value };
    setAnswers(newAnswers);

    if (step < totalSteps - 1) {
      setStep(step + 1);
      return;
    }

    const quizAnswers: QuizAnswers = {
      gender: (newAnswers.gender as QuizAnswers['gender']) || undefined,
      occasion: newAnswers.occasion || undefined,
      preferredFamily: newAnswers.preferredFamily || undefined,
      longevity: newAnswers.longevity || undefined,
    };

    const budgetVal = newAnswers.budgetMin;
    if (budgetVal) {
      const [min, max] = budgetVal.split('-').map(Number);
      quizAnswers.budgetMin = min;
      quizAnswers.budgetMax = max;
    }

    onSubmit(quizAnswers);
  };

  const handleBack = () => {
    if (step > 0) {
      setStep(step - 1);
    }
  };

  const getGridClass = (count: number) => {
    if (count <= 3) return 'grid-cols-1 lg:grid-cols-3';
    if (count === 4) return 'grid-cols-1 md:grid-cols-2 xl:grid-cols-4';
    if (count === 5) return 'grid-cols-1 md:grid-cols-2 xl:grid-cols-5';
    return 'grid-cols-1 md:grid-cols-2 xl:grid-cols-3';
  };

  const getOptionNote = (stepKey: keyof QuizAnswers, value: string) =>
    optionNotes[String(stepKey)]?.[value] ?? '';

  return (
    <div className="mx-auto w-full max-w-[1400px]">
      <div className="grid gap-6 lg:grid-cols-[280px_1fr]">
        {/* SIDEBAR: Hidden on Mobile, Fixed on Desktop */}
        <aside className="hidden lg:block">
          <div className="sticky top-24 space-y-6">
            {/* Progress Card */}
            <div className="relative overflow-hidden rounded-[2rem] border border-border bg-card/30 p-6 backdrop-blur-xl shadow-sm">
              <div className="absolute inset-0 bg-gradient-to-br from-gold/5 via-transparent to-transparent opacity-50" />
              <div className="relative">
                <div className="flex items-center justify-between mb-6">
                  <div className="flex flex-col">
                    <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-gold-dark/60 mb-1">{helperCopy.progressLabel}</span>
                    <div className="flex items-baseline gap-1">
                      <span className="font-heading text-4xl leading-none tracking-tighter text-foreground">{String(step + 1).padStart(2, '0')}</span>
                      <span className="text-lg font-medium text-muted-foreground/30">/</span>
                      <span className="text-xl font-bold text-muted-foreground/30">{totalSteps}</span>
                    </div>
                  </div>
                  <div className="h-12 w-12 rounded-2xl bg-gold/5 border border-gold/10 flex items-center justify-center">
                    <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse shadow-[0_0_8px_rgba(16,185,129,0.5)]" />
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-widest text-muted-foreground/60">
                    <span>{Math.round(progress)}% {helperCopy.completedLabel.toLowerCase()}</span>
                  </div>
                  <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted/30 p-[1px] border border-border/40">
                    <motion.div
                      initial={{ width: 0 }}
                      animate={{ width: `${progress}%` }}
                      transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
                      className="h-full rounded-full bg-gold-btn-gradient shadow-[0_0_10px_rgba(197,160,89,0.2)]"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Steps Navigation - Vertical Minimalist */}
            <div className="rounded-[2rem] border border-border bg-card/20 p-5 backdrop-blur-md">
              <p className="mb-6 px-3 text-[10px] font-bold uppercase tracking-[0.25em] text-muted-foreground/40">
                {helperCopy.stageLabel}
              </p>

              <div className="space-y-2">
                {steps.map((item, index) => {
                  const isCurrent = index === step;
                  const isDone = index < step;

                  return (
                    <div
                      key={item.id}
                      className={`group relative flex items-center gap-4 px-4 py-3 rounded-2xl transition-all duration-300 ${isCurrent ? 'bg-gold/5' : ''
                        }`}
                    >
                      <div
                        className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-lg border transition-all duration-500 ${isCurrent
                            ? 'border-gold bg-gold text-primary-foreground shadow-[0_0_10px_rgba(197,160,89,0.3)]'
                            : isDone
                              ? 'border-emerald-500/50 bg-emerald-500/10 text-emerald-500'
                              : 'border-border bg-muted/20 text-muted-foreground/30'
                          }`}
                      >
                        {isDone ? <Check size={12} strokeWidth={3} /> : <span className="text-[10px] font-bold">{item.id}</span>}
                      </div>

                      <div className="min-w-0">
                        <p className={`text-[11px] font-bold uppercase tracking-wider transition-colors duration-300 ${isCurrent ? 'text-foreground' : 'text-muted-foreground/30'
                          }`}>
                          {t(item.titleKey)}
                        </p>
                        {isCurrent && (
                          <p className="text-[11px] font-medium text-gold-dark/60 truncate italic">
                            {currentSelectionLabel}
                          </p>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Selection Summary - Improved */}
            <div className="rounded-[2rem] border border-border/40 bg-muted/5 p-6 border-dashed">
              <p className="mb-5 text-[10px] font-bold uppercase tracking-[0.25em] text-muted-foreground/50">{helperCopy.selectionsLabel}</p>
              <div className="space-y-4">
                {selectionSummary.filter((s) => s.completed).map((item) => (
                  <div key={item.id} className="flex flex-col gap-1">
                    <div className="flex items-center justify-between">
                      <p className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground/30">{item.title}</p>
                      <div className="h-1 w-1 rounded-full bg-emerald-500" />
                    </div>
                    <p className="text-xs font-medium text-foreground/80">{item.value}</p>
                  </div>
                ))}
                {completedCount === 0 && (
                  <p className="text-xs italic text-muted-foreground/30">Hệ thống đang chờ những lựa chọn đầu tiên của bạn...</p>
                )}
              </div>
            </div>
          </div>
        </aside>

        {/* MAIN QUESTION AREA */}
        <section className="relative flex flex-col justify-between overflow-hidden rounded-[2.5rem] border border-border bg-card/40 shadow-2xl backdrop-blur-3xl min-h-[720px]">
          {/* Subtle noise and gradients */}
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(197,160,89,0.08),transparent_35%)]" />
          <div className="absolute inset-0 opacity-[0.03] dark:opacity-[0.05] pointer-events-none noise-panel" />

          {/* MOBILE PROGRESS INDICATOR */}
          <div className="lg:hidden border-b border-border bg-muted/20 px-6 py-4 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gold text-primary-foreground font-heading font-bold text-lg">
                {step + 1}
              </div>
              <div className="flex flex-col">
                <span className="text-[10px] font-bold uppercase tracking-widest text-gold-dark">{t('step_label')} {step + 1} / {totalSteps}</span>
                <span className="text-xs font-medium text-foreground">{t(currentStep.titleKey)}</span>
              </div>
            </div>
            <div className="h-10 w-10 flex items-center justify-center rounded-full border border-border bg-background/50">
              <p className="text-xs font-bold text-gold">{Math.round(progress)}%</p>
            </div>
          </div>

          <div className="relative flex-1">
            {/* Header section with prominent title */}
            <div className="px-6 py-6 lg:px-12 lg:py-8 border-b border-border/40">
              <div className="flex items-center gap-3 mb-8">
                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-gold/10 text-gold-dark dark:text-[#ccac66] border border-gold/10">
                  <CurrentStepIcon size={24} strokeWidth={1.5} />
                </div>
                <div className="h-px w-12 bg-gold/20" />
                <span className="text-[11px] font-bold uppercase tracking-[0.3em] text-gold-dark/60">{t('step_label')} {currentStep.id}</span>
              </div>

              <h2 className="font-heading text-[clamp(1.75rem,4vw,3rem)] leading-[1.1] tracking-[-0.04em] text-foreground mb-6">
                {t(currentStep.titleKey)}
              </h2>
              <p className="max-w-2xl text-base md:text-lg leading-relaxed text-muted-foreground/60">{t(currentStep.subtitleKey)}</p>
            </div>

            {/* Options grid with ritual-like feel */}
            <div className="px-6 py-4 lg:px-12 lg:py-6">
              <AnimatePresence mode="wait">
                <motion.div
                  key={step}
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  transition={{ duration: 0.4, ease: [0.22, 1, 0.36, 1] }}
                >
                  <div className={`grid gap-5 ${getGridClass(currentStep.options.length)}`}>
                    {currentStep.options.map((opt, index) => {
                      const Icon = opt.icon;
                      const isSelected = answers[currentStep.key] === opt.value;
                      const supportText = opt.description || getOptionNote(currentStep.key, opt.value);

                      return (
                        <motion.button
                          key={opt.value}
                          initial={{ opacity: 0, scale: 0.95 }}
                          animate={{ opacity: 1, scale: 1 }}
                          transition={{ delay: index * 0.04, duration: 0.3 }}
                          whileHover={{ y: -8 }}
                          whileTap={{ scale: 0.98 }}
                          onClick={() => handleSelect(opt.value)}
                          disabled={isSubmitting}
                          className={`group relative flex flex-col min-h-[180px] overflow-hidden rounded-[2.2rem] border p-5 md:p-6 text-left transition-all duration-500 disabled:opacity-50 ${isSelected
                              ? 'border-gold bg-gold/[0.04] shadow-[0_25px_50px_-12px_rgba(197,160,89,0.12)]'
                              : 'border-border bg-muted/10 hover:border-gold/30 hover:bg-muted/20'
                            }`}
                        >
                          <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-gold/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />

                          <div className="flex items-center justify-between gap-4 mb-6">
                            <div className={`flex h-14 w-14 items-center justify-center rounded-2xl transition-all duration-500 ${isSelected
                                ? 'bg-gold text-[#121212] dark:text-cream shadow-[0_0_15px_rgba(197,160,89,0.5)]'
                                : 'bg-background/80 text-muted-foreground/60 border border-border group-hover:text-gold-dark group-hover:border-gold/30'
                              }`}>
                              {Icon ? <Icon size={24} strokeWidth={1.5} /> : null}
                            </div>
                            {isSelected && (
                              <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} className="flex h-6 w-6 items-center justify-center rounded-full bg-emerald-500 text-white shadow-[0_0_10px_rgba(16,185,129,0.4)]">
                                <Check size={14} strokeWidth={3} />
                              </motion.div>
                            )}
                          </div>

                          <div className="flex-1">
                            <h4 className="font-heading text-xl md:text-2xl tracking-tighter text-foreground group-hover:text-gold-dark transition-colors mb-3">{opt.label}</h4>
                            <p className="text-xs md:text-sm leading-relaxed text-muted-foreground/60 group-hover:text-muted-foreground transition-colors italic line-clamp-3">
                              {supportText}
                            </p>
                          </div>

                          <div className="mt-8 pt-5 border-t border-border/40 flex items-center justify-between">
                            <span className={`text-[10px] font-bold uppercase tracking-widest ${isSelected ? 'text-gold-dark' : 'hidden'}`}>
                              {isSelected ? helperCopy.selectedLabel : ''}
                            </span>
                            <div className={`h-1.5 w-1.5 rounded-full transition-all duration-500 ${isSelected ? 'bg-gold' : 'bg-muted-foreground/20'}`} />
                          </div>
                        </motion.button>
                      );
                    })}
                  </div>
                </motion.div>
              </AnimatePresence>
            </div>
          </div>

          {/* Footer Controls */}
          <div className="relative border-t border-border/40 bg-muted/10 p-8 lg:p-12">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-8">
              <div className="flex flex-col gap-2 max-w-sm">
                <div className="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.2em] text-muted-foreground/50">
                  <div className="h-1 w-1 rounded-full bg-gold animate-pulse" />
                  {isSubmitting ? helperCopy.submittingLabel : helperCopy.pickHint}
                </div>
                <p className="text-xs text-muted-foreground/30 font-medium">{helperCopy.backHint}</p>
              </div>

              <div className="flex items-center gap-4">
                {step > 0 && (
                  <button
                    onClick={handleBack}
                    disabled={isSubmitting}
                    className="group h-14 min-w-[3.5rem] flex items-center justify-center gap-3 rounded-full border border-border bg-background/50 px-8 text-sm font-bold text-foreground transition-all duration-500 hover:border-gold/40 hover:bg-gold/5 shadow-xl disabled:opacity-30"
                  >
                    <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" />
                    {t('prev_step')}
                  </button>
                )}

                {/* Visual anchor for current status in mobile logic */}
                <div className="flex-1 lg:hidden rounded-2xl bg-gold/5 border border-gold/10 p-4">
                  <p className="text-[10px] font-bold uppercase tracking-widest text-gold-dark mb-1">{helperCopy.nextLabel}</p>
                  <p className="text-xs font-medium text-foreground truncate">
                    {nextStep ? t(nextStep.titleKey) : helperCopy.nextFallback}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
