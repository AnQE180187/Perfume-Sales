import { useAtom, useAtomValue, useSetAtom } from "jotai";
import { MutableRefObject, useLayoutEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { UIMatch, useMatches } from "react-router-dom";
import { cartState, cartTotalState } from "@/state";
import { paymentMethodState } from "@/pages/cart/payment-method";
import { Cart, CartItem, Product, SelectedOptions } from "@/types";
import axiosClient from "@/services/axiosClient";
import { getDefaultOptions, isIdentical } from "@/utils/cart";
import { getConfig } from "@/utils/template";
import { openChat, purchase } from "zmp-sdk";

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
  const editing = useMemo(
    () => cart.find((item) => item.id === editingCartItemId),
    [cart, editingCartItemId]
  );

  const [options, setOptions] = useState<SelectedOptions>(
    editing ? editing.options : getDefaultOptions(product)
  );

  function handleReplace(quantity: number, cart: Cart, editing: CartItem) {
    if (quantity === 0) {
      // the user wants to remove this item.
      cart.splice(cart.indexOf(editing), 1);
    } else {
      const existed = cart.find(
        (item) =>
          item.id != editingCartItemId &&
          item.product.id === product.id &&
          isIdentical(item.options, options)
      );
      if (existed) {
        // there's another identical item in the cart; let's remove it and update the quantity in the editing item.
        cart.splice(cart.indexOf(existed), 1);
      }
      cart.splice(cart.indexOf(editing), 1, {
        ...editing,
        options,
        quantity: existed
          ? existed.quantity + quantity // updating the quantity of the identical item.
          : quantity,
      });
    }
  }

  function handleAppend(quantity: number, cart: Cart) {
    const existed = cart.find(
      (item) =>
        item.product.id === product.id && isIdentical(item.options, options)
    );
    if (existed) {
      // merging with another identical item in the cart.
      cart.splice(cart.indexOf(existed), 1, {
        ...existed,
        quantity: existed.quantity + quantity,
      });
    } else {
      // this item is new, appending it to the cart.
      cart.push({
        id: cart.length + 1,
        product,
        options,
        quantity,
      });
    }
  }

  const addToCart = (quantity: number) => {
    setCart((cart) => {
      const res = [...cart];
      if (editing) {
        handleReplace(quantity, res, editing);
      } else {
        handleAppend(quantity, res);
      }
      return res;
    });
  };

  return { addToCart, options, setOptions };
}

export function useCustomerSupport() {
  return () =>
    openChat({
      type: "oa",
      id: getConfig((config) => config.template.oaIDtoOpenChat),
    });
}

export function useToBeImplemented() {
  return () =>
    toast("Chức năng dành cho các bên tích hợp phát triển...", {
      icon: "🛠️",
    });
}

export function useCheckout() {
  const { totalAmount } = useAtomValue(cartTotalState);
  const paymentMethod = useAtomValue(paymentMethodState);
  const [cart, setCart] = useAtom(cartState);
  const [isLoading, setIsLoading] = useState(false);

  return async () => {
    try {
      setIsLoading(true);
      
      // 1. Sync cart up to Backend
      for (const item of cart) {
        let variantId = item.product.variants?.[0]?.id;
        if (item.options?.size && item.product.variants) {
           const match = item.product.variants.find((v: any) => v.label === item.options.size || `${v.volume}ml` === item.options.size);
           if (match) variantId = match.id;
        }

        if (!variantId) {
           // fallback if missing variant
           variantId = item.product.variants?.[0]?.id;
        }
        
        if (variantId) {
          await axiosClient.post("/cart/items", {
            variantId,
            quantity: item.quantity
          });
        }
      }

      // 2. Place Order
      const res = await axiosClient.post("/orders", {
         paymentMethod: paymentMethod === "PAYOS" ? "ONLINE" : "COD",
         shippingAddress: "Zalo Mini App Address"
      });

      if (paymentMethod === "PAYOS") {
        toast.success("Đang chuyển hướng sang trang thanh toán QR...");
        // Thực tế backend sẽ trả về payosUrl
        if (res.data?.paymentUrl) {
           window.location.href = res.data.paymentUrl;
        }
      } else {
        toast.success("Đặt hàng thành công bằng COD. Cảm ơn bạn!", {
          icon: "🎉",
        });
        setCart([]);
      }
    } catch (error) {
      toast.error(
        "Đặt hàng thất bại. Vui lòng kiểm tra nội dung lỗi."
      );
    } finally {
      setIsLoading(false);
    }
  };
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
