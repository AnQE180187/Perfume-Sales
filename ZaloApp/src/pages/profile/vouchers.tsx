import { useState, useEffect } from "react";
import { ArrowLeft, Ticket, Sparkles, AlertCircle } from "lucide-react";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import axiosClient from "@/services/axiosClient";
import TransitionLink from "@/components/transition-link";

export default function VouchersPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<'MY_VOUCHERS' | 'REDEEM'>('MY_VOUCHERS');
  
  const [myVouchers, setMyVouchers] = useState<any[]>([]);
  const [redeemable, setRedeemable] = useState<any[]>([]);
  const [points, setPoints] = useState(0);
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      setLoading(true);
      // Fetch user points
      const profile: any = await axiosClient.get("/users/me");
      setPoints(profile.loyaltyPoints || 0);

      // Fetch my vouchers
      const myRes: any = await axiosClient.get("/promotions/my-promotions");
      setMyVouchers(Array.isArray(myRes) ? myRes : myRes.data || []);

      // Fetch redeemable
      const redRes: any = await axiosClient.get("/promotions/redeemable");
      setRedeemable(Array.isArray(redRes) ? redRes : redRes.data || []);
      
    } catch (err) {
      console.error(err);
      toast.error("Không thể tải dữ liệu voucher");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleRedeem = async (id: string, cost: number) => {
    if (points < cost) {
       toast.error("Bạn không đủ điểm để đổi mã này.");
       return;
    }
    if (!window.confirm("Xác nhận dùng điểm để đổi mã này?")) return;
    
    try {
      await axiosClient.post(`/promotions/redeem/${id}`);
      toast.success("Đổi mã thành công!");
      fetchData(); // Reload points and lists
    } catch (err: any) {
      toast.error(err?.response?.data?.message || "Đổi mã thất bại");
    }
  };

  return (
    <div className="min-h-full bg-section flex flex-col">
      <div className="bg-white p-4 sticky top-0 z-10 border-b">
        <div className="flex gap-3 items-center mb-4">
          <button onClick={() => navigate("/profile")} className="p-1 -ml-1">
            <ArrowLeft size={24} />
          </button>
          <div className="text-lg font-bold">Kho Voucher</div>
        </div>

        {/* Điểm hiện tại */}
        <div className="bg-gradient-to-r from-primary to-[#d0b471] rounded-2xl p-4 text-white flex justify-between items-center shadow-md">
           <div>
              <div className="text-white/80 text-sm mb-1">Điểm tích luỹ</div>
              <div className="text-2xl font-bold flex items-center gap-1">
                 <Sparkles size={20} /> {points}
              </div>
           </div>
           <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
              <Ticket size={24} />
           </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex bg-white px-4 border-b border-gray-100">
        <button 
          onClick={() => setActiveTab('MY_VOUCHERS')}
          className={`flex-1 py-3 text-sm font-semibold border-b-2 transition-all ${activeTab === 'MY_VOUCHERS' ? 'border-primary text-primary' : 'border-transparent text-gray-400'}`}
        >
          Mã của tôi
        </button>
        <button 
          onClick={() => setActiveTab('REDEEM')}
          className={`flex-1 py-3 text-sm font-semibold border-b-2 transition-all ${activeTab === 'REDEEM' ? 'border-primary text-primary' : 'border-transparent text-gray-400'}`}
        >
          Đổi mã mới
        </button>
      </div>

      <div className="p-4 flex-1 overflow-y-auto">
        {loading ? (
           <div className="space-y-3">
             <div className="h-24 bg-gray-200 rounded-xl animate-pulse"></div>
             <div className="h-24 bg-gray-200 rounded-xl animate-pulse"></div>
           </div>
        ) : activeTab === 'MY_VOUCHERS' ? (
          myVouchers.length === 0 ? (
            <div className="text-center py-10 text-gray-500 flex flex-col items-center">
              <Ticket size={40} className="mb-2 text-gray-300" />
              Bạn chưa có mã giảm giá nào
            </div>
          ) : (
            <div className="space-y-3">
              {myVouchers.map((item: any) => {
                 // The backend might return { id, promotion: { name, ... } } or just promotion
                 const promo = item.promotion || item;
                 return (
                   <div key={item.id || promo.id} className="bg-white rounded-xl flex border shadow-sm overflow-hidden relative">
                     <div className="w-24 bg-green-50 flex flex-col justify-center items-center border-r border-dashed border-gray-300">
                        <div className="text-green-600 font-bold text-xl">{promo.discountPercent ? `${promo.discountPercent}%` : `${promo.discountAmount / 1000}k`}</div>
                        <div className="text-xs text-green-500 uppercase font-semibold">Giảm</div>
                     </div>
                     <div className="flex-1 p-3">
                        <div className="font-bold text-gray-800 text-sm mb-1">{promo.name}</div>
                        <div className="text-xs text-gray-500 mb-2">{promo.description}</div>
                        <div className="text-xs font-mono bg-gray-100 w-max px-2 py-1 rounded text-gray-600">Mã: {promo.code}</div>
                     </div>
                   </div>
                 );
              })}
            </div>
          )
        ) : (
          redeemable.length === 0 ? (
            <div className="text-center py-10 text-gray-500 flex flex-col items-center">
               <AlertCircle size={40} className="mb-2 text-gray-300" />
               Không có voucher nào để đổi
            </div>
          ) : (
            <div className="space-y-3">
              {redeemable.map((promo: any) => (
                <div key={promo.id} className="bg-white rounded-xl flex border shadow-sm overflow-hidden relative">
                  <div className="w-24 bg-blue-50 flex flex-col justify-center items-center border-r border-dashed border-gray-300">
                    <div className="text-blue-600 font-bold text-xl">{promo.discountPercent ? `${promo.discountPercent}%` : `${promo.discountAmount / 1000}k`}</div>
                    <div className="text-xs text-blue-500 uppercase font-semibold">Giảm</div>
                  </div>
                  <div className="flex-1 p-3">
                    <div className="font-bold text-gray-800 text-sm mb-1">{promo.name}</div>
                    <div className="text-xs text-warning font-semibold mb-2 flex items-center gap-1">
                      <Sparkles size={12}/> {promo.pointsCost} điểm
                    </div>
                    <button 
                      onClick={() => handleRedeem(promo.id, promo.pointsCost)}
                      className="w-full py-2 bg-primary text-white text-xs font-bold rounded-lg active:scale-95 transition-transform"
                    >
                      Đổi ngay
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )
        )}
      </div>
    </div>
  );
}
