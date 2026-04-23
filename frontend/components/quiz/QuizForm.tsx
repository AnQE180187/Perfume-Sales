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
    <div className="mx-auto w-full max-w-[1440px]">
      <div className="grid gap-5 xl:grid-cols-[320px_minmax(0,1fr)]">
        <aside className="relative overflow-hidden rounded-[2rem] border border-border bg-card p-5 shadow-[0_20px_60px_-40px_rgba(0,0,0,0.06)] dark:shadow-[0_34px_90px_-52px_rgba(0,0,0,0.88)] xl:sticky xl:top-24 xl:self-start sm:p-6">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(197,160,89,0.14),transparent_30%)]" />

          <div className="relative rounded-[1.7rem] border border-gold/20 bg-secondary p-5">
            <div className="inline-flex items-center gap-2 rounded-full border border-gold/20 bg-gold/10 px-3 py-1.5 text-sm font-medium text-gold">
              <Sparkles size={14} />
              {helperCopy.progressLabel}
            </div>

            <div className="mt-5 flex items-end justify-between gap-4">
              <div>
                <p className="text-sm text-muted-foreground">{helperCopy.currentLabel}</p>
                <p className="mt-1 font-heading text-5xl leading-none tracking-[-0.04em] text-foreground">
                  {String(step + 1).padStart(2, '0')}
                </p>
              </div>
              <div className="rounded-[1.25rem] border border-border bg-secondary px-4 py-3 text-right">
                <p className="text-[11px] uppercase tracking-[0.24em] text-muted-foreground">{t('step_label')}</p>
                <p className="mt-2 text-lg font-semibold text-foreground">{totalSteps}</p>
              </div>
            </div>

            <div className="mt-5 h-2 overflow-hidden rounded-full bg-secondary">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.4, ease: [0.22, 1, 0.36, 1] }}
                className="h-full rounded-full bg-[linear-gradient(90deg,#8f6b3f,#d6b36d,#f0d7a1)]"
              />
            </div>

            <div className="mt-4 flex items-center justify-between gap-3 text-sm text-muted-foreground">
              <span>
                {completedCount}/{totalSteps} {helperCopy.completedLabel.toLowerCase()}
              </span>
              <span>{Math.round(progress)}%</span>
            </div>

            <p className="mt-4 text-sm leading-7 text-muted-foreground">{helperCopy.durationLabel}</p>
          </div>

          <div className="relative mt-5">
            <p className="mb-3 text-[11px] uppercase tracking-[0.28em] text-muted-foreground">
              {helperCopy.stageLabel}
            </p>

            <div className="space-y-3">
              {steps.map((item, index) => {
                const Icon = item.stepIcon;
                const isCurrent = index === step;
                const isDone = index < step;

                return (
                  <motion.div
                    key={item.id}
                    whileHover={{ x: 4 }}
                    className={`rounded-[1.45rem] border px-4 py-4 transition-all duration-300 ${
                      isCurrent
                        ? 'border-gold/20 bg-secondary border-gold shadow-[0_20px_40px_-20px_rgba(197,160,89,0.25)] dark:shadow-[0_22px_55px_-38px_rgba(197,160,89,0.45)]'
                        : isDone
                          ? 'border-border bg-secondary'
                          : 'border-border bg-transparent opacity-75'
                    }`}
                  >
                    <div className="flex items-start gap-3">
                      <div
                        className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-[1rem] ${
                          isCurrent
                            ? 'bg-gold text-luxury-black'
                            : isDone
                              ? 'bg-emerald-500 text-white'
                              : 'bg-secondary text-muted-foreground'
                        }`}
                      >
                        {isDone ? <Check size={12} strokeWidth={3} /> : <span className="text-[10px] font-bold">{item.id}</span>}
                      </div>

                      <div className="min-w-0">
                        <div className="flex items-center gap-2">
                          <span className="text-[11px] uppercase tracking-[0.22em] text-muted-foreground">
                            {t('step_label')} {item.id}
                          </span>
                        </div>
                        <p className="mt-2 text-sm font-semibold leading-6 text-foreground">
                          {t(item.titleKey)}
                        </p>
                        <p className="mt-1 text-sm leading-6 text-muted-foreground">{t(item.subtitleKey)}</p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          <div className="relative mt-5 rounded-[1.7rem] border border-border bg-secondary p-5">
            <p className="text-sm font-semibold text-foreground">{helperCopy.selectionsLabel}</p>
            <p className="mt-2 text-sm leading-7 text-muted-foreground">{helperCopy.summaryHint}</p>

            <div className="mt-4 space-y-3">
              {selectionSummary.map((item) => (
                <div key={item.id} className="flex items-start justify-between gap-4 rounded-[1rem] bg-secondary px-3 py-3">
                  <div>
                    <p className="text-sm text-muted-foreground">{item.title}</p>
                    <p className="mt-1 text-sm font-medium leading-6 text-foreground">{item.value}</p>
                  </div>
                  <span
                    className={`mt-1 inline-flex h-2.5 w-2.5 rounded-full ${
                      item.completed ? 'bg-emerald-400 shadow-[0_0_10px_rgba(74,222,128,0.5)]' : 'bg-secondary-foreground/20'
                    }`}
                  />
                </div>
              ))}
            </div>
          </div>
        </aside>

        <section className="relative overflow-hidden rounded-[2rem] border border-border bg-card shadow-[0_20px_60px_-40px_rgba(0,0,0,0.06)] dark:shadow-[0_36px_90px_-54px_rgba(0,0,0,0.88)]">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(197,160,89,0.11),transparent_28%)]" />

          <div className="relative border-b border-border px-6 py-6 lg:px-8 lg:py-7">
            <div className="flex flex-col gap-6 xl:flex-row xl:items-end xl:justify-between">
              <div className="max-w-3xl">
                <div className="inline-flex items-center gap-2 rounded-full border border-gold/20 bg-gold/10 px-3 py-1.5 text-sm font-medium text-gold">
                  <CurrentStepIcon size={14} />
                  {t('step_label')} {currentStep.id} / {totalSteps}
                </div>

                <h2 className="mt-5 font-heading text-[clamp(2.5rem,4.5vw,4.4rem)] leading-[0.94] tracking-[-0.05em] text-foreground">
                  {t(currentStep.titleKey)}
                </h2>
                <p className="mt-4 max-w-2xl text-base leading-8 text-muted-foreground">{t(currentStep.subtitleKey)}</p>
              </div>

              <div className="grid gap-3 sm:grid-cols-2 xl:min-w-[360px]">
                <div className="rounded-[1.45rem] border border-border bg-secondary px-4 py-4">
                  <p className="text-[11px] uppercase tracking-[0.24em] text-muted-foreground">{helperCopy.pendingLabel}</p>
                  <p className="mt-3 text-sm font-medium leading-7 text-foreground">
                    {isSubmitting ? helperCopy.submittingLabel : currentSelectionLabel}
                  </p>
                </div>

                <div className="rounded-[1.45rem] border border-border bg-secondary px-4 py-4">
                  <p className="text-[11px] uppercase tracking-[0.24em] text-muted-foreground">{helperCopy.nextLabel}</p>
                  <p className="mt-3 text-sm font-medium leading-7 text-foreground">
                    {nextStep ? t(nextStep.titleKey) : helperCopy.nextFallback}
                  </p>
                </div>
              </div>
            </div>
            <div className="h-10 w-10 flex items-center justify-center rounded-full border border-border bg-background/50">
              <p className="text-xs font-bold text-gold">{Math.round(progress)}%</p>
            </div>
          </div>

          <div className="relative px-6 py-6 lg:px-8 lg:py-8">
            <div className="mb-7 flex gap-3 overflow-x-auto pb-2">
              {steps.map((item, index) => {
                const Icon = item.stepIcon;
                const isCurrent = index === step;
                const isDone = index < step;

                return (
                  <div
                    key={item.id}
                    className={`flex min-w-[140px] items-center gap-3 rounded-[1.35rem] border px-4 py-3 ${
                      isCurrent
                        ? 'border-gold/20 bg-secondary border-gold'
                        : isDone
                          ? 'border-emerald-500/20 bg-emerald-500/8'
                          : 'border-border bg-secondary'
                    }`}
                  >
                    <div
                      className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-full ${
                        isCurrent
                          ? 'bg-gold text-luxury-black'
                          : isDone
                            ? 'bg-emerald-500 text-white'
                            : 'bg-secondary text-muted-foreground'
                      }`}
                    >
                      {isDone ? <Check size={16} strokeWidth={2.2} /> : <Icon size={16} strokeWidth={1.8} />}
                    </div>

                    <div className="min-w-0">
                      <p className="text-[11px] uppercase tracking-[0.22em] text-muted-foreground">
                        {t('step_label')} {item.id}
                      </p>
                      <p className="mt-1 truncate text-sm font-medium text-foreground">{t(item.titleKey)}</p>
                    </div>
                  </div>
                );
              })}
            </div>

            <AnimatePresence mode="wait">
              <motion.div
                key={step}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.32, ease: [0.22, 1, 0.36, 1] }}
              >
                <div className={`grid gap-4 ${getGridClass(currentStep.options.length)}`}>
                  {currentStep.options.map((opt, index) => {
                    const Icon = opt.icon;
                    const isSelected = answers[currentStep.key] === opt.value;
                    const supportText = opt.description || getOptionNote(currentStep.key, opt.value);

                    return (
                      <motion.button
                        key={opt.value}
                        initial={{ opacity: 0, y: 18 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.05, duration: 0.28 }}
                        whileHover={{ y: -6 }}
                        whileTap={{ scale: 0.992 }}
                        onClick={() => handleSelect(opt.value)}
                        disabled={isSubmitting}
                        className={`group relative flex min-h-[210px] flex-col rounded-[1.7rem] border p-5 text-left transition-all duration-300 disabled:cursor-not-allowed disabled:opacity-50 ${
                          isSelected
                            ? 'border-gold/20 bg-card border-gold shadow-[0_20px_50px_-20px_rgba(197,160,89,0.2)] dark:shadow-[0_28px_65px_-40px_rgba(197,160,89,0.45)]'
                            : 'border-border bg-secondary hover:border-gold/20 hover:bg-secondary hover:shadow-[0_30px_70px_-46px_rgba(0,0,0,0.9)]'
                        }`}
                      >
                        <div className="flex items-start justify-between gap-4">
                          <div
                            className={`flex h-14 w-14 items-center justify-center rounded-[1.15rem] ${
                              isSelected ? 'bg-gold text-luxury-black' : 'bg-secondary text-foreground'
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

                          <div className="flex items-center gap-2">
                            {isSelected ? (
                              <span className="inline-flex items-center rounded-full border border-gold/20 bg-gold/10 px-3 py-1 text-[11px] uppercase tracking-[0.22em] text-gold">
                                {helperCopy.selectedLabel}
                              </span>
                            ) : null}

                            <span className="inline-flex rounded-full border border-border bg-secondary px-3 py-1 text-[11px] uppercase tracking-[0.22em] text-muted-foreground">
                              {String(index + 1).padStart(2, '0')}
                            </span>
                            <div className={`h-1.5 w-1.5 rounded-full transition-all duration-500 ${isSelected ? 'bg-gold' : 'bg-muted-foreground/20'}`} />
                          </div>
                        </div>

                        <div className="mt-7 flex-1">
                          <p className="text-xl font-semibold leading-8 text-foreground">{opt.label}</p>
                          <p className="mt-3 text-sm leading-7 text-muted-foreground">{supportText}</p>
                        </div>

                        <div className="mt-6 flex items-center justify-between border-t border-border pt-4">
                          <span className="text-sm text-muted-foreground">
                            {isSelected ? helperCopy.selectedLabel : `${t('step_label')} ${currentStep.id}`}
                          </span>
                          <span
                            className={`h-2.5 w-2.5 rounded-full ${
                              isSelected ? 'bg-gold' : 'bg-secondary-foreground/20 group-hover:bg-gold/60'
                            }`}
                          />
                        </div>
                      </motion.button>
                    );
                  })}
                </div>

                <div className="mt-8 flex flex-col gap-4 border-t border-border pt-6 sm:flex-row sm:items-center sm:justify-between">
                  <div>
                    <p className="text-sm leading-7 text-muted-foreground">
                      {isSubmitting ? helperCopy.submittingLabel : helperCopy.pickHint}
                    </p>
                    <p className="mt-1 text-sm leading-7 text-muted-foreground">{helperCopy.backHint}</p>
                  </div>
                </motion.div>
              </AnimatePresence>
            </div>
          </div>

                  {step > 0 ? (
                    <button
                      onClick={handleBack}
                      disabled={isSubmitting}
                      className="inline-flex min-h-12 items-center gap-2 rounded-full border border-border bg-secondary px-5 text-sm font-medium text-foreground transition-all duration-300 hover:-translate-y-0.5 hover:border-gold/20 hover:text-gold disabled:opacity-50"
                    >
                      <ArrowLeft size={16} />
                      {t('prev_step')}
                    </button>
                  ) : null}
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
