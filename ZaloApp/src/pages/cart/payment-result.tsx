import { useMemo } from "react";
import { useLocation, useNavigate, useSearchParams } from "react-router-dom";

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
    if (isSuccess) return "Thanh toán thành công";
    if (status) return "Thanh toán chưa hoàn tất";
    return "Kết quả thanh toán";
  }, [isSuccess, status]);

  const message = useMemo(() => {
    if (isSuccess) return "Đơn hàng của bạn đã được ghi nhận. Cảm ơn bạn đã mua sắm.";
    if (status) return "Bạn có thể kiểm tra lại trạng thái trong chi tiết đơn hàng.";
    return "Vui lòng kiểm tra lại thông tin đơn hàng trong mục lịch sử đơn.";
  }, [isSuccess, status]);

  return (
    <div className="min-h-full bg-section p-4 flex items-center justify-center">
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-black/5 max-w-sm w-full text-center">
        <div className={`text-lg font-bold ${isSuccess ? "text-green-600" : "text-primary"}`}>{title}</div>
        <p className="text-sm text-gray-600 mt-2">{message}</p>

        {orderId && (
          <button
            onClick={() => navigate(`/orders/${orderId}`)}
            className="w-full mt-4 py-2.5 rounded-lg bg-primary text-white font-semibold"
          >
            Xem chi tiết đơn hàng
          </button>
        )}

        <button
          onClick={() => navigate("/orders")}
          className="w-full mt-2 py-2.5 rounded-lg border border-primary/20 text-primary font-semibold"
        >
          Về lịch sử đơn hàng
        </button>
      </div>
    </div>
  );
}
