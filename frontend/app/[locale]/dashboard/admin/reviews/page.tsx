'use client';

import React, { useEffect, useState } from 'react';
import { reviewService, Review } from '@/services/review.service';
import {
    Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/table';
import {
    DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
    MoreHorizontal, Eye, EyeOff, Pin, Trash2, Flag,
    Star, MessageSquare, AlertCircle, CheckCircle2,
    Filter, Search, ArrowRight, ShieldAlert, Loader2,
} from 'lucide-react';
import { toast } from 'sonner';
import { format } from 'date-fns';
import StarRating from '@/components/review/star-rating';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Input } from '@/components/ui/input';

export default function AdminReviewsPage() {
    const [reviews, setReviews] = useState<Review[]>([]);
    const [reports, setReports] = useState<any[]>([]);
    const [total, setTotal] = useState(0);
    const [isLoading, setIsLoading] = useState(true);
    const [skip, setSkip] = useState(0);
    const [ratingFilter, setRatingFilter] = useState<string>('');
    const [searchProduct, setSearchProduct] = useState<string>('');

    const take = 10;

    const fetchReviews = async () => {
        setIsLoading(true);
        try {
            const data = await reviewService.adminList({
                skip,
                take,
                rating: ratingFilter ? parseInt(ratingFilter) : undefined
            });
            setReviews(data.items);
            setTotal(data.total);
        } catch (error) {
            toast.error("Failed to fetch reviews");
        } finally {
            setIsLoading(false);
        }
    };

    const fetchReports = async () => {
        try {
            const data = await reviewService.adminGetReports();
            setReports(data);
        } catch (error) {
            console.error("Failed to fetch reports", error);
        }
    };

    useEffect(() => {
        fetchReviews();
        fetchReports();
    }, [skip, ratingFilter]);

    const handleToggleHide = async (review: Review) => {
        try {
            if (review.isHidden) {
                await reviewService.adminShow(review.id);
                toast.success("Review is now visible to public");
            } else {
                await reviewService.adminHide(review.id);
                toast.success("Review has been hidden");
            }
            fetchReviews();
        } catch (error) {
            toast.error("Action failed");
        }
    };

    const handleTogglePin = async (review: Review) => {
        try {
            if (review.isPinned) {
                await reviewService.adminUnpin(review.id);
                toast.success("Review unpinned");
            } else {
                await reviewService.adminPin(review.id);
                toast.success("Review pinned to top");
            }
            fetchReviews();
        } catch (error) {
            toast.error("Action failed");
        }
    };

    const handleFlag = async (reviewId: string) => {
        try {
            await reviewService.adminFlag(reviewId);
            toast.success("Review flagged for investigation");
            fetchReviews();
        } catch (error) {
            toast.error("Action failed");
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to PERMANENTLY delete this review? This action cannot be undone.")) return;
        try {
            await reviewService.adminDelete(id);
            toast.success("Review permanently deleted");
            fetchReviews();
            fetchReports();
        } catch (error) {
            toast.error("Delete failed");
        }
    };

    return (
        <div className="p-10 space-y-10">
            <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                <div className="space-y-1">
                    <h1 className="text-4xl font-serif text-luxury-black dark:text-white">Review Moderation</h1>
                    <p className="text-[10px] text-stone-500 uppercase tracking-[.4em] font-black">Refining the voice of our community</p>
                </div>

                <div className="flex items-center gap-4 bg-white dark:bg-zinc-900 p-2 rounded-2xl border border-stone-100 dark:border-white/5">
                    <div className="text-right px-4 border-r border-stone-100 dark:border-white/5">
                        <p className="text-[8px] text-stone-400 uppercase font-black tracking-widest">Total Reviews</p>
                        <p className="text-xl font-serif text-gold leading-none">{total}</p>
                    </div>
                    <div className="text-right px-4">
                        <p className="text-[8px] text-stone-400 uppercase font-black tracking-widest">Pending Reports</p>
                        <p className="text-xl font-serif text-red-500 leading-none">{reports.length}</p>
                    </div>
                </div>
            </header>

            <Tabs defaultValue="all" className="space-y-8">
                <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                    <TabsList className="bg-stone-100 dark:bg-white/5 p-1 rounded-full h-12">
                        <TabsTrigger value="all" className="rounded-full px-8 text-[10px] uppercase font-black tracking-widest data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-800 shadow-none">
                            All Reviews
                        </TabsTrigger>
                        <TabsTrigger value="reports" className="rounded-full px-8 text-[10px] uppercase font-black tracking-widest data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-800 shadow-none relative">
                            Reports
                            {reports.length > 0 && (
                                <span className="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[8px] text-white">
                                    {reports.length}
                                </span>
                            )}
                        </TabsTrigger>
                    </TabsList>

                    <div className="flex items-center gap-3 w-full md:w-auto">
                        <div className="relative flex-1 md:w-64 group">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3 w-3 text-stone-400 group-focus-within:text-gold transition-colors" />
                            <Input
                                placeholder="Search products..."
                                className="pl-10 h-10 rounded-full bg-white dark:bg-zinc-900 border-stone-100 dark:border-white/5 text-[10px] focus-visible:ring-gold/30"
                                value={searchProduct}
                                onChange={(e) => setSearchProduct(e.target.value)}
                            />
                        </div>
                        <select
                            className="h-10 px-4 rounded-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 text-[10px] uppercase font-black tracking-widest focus:outline-none focus:ring-1 focus:ring-gold/30"
                            value={ratingFilter}
                            onChange={(e) => setRatingFilter(e.target.value)}
                        >
                            <option value="">All Ratings</option>
                            <option value="5">5 Stars</option>
                            <option value="4">4 Stars</option>
                            <option value="3">3 Stars</option>
                            <option value="2">2 Stars</option>
                            <option value="1">1 Star</option>
                        </select>
                    </div>
                </div>

                <TabsContent value="all" className="m-0 border-none">
                    <div className="glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-100 dark:border-white/5 overflow-hidden">
                        <Table>
                            <TableHeader>
                                <TableRow className="hover:bg-transparent border-stone-100 dark:border-white/5">
                                    <TableHead className="pl-8 text-[10px] uppercase tracking-widest font-black py-6">Customer & Product</TableHead>
                                    <TableHead className="text-[10px] uppercase tracking-widest font-black py-6">Impression</TableHead>
                                    <TableHead className="text-[10px] uppercase tracking-widest font-black py-6">Feedback</TableHead>
                                    <TableHead className="text-[10px] uppercase tracking-widest font-black py-6">Status</TableHead>
                                    <TableHead className="pr-8 text-right text-[10px] uppercase tracking-widest font-black py-6">Action</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {isLoading ? (
                                    <TableRow>
                                        <TableCell colSpan={5} className="h-64 text-center">
                                            <Loader2 className="h-8 w-8 animate-spin mx-auto text-gold mb-4" />
                                            <p className="text-[10px] uppercase tracking-widest font-black text-stone-400">Curating reviews...</p>
                                        </TableCell>
                                    </TableRow>
                                ) : reviews.length === 0 ? (
                                    <TableRow>
                                        <TableCell colSpan={5} className="h-64 text-center">
                                            <p className="font-serif italic text-stone-400 text-lg">Silence in the gallery.</p>
                                        </TableCell>
                                    </TableRow>
                                ) : (
                                    reviews.map((review: any) => (
                                        <TableRow key={review.id} className="border-stone-100 dark:border-white/5 group">
                                            <TableCell className="pl-8 py-6">
                                                <div className="space-y-1">
                                                    <p className="text-sm font-bold text-luxury-black dark:text-white line-clamp-1">{review.product?.name}</p>
                                                    <p className="text-[9px] text-stone-400 uppercase font-medium tracking-wider">
                                                        {review.user?.fullName} • {format(new Date(review.createdAt), 'MMM dd, yyyy')}
                                                    </p>
                                                </div>
                                            </TableCell>
                                            <TableCell className="py-6">
                                                <div className="flex flex-col gap-1">
                                                    <StarRating rating={review.rating} readOnly size={10} />
                                                    <span className="text-[8px] font-black uppercase text-gold">Score: {review.rating}/5</span>
                                                </div>
                                            </TableCell>
                                            <TableCell className="py-6">
                                                <div className="max-w-md space-y-2">
                                                    <p className="text-xs text-stone-600 dark:text-stone-400 line-clamp-2 italic font-serif">
                                                        "{review.content || 'No commentary provided'}"
                                                    </p>
                                                    {review.images.length > 0 && (
                                                        <div className="flex gap-1">
                                                            {review.images.map((img: any, i: number) => (
                                                                <div key={i} className="w-8 h-8 rounded-lg overflow-hidden border border-stone-100 dark:border-white/5">
                                                                    <img src={img.imageUrl} className="w-full h-full object-cover" alt="" />
                                                                </div>
                                                            ))}
                                                        </div>
                                                    )}
                                                </div>
                                            </TableCell>
                                            <TableCell className="py-6">
                                                <div className="flex flex-wrap gap-2">
                                                    {review.isHidden && <Badge className="bg-stone-500/10 text-stone-600 border-none rounded-full px-3 text-[8px] uppercase">Hidden</Badge>}
                                                    {review.isPinned && <Badge className="bg-gold/10 text-gold border-none rounded-full px-3 text-[8px] uppercase">Pinned</Badge>}
                                                    {review.isVerified && <Badge className="bg-emerald-500/10 text-emerald-600 border-none rounded-full px-3 text-[8px] uppercase">Verified</Badge>}
                                                    {review.flagged && <Badge className="bg-red-500/10 text-red-600 border-none rounded-full px-3 text-[8px] uppercase">Flagged</Badge>}
                                                </div>
                                            </TableCell>
                                            <TableCell className="pr-8 py-6 text-right">
                                                <DropdownMenu>
                                                    <DropdownMenuTrigger asChild>
                                                        <Button className="h-10 w-10 p-0 rounded-full hover:bg-stone-100 dark:hover:bg-white/5 transition-colors">
                                                            <MoreHorizontal className="h-4 w-4" />
                                                        </Button>
                                                    </DropdownMenuTrigger>
                                                    <DropdownMenuContent align="end" className="w-56 rounded-2xl p-2 shadow-2xl border-stone-100 dark:border-white/5">
                                                        <DropdownMenuItem onClick={() => handleToggleHide(review)} className="rounded-xl text-[10px] uppercase font-black tracking-widest py-3">
                                                            {review.isHidden ? <><Eye className="mr-3 h-4 w-4" /> Unhide Review</> : <><EyeOff className="mr-3 h-4 w-4" /> Hide from Public</>}
                                                        </DropdownMenuItem>
                                                        <DropdownMenuItem onClick={() => handleTogglePin(review)} className="rounded-xl text-[10px] uppercase font-black tracking-widest py-3">
                                                            {review.isPinned ? <><Pin className="mr-3 h-4 w-4 fill-current text-gold" /> Unpin from Top</> : <><Pin className="mr-3 h-4 w-4 text-gold" /> Pin to Highlights</>}
                                                        </DropdownMenuItem>
                                                        {!review.flagged && (
                                                            <DropdownMenuItem onClick={() => handleFlag(review.id)} className="rounded-xl text-[10px] uppercase font-black tracking-widest py-3 text-red-500">
                                                                <Flag className="mr-3 h-4 w-4" /> Flag as Suspicious
                                                            </DropdownMenuItem>
                                                        )}
                                                        <div className="h-px bg-stone-100 dark:bg-white/5 my-1" />
                                                        <DropdownMenuItem onClick={() => handleDelete(review.id)} className="rounded-xl text-[10px] uppercase font-black tracking-widest py-3 text-red-600 bg-red-50 dark:bg-red-500/10">
                                                            <Trash2 className="mr-3 h-4 w-4" /> Purge Review
                                                        </DropdownMenuItem>
                                                    </DropdownMenuContent>
                                                </DropdownMenu>
                                            </TableCell>
                                        </TableRow>
                                    ))
                                )}
                            </TableBody>
                        </Table>

                        <div className="p-6 border-t border-stone-100 dark:border-white/5 flex items-center justify-between">
                            <p className="text-[10px] text-stone-400 uppercase tracking-[.2em] font-black">
                                Displaying {skip + 1}-{Math.min(skip + take, total)} of {total} essence voices
                            </p>
                            <div className="flex gap-4">
                                <Button
                                    variant="outline"
                                    className="rounded-full px-8 text-[10px] uppercase font-black tracking-widest h-10 border-stone-100 dark:border-white/5"
                                    disabled={skip === 0}
                                    onClick={() => setSkip(Math.max(0, skip - take))}
                                >
                                    Previous
                                </Button>
                                <Button
                                    variant="outline"
                                    className="rounded-full px-8 text-[10px] uppercase font-black tracking-widest h-10 border-stone-100 dark:border-white/5"
                                    disabled={skip + take >= total}
                                    onClick={() => setSkip(skip + take)}
                                >
                                    Next
                                </Button>
                            </div>
                        </div>
                    </div>
                </TabsContent>

                <TabsContent value="reports" className="m-0 border-none">
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                        {reports.length === 0 ? (
                            <div className="col-span-full py-32 text-center glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-100 dark:border-white/5">
                                <CheckCircle2 className="mx-auto h-12 w-12 text-emerald-500 mb-6" />
                                <h3 className="text-2xl font-serif text-luxury-black dark:text-white mb-2">Purity Maintained</h3>
                                <p className="text-[10px] text-stone-400 uppercase tracking-widest font-black">No reports pending investigation</p>
                            </div>
                        ) : (
                            reports.map((report: any) => (
                                <div key={report.id} className="glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-100 dark:border-white/5 p-8 space-y-6 flex flex-col group hover:border-gold/30 transition-all duration-500">
                                    <header className="flex justify-between items-start">
                                        <div className="flex items-center gap-2 text-red-500">
                                            <ShieldAlert size={16} />
                                            <span className="text-[10px] uppercase tracking-widest font-black">Reported Concern</span>
                                        </div>
                                        <span className="text-[10px] text-stone-400 font-bold">{format(new Date(report.createdAt), 'MMM dd')}</span>
                                    </header>

                                    <div className="space-y-4 flex-1">
                                        <div className="p-4 rounded-2xl bg-red-50/50 dark:bg-red-500/5 border border-red-100/50 dark:border-red-900/10">
                                            <p className="text-[10px] uppercase tracking-widest font-black text-red-600 mb-2">Reason</p>
                                            <p className="text-sm italic font-serif text-stone-700 dark:text-stone-300">"{report.reason}"</p>
                                        </div>

                                        <div className="space-y-2">
                                            <p className="text-[8px] uppercase tracking-widest font-black text-stone-400">On Review By {report.review?.user?.fullName}</p>
                                            <p className="text-xs text-luxury-black dark:text-white line-clamp-3 italic font-serif border-l-2 border-stone-100 dark:border-white/5 pl-4">
                                                "{report.review?.content}"
                                            </p>
                                        </div>
                                    </div>

                                    <footer className="pt-6 border-t border-stone-100 dark:border-white/5 flex gap-3">
                                        <Button
                                            variant="outline"
                                            className="flex-1 rounded-full text-[10px] uppercase font-black tracking-widest border-stone-100 dark:border-white/5 hover:bg-stone-50"
                                            onClick={() => handleToggleHide(report.review)}
                                        >
                                            {report.review?.isHidden ? 'Show Review' : 'Hide Review'}
                                        </Button>
                                        <Button
                                            className="flex-1 rounded-full bg-red-600 hover:bg-red-700 text-white text-[10px] uppercase font-black tracking-widest shadow-lg shadow-red-500/20"
                                            onClick={() => handleDelete(report.reviewId)}
                                        >
                                            Purge
                                        </Button>
                                    </footer>
                                </div>
                            ))
                        )}
                    </div>
                </TabsContent>
            </Tabs>
        </div>
    );
}
