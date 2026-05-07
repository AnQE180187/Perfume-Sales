"use client";

import { useState, useRef } from "react";
import Image from "next/image";
import { useTranslations } from "next-intl";
import {
  X,
  RotateCcw,
  Minus,
  Plus,
  Upload,
  Loader2,
  CheckCircle,
  ImageIcon,
  Video,
  Trash2,
  AlertCircle,
  Play,
  Zap,
  Package,
  ArrowUpRight
} from "lucide-react";
import { returnsService } from "@/services/returns.service";
import api from "@/lib/axios";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { motion, AnimatePresence } from "framer-motion";

interface OrderItem {
  id: number;
  variantId: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  product?: {
    id: string;
    name: string;
    images?: { url: string }[];
  };
}

interface CreateReturnModalProps {
  orderId: string;
  items: OrderItem[];
  onClose: () => void;
  onSuccess: () => void;
}

interface ReturnItemState {
  selected: boolean;
  quantity: number;
  reason: string;
  images: string[];
  videoUrl: string | null;
  videoName: string | null;
  uploadingImages: boolean;
  uploadingVideo: boolean;
}

const MIN_IMAGES = 3;
const MAX_IMAGES = 5;
const MIN_VIDEO_SECONDS = 3;
const MAX_VIDEO_SECONDS = 60;

