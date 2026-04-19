import { VoucherIcon, ChevronRight } from "@/components/vectors";
import { useAtom, useAtomValue } from "jotai";
import {
  appliedPromotionCodeState,
  appliedPromotionDiscountState,
  cartTotalState,
  redeemPointsDiscountState,
  redeemPointsState,
} from "@/state";
import { useState } from "react";
import axiosClient from "@/services/axiosClient";
import toast from "react-hot-toast";
import { formatPrice } from "@/utils/format";

export default function ApplyVoucher() {
  const { subtotal } = useAtomValue(cartTotalState);
  const [promotionCode, setPromotionCode] = useAtom(appliedPromotionCodeState);
  const [promotionDiscount, setPromotionDiscount] = useAtom(appliedPromotionDiscountState);
  const [redeemPoints, setRedeemPoints] = useAtom(redeemPointsState);
  const [pointsDiscount, setPointsDiscount] = useAtom(redeemPointsDiscountState);
  const [inputCode, setInputCode] = useState(promotionCode);
  const [inputPoints, setInputPoints] = useState(String(redeemPoints || ""));
  const [expanded, setExpanded] = useState(false);

  const validatePromotion = async () => {
    if (!inputCode.trim()) {
      setPromotionCode("");
      setPromotionDiscount(0);
      toast.success("Đã bỏ mã giảm giá");
      return;
    }
    try {
      const res: any = await axiosClient.post("/promotions/validate", {
        code: inputCode.trim(),
        amount: Math.round(subtotal),
      });
      setPromotionCode(res?.code || inputCode.trim());
      setPromotionDiscount(Number(res?.discountAmount || 0));
      toast.success("Áp dụng voucher thành công");
    } catch (error: any) {
      const message = error?.message || error?.response?.data?.message;
      toast.error(typeof message === "string" ? message : "Voucher không hợp lệ");
      setPromotionCode("");
      setPromotionDiscount(0);
    }
  };

  const validatePoints = async () => {
    const points = Number(inputPoints || 0);
    if (!points) {
      setRedeemPoints(0);
      setPointsDiscount(0);
      toast.success("Đã bỏ đổi điểm");
      return;
    }
    try {
      const res: any = await axiosClient.post("/loyalty/validate-points", { points });
      setRedeemPoints(points);
      setPointsDiscount(Number(res?.discountAmount || 0));
      toast.success("Áp dụng điểm thưởng thành công");
    } catch (error: any) {
      const message = error?.message || error?.response?.data?.message;
      toast.error(typeof message === "string" ? message : "Không thể đổi điểm");
      setRedeemPoints(0);
      setPointsDiscount(0);
    }
  };

  return (
    <div
      className="flex-none py-2 px-4 space-y-2"
    >
      <div className="flex items-center space-x-2 cursor-pointer" onClick={() => setExpanded((v) => !v)}>
        <VoucherIcon />
        <div className="text-sm flex-1">Voucher & Điểm thưởng</div>
        <div className="flex items-center space-x-1">
          <div className="text-sm font-medium">
            {promotionCode || redeemPoints > 0 ? "Đã áp dụng" : "Chọn"}
          </div>
          <ChevronRight />
        </div>
      </div>
      {expanded && (
        <div className="space-y-2 bg-gray-50 rounded-xl p-3">
          <div className="flex gap-2">
            <input
              value={inputCode}
              onChange={(e) => setInputCode(e.target.value.toUpperCase())}
              placeholder="Nhập mã giảm giá"
              className="flex-1 px-3 py-2 rounded-lg border bg-white text-sm"
            />
            <button
              onClick={validatePromotion}
              className="px-3 py-2 rounded-lg bg-primary text-white text-sm font-semibold"
            >
              Áp dụng
            </button>
          </div>
          <div className="flex gap-2">
            <input
              value={inputPoints}
              onChange={(e) => setInputPoints(e.target.value.replace(/\D/g, ""))}
              placeholder="Đổi điểm thưởng"
              className="flex-1 px-3 py-2 rounded-lg border bg-white text-sm"
            />
            <button
              onClick={validatePoints}
              className="px-3 py-2 rounded-lg border border-primary/20 text-primary text-sm font-semibold"
            >
              Đổi điểm
            </button>
          </div>
          {(promotionDiscount > 0 || pointsDiscount > 0) && (
            <div className="text-xs text-gray-600">
              Giảm từ voucher: <b>{formatPrice(promotionDiscount)}</b> | Giảm từ điểm:{" "}
              <b>{formatPrice(pointsDiscount)}</b>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
