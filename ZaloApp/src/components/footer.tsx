import { CartIcon, HomeIcon, ProfileIcon } from "./vectors";
import { useAtomValue } from "jotai";
import { cartState } from "@/state";
import TransitionLink from "./transition-link";
import { Sparkles, MessageCircle } from "lucide-react";
import { useLocation } from "react-router-dom";

const NAV_ITEMS = [
  {
    name: "Trang chủ",
    path: "/",
    exact: true,
    icon: ({ active }: { active?: boolean }) => (
      <HomeIcon active={active} />
    ),
  },
  {
    name: "Bộ sưu tập",
    path: "/catalog",
    icon: ({ active }: { active?: boolean }) => (
      <Sparkles
        size={22}
        className={active ? "text-gold fill-gold/20" : "text-inactive"}
        strokeWidth={active ? 2.5 : 2}
      />
    ),
  },
  {
    name: "Tư vấn AI",
    path: "/ai-chat",
    icon: ({ active }: { active?: boolean }) => (
      <MessageCircle
        size={22}
        className={active ? "text-gold fill-gold/20" : "text-inactive"}
        strokeWidth={active ? 2.5 : 2}
      />
    ),
  },
  {
    name: "Giỏ hàng",
    path: "/cart",
    icon: ({ active }: { active?: boolean }) => {
      const cart = useAtomValue(cartState);
      return (
        <div className="relative">
          {cart.length > 0 && (
            <div className="absolute -top-1.5 left-3.5 min-w-[16px] h-4 px-1 rounded-full bg-danger text-white text-[9px] leading-4 font-bold text-center shadow-sm">
              {cart.length > 9 ? "9+" : cart.length}
            </div>
          )}
          <CartIcon active={active} />
        </div>
      );
    },
  },
  {
    name: "Thành viên",
    path: "/profile",
    icon: ({ active }: { active?: boolean }) => (
      <ProfileIcon active={active} />
    ),
  },
];

export default function Footer() {
  const location = useLocation();

  return (
    <div
      className="w-full bg-card border-t border-border"
      style={{
        paddingBottom: `max(8px, env(safe-area-inset-bottom))`,
      }}
    >
      <div
        className="w-full px-2 pt-1 grid"
        style={{
          gridTemplateColumns: `repeat(${NAV_ITEMS.length}, 1fr)`,
        }}
      >
        {NAV_ITEMS.map((item) => {
          const isActive = item.exact
            ? location.pathname === item.path
            : location.pathname.startsWith(item.path);

          return (
            <TransitionLink
              to={item.path}
              key={item.path}
              className="flex flex-col items-center gap-0.5 py-2 px-1 cursor-pointer active:scale-90 transition-transform duration-150 relative"
            >
              {() => (
                <>
                  {/* Active indicator dot */}
                  {isActive && (
                    <div className="absolute top-1 w-1 h-1 rounded-full bg-gold" />
                  )}
                  <div className="w-6 h-6 flex justify-center items-center">
                    <item.icon active={isActive} />
                  </div>
                  <div
                    className={`text-2xs font-medium transition-colors ${
                      isActive ? "text-primary font-semibold" : "text-inactive"
                    }`}
                  >
                    {item.name}
                  </div>
                </>
              )}
            </TransitionLink>
          );
        })}
      </div>
    </div>
  );
}
