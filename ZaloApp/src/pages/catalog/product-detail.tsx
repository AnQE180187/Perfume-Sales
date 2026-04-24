import Button from "@/components/button";
import { useAtomValue } from "jotai";
import { useNavigate, useParams } from "react-router-dom";
import { productState } from "@/state";
import { formatPrice } from "@/utils/format";
import ShareButton from "./share-buttont";
import { useEffect, useState } from "react";
import RelatedProducts from "./related-products";
import AiReviewSummary from "./ai-review-summary";
import ProductReviews from "./product-reviews";
import { useAddToCart } from "@/hooks";
import toast from "react-hot-toast";
import { Size } from "@/types";
import { Heart, ShoppingCart, Zap, ChevronLeft, Star } from "lucide-react";
import axiosClient from "@/services/axiosClient";

export default function ProductDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const product = useAtomValue(productState(id ?? ""));
  const [selectedSize, setSelectedSize] = useState<Size>();
  const [selectedImageIdx, setSelectedImageIdx] = useState(0);
  const [wishlisted, setWishlisted] = useState(false);
  const [wishlistLoading, setWishlistLoading] = useState(false);

  const images: string[] = (product as any)?.images?.map((i: any) => i.url || i) ??
    (product?.image ? [product.image] : []);

  const variants: any[] = (product as any)?.variants ?? [];
  const sizes: Size[] = variants.length > 0
    ? variants.map((v: any) => v.label || `${v.volume}ml`)
    : (product?.sizes ?? []);

  const selectedVariant = variants.find((v: any) =>
    (v.label || `${v.volume}ml`) === selectedSize
  );
  const displayPrice = selectedVariant?.price ?? product?.price ?? 0;
  const displayOriginalPrice = selectedVariant?.originalPrice ?? (product as any)?.originalPrice;
  const hasDiscount = displayOriginalPrice && displayOriginalPrice > displayPrice;
  const discountPct = hasDiscount ? Math.round((1 - displayPrice / displayOriginalPrice) * 100) : 0;

  const avgRating = (product as any)?.avgRating || 0;
  const reviewCount = (product as any)?.reviewCount || 0;

  useEffect(() => {
    if (sizes.length > 0) setSelectedSize(sizes[0]);
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
      <div className="w-full h-full flex flex-col items-center justify-center gap-3" style={{ background: '#FAF8F5' }}>
        <div
          className="w-12 h-12 rounded-full border-2 border-t-gold animate-spin"
          style={{ borderColor: 'rgba(212,175,55,0.2)', borderTopColor: '#D4AF37' }}
        />
        <span className="text-sm text-subtitle">Đang tải sản phẩm...</span>
      </div>
    );
  }

  const brand = (product as any)?.brand?.name;

  return (
    <div className="w-full h-full flex flex-col" style={{ background: '#FAF8F5' }}>
      <div className="flex-1 overflow-y-auto">
        {/* === IMAGE GALLERY === */}
        <div className="relative" style={{ background: '#FFFFFF' }}>
          <img
            key={selectedImageIdx}
            src={images[selectedImageIdx] || product.image}
            alt={product.name}
            className="w-full aspect-square object-cover"
            style={{ viewTransitionName: `product-image-${product.id}` }}
          />

          {/* Discount badge */}
          {hasDiscount && (
            <div className="absolute top-3 left-3 bg-danger text-white text-xs font-bold px-2.5 py-1 rounded-full">
              -{discountPct}%
            </div>
          )}

          {/* Action buttons top-right */}
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
                    toast.success("Đã bỏ khỏi yêu thích");
                  } else {
                    await axiosClient.post(`/favorites/${product.id}`);
                    setWishlisted(true);
                    toast.success("Đã thêm vào yêu thích ❤️");
                  }
                } catch {
                  toast.error("Không thể cập nhật yêu thích");
                } finally {
                  setWishlistLoading(false);
                }
              }}
              className="w-10 h-10 rounded-2xl flex items-center justify-center shadow-luxury-sm active:scale-90 transition-transform"
              style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(8px)' }}
            >
              <Heart
                size={18}
                className={wishlisted ? "fill-danger text-danger" : "text-subtitle"}
              />
            </button>
            <div
              className="w-10 h-10 rounded-2xl flex items-center justify-center shadow-luxury-sm"
              style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(8px)' }}
            >
              <ShareButton product={product} />
            </div>
          </div>
        </div>

        {/* Thumbnail strip */}
        {images.length > 1 && (
          <div className="flex gap-2 px-4 py-3 overflow-x-auto" style={{ background: '#FFFFFF', borderBottom: '1px solid rgba(0,0,0,0.04)' }}>
            {images.map((img, idx) => (
              <button
                key={idx}
                onClick={() => setSelectedImageIdx(idx)}
                className={`flex-none w-14 h-14 rounded-xl overflow-hidden border-2 transition-all active:scale-90 ${
                  idx === selectedImageIdx ? "border-gold" : "border-transparent"
                }`}
              >
                <img src={img} className="w-full h-full object-cover" />
              </button>
            ))}
          </div>
        )}

        {/* === PRODUCT INFO === */}
        <div className="px-4 pt-4 pb-3" style={{ background: '#FFFFFF' }}>
          {/* Brand */}
          {brand && (
            <div className="text-xs font-bold tracking-widest text-gold uppercase mb-1">
              {brand}
            </div>
          )}

          {/* Product name */}
          <h1 className="text-lg font-bold text-foreground leading-snug mb-3"
            style={{ fontFamily: "'Playfair Display', serif" }}>
            {product.name}
          </h1>

          {/* Rating row */}
          {avgRating > 0 && (
            <div className="flex items-center gap-2 mb-3">
              <div className="flex gap-0.5">
                {[1, 2, 3, 4, 5].map(s => (
                  <Star key={s} size={13} className={s <= Math.round(avgRating) ? "fill-gold text-gold" : "text-skeleton"} />
                ))}
              </div>
              <span className="text-xs font-semibold text-foreground">{avgRating.toFixed(1)}</span>
              <span className="text-xs text-subtitle">({reviewCount} đánh giá)</span>
            </div>
          )}

          {/* Price */}
          <div className="flex items-baseline gap-3">
            <div className="text-2xl font-black" style={{ color: '#1a1a2e' }}>
              {formatPrice(displayPrice)}
            </div>
            {hasDiscount && (
              <div className="text-sm text-inactive line-through">
                {formatPrice(displayOriginalPrice)}
              </div>
            )}
          </div>

          {/* Category */}
          <div className="text-xs text-subtitle mt-1">
            Danh mục: {product.category?.name}
          </div>
        </div>

        {/* === VARIANT PICKER === */}
        {sizes.length > 0 && (
          <div
            className="px-4 py-4 mt-2"
            style={{ background: '#FFFFFF', borderTop: '1px solid rgba(0,0,0,0.04)' }}
          >
            <div className="text-sm font-bold text-foreground mb-3">Dung tích / Phiên bản</div>
            <div className="flex flex-wrap gap-2">
              {sizes.map((s) => {
                const v = variants.find((v: any) => (v.label || `${v.volume}ml`) === s);
                const isSelected = selectedSize === s;
                return (
                  <button
                    key={s}
                    onClick={() => setSelectedSize(s)}
                    className="px-4 py-2.5 rounded-2xl text-sm font-semibold transition-all active:scale-90"
                    style={isSelected ? {
                      background: 'linear-gradient(135deg, #1a1a2e, #2d2d52)',
                      color: '#FAF8F5',
                      border: '1.5px solid rgba(212,175,55,0.4)',
                      boxShadow: '0 2px 12px rgba(26,26,46,0.2)',
                    } : {
                      background: '#F0ECE6',
                      color: '#6B6B6B',
                      border: '1.5px solid rgba(0,0,0,0.06)',
                    }}
                  >
                    {s}
                    {v?.price && !isSelected && (
                      <span className="ml-1.5 text-2xs opacity-70">{formatPrice(v.price)}</span>
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {/* === DESCRIPTION === */}
        {(product as any)?.description && (
          <div
            className="px-4 py-4 mt-2"
            style={{ background: '#FFFFFF', borderTop: '1px solid rgba(0,0,0,0.04)' }}
          >
            <div className="text-sm font-bold text-foreground mb-2">Mô tả sản phẩm</div>
            <p className="text-sm text-subtitle leading-relaxed">{(product as any).description}</p>
          </div>
        )}

        {/* AI Review Summary */}
        <AiReviewSummary productId={product.id} />

        {/* Product Reviews */}
        <ProductReviews productId={product.id} />

        {/* Related Products */}
        <div
          className="mt-2 px-4 pt-4 pb-2"
          style={{ background: '#FFFFFF', borderTop: '1px solid rgba(0,0,0,0.04)' }}
        >
          <div className="text-sm font-bold text-foreground mb-3">Sản phẩm tương tự</div>
          <RelatedProducts currentProductId={product.id} />
        </div>

        <div className="h-20" /> {/* Spacer for bottom action bar */}
      </div>

      {/* === BOTTOM ACTION BAR === */}
      <div
        className="flex-none flex gap-3 px-4 py-3"
        style={{
          background: '#FFFFFF',
          borderTop: '1px solid rgba(0,0,0,0.06)',
          paddingBottom: 'max(12px, env(safe-area-inset-bottom))',
        }}
      >
        {/* Add to Cart */}
        <button
          onClick={() => {
            addToCart(1);
            toast.success("Đã thêm vào giỏ hàng 🛍️");
          }}
          className="flex-1 flex items-center justify-center gap-2 py-3.5 rounded-2xl font-bold text-sm active:scale-95 transition-transform"
          style={{
            background: '#F0ECE6',
            color: '#1a1a2e',
            border: '1.5px solid rgba(212,175,55,0.2)',
          }}
        >
          <ShoppingCart size={16} />
          Thêm vào giỏ
        </button>

        {/* Buy Now */}
        <button
          onClick={() => {
            addToCart(1);
            navigate("/cart");
          }}
          className="flex-1 flex items-center justify-center gap-2 py-3.5 rounded-2xl font-bold text-sm active:scale-95 transition-transform"
          style={{
            background: 'linear-gradient(135deg, #E2D1B3, #D4AF37)',
            color: '#1a1a2e',
            boxShadow: '0 4px 16px rgba(212,175,55,0.35)',
          }}
        >
          <Zap size={16} />
          Mua ngay
        </button>
      </div>
    </div>
  );
}
