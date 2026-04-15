import { Sparkles, ThumbsUp, MessageCircle } from "lucide-react";
import { useEffect, useState } from "react";
import axiosClient from "@/services/axiosClient";

interface AiReviewSummaryProps {
  productId: string | number;
}

export default function AiReviewSummary({ productId }: AiReviewSummaryProps) {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const [showSkeleton, setShowSkeleton] = useState(false);

  useEffect(() => {
    // Only show skeleton if API is still loading after 500ms to avoid flash
    const t = setTimeout(() => { if (loading) setShowSkeleton(true); }, 500);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
     const fetchSummary = async () => {
       try {
         const res = await axiosClient.get(`/reviews/product/${productId}/summary`);
         const info = res as any;
         if (info && info.summary) {
           setData(info);
         }
       } catch (err) {
         console.warn("No AI summary available");
       } finally {
         setLoading(false);
         setShowSkeleton(false);
       }
     };
     fetchSummary();
  }, [productId]);

  if (loading && showSkeleton) return (
     <div className="bg-primary/5 rounded-xl p-4 m-4 border border-primary/20 animate-pulse">
        <div className="h-4 bg-primary/20 w-1/3 rounded mb-4"></div>
        <div className="h-3 bg-gray-200 w-full rounded mb-2"></div>
        <div className="h-3 bg-gray-200 w-full rounded mb-2"></div>
        <div className="h-3 bg-gray-200 w-2/3 rounded"></div>
     </div>
  );

  if (!data || !data.summary) return null; // Hide if no data

  return (
    <div className="bg-primary/5 rounded-xl p-4 m-4 border border-primary/20">
      <div className="flex items-center gap-2 mb-3 text-primary font-semibold">
        <Sparkles size={18} />
        <span>AI Tổng Hợp Đánh Giá</span>
      </div>
      
      <p className="text-[13px] text-gray-700 leading-relaxed mb-4">
        {data.summary}
      </p>

      <div className="space-y-2">
        {data.pros && data.pros.length > 0 && (
          <div className="flex gap-2 text-[13px] items-start">
            <ThumbsUp size={14} className="text-green-600 mt-0.5 flex-shrink-0" />
            <div>
              <span className="font-semibold text-gray-800">Điểm cộng: </span>
              <span className="text-gray-600">{Array.isArray(data.pros) ? data.pros.join(", ") : data.pros}</span>
            </div>
          </div>
        )}
        
        {data.cons && data.cons.length > 0 && (
          <div className="flex gap-2 text-[13px] items-start">
            <MessageCircle size={14} className="text-red-500 mt-0.5 flex-shrink-0" />
            <div>
              <span className="font-semibold text-gray-800">Lưu ý: </span>
              <span className="text-gray-600">{Array.isArray(data.cons) ? data.cons.join(", ") : data.cons}</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
