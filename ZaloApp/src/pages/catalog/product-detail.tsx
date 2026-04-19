import Button from "@/components/button";
import HorizontalDivider from "@/components/horizontal-divider";
import { useAtomValue } from "jotai";
import { useNavigate, useParams } from "react-router-dom";
import { productState } from "@/state";
import { formatPrice } from "@/utils/format";
import ShareButton from "./share-buttont";
import { useEffect, useState } from "react";
import Collapse from "@/components/collapse";
import RelatedProducts from "./related-products";
import AiReviewSummary from "./ai-review-summary";
import ProductReviews from "./product-reviews";
import { useAddToCart } from "@/hooks";
import toast from "react-hot-toast";
import { Size } from "@/types";
import { Heart, Star } from "lucide-react";
import axiosClient from "@/services/axiosClient";

export default function ProductDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  // id is a UUID string from backend - do NOT convert to Number
  const product = useAtomValue(productState(id ?? ""));
  const [selectedSize, setSelectedSize] = useState<Size>();
  const [selectedImageIdx, setSelectedImageIdx] = useState(0);
  const [wishlisted, setWishlisted] = useState(false);
  const [wishlistLoading, setWishlistLoading] = useState(false);

  // Derive images array (backend may send product.images[])
  const images: string[] = (product as any)?.images?.map((i: any) => i.url || i) ?? 
    (product?.image ? [product.image] : []);

  // Derive available sizes/variants from backend data
  const variants: any[] = (product as any)?.variants ?? [];
  const sizes: Size[] = variants.length > 0
    ? variants.map((v: any) => v.label || `${v.volume}ml`)
    : (product?.sizes ?? []);

  // Price: based on selected variant
  const selectedVariant = variants.find((v: any) => 
    (v.label || `${v.volume}ml`) === selectedSize
  );
  const displayPrice = selectedVariant?.price ?? product?.price ?? 0;
  const displayOriginalPrice = selectedVariant?.originalPrice ?? (product as any)?.originalPrice;

  useEffect(() => {
    if (sizes.length > 0) {
      setSelectedSize(sizes[0]);
    }
    setSelectedImageIdx(0);
  }, [id]);

  useEffect(() => {
    const fetchFavoriteStatus = async () => {
      if (!product?.id) return;
      try {
        const res: any = await axiosClient.get(`/favorites/${product.id}/status`);
        setWishlisted(Boolean(res?.isFavorite));
      } catch {
        setWishlisted(false);
      }
    };
    fetchFavoriteStatus();
  }, [product?.id]);

  const { addToCart, setOptions } = useAddToCart(product || ({} as any));

  useEffect(() => {
    setOptions({ size: selectedSize });
  }, [selectedSize, setOptions]);

  if (!product) {
    return (
      <div className="w-full h-full flex flex-col items-center justify-center gap-3 text-sm text-subtitle">
        <div className="w-10 h-10 border-2 border-primary/30 border-t-primary rounded-full animate-spin" />
        <span>Đang tải sản phẩm...</span>
      </div>
    );
  }

  const brand = (product as any)?.brand?.name;

  return (
    <div className="w-full h-full flex flex-col">
      <div className="flex-1 overflow-y-auto">
        {/* Image Gallery */}
        <div className="relative bg-gray-50">
          <img
            key={selectedImageIdx}
            src={images[selectedImageIdx] || product.image}
            alt={product.name}
            className="w-full aspect-square object-cover"
            style={{ viewTransitionName: `product-image-${product.id}` }}
          />
          {/* Wishlist & Share buttons */}
          <div className="absolute top-3 right-3 flex flex-col gap-2">
            <button
              id="btn-wishlist"
              onClick={async () => {
                if (!product?.id || wishlistLoading) return;
                try {
                  setWishlistLoading(true);
                  if (wishlisted) {
                    await axiosClient.delete(`/favorites/${product.id}`);
                    setWishlisted(false);
                    toast.success("Đã bỏ khỏi danh sách yêu thích");
                  } else {
                    await axiosClient.post(`/favorites/${product.id}`);
                    setWishlisted(true);
                    toast.success("Đã thêm vào danh sách yêu thích");
                  }
                } catch {
                  toast.error("Không thể cập nhật danh sách yêu thích");
                } finally {
                  setWishlistLoading(false);
                }
              }}
              className="w-9 h-9 rounded-full bg-white/90 backdrop-blur flex items-center justify-center shadow"
            >
              <Heart
                size={18}
                className={wishlisted ? "text-red-500 fill-red-500" : "text-gray-400"}
              />
            </button>
            <div className="w-9 h-9 rounded-full bg-white/90 backdrop-blur flex items-center justify-center shadow">
              <ShareButton product={product} />
            </div>
          </div>
        </div>

        {/* Thumbnail strip (only if multiple images) */}
        {images.length > 1 && (
          <div className="flex gap-2 px-4 py-2 overflow-x-auto">
            {images.map((img, idx) => (
              <button
                key={idx}
                onClick={() => setSelectedImageIdx(idx)}
                className={`flex-none w-14 h-14 rounded-lg overflow-hidden border-2 transition-all ${
                  idx === selectedImageIdx ? "border-primary" : "border-transparent"
                }`}
              >
                <img src={img} className="w-full h-full object-cover" />
              </button>
            ))}
          </div>
        )}

        {/* Product Info */}
        <div className="w-full px-4 pt-3 pb-4">
          {/* Brand */}
          {brand && (
            <div className="text-xs text-primary font-bold tracking-widest uppercase mb-1">{brand}</div>
          )}
          {/* Name */}
          <div className="text-base font-semibold text-gray-800 leading-snug mb-2">{product.name}</div>

          {/* Price row */}
          <div className="flex items-baseline gap-3 mb-3">
            <div className="text-2xl font-bold text-primary">{formatPrice(displayPrice)}</div>
            {displayOriginalPrice && displayOriginalPrice > displayPrice && (
              <div className="text-sm text-gray-400 line-through">{formatPrice(displayOriginalPrice)}</div>
            )}
            {displayOriginalPrice && displayOriginalPrice > displayPrice && (
              <div className="text-xs font-bold text-red-500 bg-red-50 px-2 py-0.5 rounded-full">
                -{Math.round((1 - displayPrice / displayOriginalPrice) * 100)}%
              </div>
            )}
          </div>

          {/* Category */}
          <div className="text-xs text-gray-400 mb-3">Danh mục: {product.category?.name}</div>
        </div>

        <HorizontalDivider />

        {/* Variant / Size Picker */}
        {sizes.length > 0 && (
          <div className="px-4 py-3">
            <div className="text-sm font-semibold mb-3 text-gray-700">Dung tích / Phiên bản</div>
            <div className="flex flex-wrap gap-2">
              {sizes.map((s) => (
                <button
                  key={s}
                  onClick={() => setSelectedSize(s)}
                  className={`px-4 py-2 rounded-xl border-2 text-sm font-medium transition-all ${
                    selectedSize === s
                      ? "border-primary bg-primary text-white"
                      : "border-gray-100 bg-white text-gray-600"
                  }`}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Description / Details */}
        {(product as any)?.description && (
          <>
            <HorizontalDivider />
            <div className="px-4 py-3">
              <div className="text-sm font-semibold mb-2 text-gray-700">Mô tả sản phẩm</div>
              <p className="text-sm text-gray-500 leading-relaxed">{(product as any).description}</p>
            </div>
          </>
        )}

        {product.details && (
          <>
            <div className="bg-section h-2 w-full" />
            <Collapse items={product.details} />
          </>
        )}

        {/* AI Review Summary */}
        <AiReviewSummary productId={product.id} />

        {/* Product Reviews */}
        <ProductReviews productId={product.id} />

        {/* Related Products */}
        <div className="bg-section h-2 w-full mt-2" />
        <div className="font-semibold py-2 px-4">
          <div className="pt-2 pb-2.5">Sản phẩm tương tự</div>
          <HorizontalDivider />
        </div>
        <RelatedProducts currentProductId={product.id} />
      </div>

      {/* Bottom Action Bar */}
      <HorizontalDivider />
      <div className="flex-none grid grid-cols-2 gap-2 py-3 px-4">
        <Button
          large
          onClick={() => {
            addToCart(1);
            toast.success("Đã thêm vào giỏ hàng 🛍️");
          }}
        >
          Thêm vào giỏ
        </Button>
        <Button
          large
          primary
          onClick={() => {
            addToCart(1);
            navigate("/cart");
          }}
        >
          Mua ngay
        </Button>
      </div>
    </div>
  );
}

