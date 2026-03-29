"use client";

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { Link } from "@/lib/i18n";
import { orderService, type Order } from "@/services/order.service";
import { shippingService, type Shipment } from "@/services/shipping.service";
import { AuthGuard } from "@/components/auth/auth-guard";
import Image from "next/image";
import {
  ArrowLeft,
  Loader2,
  MapPin,
  Phone,
  Truck,
  ExternalLink,
  Star,
} from "lucide-react";
import ReviewForm from "@/components/review/review-form";

const STATUS_CONFIG: Record<string, { label: string; color: string }> = {
  PENDING: {
    label: "Chờ xác nhận",
    color: "bg-amber-500/10 text-amber-600 border-amber-500/20",
  },
  CONFIRMED: {
    label: "Đã xác nhận",
    color: "bg-blue-500/10 text-blue-600 border-blue-500/20",
  },
  PROCESSING: {
    label: "Đang chuẩn bị",
    color: "bg-purple-500/10 text-purple-600 border-purple-500/20",
  },
  SHIPPED: {
    label: "Đang giao hàng",
    color: "bg-orange-500/10 text-orange-600 border-orange-500/20",
  },
  COMPLETED: {
    label: "Hoàn thành",
    color: "bg-emerald-500/10 text-emerald-600 border-emerald-500/20",
  },
  CANCELLED: {
    label: "Đã hủy",
    color: "bg-red-500/10 text-red-600 border-red-500/20",
  },
};

const TRACKING_URL = "https://donhang.ghn.vn/?order_code=";

