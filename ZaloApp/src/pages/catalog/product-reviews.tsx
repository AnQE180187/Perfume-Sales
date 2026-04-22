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
      } catch (err) {
        console.warn("Could not load reviews", err);
      } finally {
        setLoading(false);
      }
    };
    fetchReviews();
  }, [productId]);

  if (loading) {
    return (
      <div className="bg-white px-4 py-6 mt-2 space-y-4 animate-pulse">
         <div className="h-5 w-32 bg-gray-200 rounded"></div>
         <div className="space-y-3">
            <div className="h-16 w-full bg-gray-100 rounded-xl"></div>
            <div className="h-16 w-full bg-gray-100 rounded-xl"></div>
         </div>
      </div>
    );
  }

  if (reviews.length === 0) return null;

  return (
    <div className="bg-white px-4 py-6 mt-2 border-t border-gray-100">
      <div className="flex items-center gap-2 mb-4">
        <MessageSquare size={20} className="text-gray-800" />
        <h3 className="font-bold text-gray-800">Khách hàng đánh giá</h3>
        <span className="bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full text-xs font-semibold">{reviews.length}</span>
      </div>

      <div className="space-y-4">
        {reviews.map((review) => (
          <div key={review.id} className="border-b border-gray-50 pb-4 last:border-0 last:pb-0">
            <div className="flex justify-between items-start mb-2">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center overflow-hidden">
                   {review.user?.avatarUrl ? (
                      <img src={review.user.avatarUrl} className="w-full h-full object-cover" />
                   ) : (
                      <User size={16} className="text-primary" />
                   )}
                </div>
                <div>
                  <div className="text-xs font-semibold text-gray-800">{review.user?.fullName || "Khách hàng"}</div>
                  <div className="text-[10px] text-gray-400">{new Date(review.createdAt).toLocaleDateString('vi-VN')}</div>
                </div>
              </div>
              <div className="flex gap-0.5 mt-1">
                {[1, 2, 3, 4, 5].map((star) => (
                  <Star 
                    key={star} 
                    size={12} 
                    className={star <= review.rating ? "fill-warning text-warning" : "text-gray-200"} 
                  />
                ))}
              </div>
            </div>
            
            <p className="text-sm text-gray-700 leading-relaxed">
              {review.content}
            </p>

            {review.images && review.images.length > 0 && (
              <div className="flex gap-2 mt-3 overflow-x-auto pb-1">
                 {review.images.map((img: string, idx: number) => (
                    <img key={idx} src={img} className="w-16 h-16 rounded-lg object-cover border border-gray-100 flex-shrink-0" />
                 ))}
              </div>
            )}
            
            {review.sellerReply && (
               <div className="mt-3 bg-gray-50 rounded-xl p-3 text-xs border border-gray-100">
                  <strong className="text-primary block mb-1">Hệ thống phản hồi:</strong>
                  <span className="text-gray-600">{review.sellerReply}</span>
               </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
