'use client';

import { useState, useEffect } from 'react';
import { useTranslations } from 'next-intl';
import {
    ghnService,
    type GHNProvince,
    type GHNDistrict,
    type GHNWard,
} from '@/services/ghn.service';
import { cn } from '@/lib/utils';
import { ChevronDown } from 'lucide-react';

interface AddressPickerProps {
    onAddressChange: (data: {
        provinceId: number;
        provinceName: string;
        districtId: number;
        districtName: string;
        wardCode: string;
        wardName: string;
    }) => void;
    initialValues?: {
        provinceId?: number;
        districtId?: number;
        wardCode?: string;
    };
}

export function AddressPicker({ onAddressChange, initialValues }: AddressPickerProps) {
    const [provinces, setProvinces] = useState<GHNProvince[]>([]);
    const [districts, setDistricts] = useState<GHNDistrict[]>([]);
    const [wards, setWards] = useState<GHNWard[]>([]);

    const [provinceId, setProvinceId] = useState<number | null>(initialValues?.provinceId || null);
    const [districtId, setDistrictId] = useState<number | null>(initialValues?.districtId || null);
    const [wardCode, setWardCode] = useState<string>(initialValues?.wardCode || '');

    useEffect(() => {
        ghnService.getProvinces().then(setProvinces).catch(() => setProvinces([]));
    }, []);

    useEffect(() => {
        if (!provinceId) {
            setDistricts([]);
            return;
        }
        ghnService.getDistricts(provinceId).then(setDistricts).catch(() => setDistricts([]));
    }, [provinceId]);

    useEffect(() => {
        if (!districtId) {
            setWards([]);
            return;
        }
        ghnService.getWards(districtId).then(setWards).catch(() => setWards([]));
    }, [districtId]);

    useEffect(() => {
        if (provinceId && districtId && wardCode) {
            const p = provinces.find((p) => p.ProvinceID === provinceId);
            const d = districts.find((d) => d.DistrictID === districtId);
            const w = wards.find((w) => w.WardCode === wardCode);

            if (p && d && w) {
                onAddressChange({
                    provinceId,
                    provinceName: p.ProvinceName,
                    districtId,
                    districtName: d.DistrictName,
                    wardCode,
                    wardName: w.WardName,
                });
            }
        }
    }, [provinceId, districtId, wardCode, provinces, districts, wards]);

    const t = useTranslations('address');

    const selectClasses = "w-full h-14 rounded-2xl border border-white/5 bg-zinc-900/60 px-6 text-[10px] font-bold uppercase tracking-widest text-foreground outline-none focus:border-gold/30 transition-all appearance-none cursor-pointer disabled:opacity-20";
    const labelClasses = "text-[10px] font-bold tracking-[0.3em] uppercase text-stone-700 ml-4 mb-2 block";

    return (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="space-y-1 relative">
                <label className={labelClasses}>{t('province_label')}</label>
                <div className="relative group">
                    <select
                        value={provinceId ?? ''}
                        onChange={(e) => {
                            setProvinceId(Number(e.target.value));
                            setDistrictId(null);
                            setWardCode('');
                        }}
                        className={selectClasses}
                    >
                        <option value="" disabled>{t('province_placeholder')}</option>
                        {provinces.map((p) => (
                            <option key={p.ProvinceID} value={p.ProvinceID}>
                                {p.ProvinceName}
                            </option>
                        ))}
                    </select>
                    <ChevronDown className="absolute right-6 top-1/2 -translate-y-1/2 text-stone-700 group-hover:text-gold transition-colors pointer-events-none" size={14} />
                </div>
            </div>

            <div className="space-y-1 relative">
                <label className={labelClasses}>{t('district_label')}</label>
                <div className="relative group">
                    <select
                        value={districtId ?? ''}
                        onChange={(e) => {
                            setDistrictId(Number(e.target.value));
                            setWardCode('');
                        }}
                        disabled={!provinceId}
                        className={selectClasses}
                    >
                        <option value="" disabled>{t('district_placeholder')}</option>
                        {districts.map((d) => (
                            <option key={d.DistrictID} value={d.DistrictID}>
                                {d.DistrictName}
                            </option>
                        ))}
                    </select>
                    <ChevronDown className="absolute right-6 top-1/2 -translate-y-1/2 text-stone-700 group-hover:text-gold transition-colors pointer-events-none" size={14} />
                </div>
            </div>

            <div className="space-y-1 relative">
                <label className={labelClasses}>{t('ward_label')}</label>
                <div className="relative group">
                    <select
                        value={wardCode}
                        onChange={(e) => setWardCode(e.target.value)}
                        disabled={!districtId}
                        className={selectClasses}
                    >
                        <option value="" disabled>{t('ward_placeholder')}</option>
                        {wards.map((w) => (
                            <option key={w.WardCode} value={w.WardCode}>
                                {w.WardName}
                            </option>
                        ))}
                    </select>
                    <ChevronDown className="absolute right-6 top-1/2 -translate-y-1/2 text-stone-700 group-hover:text-gold transition-colors pointer-events-none" size={14} />
                </div>
            </div>
        </div>
    );
}
