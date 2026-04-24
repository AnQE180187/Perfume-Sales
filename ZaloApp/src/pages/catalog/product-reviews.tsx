import { useState, useEffect } from "react";
import axiosClient from "@/services/axiosClient";
import { Star, User, MessageSquare } from "lucide-react";

interface ProductReviewsProps {
  productId: string | number;
}

export default function ProductReviews({ productId }: ProductReviewsProps) {
  const [reviews, setReviews] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchReviews = async () => {
      if (!productId) return;
      try {
        setLoading(true);
        const res: any = await axiosClient.get(`/reviews/product/${productId}?take=5`);
        const items = Array.isArray(res) ? res : (res?.items || res?.data || []);
        setReviews(items);
      } catch {
        // silently fail
      } finally {
        setLoading(false);
      }
    };
    fetchReviews();
  }, [productId]);

  if (loading) {
    return (
      <div className="px-4 pt-4 pb-2 mt-2" style={{ background: '#FFFFFF', borderTop: '1px solid rgba(0,0,0,0.04)' }}>
        <div className="h-5 w-36 bg-skeleton rounded-lg animate-pulse mb-4" />
        {[1, 2].map(i => (
          <div key={i} className="flex gap-3 mb-4 animate-pulse">
            <div className="w-8 h-8 rounded-full bg-skeleton flex-shrink-0" />
            <div className="flex-1 space-y-2">
              <div className="h-3 w-1/3 bg-skeleton rounded" />
              <div className="h-3 w-full bg-skeleton rounded" />
              <div className="h-3 w-2/3 bg-skeleton rounded" />
            </div>
          </div>
        ))}
      </div>
    );
  }

  if (reviews.length === 0) return null;

  return (
    <div className="px-4 pt-4 pb-2 mt-2" style={{ background: '#FFFFFF', borderTop: '1px solid rgba(0,0,0,0.04)' }}>
      {/* Header */}
      <div className="flex items-center gap-2 mb-4">
        <MessageSquare size={16} className="text-foreground" />
        <h3 className="text-sm font-bold text-foreground">Khách hàng đánh giá</h3>
        <div
          className="px-2 py-0.5 rounded-full text-2xs font-bold"
          style={{ background: 'rgba(212,175,55,0.1)', color: '#D4AF37' }}
        >
          {reviews.length}
        </div>
      </div>

      <div className="space-y-4">
        {reviews.map((review) => (
          <div
            key={review.id}
            className="pb-4"
            style={{ borderBottom: '1px solid rgba(0,0,0,0.04)' }}
          >
            <div className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-2">
                <div
                  className="w-8 h-8 rounded-2xl overflow-hidden flex items-center justify-center flex-shrink-0"
                  style={{ background: '#F0ECE6' }}
                >
                  {review.user?.avatarUrl ? (
                    <img src={review.user.avatarUrl} className="w-full h-full object-cover" />
                  ) : (
                    <User size={14} className="text-inactive" />
                  )}
                </div>
                <div>
                  <div className="text-xs font-semibold text-foreground">
                    {review.user?.fullName || "Khách hàng"}
                  </div>
                  <div className="text-2xs text-inactive">
                    {new Date(review.createdAt).toLocaleDateString('vi-VN')}
                  </div>
                </div>
              </div>

              {/* Stars */}
              <div className="flex gap-0.5">
                {[1, 2, 3, 4, 5].map((star) => (
                  <Star
                    key={star}
                    size={11}
                    className={star <= review.rating ? "fill-gold text-gold" : "text-skeleton"}
                  />
                ))}
              </div>
            </div>

            <p className="text-xs text-subtitle leading-relaxed">{review.content}</p>

            {/* Review images */}
            {review.images && review.images.length > 0 && (
              <div className="flex gap-2 mt-2 overflow-x-auto">
                {review.images.map((img: string, idx: number) => (
                  <img
                    key={idx}
                    src={img}
                    className="w-14 h-14 rounded-xl object-cover flex-shrink-0"
                    style={{ border: '1px solid rgba(0,0,0,0.06)' }}
                  />
                ))}
              </div>
            )}

            {/* Seller reply */}
            {review.sellerReply && (
              <div
                className="mt-2 rounded-xl p-3 text-xs"
                style={{ background: 'rgba(212,175,55,0.05)', border: '1px solid rgba(212,175,55,0.15)' }}
              >
                <strong className="text-gold block mb-1">PerfumeGPT phản hồi:</strong>
                <span className="text-subtitle">{review.sellerReply}</span>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
