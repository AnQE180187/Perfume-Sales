'use client';

import { useState, useEffect } from 'react';
import { addressService, UserAddress, CreateAddressDto } from '@/services/address.service';
import { AddressCard } from '@/components/address/address-card';
import { AddressForm } from '@/components/address/address-form';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus, Loader2, Trash, Edit, Star, MapPinned } from 'lucide-react';
import { toast } from 'sonner';
import { useTranslations } from 'next-intl';

export default function AddressesPage() {
    const t = useTranslations('dashboard.addresses');
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
            toast.error(t('error.fetch'));
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
                toast.success(t('success.updated'));
            } else {
                await addressService.create(dto);
                toast.success(t('success.added'));
            }
            await fetchAddresses();
            setIsFormOpen(false);
            setSelectedAddress(null);
        } catch (error) {
            toast.error(t('error.generic'));
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm(t('delete_confirm', { type: t('title') }))) return;
        try {
            await addressService.delete(id);
            toast.success(t('success.deleted'));
            await fetchAddresses();
        } catch (error) {
            toast.error(t('error.delete'));
        }
    };

    const handleSetDefault = async (id: string) => {
        try {
            await addressService.setDefault(id);
            toast.success(t('success.set_default'));
            await fetchAddresses();
        } catch (error) {
            toast.error(t('error.set_default'));
        }
    };

    if (loading) {
        return (
            <div className="flex h-[400px] items-center justify-center">
                <Loader2 className="h-10 w-10 animate-spin text-gold" />
            </div>
        );
    }

    return (
        <div className="space-y-12 pb-12">
            <header className="flex flex-col md:flex-row justify-between items-start md:items-end gap-8">
                <div>
                    <div className="flex items-center gap-4 mb-4">
                        <div className="h-[1px] w-12 bg-gold/50" />
                        <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry</span>
                    </div>
                    <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
                        Logistics <span className="gold-gradient">Coordinates</span>
                    </h1>
                    <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest text-stone-500">{t('subtitle')}</p>
                </div>
                <Dialog open={isFormOpen} onOpenChange={setIsFormOpen}>
                    <DialogTrigger asChild>
                        <button onClick={() => setSelectedAddress(null)} className="h-14 rounded-full bg-gold px-10 text-[10px] font-bold uppercase tracking-widest text-black shadow-lg shadow-gold/20 hover:scale-105 transition-all cursor-pointer">
                            <Plus className="mr-2 h-4 w-4 inline-block" /> {t('add_new')}
                        </button>
                    </DialogTrigger>
                    <DialogContent className="rounded-[3rem] border-black/5 dark:border-white/5 glass max-w-2xl p-0 overflow-hidden">
                        <div className="p-10 lg:p-16">
                            <DialogHeader className="mb-10">
                                <DialogTitle className="font-heading text-3xl font-bold uppercase tracking-widest text-foreground">
                                    {selectedAddress ? 'Modify Entry' : 'New Coordinate'}
                                </DialogTitle>
                            </DialogHeader>
                            <AddressForm
                                onSubmit={handleFormSubmit}
                                initialData={selectedAddress || {}}
                                loading={submitting}
                            />
                        </div>
                    </DialogContent>
                </Dialog>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {addresses.map((address) => (
                    <motion.div 
                        key={address.id} 
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="relative group"
                    >
                        <AddressCard address={address} />
                        <div className="absolute top-8 right-8 flex items-center gap-3 opacity-0 group-hover:opacity-100 transition-all duration-300">
                            {!address.isDefault && (
                                <button
                                    className="w-10 h-10 rounded-full glass border-black/5 dark:border-white/5 flex items-center justify-center text-gold hover:bg-gold hover:text-black transition-all shadow-xl cursor-pointer"
                                    onClick={() => handleSetDefault(address.id)}
                                    title={t('set_default')}
                                >
                                    <Star className="h-4 w-4" />
                                </button>
                            )}
                            <button
                                className="w-10 h-10 rounded-full glass border-black/5 dark:border-white/5 flex items-center justify-center text-stone-400 hover:bg-gold hover:text-black transition-all shadow-xl cursor-pointer"
                                onClick={() => {
                                    setSelectedAddress(address);
                                    setIsFormOpen(true);
                                }}
                                title={t('edit')}
                            >
                                <Edit className="h-4 w-4" />
                            </button>
                            <button
                                className="w-10 h-10 rounded-full bg-red-500/10 border border-red-500/20 flex items-center justify-center text-red-500 hover:bg-red-500 hover:text-white transition-all shadow-xl cursor-pointer"
                                onClick={() => handleDelete(address.id)}
                            >
                                <Trash className="h-4 w-4" />
                            </button>
                        </div>
                    </motion.div>
                ))}
            </div>

            {addresses.length === 0 && (
                 <div className="text-center py-24 glass rounded-[3rem]">
                    <MapPinned className="mx-auto text-stone-200 dark:text-stone-800 mb-6" size={64} />
                    <p className="text-[10px] uppercase font-bold tracking-[0.3em] text-stone-400 dark:text-stone-700 mb-8">{t('no_addresses')}</p>
                    <Dialog open={isFormOpen} onOpenChange={setIsFormOpen}>
                        <DialogTrigger asChild>
                             <button onClick={() => setSelectedAddress(null)} className="h-14 rounded-full bg-stone-100 dark:bg-white/5 border border-black/5 dark:border-white/10 px-10 text-[10px] font-bold uppercase tracking-widest text-stone-600 dark:text-stone-400 hover:bg-gold hover:text-black transition-all cursor-pointer">
                                <Plus className="mr-2 h-4 w-4 inline-block" /> {t('add_new')}
                            </button>
                        </DialogTrigger>
                        <DialogContent className="rounded-[3rem] border-black/5 dark:border-white/5 glass max-w-2xl p-0 overflow-hidden">
                            <div className="p-10 lg:p-16">
                                <DialogHeader className="mb-10">
                                    <DialogTitle className="font-heading text-3xl font-bold uppercase tracking-widest text-foreground">New Coordinate</DialogTitle>
                                </DialogHeader>
                                <AddressForm onSubmit={handleFormSubmit} loading={submitting} />
                            </div>
                        </DialogContent>
                    </Dialog>
                </div>
            )}
        </div>
    );
}
