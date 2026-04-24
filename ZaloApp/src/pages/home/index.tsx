import { useNavigate } from "react-router-dom";
import Banners from "./banners";
import BestSellers from "./best-sellers";
import AllProducts from "./all-products";
import NewArrivals from "./new-arrivals";
import AiCta from "./ai-cta";
import { Suspense } from "react";
import { Search } from "lucide-react";

function HomeHeader() {
  const navigate = useNavigate();
  return (
    <div className="px-4 pt-4 pb-3 flex items-center gap-3">
      {/* Brand */}
      <div className="flex-1">
        <div className="text-2xs text-subtitle tracking-widest uppercase font-medium">
          Chào mừng bạn 👋
        </div>
        <div
          className="text-xl font-bold text-foreground tracking-tight"
          style={{ fontFamily: "'Playfair Display', serif" }}
        >
          PerfumeGPT
        </div>
      </div>
      {/* Action buttons */}
      <button
        id="btn-search"
        onClick={() => navigate("/search")}
        className="w-10 h-10 rounded-2xl flex items-center justify-center active:scale-90 transition-transform"
        style={{ background: "#F0ECE6", border: "1px solid rgba(212,175,55,0.2)" }}
      >
        <Search size={18} className="text-foreground" />
      </button>
    </div>
  );
}

const Divider = () => (
  <div
    className="mx-4 my-1"
    style={{ height: "1px", background: "rgba(212,175,55,0.15)" }}
  />
);

export default function HomePage() {
  const navigate = useNavigate();

  return (
    <div className="min-h-full" style={{ background: "#FAF8F5" }}>
      {/* Header */}
      <HomeHeader />

      {/* Banners */}
      <Suspense fallback={
        <div className="px-4 pb-3">
          <div className="w-full rounded-3xl bg-skeleton animate-pulse" style={{ aspectRatio: "16/7" }} />
        </div>
      }>
        <Banners />
      </Suspense>

      {/* AI CTA Banner */}
      <AiCta />

      {/* New Arrivals - Horizontal */}
      <Divider />
      <Suspense fallback={null}>
        <NewArrivals />
      </Suspense>

      {/* Best Sellers - Horizontal */}
      <Divider />
      <Suspense fallback={null}>
        <BestSellers />
      </Suspense>

      {/* All Products - Infinite Scroll */}
      <Divider />
      <Suspense fallback={null}>
        <AllProducts />
      </Suspense>

      {/* Bottom spacer */}
      <div className="h-4" />
    </div>
  );
}
