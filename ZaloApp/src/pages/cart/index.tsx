import CartList from "./cart-list";
import ApplyVoucher from "./apply-voucher";
import CartSummary from "./cart-summary";
import HorizontalDivider from "@/components/horizontal-divider";
import { useAtom } from "jotai";
import { cartState, selectedCartItemIdsState } from "@/state";
import { EmptyBoxIcon } from "@/components/vectors";
import SelectAll from "./select-all";
import PaymentMethod from "./payment-method";
import { useEffect, useState } from "react";
import axiosClient from "@/services/axiosClient";
import { Cart } from "@/types";
import toast from "react-hot-toast";

export default function CartPage() {
  const [cart, setCart] = useAtom(cartState);
  const [, setSelectedIds] = useAtom(selectedCartItemIdsState);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchCart = async () => {
      try {
        const response: any = await axiosClient.get("/cart");
        const items = response?.items || [];
        const normalized: Cart = items.map((item: any) => ({
          id: item.id,
          quantity: item.quantity,
          options: { size: item.variant?.name },
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
      <div className="w-full h-full flex items-center justify-center text-sm text-subtitle">
        Đang tải giỏ hàng...
      </div>
    );
  }

  if (!cart.length) {
    return (
      <div className="w-full h-full flex flex-col items-center justify-center space-y-8">
        <EmptyBoxIcon />
        <div className="text-2xs text-inactive text-center">
          Không có sản phẩm trong giỏ hàng
        </div>
      </div>
    );
  }
  return (
    <div className="w-full h-full flex flex-col">
      <SelectAll />
      <HorizontalDivider />
      <CartList />
      <HorizontalDivider />
      <ApplyVoucher />
      <HorizontalDivider />
      <PaymentMethod />
      <HorizontalDivider />
      <CartSummary />
    </div>
  );
}
