'use client';

import { useEffect, useMemo, useState } from 'react';
import { useTranslations } from 'next-intl';
import { toast } from 'sonner';
import { Edit, Loader2, Plus, Star, Trash, MapPin, Zap } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

import { addressService, type CreateAddressDto, type UserAddress } from '@/services/address.service';
import { AddressCard } from '@/components/address/address-card';
import { AddressForm } from '@/components/address/address-form';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { useUIStore } from '@/store/ui.store';
import { cn } from '@/lib/utils';

type AddressManagerProps = {
  className?: string;
};

export function AddressManager({ className }: AddressManagerProps) {
  const t = useTranslations('dashboard.addresses');

  const [addresses, setAddresses] = useState<UserAddress[]>([]);
  const [loading, setLoading] = useState(true);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [selectedAddress, setSelectedAddress] = useState<UserAddress | null>(null);
  const { setModalOpen } = useUIStore();

  useEffect(() => {
    setModalOpen(isFormOpen);
  }, [isFormOpen, setModalOpen]);

  const defaultAddress = useMemo(
    () => addresses.find((a) => a.isDefault) ?? addresses[0] ?? null,
    [addresses],
  );

  const fetchAddresses = async () => {
    setLoading(true);
    try {
      const data = await addressService.getAll();
      setAddresses(data);
    } catch {
      toast.error(t('error.fetch'));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void fetchAddresses();
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
    } catch {
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
    } catch {
      toast.error(t('error.delete'));
    }
  };

  const handleSetDefault = async (id: string) => {
    try {
      await addressService.setDefault(id);
      toast.success(t('success.set_default'));
      await fetchAddresses();
    } catch {
      toast.error(t('error.set_default'));
    }
  };

  if (loading) {
    return (
      <div className={cn("flex h-64 items-center justify-center", className)}>
        <Loader2 className="animate-spin text-gold" size={32} />
      </div>
    );
  }

  return (
    <div className={className}>
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-8 mb-12">
        <div className="space-y-4">
          <div className="flex items-center gap-4">
            <div className="h-[1px] w-12 bg-gold/50" />
            <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Logistics Archive</span>
          </div>
          <h1 className="font-heading text-4xl font-bold uppercase tracking-widest text-foreground">
            {t('title')}
          </h1>
          <p className="text-sm font-body text-stone-500 max-w-md">{t('subtitle')}</p>
        </div>

        <Dialog
          open={isFormOpen}
          onOpenChange={(open) => {
            setIsFormOpen(open);
            if (!open) setSelectedAddress(null);
          }}
        >
          <DialogTrigger asChild>
            <button
              onClick={() => setSelectedAddress(null)}
              className="flex h-14 items-center gap-3 rounded-2xl bg-gold px-8 text-[10px] font-black uppercase tracking-widest text-black shadow-xl shadow-gold/20 transition-all hover:scale-[1.02]"
            >
              <Plus size={18} /> {t('add_new')}
            </button>
          </DialogTrigger>
          <DialogContent className="rounded-[3rem] border-white/5 bg-zinc-950/95 backdrop-blur-3xl max-w-2xl p-0 overflow-hidden shadow-2xl">
            <div className="p-10 space-y-8">
              <DialogHeader>
                <DialogTitle className="font-heading text-2xl font-bold text-foreground uppercase tracking-widest">
                  {selectedAddress ? 'Modify' : 'Initialize'} <span className="gold-gradient">Archive</span>
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
      </div>

      <AnimatePresence mode="popLayout">
        {addresses.length === 0 ? (
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center py-24 rounded-[3rem] border border-white/5 bg-zinc-900/40 backdrop-blur-3xl">
            <MapPin className="mx-auto text-stone-800 mb-6" size={64} />
            <p className="text-[10px] uppercase font-bold tracking-[0.4em] text-stone-500">
              {t('no_addresses')}
            </p>
          </motion.div>
        ) : (
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
            {addresses.map((address) => (
              <motion.div key={address.id} layout initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="relative group">
                <AddressCard address={address} />
                
                <div className="absolute top-10 right-10 flex items-center gap-3 opacity-0 group-hover:opacity-100 transition-all duration-500 translate-x-4 group-hover:translate-x-0">
                  {!address.isDefault && (
                    <button
                      className="h-10 w-10 rounded-xl bg-zinc-950/80 border border-white/5 flex items-center justify-center text-stone-500 hover:text-gold hover:border-gold/30 transition-all shadow-xl backdrop-blur-md"
                      onClick={() => void handleSetDefault(address.id)}
                      title={t('set_default')}
                    >
                      <Star className="h-4 w-4" />
                    </button>
                  )}
                  <button
                    className="h-10 w-10 rounded-xl bg-zinc-950/80 border border-white/5 flex items-center justify-center text-stone-500 hover:text-gold hover:border-gold/30 transition-all shadow-xl backdrop-blur-md"
                    onClick={() => {
                      setSelectedAddress(address);
                      setIsFormOpen(true);
                    }}
                    title={t('edit')}
                  >
                    <Edit className="h-4 w-4" />
                  </button>
                  <button
                    className="h-10 w-10 rounded-xl bg-red-500/10 border border-red-500/20 flex items-center justify-center text-red-500 hover:bg-red-500 hover:text-white transition-all shadow-xl backdrop-blur-md"
                    onClick={() => void handleDelete(address.id)}
                    title={t('delete')}
                  >
                    <Trash className="h-4 w-4" />
                  </button>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
