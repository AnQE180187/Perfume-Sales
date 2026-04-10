"use client";

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { useTranslations, useFormatter } from "next-intl";
import { motion } from "framer-motion";
import Image from "next/image";
import {
  ArrowLeft,
  Loader2,
  RotateCcw,
  Clock,
  CheckCircle,
  XCircle,
  Truck,
  Package,
  AlertCircle,
  RefreshCw,
  Send,
  X,
  Banknote,
  ImageIcon,
} from "lucide-react";
import { Link } from "@/lib/i18n";
import { AuthGuard } from "@/components/auth/auth-guard";
import {
  returnsService,
  ReturnRequest,
  ReturnStatus,
} from "@/services/returns.service";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

const STATUS_CONFIG: Record<ReturnStatus, { icon: any; color: string }> = {
  REQUESTED: {
    icon: Clock,
    color: "bg-amber-500/10 text-amber-600 border-amber-500/20",
  },
  AWAITING_CUSTOMER: {
    icon: AlertCircle,
    color: "bg-blue-500/10 text-blue-600 border-blue-500/20",
  },
  REVIEWING: {
    icon: RefreshCw,
    color: "bg-purple-500/10 text-purple-600 border-purple-500/20",
  },
  APPROVED: {
    icon: CheckCircle,
    color: "bg-emerald-500/10 text-emerald-600 border-emerald-500/20",
  },
  RETURNING: {
    icon: Truck,
    color: "bg-orange-500/10 text-orange-600 border-orange-500/20",
  },
  RECEIVED: {
    icon: Package,
    color: "bg-teal-500/10 text-teal-600 border-teal-500/20",
  },
  REFUNDING: {
    icon: RefreshCw,
    color: "bg-indigo-500/10 text-indigo-600 border-indigo-500/20",
  },
  REFUND_FAILED: {
    icon: XCircle,
    color: "bg-red-500/10 text-red-600 border-red-500/20",
  },
  COMPLETED: {
    icon: CheckCircle,
    color: "bg-gold/10 text-amber-600 border-gold/20",
  },
  REJECTED: {
    icon: XCircle,
    color: "bg-red-500/10 text-red-600 border-red-500/20",
  },
  REJECTED_AFTER_RETURN: {
    icon: XCircle,
    color: "bg-red-500/10 text-red-600 border-red-500/20",
  },
  CANCELLED: {
    icon: XCircle,
    color: "bg-stone-500/10 text-stone-500 border-stone-500/20",
  },
};

/** Statuses where customer can add shipment info */
const CAN_ADD_SHIPMENT: ReturnStatus[] = ["APPROVED", "RETURNING"];
/** Statuses where customer can cancel */
const CAN_CANCEL: ReturnStatus[] = ["REQUESTED", "AWAITING_CUSTOMER"];

