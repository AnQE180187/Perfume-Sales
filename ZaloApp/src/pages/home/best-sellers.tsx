import { useEffect, useState } from "react";
import axiosClient from "@/services/axiosClient";
import { useAtomValue } from "jotai";
import { categoriesState } from "@/state";
import { TrendingUp } from "lucide-react";
import ProductItem from "@/components/product-item";

export default function BestSellers() {
  const categories = useAtomValue(categoriesState);
  const [products, setProducts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchBestSellers = async () => {
      try {
        setLoading(true);
        const res = await axiosClient.get(`/products/top-selling?take=8`);
        const response = res as any;
        const items = response?.items || response?.products || (Array.isArray(response) ? response : []);

        const formattedItems = items.map((p: any) => ({
          ...p,
          image: p.images?.[0]?.url || p.image || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg",
          price: p.variants?.[0]?.price || p.price || 0,
          sizes: p.variants ? p.variants.map((v: any) => v.label || `${v.volume}ml`) : (p.sizes || []),
          variants: p.variants,
          category: categories.find((c: any) => c.id === p.categoryId) || { name: "Nước hoa" },
        }));

        setProducts(formattedItems);
      } catch {
        // error
      } finally {
        setLoading(false);
      }
    };
    fetchBestSellers();
  }, [categories]);

  if (loading) {
    return (
      <div className="px-4 py-4">
        <div className="flex items-center gap-2 mb-3">
          <div className="w-32 h-5 bg-skeleton rounded animate-pulse" />
        </div>
        <div className="flex gap-4 overflow-x-hidden">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="flex-none w-[160px]">
              <div className="aspect-square rounded-2xl bg-skeleton animate-pulse" />
              <div className="mt-2 h-3 w-3/4 bg-skeleton rounded animate-pulse" />
              <div className="mt-1 h-3 w-1/2 bg-skeleton rounded animate-pulse" />
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (products.length === 0) return null;

  return (
    <div className="py-4">
      {/* Section header */}
      <div className="px-4 flex items-center gap-2 mb-3">
        <TrendingUp size={14} className="text-gold" />
        <span className="text-sm font-bold text-foreground tracking-wide uppercase">Bán chạy nhất</span>
      </div>
      
      {/* Horizontal Scroll Product List */}
      <div 
        className="flex gap-4 overflow-x-auto px-4 pb-2"
        style={{ scrollbarWidth: 'none' }}
      >
        {products.map((product, idx) => (
          <div key={`${product.id}-${idx}`} className="flex-none w-[160px]">
            <ProductItem product={product} />
          </div>
        ))}
      </div>
    </div>
  );
}
