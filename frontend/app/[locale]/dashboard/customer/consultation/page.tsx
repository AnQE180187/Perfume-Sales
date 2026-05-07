'use client';

import { useState } from 'react';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { useTranslations } from 'next-intl';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, ArrowRight, ArrowLeft, Droplet, Wind, Coffee, Zap, Moon, Sun, LucideIcon, Dna, RotateCcw, ShieldCheck, Zap as ZapIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

interface ConsultationOption {
    label: string;
    value: string;
    icon?: LucideIcon;
}

interface StepData {
    id: number;
    title: string;
    key: string;
    options: ConsultationOption[];
}

export default function ConsultationPage() {
    const t = useTranslations('consultation_page');
    const [step, setStep] = useState(1);
    const [answers, setAnswers] = useState<Record<string, string>>({});
    const [isAnalyzing, setIsAnalyzing] = useState(false);

    const totalSteps = 4;

    const handleNext = (key: string, value: string) => {
        const newAnswers = { ...answers, [key]: value };
        setAnswers(newAnswers);

        if (step < 3) {
            setStep(step + 1);
        } else if (step === 3) {
            setIsAnalyzing(true);
            setStep(4);
            setTimeout(() => {
                setIsAnalyzing(false);
            }, 4000);
        }
    };

    const currentStepData: StepData[] = [
        {
            id: 1,
            title: t('steps.intensity.title'),
            key: 'intensity',
            options: [
                { label: t('steps.intensity.options.subtle'), icon: Wind, value: 'subtle' },
                { label: t('steps.intensity.options.balanced'), icon: Droplet, value: 'balanced' },
                { label: t('steps.intensity.options.intense'), icon: Zap, value: 'intense' }
            ]
        },
        {
            id: 2,
            title: t('steps.environment.title'),
            key: 'environment',
            options: [
                { label: t('steps.environment.options.outdoor'), icon: Sun, value: 'outdoor' },
                { label: t('steps.environment.options.urban'), icon: Coffee, value: 'urban' },
                { label: t('steps.environment.options.midnight'), icon: Moon, value: 'midnight' }
            ]
        },
        {
            id: 3,
            title: t('steps.emotion.title'),
            key: 'emotion',
            options: [
                { label: t('steps.emotion.options.sophisticated'), value: 'sophisticated' },
                { label: t('steps.emotion.options.playful'), value: 'playful' },
                { label: t('steps.emotion.options.mysterious'), value: 'mysterious' },
                { label: t('steps.emotion.options.vitality'), value: 'vitality' }
            ]
        },
        {
            id: 4,
            title: t('analysis.dna_blueprint'),
            key: 'result',
            options: []
        }
    ];

    return (
        <div className="relative pb-12">
            <main className="container mx-auto px-6 space-y-16">
                {/* Progress Matrix */}
                <div className="flex items-center justify-center gap-6">
                    {[1, 2, 3, 4].map((s) => (
                        <div key={s} className="flex items-center gap-6">
                            <motion.div
                                animate={{ 
                                    scale: step >= s ? 1.2 : 1,
                                    opacity: step >= s ? 1 : 0.2
                                }}
                                className={cn(
                                    "h-2.5 w-2.5 rounded-full transition-all duration-700 shadow-lg",
                                    step >= s ? "bg-gold shadow-gold/50" : "bg-foreground"
                                )}
                            />
                            {s < 4 && (
                                <div className={cn(
                                    "h-[1px] w-12 transition-all duration-700",
                                    step > s ? "bg-gold shadow-[0_0_10px_rgba(197,160,89,0.5)]" : "bg-foreground/10"
                                )} />
                            )}
                        </div>
                    ))}
                </div>

                <AnimatePresence mode="wait">
                    <motion.div
                        key={step}
                        initial={{ opacity: 0, y: 30, filter: 'blur(10px)' }}
                        animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
                        exit={{ opacity: 0, y: -30, filter: 'blur(10px)' }}
                        transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
                        className="text-center"
                    >
                        {step < 4 ? (
                            <div className="space-y-16">
                                <header className="space-y-6">
                                    <div className="flex items-center justify-center gap-4">
                                        <div className="h-[1px] w-12 bg-gold/50" />
                                        <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">
                                            {t('section_prefix')} 0{step}
                                        </span>
                                    </div>
                                    <h2 className="font-heading text-4xl md:text-7xl font-bold text-foreground uppercase tracking-tighter leading-tight italic">
                                        {currentStepData[step - 1].title}
                                    </h2>
                                </header>

                                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto">
                                    {currentStepData[step - 1].options.map((opt, i) => {
                                        const Icon = opt.icon;
                                        return (
                                            <motion.button
                                                key={i}
                                                whileHover={{ scale: 1.05, y: -10 }}
                                                whileTap={{ scale: 0.95 }}
                                                onClick={() => handleNext(currentStepData[step - 1].key, opt.value)}
                                                className="group relative h-72 rounded-[3.5rem] glass p-10 shadow-2xl transition-all duration-700 hover:border-gold/30 flex flex-col items-center justify-center gap-10 cursor-pointer"
                                            >
                                                <div className="absolute inset-0 bg-gradient-to-br from-gold/10 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
                                                
                                                {Icon ? (
                                                    <div className="flex h-24 w-24 items-center justify-center rounded-3xl glass border border-black/5 dark:border-white/5 text-stone-300 dark:text-stone-700 transition-all duration-700 group-hover:bg-gold group-hover:text-black group-hover:rotate-6 group-hover:shadow-[0_0_50px_rgba(197,160,89,0.4)]">
                                                        <Icon size={40} strokeWidth={1} />
                                                    </div>
                                                ) : (
                                                    <div className="flex h-24 w-24 items-center justify-center rounded-full glass border-gold/20 text-gold opacity-40 group-hover:opacity-100 transition-all duration-700 group-hover:scale-125">
                                                        <Sparkles size={32} />
                                                    </div>
                                                )}
                                                <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700 transition-colors group-hover:text-gold">
                                                    {opt.label}
                                                </span>
                                            </motion.button>
                                        );
                                    })}
                                </div>

                                {step > 1 && (
                                    <button
                                        onClick={() => setStep(step - 1)}
                                        className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700 hover:text-gold transition-all flex items-center justify-center gap-4 mx-auto py-4 cursor-pointer"
                                    >
                                        <ArrowLeft size={16} /> {t('prev_step')}
                                    </button>
                                )}
                            </div>
                        ) : (
                            <div className="max-w-5xl mx-auto">
                                {isAnalyzing ? (
                                    <div className="space-y-16 py-12">
                                        <div className="relative h-56 w-56 mx-auto">
                                            <motion.div
                                                animate={{ rotate: 360 }}
                                                transition={{ repeat: Infinity, duration: 4, ease: 'linear' }}
                                                className="absolute inset-0 border-[4px] border-gold/10 border-t-gold rounded-full"
                                            />
                                            <motion.div
                                                animate={{ rotate: -360 }}
                                                transition={{ repeat: Infinity, duration: 3, ease: 'linear' }}
                                                className="absolute inset-6 border-[2px] border-black/5 dark:border-white/5 border-b-gold/40 rounded-full"
                                            />
                                            <div className="absolute inset-0 flex items-center justify-center">
                                                <Dna className="text-gold animate-pulse" size={80} />
                                            </div>
                                        </div>
                                        
                                        <div className="max-w-md mx-auto space-y-10">
                                            <div className="glass rounded-[3rem] p-10 space-y-5 text-left font-mono text-[10px] text-stone-400 dark:text-stone-700 uppercase tracking-widest shadow-2xl">
                                                <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.5 }}>{'>'} {t('analysis.initializing')}</motion.p>
                                                <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 1.2 }}>{'>'} {t('analysis.loading')}</motion.p>
                                                <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 2.0 }}>{'>'} {t('analysis.cross_referencing', { intensity: answers.intensity })}</motion.p>
                                                <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 2.8 }}>{'>'} {t('analysis.finalizing')}</motion.p>
                                                
                                                <div className="h-[3px] w-full bg-black/5 dark:bg-white/5 mt-10 overflow-hidden rounded-full">
                                                    <motion.div
                                                        initial={{ width: 0 }}
                                                        animate={{ width: '100%' }}
                                                        transition={{ duration: 3.5, ease: 'easeInOut' }}
                                                        className="h-full bg-gold shadow-[0_0_30px_rgba(197,160,89,1)]"
                                                    />
                                                </div>
                                            </div>
                                            <p className="text-[10px] font-bold uppercase tracking-[0.5em] text-gold animate-pulse">{t('analysis.calculating')}</p>
                                        </div>
                                    </div>
                                ) : (
                                    <motion.div
                                        initial={{ opacity: 0, scale: 0.95 }}
                                        animate={{ opacity: 1, scale: 1 }}
                                        className="space-y-16"
                                    >
                                        <div className="relative aspect-video w-full rounded-[4rem] overflow-hidden glass border-black/5 dark:border-white/5 shadow-2xl group">
                                            <Image
                                                src="/luxury_ai_scent_lab.png"
                                                alt="AI Analysis"
                                                fill
                                                className="object-cover transition-transform duration-[2000ms] group-hover:scale-110"
                                            />
                                            <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent p-16 flex flex-col justify-end text-left space-y-8">
                                                <div className="flex items-center gap-6">
                                                    <div className="h-16 w-16 rounded-2xl bg-gold flex items-center justify-center text-black shadow-xl shadow-gold/30">
                                                        <Sparkles size={32} />
                                                    </div>
                                                    <h3 className="font-heading text-4xl font-bold text-white uppercase tracking-widest leading-none">{t('analysis.complete')}</h3>
                                                </div>
                                                <p className="text-stone-300 text-lg max-w-xl leading-relaxed font-body">
                                                    {t('analysis.description')}
                                                </p>
                                            </div>
                                        </div>

                                        <div className="space-y-12">
                                            <div className="space-y-6">
                                                <h2 className="font-heading text-4xl md:text-8xl font-bold text-foreground uppercase tracking-tighter italic leading-none">
                                                    {t.rich('analysis.dna_blueprint', {
                                                        italic: (chunks: React.ReactNode) => <span className="gold-gradient block mt-4">{chunks}</span>
                                                    })}
                                                </h2>
                                                <div className="flex flex-wrap justify-center gap-6">
                                                    {Object.entries(answers).map(([key, val]) => (
                                                        <div key={key} className="px-8 py-3 rounded-full glass border-black/5 dark:border-white/5 text-[10px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 shadow-lg">
                                                            {key}: <span className="text-gold">{val}</span>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>

                                            <div className="flex flex-col sm:flex-row gap-8 justify-center items-center pt-8">
                                                <Link
                                                    href="/dashboard/customer/scent-dna"
                                                    className="w-full sm:w-auto h-20 px-20 rounded-full bg-gold text-[10px] font-black uppercase tracking-[0.5em] text-black shadow-2xl shadow-gold/30 transition-all hover:scale-[1.05] flex items-center justify-center gap-6"
                                                >
                                                    {t('analysis.view_profile')}
                                                    <ArrowRight size={20} />
                                                </Link>
                                                <button
                                                    onClick={() => {
                                                        setStep(1);
                                                        setAnswers({});
                                                    }}
                                                    className="text-[10px] font-black uppercase tracking-[0.5em] text-stone-400 dark:text-stone-700 hover:text-gold transition-all flex items-center gap-4 py-4 cursor-pointer"
                                                >
                                                    <RotateCcw size={18} /> {t('prev_step')}
                                                </button>
                                            </div>
                                        </div>
                                    </motion.div>
                                )}
                            </div>
                        )}
                    </motion.div>
                </AnimatePresence>
            </main>
        </div>
    );
}
