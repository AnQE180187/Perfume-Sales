"use client";

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { Link } from "@/lib/i18n";
import { orderService, type Order } from "@/services/order.service";
import { shippingService, type Shipment } from "@/services/shipping.service";
import { returnsService, type ReturnRequest } from "@/services/returns.service";
import Image from "next/image";
import {
  ArrowLeft,
  Loader2,
  MapPin,
  Phone,
  Truck,
  ExternalLink,
  Star,
  Clock,
  PackageCheck,
  XCircle,
  RotateCcw,
  Check,
  Zap,
  Package
} from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import ReviewModal from "@/components/review/review-modal";
import { CreateReturnModal } from "@/components/returns/CreateReturnModal";
import { useTranslations, useLocale, useFormatter } from "next-intl";
import { cn } from "@/lib/utils";

export default function CustomerOrderDetailPage() {
  const t = useTranslations("dashboard.customer.orders");
  const tDetail = useTranslations("dashboard.customer.order_detail");
  const tFeatured = useTranslations("featured");
  const locale = useLocale();
  const format = useFormatter();
  const params = useParams();
  const orderId = params?.id as string;

  const [order, setOrder] = useState<Order | null>(null);
  const [shipments, setShipments] = useState<Shipment[]>([]);
  const [loading, setLoading] = useState(true);
  const [reviewingItemId, setReviewingItemId] = useState<number | null>(null);
  const [showReturnModal, setShowReturnModal] = useState(false);
  const [showPolicyModal, setShowPolicyModal] = useState(false);
  const [showConfirmModal, setShowConfirmModal] = useState(false);
  const [existingReturn, setExistingReturn] = useState<ReturnRequest | null>(null);
  const [cancelling, setCancelling] = useState(false);
  const [showRefundModal, setShowRefundModal] = useState(false);
  const [savingRefundInfo, setSavingRefundInfo] = useState(false);
  const [refundInfo, setRefundInfo] = useState({ bankName: "", accountNumber: "", accountHolder: "", note: "" });
  const [submittedRefundInfo, setSubmittedRefundInfo] = useState<any>(null);

  const STATUS_CONFIG: Record<string, { label: string; color: string; icon: any }> = {
    PENDING: { label: t("status.pending"), color: "bg-amber-500/10 text-amber-600 dark:text-amber-500 border-amber-500/20", icon: Clock },
    CONFIRMED: { label: t("status.confirmed"), color: "bg-blue-500/10 text-blue-600 dark:text-blue-500 border-blue-500/20", icon: PackageCheck },
    PROCESSING: { label: t("status.processing"), color: "bg-purple-500/10 text-purple-600 dark:text-purple-500 border-purple-500/20", icon: PackageCheck },
    SHIPPED: { label: t("status.shipped"), color: "bg-orange-500/10 text-orange-600 dark:text-orange-500 border-orange-500/20", icon: Truck },
    COMPLETED: { label: t("status.completed"), color: "bg-emerald-500/10 text-emerald-600 dark:text-emerald-500 border-emerald-500/20", icon: PackageCheck },
    CANCELLED: { label: t("status.cancelled"), color: "bg-red-500/10 text-red-600 dark:text-red-500 border-red-500/20", icon: XCircle },
  };

  const TRACKING_URL = "https://donhang.ghn.vn/?order_code=";

  const fetchOrder = async () => {
    if (orderId) {
      try {
        const [o, s] = await Promise.all([
          orderService.getById(orderId),
          shippingService.getByOrderId(orderId).catch(() => []),
        ]);
        setOrder(o);
        setShipments(s);
        const r = await orderService.getRefundBankInfo(orderId).catch(() => null);
        setSubmittedRefundInfo(r);
        returnsService.listMyReturns().then((returns) => {
          const found = returns.find((r) => r.orderId === orderId) || null;
          setExistingReturn(found);
        }).catch(() => { });
      } catch (err) { setOrder(null); } finally { setLoading(false); }
    }
  };

  useEffect(() => { fetchOrder(); }, [orderId]);

  const handleCancelOrder = async () => {
    if (!window.confirm(tDetail("confirm_cancel_desc"))) return;
    setCancelling(true);
    try {
      await orderService.cancel(orderId);
      fetchOrder();
    } catch (err) { alert(tDetail("cancel_error")); } finally { setCancelling(false); }
  };

  const formatCurrency = (amount: number) => {
    return format.number(amount, {
      style: "currency",
      currency: tFeatured("currency_code") || "VND",
      maximumFractionDigits: 0,
    });
  };

  if (loading) {
    return (
      <div className="flex h-[400px] items-center justify-center">
          <Loader2 className="h-10 w-10 animate-spin text-gold" />
      </div>
    );
  }

  if (!order) {
    return (
      <div className="py-24 text-center rounded-[3rem] glass">
        <XCircle className="mx-auto text-red-500/20 mb-6" size={80} />
        <h2 className="font-heading text-2xl uppercase tracking-widest text-foreground">{tDetail("not_found")}</h2>
        <Link href="/dashboard/customer/orders" className="mt-8 inline-flex h-12 items-center px-8 rounded-full bg-stone-100 dark:bg-white/5 border border-black/5 dark:border-white/10 text-[10px] font-bold uppercase tracking-widest text-stone-600 dark:text-stone-400 hover:bg-gold hover:text-black cursor-pointer">
          {tDetail("back_to_list")}
        </Link>
      </div>
    );
  }

  const style = STATUS_CONFIG[order.status as keyof typeof STATUS_CONFIG] || STATUS_CONFIG.PENDING;
  const needsRefundBankInfo = order.status === "CANCELLED" && order.paymentStatus === "PAID" && !submittedRefundInfo;

  return (
    <div className="space-y-12 pb-12">
      <header>
        <Link href="/dashboard/customer/orders" className="group mb-8 inline-flex items-center gap-3 text-[10px] font-bold uppercase tracking-widest text-gold cursor-pointer">
          <ArrowLeft size={16} className="transition-transform group-hover:-translate-x-1" /> {tDetail("back")}
        </Link>
        <div className="flex items-center gap-4 mb-4">
          <div className="h-[1px] w-12 bg-gold/50" />
          <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry #{order.code}</span>
        </div>
        <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
          Acquisition <span className="gold-gradient">Coordinates</span>
        </h1>
        <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-[0.4em] text-stone-500 dark:text-stone-600">
           {format.dateTime(new Date(order.createdAt!), { dateStyle: 'full' })}
        </p>
      </header>

      <div className="grid grid-cols-1 gap-12 lg:grid-cols-12">
          {/* Main Manifest */}
          <div className="lg:col-span-8 space-y-8">
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="glass rounded-[3rem] p-10 lg:p-16">
                  <h2 className="mb-10 font-heading text-2xl font-bold uppercase tracking-widest text-foreground">{tDetail("products")}</h2>
                  <div className="divide-y divide-black/5 dark:divide-white/5">
                      {order.items.map((item: any, i: number) => {
                           const imageUrl = item.product?.images?.[0]?.url;
                           const productHref = item.product?.id ? `/products/${item.product.id}` : null;
                           return (
                               <div key={item.id} className="group relative py-8 first:pt-0 last:pb-0">
                                   <div className="flex gap-8">
                                       <div className="relative h-24 w-24 overflow-hidden rounded-2xl bg-stone-100 dark:bg-zinc-800 border border-black/5 dark:border-white/5">
                                           {imageUrl ? <Image src={imageUrl} alt={item.product?.name} fill className="object-cover transition-transform group-hover:scale-110" /> : <Package className="m-auto text-stone-400 dark:text-stone-700" size={32} />}
                                       </div>
                                       <div className="flex-1 space-y-4">
                                           <div className="flex justify-between gap-4">
                                               <div>
                                                   {productHref ? (
                                                       <Link href={productHref} className="font-heading text-lg font-bold uppercase tracking-widest text-foreground hover:text-gold transition-colors cursor-pointer">{item.product?.name}</Link>
                                                   ) : (
                                                       <p className="font-heading text-lg font-bold uppercase tracking-widest text-foreground">{item.product?.name}</p>
                                                   )}
                                                   <p className="mt-2 text-[10px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-600">
                                                       Quantity: {item.quantity} · Unit Price: {formatCurrency(item.unitPrice)}
                                                   </p>
                                               </div>
                                               <p className="font-heading text-xl font-bold text-foreground tracking-tighter">{formatCurrency(item.totalPrice)}</p>
                                           </div>
                                           
                                           <div className="flex items-center gap-4">
                                              {order.status === "COMPLETED" && !item.review && (
                                                  <button onClick={() => setReviewingItemId(item.id)} className="flex items-center gap-2 text-[8px] font-bold uppercase tracking-widest text-gold hover:opacity-80 cursor-pointer">
                                                      <Star size={12} /> {tDetail("write_review")}
                                                  </button>
                                              )}
                                              {item.review && (
                                                  <span className="flex items-center gap-2 text-[8px] font-bold uppercase tracking-widest text-emerald-600 dark:text-emerald-500">
                                                      <Check size={12} /> {tDetail("reviewed")}
                                                  </span>
                                              )}
                                           </div>
                                       </div>
                                   </div>
                               </div>
                           );
                      })}
                  </div>
              </motion.div>

              <div className="glass rounded-[3rem] p-10">
                  <div className="flex items-center gap-4 mb-8">
                      <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-stone-100 dark:bg-white/5 text-gold">
                          <MapPin size={24} />
                      </div>
                      <h2 className="font-heading text-xl font-bold uppercase tracking-widest text-foreground">{tDetail("shipping_address")}</h2>
                  </div>
                  <p className="font-body text-base text-stone-600 dark:text-stone-300 leading-relaxed max-w-xl">{order.shippingAddress}</p>
                  {order.phone && (
                      <div className="mt-6 flex items-center gap-3 text-stone-500 dark:text-stone-600">
                          <Phone size={14} className="text-gold/60" />
                          <span className="text-xs font-bold uppercase tracking-widest">{order.phone}</span>
                      </div>
                  )}
              </div>
          </div>

          {/* Sidebar Intel */}
          <div className="lg:col-span-4 space-y-8">
              <div className="glass rounded-[3rem] p-10 shadow-2xl">
                  <div className="space-y-8">
                      <div className="space-y-2">
                          <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-400 dark:text-stone-700">{tDetail("status")}</p>
                          <div className={cn("inline-flex items-center gap-3 rounded-full border px-6 py-2 text-[10px] font-bold uppercase tracking-widest shadow-lg shadow-black/5 dark:shadow-black/20", style.color)}>
                              <style.icon size={14} /> {style.label}
                          </div>
                      </div>

                      <div className="space-y-2">
                          <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-400 dark:text-stone-700">{tDetail("payment")}</p>
                          <p className="text-[10px] font-bold uppercase tracking-widest text-foreground">
                              {order.paymentStatus === "PAID" ? tDetail("payment_status.paid") : order.paymentStatus}
                          </p>
                      </div>

                      {["PENDING", "CONFIRMED", "PROCESSING"].includes(order.status) && (
                          <button disabled={cancelling} onClick={handleCancelOrder} className="w-full flex h-14 items-center justify-center gap-3 rounded-2xl border border-red-500/20 bg-red-500/5 text-[10px] font-bold uppercase tracking-widest text-red-600 dark:text-red-500 transition-all hover:bg-red-500/10 cursor-pointer">
                              {cancelling ? <Loader2 size={16} className="animate-spin" /> : <XCircle size={16} />}
                              {tDetail("cancel_order")}
                          </button>
                      )}

                      {needsRefundBankInfo && (
                          <button onClick={() => setShowRefundModal(true)} className="w-full flex h-14 items-center justify-center gap-3 rounded-2xl bg-red-600 dark:bg-red-500 text-[10px] font-bold uppercase tracking-widest text-white shadow-lg shadow-red-500/20 cursor-pointer">
                              <Zap size={16} /> Refund Registry Required
                          </button>
                      )}
                      
                      <div className="pt-8 border-t border-black/5 dark:border-white/5 space-y-4">
                          <div className="flex justify-between items-center text-[10px] font-bold uppercase tracking-widest">
                              <span className="text-stone-400 dark:text-stone-700">{tDetail("subtotal")}</span>
                              <span className="text-stone-600 dark:text-stone-300">{formatCurrency(order.totalAmount)}</span>
                          </div>
                          {order.discountAmount > 0 && (
                              <div className="flex justify-between items-center text-[10px] font-bold uppercase tracking-widest">
                                  <span className="text-stone-400 dark:text-stone-700">{tDetail("discount")}</span>
                                  <span className="text-red-600 dark:text-red-500">-{formatCurrency(order.discountAmount)}</span>
                              </div>
                          )}
                          <div className="flex justify-between items-center pt-4">
                              <span className="text-xs font-bold uppercase tracking-[0.3em] text-foreground">{tDetail("total")}</span>
                              <span className="font-heading text-3xl font-bold text-gold tracking-tighter">{formatCurrency(order.finalAmount)}</span>
                          </div>
                      </div>
                  </div>
              </div>

              {shipments.length > 0 && (
                  <div className="glass rounded-[3rem] p-10 bg-opacity-50 dark:bg-opacity-20">
                      <div className="flex items-center gap-4 mb-8">
                          <Truck size={20} className="text-gold" />
                          <h2 className="font-heading text-lg font-bold uppercase tracking-widest text-foreground">{tDetail("tracking")}</h2>
                      </div>
                      <div className="space-y-6">
                          {shipments.map((s) => (
                              <div key={s.id} className="space-y-4 rounded-2xl bg-stone-100 dark:bg-white/5 p-6 border border-black/5 dark:border-white/5">
                                  <div>
                                      <p className="text-[8px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-700 mb-1">{tDetail("tracking_code")}</p>
                                      <p className="font-mono text-sm font-bold text-foreground">{s.trackingCode || s.ghnOrderCode || "—"}</p>
                                  </div>
                                  <a href={`${TRACKING_URL}${s.trackingCode || s.ghnOrderCode}`} target="_blank" rel="noopener noreferrer" className="flex items-center gap-3 text-[8px] font-bold uppercase tracking-widest text-gold hover:opacity-80 cursor-pointer">
                                      GHN Manifest <ExternalLink size={12} />
                                  </a>
                              </div>
                          ))}
                      </div>
                  </div>
              )}
          </div>
      </div>

      {showRefundModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
              <div className="absolute inset-0 bg-black/60 dark:bg-black/80 backdrop-blur-md" onClick={() => setShowRefundModal(false)} />
              <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="glass relative w-full max-w-xl rounded-[3rem] p-12 shadow-2xl">
                  <div className="mb-10 space-y-4">
                      <div className="flex items-center gap-3 rounded-full border border-red-500/20 bg-red-500/5 px-4 py-2 text-[10px] font-bold uppercase tracking-widest text-red-600 dark:text-red-500 w-fit">
                          <Zap size={14} /> Refund Sync Request
                      </div>
                      <h3 className="font-heading text-3xl font-bold uppercase tracking-widest text-foreground">Account Registry</h3>
                      <p className="text-xs text-stone-500">Please provide the financial coordinates for the reversal process.</p>
                  </div>

                  <div className="space-y-4">
                      {[
                          { label: 'Institution', key: 'bankName', placeholder: 'Bank Name' },
                          { label: 'Identifier', key: 'accountNumber', placeholder: 'Account Number' },
                          { label: 'Holder', key: 'accountHolder', placeholder: 'Full Name' }
                      ].map((field) => (
                          <div key={field.key} className="space-y-2">
                              <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 px-4">{field.label}</p>
                              <input
                                  value={(refundInfo as any)[field.key]}
                                  onChange={(e) => setRefundInfo(p => ({ ...p, [field.key]: e.target.value }))}
                                  placeholder={field.placeholder}
                                  className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] text-foreground"
                              />
                          </div>
                      ))}
                      <div className="space-y-2">
                          <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 px-4">Encryption Note</p>
                          <textarea
                              value={refundInfo.note}
                              onChange={(e) => setRefundInfo(p => ({ ...p, note: e.target.value }))}
                              placeholder="Optional metadata..."
                              className="w-full rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100/50 dark:bg-white/[0.02] py-5 px-6 text-sm outline-none transition-all focus:border-gold/30 focus:bg-stone-100 dark:focus:bg-white/[0.05] min-h-[120px] text-foreground"
                          />
                      </div>
                  </div>

                  <div className="mt-10 flex gap-4">
                      <button onClick={() => setShowRefundModal(false)} className="flex-1 h-16 rounded-full border border-black/5 dark:border-white/10 text-[10px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-500 hover:bg-black/5 cursor-pointer">Cancel</button>
                      <button
                          disabled={savingRefundInfo || !refundInfo.bankName || !refundInfo.accountNumber || !refundInfo.accountHolder}
                          onClick={async () => {
                              setSavingRefundInfo(true);
                              try {
                                  await orderService.submitRefundBankInfo(orderId, refundInfo);
                                  setShowRefundModal(false);
                                  fetchOrder();
                              } catch (e: any) {
                                  alert(e?.response?.data?.message || 'Synchronization failed');
                              } finally { setSavingRefundInfo(false); }
                          }}
                          className="flex-1 h-16 rounded-full bg-gold text-[10px] font-bold uppercase tracking-widest text-black shadow-lg shadow-gold/20 disabled:opacity-20 cursor-pointer"
                      >
                          {savingRefundInfo ? 'Transmitting...' : 'Commit Protocol'}
                      </button>
                  </div>
              </motion.div>
          </div>
      )}

      {reviewingItemId && (
          <ReviewModal 
            orderItemId={reviewingItemId} 
            onClose={() => { setReviewingItemId(null); fetchOrder(); }} 
          />
      )}
    </div>
  );
}
