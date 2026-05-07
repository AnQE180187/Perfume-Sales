"use client";

import React, { useEffect, useState, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Package,
  Sparkles,
  CheckCircle2,
  Truck,
  Star,
  Settings,
  ChevronRight,
  Circle,
  Loader2,
  Bell,
} from "lucide-react";
import { useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import {
  notificationService,
  type Notification,
} from "@/services/notification.service";
import { getNotificationSocket, resetNotificationSocket } from "@/lib/socket";
import { AuthGuard } from "@/components/auth/auth-guard";

const TYPE_CONFIG: Record<
  string,
  { icon: React.ElementType; color: string; bg: string; border: string }
> = {
  ORDER: { icon: Package, color: "text-blue-500", bg: "bg-blue-500/10", border: "border-blue-500/20" },
  SHIPPING: { icon: Truck, color: "text-amber-500", bg: "bg-amber-500/10", border: "border-amber-500/20" },
  PROMOTION: { icon: Sparkles, color: "text-gold", bg: "bg-gold/10", border: "border-gold/20" },
  LOYALTY: { icon: Star, color: "text-emerald-500", bg: "bg-emerald-500/10", border: "border-emerald-500/20" },
  SYSTEM: { icon: Settings, color: "text-stone-500", bg: "bg-stone-500/10", border: "border-stone-500/20" },
};

export default function NotificationsPage() {
  const t = useTranslations("dashboard.customer.notifications");
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [total, setTotal] = useState(0);
  const [skip, setSkip] = useState(0);
  const take = 20;

  const formatTime = useCallback((dateStr: string) => {
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMin = Math.floor(diffMs / 60000);
    if (diffMin < 1) return t("time.just_now");
    if (diffMin < 60) return t("time.mins_ago", { count: diffMin });
    const diffHours = Math.floor(diffMin / 60);
    if (diffHours < 24) return t("time.hours_ago", { count: diffHours });
    const diffDays = Math.floor(diffHours / 24);
    if (diffDays === 1) return t("time.yesterday");
    if (diffDays < 7) return t("time.days_ago", { count: diffDays });
    return date.toLocaleDateString();
  }, [t]);

  const fetchNotifications = useCallback(async (s = 0) => {
    try {
      const res = await notificationService.getNotifications({ skip: s, take });
      if (s === 0) {
        setNotifications(res.data);
      } else {
        setNotifications((prev) => [...prev, ...res.data]);
      }
      setTotal(res.total);
      setSkip(s);
    } catch {
      // silently fail
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchNotifications();

    const socket = getNotificationSocket();
    const userId = typeof window !== "undefined" ? localStorage.getItem("userId") : null;
    if (userId) {
      socket.emit("join", { userId });
    }
    socket.on("notification", (data: Notification) => {
      setNotifications((prev) => [data, ...prev]);
      setTotal((prev) => prev + 1);
    });

    return () => {
      socket.off("notification");
      resetNotificationSocket();
    };
  }, [fetchNotifications]);

  const handleMarkAsRead = async (id: string) => {
    await notificationService.markAsRead(id);
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, isRead: true } : n)),
    );
  };

  const handleMarkAllAsRead = async () => {
    await notificationService.markAllAsRead();
    setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
  };

  const loadMore = () => {
    if (notifications.length < total) {
      fetchNotifications(skip + take);
    }
  };

  return (
    <div className="space-y-12 pb-12">
        <header className="flex flex-col md:flex-row md:items-end justify-between gap-8">
          <div>
            <div className="flex items-center gap-4 mb-4">
                <div className="h-[1px] w-12 bg-gold/50" />
                <span className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">Registry</span>
            </div>
            <h1 className="font-heading text-5xl font-bold uppercase tracking-tighter text-foreground md:text-6xl">
              Neural <span className="gold-gradient">Broadcast</span>
            </h1>
            <p className="mt-4 font-body text-[10px] font-bold uppercase tracking-widest text-stone-500">{t("subtitle")}</p>
          </div>
          <button
            onClick={handleMarkAllAsRead}
            className="h-14 rounded-full border border-black/5 dark:border-white/10 px-10 text-[10px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-400 hover:bg-gold hover:text-black transition-all flex items-center gap-3 cursor-pointer"
          >
            {t("mark_all_read")} <CheckCircle2 size={16} />
          </button>
        </header>

        {loading ? (
          <div className="flex h-[400px] items-center justify-center">
            <Loader2 className="h-10 w-10 animate-spin text-gold" />
          </div>
        ) : notifications.length === 0 ? (
          <div className="py-24 text-center glass rounded-[3rem]">
            <Bell className="mx-auto text-stone-200 dark:text-stone-800 mb-6" size={64} />
            <p className="text-[10px] uppercase font-bold tracking-[0.3em] text-stone-400 dark:text-stone-700">{t("empty")}</p>
          </div>
        ) : (
          <div className="space-y-6">
            <AnimatePresence mode="popLayout">
              {notifications.map((notif, i) => {
                const config = TYPE_CONFIG[notif.type] || TYPE_CONFIG.SYSTEM;
                const Icon = config.icon;
                return (
                  <motion.div
                    key={notif.id}
                    layout
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: i * 0.05 }}
                    className={cn(
                      "group relative glass rounded-[2.5rem] p-8 md:p-10 transition-all duration-500 cursor-pointer overflow-hidden",
                      notif.isRead
                        ? "opacity-60 grayscale-[0.5]"
                        : "border-gold/10 shadow-2xl shadow-gold/5 hover:border-gold/30"
                    )}
                    onClick={() => !notif.isRead && handleMarkAsRead(notif.id)}
                  >
                    {!notif.isRead && (
                      <div className="absolute top-0 right-0 w-32 h-32 bg-gold/5 blur-3xl pointer-events-none" />
                    )}

                    <div className="flex flex-col md:flex-row gap-8 items-start relative z-10">
                      <div
                        className={cn(
                          "w-16 h-16 rounded-2xl flex items-center justify-center shrink-0 transition-all duration-700 glass border group-hover:scale-110 group-hover:rotate-3",
                          config.bg,
                          config.border
                        )}
                      >
                        <Icon
                          className={config.color}
                          size={24}
                          strokeWidth={1.5}
                        />
                      </div>

                      <div className="flex-1 space-y-4">
                        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                          <h3
                            className={cn(
                              "font-heading text-xl font-bold uppercase tracking-widest transition-colors duration-500",
                              notif.isRead ? "text-stone-500" : "text-foreground"
                            )}
                          >
                            {notif.title}
                          </h3>
                          <div className="flex items-center gap-4">
                            <span className="text-[10px] font-bold text-stone-400 dark:text-stone-600 uppercase tracking-widest bg-stone-100 dark:bg-white/5 px-4 py-1 rounded-full">
                              {formatTime(notif.createdAt)}
                            </span>
                            {!notif.isRead && (
                                <Circle size={8} className="fill-gold text-gold animate-pulse" />
                            )}
                          </div>
                        </div>

                        <p
                          className={cn(
                            "font-body text-base leading-relaxed max-w-3xl transition-colors duration-500",
                            notif.isRead ? "text-stone-400" : "text-stone-600 dark:text-stone-300"
                          )}
                        >
                          {notif.content}
                        </p>

                        <div className="flex items-center gap-8 pt-6 opacity-0 group-hover:opacity-100 transition-all duration-500 translate-y-2 group-hover:translate-y-0">
                          <button className="text-[10px] font-bold uppercase tracking-[0.2em] text-gold flex items-center gap-2 hover:underline underline-offset-8 cursor-pointer">
                            {t("view_details")} <ChevronRight size={14} />
                          </button>
                          {!notif.isRead && (
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleMarkAsRead(notif.id);
                              }}
                              className="text-[10px] font-bold uppercase tracking-[0.2em] text-stone-400 hover:text-foreground cursor-pointer"
                            >
                              {t("mark_read")}
                            </button>
                          )}
                        </div>
                      </div>
                    </div>
                  </motion.div>
                );
              })}
            </AnimatePresence>
          </div>
        )}

        {notifications.length < total && (
          <footer className="mt-16 text-center">
            <button
              onClick={loadMore}
              className="h-14 rounded-full border border-black/5 dark:border-white/10 px-10 text-[10px] font-bold uppercase tracking-[0.3em] text-stone-500 dark:text-stone-400 hover:bg-gold hover:text-black transition-all cursor-pointer"
            >
              {t("load_more")}
            </button>
          </footer>
        )}
    </div>
  );
}
