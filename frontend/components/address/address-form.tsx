'use client';

import { useState, useCallback } from 'react';
import { useTranslations } from 'next-intl';
import { CreateAddressDto } from '@/services/address.service';
import { AddressPicker } from './address-picker';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Checkbox } from '@/components/ui/checkbox';
import { Button } from '@/components/ui/button';
import { Loader2, Save, Zap } from 'lucide-react';
import { cn } from '@/lib/utils';

interface AddressFormProps {
    onSubmit: (data: CreateAddressDto) => Promise<void>;
    initialData?: Partial<CreateAddressDto>;
    loading?: boolean;
}

export function AddressForm({ onSubmit, initialData, loading }: AddressFormProps) {
    const [formData, setFormData] = useState<CreateAddressDto>({
        recipientName: initialData?.recipientName || '',
        phone: initialData?.phone || '',
        provinceId: initialData?.provinceId || 0,
        provinceName: initialData?.provinceName || '',
        districtId: initialData?.districtId || 0,
        districtName: initialData?.districtName || '',
        wardCode: initialData?.wardCode || '',
        wardName: initialData?.wardName || '',
        detailAddress: initialData?.detailAddress || '',
        isDefault: initialData?.isDefault || false,
    });

    const handleAddressChange = useCallback((data: any) => {
        setFormData((prev) => ({ ...prev, ...data }));
    }, []);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        onSubmit(formData);
    };

    const t = useTranslations('address');

    const inputClasses = "h-14 rounded-2xl border border-white/5 bg-zinc-900/60 px-6 text-sm text-foreground outline-none focus:border-gold/30 transition-all placeholder:text-stone-700 font-body";
    const labelClasses = "text-[10px] font-bold tracking-[0.3em] uppercase text-stone-700 ml-4 mb-2 block";

    return (
        <form onSubmit={handleSubmit} className="space-y-10">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-1">
                    <label className={labelClasses}>{t('recipient_name')}</label>
                    <input
                        value={formData.recipientName}
                        onChange={(e) => setFormData({ ...formData, recipientName: e.target.value })}
                        placeholder={t('recipient_placeholder')}
                        required
                        className={cn(inputClasses, "w-full font-heading font-bold uppercase tracking-widest")}
                    />
                </div>
                <div className="space-y-1">
                    <label className={labelClasses}>{t('phone_number')}</label>
                    <input
                        value={formData.phone}
                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                        placeholder={t('phone_placeholder')}
                        required
                        className={cn(inputClasses, "w-full font-mono font-bold tracking-widest")}
                    />
                </div>
            </div>

            <AddressPicker
                initialValues={{
                    provinceId: formData.provinceId,
                    districtId: formData.districtId,
                    wardCode: formData.wardCode,
                }}
                onAddressChange={handleAddressChange}
            />

            <div className="space-y-1">
                <label className={labelClasses}>{t('street_name')}</label>
                <input
                    value={formData.detailAddress}
                    onChange={(e) => setFormData({ ...formData, detailAddress: e.target.value })}
                    placeholder={t('street_placeholder')}
                    required
                    className={cn(inputClasses, "w-full italic")}
                />
            </div>

            <div className="flex items-center gap-4 px-4 py-6 rounded-2xl bg-white/5 border border-white/5 group cursor-pointer" onClick={() => setFormData({ ...formData, isDefault: !formData.isDefault })}>
                <div className={cn("h-6 w-6 rounded-lg border-2 flex items-center justify-center transition-all", formData.isDefault ? "bg-gold border-gold" : "border-stone-800")}>
                    {formData.isDefault && <Save size={14} className="text-black" />}
                </div>
                <label className="text-xs font-bold uppercase tracking-widest text-stone-500 cursor-pointer group-hover:text-stone-300 transition-colors">
                    {t('set_default')}
                </label>
            </div>

            <button
                type="submit"
                disabled={loading || !formData.wardCode}
                className="w-full flex h-16 items-center justify-center gap-4 rounded-2xl bg-gold text-[10px] font-black uppercase tracking-[0.4em] text-black shadow-2xl shadow-gold/20 transition-all hover:scale-[1.02] disabled:opacity-50"
            >
                {loading ? <Loader2 className="animate-spin" /> : <Zap size={18} />}
                {t('save_address')}
            </button>
        </form>
    );
}
