"use client";

import { useEffect, useState } from "react";
import { useTranslations, useFormatter } from "next-intl";
import { motion } from "framer-motion";
import {
  RotateCcw,
  Clock,
  CheckCircle,
  XCircle,
  Truck,
  Package,
  AlertCircle,
  ChevronRight,
  Loader2,
  RefreshCw,
} from "lucide-react";
import {
  returnsService,
  ReturnRequest,
  ReturnStatus,
} from "@/services/returns.service";
import { Link } from "@/lib/i18n";
import { cn } from "@/lib/utils";

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

export function ReturnList() {
  const t = useTranslations("dashboard.customer.returns");
  const tFeatured = useTranslations("featured");
  const format = useFormatter();
  const [returns, setReturns] = useState<ReturnRequest[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchReturns = () => {
    setLoading(true);
    returnsService.listMyReturns().then(setReturns).catch(() => setReturns([])).finally(() => setLoading(false));
  };

  useEffect(() => { fetchReturns(); }, []);

  const formatCurrency = (amount?: number) => {
    if (!amount) return "—";
    return format.number(amount, {
      style: "currency",
      currency: tFeatured("currency_code") || "VND",
      maximumFractionDigits: 0,
    });
  };

  return (
    <div className="space-y-12 pb-12">
      <header>
          <div className="flex items-center gap-4 mb-4">
              <div className="h-[1px] w-12 bg-gold/50" />
              <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry</span>
          </div>
          <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
              Reversion <span className="gold-gradient">Logs</span>
          </h1>
          <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest text-stone-500">{t("subtitle")}</p>
      </header>

      <div className="space-y-6">
        {loading ? (
            <div className="flex h-[400px] items-center justify-center">
                <Loader2 className="h-10 w-10 animate-spin text-gold" />
            </div>
        ) : returns.length === 0 ? (
            <div className="py-24 text-center glass rounded-[3rem]">
                <RotateCcw className="mx-auto text-stone-200 dark:text-stone-800 mb-6" size={64} strokeWidth={1} />
                <h3 className="font-heading text-2xl uppercase tracking-widest text-foreground">{t("empty_title")}</h3>
                <p className="mt-4 text-[10px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">{t("empty_desc")}</p>
                <Link href="/dashboard/customer/orders" className="mt-8 inline-flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-gold hover:opacity-80">
                    {t("back_to_orders")} <ChevronRight size={14} />
                </Link>
            </div>
        ) : (
            returns.map((ret, i) => {
                const config = STATUS_CONFIG[ret.status as ReturnStatus] || STATUS_CONFIG.REQUESTED;
                const Icon = config.icon;

                return (
                    <motion.div
                        key={ret.id}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="group relative glass rounded-[2.5rem] p-8 md:p-10 hover:border-gold/30 transition-all duration-500 shadow-2xl shadow-black/5 dark:shadow-black/20"
                    >
                        <div className="relative flex flex-col lg:flex-row lg:items-center justify-between gap-10">
                            <div className="flex-1 space-y-8">
                                <div className="flex flex-wrap items-center gap-6">
                                    <div className={cn(
                                        "flex h-16 w-16 items-center justify-center rounded-2xl glass border group-hover:scale-110 group-hover:rotate-3 transition-all duration-700",
                                        config.color.split(" ")[0], // bg
                                        config.color.split(" ")[2]  // border
                                    )}>
                                        <Icon size={28} className={config.color.split(" ")[1]} />
                                    </div>
                                    <div>
                                        <p className="text-[10px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700 mb-1">ID: #{ret.id.slice(-8).toUpperCase()}</p>
                                        <h3 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground">
                                            {t("items_count", { count: ret.items.length })} {t("items_label")}
                                        </h3>
                                    </div>
                                </div>

                                <div className="flex flex-wrap gap-12 pt-4">
                                    <div className="space-y-2">
                                        <p className="text-[9px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">Order Ref</p>
                                        <p className="text-[11px] font-bold text-foreground">#{ret.orderId.slice(-8).toUpperCase()}</p>
                                    </div>
                                    {ret.refundAmount != null && (
                                        <div className="space-y-2">
                                            <p className="text-[9px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">Refund Value</p>
                                            <p className="font-heading text-xl font-bold text-gold tracking-tighter">{formatCurrency(ret.refundAmount)}</p>
                                        </div>
                                    )}
                                    <div className="space-y-2">
                                        <p className="text-[9px] font-bold uppercase tracking-widest text-stone-400 dark:text-stone-700">Status</p>
                                        <div className={cn("inline-flex items-center gap-2 rounded-full border px-5 py-1.5 text-[10px] font-bold uppercase tracking-widest shadow-lg", config.color)}>
                                            <div className="h-1.5 w-1.5 rounded-full bg-current animate-pulse" />
                                            {t(`status.${ret.status}` as any) || ret.status}
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div className="shrink-0">
                                <Link href={`/dashboard/customer/returns/${ret.id}`} className="flex h-14 items-center gap-3 rounded-full bg-gold px-10 text-[10px] font-bold uppercase tracking-widest text-black shadow-lg shadow-gold/20 hover:scale-105 transition-all">
                                    Details <ChevronRight size={14} />
                                </Link>
                            </div>
                        </div>
                    </motion.div>
                );
            })
        )}
      </div>
    </div>
  );
}
