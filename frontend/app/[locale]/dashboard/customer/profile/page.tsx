'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { userService } from '@/services/user.service';
import { authService } from '@/services/auth.service';
import { useAuthStore } from '@/store/auth.store';
import { AddressManager } from '@/components/address/address-manager';
import { User, Mail, Shield, Edit2, Loader2, CheckCircle, Send, Phone, Calendar, Target, Zap, ShieldCheck } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useTranslations, useLocale, useFormatter } from 'next-intl';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

type ProfileData = {
    id: string;
    email: string;
    phone?: string | null;
    role: string;
    fullName?: string | null;
    gender?: string | null;
    dateOfBirth?: string | null;
    avatarUrl?: string | null;
    budgetMin?: number | null;
    budgetMax?: number | null;
    createdAt?: string;
    emailVerified?: boolean;
};

export default function ProfilePage() {
    const t = useTranslations('dashboard.profile');
    const tFeatured = useTranslations('featured');
    const locale = useLocale();
    const format = useFormatter();
    const { user: authUser, token, setAuth } = useAuthStore();
    const [data, setData] = useState<ProfileData | null>(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [editing, setEditing] = useState(false);
    const [sendingVerify, setSendingVerify] = useState(false);
    const [verifyMsg, setVerifyMsg] = useState<string | null>(null);
    const [form, setForm] = useState({
        fullName: '',
        phone: '',
        gender: '',
        dateOfBirth: '',
        budgetMin: '' as string | number,
        budgetMax: '' as string | number,
    });

    const loadProfile = async () => {
        setLoading(true);
        setError(null);
        try {
            const me = await userService.getMe();
            setData(me);
            setForm({
                fullName: me.fullName ?? '',
                phone: me.phone ?? '',
                gender: me.gender ?? '',
                dateOfBirth: me.dateOfBirth ? me.dateOfBirth.slice(0, 10) : '',
                budgetMin: me.budgetMin ?? '',
                budgetMax: me.budgetMax ?? '',
            });
        } catch (e) {
            setError((e as Error).message);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { loadProfile(); }, []);

    const handleResendVerification = async () => {
        setSendingVerify(true);
        setVerifyMsg(null);
        try {
            await authService.resendVerificationEmail();
            setVerifyMsg(t('verification.sent'));
        } catch (e) {
            setVerifyMsg((e as Error).message);
        } finally {
            setSendingVerify(false);
        }
    };

    const handleSave = async () => {
        setSaving(true);
        setError(null);
        try {
            const updated = await userService.updateProfile({
                fullName: form.fullName || undefined,
                phone: form.phone || undefined,
                gender: form.gender || undefined,
                dateOfBirth: form.dateOfBirth || undefined,
                budgetMin: typeof form.budgetMin === 'number' ? form.budgetMin : form.budgetMin ? Number(form.budgetMin) : undefined,
                budgetMax: typeof form.budgetMax === 'number' ? form.budgetMax : form.budgetMax ? Number(form.budgetMax) : undefined,
            });
            setData(updated);
            setEditing(false);
            if (token && authUser && (updated.fullName !== authUser.name || updated.email !== authUser.email)) {
                setAuth({ ...authUser, name: updated.fullName || updated.email, email: updated.email }, token);
            }
        } catch (e) {
            setError((e as Error).message);
        } finally { setSaving(false); }
    };

    const formatCurrency = (amount: number) => {
        return format.number(amount, {
          style: 'currency',
          currency: tFeatured('currency_code') || 'VND',
          maximumFractionDigits: 0
        });
    };

    if (loading) {
        return (
            <div className="flex h-[400px] items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-gold" />
            </div>
        );
    }

    return (
        <div className="space-y-12 pb-12">
            <header>
                <div className="flex items-center gap-4 mb-4">
                    <div className="h-[1px] w-12 bg-gold/50" />
                    <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry</span>
                </div>
                <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
                    Persona <span className="gold-gradient">Matrix</span>
                </h1>
                <p className="mt-4 font-body text-base text-stone-500 max-w-2xl">{t('subtitle')}</p>
            </header>

            {error && (
                <div className="rounded-2xl border border-red-500/20 bg-red-500/5 p-4 text-xs font-bold uppercase tracking-widest text-red-600 dark:text-red-500">
                    {error}
                </div>
            )}

            <div className="grid grid-cols-1 gap-12 lg:grid-cols-12">
                {/* Left Sidebar */}
                <div className="lg:col-span-4 space-y-8">
                    <motion.div 
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="glass relative overflow-hidden rounded-[3rem] p-12 text-center"
                    >
                        <div className="absolute -right-12 -top-12 h-48 w-48 rounded-full bg-gold/5 blur-[60px]" />
                        <div className="relative mx-auto mb-8 h-32 w-32 overflow-hidden rounded-[2.5rem] border-2 border-black/10 dark:border-white/10 bg-stone-100 dark:bg-zinc-800 p-1 shadow-2xl">
                            {data?.avatarUrl ? (
                                <img src={data.avatarUrl} alt="" className="h-full w-full rounded-[2.2rem] object-cover" />
                            ) : (
                                <div className="flex h-full w-full items-center justify-center rounded-[2.2rem] bg-stone-50 dark:bg-zinc-900 text-stone-400 dark:text-stone-600 font-heading text-4xl font-bold">
                                    {data?.fullName ? data.fullName.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2) : data?.email?.[0].toUpperCase()}
                                </div>
                            )}
                        </div>
                        <h2 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground">
                            {data?.fullName || data?.email || t('user_placeholder')}
                        </h2>
                        <p className="mt-2 text-[10px] font-bold uppercase tracking-[0.4em] text-gold/80">
                            {data?.role ? t(`roles.${data.role.toLowerCase()}`) : t('roles.customer')}
                        </p>
                    </motion.div>

                    <div className="rounded-[2.5rem] border border-black/5 dark:border-white/5 bg-stone-100/30 dark:bg-zinc-900/20 p-10 backdrop-blur-xl">
                        <h3 className="mb-8 text-[10px] font-bold uppercase tracking-[0.5em] text-stone-400 dark:text-stone-600">Account Registry</h3>
                        <div className="space-y-8">
                            <div className="group">
                                <p className="text-[9px] font-bold uppercase tracking-[0.3em] text-stone-500 dark:text-stone-400 group-hover:text-gold transition-colors">Identity Status</p>
                                <p className="mt-1 text-[11px] font-bold uppercase tracking-widest text-emerald-600 dark:text-emerald-500/80">Authenticated</p>
                            </div>
                            <div className="group">
                                <p className="text-[9px] font-bold uppercase tracking-[0.3em] text-stone-500 dark:text-stone-400 group-hover:text-gold transition-colors">Access Level</p>
                                <p className="mt-1 text-[11px] font-bold uppercase tracking-widest text-foreground">Standard Tier</p>
                            </div>
                            <div className="group">
                                <p className="text-[9px] font-bold uppercase tracking-[0.3em] text-stone-500 dark:text-stone-400 group-hover:text-gold transition-colors">Neural Encryption</p>
                                <p className="mt-1 text-[11px] font-bold uppercase tracking-widest text-stone-600 dark:text-stone-700">AES-256 Enabled</p>
                            </div>
                        </div>
                    </div>

                    <div className="rounded-[2.5rem] border border-black/5 dark:border-white/5 bg-stone-100/30 dark:bg-zinc-900/20 p-8 backdrop-blur-xl">
                        <h3 className="mb-6 text-[10px] font-bold uppercase tracking-[0.3em] text-stone-400 dark:text-stone-600">{t('verification.title')}</h3>
                        {data?.emailVerified ? (
                            <div className="flex items-center gap-4 rounded-2xl bg-emerald-500/5 border border-emerald-500/20 p-4">
                                <CheckCircle size={20} className="text-emerald-600 dark:text-emerald-500" />
                                <span className="text-[10px] font-bold uppercase tracking-widest text-emerald-600 dark:text-emerald-500">{t('verification.verified')}</span>
                            </div>
                        ) : (
                            <div className="space-y-4">
                                <p className="text-[10px] font-medium leading-relaxed text-stone-500">{t('verification.unverified')}</p>
                                <button
                                    type="button"
                                    onClick={handleResendVerification}
                                    disabled={sendingVerify}
                                    className="group flex h-12 w-full items-center justify-center gap-3 rounded-xl border border-gold/30 bg-gold/5 text-[10px] font-bold uppercase tracking-widest text-gold transition-all hover:bg-gold hover:text-black cursor-pointer"
                                >
                                    {sendingVerify ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4 transition-transform group-hover:-translate-y-1 group-hover:translate-x-1" />}
                                    {t('verification.resend')}
                                </button>
                                {verifyMsg && <p className="text-center text-[10px] font-bold text-stone-400 dark:text-stone-600">{verifyMsg}</p>}
                            </div>
                        )}
                    </div>
                </div>

                {/* Main Content */}
                <div className="lg:col-span-8 space-y-8">
                    <motion.div 
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        className="glass rounded-[3rem] p-10 lg:p-16"
                    >
                        <div className="mb-12 flex items-center justify-between">
                            <h3 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground">{t('personal_info')}</h3>
                            {!editing ? (
                                <button
                                    type="button"
                                    onClick={() => setEditing(true)}
                                    className="group flex items-center gap-3 rounded-full border border-black/10 dark:border-white/10 bg-stone-100 dark:bg-white/5 px-6 py-3 text-[10px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-400 transition-all hover:bg-gold hover:text-black hover:border-gold hover:shadow-[0_0_20px_rgba(197,160,89,0.3)] cursor-pointer"
                                >
                                    <Edit2 size={14} /> {t('edit')}
                                </button>
                            ) : (
                                <div className="flex gap-3">
                                    <button
                                        type="button"
                                        onClick={handleSave}
                                        disabled={saving}
                                        className="flex h-12 items-center gap-3 rounded-full bg-gold px-8 text-[10px] font-bold uppercase tracking-widest text-black shadow-lg shadow-gold/20 disabled:opacity-20 cursor-pointer"
                                    >
                                        {saving && <Loader2 className="h-4 w-4 animate-spin" />} {t('save')}
                                    </button>
                                    <button
                                        type="button"
                                        onClick={() => setEditing(false)}
                                        className="h-12 rounded-full border border-black/10 dark:border-white/10 bg-stone-100 dark:bg-white/5 px-8 text-[10px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-400 hover:bg-black/5 dark:hover:bg-white/10 cursor-pointer"
                                    >
                                        {t('cancel')}
                                    </button>
                                </div>
                            )}
                        </div>

                        <div className="grid grid-cols-1 gap-12 md:grid-cols-2">
                            {/* Name */}
                            <div className="space-y-4">
                                <label className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">
                                    {t('labels.fullName')}
                                </label>
                                {editing ? (
                                    <input
                                        value={form.fullName}
                                        onChange={(e) => setForm(f => ({ ...f, fullName: e.target.value }))}
                                        className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] text-foreground"
                                    />
                                ) : (
                                    <p className="font-heading text-xl font-bold uppercase tracking-widest text-foreground border-b border-black/5 dark:border-white/5 pb-4">
                                        {data?.fullName || t('fallback.empty')}
                                    </p>
                                )}
                            </div>

                            {/* Phone */}
                            <div className="space-y-4">
                                <label className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">
                                    {t('labels.phone')}
                                </label>
                                {editing ? (
                                    <input
                                        value={form.phone}
                                        onChange={(e) => setForm(f => ({ ...f, phone: e.target.value }))}
                                        className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] text-foreground"
                                        placeholder={t('placeholders.phone')}
                                    />
                                ) : (
                                    <p className="font-heading text-xl font-bold uppercase tracking-widest text-foreground border-b border-black/5 dark:border-white/5 pb-4">
                                        {data?.phone || t('fallback.empty')}
                                    </p>
                                )}
                            </div>

                            {/* Email */}
                            <div className="space-y-4">
                                <label className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">
                                    {t('labels.email')}
                                </label>
                                <div className="flex flex-col border-b border-black/5 dark:border-white/5 pb-4">
                                    <p className="font-heading text-xl font-bold tracking-tight text-foreground/60">{data?.email}</p>
                                    <span className="mt-2 text-[8px] font-bold uppercase tracking-[0.2em] text-stone-400 dark:text-stone-700">{t('labels.email_immutable')}</span>
                                </div>
                            </div>

                            {/* Gender */}
                            <div className="space-y-4">
                                <label className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">
                                    {t('labels.gender')}
                                </label>
                                {editing ? (
                                    <select
                                        value={form.gender}
                                        onChange={(e) => setForm(f => ({ ...f, gender: e.target.value }))}
                                        className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-50 dark:bg-zinc-900 py-5 px-6 text-[10px] font-bold uppercase tracking-widest outline-none transition-all focus:border-gold/30 text-foreground"
                                    >
                                        <option value="">—</option>
                                        <option value="MALE">{t('gender_options.male')}</option>
                                        <option value="FEMALE">{t('gender_options.female')}</option>
                                        <option value="OTHER">{t('gender_options.other')}</option>
                                    </select>
                                ) : (
                                    <p className="font-heading text-xl font-bold uppercase tracking-widest text-foreground border-b border-black/5 dark:border-white/5 pb-4">
                                        {data?.gender ? t(`gender_options.${data.gender.toLowerCase()}`) : t('fallback.empty')}
                                    </p>
                                )}
                            </div>

                            {/* DOB */}
                            <div className="space-y-4">
                                <label className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">
                                    {t('labels.dob')}
                                </label>
                                {editing ? (
                                    <input
                                        type="date"
                                        value={form.dateOfBirth}
                                        onChange={(e) => setForm(f => ({ ...f, dateOfBirth: e.target.value }))}
                                        className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] text-foreground"
                                    />
                                ) : (
                                    <p className="font-heading text-xl font-bold uppercase tracking-widest text-foreground border-b border-black/5 dark:border-white/5 pb-4">
                                        {data?.dateOfBirth ? format.dateTime(new Date(data.dateOfBirth), { dateStyle: 'long' }) : t('fallback.empty')}
                                    </p>
                                )}
                            </div>

                            {/* Budget Matrix (AI Training) */}
                            {data?.role === 'CUSTOMER' && (
                                <div className="md:col-span-2 grid grid-cols-1 md:grid-cols-2 gap-12 pt-8 border-t border-black/5 dark:border-white/5">
                                    <div className="space-y-4">
                                        <label className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">{t('labels.min_budget')}</label>
                                        {editing ? (
                                            <input
                                                type="number"
                                                value={form.budgetMin}
                                                onChange={(e) => setForm(f => ({ ...f, budgetMin: e.target.value ? Number(e.target.value) : '' }))}
                                                className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] text-foreground"
                                            />
                                        ) : (
                                            <p className="font-heading text-2xl font-bold text-gold tracking-tighter border-b border-black/5 dark:border-white/5 pb-4">
                                                {data?.budgetMin != null ? formatCurrency(data.budgetMin) : t('fallback.empty')}
                                            </p>
                                        )}
                                    </div>
                                    <div className="space-y-4">
                                        <label className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">{t('labels.max_budget')}</label>
                                        {editing ? (
                                            <input
                                                type="number"
                                                value={form.budgetMax}
                                                onChange={(e) => setForm(f => ({ ...f, budgetMax: e.target.value ? Number(e.target.value) : '' }))}
                                                className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] text-foreground"
                                            />
                                        ) : (
                                            <p className="font-heading text-2xl font-bold text-gold tracking-tighter border-b border-black/5 dark:border-white/5 pb-4">
                                                {data?.budgetMax != null ? formatCurrency(data.budgetMax) : t('fallback.empty')}
                                            </p>
                                        )}
                                    </div>
                                </div>
                            )}
                        </div>
                    </motion.div>

                    {data?.role === 'CUSTOMER' && (
                        <div className="glass rounded-[3rem] p-10 lg:p-16">
                            <AddressManager />
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}