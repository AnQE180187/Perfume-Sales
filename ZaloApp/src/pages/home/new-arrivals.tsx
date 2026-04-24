import { useAtomValue } from "jotai";
import { atom } from "jotai";
import { unwrap } from "jotai/utils";
import axiosClient from "@/services/axiosClient";
import { categoriesState } from "@/state";
import TransitionLink from "@/components/transition-link";
import ProductItem from "@/components/product-item";
import { Sparkles } from "lucide-react";

const newArrivalsRawState = atom(async (get) => {
  try {
    const categories: any[] = await get(categoriesState);
    const res = await axiosClient.get("/products?orderBy=createdAt&order=desc&take=6");
    const response = res as any;
    const items = response?.items || response?.products || (Array.isArray(response) ? response : []);

    return items.map((p: any) => ({
      ...p,
      image: p.images?.[0]?.url || p.image || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg",
      price: p.variants?.[0]?.price || p.price || 0,
      sizes: p.variants ? p.variants.map((v: any) => v.label || `${v.volume}ml`) : (p.sizes || []),
      variants: p.variants,
      category: categories.find((c: any) => c.id === p.categoryId) || { name: "Nước hoa" },
    }));
  } catch {
    return [];
  }
});

const newArrivalsState = unwrap(newArrivalsRawState, (prev) => prev ?? []);

export default function NewArrivals() {
  const products = useAtomValue(newArrivalsState);

  if (!products.length) return null;

  return (
    <div className="px-4 py-4">
      {/* Section header */}
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <Sparkles size={14} className="text-gold" />
          <span className="text-sm font-bold text-foreground tracking-wide">Mới nhất</span>
        </div>
        <TransitionLink
          to="/flash-sales"
          className="text-2xs text-gold font-semibold tracking-wider uppercase"
        >
          {() => <>Xem thêm</>}
        </TransitionLink>
      </div>

      {/* Horizontal scroll */}
      <div className="flex gap-3 overflow-x-auto pb-1" style={{ scrollbarWidth: "none" }}>
        {products.map((product) => (
          <div key={product.id} className="flex-none w-36">
            <ProductItem product={product} />
          </div>
        ))}
      </div>
    </div>
  );
}