export function CreateReturnModal({
  orderId,
  items,
  onClose,
  onSuccess,
}: CreateReturnModalProps) {
  const t = useTranslations("dashboard.customer.returns.create_modal");

  const [reason, setReason] = useState("");
  const [selectedReasonType, setSelectedReasonType] = useState<"STORE" | "CUSTOMER" | "">(""); 
  const [additionalNote, setAdditionalNote] = useState("");
  const [bankName, setBankName] = useState("");
  const [bankAccount, setBankAccount] = useState("");
  const [bankHolder, setBankHolder] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [itemStates, setItemStates] = useState<Record<number, ReturnItemState>>(() => {
    const initial: Record<number, ReturnItemState> = {};
    items.forEach((item) => {
      initial[item.id] = {
        selected: false,
        quantity: 1,
        reason: "",
        images: [],
        videoUrl: null,
        videoName: null,
        uploadingImages: false,
        uploadingVideo: false,
      };
    });
    return initial;
  });

  const imageInputRefs = useRef<Record<number, HTMLInputElement | null>>({});
  const videoInputRefs = useRef<Record<number, HTMLInputElement | null>>({});

  const toggleItem = (id: number) =>
    setItemStates((prev) => ({
      ...prev,
      [id]: { ...prev[id], selected: !prev[id].selected },
    }));

  const updateQty = (id: number, delta: number) => {
    const item = items.find((i) => i.id === id);
    if (!item) return;
    setItemStates((prev) => ({
      ...prev,
      [id]: {
        ...prev[id],
        quantity: Math.min(item.quantity, Math.max(1, prev[id].quantity + delta)),
      },
    }));
  };

  const updateReason = (id: number, value: string) =>
    setItemStates((prev) => ({
      ...prev,
      [id]: { ...prev[id], reason: value },
    }));

  const handleImageUpload = async (id: number, files: FileList | null) => {
    if (!files || files.length === 0) return;
    const current = itemStates[id].images.length;
    const remaining = MAX_IMAGES - current;
    if (remaining <= 0) return;

    setItemStates((prev) => ({
      ...prev,
      [id]: { ...prev[id], uploadingImages: true },
    }));
    try {
      const validFiles = Array.from(files).slice(0, remaining).filter((f) => {
          if (f.size > 5 * 1024 * 1024) {
            toast.error(`Image "${f.name}" exceeds 5MB`);
            return false;
          }
          return true;
        });

      if (validFiles.length === 0) {
          setItemStates((prev) => ({ ...prev, [id]: { ...prev[id], uploadingImages: false } }));
          return;
      }
      const formData = new FormData();
      validFiles.forEach((f) => formData.append("images", f));
      const res = await api.post<string[]>("/reviews/upload-images", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      setItemStates((prev) => ({
        ...prev,
        [id]: {
          ...prev[id],
          images: [...prev[id].images, ...res.data],
          uploadingImages: false,
        },
      }));
    } catch {
      toast.error(t("error_upload_failed") || "Upload error");
      setItemStates((prev) => ({ ...prev, [id]: { ...prev[id], uploadingImages: false } }));
    }
  };

  const removeImage = (itemId: number, imgIdx: number) =>
    setItemStates((prev) => ({
      ...prev,
      [itemId]: { ...prev[itemId], images: prev[itemId].images.filter((_, i) => i !== imgIdx) },
    }));

  const handleVideoSelect = async (id: number, files: FileList | null) => {
    if (!files || files.length === 0) return;
    const file = files[0];

    const getVideoDuration = (file: File): Promise<number> => {
        return new Promise((resolve) => {
            const video = document.createElement('video');
            video.preload = 'metadata';
            video.onloadedmetadata = () => {
                window.URL.revokeObjectURL(video.src);
                resolve(video.duration);
            };
            video.src = URL.createObjectURL(file);
        });
    };

    const duration = await getVideoDuration(file);
    if (duration < MIN_VIDEO_SECONDS) {
      toast.error(t("video_too_short"));
      if (videoInputRefs.current[id]) videoInputRefs.current[id]!.value = "";
      return;
    }
    if (duration > MAX_VIDEO_SECONDS) {
      toast.error(t("video_too_long"));
      if (videoInputRefs.current[id]) videoInputRefs.current[id]!.value = "";
      return;
    }

    setItemStates((prev) => ({ ...prev, [id]: { ...prev[id], uploadingVideo: true } }));
    try {
      const formData = new FormData();
      formData.append("video", file);
      const res = await api.post<{ url: string }>("/returns/upload-video", formData, {
          headers: { "Content-Type": "multipart/form-data" },
      });
      setItemStates((prev) => ({
        ...prev,
        [id]: {
          ...prev[id],
          videoUrl: res.data.url,
          videoName: file.name,
          uploadingVideo: false,
        },
      }));
      toast.success(t("video_uploaded"));
    } catch {
      toast.error(t("error_upload_failed") || "Upload error");
      setItemStates((prev) => ({ ...prev, [id]: { ...prev[id], uploadingVideo: false } }));
    }
  };

  const removeVideo = (id: number) => {
    setItemStates((prev) => ({ ...prev, [id]: { ...prev[id], videoUrl: null, videoName: null } }));
    if (videoInputRefs.current[id]) videoInputRefs.current[id]!.value = "";
  };

  const handleSubmit = async () => {
    const selectedItems = items.filter((i) => itemStates[i.id]?.selected);
    if (selectedItems.length === 0) {
      toast.error(t("error_no_items"));
      return;
    }
    for (const item of selectedItems) {
      if (itemStates[item.id].quantity <= 0) {
        toast.error(t("error_qty"));
        return;
      }
      if (itemStates[item.id].images.length < MIN_IMAGES) {
        toast.error(t("min_images_warning"));
        return;
      }
    }

    if (!selectedReasonType || !reason) {
      toast.error(t("error_select_reason"));
      return;
    }

    if (!bankName.trim() || !bankAccount.trim() || !bankHolder.trim()) {
      toast.error(t("error_bank_info"));
      return;
    }

    setSubmitting(true);
    try {
      const idempotencyKey = crypto.randomUUID();
      const completeReason = additionalNote.trim() ? `${reason} | ${additionalNote.trim()}` : reason;

      await returnsService.createReturn({
          orderId,
          reason: completeReason,
          paymentInfo: { bankName, accountNumber: bankAccount, accountName: bankHolder },
          items: selectedItems.map((item) => ({
            variantId: item.variantId,
            quantity: itemStates[item.id].quantity,
            reason: itemStates[item.id].reason || undefined,
            images: [
              ...itemStates[item.id].images,
              ...(itemStates[item.id].videoUrl ? [itemStates[item.id].videoUrl!] : []),
            ],
          })),
        }, idempotencyKey);
      toast.success(t("success"));
      onSuccess();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || t("error_submit_failed"));
    } finally { setSubmitting(false); }
  };

  const formatCurrency = (amount: number) =>
    new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(amount);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="absolute inset-0 bg-black/80 backdrop-blur-xl" onClick={onClose} />

      <motion.div initial={{ opacity: 0, scale: 0.95, y: 20 }} animate={{ opacity: 1, scale: 1, y: 0 }} className="relative w-full max-w-2xl max-h-[90vh] flex flex-col bg-zinc-950 border border-white/5 rounded-[3rem] shadow-2xl overflow-hidden backdrop-blur-3xl">
        {/* Header */}
        <div className="flex items-center justify-between px-10 py-8 border-b border-white/5 flex-shrink-0">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gold/10 text-gold">
                <RotateCcw size={20} />
              </div>
              <h2 className="font-heading text-2xl font-bold uppercase tracking-widest text-foreground">{t("title")}</h2>
            </div>
            <p className="text-[10px] font-bold uppercase tracking-[0.4em] text-stone-500">{t("subtitle")}</p>
          </div>
          <button onClick={onClose} className="group h-12 w-12 rounded-full border border-white/5 flex items-center justify-center text-stone-500 hover:text-foreground transition-all">
            <X size={20} className="transition-transform group-hover:rotate-90" />
          </button>
        </div>

        {/* Manifest Body */}
        <div className="flex-1 overflow-y-auto custom-scrollbar px-10 py-10 space-y-10">
          {/* Item Selection Archive */}
          <div className="space-y-6">
            <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-700">{t("select_items")}</p>
            <div className="space-y-4">
              {items.map((item) => {
                const state = itemStates[item.id];
                const imageUrl = item.product?.images?.[0]?.url;
                return (
                  <div key={item.id} className={cn("rounded-[2.5rem] border transition-all duration-500 overflow-hidden", state.selected ? "border-gold/30 bg-gold/5" : "border-white/5 bg-zinc-900/40")}>
                    <div className="flex items-center gap-6 p-6 cursor-pointer" onClick={() => toggleItem(item.id)}>
                      <div className={cn("h-6 w-6 rounded-lg border-2 flex items-center justify-center transition-all", state.selected ? "bg-gold border-gold" : "border-stone-800")}>
                        {state.selected && <CheckCircle size={14} className="text-black" />}
                      </div>
                      <div className="relative h-16 w-16 overflow-hidden rounded-2xl border border-white/5 bg-zinc-800">
                        {imageUrl ? <Image src={imageUrl} alt={item.product?.name || ""} fill className="object-cover" /> : <Package className="m-auto text-stone-700" size={24} />}
                      </div>
                      <div className="flex-1">
                        <p className="font-heading text-base font-bold uppercase tracking-widest text-foreground line-clamp-1">{item.product?.name}</p>
                        <p className="text-[10px] font-bold uppercase tracking-widest text-stone-500">× {item.quantity} · {formatCurrency(item.unitPrice)}</p>
                      </div>
                      <p className="font-heading text-lg font-bold text-foreground tracking-tighter">{formatCurrency(item.totalPrice)}</p>
                    </div>

                    <AnimatePresence>
                      {state.selected && (
                        <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }} exit={{ height: 0, opacity: 0 }} className="px-6 pb-8 border-t border-white/5 pt-6 space-y-8">
                          <div className="flex items-center gap-6">
                            <span className="text-[9px] font-bold uppercase tracking-widest text-stone-700">Coordinates (Qty)</span>
                            <div className="flex h-10 items-center gap-4 rounded-xl bg-white/5 p-1 px-3 border border-white/5">
                                <button onClick={(e) => { e.stopPropagation(); updateQty(item.id, -1); }} disabled={state.quantity <= 1} className="text-stone-500 hover:text-white disabled:opacity-20"><Minus size={14} /></button>
                                <span className="font-heading text-sm font-bold text-gold w-4 text-center">{state.quantity}</span>
                                <button onClick={(e) => { e.stopPropagation(); updateQty(item.id, 1); }} disabled={state.quantity >= item.quantity} className="text-stone-500 hover:text-white disabled:opacity-20"><Plus size={14} /></button>
                            </div>
                          </div>

                          <div className="space-y-4">
                              <label className="text-[9px] font-bold uppercase tracking-widest text-stone-700">{t("item_reason_label")}</label>
                              <input type="text" value={state.reason} onChange={(e) => updateReason(item.id, e.target.value)} className="w-full h-12 rounded-xl border border-white/5 bg-zinc-800/50 px-6 text-xs text-foreground outline-none focus:border-gold/30 transition-colors" placeholder={t("item_reason_placeholder")} />
                          </div>

                          <div className="space-y-4">
                              <div className="flex justify-between items-end">
                                  <label className="text-[9px] font-bold uppercase tracking-widest text-stone-700">{t("images_label")}</label>
                                  <span className={cn("text-[9px] font-bold tracking-widest uppercase", state.images.length >= MIN_IMAGES ? "text-emerald-500" : "text-amber-500")}>
                                      {state.images.length}/{MAX_IMAGES} (Min {MIN_IMAGES})
                                  </span>
                              </div>
                              <div className="flex flex-wrap gap-4">
                                  {state.images.map((url, idx) => (
                                      <div key={idx} className="group relative h-20 w-20 overflow-hidden rounded-xl border border-white/5">
                                          <Image src={url} alt="Evidence" fill className="object-cover" />
                                          <button onClick={() => removeImage(item.id, idx)} className="absolute inset-0 bg-red-500/80 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                              <Trash2 size={16} className="text-white" />
                                          </button>
                                      </div>
                                  ))}
                                  {state.images.length < MAX_IMAGES && (
                                      <button onClick={() => imageInputRefs.current[item.id]?.click()} disabled={state.uploadingImages} className="h-20 w-20 flex flex-col items-center justify-center gap-1 rounded-xl border border-dashed border-stone-800 hover:border-gold/30 transition-all text-stone-600 hover:text-gold">
                                          {state.uploadingImages ? <Loader2 size={16} className="animate-spin" /> : <><ImageIcon size={16} /><span className="text-[8px] font-bold uppercase">Add</span></>}
                                      </button>
                                  )}
                              </div>
                              <input ref={(el) => { imageInputRefs.current[item.id] = el; }} type="file" accept="image/*" multiple className="hidden" onChange={(e) => handleImageUpload(item.id, e.target.files)} />
                          </div>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Global Reason Selection */}
          <div className="space-y-8">
              <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-700">{t("reason_selection_title")}</p>
              <div className="grid gap-6 md:grid-cols-2">
                  <div className="space-y-4">
                      <p className="text-[9px] font-bold uppercase tracking-widest text-emerald-500 flex items-center gap-2">
                          <CheckCircle size={14} /> {t("store_fault_title")}
                      </p>
                      <div className="space-y-2">
                          {["[DAMAGED]", "[WRONG_ITEM]", "[EXPIRED]"].map((key) => (
                              <button key={key} onClick={() => { setSelectedReasonType("STORE"); setReason(key); }} className={cn("w-full h-12 flex items-center gap-4 px-6 rounded-xl border text-[10px] font-bold uppercase tracking-widest transition-all", selectedReasonType === "STORE" && reason === key ? "bg-emerald-500 text-black border-emerald-500 shadow-lg shadow-emerald-500/20" : "bg-white/5 text-stone-400 border-white/5 hover:border-emerald-500/30")}>
                                  <div className={cn("h-2 w-2 rounded-full", selectedReasonType === "STORE" && reason === key ? "bg-black" : "bg-emerald-500")} />
                                  {t(`reasons.${key.slice(1, -1).toLowerCase()}` as any)}
                              </button>
                          ))}
                      </div>
                  </div>
                  <div className="space-y-4">
                      <p className="text-[9px] font-bold uppercase tracking-widest text-amber-500 flex items-center gap-2">
                          <AlertCircle size={14} /> {t("customer_fault_title")}
                      </p>
                      <div className="space-y-2">
                          {["[SCENT_MISMATCH]", "[COLOR_MISMATCH]", "[QUALITY_ISSUE]", "[PERSONAL_CHANGE]"].map((key) => (
                              <button key={key} onClick={() => { setSelectedReasonType("CUSTOMER"); setReason(key); }} className={cn("w-full h-12 flex items-center gap-4 px-6 rounded-xl border text-[10px] font-bold uppercase tracking-widest transition-all", selectedReasonType === "CUSTOMER" && reason === key ? "bg-amber-500 text-black border-amber-500 shadow-lg shadow-amber-500/20" : "bg-white/5 text-stone-400 border-white/5 hover:border-amber-500/30")}>
                                  <div className={cn("h-2 w-2 rounded-full", selectedReasonType === "CUSTOMER" && reason === key ? "bg-black" : "bg-amber-500")} />
                                  {t(`reasons.${key.slice(1, -1).toLowerCase()}` as any)}
                              </button>
                          ))}
                      </div>
                  </div>
              </div>
          </div>

          {/* Refund Coordinates */}
          <div className="space-y-6 pt-10 border-t border-white/5">
              <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-700">Financial Registry (Bank Details)</p>
              <div className="grid gap-6 sm:grid-cols-2">
                  <div className="space-y-2">
                      <label className="text-[9px] font-bold uppercase tracking-widest text-stone-700">Bank Agency</label>
                      <input type="text" value={bankName} onChange={(e) => setBankName(e.target.value)} className="w-full h-12 rounded-xl border border-white/5 bg-zinc-800/50 px-6 text-xs text-foreground outline-none focus:border-gold/30 transition-colors" placeholder="e.g., Vietcombank" />
                  </div>
                  <div className="space-y-2">
                      <label className="text-[9px] font-bold uppercase tracking-widest text-stone-700">Account Number</label>
                      <input type="text" value={bankAccount} onChange={(e) => setBankAccount(e.target.value)} className="w-full h-12 rounded-xl border border-white/5 bg-zinc-800/50 px-6 font-mono text-xs text-foreground outline-none focus:border-gold/30 transition-colors" placeholder="0001000..." />
                  </div>
                  <div className="space-y-2 sm:col-span-2">
                      <label className="text-[9px] font-bold uppercase tracking-widest text-stone-700">Account Holder</label>
                      <input type="text" value={bankHolder} onChange={(e) => setBankHolder(e.target.value)} className="w-full h-12 rounded-xl border border-white/5 bg-zinc-800/50 px-6 text-xs font-bold uppercase tracking-widest text-foreground outline-none focus:border-gold/30 transition-colors" placeholder="FULL NAME" />
                  </div>
              </div>
          </div>
        </div>

        {/* Footer Manifest */}
        <div className="p-10 border-t border-white/5 bg-black/40 flex items-center justify-between gap-8">
            <div className="hidden sm:block">
                <p className="text-[10px] font-bold uppercase tracking-widest text-stone-500">Items Registered</p>
                <p className="font-heading text-xl font-bold text-foreground">{items.filter(i => itemStates[i.id].selected).length} Selected</p>
            </div>
            <button onClick={handleSubmit} disabled={submitting} className="flex-1 sm:flex-none flex h-16 items-center justify-center gap-4 rounded-2xl bg-gold px-12 text-[10px] font-black uppercase tracking-widest text-black shadow-2xl shadow-gold/20 transition-all hover:scale-[1.02] disabled:opacity-50">
                {submitting ? <Loader2 size={18} className="animate-spin" /> : <Zap size={18} />}
                {submitting ? "Processing Registry..." : "Initialize Reversion"}
            </button>
        </div>
      </motion.div>
    </div>
  );
}