export default function CustomerReturnDetailPage() {
  const t = useTranslations("dashboard.customer.returns.detail");
  const tStatus = useTranslations("dashboard.customer.returns.status");
  const tFeatured = useTranslations("featured");
  const format = useFormatter();
  const params = useParams();
  const returnId = params?.id as string;

  const [returnReq, setReturnReq] = useState<ReturnRequest | null>(null);
  const [loading, setLoading] = useState(true);

  // Shipment form
  const [showShipment, setShowShipment] = useState(false);
  const [courier, setCourier] = useState("");
  const [trackingNumber, setTrackingNumber] = useState("");
  const [submittingShipment, setSubmittingShipment] = useState(false);

  // Cancel
  const [showCancelConfirm, setShowCancelConfirm] = useState(false);
  const [cancelReason, setCancelReason] = useState("");
  const [cancelling, setCancelling] = useState(false);

  const fetchReturn = async () => {
    if (!returnId) return;
    try {
      const data = await returnsService.getReturn(returnId);
      setReturnReq(data);
    } catch {
      setReturnReq(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReturn();
  }, [returnId]);

  const formatCurrency = (amount?: number) => {
    if (!amount) return "—";
    return format.number(amount, {
      style: "currency",
      currency: tFeatured("currency_code") || "VND",
      maximumFractionDigits: 0,
    });
  };

  const handleAddShipment = async () => {
    if (!trackingNumber.trim()) return;
    setSubmittingShipment(true);
    try {
      await returnsService.addShipment(returnId, {
        courier: courier || undefined,
        trackingNumber,
      });
      toast.success(t("shipment_added"));
      setShowShipment(false);
      setCourier("");
      setTrackingNumber("");
      fetchReturn();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || "Lỗi cập nhật thông tin");
    } finally {
      setSubmittingShipment(false);
    }
  };

  const handleCancel = async () => {
    setCancelling(true);
    try {
      await returnsService.cancelReturn(returnId, cancelReason || undefined);
      toast.success(t("cancelled"));
      setShowCancelConfirm(false);
      fetchReturn();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || "Lỗi hủy yêu cầu");
    } finally {
      setCancelling(false);
    }
  };

  if (loading) {
    return (
      <AuthGuard allowedRoles={["customer", "staff", "admin"]}>
        <div className="flex justify-center items-center py-24">
          <Loader2 className="animate-spin text-gold" size={40} />
        </div>
      </AuthGuard>
    );
  }

  if (!returnReq) {
    return (
      <AuthGuard allowedRoles={["customer", "staff", "admin"]}>
        <div className="py-20 text-center">
          <p className="text-muted-foreground mb-4">{t("not_found")}</p>
          <Link
            href="/dashboard/customer/returns"
            className="text-gold hover:underline font-bold text-sm"
          >
            {t("back")}
          </Link>
        </div>
      </AuthGuard>
    );
  }

  const cfg =
    STATUS_CONFIG[returnReq.status as ReturnStatus] || STATUS_CONFIG.REQUESTED;
  const StatusIcon = cfg.icon;
  const canAddShipment = CAN_ADD_SHIPMENT.includes(
    returnReq.status as ReturnStatus
  );
  const canCancel = CAN_CANCEL.includes(returnReq.status as ReturnStatus);

  return (
    <AuthGuard allowedRoles={["customer", "staff", "admin"]}>
      <div className="flex flex-col gap-10 py-10 px-8">
        {/* Header */}
        <header>
          <Link
            href="/dashboard/customer/returns"
            className="inline-flex items-center gap-2 text-gold hover:text-gold/80 mb-6 font-bold uppercase tracking-widest text-[10px]"
          >
            <ArrowLeft size={16} />
            {t("back")}
          </Link>
          <h1 className="text-4xl md:text-5xl font-heading gold-gradient mb-2 uppercase tracking-tighter">
            {t("title")}
          </h1>
          <p className="text-[10px] text-muted-foreground uppercase tracking-[.3em] font-bold font-mono">
            #{returnReq.id.slice(-12).toUpperCase()}
          </p>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main content */}
          <div className="lg:col-span-2 space-y-8">
            {/* Items */}
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              className="glass bg-black/40 shadow-2xl rounded-3xl p-8 border border-gold/20 backdrop-blur-md"
            >
              <h2 className="text-xl font-heading uppercase tracking-widest mb-6 border-b border-gold/10 pb-4 text-gold/90">
                {t("items")}
              </h2>
              <div className="space-y-6">
                {returnReq.items.map((item) => (
                  <div
                    key={item.id}
                    className="py-3 border-b border-border/50 last:border-0"
                  >
                    <div className="flex items-start gap-4">
                      <div className="w-12 h-12 rounded-xl bg-secondary flex-shrink-0 flex items-center justify-center text-muted-foreground/50">
                        <Package size={20} />
                      </div>
                      <div className="flex-1">
                        <p className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground">
                          Variant ID: {item.variantId.slice(-8).toUpperCase()}
                        </p>
                        <p className="text-sm font-bold text-foreground">
                          × {item.quantity}
                        </p>
                        {item.reason && (
                          <p className="text-[11px] text-muted-foreground mt-1 italic">
                            "{item.reason}"
                          </p>
                        )}
                      </div>
                    </div>

                    {/* Item images */}
                    {item.images && item.images.length > 0 && (
                      <div className="mt-4 ml-16">
                        <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-widest mb-3">
                          {t("images")}
                        </p>
                        <div className="flex gap-3 flex-wrap">
                          {item.images.map((url, idx) => {
                            const isVideo = url.match(/\.(mp4|webm|mov)$/i) || url.includes("res.cloudinary.com/perfume-gpt/video") || url.includes("returns/videos");
                            return (
                              <div key={idx} className="w-24 h-24 sm:w-32 sm:h-32 rounded-xl overflow-hidden relative border border-gold/20 hover:border-gold/60 transition-colors shadow-lg bg-black/50 group">
                                {isVideo ? (
                                  <video 
                                    src={url} 
                                    controls 
                                    className="w-full h-full object-cover"
                                  />
                                ) : (
                                  <a href={url} target="_blank" rel="noopener noreferrer" className="block w-full h-full">
                                    <Image
                                      src={url}
                                      alt={`evidence-${idx}`}
                                      fill
                                      className="object-cover group-hover:scale-110 transition-transform duration-500"
                                      sizes="128px"
                                    />
                                  </a>
                                )}
                              </div>
                            );
                          })}
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </motion.div>

            {/* Shipment section (for APPROVED status) */}
            {canAddShipment && (
              <motion.div
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="glass bg-background/40 rounded-[3rem] p-8 border border-amber-500/20"
              >
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-8 h-8 rounded-xl bg-amber-500/10 flex items-center justify-center">
                    <Truck size={16} className="text-amber-500" />
                  </div>
                  <h2 className="text-lg font-heading uppercase tracking-widest text-foreground">
                    {t("shipment_title")}
                  </h2>
                </div>
                <p className="text-[11px] text-muted-foreground mb-6 leading-relaxed">
                  {t("shipment_desc")}
                </p>

                {!showShipment ? (
                  <button
                    onClick={() => setShowShipment(true)}
                    className="flex items-center gap-2 px-5 py-3 bg-amber-500/10 text-amber-600 border border-amber-500/30 rounded-2xl text-[10px] font-bold uppercase tracking-widest hover:bg-amber-500/20 transition-all"
                  >
                    <Send size={12} />
                    {t("submit_shipment")}
                  </button>
                ) : (
                  <div className="space-y-4">
                    <div>
                      <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground block mb-2">
                        {t("courier")}
                      </label>
                      <input
                        type="text"
                        value={courier}
                        onChange={(e) => setCourier(e.target.value)}
                        placeholder={t("courier_placeholder")}
                        className="w-full bg-background/60 border border-border rounded-xl px-4 py-2.5 text-sm placeholder:text-muted-foreground/50 focus:outline-none focus:border-gold/50 transition-colors"
                      />
                    </div>
                    <div>
                      <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground block mb-2">
                        {t("tracking_number")}
                      </label>
                      <input
                        type="text"
                        value={trackingNumber}
                        onChange={(e) => setTrackingNumber(e.target.value)}
                        placeholder={t("tracking_placeholder")}
                        className="w-full bg-background/60 border border-border rounded-xl px-4 py-2.5 text-sm placeholder:text-muted-foreground/50 focus:outline-none focus:border-gold/50 transition-colors"
                      />
                    </div>
                    <div className="flex gap-3">
                      <button
                        onClick={handleAddShipment}
                        disabled={submittingShipment || !trackingNumber.trim()}
                        className="flex items-center gap-2 px-5 py-3 bg-gold text-primary-foreground rounded-2xl text-[10px] font-bold uppercase tracking-widest hover:bg-gold/90 transition-all disabled:opacity-40"
                      >
                        {submittingShipment ? (
                          <Loader2 size={12} className="animate-spin" />
                        ) : (
                          <Send size={12} />
                        )}
                        {submittingShipment ? t("submitting") : t("submit_shipment")}
                      </button>
                      <button
                        onClick={() => setShowShipment(false)}
                        className="px-4 py-3 text-[10px] font-bold uppercase tracking-widest text-muted-foreground hover:text-foreground transition-colors"
                      >
                        <X size={14} />
                      </button>
                    </div>
                  </div>
                )}
              </motion.div>
            )}

            {/* Cancel section */}
            {canCancel && (
              <motion.div
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="glass bg-background/40 rounded-[3rem] p-8 border border-border"
              >
                {!showCancelConfirm ? (
                  <button
                    onClick={() => setShowCancelConfirm(true)}
                    className="flex items-center gap-2 text-red-500 hover:text-red-400 text-[10px] font-bold uppercase tracking-widest transition-colors"
                  >
                    <XCircle size={14} />
                    {t("cancel_btn")}
                  </button>
                ) : (
                  <div className="space-y-4">
                    <p className="text-sm font-bold text-foreground">
                      {t("cancel_confirm")}
                    </p>
                    <textarea
                      value={cancelReason}
                      onChange={(e) => setCancelReason(e.target.value)}
                      placeholder={t("cancel_reason_placeholder")}
                      rows={3}
                      className="w-full bg-background/60 border border-border rounded-xl px-4 py-3 text-sm placeholder:text-muted-foreground/50 focus:outline-none focus:border-red-500/50 transition-colors resize-none"
                    />
                    <div className="flex gap-3">
                      <button
                        onClick={handleCancel}
                        disabled={cancelling}
                        className="flex items-center gap-2 px-5 py-3 bg-red-500/10 text-red-500 border border-red-500/20 rounded-2xl text-[10px] font-bold uppercase tracking-widest hover:bg-red-500/20 transition-all disabled:opacity-40"
                      >
                        {cancelling ? (
                          <Loader2 size={12} className="animate-spin" />
                        ) : (
                          <XCircle size={12} />
                        )}
                        {cancelling ? t("cancelling") : t("cancel_btn")}
                      </button>
                      <button
                        onClick={() => setShowCancelConfirm(false)}
                        className="px-4 py-3 text-[10px] font-bold uppercase tracking-widest text-muted-foreground hover:text-foreground transition-colors"
                      >
                        <X size={14} />
                      </button>
                    </div>
                  </div>
                )}
              </motion.div>
            )}

            {/* === REFUND CONFIRMATION SECTION === */}
            {returnReq.status === "COMPLETED" &&
              returnReq.refunds &&
              returnReq.refunds.length > 0 &&
              (() => {
                const latestRefund = returnReq.refunds![returnReq.refunds!.length - 1];
                return (
                  <motion.div
                    initial={{ opacity: 0, y: 16 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.15 }}
                    className="glass bg-emerald-950/30 rounded-3xl p-8 border border-emerald-500/30 shadow-2xl backdrop-blur-md"
                  >
                    {/* Header */}
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 rounded-2xl bg-emerald-500/15 flex items-center justify-center ring-1 ring-emerald-500/30">
                        <Banknote size={18} className="text-emerald-400" />
                      </div>
                      <div>
                        <h2 className="text-base font-heading uppercase tracking-widest text-emerald-300">
                          Xác Nhận Hoàn Tiền Thành Công
                        </h2>
                        <p className="text-[9px] text-emerald-500/70 font-bold uppercase tracking-widest mt-0.5">
                          Admin đã chuyển khoản vào tài khoản của bạn
                        </p>
                      </div>
                      <span className="ml-auto inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 border border-emerald-500/30 text-[9px] font-black text-emerald-400 uppercase tracking-widest">
                        <CheckCircle size={10} /> Thành công
                      </span>
                    </div>

                    {/* Amount + time */}
                    <div className="bg-emerald-900/20 border border-emerald-500/20 rounded-2xl p-4 mb-5 flex items-center justify-between gap-4">
                      <div>
                        <p className="text-[9px] font-bold uppercase tracking-widest text-emerald-500/80 mb-1">Số tiền đã hoàn</p>
                        <p className="text-2xl font-heading text-emerald-300">
                          {formatCurrency(latestRefund.amount)}
                        </p>
                      </div>
                      {latestRefund.createdAt && (
                        <div className="text-right">
                          <p className="text-[9px] font-bold uppercase tracking-widest text-emerald-500/80 mb-1">Thời gian</p>
                          <p className="text-xs text-emerald-300/80 font-mono">
                            {new Date(latestRefund.createdAt).toLocaleString("vi-VN")}
                          </p>
                        </div>
                      )}
                    </div>

                    {/* Admin note/message */}
                    {latestRefund.note && (
                      <div className="mb-5 bg-black/30 border border-emerald-500/15 rounded-2xl p-4">
                        <p className="text-[9px] font-bold uppercase tracking-widest text-emerald-500/80 mb-2">Lời nhắn từ cửa hàng</p>
                        <p className="text-sm text-emerald-100/90 leading-relaxed italic">&ldquo;{latestRefund.note}&rdquo;</p>
                      </div>
                    )}

                    {/* Receipt image */}
                    {latestRefund.receiptImage ? (
                      <div>
                        <p className="text-[9px] font-bold uppercase tracking-widest text-emerald-500/80 mb-3">Hình ảnh hóa đơn chuyển khoản</p>
                        <a
                          href={latestRefund.receiptImage}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="block relative rounded-2xl overflow-hidden border border-emerald-500/30 bg-black/40 group hover:border-emerald-400/60 transition-colors max-w-xs"
                        >
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={latestRefund.receiptImage}
                            alt="Hóa đơn chuyển khoản"
                            className="w-full object-contain max-h-72 group-hover:scale-[1.02] transition-transform duration-500"
                          />
                          <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end p-3">
                            <span className="text-[9px] font-bold text-white uppercase tracking-widest">Nhấn để xem toàn màn hình</span>
                          </div>
                        </a>
                      </div>
                    ) : (
                      <div className="flex items-center gap-2 text-emerald-500/50 text-[10px] font-bold uppercase tracking-widest">
                        <ImageIcon size={12} /> Không có hình ảnh hóa đơn
                      </div>
                    )}
                  </motion.div>
                );
              })()}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Status card */}
            <motion.div
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              className="glass bg-black/40 rounded-3xl p-8 border border-gold/20 shadow-2xl backdrop-blur-md"
            >
              <h3 className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground mb-4">
                {t("status")}
              </h3>
              <span
                className={cn(
                  "inline-flex items-center gap-2 px-4 py-2 rounded-full text-[10px] font-black uppercase tracking-widest border",
                  cfg.color
                )}
              >
                <StatusIcon size={12} />
                {tStatus(returnReq.status as any)}
              </span>
            </motion.div>

            {/* Details */}
            <motion.div
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.1 }}
              className="glass bg-black/40 rounded-3xl p-8 border border-gold/20 shadow-2xl space-y-6 backdrop-blur-md"
            >
              <div>
                <p className="text-[9px] font-bold text-muted-foreground uppercase tracking-widest mb-1">
                  {t("return_id")}
                </p>
                <p className="font-mono text-xs font-bold text-foreground break-all">
                  {returnReq.id}
                </p>
              </div>

              <div>
                <p className="text-[9px] font-bold text-muted-foreground uppercase tracking-widest mb-1">
                  {t("order")}
                </p>
                <Link
                  href={`/dashboard/customer/orders/${returnReq.orderId}`}
                  className="font-mono text-xs font-bold text-gold hover:underline break-all"
                >
                  {returnReq.orderId.slice(-10).toUpperCase()}
                </Link>
              </div>

              {returnReq.reason && (
                <div>
                  <p className="text-[9px] font-bold text-muted-foreground uppercase tracking-widest mb-1">
                    {t("reason")}
                  </p>
                  <p className="text-sm text-foreground italic whitespace-pre-wrap">
                    "{returnReq.reason}"
                  </p>
                </div>
              )}

              {returnReq.paymentInfo && (
                <div className="bg-indigo-900/20 border border-indigo-500/20 p-4 rounded-xl mt-2">
                   <p className="text-[9px] font-bold text-indigo-300 uppercase tracking-widest mb-2">
                     Thông tin nhận hoàn tiền
                   </p>
                   <p className="text-xs text-white">Ngân hàng: <span className="font-semibold text-indigo-200">{returnReq.paymentInfo.bankName}</span></p>
                   <p className="text-xs text-white mt-1">Chủ tài khoản: <span className="font-semibold text-indigo-200">{returnReq.paymentInfo.accountName}</span></p>
                   <p className="text-xs text-white mt-1">Số tài khoản: <span className="font-mono bg-black/30 px-2 py-0.5 rounded text-indigo-200">{returnReq.paymentInfo.accountNumber}</span></p>
                </div>
              )}

              {returnReq.totalAmount != null && (
                <div>
                  <p className="text-[9px] font-bold text-muted-foreground uppercase tracking-widest mb-1">
                    {t("total_amount")}
                  </p>
                  <p className="text-lg font-heading text-foreground">
                    {formatCurrency(returnReq.totalAmount)}
                  </p>
                </div>
              )}

              {returnReq.refundAmount != null &&
                returnReq.refundAmount > 0 && (
                  <div className="pt-4 border-t border-border">
                    <p className="text-[9px] font-bold text-muted-foreground uppercase tracking-widest mb-1">
                      {t("refund_amount")}
                    </p>
                    <p className="text-2xl font-heading text-gold">
                      {formatCurrency(returnReq.refundAmount)}
                    </p>
                  </div>
                )}
            </motion.div>
          </div>
        </div>
      </div>
    </AuthGuard>
  );
}
