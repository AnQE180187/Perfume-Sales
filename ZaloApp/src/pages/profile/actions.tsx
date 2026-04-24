import { useNavigate } from "react-router-dom";
import {
  Package, Heart, MapPin, RotateCcw, ShoppingBag,
  User, Ticket, ChevronRight, Sparkles
} from "lucide-react";

const ACTIONS = [
  {
    label: "Đơn hàng của tôi",
    icon: Package,
    path: "/orders",
    badge: null,
    highlight: false,
  },
  {
    label: "Sản phẩm yêu thích",
    icon: Heart,
    path: "/profile/favorites",
    badge: null,
    highlight: false,
  },
  {
    label: "Kho Voucher",
    icon: Ticket,
    path: "/profile/vouchers",
    badge: null,
    highlight: false,
  },
  {
    label: "Địa chỉ nhận hàng",
    icon: MapPin,
    path: "/profile/addresses",
    badge: null,
    highlight: false,
  },
  {
    label: "Yêu cầu trả hàng",
    icon: RotateCcw,
    path: "/returns",
    badge: null,
    highlight: false,
  },
  {
    label: "Thông tin tài khoản",
    icon: User,
    path: "/profile/edit",
    badge: null,
    highlight: false,
  },
];

export default function ProfileActions() {
  const navigate = useNavigate();

  return (
    <div
      className="rounded-3xl overflow-hidden"
      style={{
        background: "#FFFFFF",
        border: "1px solid rgba(0,0,0,0.06)",
        boxShadow: "0 2px 12px rgba(0,0,0,0.06)",
      }}
    >
      {/* AI shortcut */}
      <div
        onClick={() => navigate("/ai-chat")}
        className="flex items-center gap-3 px-4 py-3.5 cursor-pointer active:bg-primary/5 transition-colors"
        style={{
          borderBottom: "1px solid rgba(212,175,55,0.12)",
          background: "linear-gradient(90deg, #FAF8F5, #FFF9F0)",
        }}
      >
        <div
          className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0"
          style={{ background: "linear-gradient(135deg, #E2D1B3, #D4AF37)" }}
        >
          <Sparkles size={16} className="text-primary" />
        </div>
        <div className="flex-1">
          <div className="text-sm font-bold text-foreground">Tư vấn AI ngay</div>
          <div className="text-2xs text-subtitle">Chat với AI để tìm mùi hương phù hợp</div>
        </div>
        <ChevronRight size={16} className="text-gold" />
      </div>

      {/* Action list */}
      {ACTIONS.map((action, i) => (
        <div
          key={action.path}
          onClick={() => navigate(action.path)}
          className="flex items-center gap-3 px-4 py-3.5 cursor-pointer active:bg-skeleton transition-colors"
          style={{
            borderTop: i > 0 ? "1px solid rgba(0,0,0,0.04)" : undefined,
          }}
        >
          <div
            className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0"
            style={{ background: "#F0ECE6" }}
          >
            <action.icon size={16} className="text-subtitle" />
          </div>
          <div className="flex-1">
            <div className="text-sm font-medium text-foreground">{action.label}</div>
          </div>
          <ChevronRight size={16} className="text-inactive" />
        </div>
      ))}
    </div>
  );
}
