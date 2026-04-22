import {
  OrderHistoryIcon,
  PackageIcon,
  ProfileIcon,
  VoucherIcon,
} from "@/components/vectors";
import { useNavigate } from "react-router-dom";

export default function ProfileActions() {
  const navigate = useNavigate();

  return (
    <div className="bg-white rounded-lg p-4 grid grid-cols-4 gap-4 border-[0.5px] border-black/15">
      {[
        {
          label: "Thông tin tài khoản",
          icon: ProfileIcon,
          onClick: () => navigate("/profile/edit"),
        },
        {
          label: "Đổi voucher",
          icon: VoucherIcon,
          onClick: () => navigate("/profile/vouchers"),
        },
        {
          label: "Yêu thích",
          icon: VoucherIcon,
          onClick: () => navigate("/profile/favorites"),
        },
        {
          label: "Địa chỉ nhận hàng",
          icon: PackageIcon,
          onClick: () => navigate("/profile/addresses"),
        },
        {
          label: "Theo dõi đơn hàng",
          icon: PackageIcon,
          onClick: () => navigate("/orders"),
        },
        {
          label: "Trả hàng",
          icon: PackageIcon,
          onClick: () => navigate("/returns"),
        },
        {
          label: "Lịch sử mua hàng",
          icon: OrderHistoryIcon,
          onClick: () => navigate("/orders"),
        },
      ].map((action) => (
        <div
          key={action.label}
          className="flex flex-col gap-2 items-center cursor-pointer"
          onClick={action.onClick}
        >
          <div className="w-10 h-10 rounded-full bg-[#EBEFF7] flex items-center justify-center">
            <action.icon active />
          </div>
          <div className="text-2xs text-center">{action.label}</div>
        </div>
      ))}
    </div>
  );
}
