import { useEffect, useState } from "react";
import { Heart } from "lucide-react";
import axiosClient from "@/services/axiosClient";
import TransitionLink from "@/components/transition-link";
import toast from "react-hot-toast";

export default function FavoritesPage() {
  const [items, setItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchFavorites = async () => {
    try {
      setLoading(true);
      const res: any = await axiosClient.get("/favorites");
      const rows = Array.isArray(res) ? res : res?.items || res?.data || [];
      setItems(rows);
    } catch {
      toast.error("Không tải được danh sách yêu thích");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFavorites();
  }, []);

  const handleRemove = async (productId: string) => {
    try {
      await axiosClient.delete(`/favorites/${productId}`);
      toast.success("Đã bỏ khỏi yêu thích");
      setItems((prev) => prev.filter((item) => item.productId !== productId));
    } catch {
      toast.error("Không thể cập nhật yêu thích");
    }
  };

  return (
    <div className="min-h-full bg-section p-4 space-y-4">
      {loading ? (
        <div className="text-center py-10 text-gray-500">Đang tải danh sách yêu thích...</div>
      ) : items.length === 0 ? (
        <div className="text-center py-10 text-gray-500">Bạn chưa có sản phẩm yêu thích</div>
      ) : (
        items.map((row) => (
          <div key={row.productId} className="bg-white rounded-xl p-3 border border-gray-100 shadow-sm flex gap-3">
            <img
              src={row.product?.images?.[0]?.url || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg"}
              className="w-20 h-20 rounded-lg object-cover"
            />
            <div className="flex-1 min-w-0">
              <div className="text-xs text-primary font-semibold">
                {row.product?.brand?.name || "PerfumeGPT"}
              </div>
              <div className="font-semibold text-sm line-clamp-2">{row.product?.name || "Sản phẩm"}</div>
              <div className="text-sm text-primary font-bold mt-1">
                {Number(row.variant?.price || row.product?.variants?.[0]?.price || 0).toLocaleString()}đ
              </div>
              <div className="mt-2 flex gap-2">
                <TransitionLink
                  to={`/product/${row.productId}`}
                  className="px-3 py-1.5 rounded-lg bg-primary text-white text-xs font-semibold"
                >
                  Xem sản phẩm
                </TransitionLink>
                <button
                  onClick={() => handleRemove(row.productId)}
                  className="px-3 py-1.5 rounded-lg border text-xs font-semibold text-gray-600"
                >
                  Bỏ thích
                </button>
              </div>
            </div>
            <Heart size={16} className="text-red-500 fill-red-500" />
          </div>
        ))
      )}
    </div>
  );
}
