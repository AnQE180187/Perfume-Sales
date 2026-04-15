import ProductGrid from "@/components/product-grid";
import Section from "@/components/section";
import { useAtomValue } from "jotai";
import { atom } from "jotai";
import { unwrap } from "jotai/utils";
import axiosClient from "@/services/axiosClient";
import { categoriesState } from "@/state";

// Fetch best selling products (sorted by sold count)
const bestSellersRawState = atom(async (get) => {
  try {
    const categories: any[] = await get(categoriesState);
    const res = await axiosClient.get("/products?isBestseller=true&take=8");
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

const bestSellersState = unwrap(bestSellersRawState, (prev) => prev ?? []);

export default function BestSellers() {
  const products = useAtomValue(bestSellersState);

  if (!products.length) return null;

  return (
    <Section title="Bán chạy nhất" viewMoreTo="/flash-sales">
      <ProductGrid products={products} />
    </Section>
  );
}
