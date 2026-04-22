import HorizontalDivider from "@/components/horizontal-divider";
import { Package } from "lucide-react";
import TransitionLink from "@/components/transition-link";
import { useEffect, useState } from "react";
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

export default function OrdersPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [cancellingId, setCancellingId] = useState<string | null>(null);
  const [syncingId, setSyncingId] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState<string>("ALL");

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const res = await axiosClient.get("/orders");
      const items = Array.isArray(res) ? res : res?.data || res?.items || res?.orders || [];
      setOrders(items);
    } catch (err) {
      toast.error("Không thể tải danh sách đơn hàng");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  const handleCancel = async (orderId: string) => {
    try {
      setCancellingId(orderId);
      await axiosClient.post(`/orders/${orderId}/cancel`);
      toast.success("Đã hủy đơn hàng");
      await fetchOrders();
    } catch (error: any) {
      const message = error?.message || error?.response?.data?.message;
      toast.error(typeof message === "string" ? message : "Không thể hủy đơn hàng");
    } finally {
      setCancellingId(null);
    }
  };

  const handleSyncPayment = async (orderId: string) => {
    try {
      setSyncingId(orderId);
      await axiosClient.get(`/payments/verify-sync/${orderId}`);
      await fetchOrders();
      toast.success("Đã kiểm tra trạng thái thanh toán");
    } catch {
      toast.error("Không thể đồng bộ thanh toán");
    } finally {
      setSyncingId(null);
    }
  };

  return (
    <div className="min-h-full bg-section">
      <div className="bg-white p-4 text-lg font-bold flex gap-2 items-center">
        <Package size={24} className="text-primary" />
        Lịch sử đơn hàng
      </div>
      <HorizontalDivider />
      <div className="px-4 pt-3 flex gap-2 overflow-x-auto">
        {["ALL", "PENDING", "CONFIRMED", "SHIPPED", "COMPLETED", "CANCELLED"].map((status) => (
          <button
            key={status}
            onClick={() => setStatusFilter(status)}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap ${
              statusFilter === status ? "bg-primary text-white" : "bg-white border text-gray-600"
            }`}
          >
            {status === "ALL" ? "Tất cả" : ORDER_STATUS_LABEL[status] || status}
          </button>
        ))}
      </div>

      <div className="p-4 space-y-4">
        {loading ? (
           <div className="text-center py-10 text-gray-500">Đang tải đơn hàng...</div>
        ) : orders.length === 0 ? (
          <div className="text-center py-10 text-gray-500">
            Bạn chưa có đơn hàng nào
          </div>
        ) : (
          orders
            .filter((order: any) => statusFilter === "ALL" || order.status === statusFilter)
            .map((order: any) => (
            <div key={order.id} className="bg-white rounded-xl p-4 border shadow-sm relative overflow-hidden">
              <div className="flex justify-between items-center mb-3 border-b border-dashed pb-3">
                <div className="font-semibold text-gray-800">Mã: #{(order.code || order.id)?.slice(0, 8).toUpperCase()}</div>
                <div className={`px-2 py-1 rounded text-xs font-semibold ${
                  order.status === 'COMPLETED' ? 'bg-green-100 text-green-700' :
                  order.status === 'CANCELLED' ? 'bg-red-100 text-red-700' : 
                  'bg-blue-100 text-blue-700'
                }`}>
                  {ORDER_STATUS_LABEL[order.status] || order.status}
                </div>
              </div>
              
              {/* Order Content */}
              <div className="space-y-3 mb-3">
                {order.items && order.items.map((item: any) => (
                   <div key={item.id} className="flex gap-3 items-center">
                     <div className="w-12 h-12 bg-gray-100 rounded-md overflow-hidden">
                        <img src={item.product?.images?.[0]?.url || item.product?.image || 'https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg'} className="w-full h-full object-cover" />
                     </div>
                     <div className="flex-1">
                        <p className="text-sm font-semibold truncate max-w-[200px]">{item.product?.name || 'Sản phẩm'}</p>
                        <p className="text-xs text-gray-500">{item.variant?.name || item.variant?.volume + "ml"} - Số lượng: {item.quantity}</p>
                     </div>
                     <div className="font-semibold text-sm">{Number(item.price).toLocaleString()}đ</div>
                   </div>
                ))}
              </div>

              {order.shippingProvider && (
                <div className="bg-gray-50 p-2 rounded-lg text-xs mb-3 text-gray-600 flex justify-between items-center">
                  <span>Giao bởi: <strong className="text-gray-800">{order.shippingProvider}</strong></span>
                  {order.trackingNumber && <span>Mã vận đơn: <strong className="text-primary">{order.trackingNumber}</strong></span>}
                </div>
              )}

              <div className="text-xs text-gray-500 mb-2">Ngày đặt: {new Date(order.createdAt).toLocaleDateString("vi-VN")}</div>
              <div className="text-xs text-gray-500 mb-2">
                Thanh toán: <span className="font-medium">{PAYMENT_STATUS_LABEL[order.paymentStatus] || order.paymentStatus || "N/A"}</span>
              </div>
              
              <div className="flex justify-between items-center pt-3 border-t">
                <div className="text-gray-500 text-sm">Tổng tiền</div>
                <div className="font-bold text-primary text-lg">{Number(order.totalAmount || 0).toLocaleString()}đ</div>
              </div>
              <TransitionLink
                to={`/orders/${order.id}`}
                className="mt-3 block w-full text-center border border-primary/20 text-primary text-sm font-semibold py-2 rounded-lg"
              >
                Xem chi tiết
              </TransitionLink>
              {!!order.returnRequests?.length && (
                <TransitionLink
                  to={`/returns/${order.returnRequests[0].id}`}
                  className="mt-2 block w-full text-center border border-amber-200 text-amber-700 text-sm font-semibold py-2 rounded-lg"
                >
                  Xem yêu cầu trả hàng
                </TransitionLink>
              )}
              {order.paymentStatus === "PENDING" && order.status !== "CANCELLED" && (
                <button
                  onClick={() => handleSyncPayment(order.id)}
                  disabled={syncingId === order.id}
                  className="mt-2 w-full border border-blue-200 text-blue-600 text-sm font-semibold py-2 rounded-lg disabled:opacity-60"
                >
                  {syncingId === order.id ? "Đang kiểm tra..." : "Kiểm tra thanh toán"}
                </button>
              )}
              {["PENDING", "CONFIRMED", "PROCESSING"].includes(order.status) && (
                <button
                  onClick={() => handleCancel(order.id)}
                  disabled={cancellingId === order.id}
                  className="mt-3 w-full border border-red-200 text-red-600 text-sm font-semibold py-2 rounded-lg disabled:opacity-60"
                >
                  {cancellingId === order.id ? "Đang hủy..." : "Hủy đơn hàng"}
                </button>
              )}
            </div>
          ))
        )}
      </div>

      <div className="px-4 pb-4">
        <TransitionLink to="/profile" className="block text-center text-primary font-medium py-3 rounded-xl bg-primary/10">
          Quay lại Hồ sơ
        </TransitionLink>
      </div>
    </div>
  );
}
