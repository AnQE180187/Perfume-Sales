import { Product } from "@/types";
import { formatPrice } from "@/utils/format";
import TransitionLink from "./transition-link";
import { useState } from "react";
import { Heart } from "lucide-react";

export interface ProductItemProps {
  product: Product;
  replace?: boolean;
  horizontal?: boolean;
}

export default function ProductItem({ product, replace, horizontal }: ProductItemProps) {
  const [selected, setSelected] = useState(false);
  const [wishlisted, setWishlisted] = useState(false);

  const brand = (product as any)?.brand?.name;
  const originalPrice = (product as any)?.originalPrice;
  const hasDiscount = originalPrice && originalPrice > product.price;
  const discountPct = hasDiscount ? Math.round((1 - product.price / originalPrice) * 100) : 0;

  if (horizontal) {
    return (
      <TransitionLink
        className="flex gap-3 cursor-pointer active:opacity-70 transition-opacity"
        to={`/product/${product.id}`}
        replace={replace}
        onClick={() => setSelected(true)}
      >
        {({ isTransitioning }) => (
          <>
            <div className="w-20 h-20 rounded-2xl overflow-hidden bg-skeleton flex-shrink-0">
              <img
                src={product.image}
                className="w-full h-full object-cover"
                style={{
                  viewTransitionName:
                    isTransitioning && selected
                      ? `product-image-${product.id}`
                      : undefined,
                }}
                alt={product.name}
              />
            </div>
            <div className="flex-1 min-w-0 py-1">
              {brand && (
                <div className="text-2xs font-bold tracking-wider text-gold uppercase truncate">
                  {brand}
                </div>
              )}
              <div className="text-xs font-semibold text-foreground line-clamp-2 leading-snug">
                {product.name}
              </div>
              <div className="flex items-center gap-2 mt-1">
                <div className="text-sm font-bold text-primary">
                  {formatPrice(product.price)}
                </div>
                {hasDiscount && (
                  <div className="text-2xs text-inactive line-through">
                    {formatPrice(originalPrice)}
                  </div>
                )}
              </div>
            </div>
          </>
        )}
      </TransitionLink>
    );
  }

  return (
    <TransitionLink
      className="flex flex-col cursor-pointer group relative"
      to={`/product/${product.id}`}
      replace={replace}
      onClick={() => setSelected(true)}
    >
      {({ isTransitioning }) => (
        <>
          <div className="relative overflow-hidden rounded-2xl bg-skeleton">
            <img
              src={product.image}
              className="w-full aspect-square object-cover transition-transform duration-500 group-active:scale-105"
              style={{
                viewTransitionName:
                  isTransitioning && selected
                    ? `product-image-${product.id}`
                    : undefined,
              }}
              alt={product.name}
            />
            {hasDiscount && (
              <div className="absolute top-2 left-2 bg-danger text-white text-2xs font-bold px-1.5 py-0.5 rounded-full">
                -{discountPct}%
              </div>
            )}
          </div>
          <div className="pt-2 pb-1 px-0.5">
            {brand && (
              <div className="text-2xs font-bold tracking-wider text-gold uppercase truncate">
                {brand}
              </div>
            )}
            <div className="text-xs h-8 line-clamp-2 font-medium text-foreground leading-snug">
              {product.name}
            </div>
            <div className="flex items-baseline gap-1.5 mt-1">
              <div className="text-sm font-bold text-primary">
                {formatPrice(product.price)}
              </div>
              {hasDiscount && (
                <div className="text-2xs text-inactive line-through">
                  {formatPrice(originalPrice)}
                </div>
              )}
            </div>
          </div>
        </>
      )}
    </TransitionLink>
  );
}
