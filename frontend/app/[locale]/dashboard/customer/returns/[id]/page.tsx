"use client";

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import { useTranslations, useFormatter } from "next-intl";
import { motion, AnimatePresence } from "framer-motion";
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
  ArrowUpRight,
  ShieldCheck,
  Zap
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
import { Badge } from "@/components/ui/badge";

const STATUS_CONFIG: Record<ReturnStatus, { icon: any; color: string }> = {
  REQUESTED: { icon: Clock, color: "bg-amber-500/10 text-amber-500 border-amber-500/20" },
  AWAITING_CUSTOMER: { icon: AlertCircle, color: "bg-blue-500/10 text-blue-500 border-blue-500/20" },
  REVIEWING: { icon: RefreshCw, color: "bg-purple-500/10 text-purple-500 border-purple-500/20" },
  APPROVED: { icon: CheckCircle, color: "bg-emerald-500/10 text-emerald-500 border-emerald-500/20" },
  RETURNING: { icon: Truck, color: "bg-orange-500/10 text-orange-500 border-orange-500/20" },
  RECEIVED: { icon: Package, color: "bg-teal-500/10 text-teal-500 border-teal-500/20" },
  REFUNDING: { icon: RefreshCw, color: "bg-indigo-500/10 text-indigo-500 border-indigo-500/20" },
  REFUND_FAILED: { icon: XCircle, color: "bg-red-500/10 text-red-500 border-red-500/20" },
  COMPLETED: { icon: CheckCircle, color: "bg-gold/10 text-gold border-gold/20" },
  REJECTED: { icon: XCircle, color: "bg-red-500/10 text-red-500 border-red-500/20" },
  REJECTED_AFTER_RETURN: { icon: XCircle, color: "bg-red-500/10 text-red-500 border-red-500/20" },
  CANCELLED: { icon: XCircle, color: "bg-stone-500/10 text-stone-500 border-stone-500/20" },
};

const CAN_ADD_SHIPMENT: ReturnStatus[] = ["APPROVED", "RETURNING"];
const CAN_CANCEL: ReturnStatus[] = ["REQUESTED", "AWAITING_CUSTOMER"];

