import { Outlet, Navigate, useNavigate } from "react-router-dom";
import Header from "./header";
import Footer from "./footer";
import { Suspense, useEffect, useState } from "react";
import { PageSkeleton } from "./skeleton";
import { Toaster } from "react-hot-toast";
import { ScrollRestoration } from "./scroll-restoration";
import { authService } from "@/services/auth.service";
import { useSetAtom } from "jotai";
import { systemUserState } from "@/state";

export default function Layout() {
  const navigate = useNavigate();
  const [hasLoggedIn, setHasLoggedIn] = useState(() => localStorage.getItem("hasLoggedIn"));
  const [isInitializing, setIsInitializing] = useState(hasLoggedIn === "true");
  const setSystemUser = useSetAtom(systemUserState);

  useEffect(() => {
    if (hasLoggedIn === "true") {
      authService.silentReLogin().then((user) => {
        if (user) {
          setSystemUser(user);
        } else {
          localStorage.removeItem("hasLoggedIn");
          setHasLoggedIn(null);
          navigate("/login", { replace: true });
        }
      }).finally(() => {
        setIsInitializing(false);
      });
    }
  }, [hasLoggedIn, setSystemUser, navigate]);

  if (hasLoggedIn !== "true") {
    return <Navigate to="/login" replace />;
  }

  if (isInitializing) {
    return (
      <div className="w-screen h-screen p-4 flex flex-col items-center justify-center" style={{ background: '#FAF8F5' }}>
        <div
          className="w-12 h-12 rounded-full border-2 animate-spin mb-4"
          style={{ borderColor: 'rgba(212,175,55,0.2)', borderTopColor: '#D4AF37' }}
        />
        <div className="text-sm font-medium" style={{ color: '#D4AF37', fontFamily: "'Playfair Display', serif" }}>PerfumeGPT</div>
      </div>
    );
  }

  return (
    <div className="w-screen h-screen flex flex-col text-foreground" style={{ background: '#FAF8F5' }}>
      <Header />
      <div className="flex-1 overflow-y-auto">
        <Suspense fallback={<PageSkeleton />}>
          <Outlet />
        </Suspense>
      </div>
      <Footer />
      <Toaster
        containerClassName="toast-container"
        containerStyle={{
          top: "calc(50% - 24px)",
        }}
      />
      <ScrollRestoration />
    </div>
  );
}
