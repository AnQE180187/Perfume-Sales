import { useNavigate } from "react-router-dom";
import { MessageCircle, Sparkles } from "lucide-react";

export default function AiCta() {
  const navigate = useNavigate();

  return (
    <div className="px-4 pb-4">
      {/* Main AI Banner - Animated luxury card matching mobile */}
      <div
        onClick={() => navigate("/ai-chat")}
        className="relative w-full rounded-3xl overflow-hidden cursor-pointer active:scale-[0.98] transition-transform duration-200"
        style={{
          background: "linear-gradient(135deg, #1a1a2e 0%, #2d2d52 50%, #1a1a2e 100%)",
          boxShadow: "0 8px 32px rgba(26, 26, 46, 0.35), 0 0 0 1px rgba(212, 175, 55, 0.15)",
          minHeight: "160px",
        }}
      >
        {/* Animated gold glow orb */}
        <div
          className="absolute right-[-20px] top-[-20px] w-40 h-40 rounded-full animate-pulse-slow"
          style={{
            background: "radial-gradient(circle, rgba(212,175,55,0.25) 0%, transparent 70%)",
          }}
        />
        <div
          className="absolute left-[-20px] bottom-[-20px] w-32 h-32 rounded-full"
          style={{
            background: "radial-gradient(circle, rgba(212,175,55,0.12) 0%, transparent 70%)",
          }}
        />

        <div className="relative z-10 p-5 flex items-center gap-4">
          <div className="flex-1">
            {/* Gold label */}
            <div className="flex items-center gap-1.5 mb-2">
              <Sparkles size={12} className="text-gold" />
              <span className="text-2xs font-bold tracking-widest text-gold uppercase">
                AI Consultant
              </span>
            </div>
            <h2
              className="text-white text-lg font-bold leading-snug mb-2"
              style={{ fontFamily: "'Playfair Display', serif" }}
            >
              Tìm mùi hương{"\n"}hoàn hảo của bạn
            </h2>
            <p className="text-2xs text-white/60 leading-relaxed mb-3">
              Chat với trí tuệ nhân tạo để được tư vấn nước hoa phù hợp với phong cách riêng của bạn.
            </p>
            <div
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-bold uppercase tracking-wider"
              style={{
                background: "linear-gradient(135deg, #E2D1B3, #D4AF37)",
                color: "#1a1a2e",
              }}
            >
              <MessageCircle size={12} />
              Hỏi ngay
            </div>
          </div>

          {/* AI Avatar */}
          <div className="flex-shrink-0">
            <div
              className="w-20 h-20 rounded-full flex items-center justify-center animate-float"
              style={{
                background: "linear-gradient(135deg, rgba(212,175,55,0.2), rgba(212,175,55,0.05))",
                border: "2px solid rgba(212,175,55,0.4)",
                boxShadow: "0 0 24px rgba(212,175,55,0.2)",
              }}
            >
              <Sparkles size={36} className="text-gold" />
            </div>
          </div>
        </div>
      </div>

      {/* Secondary: AI Quiz shortcut */}
      <div
        onClick={() => navigate("/ai-quiz")}
        className="mt-3 w-full rounded-2xl p-4 cursor-pointer active:scale-[0.98] transition-transform duration-150 flex items-center gap-4"
        style={{
          background: "linear-gradient(135deg, #FAF8F5, #F5F1ED)",
          border: "1px solid rgba(212,175,55,0.25)",
          boxShadow: "0 2px 12px rgba(0,0,0,0.06)",
        }}
      >
        <div
          className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
          style={{
            background: "linear-gradient(135deg, #E2D1B3, #D4AF37)",
          }}
        >
          <Sparkles size={18} className="text-primary" />
        </div>
        <div className="flex-1">
          <div className="text-xs font-bold text-foreground">Scent DNA Quiz</div>
          <div className="text-2xs text-subtitle mt-0.5">5 câu hỏi · AI phân tích · Top 3 gợi ý</div>
        </div>
        <div className="text-gold">
          <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2.5">
            <path d="M6 4l4 4-4 4" />
          </svg>
        </div>
      </div>
    </div>
  );
}
