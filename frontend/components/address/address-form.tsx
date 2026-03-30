'use client';

import { useState, useCallback } from 'react';
import { CreateAddressDto } from '@/services/address.service';
import { AddressPicker } from './address-picker';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Checkbox } from '@/components/ui/checkbox';
import { Button } from '@/components/ui/button';
import { Loader2, Save } from 'lucide-react';

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

    return (
        <form onSubmit={handleSubmit} className="space-y-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                    <Label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Tên người nhận *</Label>
                    <Input
                        value={formData.recipientName}
                        onChange={(e) => setFormData({ ...formData, recipientName: e.target.value })}
                        placeholder="Nguyễn Văn A"
                        required
                        className="rounded-[1.5rem]"
                    />
                </div>
                <div className="space-y-2">
                    <Label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Số điện thoại *</Label>
                    <Input
                        value={formData.phone}
                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                        placeholder="0901234567"
                        required
                        className="rounded-[1.5rem]"
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

            <div className="space-y-2">
                <Label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">Số nhà, tên đường *</Label>
                <Input
                    value={formData.detailAddress}
                    onChange={(e) => setFormData({ ...formData, detailAddress: e.target.value })}
                    placeholder="Số 123, đường ABC..."
                    required
                    className="rounded-[1.5rem]"
                />
            </div>

            <div className="flex items-center space-x-3 pl-2">
                <Checkbox
                    id="isDefault"
                    checked={formData.isDefault}
                    onCheckedChange={(checked) => setFormData({ ...formData, isDefault: checked === true })}
                />
                <Label htmlFor="isDefault" className="text-xs font-medium text-stone-500 cursor-pointer">
                    Đặt làm địa chỉ mặc định
                </Label>
            </div>

            <Button
                type="submit"
                disabled={loading || !formData.wardCode}
                className="w-full py-6 rounded-full bg-luxury-black dark:bg-gold text-white font-bold tracking-[.3em] uppercase text-[10px] hover:scale-[1.02] active:scale-95 transition-all"
            >
                {loading ? <Loader2 className="animate-spin mr-2" /> : <Save className="mr-2" size={16} />}
                Lưu địa chỉ
            </Button>
        </form>
    );
}
