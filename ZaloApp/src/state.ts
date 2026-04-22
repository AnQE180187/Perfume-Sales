import { atom } from "jotai";
import { atomFamily, unwrap } from "jotai/utils";
import { Cart, Category, Color, Product } from "@/types";
import { requestWithFallback } from "@/utils/request";
import { getUserInfo } from "zmp-sdk";
import axiosClient from "@/services/axiosClient";

import { authService } from "./services/auth.service";

// Zalo's built-in User Info
export const userState = atom(() =>
  getUserInfo({
    avatarType: "normal",
  })
);

// Backend system's User Info (from Prisma)
export const systemUserState = atom<any | null>(null);

// Atom to trigger initialization (silent re-login & fetch base data)
export const appInitState = atom(
  (get) => get(systemUserState),
  async (get, set) => {
    try {
      const hasLoggedIn = localStorage.getItem("hasLoggedIn");
      if (hasLoggedIn === "true") {
        console.log("Initializing App: Attempting silent re-login...");
        // Use refresh token to silently restore session without Zalo dialog
        const sysUser = await authService.silentReLogin();
        if (sysUser) {
          set(systemUserState, sysUser);
          console.log("Silent re-login successful.");
        } else {
          // Refresh token expired — clear flag so user is redirected to login
          localStorage.removeItem("hasLoggedIn");
        }
      }
    } catch (error) {
      console.error("Initialization Failed:", error);
      localStorage.removeItem("hasLoggedIn");
    }
  }
);

export const bannersState = atom(async () => {
  try {
    const res = await axiosClient.get("/banners");
    const data = res.data || res;
    // Map backend response (which has imageUrl) or fallback to string array
    return data.map((b: any) => typeof b === 'string' ? b : b.imageUrl);
  } catch (err) {
    return [];
  }
});

export const tabsState = atom(["Tất cả", "Nam", "Nữ", "Trẻ em"]);

export const selectedTabIndexState = atom(0);

export const productsState = atom(async (get) => {
  try {
    const categories: any[] = await get(categoriesState);
    // axiosClient interceptor already returns response.data directly
    const response: any = await axiosClient.get("/products");
    // Backend returns { items, total, skip, take }
    const items = response?.items || response?.products || (Array.isArray(response) ? response : []);

    return items.map((p: any) => ({
      ...p,
      image: p.images?.[0]?.url || p.image || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg",
      price: p.variants?.[0]?.price || p.price || 0,
      sizes: p.variants ? p.variants.map((v: any) => v.label || `${v.volume}ml`) : (p.sizes || []),
      description: p.description,
      variants: p.variants,
      category: categories.find((c: any) => c.id === p.categoryId) || p.category || { name: 'Chưa có phân loại' },
    }));
  } catch (err) {
    return [];
  }
});

export const categoriesState = atom(async () => {
  try {
    const res: any = await axiosClient.get("/catalog/categories");
    // axiosClient interceptor returns response.data directly
    return Array.isArray(res) ? res : (res?.data || res || []);
  } catch {
    return [];
  }
});

export const categoriesStateUpwrapped = unwrap(
  categoriesState,
  (prev) => prev ?? []
);



export const flashSaleProductsState = atom((get) => get(productsState));

export const recommendedProductsState = atom((get) => get(productsState));

export const sizesState = atom(["S", "M", "L", "XL"]);

export const selectedSizeState = atom<string | undefined>(undefined);

export const colorsState = atom<Color[]>([
  {
    name: "Đỏ",
    hex: "#FFC7C7",
  },
  {
    name: "Xanh dương",
    hex: "#DBEBFF",
  },
  {
    name: "Xanh lá",
    hex: "#D1F0DB",
  },
  {
    name: "Xám",
    hex: "#D9E2ED",
  },
]);

export const selectedColorState = atom<Color | undefined>(undefined);

export const productState = atomFamily((id: string) =>
  atom(async (get) => {
    if (!id) return undefined;
    try {
      // Fetch directly from API by UUID — instant, no need to wait for full products list
      const res = await axiosClient.get(`/products/${id}`);
      const raw = res as any;
      // Map from backend shape to the UI shape used in this app
      const categories: any[] = await get(categoriesState);
      return {
        ...raw,
        image: raw.images?.[0]?.url || raw.image || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg",
        price: raw.variants?.[0]?.price || raw.price || 0,
        sizes: raw.variants ? raw.variants.map((v: any) => v.label || `${v.volume}ml`) : (raw.sizes || []),
        description: raw.description,
        variants: raw.variants,
        category: categories.find((c: any) => c.id === raw.categoryId) || raw.category || { name: "Nước hoa" },
      };
    } catch {
      // Fallback: search in list cache if direct fetch fails
      const products = await get(productsState);
      return products.find((product) => String(product.id) === String(id));
    }
  })
);

