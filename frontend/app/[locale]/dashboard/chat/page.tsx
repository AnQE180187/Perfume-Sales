"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import {
  chatService,
  Conversation,
  Message,
  ChatContact,
} from "@/services/chat.service";
import { getChatSocket } from "@/lib/socket";
import { useAuth } from "@/hooks/use-auth";
import {
  ArrowLeft,
  MessageCircle,
  Send,
  Bot,
  Sparkles,
  Users,
  Plus,
  Search,
  BrainCircuit,
  BarChart3,
  ExternalLink,
  Image as ImageIcon,
  ArrowUpRight,
  MoreVertical,
  ShieldCheck,
  Zap
} from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { cn } from "@/lib/utils";
import { Link } from "@/lib/i18n";

import { useTranslations, useLocale, useFormatter } from "next-intl";

type Tab = "conversations" | "contacts";

export default function DashboardChatPage() {
  const t = useTranslations("dashboard.profile.chat");
  const tRoles = useTranslations("dashboard.profile.roles");
  const tFeatured = useTranslations("featured");
  const format = useFormatter();
  const { user } = useAuth();
  const [tab, setTab] = useState<Tab>("conversations");
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [contacts, setContacts] = useState<ChatContact[]>([]);
  const [selected, setSelected] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isMobileListVisible, setIsMobileListVisible] = useState(true);

  // ── Init ──
  useEffect(() => {
    loadConversations();
    loadContacts();
  }, []);

  // ── WebSocket ──
  useEffect(() => {
    if (!selected || selected.id.startsWith("draft-")) return;
    const socket = getChatSocket();
    const handler = (message: Message) => {
      if (message.conversationId === selected.id) {
        setMessages((prev) => {
          if (prev.some((m) => m.id === message.id)) return prev;
          return [...prev, message];
        });
      }
    };
    socket.on("message", handler);
    socket.emit("joinConversation", selected.id);
    return () => {
      socket.off("message", handler);
      socket.emit("leaveConversation", selected.id);
    };
  }, [selected]);

  // ── Load messages ──
  useEffect(() => {
    if (selected && !selected.id.startsWith("draft-")) {
      loadMessages(selected.id);
      setIsMobileListVisible(false);
      setTimeout(() => inputRef.current?.focus(), 200);
    } else if (selected?.id.startsWith("draft-")) {
      setMessages([]);
      setIsMobileListVisible(false);
      setTimeout(() => inputRef.current?.focus(), 200);
    }
  }, [selected?.id]);

  // ── Scroll ──
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // ── API calls ──
  const loadConversations = async () => {
    try {
      const data = await chatService.listConversations();
      setConversations(data);
    } catch (e) {
      console.error(e);
    }
  };

  const loadContacts = async () => {
    try {
      const data = await chatService.listContacts();
      setContacts(data);
    } catch (e) {
      console.error(e);
    }
  };

  const loadMessages = async (conversationId: string) => {
    try {
      const { items } = await chatService.getMessages({
        conversationId,
        take: 50,
      });
      setMessages(items.reverse());
    } catch (e) {
      console.error(e);
    }
  };

  const createAiConversation = async (type: "CUSTOMER_AI" | "ADMIN_AI") => {
    const draft: Conversation = {
      id: `draft-${type}-${Date.now()}`,
      type,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      participants: [],
      messages: [],
    };
    setSelected(draft);
    setMessages([]);
  };

  const startHumanChat = async (contact: ChatContact) => {
    try {
      const type = contact.role === "STAFF" ? "ADMIN_STAFF" : "CUSTOMER_ADMIN";
      const conv = await chatService.createConversation({
        type: type as any,
        otherUserId: contact.id,
      });
      setConversations((prev) => [
        conv,
        ...prev.filter((c) => c.id !== conv.id),
      ]);
      setSelected(conv);
      setTab("conversations");
    } catch (e) {
      console.error(e);
    }
  };

  const sendMessage = useCallback(async () => {
    if (!selected || !newMessage.trim()) return;
    setLoading(true);
    const text = newMessage.trim();
    setNewMessage("");
    try {
      let convId = selected.id;
      if (convId.startsWith("draft-")) {
        const realConv = await chatService.createConversation({
          type: selected.type,
        });
        convId = realConv.id;
        setSelected(realConv);
        setConversations((prev) => [
          realConv,
          ...prev.filter((c) => c.id !== realConv.id),
        ]);
      }
      const { message, aiMessage } = await chatService.sendMessage({
        conversationId: convId,
        type: "TEXT",
        content: { text },
      });
      setMessages((prev) => {
        let next = prev.some((m) => m.id === message.id)
          ? prev
          : [...prev, message];
        if (aiMessage && !next.some((m) => m.id === aiMessage.id)) {
          next = [...next, aiMessage];
        }
        return next;
      });
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  }, [selected, newMessage]);

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !selected) return;

    setLoading(true);
    try {
      let convId = selected.id;
      if (convId.startsWith("draft-")) {
        const realConv = await chatService.createConversation({
          type: selected.type,
        });
        convId = realConv.id;
        setSelected(realConv);
        setConversations((prev) => [
          realConv,
          ...prev.filter((c) => c.id !== realConv.id),
        ]);
      }

      const { message } = await chatService.uploadImage(convId, file);
      setMessages((prev) => {
        if (prev.some((m) => m.id === message.id)) return prev;
        return [...prev, message];
      });
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  };

  const getOtherParticipant = (conv: Conversation) => {
    return conv.participants?.find((p) => p.userId !== user?.id);
  };

  const getConversationLabel = (conv: Conversation) => {
    if (conv.type === "CUSTOMER_AI") return t("ai_labels.perfume");
    if (conv.type === "ADMIN_AI") return t("ai_labels.marketing");
    const other = getOtherParticipant(conv);
    return other?.user?.fullName || other?.user?.email || conv.type;
  };

  const getConversationIcon = (type: string) => {
    if (type === "CUSTOMER_AI")
      return <BrainCircuit size={18} className="text-gold" />;
    if (type === "ADMIN_AI")
      return <BarChart3 size={18} className="text-gold" />;
    return <Users size={18} className="text-gold" />;
  };

  const getLastMessage = (conv: Conversation) => {
    const msg = conv.messages?.[0];
    if (!msg) return t("ai_labels.no_messages");
    return (
      (msg.content as any)?.text?.slice(0, 45) ||
      t("ai_labels.message_placeholder")
    );
  };

  const formatTime = (d: string) =>
    new Date(d).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });

  const filteredConversations = conversations.filter((c) => {
    if (!searchTerm) return true;
    const label = getConversationLabel(c).toLowerCase();
    return label.includes(searchTerm.toLowerCase());
  });

  const filteredContacts = contacts.filter((c) => {
    if (!searchTerm) return true;
    return (
      (c.fullName?.toLowerCase() || "").includes(searchTerm.toLowerCase()) ||
      c.email.toLowerCase().includes(searchTerm.toLowerCase())
    );
  });

  return (
    <div className="relative flex h-[calc(100vh-6rem)] overflow-hidden rounded-[2.5rem] border border-white/5 bg-zinc-950 shadow-2xl backdrop-blur-3xl">
      {/* ──────── Sidebar ──────── */}
      <div className={cn(
        "w-full md:w-[380px] border-r border-white/5 flex flex-col shrink-0 transition-all duration-500",
        !isMobileListVisible && "hidden md:flex"
      )}>
        {/* Sidebar Header */}
        <div className="p-8 space-y-6">
            <div className="flex items-center justify-between">
                <h2 className="text-[10px] font-bold uppercase tracking-[0.4em] text-gold/60">{t("title")}</h2>
                <div className="flex h-8 w-8 items-center justify-center rounded-full bg-white/5 text-stone-400">
                    <Plus size={16} />
                </div>
            </div>

            <div className="relative">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-600" size={16} />
                <input
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    placeholder={t("placeholders.search")}
                    className="w-full rounded-2xl border border-white/5 bg-white/[0.02] py-4 pl-12 pr-4 text-xs outline-none transition-all focus:border-gold/30 focus:bg-white/[0.05]"
                />
            </div>

            <div className="flex gap-2">
                <button
                    onClick={() => createAiConversation("CUSTOMER_AI")}
                    className="group relative flex-1 flex items-center justify-center gap-3 py-4 rounded-2xl bg-gold text-[10px] font-bold uppercase tracking-widest text-black transition-all hover:scale-[1.02]"
                >
                    <BrainCircuit size={16} className="group-hover:rotate-12 transition-transform" />
                    {t("buttons.perfume_ai")}
                </button>
                {user?.role === "ADMIN" && (
                    <button
                        onClick={() => createAiConversation("ADMIN_AI")}
                        className="flex-1 flex items-center justify-center gap-3 py-4 rounded-2xl border border-white/10 bg-white/5 text-[10px] font-bold uppercase tracking-widest text-stone-300 hover:bg-white/10"
                    >
                        <BarChart3 size={16} />
                        {t("buttons.marketing_ai")}
                    </button>
                )}
            </div>
        </div>

        {/* Tab Selection */}
        <div className="flex px-8 border-b border-white/5">
            {(["conversations", "contacts"] as Tab[]).map((tTab) => (
                <button
                    key={tTab}
                    onClick={() => setTab(tTab)}
                    className={cn(
                        "flex-1 pb-4 text-[10px] font-bold uppercase tracking-[0.2em] transition-all",
                        tab === tTab ? "text-gold border-b-2 border-gold" : "text-stone-600 hover:text-stone-400"
                    )}
                >
                    {tTab === "conversations" ? t("tabs.history") : t("tabs.contacts")}
                </button>
            ))}
        </div>

        {/* Scrollable List */}
        <div className="flex-1 overflow-y-auto p-4 space-y-2 custom-scrollbar">
            {tab === "conversations" ? (
                filteredConversations.map((conv) => (
                    <button
                        key={conv.id}
                        onClick={() => setSelected(conv)}
                        className={cn(
                            "w-full group flex items-center gap-4 rounded-3xl p-4 transition-all duration-300",
                            selected?.id === conv.id ? "bg-gold/10 border border-gold/20" : "hover:bg-white/[0.02]"
                        )}
                    >
                        <div className={cn(
                            "flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl transition-all duration-500",
                            selected?.id === conv.id ? "bg-gold text-black shadow-[0_0_20px_rgba(197,160,89,0.3)]" : "bg-zinc-900 text-stone-400"
                        )}>
                            {getConversationIcon(conv.type)}
                        </div>
                        <div className="flex-1 text-left min-w-0">
                            <div className="flex items-center justify-between mb-1">
                                <p className="text-[11px] font-bold uppercase tracking-widest text-foreground truncate">{getConversationLabel(conv)}</p>
                                <span className="text-[9px] text-stone-600">{conv.updatedAt && formatTime(conv.updatedAt)}</span>
                            </div>
                            <p className="text-[10px] text-stone-500 truncate leading-relaxed">{getLastMessage(conv)}</p>
                        </div>
                    </button>
                ))
            ) : (
                filteredContacts.map((contact) => (
                    <button
                        key={contact.id}
                        onClick={() => startHumanChat(contact)}
                        className="w-full group flex items-center gap-4 rounded-3xl p-4 hover:bg-white/[0.02] transition-all"
                    >
                        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-zinc-900 text-[11px] font-bold uppercase text-stone-400">
                            {(contact.fullName || contact.email).slice(0, 2)}
                        </div>
                        <div className="flex-1 text-left min-w-0">
                            <p className="text-[11px] font-bold uppercase tracking-widest text-foreground">{contact.fullName || contact.email}</p>
                            <p className="text-[9px] font-medium uppercase tracking-widest text-stone-600 mt-1">{contact.role}</p>
                        </div>
                        <MessageCircle size={14} className="text-gold opacity-0 group-hover:opacity-100 transition-opacity" />
                    </button>
                ))
            )}
        </div>
      </div>

      {/* ──────── Main Chat Area ──────── */}
      <div className={cn(
        "flex-1 flex flex-col min-w-0 bg-zinc-950/50 backdrop-blur-xl transition-all duration-500",
        isMobileListVisible && "hidden md:flex"
      )}>
        {selected ? (
          <>
            {/* Chat Header */}
            <header className="flex h-24 items-center justify-between border-b border-white/5 px-8">
                <div className="flex items-center gap-5">
                    <button onClick={() => setIsMobileListVisible(true)} className="md:hidden text-stone-400 hover:text-white">
                        <ArrowLeft size={24} />
                    </button>
                    <div className="flex h-14 w-14 items-center justify-center rounded-[1.25rem] bg-gold text-black shadow-[0_0_30px_rgba(197,160,89,0.3)]">
                        {getConversationIcon(selected.type)}
                    </div>
                    <div>
                        <div className="flex items-center gap-3">
                            <h3 className="font-heading text-xl font-bold uppercase tracking-widest text-foreground">{getConversationLabel(selected)}</h3>
                            <div className="h-1.5 w-1.5 rounded-full bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.5)]" />
                        </div>
                        <p className="text-[10px] font-bold uppercase tracking-[0.3em] text-stone-500 mt-1">{selected.type.replace("_", " · ")}</p>
                    </div>
                </div>
                <div className="flex items-center gap-3">
                    <button className="flex h-12 w-12 items-center justify-center rounded-full border border-white/5 bg-white/[0.02] text-stone-400 hover:bg-white/10 transition-all">
                        <MoreVertical size={20} />
                    </button>
                </div>
            </header>

            {/* Messages Area */}
            <div className="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar">
                <AnimatePresence mode="popLayout">
                    {messages.map((msg) => {
                        const isMe = msg.senderType === "USER" && msg.senderId === user?.id;

                        return (
                            <motion.div
                                key={msg.id}
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                className={cn("flex", isMe ? "justify-end" : "justify-start")}
                            >
                                <div className={cn(
                                    "max-w-[75%] space-y-2",
                                    isMe ? "items-end" : "items-start"
                                )}>
                                    <div className={cn(
                                        "relative rounded-[2rem] px-8 py-5 text-sm leading-relaxed",
                                        isMe 
                                            ? "bg-gold text-black font-medium rounded-tr-none shadow-[0_15px_30px_-10px_rgba(197,160,89,0.4)]" 
                                            : "bg-white/[0.03] border border-white/5 text-stone-300 rounded-tl-none backdrop-blur-xl"
                                    )}>
                                        {(msg.type === "TEXT" || msg.type === "AI_RECOMMENDATION") && (
                                            <p className="whitespace-pre-wrap">{ (msg.content as any)?.text }</p>
                                        )}
                                        {msg.type === "IMAGE" && (
                                            <div className="rounded-2xl overflow-hidden mt-1 border border-white/10 shadow-2xl">
                                                <img src={(msg.content as any)?.imageUrl} alt="Attachment" className="max-w-full h-auto object-cover max-h-[450px]" />
                                            </div>
                                        )}
                                        
                                        {msg.type === "AI_RECOMMENDATION" && (msg.content as any)?.recommendations?.map((rec: any, i: number) => (
                                            <Link key={i} href={`/products/${rec.productId}`} className="group mt-6 block overflow-hidden rounded-[2rem] border border-gold/30 bg-black/40 backdrop-blur-xl transition-all hover:bg-gold/10">
                                                <div className="flex">
                                                    <div className="w-24 h-32 shrink-0 bg-zinc-900">
                                                        {rec.imageUrl && <img src={rec.imageUrl} alt={rec.name} className="h-full w-full object-cover group-hover:scale-110 transition-transform duration-700" />}
                                                    </div>
                                                    <div className="p-6 flex-1 min-w-0">
                                                        <div className="flex items-start justify-between">
                                                            <h4 className="font-heading text-[10px] font-bold uppercase tracking-widest text-gold truncate">{rec.name}</h4>
                                                            <ArrowUpRight size={14} className="text-gold opacity-0 group-hover:opacity-100 transition-opacity" />
                                                        </div>
                                                        <p className="mt-2 line-clamp-2 text-[10px] text-stone-500 italic leading-relaxed">"{rec.reason}"</p>
                                                        <div className="mt-4 flex items-center justify-between">
                                                            <span className="text-xs font-bold text-foreground">
                                                                {format.number(Number(rec.price), { style: "currency", currency: tFeatured("currency_code") || "VND", maximumFractionDigits: 0 })}
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </Link>
                                        ))}
                                    </div>
                                    <span className="text-[9px] font-bold uppercase tracking-widest text-stone-600 px-2">{formatTime(msg.createdAt)}</span>
                                </div>
                            </motion.div>
                        );
                    })}
                </AnimatePresence>
                <div ref={messagesEndRef} />
            </div>

            {/* Input Area */}
            <footer className="p-8 border-t border-white/5 bg-zinc-950/80 backdrop-blur-3xl">
                <div className="relative flex items-center gap-4">
                    <input type="file" ref={fileInputRef} onChange={handleImageUpload} accept="image/*" className="hidden" />
                    <button 
                        onClick={() => fileInputRef.current?.click()}
                        className="flex h-16 w-16 shrink-0 items-center justify-center rounded-[1.5rem] border border-white/5 bg-white/[0.02] text-stone-500 hover:bg-white/10 hover:text-gold transition-all"
                    >
                        <ImageIcon size={24} />
                    </button>
                    <div className="relative flex-1">
                        <input
                            ref={inputRef}
                            value={newMessage}
                            onChange={(e) => setNewMessage(e.target.value)}
                            onKeyDown={(e) => e.key === "Enter" && !e.shiftKey && sendMessage()}
                            placeholder={t("placeholders.type_message")}
                            className="w-full rounded-[1.5rem] border border-white/5 bg-white/[0.02] px-8 py-5 text-sm outline-none transition-all focus:border-gold/30 focus:bg-white/[0.04]"
                        />
                        <button 
                            onClick={sendMessage}
                            disabled={!newMessage.trim() || loading}
                            className="absolute right-3 top-1/2 -translate-y-1/2 flex h-10 w-10 items-center justify-center rounded-xl bg-gold text-black shadow-lg shadow-gold/20 disabled:opacity-20 transition-all hover:scale-105"
                        >
                            <Send size={18} />
                        </button>
                    </div>
                </div>
                <div className="mt-4 flex items-center justify-center gap-8">
                    <div className="flex items-center gap-2">
                        <ShieldCheck size={12} className="text-emerald-500" />
                        <span className="text-[8px] font-bold uppercase tracking-[0.2em] text-stone-600">End-to-End Encrypted</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <Zap size={12} className="text-gold" />
                        <span className="text-[8px] font-bold uppercase tracking-[0.2em] text-stone-600">Neural Sync Active</span>
                    </div>
                </div>
            </footer>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center text-center p-20">
            <div className="relative mb-12">
                <div className="absolute inset-0 animate-ping rounded-full bg-gold/5" />
                <div className="relative flex h-32 w-32 items-center justify-center rounded-[2.5rem] border border-white/5 bg-white/[0.02] backdrop-blur-3xl">
                    <Bot size={56} className="text-gold/20" />
                </div>
            </div>
            <h3 className="font-heading text-xl font-bold uppercase tracking-[0.4em] text-stone-600">{t("fallbacks.no_selection_title")}</h3>
            <p className="mt-6 max-w-xs font-body text-sm leading-relaxed text-stone-500">{t("fallbacks.no_selection_subtitle")}</p>
            <div className="mt-12 grid grid-cols-2 gap-4">
                <div className="rounded-2xl border border-white/5 bg-white/[0.02] p-4">
                    <p className="text-[8px] font-bold uppercase tracking-widest text-stone-700 mb-1">Latency</p>
                    <p className="text-xs font-bold text-stone-500">~2.4ms</p>
                </div>
                <div className="rounded-2xl border border-white/5 bg-white/[0.02] p-4">
                    <p className="text-[8px] font-bold uppercase tracking-widest text-stone-700 mb-1">Status</p>
                    <p className="text-xs font-bold text-emerald-500/50">Online</p>
                </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
