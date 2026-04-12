import { atom, useAtom } from "jotai";
import { CreditCard, Wallet } from "lucide-react";

export type PaymentType = "COD" | "PAYOS";
export const paymentMethodState = atom<PaymentType>("COD");

export default function PaymentMethod() {
  const [method, setMethod] = useAtom(paymentMethodState);

  return (
    <div className="py-4 px-4 bg-white">
      <h3 className="text-sm font-semibold mb-3">Phương thức thanh toán</h3>
      <div className="space-y-3">
        {/* COD */}
        <label className="flex items-center gap-3 p-3 border rounded-xl cursor-pointer transition-colors hover:bg-gray-50 has-[:checked]:border-primary has-[:checked]:bg-primary/5">
          <input 
            type="radio" 
            name="payment" 
            value="COD"
            className="w-4 h-4 text-primary accent-primary"
            checked={method === "COD"}
            onChange={() => setMethod("COD")}
          />
          <div className="w-8 h-8 rounded bg-orange-100 text-orange-600 flex items-center justify-center flex-shrink-0">
            <Wallet size={18} />
          </div>
          <div>
            <div className="text-sm font-medium">Thanh toán khi nhận hàng (COD)</div>
            <div className="text-xs text-gray-500">Thanh toán bằng tiền mặt khi shipper giao hàng</div>
          </div>
        </label>

        {/* PayOS */}
        <label className="flex items-center gap-3 p-3 border rounded-xl cursor-pointer transition-colors hover:bg-gray-50 has-[:checked]:border-primary has-[:checked]:bg-primary/5">
          <input 
            type="radio" 
            name="payment" 
            value="PAYOS"
            className="w-4 h-4 text-primary accent-primary"
            checked={method === "PAYOS"}
            onChange={() => setMethod("PAYOS")}
          />
          <div className="w-8 h-8 rounded bg-blue-100 text-blue-600 flex items-center justify-center flex-shrink-0">
            <CreditCard size={18} />
          </div>
          <div>
            <div className="text-sm font-medium">Quét mã QR Ngân Hàng (PayOS)</div>
            <div className="text-xs text-gray-500">Mở ứng dụng ngân hàng và quét mã dễ dàng</div>
          </div>
        </label>
      </div>
    </div>
  );
}
