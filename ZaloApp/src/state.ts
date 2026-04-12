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

// Atom to trigger initialization (login & fetch base data)
export const appInitState = atom(
  (get) => get(systemUserState),
  async (get, set) => {
    try {
      console.log("Initializing App & Zalo Login...");
      const sysUser = await authService.login();
      if (sysUser) {
        set(systemUserState, sysUser);
      }
    } catch (error) {
      console.error("Initialization Failed:", error);
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
    const res = await axiosClient.get("/products");
    const response = res.data || res;
    const items = response.products || response; // Handle both list Public schema and mock array
    return items.map((p: any) => ({
      ...p,
      image: p.images?.[0]?.url || p.image || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg",
      price: p.variants?.[0]?.price || p.price || 0,
      sizes: p.variants ? p.variants.map((v: any) => v.label || `${v.volume}ml`) : p.sizes,
      description: p.description,
      variants: p.variants,
      category: categories.find((c: any) => c.id === p.categoryId) || { name: 'Chưa có phân loại' } // Safe fallback
    }));
  } catch (err) {
    return [];
  }
});

export const categoriesState = atom(async () => {
  try {
    const res = await axiosClient.get("/catalog/categories");
    return res.data || res || [];
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

export const productState = atomFamily((id: number) =>
  atom(async (get) => {
    const products = await get(productsState);
    return products.find((product) => product.id === id);
  })
);

export const cartState = atom<Cart>([]);

export const selectedCartItemIdsState = atom<number[]>([]);

export const checkoutItemsState = atom((get) => {
  const ids = get(selectedCartItemIdsState);
  const cart = get(cartState);
  return cart.filter((item) => ids.includes(item.id));
});

export const cartTotalState = atom((get) => {
  const items = get(checkoutItemsState);
  return {
    totalItems: items.length,
    totalAmount: items.reduce(
      (total, item) => total + item.product.price * item.quantity,
      0
    ),
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
