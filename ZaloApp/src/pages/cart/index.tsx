import CartList from "./cart-list";
import ApplyVoucher from "./apply-voucher";
import CartSummary from "./cart-summary";
import { useAtom } from "jotai";
import { cartState, selectedCartItemIdsState } from "@/state";
import SelectAll from "./select-all";
import PaymentMethod from "./payment-method";
import { useEffect, useState } from "react";
import axiosClient from "@/services/axiosClient";
import { Cart } from "@/types";
import toast from "react-hot-toast";
import { ShoppingBag } from "lucide-react";
import { useNavigate } from "react-router-dom";

export default function CartPage() {
  const [cart, setCart] = useAtom(cartState);
  const [, setSelectedIds] = useAtom(selectedCartItemIdsState);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchCart = async () => {
      try {
        const response: any = await axiosClient.get("/cart");
        const items = response?.items || [];
        const normalized: Cart = items.map((item: any) => ({
          id: item.id,
          quantity: item.quantity,
          options: { size: item.variant?.label || item.variant?.name },
          product: {
            id: item.variant?.product?.id,
            name: item.variant?.product?.name || "Sản phẩm",
            price: Number(item.variant?.price || 0),
            image:
              item.variant?.product?.images?.[0]?.url ||
              "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg",
            category: { id: 0, name: "", image: "" },
          } as any,
        }));
        setCart(normalized);
        setSelectedIds(normalized.map((item) => item.id));
      } catch {
        toast.error("Không tải được giỏ hàng");
      } finally {
        setLoading(false);
      }
    };
    fetchCart();
  }, [setCart, setSelectedIds]);

  if (loading) {
    return (
      <div className="min-h-full" style={{ background: '#FAF8F5' }}>
        <div className="px-4 pt-4 space-y-3">
          {[1, 2, 3].map(i => (
            <div key={i} className="flex gap-3 p-3 rounded-2xl animate-pulse" style={{ background: '#FFFFFF' }}>
              <div className="w-16 h-16 rounded-2xl bg-skeleton" />
              <div className="flex-1 space-y-2">
                <div className="h-4 w-3/4 bg-skeleton rounded" />
                <div className="h-3 w-1/2 bg-skeleton rounded" />
                <div className="h-4 w-1/3 bg-skeleton rounded" />
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (!cart.length) {
    return (
      <div className="min-h-full flex flex-col items-center justify-center px-6" style={{ background: '#FAF8F5' }}>
        <div
          className="w-24 h-24 rounded-3xl flex items-center justify-center mb-6"
          style={{ background: 'linear-gradient(135deg, #F0ECE6, #E8E0D5)' }}
        >
          <ShoppingBag size={40} className="text-inactive" />
        </div>
        <h2 className="text-lg font-bold text-foreground mb-2"
          style={{ fontFamily: "'Playfair Display', serif" }}>
          Giỏ hàng trống
        </h2>
        <p className="text-sm text-subtitle text-center mb-6 leading-relaxed">
          Hãy khám phá bộ sưu tập nước hoa và thêm sản phẩm vào giỏ hàng của bạn.
        </p>
        <button
          onClick={() => navigate("/")}
          className="px-8 py-3.5 rounded-2xl font-bold text-sm active:scale-95 transition-transform"
          style={{
            background: 'linear-gradient(135deg, #E2D1B3, #D4AF37)',
            color: '#1a1a2e',
            boxShadow: '0 4px 16px rgba(212,175,55,0.3)',
          }}
        >
          Khám phá ngay
        </button>
      </div>
    );
  }

  return (
    <div className="w-full h-full flex flex-col" style={{ background: '#FAF8F5' }}>
      {/* Cart items section */}
      <div className="flex-1 overflow-y-auto">
        <div className="pt-2 pb-1" style={{ background: '#FFFFFF' }}>
          <SelectAll />
          <CartList />
        </div>

        {/* Voucher & Payment */}
        <div className="mt-2 space-y-2">
          <div className="rounded-none" style={{ background: '#FFFFFF' }}>
            <ApplyVoucher />
          </div>
          <div style={{ background: '#FFFFFF' }}>
            <PaymentMethod />
          </div>
        </div>

        <div className="h-4" />
      </div>

      {/* Cart Summary bottom bar */}
      <CartSummary />
    </div>
  );
}
