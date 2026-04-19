import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
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

export default function ReturnDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [ret, setRet] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [trackingNumber, setTrackingNumber] = useState("");
  const [courier, setCourier] = useState("GHN");

  const fetchDetail = async () => {
    if (!id) return;
    try {
      setLoading(true);
      const res: any = await axiosClient.get(`/returns/${id}`);
      setRet(res);
    } catch {
      toast.error("Không tải được chi tiết trả hàng");
      navigate("/returns");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDetail();
  }, [id]);

  const canCancel = ["REQUESTED", "REVIEWING", "AWAITING_CUSTOMER"].includes(ret?.status);
  const canAddShipment = ret?.status === "APPROVED";
  const canHandover = ret?.status === "RETURNING";

  const handleCancel = async () => {
    if (!id) return;
    try {
      setActionLoading(true);
      await axiosClient.patch(`/returns/${id}/cancel`, { reason: "Khách hàng hủy yêu cầu" });
      toast.success("Đã hủy yêu cầu trả hàng");
      await fetchDetail();
    } catch (error: any) {
      toast.error(error?.message || "Không thể hủy yêu cầu");
    } finally {
      setActionLoading(false);
    }
  };

  const handleAddShipment = async () => {
    if (!id || !trackingNumber.trim()) {
      toast.error("Vui lòng nhập mã vận đơn");
      return;
    }
    try {
      setActionLoading(true);
      await axiosClient.post(`/returns/${id}/shipment`, {
        courier,
        trackingNumber: trackingNumber.trim(),
      });
      toast.success("Đã cập nhật vận đơn trả hàng");
      setTrackingNumber("");
      await fetchDetail();
    } catch (error: any) {
      toast.error(error?.message || "Không thể cập nhật vận đơn");
    } finally {
      setActionLoading(false);
    }
  };

  const handleHandover = async () => {
    if (!id) return;
    try {
      setActionLoading(true);
      await axiosClient.patch(`/returns/${id}/handover`);
      toast.success("Đã xác nhận bàn giao cho đơn vị vận chuyển");
      await fetchDetail();
    } catch (error: any) {
      toast.error(error?.message || "Không thể xác nhận bàn giao");
    } finally {
      setActionLoading(false);
    }
  };

  if (loading) return <div className="p-4 text-center text-gray-500">Đang tải chi tiết...</div>;
  if (!ret) return null;

  return (
    <div className="min-h-full bg-section p-4 space-y-3">
      <div className="bg-white rounded-xl p-4 border shadow-sm">
        <div className="text-sm text-gray-500">Mã yêu cầu</div>
        <div className="font-semibold">#{(ret.id || "").slice(0, 10).toUpperCase()}</div>
        <div className="text-sm text-gray-600 mt-1">Trạng thái: {STATUS_LABEL[ret.status] || ret.status}</div>
        {ret.note && <div className="text-xs text-gray-500 mt-1">Ghi chú: {ret.note}</div>}
      </div>

      <div className="bg-white rounded-xl p-4 border shadow-sm space-y-3">
        <div className="font-semibold">Sản phẩm trả</div>
        {ret.items?.map((item: any) => (
          <div key={item.id} className="flex items-center gap-3">
            <img
              src={item.variant?.product?.images?.[0]?.url || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg"}
              className="w-14 h-14 rounded-lg object-cover bg-gray-100"
            />
            <div className="flex-1">
              <div className="text-sm font-semibold">{item.variant?.product?.name || "Sản phẩm"}</div>
              <div className="text-xs text-gray-500">{item.variant?.name || "Phiên bản"} x {item.quantity}</div>
            </div>
          </div>
        ))}
      </div>

      {canAddShipment && (
        <div className="bg-white rounded-xl p-4 border shadow-sm space-y-2">
          <div className="font-semibold">Cập nhật vận đơn trả hàng</div>
          <input
            value={courier}
            onChange={(e) => setCourier(e.target.value)}
            placeholder="Đơn vị vận chuyển"
            className="w-full px-3 py-2 rounded-lg border text-sm"
          />
          <input
            value={trackingNumber}
            onChange={(e) => setTrackingNumber(e.target.value)}
            placeholder="Mã vận đơn"
            className="w-full px-3 py-2 rounded-lg border text-sm"
          />
          <button
            onClick={handleAddShipment}
            disabled={actionLoading}
            className="w-full py-2.5 rounded-lg bg-primary text-white font-semibold disabled:opacity-60"
          >
            Cập nhật vận đơn
          </button>
        </div>
      )}

      <div className="grid grid-cols-2 gap-2">
        {canHandover && (
          <button
            onClick={handleHandover}
            disabled={actionLoading}
            className="py-2.5 rounded-lg border border-blue-200 text-blue-600 font-semibold disabled:opacity-60"
          >
            Xác nhận bàn giao
          </button>
        )}
        {canCancel && (
          <button
            onClick={handleCancel}
            disabled={actionLoading}
            className="py-2.5 rounded-lg border border-red-200 text-red-600 font-semibold disabled:opacity-60"
          >
            Hủy yêu cầu
          </button>
        )}
      </div>
    </div>
  );
}
