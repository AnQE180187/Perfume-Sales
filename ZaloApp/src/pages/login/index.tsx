import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useSetAtom } from "jotai";
import toast from "react-hot-toast";
import { authService } from "@/services/auth.service";
import { systemUserState } from "@/state";
import { Sparkles, Mail, Lock, User, Phone, Eye, EyeOff } from "lucide-react";

export default function LoginPage() {
  const navigate = useNavigate();
  const setSystemUser = useSetAtom(systemUserState);
  const [loading, setLoading] = useState(false);
  const [loadingZalo, setLoadingZalo] = useState(false);
  const [isRegister, setIsRegister] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

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
        toast.success("Đăng ký thành công! ✨");
        user = await authService.loginWithEmail(email, password);
      } else {
        user = await authService.loginWithEmail(email, password);
        toast.success("Chào mừng bạn trở lại! 🌸");
      }

      if (user) {
        localStorage.setItem("hasLoggedIn", "true");
        setSystemUser(user);
        navigate("/");
      }
    } catch (err: any) {
      toast.error(err?.response?.data?.message || err.message || "Có lỗi xảy ra. Vui lòng thử lại.");
    } finally {
      setLoading(false);
    }
  };

  const handleZaloLogin = async () => {
    try {
      setLoadingZalo(true);
      const user = await authService.loginZalo();
      if (user) {
        localStorage.setItem("hasLoggedIn", "true");
        setSystemUser(user);
        toast.success("Đăng nhập Zalo thành công! ✨");
        navigate("/");
      }
    } catch (err: any) {
      if (err.code === -1401 || err.code === -201) {
        toast.error("Vui lòng cấp quyền truy cập Zalo để tiếp tục.");
      } else {
        toast.error(err?.response?.data?.message || err.message || "Có lỗi xảy ra khi đăng nhập Zalo.");
      }
    } finally {
      setLoadingZalo(false);
    }
  };

  return (
    <div
      className="w-screen min-h-screen flex flex-col items-center relative overflow-hidden"
      style={{ background: "#FAF8F5" }}
    >
      {/* Decorative background */}
      <div
        className="absolute top-0 left-0 right-0 h-72"
        style={{
          background: "linear-gradient(160deg, #1a1a2e 0%, #2d2d52 60%, #1a1a2e 100%)",
        }}
      />
      <div
        className="absolute top-[-60px] right-[-60px] w-56 h-56 rounded-full opacity-30"
        style={{
          background: "radial-gradient(circle, rgba(212,175,55,0.4) 0%, transparent 70%)",
        }}
      />
      <div
        className="absolute top-20 left-[-40px] w-40 h-40 rounded-full opacity-20"
        style={{
          background: "radial-gradient(circle, rgba(212,175,55,0.3) 0%, transparent 70%)",
        }}
      />

      <div className="relative z-10 flex flex-col items-center w-full max-w-sm px-6 pt-16 pb-8">
        {/* Logo */}
        <div
          className="w-20 h-20 mb-6 rounded-3xl flex items-center justify-center shadow-2xl"
          style={{
            background: "linear-gradient(135deg, #E2D1B3, #D4AF37)",
            boxShadow: "0 8px 32px rgba(212,175,55,0.35)",
          }}
        >
          <Sparkles className="text-primary w-9 h-9" />
        </div>

        <h1
          className="text-3xl font-bold text-white text-center mb-1 tracking-tight"
          style={{ fontFamily: "'Playfair Display', serif" }}
        >
          PerfumeGPT
        </h1>
        <p className="text-center text-sm text-white/60 mb-8">
          Hương thơm dành riêng cho bạn
        </p>

        {/* Card */}
        <div
          className="w-full rounded-3xl p-6 shadow-luxury"
          style={{
            background: "#FFFFFF",
            boxShadow: "0 16px 48px rgba(0,0,0,0.12)",
          }}
        >
          {/* Tab Toggle */}
          <div
            className="flex w-full rounded-2xl p-1 mb-6"
            style={{ background: "#F0ECE6" }}
          >
            <button
              className={`flex-1 py-2.5 text-sm font-bold rounded-xl transition-all duration-200 ${
                !isRegister
                  ? "bg-white text-primary shadow-luxury-sm"
                  : "text-subtitle"
              }`}
              onClick={() => setIsRegister(false)}
            >
              Đăng nhập
            </button>
            <button
              className={`flex-1 py-2.5 text-sm font-bold rounded-xl transition-all duration-200 ${
                isRegister
                  ? "bg-white text-primary shadow-luxury-sm"
                  : "text-subtitle"
              }`}
              onClick={() => setIsRegister(true)}
            >
              Đăng ký
            </button>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-3">
            {isRegister && (
              <div className="relative">
                <User
                  className="absolute left-3.5 top-1/2 -translate-y-1/2 text-inactive"
                  size={16}
                />
                <input
                  type="text"
                  placeholder="Họ và tên"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="w-full border rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 transition-all"
                  style={{
                    background: "#FAF8F5",
                    borderColor: "rgba(0,0,0,0.1)",
                    color: "#0D0D0D",
                  }}
                />
              </div>
            )}

            <div className="relative">
              <Mail
                className="absolute left-3.5 top-1/2 -translate-y-1/2 text-inactive"
                size={16}
              />
              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full border rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none transition-all"
                style={{
                  background: "#FAF8F5",
                  borderColor: "rgba(0,0,0,0.1)",
                  color: "#0D0D0D",
                }}
              />
            </div>

            {isRegister && (
              <div className="relative">
                <Phone
                  className="absolute left-3.5 top-1/2 -translate-y-1/2 text-inactive"
                  size={16}
                />
                <input
                  type="tel"
                  placeholder="Số điện thoại (tùy chọn)"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full border rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none transition-all"
                  style={{
                    background: "#FAF8F5",
                    borderColor: "rgba(0,0,0,0.1)",
                    color: "#0D0D0D",
                  }}
                />
              </div>
            )}

            <div className="relative">
              <Lock
                className="absolute left-3.5 top-1/2 -translate-y-1/2 text-inactive"
                size={16}
              />
              <input
                type={showPassword ? "text" : "password"}
                placeholder="Mật khẩu"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full border rounded-xl py-3 pl-10 pr-10 text-sm focus:outline-none transition-all"
                style={{
                  background: "#FAF8F5",
                  borderColor: "rgba(0,0,0,0.1)",
                  color: "#0D0D0D",
                }}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3.5 top-1/2 -translate-y-1/2 text-inactive"
              >
                {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full flex justify-center items-center gap-2 py-3.5 rounded-xl font-bold text-sm tracking-wider uppercase transition-all duration-200 mt-2 active:scale-95"
              style={{
                background: loading
                  ? "#E8E0D5"
                  : "linear-gradient(135deg, #E2D1B3, #D4AF37)",
                color: "#1a1a2e",
                boxShadow: loading ? "none" : "0 4px 16px rgba(212,175,55,0.35)",
              }}
            >
              {loading ? (
                <span className="flex items-center gap-2">
                  <span className="w-4 h-4 border-2 border-primary/40 border-t-primary rounded-full animate-spin" />
                  Đang xử lý...
                </span>
              ) : isRegister ? (
                "Tạo tài khoản"
              ) : (
                "Đăng nhập"
              )}
            </button>
          </form>

          {/* Divider */}
          <div className="flex items-center gap-3 my-5">
            <div className="flex-1 h-px" style={{ background: "rgba(0,0,0,0.08)" }} />
            <span className="text-2xs text-inactive">hoặc</span>
            <div className="flex-1 h-px" style={{ background: "rgba(0,0,0,0.08)" }} />
          </div>

          <button
            type="button"
            onClick={handleZaloLogin}
            disabled={loadingZalo}
            className="w-full flex justify-center items-center gap-2 py-3.5 rounded-xl font-bold text-sm transition-all duration-200 active:scale-95"
            style={{
              background: loadingZalo ? "#E8E0D5" : "#0068FF",
              color: "#FFFFFF",
              boxShadow: loadingZalo ? "none" : "0 4px 16px rgba(0,104,255,0.25)",
            }}
          >
            {loadingZalo ? (
              <span className="flex items-center gap-2">
                <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                Đang xử lý...
              </span>
            ) : (
              <>
                <img
                  src="https://upload.wikimedia.org/wikipedia/commons/a/a1/Logo_Zalo.svg"
                  alt="Zalo"
                  className="w-5 h-5 bg-white rounded-full p-0.5"
                />
                Đăng nhập nhanh bằng Zalo
              </>
            )}
          </button>        </div>

        <p className="text-2xs text-white/40 text-center mt-6 px-4">
          Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của PerfumeGPT.
        </p>
      </div>
    </div>
  );
}
