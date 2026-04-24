import { useState, useEffect } from "react";
import axiosClient from "@/services/axiosClient";
import { Sparkles, ThumbsUp, ThumbsDown } from "lucide-react";

interface AiReviewSummaryProps {
  productId: string | number;
}

export default function AiReviewSummary({ productId }: AiReviewSummaryProps) {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [showSkeleton, setShowSkeleton] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => { if (loading) setShowSkeleton(true); }, 500);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    const fetchSummary = async () => {
      try {
        const res = await axiosClient.get(`/reviews/product/${productId}/summary`);
        const info = res as any;
        if (info?.summary) setData(info);
      } catch {
        // No summary available
      } finally {
        setLoading(false);
        setShowSkeleton(false);
      }
    };
    fetchSummary();
  }, [productId]);

  if (loading && showSkeleton) {
    return (
      <div className="mx-4 mt-3 rounded-2xl p-4 animate-pulse"
        style={{ background: 'rgba(212,175,55,0.06)', border: '1px solid rgba(212,175,55,0.15)' }}>
        <div className="h-4 w-1/3 rounded-lg bg-skeleton mb-3" />
        <div className="space-y-2">
          <div className="h-3 w-full rounded-lg bg-skeleton" />
          <div className="h-3 w-full rounded-lg bg-skeleton" />
          <div className="h-3 w-2/3 rounded-lg bg-skeleton" />
        </div>
      </div>
    );
  }

  if (!data?.summary) return null;

  return (
    <div
      className="mx-4 mt-3 rounded-2xl p-4"
      style={{
        background: 'rgba(212,175,55,0.05)',
        border: '1px solid rgba(212,175,55,0.2)',
      }}
    >
      <div className="flex items-center gap-2 mb-3">
        <div
          className="w-7 h-7 rounded-xl flex items-center justify-center flex-shrink-0"
          style={{ background: 'linear-gradient(135deg, #E2D1B3, #D4AF37)' }}
        >
          <Sparkles size={13} className="text-primary" />
        </div>
        <span className="text-sm font-bold text-foreground">AI Tổng Hợp Đánh Giá</span>
      </div>

      <p className="text-xs text-subtitle leading-relaxed mb-3">{data.summary}</p>

      <div className="space-y-2">
        {data.pros && data.pros.length > 0 && (
          <div className="flex gap-2 items-start">
            <div className="w-5 h-5 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5"
              style={{ background: 'rgba(52,199,89,0.1)' }}>
              <ThumbsUp size={10} className="text-success" />
            </div>
            <div className="text-xs text-foreground leading-relaxed">
              <span className="font-semibold">Điểm cộng: </span>
              <span className="text-subtitle">{Array.isArray(data.pros) ? data.pros.join(", ") : data.pros}</span>
            </div>
          </div>
        )}

        {data.cons && data.cons.length > 0 && (
          <div className="flex gap-2 items-start">
            <div className="w-5 h-5 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5"
              style={{ background: 'rgba(255,69,58,0.1)' }}>
              <ThumbsDown size={10} className="text-danger" />
            </div>
            <div className="text-xs text-foreground leading-relaxed">
              <span className="font-semibold">Lưu ý: </span>
              <span className="text-subtitle">{Array.isArray(data.cons) ? data.cons.join(", ") : data.cons}</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
