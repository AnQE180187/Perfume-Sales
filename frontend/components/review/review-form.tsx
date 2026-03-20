'use client';

import React, { useState, useRef } from 'react';
import StarRating from './star-rating';
import { Button } from '@/components/ui/button';
import { reviewService } from '@/services/review.service';
import { X, Image as ImageIcon, Loader2, AlertCircle } from 'lucide-react';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';

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
    const [rating, setRating] = useState(5);
    const [content, setContent] = useState('');
    const [images, setImages] = useState<{ file?: File, url: string }[]>([]);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [isUploading, setIsUploading] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const files = Array.from(e.target.files || []);
        if (images.length + files.length > MAX_IMAGES) {
            toast.error(`You can only upload up to ${MAX_IMAGES} images`);
            return;
        }

        const validFiles = files.filter(file => {
            if (file.size > MAX_FILE_SIZE) {
                toast.error(`File ${file.name} is too large (max 5MB)`);
                return false;
            }
            if (!file.type.startsWith('image/')) {
                toast.error(`File ${file.name} is not an image`);
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
            toast.error("Please select a rating");
            return;
        }

        setIsSubmitting(true);
        try {
            // Logic to upload images if any
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
                    console.error("Failed to upload images:", error);
                    toast.error("Failed to upload images. Please try again.");
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

            toast.success("Thank you for your elegant review!");
            onSuccess?.();
        } catch (error: any) {
            toast.error(error.message || "Failed to submit review");
        } finally {
            setIsSubmitting(false);
            setIsUploading(false);
        }
    };

    return (
        <form onSubmit={handleSubmit} className="glass bg-white dark:bg-zinc-900 rounded-[2.5rem] p-8 border border-stone-100 dark:border-white/5 space-y-8 animate-in fade-in zoom-in-95 duration-300">
            <div className="space-y-1 text-center md:text-left">
                <h3 className="text-2xl font-serif text-luxury-black dark:text-white italic">Share Your Experience</h3>
                <p className="text-[10px] text-stone-400 uppercase tracking-widest font-bold">Reviewing: {productName}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-4">
                    <div className="space-y-2">
                        <label className="text-[10px] font-black uppercase tracking-[.2em] text-stone-500">Your Rating</label>
                        <div className="flex items-center gap-4">
                            <StarRating rating={rating} onChange={setRating} size={32} />
                            <span className="text-sm font-serif text-gold italic">
                                {rating === 5 ? 'Excellent' : rating === 4 ? 'Very Good' : rating === 3 ? 'Good' : rating === 2 ? 'Fair' : 'Poor'}
                            </span>
                        </div>
                    </div>

                    <div className="space-y-2">
                        <label className="text-[10px] font-black uppercase tracking-[.2em] text-stone-500">Your Story</label>
                        <textarea
                            className="w-full h-32 bg-stone-50 dark:bg-white/[0.02] border border-stone-100 dark:border-white/5 rounded-2xl p-4 text-sm font-serif italic focus:outline-none focus:ring-1 focus:ring-gold/30 transition-all resize-none"
                            placeholder="Describe the scent, the longevity, or the compliments you received..."
                            value={content}
                            onChange={(e) => setContent(e.target.value)}
                            required
                        />
                    </div>
                </div>

                <div className="space-y-4">
                    <label className="text-[10px] font-black uppercase tracking-[.2em] text-stone-500 flex justify-between">
                        Visual Memories
                        <span className="text-stone-400">{images.length}/{MAX_IMAGES}</span>
                    </label>

                    <div className="grid grid-cols-3 gap-3">
                        {images.map((img, idx) => (
                            <div key={idx} className="relative aspect-square rounded-2xl overflow-hidden border border-stone-100 dark:border-white/5 group">
                                <img src={img.url} alt="review" className="w-full h-full object-cover" />
                                <button
                                    type="button"
                                    onClick={() => removeImage(idx)}
                                    className="absolute top-1 right-1 bg-black/50 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                                >
                                    <X size={12} />
                                </button>
                            </div>
                        ))}

                        {images.length < MAX_IMAGES && (
                            <button
                                type="button"
                                onClick={() => fileInputRef.current?.click()}
                                className="aspect-square flex flex-col items-center justify-center border-2 border-dashed border-stone-200 dark:border-white/10 rounded-2xl hover:bg-stone-50 dark:hover:bg-white/5 hover:border-gold/30 transition-all group"
                            >
                                <ImageIcon className="text-stone-300 group-hover:text-gold transition-colors" size={24} />
                                <span className="text-[8px] mt-2 text-stone-400 uppercase font-black tracking-widest">Add Photo</span>
                            </button>
                        )}
                    </div>

                    <input
                        type="file"
                        ref={fileInputRef}
                        onChange={handleFileChange}
                        accept="image/*"
                        multiple
                        className="hidden"
                    />

                    <div className="p-3 rounded-xl bg-amber-50/50 dark:bg-amber-900/10 border border-amber-100/50 dark:border-amber-900/20 flex gap-2">
                        <AlertCircle size={14} className="text-amber-600 shrink-0" />
                        <p className="text-[9px] text-amber-700 dark:text-amber-500 leading-tight italic">
                            Help others by uploading photos of the bottle or the packaging. Max 5MB per image.
                        </p>
                    </div>
                </div>
            </div>

            <div className="flex justify-end gap-4 pt-4">
                {onCancel && (
                    <Button
                        type="button"

                        onClick={onCancel}
                        disabled={isSubmitting}
                        className="text-[10px] uppercase font-bold tracking-[.2em] text-stone-400 hover:text-luxury-black"
                    >
                        Cancel
                    </Button>
                )}
                <Button
                    type="submit"
                    disabled={isSubmitting || isUploading}
                    className="rounded-full bg-gold hover:bg-gold/90 text-white px-10 h-12 text-[10px] uppercase font-black tracking-[.2em] shadow-lg shadow-gold/20"
                >
                    {isSubmitting ? (
                        <>
                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                            Sending...
                        </>
                    ) : isUploading ? (
                        <>
                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                            Uploading...
                        </>
                    ) : (
                        "Submit Review"
                    )}
                </Button>
            </div>
        </form>
    );
};

export default ReviewForm;
