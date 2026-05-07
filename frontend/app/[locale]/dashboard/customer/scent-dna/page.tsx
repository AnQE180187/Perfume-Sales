'use client';

import { useEffect, useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useTranslations } from 'next-intl';
import { 
  Sparkles, 
  Search, 
  Plus, 
  X, 
  Dna, 
  Trash2, 
  RotateCcw, 
  Save,
  CheckCircle2,
  AlertCircle
} from 'lucide-react';
import { useScentDNAStore } from '@/store/scent-dna.store';
import { catalogService } from '@/services/catalog.service';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';
import { ScentDNARadar } from '@/components/product/scent-dna-radar';
import { ScentDNASuggestions } from '@/components/product/scent-dna-suggestions';

export default function ScentDNAPage() {
  const t = useTranslations('dashboard.scent_dna');
  const { preferences, loading, fetchPreferences, updatePreferences, resetPreferences } = useScentDNAStore();
  const [allNotes, setAllNotes] = useState<string[]>([]);
  const [search, setSearch] = useState('');
  const [activeTab, setActiveTab] = useState<'preferred' | 'avoided'>('preferred');
  const [isFocused, setIsFocused] = useState(false);

  useEffect(() => {
    fetchPreferences();
    catalogService.getScentNotes().then(setAllNotes).catch(console.error);
  }, [fetchPreferences]);

  const filteredNotes = useMemo(() => {
    const available = allNotes.filter(
      note => !preferences?.preferredNotes.includes(note) && !preferences?.avoidedNotes.includes(note)
    );

    if (!search.trim()) return available;

    return available
      .filter(note => note.toLowerCase().includes(search.toLowerCase()))
      .slice(0, 50);
  }, [search, allNotes, preferences]);

  const handleAddNote = (note: string) => {
    if (!preferences) return;
    
    const nextPrefs = {
      preferredNotes: [...preferences.preferredNotes],
      avoidedNotes: [...preferences.avoidedNotes],
    };

    if (activeTab === 'preferred') {
      if (nextPrefs.preferredNotes.includes(note)) return;
      nextPrefs.preferredNotes.push(note);
    } else {
      if (nextPrefs.avoidedNotes.includes(note)) return;
      nextPrefs.avoidedNotes.push(note);
    }

    updatePreferences(nextPrefs);
    setSearch('');
    toast.success(t('add_success', { note, type: t(activeTab === 'preferred' ? 'search_preferred' : 'search_avoided') }));
  };

  const handleRemoveNote = (note: string, type: 'preferred' | 'avoided') => {
    if (!preferences) return;

    const nextPrefs = {
      preferredNotes: preferences.preferredNotes.filter(n => n !== note),
      avoidedNotes: preferences.avoidedNotes.filter(n => n !== note),
    };

    updatePreferences(nextPrefs);
    toast.info(t('remove_info', { note }));
  };

  const handleReset = async () => {
    if (confirm(t('reset_confirm'))) {
      await resetPreferences();
      toast.success(t('reset_success'));
    }
  };

  const handleRiskChange = (value: number) => {
    if (!preferences) return;
    updatePreferences({ riskLevel: value });
  };

  const riskLevel = preferences?.riskLevel ?? 0.3;
  const riskInfo = useMemo(() => {
    if (riskLevel < 0.35) return { text: t('ai_safe_suggestion'), color: 'text-emerald-500', bg: 'bg-emerald-500/10', border: 'border-emerald-500/20' };
    if (riskLevel < 0.7) return { text: t('ai_balanced_suggestion'), color: 'text-gold', bg: 'bg-gold/10', border: 'border-gold/20' };
    return { text: t('ai_daring_suggestion'), color: 'text-orange-500', bg: 'bg-orange-500/10', border: 'border-orange-500/20' };
  }, [riskLevel, t]);

  return (
    <div className="relative pb-12">
      <AnimatePresence>
        {loading && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] flex items-center justify-center bg-black/40 backdrop-blur-3xl"
          >
            <div className="text-center space-y-8">
              <div className="relative w-24 h-24 mx-auto">
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ repeat: Infinity, duration: 4, ease: 'linear' }}
                  className="absolute inset-0 border-t-2 border-gold rounded-full"
                />
                <motion.div
                  animate={{ rotate: -360 }}
                  transition={{ repeat: Infinity, duration: 2, ease: 'linear' }}
                  className="absolute inset-2 border-b-2 border-gold/30 rounded-full"
                />
                <div className="absolute inset-0 flex items-center justify-center">
                  <Dna className="text-gold animate-pulse" size={32} />
                </div>
              </div>
              <div className="space-y-2">
                <h2 className="text-xl font-heading gold-gradient uppercase tracking-[0.4em]">{t('analyzing') || 'Analyzing DNA'}</h2>
                <p className="text-[10px] text-stone-400 uppercase tracking-widest font-bold animate-pulse">Recalculating Scent Blueprint</p>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <div className="space-y-12">
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-8">
          <header>
            <div className="flex items-center gap-4 mb-4">
              <div className="h-[1px] w-12 bg-gold/50" />
              <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Aura Analytics</span>
            </div>
            <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
              Scent <span className="gold-gradient">DNA</span>
            </h1>
            <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest text-stone-500 max-w-xl">
              {t('description')}
            </p>
          </header>

          <button
            onClick={handleReset}
            disabled={loading}
            className="flex h-14 items-center gap-3 rounded-full bg-stone-100 dark:bg-white/5 border border-black/5 dark:border-white/10 px-8 text-[10px] font-bold uppercase tracking-widest text-foreground hover:bg-gold hover:text-black transition-all cursor-pointer shadow-lg"
          >
            <RotateCcw size={16} className={cn(loading && "animate-spin")} />
            {t('reset_profile')}
          </button>
        </div>

        <div className="grid gap-12 lg:grid-cols-[1fr_400px]">
          <div className="space-y-10">
            {/* Tabs */}
            <div className="flex p-1.5 rounded-2xl bg-stone-100 dark:bg-white/5 border border-black/5 dark:border-white/5 max-w-md shadow-inner">
              <button
                onClick={() => setActiveTab('preferred')}
                className={cn(
                  "flex-1 flex items-center justify-center gap-3 py-3.5 rounded-xl text-[10px] font-bold uppercase tracking-widest transition-all cursor-pointer",
                  activeTab === 'preferred' ? "glass bg-white dark:bg-zinc-800 shadow-xl text-gold" : "text-stone-400 dark:text-stone-700 hover:text-foreground"
                )}
              >
                <Sparkles size={16} />
                {t('preferred_tab')}
              </button>
              <button
                onClick={() => setActiveTab('avoided')}
                className={cn(
                  "flex-1 flex items-center justify-center gap-3 py-3.5 rounded-xl text-[10px] font-bold uppercase tracking-widest transition-all cursor-pointer",
                  activeTab === 'avoided' ? "glass bg-white dark:bg-zinc-800 shadow-xl text-red-500" : "text-stone-400 dark:text-stone-700 hover:text-foreground"
                )}
              >
                <AlertCircle size={16} />
                {t('avoided_tab')}
              </button>
            </div>

            {/* Search Area */}
            <div className="relative">
              <div className="relative group">
                <Search className="absolute left-8 top-1/2 -translate-y-1/2 text-stone-400 dark:text-stone-700 group-focus-within:text-gold transition-colors" size={20} />
                <input
                  type="text"
                  placeholder={t('search_placeholder', { type: t(activeTab === 'preferred' ? 'search_preferred' : 'search_avoided') })}
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  onFocus={() => setIsFocused(true)}
                  onBlur={() => setTimeout(() => setIsFocused(false), 200)}
                  className="w-full h-20 pl-20 pr-10 rounded-[2.5rem] border border-black/5 dark:border-white/5 bg-stone-100 dark:bg-zinc-900/40 text-[10px] font-bold uppercase tracking-widest outline-none focus:border-gold/50 focus:bg-white dark:focus:bg-zinc-800/60 transition-all shadow-2xl"
                />
              </div>

              <AnimatePresence>
                {(isFocused || search.trim()) && filteredNotes.length > 0 && (
                  <motion.div
                    initial={{ opacity: 0, y: 10, filter: 'blur(10px)' }}
                    animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
                    exit={{ opacity: 0, y: 10, filter: 'blur(10px)' }}
                    className="absolute left-0 right-0 top-full mt-4 p-4 rounded-[2.5rem] glass dark:bg-zinc-900/95 border-black/5 dark:border-white/10 shadow-[0_30px_60px_-15px_rgba(0,0,0,0.3)] z-50 overflow-hidden"
                  >
                    <div className="max-h-72 overflow-y-auto custom-scrollbar">
                      {filteredNotes.map(note => (
                        <button
                          key={note}
                          onClick={() => handleAddNote(note)}
                          className="w-full flex items-center justify-between px-8 py-5 rounded-2xl hover:bg-gold/10 transition-all text-left group cursor-pointer"
                        >
                          <span className="text-[10px] font-bold uppercase tracking-widest text-foreground group-hover:text-gold">{note}</span>
                          <div className={cn(
                            "flex h-8 w-8 items-center justify-center rounded-xl transition-all opacity-0 group-hover:opacity-100 shadow-lg",
                            activeTab === 'preferred' ? "bg-gold text-black" : "bg-red-500 text-white"
                          )}>
                            <Plus size={16} />
                          </div>
                        </button>
                      ))}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>

            {/* Active List */}
            <div className="space-y-6">
               <div className="flex items-center justify-between px-2">
                  <h3 className="text-[10px] font-bold uppercase tracking-[0.3em] flex items-center gap-3">
                    <div className={cn("h-1.5 w-1.5 rounded-full animate-pulse", activeTab === 'preferred' ? "bg-gold shadow-[0_0_10px_rgba(197,160,89,0.5)]" : "bg-red-500 shadow-[0_0_10px_rgba(239,68,68,0.5)]")} />
                    {t('your_list_title', { type: t(activeTab === 'preferred' ? 'preferred_label' : 'avoided_label') })}
                  </h3>
                  <span className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">
                    {t('notes_count', { count: (activeTab === 'preferred' ? preferences?.preferredNotes.length : preferences?.avoidedNotes.length) || 0 })}
                  </span>
               </div>

               <div className="flex flex-wrap gap-4 min-h-[120px] p-8 rounded-[2.5rem] bg-stone-100/50 dark:bg-white/5 border border-dashed border-black/5 dark:border-white/5 transition-all">
                  {activeTab === 'preferred' ? (
                    preferences?.preferredNotes.map(note => (
                      <motion.div
                        layout
                        key={note}
                        initial={{ scale: 0.8, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className="group flex items-center gap-3 pl-5 pr-3 py-2.5 rounded-xl glass border-gold/20 text-gold font-bold text-[10px] uppercase tracking-widest shadow-lg hover:border-gold/50 transition-all"
                      >
                        {note}
                        <button 
                          onClick={() => handleRemoveNote(note, 'preferred')}
                          className="h-6 w-6 flex items-center justify-center rounded-lg hover:bg-gold/10 transition-all text-gold/40 hover:text-gold cursor-pointer"
                        >
                          <X size={14} />
                        </button>
                      </motion.div>
                    ))
                  ) : (
                    preferences?.avoidedNotes.map(note => (
                      <motion.div
                        layout
                        key={note}
                        initial={{ scale: 0.8, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className="group flex items-center gap-3 pl-5 pr-3 py-2.5 rounded-xl glass border-red-500/20 text-red-500 font-bold text-[10px] uppercase tracking-widest shadow-lg hover:border-red-500/50 transition-all"
                      >
                        {note}
                        <button 
                          onClick={() => handleRemoveNote(note, 'avoided')}
                          className="h-6 w-6 flex items-center justify-center rounded-lg hover:bg-red-500/10 transition-all text-red-500/40 hover:text-red-500 cursor-pointer"
                        >
                          <X size={14} />
                        </button>
                      </motion.div>
                    ))
                  )}
                  
                  {((activeTab === 'preferred' && preferences?.preferredNotes.length === 0) || 
                    (activeTab === 'avoided' && preferences?.avoidedNotes.length === 0)) && (
                    <div className="w-full flex flex-col items-center justify-center text-stone-300 dark:text-stone-800 space-y-4">
                      <Dna size={48} className="opacity-40 animate-pulse" />
                      <div className="text-center">
                        <p className="text-[10px] font-bold uppercase tracking-widest">{t('no_notes', { type: t(activeTab === 'preferred' ? 'search_preferred' : 'search_avoided') })}</p>
                        <p className="text-[8px] font-bold uppercase tracking-widest mt-2 opacity-50">{t('start_typing')}</p>
                      </div>
                    </div>
                  )}
               </div>
            </div>

            <div className="pt-10 border-t border-black/5 dark:border-white/5">
               <ScentDNASuggestions />
            </div>
          </div>

          {/* Sidebar Info */}
          <div className="space-y-8">
            <div className="p-10 rounded-[3rem] glass shadow-2xl overflow-hidden relative group">
              <div className="absolute inset-0 bg-gradient-to-br from-gold/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
              
              <h4 className="text-[8px] font-bold uppercase tracking-[0.4em] flex items-center gap-3 mb-10 text-stone-400 dark:text-stone-700 relative">
                <div className="h-1.5 w-1.5 rounded-full bg-gold" />
                {t('suggestion_mode')}
              </h4>
              
              <AnimatePresence mode="wait">
                <motion.div 
                  key={riskInfo.text}
                  initial={{ opacity: 0, scale: 0.95, filter: 'blur(10px)' }}
                  animate={{ opacity: 1, scale: 1, filter: 'blur(0px)' }}
                  exit={{ opacity: 0, scale: 1.05, filter: 'blur(10px)' }}
                  className={cn(
                    "p-8 rounded-[2rem] glass shadow-2xl backdrop-blur-3xl relative transition-all duration-700 min-h-[140px] flex items-center justify-center text-center",
                    riskInfo.bg, riskInfo.color, riskInfo.border
                  )}
                >
                  <p className="text-[11px] font-bold leading-relaxed tracking-widest uppercase italic">
                    {riskInfo.text}
                  </p>
                  <div className={cn("absolute -top-3 -right-3 h-8 w-8 rounded-full flex items-center justify-center glass border animate-pulse shadow-lg", riskInfo.bg, riskInfo.border)}>
                     <Sparkles size={14} />
                  </div>
                </motion.div>
              </AnimatePresence>

              <div className="mt-12 space-y-8 relative">
                <div className="relative h-12 flex items-center group/slider">
                  {/* Custom Slider Track */}
                  <div className="absolute inset-0 h-2.5 my-auto rounded-full bg-black/5 dark:bg-white/5 overflow-hidden shadow-inner">
                    <motion.div 
                      initial={false}
                      animate={{ width: `${riskLevel * 100}%` }}
                      className={cn("h-full transition-colors duration-700", 
                        riskLevel < 0.35 ? "bg-emerald-500 shadow-[0_0_20px_rgba(16,185,129,0.5)]" : 
                        riskLevel < 0.7 ? "bg-gold shadow-[0_0_20px_rgba(197,160,89,0.5)]" : 
                        "bg-orange-500 shadow-[0_0_20px_rgba(249,115,22,0.5)]"
                      )}
                    />
                  </div>
                  
                  {/* Transparent Actual Input */}
                  <input 
                    type="range"
                    min="0"
                    max="1"
                    step="0.01"
                    value={riskLevel}
                    onChange={(e) => handleRiskChange(parseFloat(e.target.value))}
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-20"
                  />

                  {/* Animated Thumb */}
                  <motion.div 
                    initial={false}
                    animate={{ left: `${riskLevel * 100}%` }}
                    className="absolute top-1/2 -translate-y-1/2 -translate-x-1/2 h-8 w-8 rounded-full bg-white dark:bg-zinc-800 border-2 border-gold shadow-[0_0_25px_rgba(197,160,89,0.6)] pointer-events-none z-10 flex items-center justify-center transition-transform group-hover/slider:scale-125"
                  >
                    <div className="h-2 w-2 rounded-full bg-gold animate-ping" />
                  </motion.div>
                </div>

                <div className="flex justify-between items-center px-2">
                  <div className="flex flex-col">
                    <span className="text-[8px] font-bold uppercase tracking-[0.2em] text-stone-400 dark:text-stone-700">{t('classic')}</span>
                    <span className="text-[9px] font-bold mt-1 uppercase tracking-widest">Minimal</span>
                  </div>
                  <div className="flex flex-col items-end">
                    <span className={cn("text-[8px] font-bold uppercase tracking-[0.2em] transition-colors", riskLevel > 0.7 ? "text-orange-500" : "text-stone-400 dark:text-stone-700")}>{t('daring')}</span>
                    <span className="text-[9px] font-bold mt-1 uppercase tracking-widest">Experimental</span>
                  </div>
                </div>
              </div>
            </div>

            {preferences && preferences.preferredNotes.length > 0 && (
              <div className="p-10 rounded-[3rem] glass shadow-2xl space-y-6">
                <h4 className="text-[10px] font-bold uppercase tracking-widest">{t('scent_profile_chart')}</h4>
                <div className="aspect-square relative overflow-hidden rounded-[2rem] glass bg-white/5 border-black/5 dark:border-white/5">
                  <ScentDNARadar />
                </div>
              </div>
            )}

            <div className="p-10 rounded-[3rem] bg-gold text-black shadow-2xl relative overflow-hidden group">
              <div className="absolute top-0 right-0 p-8 opacity-10 group-hover:scale-110 transition-transform duration-700">
                <Dna size={120} />
              </div>
              <h3 className="text-3xl font-heading font-black leading-tight uppercase tracking-tighter">{t('how_it_works')}</h3>
              <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest leading-relaxed opacity-70">
                {t('how_it_works_desc')}
              </p>
              
              <ul className="mt-12 space-y-8">
                <li className="flex gap-6 group/item">
                  <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-black/10 group-hover/item:bg-black/20 transition-all shadow-lg">
                    <CheckCircle2 size={20} className="opacity-60" />
                  </div>
                  <div className="space-y-1">
                    <p className="font-bold uppercase tracking-widest text-[11px]">{t('base_match')}</p>
                    <p className="text-[9px] font-bold opacity-50 uppercase tracking-widest leading-relaxed">{t('base_match_desc')}</p>
                  </div>
                </li>
                <li className="flex gap-6 group/item">
                  <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-black/10 group-hover/item:bg-black/20 transition-all shadow-lg">
                    <Plus size={20} className="opacity-60" />
                  </div>
                  <div className="space-y-1">
                    <p className="font-bold uppercase tracking-widest text-[11px]">{t('bonus_score')}</p>
                    <p className="text-[9px] font-bold opacity-50 uppercase tracking-widest leading-relaxed">{t('bonus_score_desc')}</p>
                  </div>
                </li>
                <li className="flex gap-6 group/item">
                  <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-black/10 group-hover/item:bg-black/20 transition-all shadow-lg">
                    <AlertCircle size={20} className="opacity-60" />
                  </div>
                  <div className="space-y-1">
                    <p className="font-bold uppercase tracking-widest text-[11px]">{t('penalty_system')}</p>
                    <p className="text-[9px] font-bold opacity-50 uppercase tracking-widest leading-relaxed">{t('penalty_system_desc')}</p>
                  </div>
                </li>
              </ul>
            </div>

            <div className="p-10 rounded-[3rem] glass border-black/5 dark:border-white/5 shadow-xl">
               <div className="flex items-center gap-3 mb-4">
                  <Sparkles size={16} className="text-gold" />
                  <h4 className="text-[10px] font-bold uppercase tracking-widest">{t('pro_tip')}</h4>
               </div>
               <p className="font-body text-[10px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 leading-relaxed">
                 {t('pro_tip_desc')}
               </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
