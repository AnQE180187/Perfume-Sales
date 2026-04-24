import { useEffect, useState } from "react";
import axiosClient from "@/services/axiosClient";
import { Sparkles, Star, Barcode } from "lucide-react";
import { useNavigate } from "react-router-dom";

export default function Points() {
  const [loyaltyPoints, setLoyaltyPoints] = useState(0);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchLoyalty = async () => {
      try {
        const res: any = await axiosClient.get("/loyalty/status");
        setLoyaltyPoints(Number(res?.points || 0));
      } catch {
        setLoyaltyPoints(0);
      } finally {
        setLoading(false);
      }
    };
    fetchLoyalty();
  }, []);

  if (loading) {
    return (
      <div
        className="rounded-3xl p-5 animate-pulse"
        style={{ background: "#1a1a2e", height: "160px" }}
      />
    );
  }

  return (
    <div
      className="rounded-3xl overflow-hidden"
      style={{
        background: "linear-gradient(135deg, #1a1a2e 0%, #2d2d52 100%)",
        boxShadow: "0 8px 32px rgba(26,26,46,0.3)",
      }}
    >
      {/* Top row */}
      <div className="px-5 pt-5 pb-5 flex items-start justify-between">
        <div>
          <div className="text-2xs text-white/50 tracking-widest uppercase font-medium mb-1">
            PerfumeGPT Member
          </div>
          <div className="flex items-center gap-2">
            <div
              className="text-3xl font-black text-white"
              style={{ fontFamily: "'Playfair Display', serif" }}
            >
              {loyaltyPoints.toLocaleString()}
            </div>
            <div className="text-sm text-white/60 font-medium">điểm</div>
          </div>
        </div>

        {/* Member badge */}
        <div
          className="px-3 py-1.5 rounded-full flex items-center gap-1.5 text-xs font-bold"
          style={{
            background: `rgba(212,175,55,0.15)`,
            border: `1px solid rgba(212,175,55,0.3)`,
            color: "#D4AF37",
          }}
        >
          <Star size={10} fill="currentColor" />
          Member
        </div>
      </div>

      {/* Bottom actions */}
      <div
        className="flex"
        style={{ borderTop: "1px solid rgba(255,255,255,0.08)" }}
      >
        <button
          onClick={() => navigate("/profile/vouchers")}
          className="flex-1 py-3 flex items-center justify-center gap-2 text-xs font-semibold text-white/70 active:text-white transition-colors"
          style={{ borderRight: "1px solid rgba(255,255,255,0.08)" }}
        >
          <Sparkles size={13} className="text-gold" />
          Đổi voucher
        </button>
        <button
          onClick={() => navigate("/orders")}
          className="flex-1 py-3 flex items-center justify-center gap-2 text-xs font-semibold text-white/70 active:text-white transition-colors"
        >
          <Barcode size={13} className="text-gold" />
          Đơn hàng
        </button>
      </div>
    </div>
  );
}
