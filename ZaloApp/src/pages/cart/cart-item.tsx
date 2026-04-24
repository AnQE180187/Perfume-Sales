import Checkbox from "@/components/checkbox";
import QuantityInput from "@/components/quantity-input";
import { useAddToCart } from "@/hooks";
import { CartItem as CartItemProps } from "@/types";
import { formatPrice } from "@/utils/format";
import { animated, useSpring } from "@react-spring/web";
import { useDrag } from "@use-gesture/react";
import { Trash2 } from "lucide-react";
import { useAtom } from "jotai";
import { selectedCartItemIdsState } from "@/state";
import { useMemo, useState } from "react";

const SWIPE_TO_DELETE_OFFSET = 76;

export default function CartItem(props: CartItemProps) {
  const [quantity, setQuantity] = useState(props.quantity);
  const { addToCart } = useAddToCart(props.product, props.id);
  const [selectedItemIds, setSelectedItemIds] = useAtom(selectedCartItemIdsState);

  const variantLabel = useMemo(
    () => Object.entries({ Size: props.options.size, Color: props.options.color })
      .filter(([_, v]) => v !== undefined)
      .map(([k, v]) => v)
      .join(" · "),
    [props.options]
  );

  const [{ x }, api] = useSpring(() => ({ x: 0 }));
  const bind = useDrag(
    ({ last, offset: [ox] }) => {
      if (last) {
        api.start({ x: ox < -SWIPE_TO_DELETE_OFFSET ? -SWIPE_TO_DELETE_OFFSET : 0 });
      } else {
        api.start({ x: Math.min(ox, 0), immediate: true });
      }
    },
    {
      from: () => [x.get(), 0],
      axis: "x",
      bounds: { left: -100, right: 0, top: 0, bottom: 0 },
      rubberband: true,
      preventScroll: true,
    }
  );

  const isSelected = selectedItemIds.includes(props.id);

  return (
    <div className="relative">
      {/* Delete reveal */}
      <div
        className="absolute right-0 top-0 bottom-0 w-[76px] flex items-center justify-center cursor-pointer"
        style={{ background: '#FFF0F0' }}
        onClick={() => addToCart(0)}
      >
        <div className="flex flex-col items-center gap-1">
          <Trash2 size={18} className="text-danger" />
          <span className="text-2xs font-semibold text-danger">Xoá</span>
        </div>
      </div>

      {/* Main item */}
      <animated.div
        {...bind()}
        style={{ x }}
        className="flex items-center gap-3 px-4 py-3"
        style2={{ background: '#FFFFFF' }}
      >
        {/* Checkbox */}
        <Checkbox
          checked={isSelected}
          onChange={(checked) => {
            setSelectedItemIds(checked
              ? [...selectedItemIds, props.id]
              : selectedItemIds.filter((id) => id !== props.id)
            );
          }}
        />

        {/* Product image */}
        <div className="w-16 h-16 rounded-2xl overflow-hidden flex-shrink-0" style={{ background: '#F0ECE6' }}>
          <img src={props.product.image} className="w-full h-full object-cover" alt={props.product.name} />
        </div>

        {/* Product info */}
        <div className="flex-1 min-w-0">
          <div className="text-sm font-semibold text-foreground line-clamp-2 leading-snug">
            {props.product.name}
          </div>
          {variantLabel && (
            <div
              className="inline-block text-2xs font-medium px-2 py-0.5 rounded-full mt-1"
              style={{ background: '#F0ECE6', color: '#6B6B6B' }}
            >
              {variantLabel}
            </div>
          )}

          <div className="flex items-center justify-between mt-2">
            {/* Price */}
            <div>
              <div className="text-sm font-bold" style={{ color: '#1a1a2e' }}>
                {formatPrice(props.product.price)}
              </div>
              {props.product.originalPrice && (
                <div className="text-2xs text-inactive line-through">
                  {formatPrice(props.product.originalPrice)}
                </div>
              )}
            </div>

            {/* Quantity */}
            <QuantityInput
              value={quantity}
              onChange={async (value) => {
                if (value <= 0) {
                  setQuantity(1);
                  api.start({ x: -SWIPE_TO_DELETE_OFFSET });
                } else {
                  setQuantity(value);
                  await addToCart(value);
                }
              }}
            />
          </div>
        </div>
      </animated.div>

      {/* Bottom divider */}
      <div className="mx-4 h-px" style={{ background: 'rgba(0,0,0,0.04)' }} />
    </div>
  );
}
