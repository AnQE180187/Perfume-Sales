import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useSetAtom } from "jotai";
import toast from "react-hot-toast";
import { authService } from "@/services/auth.service";
import { systemUserState } from "@/state";
import { Sparkles, Mail, Lock, User, Phone } from "lucide-react";
import Button from "@/components/button";

export default function LoginPage() {
  const navigate = useNavigate();
  const setSystemUser = useSetAtom(systemUserState);
  const [loading, setLoading] = useState(false);
  const [isRegister, setIsRegister] = useState(false);

  // Form states
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [phone, setPhone] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      toast.error("Vui lòng nhập email và mật khẩu");
      return;
    }

    try {
      setLoading(true);
      let user;
      if (isRegister) {
        if (!fullName) {
          toast.error("Vui lòng nhập họ tên");
          return;
        }
        await authService.registerWithEmail({ email, password, fullName, phone });
        toast.success("Đăng ký thành công!", { icon: "🎉" });
        // Automatically login to retrieve the access token, since register only returns success
        user = await authService.loginWithEmail(email, password);
      } else {
        user = await authService.loginWithEmail(email, password);
        toast.success("Đăng nhập thành công!", { icon: "🎉" });
      }

      if (user) {
        localStorage.setItem("hasLoggedIn", "true");
        setSystemUser(user);
        navigate("/");
      }
    } catch (err: any) {
      toast.error(err?.response?.data?.message || err.message || "Có lỗi xảy ra. Vui lòng thử lại.");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSocialLogin = (provider: string) => {
    toast("Tính năng đang được phát triển!", { icon: "🚧" });
  };

  return (
    <div className="w-screen h-screen flex flex-col items-center bg-background text-foreground relative overflow-y-auto overflow-x-hidden px-6 pt-12 pb-6">
      {/* Decorative blobs */}
      <div className="absolute top-[-80px] right-[-80px] w-64 h-64 bg-primary/20 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-[-80px] left-[-80px] w-64 h-64 bg-gold/20 rounded-full blur-3xl pointer-events-none" />

      <div className="z-10 flex flex-col items-center max-w-sm w-full">
        {/* Logo */}
        <div className="w-20 h-20 mb-4 rounded-3xl bg-gradient-to-tr from-primary to-gold flex items-center justify-center shadow-xl shadow-primary/30">
          <Sparkles className="text-white w-8 h-8" />
        </div>

        <h1 className="text-3xl tracking-widest font-serif text-center mb-1">PerfumeGPT</h1>
        <p className="text-center text-sm text-subtitle mb-8">
          Hương thơm dành riêng cho bạn
        </p>

        {/* Tab Toggle */}
        <div className="flex w-full bg-gray-100 rounded-xl p-1 mb-6">
          <button
            className={`flex-1 py-2 text-sm font-semibold rounded-lg transition-all ${!isRegister ? "bg-white shadow-sm text-primary" : "text-gray-500"}`}
            onClick={() => setIsRegister(false)}
          >
            Đăng nhập
          </button>
          <button
            className={`flex-1 py-2 text-sm font-semibold rounded-lg transition-all ${isRegister ? "bg-white shadow-sm text-primary" : "text-gray-500"}`}
            onClick={() => setIsRegister(true)}
          >
            Đăng ký
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="w-full space-y-4">
          {isRegister && (
            <div className="relative">
              <User className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="text"
                placeholder="Họ và tên"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>
          )}

          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
            />
          </div>

          {isRegister && (
             <div className="relative">
              <Phone className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="tel"
                placeholder="Số điện thoại (tùy chọn)"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>
          )}

          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="password"
              placeholder="Mật khẩu"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
            />
          </div>

          <button
            type="submit"
            className={`w-full flex justify-center items-center gap-2 bg-primary text-white py-3.5 rounded-xl font-bold uppercase tracking-wider text-sm shadow-lg shadow-primary/30 transition-all mt-2 ${
              loading ? "opacity-70 pointer-events-none scale-95" : "hover:bg-primary/90 active:scale-95"
            }`}
            disabled={loading}
          >
            {loading ? (
              <span className="flex items-center gap-2">
                <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                Đang xử lý...
              </span>
            ) : (
              isRegister ? "Tạo tài khoản" : "Đăng nhập"
            )}
          </button>
        </form>

        <div className="w-full mt-6 flex items-center justify-between">
          <hr className="w-full border-gray-200" />
          <span className="p-2 text-xs text-gray-400 whitespace-nowrap">Hoặc tiếp tục với</span>
          <hr className="w-full border-gray-200" />
        </div>

        <div className="w-full flex gap-3 mt-4">
          <button onClick={() => handleSocialLogin('google')} className="flex-1 py-2.5 bg-white border border-gray-200 rounded-xl flex justify-center items-center active:bg-gray-50 transition">
            <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" className="w-5 h-5" />
          </button>
          <button onClick={() => handleSocialLogin('facebook')} className="flex-1 py-2.5 bg-white border border-gray-200 rounded-xl flex justify-center items-center active:bg-gray-50 transition">
            <img src="https://www.svgrepo.com/show/475647/facebook-color.svg" alt="Facebook" className="w-5 h-5" />
          </button>
        </div>

      </div>
    </div>
  );
}
