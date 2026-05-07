'use client';

import React, { useState, useRef } from 'react';
import { useTranslations } from 'next-intl';
import StarRating from './star-rating';
import { Button } from '@/components/ui/button';
import { reviewService } from '@/services/review.service';
import { X, Image as ImageIcon, Loader2, AlertCircle, Zap, ShieldCheck, Sparkles } from 'lucide-react';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';
import { motion, AnimatePresence } from 'framer-motion';

interface ReviewFormProps {
    productId: string;
    orderItemId: number;
    productName: string;
    onSuccess?: () => void;
    onCancel?: () => void;
}

const MAX_IMAGES = 5;
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

const ReviewForm: React.FC<ReviewFormProps> = ({
    productId,
    orderItemId,
    productName,
    onSuccess,
    onCancel,
}) => {
    const t = useTranslations('notifications');
    const tReview = useTranslations('review');
    const [rating, setRating] = useState(5);
    const [content, setContent] = useState('');
    const [images, setImages] = useState<{ file?: File, url: string }[]>([]);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [isUploading, setIsUploading] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const files = Array.from(e.target.files || []);
        if (images.length + files.length > MAX_IMAGES) {
            toast.error(t('image_limit', { max: MAX_IMAGES }));
            return;
        }

        const validFiles = files.filter(file => {
            if (file.size > MAX_FILE_SIZE) {
                toast.error(t('image_size_error', { name: file.name, max: 5 }));
                return false;
            }
            if (!file.type.startsWith('image/')) {
                toast.error(t('image_type_error', { name: file.name }));
                return false;
            }
            return true;
        });

        const newImages = validFiles.map(file => ({
            file,
            url: URL.createObjectURL(file)
        }));

        setImages(prev => [...prev, ...newImages]);
    };

    const removeImage = (index: number) => {
        const removed = images[index];
        if (removed.url.startsWith('blob:')) {
            URL.revokeObjectURL(removed.url);
        }
        setImages(images.filter((_, i) => i !== index));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (rating < 1) {
            toast.error(t('rating_required'));
            return;
        }

        setIsSubmitting(true);
        try {
            let imageUrls: string[] = [];

            if (images.length > 0) {
                setIsUploading(true);
                try {
                    const filesToUpload = images
                        .filter(img => img.file)
                        .map(img => img.file as File);
                    
                    if (filesToUpload.length > 0) {
                        imageUrls = await reviewService.uploadImages(filesToUpload);
                    }
                } catch (error: any) {
                    toast.error(t('image_upload_error'));
                    setIsUploading(false);
                    setIsSubmitting(false);
                    return;
                }
                setIsUploading(false);
            }

            await reviewService.create({
                productId,
                orderItemId,
                rating,
                content,
                images: imageUrls,
            });

            toast.success(t('review_success'));
            onSuccess?.();
        } catch (error: any) {
            toast.error(error.message || t('review_error'));
        } finally {
            setIsSubmitting(false);
            setIsUploading(false);
        }
    };

    const getRatingDesc = (r: number) => {
        switch (r) {
            case 5: return tReview('form.rating_desc.excellent');
            case 4: return tReview('form.rating_desc.very_good');
            case 3: return tReview('form.rating_desc.good');
            case 2: return tReview('form.rating_desc.fair');
            case 1: return tReview('form.rating_desc.poor');
            default: return '';
        }
    };

    return (
        <form onSubmit={handleSubmit} className="bg-zinc-950/90 backdrop-blur-3xl rounded-[3rem] p-10 md:p-16 border border-white/5 shadow-2xl space-y-12 overflow-hidden relative">
            <div className="absolute top-0 right-0 p-16 opacity-5 pointer-events-none">
                <Sparkles size={200} className="text-gold" />
            </div>

            <div className="space-y-4 text-center md:text-left relative">
                <div className="flex items-center gap-4 mb-2">
                    <div className="h-[1px] w-12 bg-gold/50" />
                    <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Quality Appraisal</span>
                </div>
                <h3 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground italic">{tReview('form.title')}</h3>
                <p className="text-[10px] text-stone-500 uppercase tracking-[.4em] font-bold">{tReview('form.reviewing_label')} <span className="text-gold font-black italic">{productName}</span></p>
            </div>

            <div className="space-y-6">
                <label className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-700 ml-4">{tReview('form.rating_label', { rating })}</label>
                <div className="flex flex-col md:flex-row md:items-center gap-8 bg-white/5 px-10 py-8 rounded-[2.5rem] border border-white/5 transition-all duration-500 hover:border-gold/20 backdrop-blur-md group">
                    <StarRating rating={rating} onChange={setRating} size={40} className="shrink-0" />
                    <div className="h-px w-full md:h-12 md:w-px bg-white/5" />
                    <span className="text-xl font-heading text-gold font-bold uppercase tracking-widest flex items-center">
                        {getRatingDesc(rating)}
                    </span>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-12">
                <div className="lg:col-span-7 space-y-6">
                    <label className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-700 ml-4">{tReview('form.description_label')}</label>
                    <div className="relative group">
                        <textarea
                            className="w-full h-56 bg-zinc-900/60 border border-white/5 rounded-[2rem] p-8 text-sm font-body text-stone-300 outline-none focus:border-gold/30 transition-all resize-none custom-scrollbar placeholder:text-stone-700 italic"
                            placeholder={tReview('form.description_placeholder')}
                            value={content}
                            onChange={(e) => setContent(e.target.value)}
                            required
                        />
                        <div className="absolute bottom-4 right-8 text-[10px] font-bold text-stone-800 uppercase tracking-widest">{content.length} / 1000</div>
                    </div>
                </div>

                <div className="lg:col-span-5 space-y-6">
                    <div className="flex justify-between items-center ml-4">
                        <label className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-700">{tReview('form.visual_label')}</label>
                        <span className="text-[10px] font-bold tracking-widest uppercase text-gold/40">{images.length}/{MAX_IMAGES}</span>
                    </div>

                    <div className="grid grid-cols-3 gap-4">
                        <AnimatePresence>
                            {images.map((img, idx) => (
                                <motion.div key={idx} initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.8 }} className="relative aspect-square rounded-2xl overflow-hidden border border-white/5 group bg-zinc-900">
                                    <img src={img.url} alt="review" className="w-full h-full object-cover transition-transform group-hover:scale-110" />
                                    <button
                                        type="button"
                                        onClick={() => removeImage(idx)}
                                        className="absolute inset-0 bg-red-500/80 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-white"
                                    >
                                        <X size={18} />
                                    </button>
                                </motion.div>
                            ))}
                        </AnimatePresence>

                        {images.length < MAX_IMAGES && (
                            <button
                                type="button"
                                onClick={() => fileInputRef.current?.click()}
                                className="aspect-square flex flex-col items-center justify-center border border-dashed border-stone-800 rounded-2xl hover:border-gold/30 transition-all group bg-white/5"
                            >
                                <ImageIcon className="text-stone-700 group-hover:text-gold transition-colors duration-500" size={32} />
                                <span className="text-[8px] mt-2 text-stone-700 uppercase font-bold tracking-widest">{tReview('form.add_photo')}</span>
                            </button>
                        )}
                    </div>

                    <input type="file" ref={fileInputRef} onChange={handleFileChange} accept="image/*" multiple className="hidden" />

                    <div className="p-8 rounded-[2rem] bg-gold/5 border border-gold/10 flex gap-6">
                        <div className="h-10 w-10 shrink-0 rounded-xl bg-gold/20 flex items-center justify-center text-gold">
                            <ShieldCheck size={20} />
                        </div>
                        <p className="text-[10px] text-stone-500 leading-relaxed font-bold uppercase tracking-widest italic">
                            {tReview('form.visual_desc')}
                        </p>
                    </div>
                </div>
            </div>

            <div className="flex flex-col sm:flex-row justify-end items-center gap-10 pt-12 border-t border-white/5">
                {onCancel && (
                    <button
                        type="button"
                        onClick={onCancel}
                        disabled={isSubmitting}
                        className="text-[10px] uppercase font-black tracking-[0.4em] text-stone-700 hover:text-white transition-colors"
                    >
                        {tReview('form.cancel')}
                    </button>
                )}
                <button
                    type="submit"
                    disabled={isSubmitting || isUploading}
                    className="w-full sm:w-auto h-16 px-16 rounded-2xl bg-gold text-[10px] font-black uppercase tracking-[0.4em] text-black shadow-2xl shadow-gold/20 transition-all hover:scale-[1.02] disabled:opacity-50 flex items-center justify-center gap-4"
                >
                    {isSubmitting || isUploading ? (
                        <>
                            <Loader2 className="h-4 w-4 animate-spin" />
                            {isUploading ? tReview('form.uploading') : tReview('form.sending')}
                        </>
                    ) : (
                        <>
                            <Zap size={18} />
                            {tReview('form.submit')}
                        </>
                    )}
                </button>
            </div>
        </form>
    );
};

export default ReviewForm;
