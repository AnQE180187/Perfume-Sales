import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axiosClient from "@/services/axiosClient";
import toast from "react-hot-toast";

const STATUS_LABEL: Record<string, string> = {
  REQUESTED: "Đã yêu cầu",
  REVIEWING: "Đang xét duyệt",
  APPROVED: "Đã duyệt",
  REJECTED: "Từ chối",
  RETURNING: "Đang hoàn hàng",
  REFUNDED: "Đã hoàn tiền",
  CANCELLED: "Đã hủy",
  AWAITING_CUSTOMER: "Chờ khách xác nhận",
};

export default function ReturnsPage() {
  const navigate = useNavigate();
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchReturns = async () => {
      try {
        setLoading(true);
        const res: any = await axiosClient.get("/returns");
        setRows(Array.isArray(res) ? res : res?.data || []);
      } catch {
        toast.error("Không tải được danh sách trả hàng");
      } finally {
        setLoading(false);
      }
    };
    fetchReturns();
  }, []);

  return (
    <div className="min-h-full bg-section p-4 space-y-3">
      {loading ? (
        <div className="text-center py-10 text-gray-500">Đang tải yêu cầu trả hàng...</div>
      ) : rows.length === 0 ? (
        <div className="text-center py-10 text-gray-500">Bạn chưa có yêu cầu trả hàng nào</div>
      ) : (
        rows.map((ret) => (
          <button
            key={ret.id}
            onClick={() => navigate(`/returns/${ret.id}`)}
            className="w-full text-left bg-white rounded-xl p-4 border shadow-sm"
          >
            <div className="flex justify-between items-center">
              <div className="font-semibold text-sm">#{(ret.id || "").slice(0, 8).toUpperCase()}</div>
              <div className="text-xs px-2 py-1 rounded bg-primary/10 text-primary font-semibold">
                {STATUS_LABEL[ret.status] || ret.status}
              </div>
            </div>
            <div className="text-xs text-gray-500 mt-2">Đơn gốc: {ret.order?.code || ret.orderId}</div>
            <div className="text-xs text-gray-500 mt-1">
              Số sản phẩm: {ret.items?.length || 0} - {new Date(ret.createdAt).toLocaleDateString("vi-VN")}
            </div>
          </button>
        ))
      )}
    </div>
  );
}
