import TransitionLink from "@/components/transition-link";
import { Package, ChevronRight, RefreshCw, X, Truck } from "lucide-react";
import { useEffect, useState } from "react";
import axiosClient from "@/services/axiosClient";
import toast from "react-hot-toast";
import { formatPrice } from "@/utils/format";

const ORDER_STATUS: Record<string, { label: string; color: string; bg: string }> = {
  PENDING:    { label: "Chờ xác nhận", color: "#D4AF37", bg: "rgba(212,175,55,0.1)" },
  CONFIRMED:  { label: "Đã xác nhận",  color: "#007AFF", bg: "rgba(0,122,255,0.1)" },
  PROCESSING: { label: "Đang xử lý",   color: "#FF9500", bg: "rgba(255,149,0,0.1)" },
  SHIPPED:    { label: "Đang giao",     color: "#5856D6", bg: "rgba(88,86,214,0.1)" },
  COMPLETED:  { label: "Hoàn tất",      color: "#34C759", bg: "rgba(52,199,89,0.1)" },
  CANCELLED:  { label: "Đã hủy",        color: "#FF453A", bg: "rgba(255,69,58,0.1)" },
};

const PAYMENT_STATUS: Record<string, string> = {
  PENDING: "Chưa thanh toán",
  PAID: "Đã thanh toán",
  FAILED: "Thanh toán lỗi",
  REFUNDED: "Đã hoàn tiền",
};

const STATUS_TABS = ["ALL", "PENDING", "CONFIRMED", "SHIPPED", "COMPLETED", "CANCELLED"];

