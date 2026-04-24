import { useCheckout, useCustomerSupport } from "@/hooks";
import { useAtomValue } from "jotai";
import { cartTotalState } from "@/state";
import { formatPrice } from "@/utils/format";
import { useNavigate } from "react-router-dom";
import { ShoppingBag, Headphones, Zap } from "lucide-react";

export default function CartSummary() {
  const { totalItems, subtotal, promotionDiscount, pointsDiscount, totalAmount } =
    useAtomValue(cartTotalState);
  const contact = useCustomerSupport();
  const navigate = useNavigate();
  const { checkout, isCheckingOut } = useCheckout({
    onMissingAddress: () => navigate("/profile/addresses"),
  });

  return (
    <div
      className="flex-none"
      style={{
        background: '#FFFFFF',
        borderTop: '1px solid rgba(0,0,0,0.06)',
        paddingBottom: 'max(12px, env(safe-area-inset-bottom))',
      }}
    >
      {/* Price breakdown */}
      <div className="px-4 pt-3 pb-2 space-y-1">
        <div className="flex justify-between text-xs text-subtitle">
          <span>Tạm tính ({totalItems} sản phẩm)</span>
          <span>{formatPrice(subtotal)}</span>
        </div>
        {promotionDiscount > 0 && (
          <div className="flex justify-between text-xs text-success">
            <span>Giảm giá voucher</span>
            <span>-{formatPrice(promotionDiscount)}</span>
          </div>
        )}
        {pointsDiscount > 0 && (
          <div className="flex justify-between text-xs text-success">
            <span>Điểm đổi thưởng</span>
            <span>-{formatPrice(pointsDiscount)}</span>
          </div>
        )}
        <div
          className="flex justify-between pt-1"
          style={{ borderTop: '1px solid rgba(0,0,0,0.04)' }}
        >
          <span className="text-sm font-bold text-foreground">Thanh toán</span>
          <span
            className="text-base font-black"
            style={{ fontFamily: "'Playfair Display', serif", color: '#1a1a2e' }}
          >
            {formatPrice(totalAmount)}
          </span>
        </div>
      </div>

      {/* Action buttons */}
      <div className="px-4 pb-1 flex gap-2">
        <button
          onClick={contact}
          className="w-11 h-11 rounded-2xl flex items-center justify-center flex-shrink-0 active:scale-90 transition-transform"
          style={{ background: '#F0ECE6', border: '1px solid rgba(212,175,55,0.2)' }}
        >
          <Headphones size={18} className="text-subtitle" />
        </button>

        <button
          onClick={checkout}
          disabled={totalItems === 0 || isCheckingOut}
          className="flex-1 flex items-center justify-center gap-2 py-3.5 rounded-2xl font-bold text-sm active:scale-95 transition-all disabled:opacity-50"
          style={{
            background: totalItems === 0 || isCheckingOut
              ? '#E8E0D5'
              : 'linear-gradient(135deg, #E2D1B3, #D4AF37)',
            color: '#1a1a2e',
            boxShadow: totalItems === 0 || isCheckingOut
              ? 'none'
              : '0 4px 16px rgba(212,175,55,0.35)',
          }}
        >
          {isCheckingOut ? (
            <>
              <span className="w-4 h-4 border-2 border-primary/40 border-t-primary rounded-full animate-spin" />
              Đang xử lý...
            </>
          ) : (
            <>
              <Zap size={16} />
              Đặt hàng ngay
            </>
          )}
        </button>
      </div>
    </div>
  );
}
