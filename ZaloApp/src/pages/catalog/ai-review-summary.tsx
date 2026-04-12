import { Sparkles, ThumbsUp, MessageCircle } from "lucide-react";

interface AiReviewSummaryProps {
  productId: string | number;
}

export default function AiReviewSummary({ productId }: AiReviewSummaryProps) {
  // Mock data for AI Summary. In real app, fetch from /reviews/summary
  const data = {
    summary: "Đa số người dùng đánh giá mùi hương rất nịnh mũi, có độ lưu hương tốt từ 6-8 tiếng trên da. Phù hợp cho những buổi tiệc đêm hoặc đi hẹn hò.",
    pros: ["Lưu hương lâu", "Thiết kế đẹp", "Mùi hương sang trọng"],
    cons: ["Có thể hơi nồng với tiết trời quá nóng"],
    sentiment: "POSITIVE",
  };

  return (
    <div className="bg-primary/5 rounded-xl p-4 m-4 border border-primary/20">
      <div className="flex items-center gap-2 mb-3 text-primary font-semibold">
        <Sparkles size={18} />
        <span>AI Tổng Hợp Đánh Giá</span>
      </div>
      
      <p className="text-sm text-gray-700 leading-relaxed mb-4">
        {data.summary}
      </p>

      <div className="space-y-2">
        <div className="flex gap-2 text-sm items-start">
          <ThumbsUp size={16} className="text-green-600 mt-0.5 flex-shrink-0" />
          <div>
            <span className="font-semibold text-gray-800">Điểm cộng: </span>
            <span className="text-gray-600">{data.pros.join(", ")}</span>
          </div>
        </div>
        
        <div className="flex gap-2 text-sm items-start">
          <MessageCircle size={16} className="text-red-500 mt-0.5 flex-shrink-0" />
          <div>
            <span className="font-semibold text-gray-800">Lưu ý: </span>
            <span className="text-gray-600">{data.cons.join(", ")}</span>
          </div>
        </div>
      </div>
    </div>
  );
}
