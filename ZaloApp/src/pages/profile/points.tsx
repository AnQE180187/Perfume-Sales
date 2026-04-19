import pointsCover from "@/static/points-cover.png";
import Barcode from "./barcode";
import { useEffect, useState } from "react";
import axiosClient from "@/services/axiosClient";

export default function Points() {
  const [loyaltyPoints, setLoyaltyPoints] = useState(0);

  useEffect(() => {
    const fetchLoyalty = async () => {
      try {
        const res: any = await axiosClient.get("/loyalty/status");
        setLoyaltyPoints(Number(res?.points || 0));
      } catch {
        setLoyaltyPoints(0);
      }
    };
    fetchLoyalty();
  }, []);
  
  return (
    <div
      className="rounded-lg bg-primary text-white p-8 pt-6 bg-cover text-center"
      style={{
        backgroundImage: `url(${pointsCover})`,
      }}
    >
      <div className="text-xl font-medium opacity-95">{loyaltyPoints} điểm</div>
      <div className="opacity-95 text-2xs">Thành viên PerfumeGPT</div>
      <div className="bg-white rounded-lg mt-2 py-2.5 space-y-2.5 flex flex-col items-center">
        <div className="text-2xs text-subtitle text-center">
          Quét mã để tích điểm
        </div>
        <Barcode />
      </div>
    </div>
  );
}