export default function CustomerOrderDetailPage() {
  const params = useParams();
  const orderId = params?.id as string;

  const [order, setOrder] = useState<Order | null>(null);
  const [shipments, setShipments] = useState<Shipment[]>([]);
  const [loading, setLoading] = useState(true);
  const [reviewingItemId, setReviewingItemId] = useState<number | null>(null);

  const fetchOrder = async () => {
    if (orderId) {
      try {
        const [o, s] = await Promise.all([
          orderService.getById(orderId),
          shippingService.getByOrderId(orderId).catch(() => []),
        ]);
        setOrder(o);
        setShipments(s);
      } catch (err) {
        setOrder(null);
      } finally {
        setLoading(false);
      }
    }
  };

  useEffect(() => {
    fetchOrder();
  }, [orderId]);

  if (loading) {
    return (
      <AuthGuard allowedRoles={["customer", "staff", "admin"]}>
        <div className="flex flex-col items-center justify-center py-24">
          <Loader2 className="w-10 h-10 animate-spin text-gold" />
        </div>
      </AuthGuard>
    );
  }

  if (!order) {
    return (
      <AuthGuard allowedRoles={["customer", "staff", "admin"]}>
        <div className="py-20 text-center">
          <p className="text-stone-500 dark:text-stone-400 mb-4">
            Không tìm thấy đơn hàng
          </p>
          <Link
            href="/dashboard/customer/orders"
            className="text-gold hover:underline font-bold"
          >
            Quay lại danh sách đơn hàng
          </Link>
        </div>
      </AuthGuard>
    );
  }

  const style =
    STATUS_CONFIG[order.status as keyof typeof STATUS_CONFIG] ||
    STATUS_CONFIG.PENDING;

  return (
    <AuthGuard allowedRoles={["customer", "staff", "admin"]}>
      <div className="flex flex-col gap-10 py-10 px-8">
        <header>
          <Link
            href="/dashboard/customer/orders"
            className="inline-flex items-center gap-2 text-gold hover:text-gold/80 mb-6"
          >
            <ArrowLeft size={18} />
            Quay lại đơn hàng
          </Link>
          <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-2">
            Đơn hàng {order.code}
          </h1>
          <p className="text-[10px] text-stone-500 uppercase tracking-[.4em] font-bold">
            {new Date(order.createdAt!).toLocaleDateString("vi-VN", {
              dateStyle: "full",
            })}
          </p>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-8">
            <div className="glass bg-white dark:bg-zinc-900 rounded-[3rem] p-8 border border-stone-100 dark:border-white/5">
              <h2 className="text-xl font-serif text-luxury-black dark:text-white mb-6">
                Sản phẩm
              </h2>
              {order.items && order.items.length > 0 ? (
                <div className="space-y-6">
                  {order.items.map((item: any) => {
                    const imageUrl = item.product?.images?.[0]?.url ?? null;
                    const productHref = item.product?.id
                      ? `/products/${item.product.id}`
                      : null;

                    return (
                      <div
                        key={item.id}
                        className="py-4 border-b border-stone-100 dark:border-white/5 last:border-0"
                      >
                        <div className="flex items-start gap-4">
                          {/* Product Image */}
                          {productHref ? (
                            <Link
                              href={productHref}
                              className="flex-shrink-0 group"
                            >
                              <div className="w-20 h-20 rounded-2xl overflow-hidden border border-stone-200 dark:border-white/10 bg-stone-100 dark:bg-zinc-800 relative">
                                {imageUrl ? (
                                  <Image
                                    src={imageUrl}
                                    alt={item.product?.name ?? "product"}
                                    fill
                                    className="object-cover group-hover:scale-105 transition-transform duration-300"
                                    sizes="80px"
                                  />
                                ) : (
                                  <div className="w-full h-full flex items-center justify-center text-stone-400 text-2xl">
                                    📦
                                  </div>
                                )}
                              </div>
                            </Link>
                          ) : (
                            <div className="flex-shrink-0 w-20 h-20 rounded-2xl overflow-hidden border border-stone-200 dark:border-white/10 bg-stone-100 dark:bg-zinc-800 relative">
                              {imageUrl ? (
                                <Image
                                  src={imageUrl}
                                  alt={item.product?.name ?? "product"}
                                  fill
                                  className="object-cover"
                                  sizes="80px"
                                />
                              ) : (
                                <div className="w-full h-full flex items-center justify-center text-stone-400 text-2xl">
                                  📦
                                </div>
                              )}
                            </div>
                          )}

                          {/* Info */}
                          <div className="flex-1 min-w-0">
                            <div className="flex justify-between items-start gap-2">
                              <div>
                                {productHref ? (
                                  <Link
                                    href={productHref}
                                    className="font-bold text-luxury-black dark:text-white hover:text-gold transition-colors line-clamp-2"
                                  >
                                    {item.product?.name}
                                  </Link>
                                ) : (
                                  <p className="font-bold text-luxury-black dark:text-white">
                                    {item.product?.name}
                                  </p>
                                )}
                                <p className="text-[10px] text-stone-400 uppercase mt-1">
                                  × {item.quantity} —{" "}
                                  {new Intl.NumberFormat("vi-VN", {
                                    style: "currency",
                                    currency: "VND",
                                  }).format(item.unitPrice)}
                                </p>
                              </div>
                              <div className="flex flex-col items-end gap-2 flex-shrink-0">
                                <span className="font-bold text-luxury-black dark:text-white">
                                  {new Intl.NumberFormat("vi-VN", {
                                    style: "currency",
                                    currency: "VND",
                                  }).format(item.totalPrice)}
                                </span>
                                {order.status === "COMPLETED" &&
                                  !item.review && (
                                    <button
                                      onClick={() =>
                                        setReviewingItemId(
                                          reviewingItemId === item.id
                                            ? null
                                            : item.id,
                                        )
                                      }
                                      className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-widest text-gold hover:text-gold/80"
                                    >
                                      <Star
                                        size={12}
                                        className={
                                          reviewingItemId === item.id
                                            ? "fill-gold"
                                            : ""
                                        }
                                      />
                                      {reviewingItemId === item.id
                                        ? "Đang viết"
                                        : "Viết đánh giá"}
                                    </button>
                                  )}
                                {item.review && (
                                  <span className="text-[10px] font-bold uppercase tracking-widest text-emerald-500 flex items-center gap-1">
                                    <Star
                                      size={12}
                                      className="fill-emerald-500"
                                    />
                                    Đã đánh giá
                                  </span>
                                )}
                              </div>
                            </div>

                            {reviewingItemId === item.id && (
                              <div className="mt-4 animate-in slide-in-from-top-2 duration-300">
                                <ReviewForm
                                  productId={item.product?.id || ""}
                                  orderItemId={item.id}
                                  productName={item.product?.name || ""}
                                  onCancel={() => setReviewingItemId(null)}
                                  onSuccess={() => {
                                    setReviewingItemId(null);
                                    fetchOrder();
                                  }}
                                />
                              </div>
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              ) : (
                <p className="text-stone-500">Không có sản phẩm</p>
              )}
            </div>

            <div className="glass bg-white dark:bg-zinc-900 rounded-[3rem] p-8 border border-stone-100 dark:border-white/5">
              <h2 className="text-xl font-serif text-luxury-black dark:text-white mb-6 flex items-center gap-3">
                <MapPin size={20} className="text-gold" />
                Địa chỉ giao hàng
              </h2>
              <p className="text-sm text-stone-600 dark:text-stone-300">
                {order.shippingAddress}
              </p>
              {order.phone && (
                <p className="text-[10px] text-stone-400 mt-2 flex items-center gap-2">
                  <Phone size={12} /> {order.phone}
                </p>
              )}
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-8">
            <div className="glass bg-white dark:bg-zinc-900 rounded-[3rem] p-8 border border-stone-100 dark:border-white/5">
              <h3 className="text-[10px] font-bold uppercase tracking-widest text-stone-400 mb-4">
                Trạng thái
              </h3>
              <span
                className={`inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-bold border ${style.color}`}
              >
                {style.label}
              </span>
              <p className="mt-6 text-[10px] text-stone-400 uppercase tracking-wider">
                Thanh toán:{" "}
                {order.paymentStatus === "PAID"
                  ? "Đã thanh toán"
                  : order.paymentStatus === "PENDING"
                    ? "Chờ thanh toán"
                    : order.paymentStatus}
              </p>
              <p className="mt-8 text-2xl font-serif text-luxury-black dark:text-white italic">
                {new Intl.NumberFormat("vi-VN", {
                  style: "currency",
                  currency: "VND",
                }).format(order.finalAmount)}
              </p>
            </div>

            {/* Shipment / Tracking */}
            {shipments.length > 0 && (
              <div className="glass bg-white dark:bg-zinc-900 rounded-[3rem] p-8 border border-stone-100 dark:border-white/5">
                <h3 className="text-xl font-serif text-luxury-black dark:text-white mb-6 flex items-center gap-3">
                  <Truck size={20} className="text-gold" />
                  Theo dõi đơn hàng
                </h3>
                <div className="space-y-4">
                  {shipments.map((s) => (
                    <div
                      key={s.id}
                      className="p-4 rounded-2xl bg-stone-50 dark:bg-zinc-800 border border-stone-100 dark:border-white/5"
                    >
                      <div className="flex justify-between items-start gap-4">
                        <div>
                          <p className="text-[10px] font-bold uppercase tracking-widest text-stone-400 mb-1">
                            Mã vận đơn
                          </p>
                          <p className="font-mono font-bold text-luxury-black dark:text-white">
                            {s.trackingCode || s.ghnOrderCode || "—"}
                          </p>
                          <p className="text-[10px] text-stone-500 mt-2">
                            Trạng thái: {s.status}
                          </p>
                        </div>
                        {(s.trackingCode || s.ghnOrderCode) && (
                          <a
                            href={`${TRACKING_URL}${s.trackingCode || s.ghnOrderCode}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex items-center gap-2 text-gold hover:text-gold/80 text-[10px] font-bold uppercase tracking-wider whitespace-nowrap"
                          >
                            Tra cứu GHN <ExternalLink size={12} />
                          </a>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </AuthGuard>
  );
}
