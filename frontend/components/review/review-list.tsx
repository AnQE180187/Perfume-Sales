'use client';

import React, { useEffect, useState, useMemo } from 'react';
import { Review, reviewService } from '@/services/review.service';
import StarRating from './star-rating';
import { ThumbsUp, Flag, CheckCircle2, Loader2, Filter, SortAsc, ChevronDown } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { format } from 'date-fns';
import { toast } from 'sonner';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Progress } from '@/components/ui/progress';

interface ReviewListProps {
    productId: string;
}

const ReviewList: React.FC<ReviewListProps> = ({ productId }) => {
    const [reviews, setReviews] = useState<Review[]>([]);
    const [total, setTotal] = useState(0);
    const [isLoading, setIsLoading] = useState(true);
    const [skip, setSkip] = useState(0);
    const [ratingFilter, setRatingFilter] = useState<number | null>(null);
    const [sortBy, setSortBy] = useState<'newest' | 'highest' | 'lowest' | 'helpful'>('newest');
    
    const take = 10;

    const fetchReviews = async () => {
        setIsLoading(true);
        try {
            const res = await reviewService.getByProduct(productId, skip, take);
            setReviews(res.items);
            setTotal(res.total);
        } catch (error) {
            console.error("Failed to fetch reviews", error);
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        fetchReviews();
    }, [productId, skip]);

    // Statistics (Mocked based on current reviews for demo, ideally from backend)
    const stats = useMemo(() => {
        if (reviews.length === 0) return { avg: 0, distribution: [0, 0, 0, 0, 0] };
        const distribution = [0, 0, 0, 0, 0];
        let sum = 0;
        reviews.forEach(r => {
            sum += r.rating;
            distribution[r.rating - 1]++;
        });
        return {
            avg: (sum / reviews.length).toFixed(1),
            distribution: distribution.reverse() // 5 to 1
        };
    }, [reviews]);

    const handleReact = async (reviewId: string) => {
        try {
            await reviewService.react(reviewId, 'HELPFUL');
            toast.success("Marked as helpful");
            setReviews(prev => prev.map(r => 
                r.id === reviewId 
                ? { ...r, _count: { reactions: (r._count?.reactions || 0) + 1 } } 
                : r
            ));
        } catch (error: any) {
            toast.error(error.message || "Failed to react");
        }
    };

    const handleReport = async (reviewId: string) => {
        const reason = window.prompt("Reason for reporting:");
        if (!reason) return;
        
        try {
            await reviewService.report(reviewId, reason);
            toast.success("Report submitted");
        } catch (error: any) {
            toast.error(error.message || "Failed to report");
        }
    };

    const filteredReviews = useMemo(() => {
        let result = [...reviews];
        if (ratingFilter) {
            result = result.filter(r => r.rating === ratingFilter);
        }
        
        switch (sortBy) {
            case 'highest': result.sort((a, b) => b.rating - a.rating); break;
            case 'lowest': result.sort((a, b) => a.rating - b.rating); break;
            case 'helpful': result.sort((a, b) => (b._count?.reactions || 0) - (a._count?.reactions || 0)); break;
            default: result.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        }
        return result;
    }, [reviews, ratingFilter, sortBy]);

    if (isLoading && reviews.length === 0) {
        return (
            <div className="flex justify-center py-20">
                <Loader2 className="animate-spin h-10 w-10 text-gold" />
            </div>
        );
    }

    return (
        <div className="space-y-12">
            {/* Header & Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-12 items-center border-b border-stone-100 dark:border-white/5 pb-12">
                <div className="text-center md:text-left space-y-2">
                    <h2 className="text-4xl font-serif text-luxury-black dark:text-white">Customer Reviews</h2>
                    <div className="flex items-center justify-center md:justify-start gap-4">
                        <span className="text-5xl font-serif text-gold">{stats.avg}</span>
                        <div className="space-y-1">
                            <StarRating rating={Number(stats.avg)} readOnly size={18} />
                            <p className="text-[10px] text-stone-400 uppercase tracking-widest font-bold">Based on {total} reviews</p>
                        </div>
                    </div>
                </div>

                <div className="md:col-span-2 space-y-2 max-w-md mx-auto md:ml-auto w-full">
                    {stats.distribution.map((count, i) => {
                        const starNum = 5 - i;
                        const percentage = reviews.length > 0 ? (count / reviews.length) * 100 : 0;
                        return (
                            <div key={starNum} className="flex items-center gap-4 text-xs">
                                <span className="w-12 text-stone-400 font-bold uppercase tracking-tighter">{starNum} Stars</span>
                                <Progress value={percentage} className="h-1.5 bg-stone-100 dark:bg-white/5" indicatorClassName="bg-gold" />
                                <span className="w-8 text-right text-stone-400 font-medium">{Math.round(percentage)}%</span>
                            </div>
                        );
                    })}
                </div>
            </div>

            {/* Filters */}
            <div className="flex flex-wrap items-center justify-between gap-4">
                <div className="flex items-center gap-2">
                    <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                            <Button variant="outline" size="sm" className="rounded-full border-stone-200 dark:border-white/10 text-[10px] uppercase font-bold tracking-widest">
                                <Filter size={14} className="mr-2" />
                                {ratingFilter ? `${ratingFilter} Stars` : 'All Ratings'}
                                <ChevronDown size={14} className="ml-2 opacity-50" />
                            </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent className="w-40 rounded-2xl p-2 border-stone-100 dark:border-white/5 shadow-2xl">
                            <DropdownMenuItem onClick={() => setRatingFilter(null)} className="rounded-xl text-[10px] uppercase font-bold tracking-widest">All Ratings</DropdownMenuItem>
                            {[5, 4, 3, 2, 1].map(num => (
                                <DropdownMenuItem key={num} onClick={() => setRatingFilter(num)} className="rounded-xl text-[10px] uppercase font-bold tracking-widest">
                                    {num} Stars
                                </DropdownMenuItem>
                            ))}
                        </DropdownMenuContent>
                    </DropdownMenu>

                    <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                            <Button variant="outline" size="sm" className="rounded-full border-stone-200 dark:border-white/10 text-[10px] uppercase font-bold tracking-widest">
                                <SortAsc size={14} className="mr-2" />
                                Sort: {sortBy.charAt(0).toUpperCase() + sortBy.slice(1)}
                                <ChevronDown size={14} className="ml-2 opacity-50" />
                            </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent className="w-48 rounded-2xl p-2 border-stone-100 dark:border-white/5 shadow-2xl">
                            <DropdownMenuItem onClick={() => setSortBy('newest')} className="rounded-xl text-[10px] uppercase font-bold tracking-widest">Newest First</DropdownMenuItem>
                            <DropdownMenuItem onClick={() => setSortBy('highest')} className="rounded-xl text-[10px] uppercase font-bold tracking-widest">Highest Rated</DropdownMenuItem>
                            <DropdownMenuItem onClick={() => setSortBy('lowest')} className="rounded-xl text-[10px] uppercase font-bold tracking-widest">Lowest Rated</DropdownMenuItem>
                            <DropdownMenuItem onClick={() => setSortBy('helpful')} className="rounded-xl text-[10px] uppercase font-bold tracking-widest">Most Helpful</DropdownMenuItem>
                        </DropdownMenuContent>
                    </DropdownMenu>
                </div>
                
                {ratingFilter && (
                    <Button 
                        variant="ghost" 
                        size="sm" 
                        onClick={() => setRatingFilter(null)}
                        className="text-[10px] uppercase font-bold tracking-widest text-stone-400 hover:text-gold"
                    >
                        Clear Filters
                    </Button>
                )}
            </div>

            {/* List */}
            <div className="space-y-10">
                {filteredReviews.length === 0 ? (
                    <div className="text-center py-20 border border-dashed border-stone-200 dark:border-white/10 rounded-[2rem] bg-stone-50/50 dark:bg-white/[0.02]">
                        <p className="text-stone-400 font-serif italic text-lg">No reviews matching your criteria.</p>
                    </div>
                ) : (
                    filteredReviews.map((review) => (
                        <div key={review.id} className="group animate-in fade-in slide-in-from-bottom-4 duration-500">
                            <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                                <div className="space-y-4">
                                    <div className="flex items-center gap-4">
                                        <div className="w-12 h-12 rounded-full bg-stone-100 dark:bg-white/5 border border-stone-200 dark:border-white/10 flex items-center justify-center font-serif text-lg text-gold overflow-hidden">
                                            {review.user.avatarUrl ? (
                                                <img src={review.user.avatarUrl} alt={review.user.fullName} className="w-full h-full object-cover" />
                                            ) : (
                                                review.user.fullName?.[0] || 'U'
                                            )}
                                        </div>
                                        <div>
                                            <p className="font-bold text-luxury-black dark:text-white leading-tight">
                                                {review.user.fullName || 'Anonymous User'}
                                            </p>
                                            {review.isVerified && (
                                                <p className="text-[8px] text-emerald-500 uppercase tracking-widest font-black flex items-center gap-1 mt-1">
                                                    <CheckCircle2 size={10} /> Verified Customer
                                                </p>
                                            )}
                                        </div>
                                    </div>
                                    <p className="text-[10px] text-stone-400 uppercase tracking-widest font-bold">
                                        {format(new Date(review.createdAt), 'MMMM d, yyyy')}
                                    </p>
                                </div>

                                <div className="md:col-span-3 space-y-4">
                                    <StarRating rating={review.rating} readOnly size={14} />
                                    
                                    {review.content && (
                                        <p className="text-stone-600 dark:text-stone-300 leading-relaxed font-serif text-lg italic">
                                            "{review.content}"
                                        </p>
                                    )}

                                    {review.images.length > 0 && (
                                        <div className="flex flex-wrap gap-3 pt-2">
                                            {review.images.map((img) => (
                                                <div key={img.id} className="relative w-24 h-24 rounded-2xl overflow-hidden border border-stone-100 dark:border-white/5 group-hover:border-gold/30 transition-colors cursor-zoom-in" onClick={() => window.open(img.imageUrl, '_blank')}>
                                                    <img
                                                        src={img.imageUrl}
                                                        alt="review"
                                                        className="w-full h-full object-cover hover:scale-110 transition-transform duration-500"
                                                    />
                                                </div>
                                            ))}
                                        </div>
                                    )}

                                    <div className="flex items-center gap-6 pt-4 border-t border-stone-100 dark:border-white/5">
                                        <button
                                            onClick={() => handleReact(review.id)}
                                            className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-stone-400 hover:text-gold transition-colors"
                                        >
                                            <ThumbsUp size={14} className={review._count?.reactions ? 'fill-gold text-gold' : ''} />
                                            Helpful ({review._count?.reactions || 0})
                                        </button>
                                        <button 
                                            onClick={() => handleReport(review.id)}
                                            className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-stone-400 hover:text-red-500 transition-colors opacity-0 group-hover:opacity-100"
                                        >
                                            <Flag size={14} />
                                            Report
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))
                )}
            </div>

            {/* Pagination */}
            {total > take && (
                <div className="flex items-center justify-between pt-12 border-t border-stone-100 dark:border-white/5">
                    <p className="text-[10px] text-stone-400 uppercase tracking-widest font-bold">
                        Showing {skip + 1}-{Math.min(skip + take, total)} of {total}
                    </p>
                    <div className="flex gap-4">
                        <Button
                            variant="outline"
                            size="sm"
                            className="rounded-full px-6 text-[10px] uppercase font-bold tracking-widest"
                            disabled={skip === 0}
                            onClick={() => setSkip(Math.max(0, skip - take))}
                        >
                            Previous
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            className="rounded-full px-6 text-[10px] uppercase font-bold tracking-widest"
                            disabled={skip + take >= total}
                            onClick={() => setSkip(skip + take)}
                        >
                            Next
                        </Button>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ReviewList;