export default function OrdersPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [cancellingId, setCancellingId] = useState<string | null>(null);
  const [syncingId, setSyncingId] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState("ALL");

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const res: any = await axiosClient.get("/orders");
      const items = Array.isArray(res) ? res : res?.data || res?.items || res?.orders || [];
      setOrders(items);
    } catch {
      toast.error("Không thể tải danh sách đơn hàng");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchOrders(); }, []);

  const handleCancel = async (orderId: string) => {
    try {
      setCancellingId(orderId);
      await axiosClient.post(`/orders/${orderId}/cancel`);
      toast.success("Đã hủy đơn hàng");
      await fetchOrders();
    } catch (error: any) {
      toast.error(error?.message || "Không thể hủy đơn hàng");
    } finally {
      setCancellingId(null);
    }
  };

  const handleSyncPayment = async (orderId: string) => {
    try {
      setSyncingId(orderId);
      await axiosClient.get(`/payments/verify-sync/${orderId}`);
      await fetchOrders();
      toast.success("Đã đồng bộ trạng thái thanh toán");
    } catch {
      toast.error("Không thể đồng bộ thanh toán");
    } finally {
      setSyncingId(null);
    }
  };

  const filteredOrders = orders.filter((o: any) =>
    statusFilter === "ALL" || o.status === statusFilter
  );

  return (
    <div className="min-h-full" style={{ background: '#FAF8F5' }}>
      {/* Status filter tabs */}
      <div className="px-4 pt-3 pb-2">
        <div
          className="flex gap-2 overflow-x-auto pb-1"
          style={{ scrollbarWidth: 'none' }}
        >
          {STATUS_TABS.map((s) => {
            const info = ORDER_STATUS[s];
            const isActive = statusFilter === s;
            return (
              <button
                key={s}
                onClick={() => setStatusFilter(s)}
                className="flex-none px-3.5 py-1.5 rounded-full text-xs font-bold whitespace-nowrap active:scale-95 transition-all"
                style={isActive ? {
                  background: s === "ALL"
                    ? 'linear-gradient(135deg, #1a1a2e, #2d2d52)'
                    : info?.bg,
                  color: s === "ALL" ? '#FAF8F5' : info?.color,
                  border: `1px solid ${s === "ALL" ? 'transparent' : info?.color + '40'}`,
                } : {
                  background: '#FFFFFF',
                  color: '#6B6B6B',
                  border: '1px solid rgba(0,0,0,0.08)',
                }}
              >
                {s === "ALL" ? "Tất cả" : info?.label || s}
              </button>
            );
          })}
        </div>
      </div>

      {/* Order list */}
      <div className="px-4 space-y-3 pb-6">
        {loading ? (
          Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="rounded-3xl p-4 animate-pulse" style={{ background: '#FFFFFF', height: '160px' }} />
          ))
        ) : filteredOrders.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-center">
            <Package size={48} className="text-skeleton mb-4" />
            <div className="text-base font-bold text-foreground mb-1">Không có đơn hàng</div>
            <p className="text-xs text-subtitle">
              {statusFilter === "ALL" ? "Bạn chưa có đơn hàng nào." : `Không có đơn hàng ở trạng thái này.`}
            </p>
          </div>
        ) : (
          filteredOrders.map((order: any) => {
            const statusInfo = ORDER_STATUS[order.status] || { label: order.status, color: '#6B6B6B', bg: '#F0ECE6' };
            return (
              <div
                key={order.id}
                className="rounded-3xl overflow-hidden"
                style={{
                  background: '#FFFFFF',
                  border: '1px solid rgba(0,0,0,0.06)',
                  boxShadow: '0 2px 12px rgba(0,0,0,0.06)',
                }}
              >
                {/* Header */}
                <div
                  className="flex items-center justify-between px-4 py-3"
                  style={{ borderBottom: '1px solid rgba(0,0,0,0.04)' }}
                >
                  <div className="flex items-center gap-2">
                    <Package size={14} className="text-inactive" />
                    <span className="text-xs font-bold text-foreground">
                      #{(order.code || order.id)?.slice(0, 8).toUpperCase()}
                    </span>
                  </div>
                  <div
                    className="px-2.5 py-1 rounded-full text-2xs font-bold"
                    style={{ background: statusInfo.bg, color: statusInfo.color }}
                  >
                    {statusInfo.label}
                  </div>
                </div>

                {/* Items preview */}
                <div className="px-4 py-3 space-y-2.5">
                  {order.items?.slice(0, 2).map((item: any) => (
                    <div key={item.id} className="flex gap-3 items-center">
                      <div className="w-12 h-12 rounded-xl overflow-hidden flex-shrink-0" style={{ background: '#F0ECE6' }}>
                        <img
                          src={item.product?.images?.[0]?.url || item.product?.image || 'https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg'}
                          className="w-full h-full object-cover"
                          alt={item.product?.name}
                        />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="text-xs font-semibold text-foreground truncate">{item.product?.name}</div>
                        <div className="text-2xs text-subtitle">
                          {item.variant?.name || (item.variant?.volume && `${item.variant.volume}ml`)} · x{item.quantity}
                        </div>
                      </div>
                      <div className="text-xs font-bold text-foreground">{formatPrice(Number(item.price))}</div>
                    </div>
                  ))}
                  {order.items?.length > 2 && (
                    <div className="text-2xs text-subtitle">+{order.items.length - 2} sản phẩm khác</div>
                  )}
                </div>

                {/* Shipping info */}
                {order.shippingProvider && (
                  <div
                    className="mx-4 px-3 py-2 rounded-xl mb-3 flex items-center gap-2"
                    style={{ background: '#F0ECE6' }}
                  >
                    <Truck size={12} className="text-subtitle flex-shrink-0" />
                    <span className="text-2xs text-subtitle">
                      {order.shippingProvider}
                      {order.trackingNumber && ` · ${order.trackingNumber}`}
                    </span>
                  </div>
                )}

                {/* Footer: total + date */}
                <div
                  className="px-4 py-3"
                  style={{ borderTop: '1px solid rgba(0,0,0,0.04)' }}
                >
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <div className="text-2xs text-subtitle">
                        {new Date(order.createdAt).toLocaleDateString("vi-VN")} · {PAYMENT_STATUS[order.paymentStatus] || order.paymentStatus}
                      </div>
                    </div>
                    <div
                      className="text-base font-black"
                      style={{ fontFamily: "'Playfair Display', serif", color: '#1a1a2e' }}
                    >
                      {formatPrice(Number(order.totalAmount || 0))}
                    </div>
                  </div>

                  {/* Action buttons */}
                  <div className="flex gap-2">
                    <TransitionLink
                      to={`/orders/${order.id}`}
                      className="flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-2xl text-xs font-bold active:scale-95 transition-transform"
                      style={{
                        background: 'linear-gradient(135deg, #E2D1B3, #D4AF37)',
                        color: '#1a1a2e',
                      }}
                    >
                      {() => (
                        <>
                          Chi tiết
                          <ChevronRight size={13} />
                        </>
                      )}
                    </TransitionLink>

                    {order.paymentStatus === "PENDING" && order.status !== "CANCELLED" && (
                      <button
                        onClick={() => handleSyncPayment(order.id)}
                        disabled={syncingId === order.id}
                        className="px-3 py-2.5 rounded-2xl text-xs font-bold disabled:opacity-60 active:scale-95 transition-transform"
                        style={{ background: '#F0ECE6', color: '#1a1a2e' }}
                      >
                        {syncingId === order.id ? <RefreshCw size={13} className="animate-spin" /> : "Xác nhận TT"}
                      </button>
                    )}

                    {["PENDING", "CONFIRMED", "PROCESSING"].includes(order.status) && (
                      <button
                        onClick={() => handleCancel(order.id)}
                        disabled={cancellingId === order.id}
                        className="px-3 py-2.5 rounded-2xl text-xs font-bold disabled:opacity-60 active:scale-95 transition-transform"
                        style={{ background: 'rgba(255,69,58,0.1)', color: '#FF453A' }}
                      >
                        {cancellingId === order.id ? <RefreshCw size={13} className="animate-spin" /> : <X size={13} />}
                      </button>
                    )}
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
