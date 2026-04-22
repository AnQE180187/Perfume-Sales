import { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import axiosClient from "@/services/axiosClient";
import toast from "react-hot-toast";

const ORDER_STATUS_LABEL: Record<string, string> = {
  PENDING: "Chờ xác nhận",
  CONFIRMED: "Đã xác nhận",
  PROCESSING: "Đang xử lý",
  SHIPPED: "Đang giao",
  COMPLETED: "Hoàn tất",
  CANCELLED: "Đã hủy",
};

const PAYMENT_STATUS_LABEL: Record<string, string> = {
  PENDING: "Chưa thanh toán",
  PAID: "Đã thanh toán",
  FAILED: "Thanh toán lỗi",
  REFUNDED: "Đã hoàn tiền",
  PARTIALLY_REFUNDED: "Hoàn tiền một phần",
};

export default function OrderDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState(false);
  const [syncingPayment, setSyncingPayment] = useState(false);

  const canCancel = useMemo(
    () => ["PENDING", "CONFIRMED", "PROCESSING"].includes(order?.status),
    [order?.status]
  );
  const canRequestReturn = useMemo(
    () => ["SHIPPED", "COMPLETED"].includes(order?.status),
    [order?.status]
  );
  const canRepay = useMemo(
    () => order?.paymentStatus === "PENDING" && order?.status !== "CANCELLED",
    [order?.paymentStatus, order?.status]
  );

  const fetchOrder = async () => {
    if (!id) return;
    try {
      setLoading(true);
      const res: any = await axiosClient.get(`/orders/${id}`);
      setOrder(res);
    } catch {
      toast.error("Không tải được chi tiết đơn hàng");
      navigate("/orders");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrder();
  }, [id]);

  const handleCancel = async () => {
    if (!id) return;
    try {
      setProcessing(true);
      await axiosClient.post(`/orders/${id}/cancel`);
      toast.success("Đã hủy đơn hàng");
      await fetchOrder();
    } catch (error: any) {
      const message = error?.message || error?.response?.data?.message;
      toast.error(typeof message === "string" ? message : "Không thể hủy đơn hàng");
    } finally {
      setProcessing(false);
    }
  };

  const handleRepay = async () => {
    if (!id) return;
    try {
      setProcessing(true);
      const payment: any = await axiosClient.post("/payments/create-payment", { orderId: id });
      const checkoutUrl = payment?.checkoutUrl || payment?.data?.checkoutUrl;
      if (!checkoutUrl) {
        toast.error("Không lấy được liên kết thanh toán");
        return;
      }
      window.location.href = checkoutUrl;
    } catch (error: any) {
      const message = error?.message || error?.response?.data?.message;
      toast.error(typeof message === "string" ? message : "Không thể tạo thanh toán");
    } finally {
      setProcessing(false);
    }
  };

  const handleSyncPayment = async () => {
    if (!id) return;
    try {
      setSyncingPayment(true);
      await axiosClient.get(`/payments/verify-sync/${id}`);
      await fetchOrder();
      toast.success("Đã đồng bộ trạng thái thanh toán");
    } catch (error: any) {
      const message = error?.message || error?.response?.data?.message;
      toast.error(typeof message === "string" ? message : "Không thể đồng bộ thanh toán");
    } finally {
      setSyncingPayment(false);
    }
  };

  if (loading) {
    return <div className="p-4 text-center text-gray-500">Đang tải chi tiết đơn hàng...</div>;
  }

  if (!order) {
    return null;
  }

  return (
    <div className="min-h-full bg-section">
      <div className="bg-white p-4 flex items-center gap-2 border-b">
        <button onClick={() => navigate(-1)} className="p-1 -ml-1">
          <ArrowLeft size={22} />
        </button>
        <div className="font-bold text-lg">Chi tiết đơn hàng</div>
      </div>

      <div className="p-4 space-y-3">
        <div className="bg-white rounded-xl p-4 border shadow-sm">
          <div className="text-sm text-gray-500">Mã đơn</div>
          <div className="font-semibold">#{(order.code || order.id)?.slice(0, 12).toUpperCase()}</div>
          <div className="mt-2 text-sm text-gray-500">
            Trạng thái: <span className="font-semibold text-gray-800">{ORDER_STATUS_LABEL[order.status] || order.status}</span>
          </div>
          <div className="text-sm text-gray-500">
            Thanh toán:{" "}
            <span className="font-semibold text-gray-800">
              {PAYMENT_STATUS_LABEL[order.paymentStatus] || order.paymentStatus || "N/A"}
            </span>
          </div>
          <div className="text-sm text-gray-500 mt-1">
            Ngày đặt: {new Date(order.createdAt).toLocaleString("vi-VN")}
          </div>
        </div>

        <div className="bg-white rounded-xl p-4 border shadow-sm space-y-3">
          <div className="font-semibold">Sản phẩm</div>
          {order.items?.map((item: any) => (
            <div key={item.id} className="flex gap-3 items-center">
              <img
                src={item.product?.images?.[0]?.url || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg"}
                className="w-14 h-14 rounded-lg object-cover bg-gray-100"
              />
              <div className="flex-1">
                <div className="text-sm font-semibold">{item.product?.name || "Sản phẩm"}</div>
                <div className="text-xs text-gray-500">{item.variant?.name || "Phiên bản"} x {item.quantity}</div>
              </div>
              <div className="text-sm font-semibold">{Number(item.totalPrice || item.price || 0).toLocaleString()}đ</div>
            </div>
          ))}
          <div className="border-t pt-3 flex justify-between">
            <div className="text-sm text-gray-500">Tổng thanh toán</div>
            <div className="font-bold text-primary">{Number(order.finalAmount || order.totalAmount || 0).toLocaleString()}đ</div>
          </div>
        </div>

        {order.shippingAddress && (
          <div className="bg-white rounded-xl p-4 border shadow-sm">
            <div className="font-semibold mb-1">Địa chỉ giao hàng</div>
            <div className="text-sm text-gray-600">{order.recipientName || "Người nhận"} - {order.phone || "N/A"}</div>
            <div className="text-sm text-gray-600">{order.shippingAddress}</div>
          </div>
        )}

        <div className="grid grid-cols-2 gap-2">
          {canRequestReturn && (
            <button
              onClick={() => navigate(`/orders/${id}/return`)}
              className="py-2.5 rounded-lg border border-amber-200 text-amber-700 font-semibold"
            >
              Yêu cầu trả hàng
            </button>
          )}
          {order.paymentStatus === "PENDING" && order.status !== "CANCELLED" && (
            <button
              onClick={handleSyncPayment}
              disabled={syncingPayment}
              className="py-2.5 rounded-lg border border-blue-200 text-blue-600 font-semibold disabled:opacity-60"
            >
              {syncingPayment ? "Đang kiểm tra..." : "Kiểm tra thanh toán"}
            </button>
          )}
          {canRepay && (
            <button
              onClick={handleRepay}
              disabled={processing}
              className="py-2.5 rounded-lg bg-primary text-white font-semibold disabled:opacity-60"
            >
              {processing ? "Đang xử lý..." : "Thanh toán lại"}
            </button>
          )}
          {canCancel && (
            <button
              onClick={handleCancel}
              disabled={processing}
              className="py-2.5 rounded-lg border border-red-200 text-red-600 font-semibold disabled:opacity-60"
            >
              {processing ? "Đang xử lý..." : "Hủy đơn"}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
