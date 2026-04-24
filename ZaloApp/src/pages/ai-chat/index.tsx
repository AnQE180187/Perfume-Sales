import { useState, useEffect, useRef } from 'react';
import { Sparkles, Send, ArrowLeft } from 'lucide-react';
import axiosClient from '@/services/axiosClient';
import { useNavigate } from 'react-router-dom';
import { formatPrice } from '@/utils/format';

const SUGGESTED_PROMPTS = [
  "Tôi muốn tìm nước hoa cho buổi đi làm",
  "Gợi ý nước hoa nam mùi gỗ ấm",
  "Nước hoa nữ hương hoa nhẹ nhàng dưới 2 triệu",
  "Nước hoa lưu hương lâu cho buổi tối",
];

export default function AiChatPage() {
  const [messages, setMessages] = useState<any[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(true);
  const [isTyping, setIsTyping] = useState(false);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const navigate = useNavigate();
  const scrollRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTo({ top: scrollRef.current.scrollHeight, behavior: 'smooth' });
    }
  }, [messages, isTyping]);

  useEffect(() => {
    initChat();
  }, []);

  const initChat = async () => {
    try {
      const res: any = await axiosClient.get('/chat/conversations');
      let items: any[] = [];
      if (Array.isArray(res)) items = res;
      else if (res?.items) items = res.items;
      else if (res?.data) items = res.data;

      let conv = items.find((c: any) => c.type === 'CUSTOMER_AI');
      if (!conv) {
        const createRes: any = await axiosClient.post('/chat/conversations', { type: 'CUSTOMER_AI' });
        conv = createRes.data || createRes;
      }
      setConversationId(conv.id);

      const msgsRes: any = await axiosClient.get(`/chat/messages?conversationId=${conv.id}`);
      let oldMsgs: any[] = [];
      if (Array.isArray(msgsRes)) oldMsgs = msgsRes;
      else if (msgsRes?.items) oldMsgs = msgsRes.items;
      else if (msgsRes?.data) oldMsgs = msgsRes.data;

      const validMsgs = oldMsgs.filter(m => m && typeof m === 'object');
      setMessages(validMsgs.reverse());
    } catch {
      setMessages([{
        id: 'init',
        senderType: 'AI',
        content: { text: 'Chào bạn! Tôi là AI Consultant của PerfumeGPT 🌸\n\nTôi có thể giúp bạn tìm ra mùi hương hoàn hảo. Hãy cho tôi biết bạn đang tìm kiếm gì?' }
      }]);
    } finally {
      setLoading(false);
    }
  };

  const handleSend = async (text?: string) => {
    const msg = text || input;
    if (!msg.trim() || !conversationId) return;
    setInput('');

    const tempId = Date.now().toString();
    setMessages(prev => [...prev, { id: tempId, senderType: 'USER', content: { text: msg } }]);
    setIsTyping(true);

    try {
      const response: any = await axiosClient.post('/chat/messages', {
        conversationId,
        type: 'TEXT',
        content: { text: msg }
      });
      const data = response.data || response;
      if (data.aiMessage) {
        setMessages(prev => {
          const list = [...prev];
          const idx = list.findIndex(m => m.id === tempId);
          if (idx !== -1 && data.message) list[idx] = data.message;
          return [...list, data.aiMessage];
        });
      }
    } catch {
      setMessages(prev => [...prev, {
        id: Date.now().toString(),
        senderType: 'AI',
        content: { text: 'Hệ thống đang bận, xin vui lòng thử lại sau.' }
      }]);
    } finally {
      setIsTyping(false);
    }
  };

  const renderContent = (msg: any) => {
    const text = msg.content?.text || '';
    const recs = msg.type === 'AI_RECOMMENDATION' ? (msg.content?.recommendations || []) : [];
    return (
      <div>
        {text && (
          <p className="text-sm leading-relaxed whitespace-pre-wrap">{text}</p>
        )}
        {recs.length > 0 && (
          <div className="mt-3">
            <div className="text-2xs font-bold uppercase tracking-wider mb-2 opacity-60">
              Gợi ý cho bạn
            </div>
            <div className="flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth: 'none' }}>
              {recs.map((rec: any, idx: number) => (
                <div
                  key={idx}
                  onClick={() => navigate(`/product/${rec.productId}`)}
                  className="w-36 flex-shrink-0 rounded-2xl overflow-hidden cursor-pointer active:scale-95 transition-transform"
                  style={{ background: '#FAF8F5', border: '1px solid rgba(212,175,55,0.2)' }}
                >
                  <div className="aspect-square bg-skeleton overflow-hidden">
                    {rec.imageUrl && (
                      <img src={rec.imageUrl} className="w-full h-full object-cover" alt={rec.name} />
                    )}
                  </div>
                  <div className="p-2">
                    {rec.brand && (
                      <div className="text-2xs font-bold tracking-wider text-gold uppercase truncate">
                        {rec.brand}
                      </div>
                    )}
                    <div className="text-xs font-semibold text-foreground line-clamp-2 leading-snug">
                      {rec.name}
                    </div>
                    {rec.price && (
                      <div className="text-xs font-bold text-primary mt-1">
                        {formatPrice(rec.price)}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    );
  };

  const isEmpty = !loading && messages.length === 0;

  return (
    <div className="flex flex-col h-full" style={{ background: '#FAF8F5' }}>
      {/* Chat area */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* AI identity badge */}
        <div className="flex justify-center">
          <div
            className="flex items-center gap-2 px-4 py-2 rounded-full text-xs font-semibold"
            style={{
              background: 'linear-gradient(135deg, #1a1a2e, #2d2d52)',
              color: '#E2D1B3',
              boxShadow: '0 2px 12px rgba(26,26,46,0.2)',
            }}
          >
            <Sparkles size={12} className="text-gold" />
            AI Perfume Consultant
          </div>
        </div>

        {loading && (
          <div className="flex gap-3 items-end">
            <div
              className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
              style={{ background: 'linear-gradient(135deg, #1a1a2e, #2d2d52)' }}
            >
              <Sparkles size={14} className="text-gold" />
            </div>
            <div className="flex gap-1.5 items-center p-3 rounded-2xl rounded-bl-sm"
              style={{ background: '#FFFFFF', border: '1px solid rgba(0,0,0,0.06)' }}>
              <span className="w-1.5 h-1.5 bg-inactive rounded-full animate-bounce" />
              <span className="w-1.5 h-1.5 bg-inactive rounded-full animate-bounce" style={{ animationDelay: '0.15s' }} />
              <span className="w-1.5 h-1.5 bg-inactive rounded-full animate-bounce" style={{ animationDelay: '0.3s' }} />
            </div>
          </div>
        )}

        {/* Suggested prompts when empty */}
        {isEmpty && (
          <div className="space-y-3">
            <p className="text-center text-xs text-subtitle">Thử hỏi tôi:</p>
            {SUGGESTED_PROMPTS.map((prompt, i) => (
              <button
                key={i}
                onClick={() => handleSend(prompt)}
                className="w-full text-left p-3 rounded-2xl text-sm text-foreground font-medium active:scale-[0.98] transition-transform"
                style={{
                  background: '#FFFFFF',
                  border: '1px solid rgba(212,175,55,0.2)',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.04)',
                }}
              >
                <span className="text-gold mr-2">✦</span>
                {prompt}
              </button>
            ))}
          </div>
        )}

        {/* Messages */}
        {messages.map(msg => {
          const isUser = msg.senderType === 'USER';
          return (
            <div key={msg.id} className={`flex gap-2.5 items-end ${isUser ? 'flex-row-reverse' : 'flex-row'}`}>
              {!isUser && (
                <div
                  className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
                  style={{ background: 'linear-gradient(135deg, #1a1a2e, #2d2d52)' }}
                >
                  <Sparkles size={14} className="text-gold" />
                </div>
              )}
              <div
                className={`p-3.5 rounded-2xl max-w-[85%] relative ${
                  isUser ? 'rounded-br-sm' : 'rounded-bl-sm'
                }`}
                style={isUser ? {
                  background: 'linear-gradient(135deg, #1a1a2e, #2d2d52)',
                  color: '#FAF8F5',
                  boxShadow: '0 2px 12px rgba(26,26,46,0.25)',
                } : {
                  background: '#FFFFFF',
                  color: '#0D0D0D',
                  border: '1px solid rgba(0,0,0,0.06)',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
                }}
              >
                {renderContent(msg)}
              </div>
            </div>
          );
        })}

        {/* Typing indicator */}
        {isTyping && (
          <div className="flex gap-2.5 items-end">
            <div
              className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
              style={{ background: 'linear-gradient(135deg, #1a1a2e, #2d2d52)' }}
            >
              <Sparkles size={14} className="text-gold" />
            </div>
            <div className="flex gap-1.5 items-center p-3.5 rounded-2xl rounded-bl-sm"
              style={{ background: '#FFFFFF', border: '1px solid rgba(0,0,0,0.06)' }}>
              <span className="w-2 h-2 bg-gold rounded-full animate-bounce" />
              <span className="w-2 h-2 bg-gold rounded-full animate-bounce" style={{ animationDelay: '0.15s' }} />
              <span className="w-2 h-2 bg-gold rounded-full animate-bounce" style={{ animationDelay: '0.3s' }} />
            </div>
          </div>
        )}
      </div>

      {/* Input area */}
      <div
        className="flex-none px-4 py-3 flex items-center gap-2"
        style={{
          background: '#FFFFFF',
          borderTop: '1px solid rgba(0,0,0,0.06)',
          paddingBottom: 'max(12px, env(safe-area-inset-bottom))',
        }}
      >
        <div
          className="flex-1 flex items-center rounded-2xl px-4"
          style={{
            background: '#FAF8F5',
            border: '1px solid rgba(212,175,55,0.2)',
            minHeight: '44px',
          }}
        >
          <input
            ref={inputRef}
            type="text"
            className="flex-1 bg-transparent py-2.5 text-sm outline-none"
            placeholder="Hỏi AI về mùi hương..."
            style={{ color: '#0D0D0D' }}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            disabled={loading || isTyping}
          />
        </div>
        <button
          onClick={() => handleSend()}
          disabled={loading || isTyping || !input.trim()}
          className="w-11 h-11 rounded-2xl flex items-center justify-center flex-shrink-0 active:scale-90 transition-transform disabled:opacity-40"
          style={{
            background: 'linear-gradient(135deg, #E2D1B3, #D4AF37)',
            boxShadow: '0 2px 12px rgba(212,175,55,0.3)',
          }}
        >
          <Send size={18} className="text-primary translate-x-0.5" />
        </button>
      </div>
    </div>
  );
}
