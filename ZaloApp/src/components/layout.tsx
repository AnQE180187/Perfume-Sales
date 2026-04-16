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
      <div className="w-screen h-screen bg-background p-4 flex flex-col">
        <PageSkeleton />
      </div>
    );
  }

  return (
    <div className="w-screen h-screen flex flex-col bg-background text-foreground">
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
