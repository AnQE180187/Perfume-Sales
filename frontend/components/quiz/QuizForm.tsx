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
  ChevronRight,
  Target
} from 'lucide-react';

import { type QuizAnswers } from '@/services/quiz.service';
import { cn } from '@/lib/utils';

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
          pickHint: 'Chọn một phương án để tiếp tục cuộc hành trình.',
          answerPlaceholder: 'Chưa chọn',
          submittingLabel: 'Đang chắt lọc tinh túy mùi hương...',
        }
        : {
          progressLabel: 'Profile progress',
          currentLabel: 'Current step',
          pickHint: 'Choose one option to continue the journey.',
          answerPlaceholder: 'Not selected',
          submittingLabel: 'Distilling olfactory essence...',
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
  const progress = ((step + 1) / totalSteps) * 100;
  const CurrentStepIcon = currentStep.stepIcon;

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

  return (
    <div className="grid grid-cols-1 gap-8 lg:grid-cols-12">
      <div className="lg:col-span-4">
        <div className="sticky top-24 rounded-[2.5rem] border border-white/5 bg-zinc-900/40 p-8 backdrop-blur-xl">
            <div className="mb-8 space-y-2">
                <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-gold/60">{helperCopy.progressLabel}</p>
                <div className="flex items-end gap-3">
                    <span className="font-heading text-6xl font-bold leading-none text-foreground">{String(step + 1).padStart(2, '0')}</span>
                    <span className="mb-2 text-xl font-medium text-stone-600">/ {String(totalSteps).padStart(2, '0')}</span>
                </div>
            </div>

            <div className="mb-10 h-1.5 w-full overflow-hidden rounded-full bg-white/5">
                <motion.div 
                    initial={{ width: 0 }}
                    animate={{ width: `${progress}%` }}
                    className="h-full bg-gold shadow-[0_0_15px_rgba(197,160,89,0.5)]"
                />
            </div>

            <div className="space-y-4">
                {steps.map((s, i) => (
                    <div key={s.id} className="flex items-center gap-4">
                        <div className={cn(
                            "flex h-8 w-8 items-center justify-center rounded-full border text-[10px] font-bold transition-all duration-500",
                            i < step ? "border-gold bg-gold text-black" : i === step ? "border-gold text-gold shadow-[0_0_10px_rgba(197,160,89,0.2)]" : "border-white/5 text-stone-600"
                        )}>
                            {i < step ? <Check size={14} strokeWidth={3} /> : s.id}
                        </div>
                        <span className={cn(
                            "text-[10px] font-bold uppercase tracking-widest transition-colors",
                            i === step ? "text-foreground" : "text-stone-500"
                        )}>
                            {t(s.titleKey)}
                        </span>
                    </div>
                ))}
            </div>
        </div>
      </div>

      <div className="lg:col-span-8">
        <div className="rounded-[3rem] border border-white/5 bg-zinc-900/20 p-8 backdrop-blur-xl md:p-12">
            <header className="mb-12">
                <div className="mb-4 inline-flex items-center gap-3 rounded-2xl border border-gold/20 bg-gold/5 px-4 py-2 text-gold">
                    <CurrentStepIcon size={18} />
                    <span className="text-[10px] font-bold uppercase tracking-widest">{t('step_label')} {currentStep.id}</span>
                </div>
                <h2 className="font-heading text-4xl uppercase tracking-widest text-foreground md:text-5xl">
                    {t(currentStep.titleKey)}
                </h2>
                <p className="mt-4 font-body text-base text-stone-400">
                    {t(currentStep.subtitleKey)}
                </p>
            </header>

            <AnimatePresence mode="wait">
                <motion.div
                    key={step}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    className="grid grid-cols-1 gap-4 sm:grid-cols-2"
                >
                    {currentStep.options.map((opt) => {
                        const Icon = opt.icon;
                        const isSelected = answers[currentStep.key] === opt.value;
                        return (
                            <button
                                key={opt.value}
                                onClick={() => handleSelect(opt.value)}
                                disabled={isSubmitting}
                                className={cn(
                                    "group relative flex flex-col justify-between overflow-hidden rounded-[2rem] border p-8 text-left transition-all duration-300",
                                    isSelected 
                                        ? "border-gold bg-gold/10 shadow-[0_0_40px_rgba(197,160,89,0.1)]" 
                                        : "border-white/5 bg-white/[0.02] hover:border-gold/30 hover:bg-white/[0.05]"
                                )}
                            >
                                <div className="mb-8 flex items-center justify-between">
                                    <div className={cn(
                                        "flex h-12 w-12 items-center justify-center rounded-2xl transition-all duration-500",
                                        isSelected ? "bg-gold text-black" : "bg-zinc-800 text-stone-400 group-hover:text-gold"
                                    )}>
                                        {Icon && <Icon size={24} />}
                                    </div>
                                    <div className={cn(
                                        "h-2 w-2 rounded-full transition-all",
                                        isSelected ? "bg-gold shadow-[0_0_10px_rgba(197,160,89,0.8)]" : "bg-white/5"
                                    )} />
                                </div>
                                
                                <div className="space-y-2">
                                    <h4 className="font-heading text-lg font-bold uppercase tracking-widest text-foreground">
                                        {opt.label}
                                    </h4>
                                    <p className="text-xs leading-relaxed text-stone-500">
                                        {opt.description || t(`steps.${currentStep.key}.options.${opt.value.toLowerCase()}_desc`, { defaultValue: '' })}
                                    </p>
                                </div>
                            </button>
                        );
                    })}
                </motion.div>
            </AnimatePresence>

            <div className="mt-12 flex items-center justify-between border-t border-white/5 pt-8">
                <p className="text-[10px] font-bold uppercase tracking-widest text-stone-600">
                    {isSubmitting ? helperCopy.submittingLabel : helperCopy.pickHint}
                </p>
                {step > 0 && (
                    <button
                        onClick={() => setStep(step - 1)}
                        disabled={isSubmitting}
                        className="flex h-12 items-center gap-3 rounded-full border border-white/10 px-6 text-[10px] font-bold uppercase tracking-widest text-stone-400 transition-all hover:bg-white/5 hover:text-foreground"
                    >
                        <ArrowLeft size={16} />
                        {t('prev_step')}
                    </button>
                )}
            </div>
        </div>
      </div>
    </div>
  );
}
