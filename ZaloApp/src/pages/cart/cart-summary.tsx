import Button from "@/components/button";
import { CustomerSupportIcon } from "@/components/vectors";
import { useCheckout, useCustomerSupport } from "@/hooks";
import { useAtomValue } from "jotai";
import { cartTotalState } from "@/state";
import { formatPrice } from "@/utils/format";
import { useNavigate } from "react-router-dom";

export default function CartSummary() {
  const { totalItems, subtotal, promotionDiscount, pointsDiscount, totalAmount } =
    useAtomValue(cartTotalState);
  const contact = useCustomerSupport();
  const navigate = useNavigate();
  const { checkout, isCheckingOut } = useCheckout({
    onMissingAddress: () => navigate("/profile/addresses"),
  });

  return (
    <div className="flex-none flex items-center py-3 px-4 space-x-2">
      <div className="space-y-1 flex-1">
        <div className="text-2xs text-subtitle">Tạm tính ({totalItems})</div>
        <div className="text-xs text-subtitle">{formatPrice(subtotal)}</div>
        {(promotionDiscount > 0 || pointsDiscount > 0) && (
          <div className="text-2xs text-green-600">
            - Giảm: {formatPrice((promotionDiscount || 0) + (pointsDiscount || 0))}
          </div>
        )}
        <div className="text-sm font-medium text-primary">
          Thanh toán: {formatPrice(totalAmount)}
        </div>
      </div>
      <Button className="w-10 h-10 !p-2" onClick={contact}>
        <CustomerSupportIcon />
      </Button>
      <Button primary onClick={checkout} disabled={totalItems === 0 || isCheckingOut}>
        {isCheckingOut ? "Đang xử lý..." : "Mua ngay"}
      </Button>
    </div>
  );
}
