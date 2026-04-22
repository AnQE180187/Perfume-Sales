import { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import axiosClient from "@/services/axiosClient";
import toast from "react-hot-toast";

export default function CreateReturnPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [reason, setReason] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [quantities, setQuantities] = useState<Record<string, number>>({});

  useEffect(() => {
    const fetchOrder = async () => {
      if (!id) return;
      try {
        setLoading(true);
        const res: any = await axiosClient.get(`/orders/${id}`);
        setOrder(res);
        const qMap: Record<string, number> = {};
        (res?.items || []).forEach((item: any) => {
          qMap[item.id] = item.quantity;
        });
        setQuantities(qMap);
      } catch {
        toast.error("Không tải được thông tin đơn hàng");
        navigate("/orders");
      } finally {
        setLoading(false);
      }
    };
    fetchOrder();
  }, [id]);

  const selectedItems = useMemo(() => {
    return (order?.items || [])
      .filter((item: any) => (quantities[item.id] || 0) > 0)
      .map((item: any) => ({
        variantId: item.variantId,
        quantity: quantities[item.id],
        reason: reason || undefined,
      }));
  }, [order?.items, quantities, reason]);

  const submitReturn = async () => {
    if (!id) return;
    if (!selectedItems.length) {
      toast.error("Vui lòng chọn ít nhất 1 sản phẩm để trả");
      return;
    }
    try {
      setSubmitting(true);
      const res: any = await axiosClient.post("/returns", {
        orderId: id,
        items: selectedItems,
        reason: reason || undefined,
      });
      toast.success("Tạo yêu cầu trả hàng thành công");
      navigate(`/returns/${res?.id || ""}`);
    } catch (error: any) {
      toast.error(error?.message || "Không thể tạo yêu cầu trả hàng");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) return <div className="p-4 text-center text-gray-500">Đang tải thông tin đơn hàng...</div>;

  return (
    <div className="min-h-full bg-section p-4 space-y-3">
      <div className="bg-white rounded-xl p-4 border shadow-sm space-y-3">
        <div className="font-semibold">Chọn sản phẩm cần trả</div>
        {(order?.items || []).map((item: any) => (
          <div key={item.id} className="flex items-center gap-3">
            <img
              src={item.product?.images?.[0]?.url || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg"}
              className="w-12 h-12 rounded-lg object-cover bg-gray-100"
            />
            <div className="flex-1">
              <div className="text-sm font-semibold">{item.product?.name || "Sản phẩm"}</div>
              <div className="text-xs text-gray-500">Đã mua: {item.quantity}</div>
            </div>
            <input
              type="number"
              min={0}
              max={item.quantity}
              value={quantities[item.id] ?? 0}
              onChange={(e) =>
                setQuantities((prev) => ({
                  ...prev,
                  [item.id]: Math.max(0, Math.min(item.quantity, Number(e.target.value || 0))),
                }))
              }
              className="w-16 px-2 py-1 rounded border text-sm"
            />
          </div>
        ))}
      </div>

      <div className="bg-white rounded-xl p-4 border shadow-sm">
        <div className="font-semibold mb-2">Lý do trả hàng</div>
        <textarea
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          className="w-full min-h-24 px-3 py-2 rounded border text-sm"
          placeholder="Mô tả lý do trả hàng..."
        />
      </div>

      <button
        onClick={submitReturn}
        disabled={submitting}
        className="w-full py-3 rounded-lg bg-primary text-white font-semibold disabled:opacity-60"
      >
        {submitting ? "Đang gửi yêu cầu..." : "Gửi yêu cầu trả hàng"}
      </button>
    </div>
  );
}
