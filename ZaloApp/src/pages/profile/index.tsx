import ProfileActions from "./actions";
import FollowOA from "./follow-oa";
import Points from "./points";
import { useAtomValue, useSetAtom } from "jotai";
import { systemUserState, userState } from "@/state";
import { authService } from "@/services/auth.service";
import { useNavigate } from "react-router-dom";
import { LogOut, User } from "lucide-react";
import toast from "react-hot-toast";
import { Suspense } from "react";

function UserHeader() {
  const systemUser = useAtomValue(systemUserState);
  const zaloUser = useAtomValue(userState);
  const setSystemUser = useSetAtom(systemUserState);
  const navigate = useNavigate();

  const displayName = systemUser?.fullName || (zaloUser as any)?.userInfo?.name || "Khách";
  const avatar = systemUser?.avatarUrl || (zaloUser as any)?.userInfo?.avatar;

  const handleLogout = () => {
    authService.logout();
    setSystemUser(null);
    toast.success("Đã đăng xuất");
    navigate("/login");
  };

  return (
    <div className="bg-white rounded-2xl p-4 flex items-center gap-4 border border-black/5 shadow-sm">
      <div className="w-14 h-14 rounded-full overflow-hidden bg-primary/10 flex items-center justify-center flex-shrink-0">
        {avatar ? (
          <img src={avatar} className="w-full h-full object-cover" alt={displayName} />
        ) : (
          <User size={28} className="text-primary" />
        )}
      </div>
      <div className="flex-1 min-w-0">
        <div className="font-bold text-gray-800 truncate">{displayName}</div>
        {systemUser?.phone && (
          <div className="text-xs text-gray-400 mt-0.5">{systemUser.phone}</div>
        )}
        <div className="text-xs text-primary font-medium mt-0.5">
          Thành viên PerfumeGPT
        </div>
      </div>
      <button
        id="btn-logout"
        onClick={handleLogout}
        className="p-2 rounded-xl bg-gray-50 text-gray-400 active:bg-gray-100 transition"
      >
        <LogOut size={18} />
      </button>
    </div>
  );
}

export default function ProfilePage() {
  return (
    <div className="min-h-full bg-section p-4 space-y-3">
      <Suspense fallback={<div className="h-20 bg-white rounded-2xl animate-pulse" />}>
        <UserHeader />
      </Suspense>
      <Points />
      <ProfileActions />
      <FollowOA />
    </div>
  );
}
