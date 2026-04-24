import { useMemo } from "react";
import { useLocation, useNavigate, useSearchParams } from "react-router-dom";
import { CheckCircle, XCircle, Package } from "lucide-react";

export default function PaymentResultPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const [searchParams] = useSearchParams();

  const rawStatus = (searchParams.get("status") || "").toUpperCase();
  const inferredStatus = location.pathname.includes("/payment/payos/cancel")
    ? "FAILED"
    : location.pathname.includes("/payment/payos/return")
      ? "SUCCESS"
      : "";
  const status = rawStatus || inferredStatus;
  const orderId = searchParams.get("orderId");
  const isSuccess = status === "PAID" || status === "SUCCESS" || status === "00";

  const title = useMemo(() => {
    if (isSuccess) return "Thanh toán thành công! 🎉";
    if (status) return "Thanh toán chưa hoàn tất";
    return "Kết quả thanh toán";
  }, [isSuccess, status]);

  const message = useMemo(() => {
    if (isSuccess) return "Đơn hàng của bạn đã được ghi nhận. Cảm ơn bạn đã tin tưởng PerfumeGPT!";
    if (status) return "Giao dịch bị huỷ hoặc chưa hoàn thành. Bạn có thể thử lại hoặc kiểm tra trong lịch sử đơn hàng.";
    return "Vui lòng kiểm tra lại thông tin đơn hàng trong mục lịch sử đơn.";
  }, [isSuccess, status]);

  return (
    <div
      className="min-h-full flex flex-col items-center justify-center px-6"
      style={{ background: '#FAF8F5' }}
    >
      {/* Result card */}
      <div
        className="w-full max-w-sm rounded-3xl p-8 text-center"
        style={{
          background: '#FFFFFF',
          boxShadow: '0 8px 32px rgba(0,0,0,0.1)',
          border: '1px solid rgba(0,0,0,0.06)',
        }}
      >
        {/* Icon */}
        <div className="flex justify-center mb-5">
          {isSuccess ? (
            <div
              className="w-20 h-20 rounded-full flex items-center justify-center"
              style={{
                background: 'rgba(52,199,89,0.1)',
                border: '2px solid rgba(52,199,89,0.2)',
              }}
            >
              <CheckCircle size={40} className="text-success" />
            </div>
          ) : (
            <div
              className="w-20 h-20 rounded-full flex items-center justify-center"
              style={{
                background: 'rgba(255,69,58,0.1)',
                border: '2px solid rgba(255,69,58,0.2)',
              }}
            >
              <XCircle size={40} className="text-danger" />
            </div>
          )}
        </div>

        {/* Text */}
        <h2
          className="text-lg font-bold mb-2"
          style={{
            fontFamily: "'Playfair Display', serif",
            color: isSuccess ? '#34C759' : '#FF453A',
          }}
        >
          {title}
        </h2>
        <p className="text-sm text-subtitle leading-relaxed mb-6">{message}</p>

        {/* Actions */}
        <div className="space-y-2">
          {orderId && (
            <button
              onClick={() => navigate(`/orders/${orderId}`)}
              className="w-full py-3.5 rounded-2xl font-bold text-sm active:scale-95 transition-transform flex items-center justify-center gap-2"
              style={{
                background: 'linear-gradient(135deg, #E2D1B3, #D4AF37)',
                color: '#1a1a2e',
                boxShadow: '0 4px 16px rgba(212,175,55,0.3)',
              }}
            >
              <Package size={16} />
              Xem chi tiết đơn hàng
            </button>
          )}

          <button
            onClick={() => navigate("/orders")}
            className="w-full py-3.5 rounded-2xl font-bold text-sm active:scale-95 transition-transform"
            style={{
              background: '#F0ECE6',
              color: '#1a1a2e',
              border: '1px solid rgba(212,175,55,0.2)',
            }}
          >
            Lịch sử đơn hàng
          </button>

          <button
            onClick={() => navigate("/")}
            className="w-full py-3 text-sm font-medium text-subtitle"
          >
            Về trang chủ
          </button>
        </div>
      </div>
    </div>
  );
}
