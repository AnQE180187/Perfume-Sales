'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { useAuth } from '@/hooks/use-auth';
import { chatService, type ChatContact, type Conversation, type Message } from '@/services/chat.service';
import { getChatSocket } from '@/lib/socket';
import { useEffect, useMemo, useRef, useState } from 'react';
import { BrainCircuit, MessageSquare, Search, Send, Sparkles, User, Users, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

type ChatTarget = {
  label: string;
  icon: React.ReactNode;
  conversation: Conversation;
  pinned?: boolean;
};

function cn(...classes: any[]) {
  return classes.filter(Boolean).join(' ');
}

function getTextFromContent(content: any): string {
  if (!content) return '';
  if (typeof content === 'string') return content;
  if (typeof content?.text === 'string') return content.text;
  return '';
}

function getConversationDisplayName(c: Conversation, meId: string | undefined, role: string): string {
  if (c.type === 'CUSTOMER_AI') return 'PerfumeGPT Consultant';
  if (c.type === 'ADMIN_AI') return 'AI Marketing Assistant';

  const others = (c.participants ?? []).filter((p) => p.userId && p.userId !== meId);
  const primary = others[0];
  const baseName = primary?.user?.fullName || primary?.user?.email;

  if (baseName) return baseName;

  if (c.type === 'CUSTOMER_ADMIN') {
    return role === 'CUSTOMER' ? 'Admin Support' : 'Customer';
  }
  if (c.type === 'ADMIN_STAFF') {
    return 'Staff';
  }
  return 'Conversation';
}

export default function ChatHubPage() {
  const { user } = useAuth();
  const role = user?.role ?? 'CUSTOMER';

  const [loading, setLoading] = useState(true);
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [activeId, setActiveId] = useState<string | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [error, setError] = useState<string | null>(null);

  const [showNewChat, setShowNewChat] = useState(false);
  const [contactSearch, setContactSearch] = useState('');
  const [contacts, setContacts] = useState<ChatContact[]>([]);
  const [contactsLoading, setContactsLoading] = useState(false);

  const bottomRef = useRef<HTMLDivElement | null>(null);

  const hasAi = role === 'CUSTOMER' || role === 'ADMIN';
  const aiType = role === 'ADMIN' ? 'ADMIN_AI' : 'CUSTOMER_AI';
  const canStartNewChat = role === 'ADMIN' || role === 'CUSTOMER' || role === 'STAFF';

  const targets: ChatTarget[] = useMemo(() => {
    const aiConv = hasAi ? conversations.find((c) => c.type === aiType) : undefined;
    const others = conversations.filter((c) => (hasAi ? c.id !== aiConv?.id : true));

    const aiTarget: ChatTarget[] =
      hasAi && aiConv
        ? [
            {
              label: getConversationDisplayName(aiConv, user?.id, role),
              icon: <Sparkles className="w-4 h-4 text-gold" />,
              conversation: aiConv,
              pinned: true,
            },
          ]
        : [];

    const otherTargets = others.map((c) => {
      const icon =
        c.type === 'CUSTOMER_ADMIN' ? <MessageSquare className="w-4 h-4 text-gold" /> : <Users className="w-4 h-4 text-gold" />;
      const label = getConversationDisplayName(c, user?.id, role);

      return { label, icon, conversation: c };
    });

    return [...aiTarget, ...otherTargets];
  }, [conversations, hasAi, aiType, role]);

  // Ensure AI conversation exists for admin/customer
  useEffect(() => {
    let cancelled = false;
    async function boot() {
      setLoading(true);
      setError(null);
      try {
        let list = await chatService.listConversations();
        if (!cancelled && hasAi && !list.find((c) => c.type === aiType)) {
          await chatService.createConversation({ type: aiType as any });
          list = await chatService.listConversations();
        }
        if (cancelled) return;
        setConversations(list);
        const preferred = hasAi ? list.find((c) => c.type === aiType) : list[0];
        setActiveId(preferred?.id ?? list[0]?.id ?? null);
      } catch (e: any) {
        setError(e?.message || 'Failed to load chat');
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    boot();
    return () => {
      cancelled = true;
    };
  }, [hasAi, aiType]);

  // Load contacts when opening New Chat modal
  useEffect(() => {
    if (!showNewChat) return;
    let cancelled = false;
    async function load() {
      setContactsLoading(true);
      try {
        const list = await chatService.listContacts({ search: contactSearch, take: 30 });
        if (!cancelled) setContacts(list);
      } catch (e: any) {
        if (!cancelled) setError(e?.message || 'Failed to load contacts');
      } finally {
        if (!cancelled) setContactsLoading(false);
      }
    }
    load();
    return () => {
      cancelled = true;
    };
  }, [showNewChat, contactSearch]);

  // Load messages + join room on active change
  useEffect(() => {
    if (!activeId) {
      setMessages([]);
      return;
    }

    const conversationId = activeId;

    let cancelled = false;
    async function load() {
      setError(null);
      try {
        const res = await chatService.getMessages({ conversationId, take: 50 });
        if (cancelled) return;
        // backend returns desc; UI wants asc
        setMessages([...res.items].reverse());
      } catch (e: any) {
        setError(e?.message || 'Failed to load messages');
      }
    }
    load();

    const socket = getChatSocket();
    socket.emit('joinConversation', { conversationId });

    return () => {
      cancelled = true;
    };
  }, [activeId]);

  // Realtime listener
  useEffect(() => {
    const socket = getChatSocket();
    const onReceived = (msg: Message) => {
      setMessages((prev) => {
        if (prev.some((m) => m.id === msg.id)) return prev;
        return [...prev, msg];
      });
      setConversations((prev) =>
        prev.map((c) => (c.id === msg.conversationId ? { ...c, updatedAt: new Date().toISOString(), messages: [msg] } : c)),
      );
    };
    socket.on('messageReceived', onReceived);
    return () => {
      socket.off('messageReceived', onReceived);
    };
  }, []);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages.length, activeId]);

  const active = useMemo(() => conversations.find((c) => c.id === activeId) ?? null, [conversations, activeId]);

  const send = async () => {
    if (!activeId || !input.trim()) return;
    const text = input.trim();
    setInput('');
    setError(null);

    const socket = getChatSocket();
    socket.emit('sendMessage', {
      conversationId: activeId,
      type: 'TEXT',
      content: { text },
    });
  };

  const startChatWith = async (contact: ChatContact) => {
    setError(null);
    try {
      const type =
        role === 'ADMIN'
          ? contact.role === 'STAFF'
            ? 'ADMIN_STAFF'
            : 'CUSTOMER_ADMIN'
          : 'CUSTOMER_ADMIN';

      const conv = await chatService.createConversation({
        type: type as any,
        otherUserId: contact.id,
      });

      // Refresh list to get lastMessage + participants (consistent display)
      const list = await chatService.listConversations();
      setConversations(list);
      setActiveId(conv.id);
      setShowNewChat(false);
      setContactSearch('');
      setContacts([]);
    } catch (e: any) {
      setError(e?.message || 'Failed to create conversation');
    }
  };

  return (
    <AuthGuard allowedRoles={['admin', 'staff', 'customer']}>
      <div className="h-[calc(100vh-80px)] px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-[380px_1fr] gap-6 h-full">
          {/* Left: conversation list */}
          <section className="glass rounded-[2.5rem] border border-border overflow-hidden flex flex-col">
            <div className="p-7 border-b border-border/60 flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-gold/10 border border-gold/20 flex items-center justify-center">
                <BrainCircuit className="w-5 h-5 text-gold" />
              </div>
              <div className="min-w-0">
                <h2 className="font-heading uppercase tracking-widest text-xs">Chat</h2>
                <p className="text-[10px] uppercase tracking-[0.2em] text-muted-foreground truncate">
                  {role === 'ADMIN' ? 'Admin inbox & AI marketing' : role === 'STAFF' ? 'Staff ↔ Admin' : 'Customer support & AI consultant'}
                </p>
              </div>
              <div className="ml-auto">
                {canStartNewChat && (
                  <button
                    onClick={() => setShowNewChat(true)}
                    className="px-4 py-2 rounded-2xl border border-border/60 hover:border-gold/30 hover:bg-secondary/20 transition-all text-[10px] uppercase tracking-widest font-heading"
                  >
                    New chat
                  </button>
                )}
              </div>
            </div>

            <div className="flex-1 overflow-y-auto custom-scrollbar p-3">
              {loading ? (
                <div className="p-6 text-xs text-muted-foreground">Loading...</div>
              ) : error ? (
                <div className="p-6 text-xs text-destructive">{error}</div>
              ) : targets.length === 0 ? (
                <div className="p-6 text-xs text-muted-foreground">Chưa có hội thoại nào.</div>
              ) : (
                <div className="space-y-2">
                  {targets.map((t) => {
                    const c = t.conversation;
                    const last = (c.messages && c.messages[0]) || null;
                    const lastText = last ? getTextFromContent(last.content) : '';
                    const isActive = c.id === activeId;

                    return (
                      <button
                        key={c.id}
                        onClick={() => setActiveId(c.id)}
                        className={cn(
                          'w-full text-left p-4 rounded-2xl border transition-all',
                          isActive ? 'border-gold/40 bg-gold/10' : 'border-border/40 hover:border-gold/25 hover:bg-secondary/20',
                        )}
                      >
                        <div className="flex items-center gap-3">
                          <div className={cn('w-9 h-9 rounded-2xl border flex items-center justify-center',
                            t.pinned ? 'bg-gold/10 border-gold/20' : 'bg-secondary/30 border-border'
                          )}>
                            {t.icon}
                          </div>
                          <div className="min-w-0 flex-1">
                            <div className="flex items-center justify-between gap-3">
                              <p className={cn('text-[10px] font-heading uppercase tracking-widest truncate', t.pinned ? 'text-gold' : 'text-foreground')}>
                                {t.label}
                              </p>
                              {t.pinned && (
                                <span className="text-[9px] uppercase tracking-[0.2em] text-gold border border-gold/20 bg-gold/5 px-2 py-1 rounded-full">
                                  AI
                                </span>
                              )}
                            </div>
                            <p className="text-[10px] text-muted-foreground truncate mt-1">
                              {lastText || 'No messages yet'}
                            </p>
                          </div>
                        </div>
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          </section>

          {/* Right: chat window */}
          <section className="glass rounded-[2.5rem] border border-border overflow-hidden flex flex-col min-h-0">
            <div className="p-7 border-b border-border/60 flex items-center justify-between">
              <div className="min-w-0">
                <p className="text-[10px] uppercase tracking-[0.25em] text-muted-foreground">Conversation</p>
                <h3 className="font-heading uppercase tracking-widest text-sm truncate">
                  {active ? getConversationDisplayName(active, user?.id, role) : '—'}
                </h3>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto custom-scrollbar p-8 space-y-6 min-h-0">
              <AnimatePresence initial={false}>
                {messages.map((m) => {
                  const isMe = m.senderType === 'USER' && m.senderId === user?.id;
                  const isAi = m.senderType === 'AI';
                  const text = getTextFromContent(m.content);
                  const recommendations = Array.isArray(m.content?.recommendations) ? m.content.recommendations : [];

                  return (
                    <motion.div
                      key={m.id}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className={cn('flex gap-4 max-w-3xl', isMe ? 'ml-auto flex-row-reverse' : '')}
                    >
                      <div
                        className={cn(
                          'w-10 h-10 rounded-2xl flex items-center justify-center shrink-0 border',
                          isAi ? 'bg-gold/10 border-gold/20' : 'bg-secondary/30 border-border',
                        )}
                      >
                        {isAi ? <Sparkles className="w-5 h-5 text-gold" /> : <User className="w-5 h-5" />}
                      </div>
                      <div
                        className={cn(
                          'p-6 rounded-3xl glass text-sm leading-relaxed border',
                          isMe ? 'bg-secondary/30 border-border' : isAi ? 'border-gold/20' : 'border-border',
                        )}
                      >
                        {text ? <p>{text}</p> : <p className="text-muted-foreground">Unsupported message</p>}

                        {m.type === 'AI_RECOMMENDATION' && recommendations.length > 0 && (
                          <div className="mt-4 grid gap-3">
                            {recommendations.slice(0, 5).map((r: any, idx: number) => (
                              <div key={idx} className="p-4 rounded-2xl border border-gold/20 bg-gold/5">
                                <p className="text-[10px] font-heading uppercase tracking-widest text-gold truncate">
                                  {r.name || r.productId}
                                </p>
                                <p className="text-xs text-muted-foreground mt-2">{r.reason}</p>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    </motion.div>
                  );
                })}
              </AnimatePresence>
              <div ref={bottomRef} />
            </div>

            <div className="p-6 border-t border-border/60 bg-background/40 backdrop-blur-xl">
              <div className="flex items-center gap-3">
                <input
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && send()}
                  placeholder={activeId ? 'Nhập tin nhắn...' : 'Chọn một hội thoại...'}
                  disabled={!activeId}
                  className="flex-1 bg-secondary/30 border border-border rounded-2xl px-5 py-4 text-sm outline-none focus:border-gold/40 disabled:opacity-60"
                />
                <button
                  onClick={send}
                  disabled={!activeId || !input.trim()}
                  className="w-12 h-12 rounded-2xl bg-gold text-primary flex items-center justify-center hover:scale-105 active:scale-95 transition-all disabled:opacity-50"
                >
                  <Send className="w-5 h-5" />
                </button>
              </div>
              <p className="text-[10px] uppercase tracking-[0.25em] text-muted-foreground mt-3">
                {role === 'STAFF'
                  ? 'Staff chỉ chat với Admin'
                  : role === 'ADMIN'
                    ? 'AI dành riêng cho Admin, chat realtime với Customer/Staff'
                    : 'AI dành riêng cho Customer, chat realtime với Admin'}
              </p>
            </div>
          </section>
        </div>
      </div>

      {/* New chat modal */}
      <AnimatePresence>
        {showNewChat && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[60] bg-black/60 backdrop-blur-sm flex items-center justify-center p-6"
          >
            <motion.div
              initial={{ opacity: 0, y: 10, scale: 0.98 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: 10, scale: 0.98 }}
              className="w-full max-w-2xl glass rounded-[2.5rem] border border-border overflow-hidden"
            >
              <div className="p-7 border-b border-border/60 flex items-center justify-between">
                <div>
                  <p className="text-[10px] uppercase tracking-[0.25em] text-muted-foreground">Start new conversation</p>
                  <h3 className="font-heading uppercase tracking-widest text-sm">
                    {role === 'ADMIN' ? 'Customer / Staff' : 'Admin'}
                  </h3>
                </div>
                <button
                  onClick={() => setShowNewChat(false)}
                  className="w-10 h-10 rounded-2xl border border-border/60 hover:border-gold/30 hover:bg-secondary/20 transition-all flex items-center justify-center"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="p-7">
                <div className="relative">
                  <Search className="absolute left-5 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <input
                    value={contactSearch}
                    onChange={(e) => setContactSearch(e.target.value)}
                    placeholder="Search by name, email, phone..."
                    className="w-full bg-secondary/30 border border-border rounded-2xl pl-12 pr-4 py-4 text-sm outline-none focus:border-gold/40"
                  />
                </div>

                <div className="mt-5 max-h-[420px] overflow-y-auto custom-scrollbar space-y-2">
                  {contactsLoading ? (
                    <div className="p-6 text-xs text-muted-foreground">Loading...</div>
                  ) : contacts.length === 0 ? (
                    <div className="p-6 text-xs text-muted-foreground">No contacts found.</div>
                  ) : (
                    contacts.map((c) => (
                      <button
                        key={c.id}
                        onClick={() => startChatWith(c)}
                        className="w-full text-left p-4 rounded-2xl border border-border/50 hover:border-gold/25 hover:bg-secondary/20 transition-all"
                      >
                        <div className="flex items-center gap-4">
                          <div className="w-10 h-10 rounded-2xl bg-secondary/30 border border-border flex items-center justify-center">
                            <User className="w-5 h-5 text-gold" />
                          </div>
                          <div className="min-w-0 flex-1">
                            <p className="text-[10px] font-heading uppercase tracking-widest truncate">
                              {c.fullName || c.email}
                            </p>
                            <p className="text-xs text-muted-foreground truncate mt-1">{c.email}</p>
                          </div>
                          <span className="text-[9px] uppercase tracking-[0.2em] px-3 py-1 rounded-full border border-border bg-secondary/20 text-muted-foreground">
                            {c.role}
                          </span>
                        </div>
                      </button>
                    ))
                  )}
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </AuthGuard>
  );
}

