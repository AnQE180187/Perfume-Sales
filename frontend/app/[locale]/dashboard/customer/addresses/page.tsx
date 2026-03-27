'use client';

import { useState, useEffect } from 'react';
import { addressService, UserAddress, CreateAddressDto } from '@/services/address.service';
import { AddressCard } from '@/components/address/address-card';
import { AddressForm } from '@/components/address/address-form';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus, Loader2, Trash, Edit, Star, MapPinned } from 'lucide-react';
import { toast } from 'sonner';

export default function AddressesPage() {
    const [addresses, setAddresses] = useState<UserAddress[]>([]);
    const [loading, setLoading] = useState(true);
    const [isFormOpen, setIsFormOpen] = useState(false);
    const [submitting, setSubmitting] = useState(false);
    const [selectedAddress, setSelectedAddress] = useState<UserAddress | null>(null);

    const fetchAddresses = async () => {
        setLoading(true);
        try {
            const data = await addressService.getAll();
            setAddresses(data);
        } catch (error) {
            toast.error('Không thể tải danh sách địa chỉ.');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchAddresses();
    }, []);

    const handleFormSubmit = async (dto: CreateAddressDto) => {
        setSubmitting(true);
        try {
            if (selectedAddress) {
                await addressService.update(selectedAddress.id, dto);
                toast.success('Cập nhật địa chỉ thành công!');
            } else {
                await addressService.create(dto);
                toast.success('Thêm địa chỉ mới thành công!');
            }
            await fetchAddresses();
            setIsFormOpen(false);
            setSelectedAddress(null);
        } catch (error) {
            toast.error('Đã có lỗi xảy ra.');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm('Bạn có chắc chắn muốn xóa địa chỉ này?')) return;
        try {
            await addressService.delete(id);
            toast.success('Xóa địa chỉ thành công!');
            await fetchAddresses();
        } catch (error) {
            toast.error('Không thể xóa địa chỉ.');
        }
    };

    const handleSetDefault = async (id: string) => {
        try {
            await addressService.setDefault(id);
            toast.success('Đặt làm địa chỉ mặc định thành công!');
            await fetchAddresses();
        } catch (error) {
            toast.error('Không thể đặt làm mặc định.');
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center p-20">
                <Loader2 className="animate-spin text-gold" size={32} />
            </div>
        );
    }

    return (
        <div className="p-4 sm:p-10">
            <div className="flex items-center justify-between mb-10">
                <h1 className="text-3xl font-serif text-luxury-black dark:text-white flex items-center gap-4">
                    <MapPinned className="text-gold" />
                    Sổ địa chỉ
                </h1>
                <Dialog open={isFormOpen} onOpenChange={setIsFormOpen}>
                    <DialogTrigger asChild>
                        <Button onClick={() => setSelectedAddress(null)} className="rounded-full bg-luxury-black dark:bg-gold hover:scale-105 transition-transform">
                            <Plus className="mr-2 h-4 w-4" /> Thêm địa chỉ mới
                        </Button>
                    </DialogTrigger>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>{selectedAddress ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới'}</DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <AddressForm
                                onSubmit={handleFormSubmit}
                                initialData={selectedAddress || {}}
                                loading={submitting}
                            />
                        </div>
                    </DialogContent>
                </Dialog>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {addresses.map((address) => (
                    <div key={address.id} className="relative group">
                        <AddressCard address={address} />
                        <div className="absolute top-6 right-6 flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                            {!address.isDefault && (
                                <Button
                                    size="icon"
                                    variant="outline"
                                    className="rounded-full bg-white/50 dark:bg-zinc-800/50 backdrop-blur-sm"
                                    onClick={() => handleSetDefault(address.id)}
                                >
                                    <Star className="h-4 w-4 text-gold" />
                                </Button>
                            )}
                            <Button
                                size="icon"
                                variant="outline"
                                className="rounded-full bg-white/50 dark:bg-zinc-800/50 backdrop-blur-sm"
                                onClick={() => {
                                    setSelectedAddress(address);
                                    setIsFormOpen(true);
                                }}
                            >
                                <Edit className="h-4 w-4" />
                            </Button>
                            <Button
                                size="icon"
                                variant="destructive"
                                className="rounded-full bg-red-500/80 backdrop-blur-sm"
                                onClick={() => handleDelete(address.id)}
                            >
                                <Trash className="h-4 w-4" />
                            </Button>
                        </div>
                    </div>
                ))}
            </div>

            {addresses.length === 0 && (
                 <div className="text-center py-20 border-2 border-dashed border-stone-200 dark:border-white/10 rounded-[2rem]">
                    <p className="text-sm text-stone-500 mb-4">Bạn chưa có địa chỉ nào được lưu.</p>
                    <Dialog open={isFormOpen} onOpenChange={setIsFormOpen}>
                        <DialogTrigger asChild>
                             <Button onClick={() => setSelectedAddress(null)} className="rounded-full">
                                <Plus className="mr-2 h-4 w-4" /> Thêm địa chỉ
                            </Button>
                        </DialogTrigger>
                        <DialogContent>
                             <DialogHeader>
                                <DialogTitle>Thêm địa chỉ mới</DialogTitle>
                            </DialogHeader>
                             <div className="py-4">
                                <AddressForm onSubmit={handleFormSubmit} loading={submitting} />
                            </div>
                        </DialogContent>
                    </Dialog>
                </div>
            )}
        </div>
    );
}
