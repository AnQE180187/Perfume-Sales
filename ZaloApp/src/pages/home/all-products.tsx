import { useEffect, useRef, useState, useCallback } from "react";
import axiosClient from "@/services/axiosClient";
import { useAtomValue } from "jotai";
import { categoriesState } from "@/state";
import { Loader2, Sparkles } from "lucide-react";
import ProductItem from "@/components/product-item";

export default function AllProducts() {
  const categories = useAtomValue(categoriesState);
  const [products, setProducts] = useState<any[]>([]);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const observerRef = useRef<IntersectionObserver | null>(null);
  const loaderRef = useRef<HTMLDivElement>(null);

  const fetchProducts = async (pageNumber: number) => {
    try {
      setLoading(true);
      const take = 8;
      const skip = (pageNumber - 1) * take;
      const res = await axiosClient.get(`/products?take=${take}&skip=${skip}`);
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

      if (formattedItems.length < take) {
        setHasMore(false);
      }

      if (pageNumber === 1) {
        setProducts(formattedItems);
      } else {
        setProducts((prev) => {
          const existingIds = new Set(prev.map(p => p.id));
          const newItems = formattedItems.filter((i: any) => !existingIds.has(i.id));
          return [...prev, ...newItems];
        });
      }
    } catch {
      setHasMore(false);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts(1);
  }, []);

  useEffect(() => {
    if (page > 1) {
      fetchProducts(page);
    }
  }, [page]);

  const handleObserver = useCallback(
    (entries: IntersectionObserverEntry[]) => {
      const target = entries[0];
      if (target.isIntersecting && hasMore && !loading) {
        setPage((prev) => prev + 1);
      }
    },
    [hasMore, loading]
  );

  useEffect(() => {
    const option = {
      root: null,
      rootMargin: "20px",
      threshold: 0,
    };
    observerRef.current = new IntersectionObserver(handleObserver, option);
    if (loaderRef.current) observerRef.current.observe(loaderRef.current);
    
    return () => {
      if (observerRef.current) observerRef.current.disconnect();
    };
  }, [handleObserver]);

  return (
    <div className="px-4 py-4">
      {/* Section header */}
      <div className="flex items-center gap-2 mb-3">
        <Sparkles size={14} className="text-gold" />
        <span className="text-sm font-bold text-foreground tracking-wide uppercase">Gợi ý cho bạn</span>
      </div>
      
      {/* Product Grid */}
      <div className="grid grid-cols-2 gap-4">
        {products.map((product) => (
          <ProductItem key={product.id} product={product} />
        ))}
      </div>

      {/* Initial Skeleton */}
      {loading && products.length === 0 && (
        <div className="grid grid-cols-2 gap-4 mt-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i}>
              <div className="aspect-square rounded-2xl bg-skeleton animate-pulse" />
              <div className="mt-2 h-3 w-3/4 bg-skeleton rounded animate-pulse" />
              <div className="mt-1 h-3 w-1/2 bg-skeleton rounded animate-pulse" />
            </div>
          ))}
        </div>
      )}

      {/* Loading Indicator / Sentinel */}
      <div ref={loaderRef} className="w-full flex justify-center py-6">
        {loading && products.length > 0 && (
          <Loader2 className="animate-spin text-gold" size={24} />
        )}
        {!hasMore && products.length > 0 && (
          <span className="text-xs text-subtitle">Đã xem hết sản phẩm</span>
        )}
      </div>
    </div>
  );
}
