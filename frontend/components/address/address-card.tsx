'use client';

import { UserAddress } from '@/services/address.service';
import { cn } from '@/lib/utils';
import { MapPin, Phone, User, CheckCircle2, ShieldCheck, Zap } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { motion } from 'framer-motion';

interface AddressCardProps {
    address: UserAddress;
    selected?: boolean;
    onClick?: () => void;
    className?: string;
}

export function AddressCard({ address, selected, onClick, className }: AddressCardProps) {
    const t = useTranslations('address.card');

    return (
        <motion.div
            layout
            onClick={onClick}
            className={cn(
                'relative rounded-[2.5rem] border p-10 transition-all duration-500 cursor-pointer group backdrop-blur-3xl',
                selected
                    ? 'border-gold bg-gold/5 shadow-[0_20px_50px_-36px_rgba(197,160,89,0.3)]'
                    : 'border-white/5 bg-zinc-900/40 hover:border-gold/30',
                className
            )}
        >
            <div className="flex justify-between items-start mb-8">
                <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gold/10 text-gold">
                        <MapPin size={18} />
                    </div>
                    <div>
                        <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-700">{t('shipping')}</p>
                        <p className="font-heading text-lg font-bold text-foreground tracking-widest">ARCHIVE #{address.id.slice(-6).toUpperCase()}</p>
                    </div>
                </div>
                {selected && (
                    <div className="h-8 w-8 rounded-full bg-gold flex items-center justify-center text-black shadow-lg shadow-gold/20">
                        <CheckCircle2 size={16} />
                    </div>
                )}
            </div>

            <div className="space-y-8">
                <div className="grid gap-8 sm:grid-cols-2">
                    <div className="space-y-2">
                        <div className="flex items-center gap-2 text-[9px] font-bold uppercase tracking-widest text-stone-700">
                            <User size={12} className="text-gold/60" /> {t('recipient')}
                        </div>
                        <p className="font-heading text-base font-bold text-foreground uppercase tracking-widest">{address.recipientName}</p>
                    </div>
                    <div className="space-y-2">
                        <div className="flex items-center gap-2 text-[9px] font-bold uppercase tracking-widest text-stone-700">
                            <Phone size={12} className="text-gold/60" /> {t('phone')}
                        </div>
                        <p className="font-mono text-base font-bold text-foreground tracking-widest">{address.phone}</p>
                    </div>
                </div>

                <div className="pt-8 border-t border-white/5">
                    <p className="text-sm leading-relaxed text-stone-400 font-body italic">
                        {address.detailAddress}, {address.wardName}, {address.districtName}, {address.provinceName}
                    </p>
                </div>
            </div>

            {address.isDefault && (
                <div className="absolute bottom-6 right-6 flex items-center gap-2 rounded-full border border-emerald-500/20 bg-emerald-500/10 px-4 py-1.5 shadow-lg shadow-emerald-500/10">
                    <ShieldCheck size={12} className="text-emerald-500" />
                    <span className="text-[8px] font-black uppercase tracking-widest text-emerald-500">{t('default')}</span>
                </div>
            )}
        </motion.div>
    );
}