// ===== FILTER ATOMS =====
export const selectedGenderState = atom<string | undefined>(undefined);
export const gendersState = atom([
  { id: 'MALE', label: 'Nam' },
  { id: 'FEMALE', label: 'Nữ' },
  { id: 'UNISEX', label: 'Unisex' }
]);

export const selectedBrandState = atom<string | undefined>(undefined);
export const brandsState = atom(async (get) => {
  const products = await get(productsState);
  const brandNames = Array.from(new Set(products.map((p) => p.brand?.name).filter(Boolean)));
  return brandNames as string[];
});

export type PriceRange = "P1" | "P2" | "P3" | "P4";
export const selectedPriceRangeState = atom<PriceRange | undefined>(undefined);
export const priceRangesState = atom([
  { id: "P1", label: "< 1.500.000" },
  { id: "P2", label: "1.5tr - 3tr" },
  { id: "P3", label: "3tr - 5tr" },
  { id: "P4", label: "> 5.000.000" }
]);

export const filteredProductsState = atom(async (get) => {
  const products = await get(productsState);
  const gender = get(selectedGenderState);
  const brand = get(selectedBrandState);
  const priceRange = get(selectedPriceRangeState);
  const size = get(selectedSizeState);
  const color = get(selectedColorState);

  return products.filter((p) => {
    // Brand filter
    if (brand && p.brand?.name !== brand && p.brand?.id !== Number(brand)) return false;

    // Gender filter
    if (gender) {
      const g = (p.gender || '').toUpperCase();
      if (gender === 'MALE' && g !== 'MALE' && g !== 'MEN' && g !== 'NAM') return false;
      if (gender === 'FEMALE' && g !== 'FEMALE' && g !== 'WOMEN' && g !== 'NU' && g !== 'NỮ') return false;
      if (gender === 'UNISEX' && g !== 'UNISEX' && g !== 'ALL' && g !== '') return false;
    }

    // Price filter (based on minimum variant price or base price)
    if (priceRange) {
      const price = p.price; 
      if (priceRange === 'P1' && price >= 1500000) return false;
      if (priceRange === 'P2' && (price < 1500000 || price > 3000000)) return false;
      if (priceRange === 'P3' && (price <= 3000000 || price > 5000000)) return false;
      if (priceRange === 'P4' && price <= 5000000) return false;
    }

    // Size filter
    if (size && (!p.sizes || !p.sizes.includes(size))) return false;

    // Color filter
    if (color && (!p.colors || !p.colors.some((c: any) => c.name === color.name))) return false;

    return true;
  });
});
// ========================

export const cartState = atom<Cart>([]);

export const selectedCartItemIdsState = atom<number[]>([]);
export const appliedPromotionCodeState = atom<string>("");
export const appliedPromotionDiscountState = atom<number>(0);
export const redeemPointsState = atom<number>(0);
export const redeemPointsDiscountState = atom<number>(0);

export const checkoutItemsState = atom((get) => {
  const ids = get(selectedCartItemIdsState);
  const cart = get(cartState);
  return cart.filter((item) => ids.includes(item.id));
});

export const cartTotalState = atom((get) => {
  const items = get(checkoutItemsState);
  const promotionDiscount = get(appliedPromotionDiscountState);
  const pointsDiscount = get(redeemPointsDiscountState);
  const subtotal = items.reduce(
    (total, item) => total + item.product.price * item.quantity,
    0
  );
  const finalAmount = Math.max(0, subtotal - promotionDiscount - pointsDiscount);
  return {
    totalItems: items.length,
    subtotal,
    promotionDiscount,
    pointsDiscount,
    totalAmount: finalAmount,
  };
});

export const keywordState = atom("");

export const searchResultState = atom(async (get) => {
  const keyword = get(keywordState);
  const products = await get(productsState);
  await new Promise((resolve) => setTimeout(resolve, 1000));
  return products.filter((product) =>
    product.name.toLowerCase().includes(keyword.toLowerCase())
  );
});
