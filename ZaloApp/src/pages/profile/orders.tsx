import HorizontalDivider from "@/components/horizontal-divider";
import { Package } from "lucide-react";
import TransitionLink from "@/components/transition-link";
import { useEffect, useState } from "react";
import axiosClient from "@/services/axiosClient";

export default function OrdersPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchOrders() {
      try {
        const res = await axiosClient.get("/orders");
        // Check if the backend returns array of orders directly or `{ orders }` object
        const items = Array.isArray(res) ? res : (res.orders || res.data || []);
        setOrders(items);
      } catch (err) {
        console.error("Failed to fetch orders:", err);
      } finally {
        setLoading(false);
      }
    }
    fetchOrders();
  }, []);

  return (
    <div className="min-h-full bg-section">
      <div className="bg-white p-4 text-lg font-bold flex gap-2 items-center">
        <Package size={24} className="text-primary" />
        Lịch sử đơn hàng
      </div>
      <HorizontalDivider />

      <div className="p-4 space-y-4">
        {loading ? (
           <div className="text-center py-10 text-gray-500">Đang tải đơn hàng...</div>
        ) : orders.length === 0 ? (
          <div className="text-center py-10 text-gray-500">
            Bạn chưa có đơn hàng nào
          </div>
        ) : (
          orders.map(order => (
            <div key={order.id} className="bg-white rounded-xl p-4 border shadow-sm">
              <div className="flex justify-between items-center mb-3">
                <div className="font-semibold text-gray-800">#{order.id.slice(0, 8)}</div>
                <div className={`px-2 py-1 rounded text-xs font-semibold ${order.status === 'COMPLETED' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'}`}>
                  {order.status}
                </div>
              </div>
              <div className="text-sm text-gray-500 mb-2">Ngày đặt: {new Date(order.createdAt).toLocaleDateString("vi-VN")}</div>
              
              <div className="flex justify-between items-center pt-3 border-t">
                <div className="text-gray-500 text-sm">Tổng tiền</div>
                <div className="font-bold text-primary">{Number(order.totalAmount || 0).toLocaleString()}đ</div>
              </div>
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
