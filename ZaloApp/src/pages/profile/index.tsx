import { useAtomValue, useSetAtom } from "jotai";
import { systemUserState, userState } from "@/state";
import { authService } from "@/services/auth.service";
import { useNavigate } from "react-router-dom";
import { LogOut, User, Edit3, Crown } from "lucide-react";
import toast from "react-hot-toast";
import { Suspense } from "react";
import Points from "./points";
import ProfileActions from "./actions";

function UserHeader() {
  const systemUser = useAtomValue(systemUserState);
  const zaloUser = useAtomValue(userState);
  const setSystemUser = useSetAtom(systemUserState);
  const navigate = useNavigate();

  const displayName = systemUser?.fullName || (zaloUser as any)?.userInfo?.name || "Khách";
  const avatar = systemUser?.avatarUrl || (zaloUser as any)?.userInfo?.avatar;
  const email = systemUser?.email;

  const handleLogout = () => {
    authService.logout();
    setSystemUser(null);
    toast.success("Đã đăng xuất");
    navigate("/login");
  };

  return (
    <div
      className="rounded-3xl p-5"
      style={{
        background: "#FFFFFF",
        border: "1px solid rgba(0,0,0,0.06)",
        boxShadow: "0 2px 12px rgba(0,0,0,0.06)",
      }}
    >
      <div className="flex items-center gap-4">
        {/* Avatar */}
        <div className="relative">
          <div
            className="w-16 h-16 rounded-2xl overflow-hidden flex items-center justify-center flex-shrink-0"
            style={{ background: "#F0ECE6", border: "2px solid rgba(212,175,55,0.25)" }}
          >
            {avatar ? (
              <img src={avatar} className="w-full h-full object-cover" alt={displayName} />
            ) : (
              <User size={28} className="text-inactive" />
            )}
          </div>
          {/* Premium indicator */}
          <div
            className="absolute -bottom-1 -right-1 w-5 h-5 rounded-full flex items-center justify-center"
            style={{ background: "linear-gradient(135deg, #E2D1B3, #D4AF37)" }}
          >
            <Crown size={10} className="text-primary" />
          </div>
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          <div className="text-base font-bold text-foreground truncate">{displayName}</div>
          {email && (
            <div className="text-xs text-subtitle truncate mt-0.5">{email}</div>
          )}
          {systemUser?.phone && (
            <div className="text-xs text-subtitle truncate">{systemUser.phone}</div>
          )}
          <div
            className="inline-flex items-center gap-1 mt-1.5 px-2 py-0.5 rounded-full text-2xs font-bold"
            style={{
              background: "rgba(212,175,55,0.1)",
              color: "#D4AF37",
              border: "1px solid rgba(212,175,55,0.2)",
            }}
          >
            <Crown size={8} />
            Thành viên PerfumeGPT
          </div>
        </div>

        {/* Actions */}
        <div className="flex flex-col gap-2">
          <button
            onClick={() => navigate("/profile/edit")}
            className="w-9 h-9 rounded-xl flex items-center justify-center active:scale-90 transition-transform"
            style={{ background: "#F0ECE6" }}
          >
            <Edit3 size={15} className="text-subtitle" />
          </button>
          <button
            id="btn-logout"
            onClick={handleLogout}
            className="w-9 h-9 rounded-xl flex items-center justify-center active:scale-90 transition-transform"
            style={{ background: "#FFF0F0" }}
          >
            <LogOut size={15} className="text-danger" />
          </button>
        </div>
      </div>
    </div>
  );
}

export default function ProfilePage() {
  return (
    <div
      className="min-h-full p-4 space-y-3"
      style={{ background: "#FAF8F5" }}
    >
      <Suspense fallback={
        <div className="h-24 rounded-3xl bg-skeleton animate-pulse" />
      }>
        <UserHeader />
      </Suspense>

      <Points />

      <ProfileActions />

      {/* App version footer */}
      <div className="text-center py-2">
        <div
          className="text-2xs font-medium tracking-widest uppercase"
          style={{ color: "rgba(212,175,55,0.5)" }}
        >
          PerfumeGPT · v1.0
        </div>
      </div>
    </div>
  );
}
