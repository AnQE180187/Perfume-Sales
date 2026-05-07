'use client';

import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useTranslations, useFormatter } from 'next-intl';
import { 
  Clock, 
  ArrowRight, 
  ChevronRight, 
  Sparkles, 
  Target, 
  Briefcase, 
  User, 
  Zap, 
  Palette,
  LayoutGrid,
  History,
  ShieldCheck,
  ChevronLeft,
  Search
} from 'lucide-react';
import { quizService } from '@/services/quiz.service';
import { cn } from '@/lib/utils';

interface QuizHistoryProps {
  onViewResult: (recommendations: any[], analysis?: string) => void;
  onBack: () => void;
}

export function QuizHistory({ onViewResult, onBack }: QuizHistoryProps) {
  const t = useTranslations('quiz');
  const format = useFormatter();
  const [history, setHistory] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    quizService.getHistory()
      .then(setHistory)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const getTranslatedValue = (step: string, value: string) => {
    try {
      return t(`steps.${step}.options.${value.toLowerCase()}`);
    } catch {
      return value;
    }
  };

  const parseRecommendations = (item: any) => {
    const rawRecs = item.recommendation || item.recommendations || [];
    let recs = typeof rawRecs === 'string' ? JSON.parse(rawRecs) : rawRecs;
    if (recs && !Array.isArray(recs) && Array.isArray(recs.recommendations)) {
      recs = recs.recommendations;
    }
    return Array.isArray(recs) ? recs : [];
  };

  return (
    <div className="space-y-12 pb-12">
      <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
        {loading ? (
          Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="h-64 animate-pulse rounded-[2.5rem] bg-white/5" />
          ))
        ) : history.length === 0 ? (
          <div className="col-span-full py-32 text-center">
            <div className="mx-auto mb-8 flex h-24 w-24 items-center justify-center rounded-[2rem] bg-white/5 text-stone-700">
                <Search size={40} />
            </div>
            <h3 className="font-heading text-2xl uppercase tracking-widest text-foreground">Vault Empty</h3>
            <p className="mt-4 text-stone-500">You haven't initiated any rituals yet.</p>
          </div>
        ) : (
          history.map((item, index) => {
            const recs = parseRecommendations(item);
            const date = new Date(item.createdAt);
            return (
              <motion.article
                key={item.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                whileHover={{ y: -8 }}
                onClick={() => onViewResult(recs, item.analysis)}
                className="group relative overflow-hidden rounded-[2.5rem] border border-white/5 bg-zinc-900/40 p-8 transition-all duration-500 hover:border-gold/30"
              >
                <div className="mb-8 flex items-center justify-between">
                    <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-white/5 text-gold group-hover:bg-gold group-hover:text-black transition-all duration-500">
                        <History size={24} />
                    </div>
                    <div className="text-right">
                        <p className="text-[10px] font-bold uppercase tracking-widest text-stone-500">Ritual ID</p>
                        <p className="font-heading text-lg text-foreground">#{String(history.length - index).padStart(3, '0')}</p>
                    </div>
                </div>

                <div className="space-y-4 border-b border-white/5 pb-8">
                    <div className="flex items-center justify-between">
                        <span className="text-[10px] font-bold uppercase tracking-widest text-stone-600">Date</span>
                        <span className="text-xs font-medium text-stone-300">{format.dateTime(date, { day: 'numeric', month: 'long', year: 'numeric' })}</span>
                    </div>
                    <div className="flex items-center justify-between">
                        <span className="text-[10px] font-bold uppercase tracking-widest text-stone-600">Profile</span>
                        <span className="text-xs font-medium text-stone-300">{getTranslatedValue('gender', item.gender)}</span>
                    </div>
                    <div className="flex items-center justify-between">
                        <span className="text-[10px] font-bold uppercase tracking-widest text-stone-600">Resonances</span>
                        <span className="text-xs font-medium text-gold">{recs.length} Found</span>
                    </div>
                </div>

                <div className="mt-8 flex items-center justify-between">
                    <div className="flex -space-x-3">
                        {recs.slice(0, 4).map((rec: any, i: number) => (
                            <div key={i} className="h-10 w-10 overflow-hidden rounded-full border-2 border-zinc-900 bg-zinc-800">
                                {rec.imageUrl ? <img src={rec.imageUrl} alt="" className="h-full w-full object-cover" /> : <div className="h-full w-full bg-gold/20" />}
                            </div>
                        ))}
                    </div>
                    <div className="flex h-10 w-10 items-center justify-center rounded-full border border-white/10 bg-white/5 text-stone-400 group-hover:bg-gold group-hover:text-black group-hover:border-gold group-hover:shadow-[0_0_20px_rgba(197,160,89,0.3)] transition-all">
                        <ChevronRight size={18} />
                    </div>
                </div>

                <div className="absolute inset-0 -z-10 bg-gradient-to-br from-gold/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
              </motion.article>
            );
          })
        )}
      </div>
    </div>
  );
}