export default function CustomerReturnDetailPage() {
  const t = useTranslations("dashboard.customer.returns.detail");
  const tStatus = useTranslations("dashboard.customer.returns.status");
  const tFeatured = useTranslations("featured");
  const format = useFormatter();
  const params = useParams();
  const returnId = params?.id as string;
  const tReasons = useTranslations("dashboard.customer.returns.create_modal.reasons");

  const getReasonLabel = (reason: string | undefined): string => {
    if (!reason) return "";
    if (reason.includes(" | ")) {
      const [main, ...rest] = reason.split(" | ");
      const note = rest.join(" | ");
      return `${getReasonLabel(main)} | ${note}`;
    }
    const match = reason.match(/^\[(.*)\]$/);
    if (match) {
      const key = match[1].toLowerCase();
      try { return tReasons(key); } catch { return reason; }
    }
    return reason;
  };

  const [returnReq, setReturnReq] = useState<ReturnRequest | null>(null);
  const [loading, setLoading] = useState(true);
  const [showShipment, setShowShipment] = useState(false);
  const [courier, setCourier] = useState("");
  const [trackingNumber, setTrackingNumber] = useState("");
  const [submittingShipment, setSubmittingShipment] = useState(false);
  const [showCancelConfirm, setShowCancelConfirm] = useState(false);
  const [cancelReason, setCancelReason] = useState("");
  const [cancelling, setCancelling] = useState(false);
  const [confirmingHandover, setConfirmingHandover] = useState(false);

  const fetchReturn = async () => {
    if (!returnId) return;
    try {
      const data = await returnsService.getReturn(returnId);
      setReturnReq(data);
    } catch { setReturnReq(null); } finally { setLoading(false); }
  };

  useEffect(() => { fetchReturn(); }, [returnId]);

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
      await returnsService.addShipment(returnId, { courier: courier || undefined, trackingNumber });
      toast.success(t("shipment_added"));
      setShowShipment(false);
      setCourier("");
      setTrackingNumber("");
      fetchReturn();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || t("shipment_error"));
    } finally { setSubmittingShipment(false); }
  };

  const handleCancel = async () => {
    setCancelling(true);
    try {
      await returnsService.cancelReturn(returnId, cancelReason || undefined);
      toast.success(t("cancelled"));
      setShowCancelConfirm(false);
      fetchReturn();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || t("cancel_error"));
    } finally { setCancelling(false); }
  };

  const handleHandover = async () => {
    setConfirmingHandover(true);
    try {
      await returnsService.handoverReturn(returnId);
      toast.success(t("shipment_confirmed"));
      fetchReturn();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || t("handover_error"));
    } finally { setConfirmingHandover(false); }
  };

  if (loading) {
    return (
        <div className="flex h-[400px] items-center justify-center">
            <Loader2 className="h-10 w-10 animate-spin text-gold" />
        </div>
    );
  }

  if (!returnReq) {
    return (
        <div className="py-24 text-center glass rounded-[3rem]">
          <XCircle className="mx-auto text-red-500/20 mb-6" size={80} />
          <h2 className="font-heading text-2xl uppercase tracking-widest text-foreground">{t("not_found")}</h2>
          <Link href="/dashboard/customer/returns" className="mt-8 inline-flex h-12 items-center px-8 rounded-full border border-black/5 dark:border-white/10 text-[10px] font-bold uppercase tracking-widest text-stone-400 hover:bg-gold hover:text-black transition-all">
            {t("back")}
          </Link>
        </div>
    );
  }

  const cfg = STATUS_CONFIG[returnReq.status as ReturnStatus] || STATUS_CONFIG.REQUESTED;
  const canAddShipment = CAN_ADD_SHIPMENT.includes(returnReq.status as ReturnStatus);
  const canCancel = CAN_CANCEL.includes(returnReq.status as ReturnStatus);

  return (
      <div className="space-y-12 pb-12">
        <header>
          <Link href="/dashboard/customer/returns" className="group mb-8 inline-flex items-center gap-3 text-[10px] font-bold uppercase tracking-widest text-gold">
            <ArrowLeft size={16} className="transition-transform group-hover:-translate-x-1" /> {t("back")}
          </Link>
          <div className="flex items-center gap-4 mb-4">
            <div className="h-[1px] w-12 bg-gold/50" />
            <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry #{returnReq.id.slice(-8).toUpperCase()}</span>
          </div>
          <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
            Reversion <span className="gold-gradient">Coordinates</span>
          </h1>
          <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest text-stone-500">{t("subtitle", { defaultValue: "Tracking the lifecycle of your item return request." })}</p>
        </header>

        {/* Global Intel Strip */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="glass rounded-[2.5rem] p-8 md:p-10 flex flex-col md:flex-row items-center gap-8 lg:gap-12 shadow-2xl">
            <div className="flex-1 space-y-2">
                <p className="text-[8px] font-bold uppercase tracking-[0.3em] text-stone-400 dark:text-stone-700">{t("reason")}</p>
                <p className="font-heading text-xl font-bold text-foreground leading-tight uppercase tracking-widest">{getReasonLabel(returnReq.reason)}</p>
            </div>
            <div className="h-px w-full md:h-12 md:w-px bg-black/5 dark:bg-white/5" />
            <div className="flex-1 space-y-3">
                <p className="text-[8px] font-bold uppercase tracking-[0.3em] text-stone-400 dark:text-stone-700">{t("shipping_fee_responsibility")}</p>
                <div className="flex items-center gap-3">
                    {['[DAMAGED]', '[WRONG_ITEM]', '[EXPIRED]'].some(r => returnReq.reason?.includes(r)) ? (
                        <div className="flex items-center gap-2 text-emerald-500 font-bold uppercase tracking-widest text-[10px]">
                            <ShieldCheck size={16} /> {t("shipping_fee_shop")}
                        </div>
                    ) : (
                        <div className="flex items-center gap-2 text-amber-500 font-bold uppercase tracking-widest text-[10px]">
                            <AlertCircle size={16} /> {t("shipping_fee_customer")}
                        </div>
                    )}
                </div>
            </div>
        </motion.div>

        <div className="grid grid-cols-1 gap-12 lg:grid-cols-12">
            {/* Main Manifesto */}
            <div className="lg:col-span-8 space-y-8">
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} className="glass rounded-[3rem] p-10 lg:p-16 shadow-2xl">
                    <h2 className="mb-12 font-heading text-2xl font-bold uppercase tracking-widest text-foreground">{t("items")}</h2>
                    <div className="space-y-12 divide-y divide-black/5 dark:divide-white/5">
                        {returnReq.items.map((item, i) => (
                            <div key={item.id} className="pt-12 first:pt-0">
                                <div className="flex flex-col sm:flex-row gap-10">
                                    <div className="relative h-32 w-32 shrink-0 overflow-hidden rounded-[2rem] bg-stone-100 dark:bg-zinc-800 border border-black/5 dark:border-white/5 flex items-center justify-center">
                                        <Package className="text-stone-300 dark:text-stone-700" size={48} />
                                    </div>
                                    <div className="flex-1 space-y-6">
                                        <div className="space-y-2">
                                            <p className="text-[8px] font-bold uppercase tracking-widest text-gold/60 mb-1">Variant #{item.variantId.slice(-6).toUpperCase()}</p>
                                            <h3 className="font-heading text-2xl font-bold text-foreground uppercase tracking-widest">Quantity: {item.quantity}</h3>
                                        </div>
                                        {item.reason && <p className="font-body text-[10px] font-bold uppercase tracking-widest text-stone-500 italic leading-relaxed">"{getReasonLabel(item.reason)}"</p>}
                                        
                                        {item.images && item.images.length > 0 && (
                                            <div className="pt-6 space-y-4">
                                                <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">{t("images")}</p>
                                                <div className="flex flex-wrap gap-4">
                                                    {item.images.map((url, idx) => (
                                                        <a key={idx} href={url} target="_blank" rel="noopener noreferrer" className="group relative h-24 w-24 overflow-hidden rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100 dark:bg-zinc-800 transition-all hover:border-gold/50">
                                                            <Image src={url} alt="Evidence" fill className="object-cover transition-transform group-hover:scale-110" />
                                                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                                                <ArrowUpRight size={16} className="text-white" />
                                                            </div>
                                                        </a>
                                                    ))}
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </motion.div>

                {/* Shipment Logistics */}
                {canAddShipment && (
                    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }} className={cn("glass rounded-[3rem] p-10 lg:p-16 shadow-2xl", returnReq.origin === "ONLINE" && returnReq.shipments?.some(s => s.courier === "GHN") && "border-blue-500/20")}>
                        <div className="flex items-center gap-6 mb-12">
                            <div className={cn("flex h-16 w-16 items-center justify-center rounded-2xl glass border", returnReq.origin === "ONLINE" && returnReq.shipments?.some(s => s.courier === "GHN") ? "text-blue-500 border-blue-500/20" : "text-gold border-gold/20")}>
                                <Truck size={28} />
                            </div>
                            <h2 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground">{t("shipment_title")}</h2>
                        </div>

                        {returnReq.origin === "ONLINE" && returnReq.shipments?.some(s => s.courier === "GHN") ? (
                            <div className="space-y-10">
                                <div className="space-y-4">
                                    <div className="flex items-center gap-3 text-blue-500 font-bold uppercase tracking-widest text-[10px]">
                                        <CheckCircle size={16} /> {t("pickup_scheduled")}
                                    </div>
                                    <p className="font-body text-sm text-stone-500 leading-relaxed max-w-xl">
                                        {t.rich("pickup_instruction", {
                                            phone: returnReq.order?.phone || "registered",
                                            strong: (chunks) => <strong className="text-blue-500 font-bold">{chunks}</strong>
                                        })}
                                    </p>
                                </div>

                                <div className="grid gap-6 sm:grid-cols-2">
                                    {returnReq.shipments.filter(s => s.courier === "GHN").map(s => (
                                        <div key={s.id} className="rounded-3xl border border-blue-500/10 bg-blue-500/5 p-8 space-y-6">
                                            <div>
                                                <p className="text-[8px] font-bold uppercase tracking-widest text-blue-500/60 mb-2">GHN Tracking Manifest</p>
                                                <p className="font-heading text-2xl font-bold text-blue-500 uppercase select-all tracking-widest">{s.trackingNumber}</p>
                                            </div>
                                            <a href={`https://donhang.ghn.vn/?order_code=${s.trackingNumber}`} target="_blank" rel="noopener noreferrer" className="flex h-12 items-center justify-center gap-3 rounded-full bg-blue-500 text-[10px] font-bold uppercase tracking-widest text-white shadow-xl shadow-blue-500/30 transition-all hover:scale-105">
                                                Track Shipment <ArrowUpRight size={14} />
                                            </a>
                                        </div>
                                    ))}
                                </div>

                                {returnReq.status === "APPROVED" && (
                                    <button onClick={handleHandover} disabled={confirmingHandover} className="w-full flex h-16 items-center justify-center gap-4 rounded-2xl bg-blue-500 text-[10px] font-bold uppercase tracking-widest text-white shadow-xl shadow-blue-500/20 transition-all hover:scale-[1.02] disabled:opacity-50 cursor-pointer">
                                        {confirmingHandover ? <Loader2 size={18} className="animate-spin" /> : <Zap size={18} />}
                                        {t("confirm_handover")}
                                    </button>
                                )}
                            </div>
                        ) : (
                            <div className="space-y-10">
                                <p className="font-body text-sm text-stone-500 leading-relaxed max-w-xl">{t("shipping_instruction_manual")}</p>
                                <div className="rounded-3xl border border-gold/20 bg-gold/5 p-10 space-y-4">
                                    <p className="text-[8px] font-bold uppercase tracking-widest text-gold mb-2">{t("showroom_address_title")}</p>
                                    <p className="font-heading text-2xl font-bold text-foreground uppercase tracking-widest">{t("showroom_name")}</p>
                                    <p className="font-body text-sm text-stone-500 italic leading-relaxed">{t("showroom_address_detail")}</p>
                                </div>

                                {!showShipment ? (
                                    <button onClick={() => setShowShipment(true)} className="flex h-16 items-center gap-4 rounded-full bg-gold px-12 text-[10px] font-bold uppercase tracking-widest text-black shadow-xl shadow-gold/20 transition-all hover:scale-105 cursor-pointer">
                                        <Send size={18} /> {t("submit_shipment")}
                                    </button>
                                ) : (
                                    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="space-y-8 pt-4">
                                        <div className="grid gap-8 sm:grid-cols-2">
                                            <div className="space-y-3">
                                                <label className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">{t("courier")}</label>
                                                <input type="text" value={courier} onChange={(e) => setCourier(e.target.value)} className="w-full h-14 rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100 dark:bg-zinc-800 px-8 text-[10px] font-bold uppercase tracking-widest text-foreground outline-none focus:border-gold/50 transition-all" placeholder={t("courier_placeholder")} />
                                            </div>
                                            <div className="space-y-3">
                                                <label className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">{t("tracking_number")}</label>
                                                <input type="text" value={trackingNumber} onChange={(e) => setTrackingNumber(e.target.value)} className="w-full h-14 rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100 dark:bg-zinc-800 px-8 font-mono text-[10px] font-bold uppercase tracking-[0.3em] text-foreground outline-none focus:border-gold/50 transition-all" placeholder={t("tracking_placeholder")} />
                                            </div>
                                        </div>
                                        <div className="flex gap-4">
                                            <button onClick={handleAddShipment} disabled={submittingShipment || !trackingNumber.trim()} className="flex-1 flex h-16 items-center justify-center gap-4 rounded-2xl bg-gold text-[10px] font-bold uppercase tracking-widest text-black shadow-xl shadow-gold/20 disabled:opacity-50 cursor-pointer">
                                                {submittingShipment ? <Loader2 size={18} className="animate-spin" /> : <Send size={18} />}
                                                {submittingShipment ? t("submitting") : t("submit_shipment")}
                                            </button>
                                            <button onClick={() => setShowShipment(false)} className="h-16 w-16 flex items-center justify-center rounded-2xl border border-black/5 dark:border-white/10 text-stone-400 hover:text-foreground cursor-pointer">
                                                <X size={24} />
                                            </button>
                                        </div>
                                    </motion.div>
                                )}
                            </div>
                        )}
                    </motion.div>
                )}

                {/* Refund Intelligence Archive */}
                {returnReq.status === "COMPLETED" && returnReq.refunds && returnReq.refunds.length > 0 && (
                    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }} className="glass rounded-[3rem] p-10 lg:p-16 shadow-2xl border-emerald-500/20">
                        <div className="flex items-center gap-6 mb-12">
                            <div className="flex h-16 w-16 items-center justify-center rounded-2xl glass border border-emerald-500/20 text-emerald-500">
                                <Banknote size={28} />
                            </div>
                            <h2 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground">{t("refund_confirmation_title")}</h2>
                        </div>

                        {returnReq.refunds.map((refund, idx) => (
                            <div key={idx} className="space-y-10">
                                <div className="grid gap-8 sm:grid-cols-2">
                                    <div className="rounded-3xl border border-emerald-500/10 bg-emerald-500/5 p-8 space-y-2">
                                        <p className="text-[8px] font-bold uppercase tracking-widest text-emerald-500/60">Manifest Amount</p>
                                        <p className="font-heading text-4xl font-bold text-emerald-500 tracking-tighter">{formatCurrency(refund.amount)}</p>
                                    </div>
                                    <div className="rounded-3xl border border-emerald-500/10 bg-emerald-500/5 p-8 space-y-2">
                                        <p className="text-[8px] font-bold uppercase tracking-widest text-emerald-500/60">Execution Date</p>
                                        <p className="font-heading text-xl font-bold text-foreground uppercase tracking-widest">{format.dateTime(new Date(refund.createdAt!), { dateStyle: 'medium', timeStyle: 'short' })}</p>
                                    </div>
                                </div>
                                {refund.note && (
                                    <div className="rounded-3xl glass p-10 border-black/5 dark:border-white/5">
                                        <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 mb-4">{t("admin_message_label")}</p>
                                        <p className="font-body text-sm text-stone-500 italic leading-relaxed">"{refund.note}"</p>
                                    </div>
                                )}
                                {refund.receiptImage && (
                                    <div className="space-y-6">
                                        <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">{t("receipt_image_label")}</p>
                                        <a href={refund.receiptImage} target="_blank" rel="noopener noreferrer" className="group relative block w-full max-w-lg overflow-hidden rounded-[2.5rem] border border-black/5 dark:border-white/5 bg-stone-100 dark:bg-zinc-800">
                                            <img src={refund.receiptImage} alt="Refund Receipt" className="w-full object-contain transition-transform duration-700 group-hover:scale-105" />
                                            <div className="absolute inset-0 bg-emerald-500/5 opacity-0 group-hover:opacity-100 transition-opacity" />
                                        </a>
                                    </div>
                                )}
                            </div>
                        ))}
                    </motion.div>
                )}
            </div>

            {/* Sidebar Intel */}
            <div className="lg:col-span-4 space-y-8">
                <div className="glass rounded-[3rem] p-10 shadow-2xl space-y-10">
                    <div className="space-y-4">
                        <p className="text-[8px] font-bold uppercase tracking-[0.4em] text-stone-400 dark:text-stone-700">{t("status")}</p>
                        <div className={cn("inline-flex items-center gap-3 rounded-full border px-6 py-2 text-[10px] font-bold uppercase tracking-widest shadow-xl", cfg.color)}>
                            <cfg.icon size={14} className="animate-pulse" /> {tStatus(returnReq.status as any)}
                        </div>
                    </div>

                    <div className="space-y-6 pt-10 border-t border-black/5 dark:border-white/5">
                        <div className="space-y-2">
                            <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">{t("return_id")}</p>
                            <p className="font-mono text-[10px] font-bold text-foreground break-all tracking-widest">#{returnReq.id.toUpperCase()}</p>
                        </div>
                        <div className="space-y-2">
                            <p className="text-[8px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">{t("order")}</p>
                            <Link href={`/dashboard/customer/orders/${returnReq.orderId}`} className="group flex items-center gap-2 font-mono text-[10px] font-bold text-gold tracking-widest">
                                #{returnReq.orderId.slice(-12).toUpperCase()} <ArrowUpRight size={14} className="transition-transform group-hover:translate-x-1 group-hover:-translate-y-1" />
                            </Link>
                        </div>
                    </div>

                    {returnReq.paymentInfo && (
                        <div className="rounded-3xl border border-gold/20 bg-gold/5 p-8 space-y-6">
                            <p className="text-[8px] font-bold uppercase tracking-widest text-gold/60">{t("payment_info_title")}</p>
                            <div className="space-y-4">
                                <div className="flex justify-between items-center text-[10px] font-bold uppercase tracking-widest">
                                    <span className="text-stone-400 dark:text-stone-700">Bank</span>
                                    <span className="text-foreground">{returnReq.paymentInfo.bankName}</span>
                                </div>
                                <div className="flex justify-between items-center text-[10px] font-bold uppercase tracking-widest">
                                    <span className="text-stone-400 dark:text-stone-700">Holder</span>
                                    <span className="text-foreground">{returnReq.paymentInfo.accountName}</span>
                                </div>
                                <div className="flex justify-between items-center text-[10px] font-bold uppercase tracking-widest pt-2 border-t border-gold/10">
                                    <span className="text-stone-400 dark:text-stone-700">Account</span>
                                    <span className="font-mono text-gold text-sm tracking-widest">{returnReq.paymentInfo.accountNumber}</span>
                                </div>
                            </div>
                        </div>
                    )}

                    <div className="pt-10 border-t border-black/5 dark:border-white/5 space-y-6">
                        {returnReq.totalAmount != null && (
                            <div className="flex justify-between items-center text-[10px] font-bold uppercase tracking-widest">
                                <span className="text-stone-400 dark:text-stone-700">{t("total_amount")}</span>
                                <span className="text-stone-600 dark:text-stone-300">{formatCurrency(returnReq.totalAmount)}</span>
                            </div>
                        )}
                        {returnReq.refundAmount != null && returnReq.refundAmount > 0 && (
                            <div className="flex justify-between items-end pt-6 border-t border-black/5 dark:border-white/5">
                                <span className="text-[10px] font-bold uppercase tracking-[0.3em] text-foreground">{t("refund_amount")}</span>
                                <span className="font-heading text-4xl font-bold text-gold tracking-tighter">{formatCurrency(returnReq.refundAmount)}</span>
                            </div>
                        )}
                    </div>
                </div>

                {canCancel && (
                    <div className="glass rounded-[3rem] p-10 space-y-8 shadow-xl">
                        {!showCancelConfirm ? (
                            <button onClick={() => setShowCancelConfirm(true)} className="w-full flex h-14 items-center justify-center gap-3 rounded-full border border-red-500/20 text-[10px] font-bold uppercase tracking-widest text-red-500/60 hover:text-red-500 hover:border-red-500 transition-all cursor-pointer">
                                <XCircle size={16} /> {t("cancel_btn")}
                            </button>
                        ) : (
                            <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="space-y-6">
                                <p className="text-[10px] font-bold uppercase tracking-widest text-foreground text-center">{t("cancel_confirm")}</p>
                                <textarea value={cancelReason} onChange={(e) => setCancelReason(e.target.value)} className="w-full h-32 rounded-2xl border border-black/5 dark:border-white/5 bg-stone-100 dark:bg-zinc-800 p-6 text-[10px] font-bold uppercase tracking-widest text-foreground outline-none focus:border-red-500/30 transition-all resize-none" placeholder={t("cancel_reason_placeholder")} />
                                <div className="flex gap-4">
                                    <button onClick={handleCancel} disabled={cancelling} className="flex-1 flex h-14 items-center justify-center gap-3 rounded-2xl bg-red-500 text-[10px] font-bold uppercase tracking-widest text-white shadow-xl shadow-red-500/20 hover:scale-[1.02] active:scale-95 transition-all cursor-pointer">
                                        {cancelling ? <Loader2 size={18} className="animate-spin" /> : <CheckCircle size={18} />}
                                        {t("cancel_btn")}
                                    </button>
                                    <button onClick={() => setShowCancelConfirm(false)} className="h-14 w-14 flex items-center justify-center rounded-2xl border border-black/5 dark:border-white/10 text-stone-400 hover:text-foreground cursor-pointer">
                                        <X size={24} />
                                    </button>
                                </div>
                            </motion.div>
                        )}
                    </div>
                )}
      </div>
    </div>
  </div>
  );
}
