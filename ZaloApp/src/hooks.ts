import { useAtom, useAtomValue } from "jotai";
import { MutableRefObject, useLayoutEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { UIMatch, useMatches } from "react-router-dom";
import {
  appliedPromotionCodeState,
  appliedPromotionDiscountState,
  cartState,
  redeemPointsDiscountState,
  redeemPointsState,
  selectedCartItemIdsState,
  systemUserState,
} from "@/state";
import { paymentMethodState } from "@/pages/cart/payment-method";
import { Cart, CartItem, Product, SelectedOptions } from "@/types";
import axiosClient from "@/services/axiosClient";
import { getDefaultOptions, isIdentical } from "@/utils/cart";
import { AxiosError } from "axios";

export function useRealHeight(
  element: MutableRefObject<HTMLDivElement | null>,
  defaultValue?: number
) {
  const [height, setHeight] = useState(defaultValue ?? 0);
  useLayoutEffect(() => {
    if (element.current && typeof ResizeObserver !== "undefined") {
      const ro = new ResizeObserver((entries: ResizeObserverEntry[]) => {
        const [{ contentRect }] = entries;
        setHeight(contentRect.height);
      });
      ro.observe(element.current);
      return () => ro.disconnect();
    }
    return () => {};
  }, [element.current]);

  if (typeof ResizeObserver === "undefined") {
    return -1;
  }
  return height;
}

export function useAddToCart(product: Product, editingCartItemId?: number) {
  const [cart, setCart] = useAtom(cartState);
  const editing = useMemo(() => cart.find((item) => item.id === editingCartItemId), [cart, editingCartItemId]);

  const [options, setOptions] = useState<SelectedOptions>(
    editing ? editing.options : getDefaultOptions(product)
  );

  function handleReplace(quantity: number, nextCart: Cart, editingItem: CartItem) {
    if (quantity === 0) {
      nextCart.splice(nextCart.indexOf(editingItem), 1);
    } else {
      const existed = nextCart.find(
        (item) =>
          item.id != editingCartItemId &&
          item.product.id === product.id &&
          isIdentical(item.options, options)
      );
      if (existed) {
        nextCart.splice(nextCart.indexOf(existed), 1);
      }
      nextCart.splice(nextCart.indexOf(editingItem), 1, {
        ...editingItem,
        options,
        quantity: existed ? existed.quantity + quantity : quantity,
      });
    }
  }

  function handleAppend(quantity: number, nextCart: Cart) {
    const existed = nextCart.find((item) => item.product.id === product.id && isIdentical(item.options, options));
    if (existed) {
      nextCart.splice(nextCart.indexOf(existed), 1, {
        ...existed,
        quantity: existed.quantity + quantity,
      });
    } else {
      nextCart.push({
        id: nextCart.length + 1,
        product,
        options,
        quantity,
      });
    }
  }

  const syncServerCart = async () => {
    const response: any = await axiosClient.get("/cart");
    const serverItems = response?.items || [];
    const normalized: Cart = serverItems.map((item: any) => ({
      id: item.id,
      quantity: item.quantity,
      options: {
        size: item.variant?.name,
      },
      product: {
        id: item.variant?.product?.id,
        name: item.variant?.product?.name || "Sản phẩm",
        price: Number(item.variant?.price || 0),
        image: item.variant?.product?.images?.[0]?.url || "https://file.hstatic.net/1000388226/file/nuoc-hoa-thu-hut-phai-dep.jpg",
        category: { id: 0, name: "", image: "" },
      } as any,
    }));
    setCart(normalized);
  };

  const addToCart = async (quantity: number) => {
    try {
      if (editingCartItemId) {
        if (quantity <= 0) {
          await axiosClient.delete(`/cart/items/${editingCartItemId}`);
        } else {
          await axiosClient.patch(`/cart/items/${editingCartItemId}`, { quantity });
        }
        await syncServerCart();
        return;
      }

      let variantId = (product as any)?.variants?.[0]?.id;
      if (options.size && (product as any)?.variants) {
        const match = (product as any).variants.find(
          (v: any) => v.label === options.size || `${v.volume}ml` === options.size || v.name === options.size
        );
        if (match) variantId = match.id;
      }
      if (!variantId) {
        toast.error("Không tìm thấy phiên bản sản phẩm phù hợp");
        return;
      }

      await axiosClient.post("/cart/items", {
        variantId,
        quantity: Math.max(1, quantity),
      });
      await syncServerCart();
    } catch (error) {
      const message =
        (error as AxiosError<any>)?.response?.data?.message ||
        "Thêm vào giỏ hàng thất bại. Vui lòng thử lại.";
      toast.error(typeof message === "string" ? message : "Thêm vào giỏ hàng thất bại");
    }
  };

  return { addToCart, options, setOptions, syncServerCart };
}

export function useCustomerSupport() {
  return () => toast("Tạm thời chưa bật hỗ trợ OA trong mini app", { icon: "ℹ️" });
}

export function useToBeImplemented() {
  return () =>
    toast("Chức năng dành cho các bên tích hợp phát triển...", {
      icon: "🛠️",
    });
}

export function useCheckout(options?: { onMissingAddress?: () => void }) {
  const paymentMethod = useAtomValue(paymentMethodState);
  const selectedCartItemIds = useAtomValue(selectedCartItemIdsState);
  const systemUser = useAtomValue(systemUserState);
  const [cart, setCart] = useAtom(cartState);
  const [, setSelectedIds] = useAtom(selectedCartItemIdsState);
  const [promotionCode, setPromotionCode] = useAtom(appliedPromotionCodeState);
  const [, setPromotionDiscount] = useAtom(appliedPromotionDiscountState);
  const [redeemPoints, setRedeemPoints] = useAtom(redeemPointsState);
  const [, setRedeemPointsDiscount] = useAtom(redeemPointsDiscountState);
  const [isCheckingOut, setIsCheckingOut] = useState(false);

  const checkout = async () => {
    if (isCheckingOut) return;
    try {
      setIsCheckingOut(true);
      if (!selectedCartItemIds.length) {
        toast.error("Vui lòng chọn ít nhất 1 sản phẩm để thanh toán");
        return;
      }

      const addressesRes: any = await axiosClient.get("/addresses");
      const addresses: any[] = Array.isArray(addressesRes)
        ? addressesRes
        : addressesRes?.data || addressesRes?.items || [];
      const defaultAddress = addresses.find((addr) => addr.isDefault) || addresses[0];
      if (!defaultAddress) {
        toast.error("Vui lòng thêm địa chỉ nhận hàng trước khi thanh toán");
        options?.onMissingAddress?.();
        return;
      }

      const shippingAddress =
        [
          defaultAddress.detailAddress,
          defaultAddress.wardName,
          defaultAddress.districtName,
          defaultAddress.provinceName,
        ]
          .filter(Boolean)
          .join(", ") || "Địa chỉ nhận hàng";

      const order: any = await axiosClient.post("/orders", {
        cartItemIds: selectedCartItemIds,
        paymentMethod: paymentMethod === "PAYOS" ? "ONLINE" : "COD",
        shippingAddress,
        shippingProvinceId: Number(defaultAddress.provinceId) || undefined,
        shippingDistrictId: Number(defaultAddress.districtId) || undefined,
        shippingWardCode: defaultAddress.wardCode || undefined,
        recipientName: defaultAddress.recipientName || systemUser?.fullName || "Khách hàng",
        phone: defaultAddress.phone || systemUser?.phone || "",
        promotionCode: promotionCode || undefined,
        redeemPoints: redeemPoints > 0 ? redeemPoints : undefined,
      });

      if (paymentMethod === "PAYOS") {
        const payment: any = await axiosClient.post("/payments/create-payment", { orderId: order.id });
        const checkoutUrl = payment?.checkoutUrl || payment?.data?.checkoutUrl;
        if (checkoutUrl) {
          window.location.href = checkoutUrl;
        } else {
          toast.error("Không lấy được liên kết thanh toán");
        }
      } else {
        toast.success("Đặt hàng COD thành công!", { icon: "🎉" });
      }

      const remaining = cart.filter((item) => !selectedCartItemIds.includes(item.id));
      setCart(remaining);
      setSelectedIds([]);
      setPromotionCode("");
      setPromotionDiscount(0);
      setRedeemPoints(0);
      setRedeemPointsDiscount(0);
    } catch (error) {
      const message =
        (error as AxiosError<any>)?.response?.data?.message ||
        "Đặt hàng thất bại. Vui lòng thử lại.";
      toast.error(typeof message === "string" ? message : "Đặt hàng thất bại");
    } finally {
      setIsCheckingOut(false);
    }
  };

  return { checkout, isCheckingOut };
}

export function useRouteHandle() {
  const matches = useMatches() as UIMatch<
    undefined,
    {
      title?: string | Function;
      logo?: boolean;
      back?: boolean;
      scrollRestoration?: number;
    }
  >[];
  const lastMatch = matches[matches.length - 1];

  return [lastMatch.handle, lastMatch, matches] as const;
}
