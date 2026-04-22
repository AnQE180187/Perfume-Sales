import { useState, useEffect, useRef } from 'react';
import { Bot, Send, Sparkles, User as UserIcon } from 'lucide-react';
import axiosClient from '@/services/axiosClient';
import { useNavigate } from 'react-router-dom';
import { formatPrice } from '@/utils/format';

export default function AiChatPage() {
  const [messages, setMessages] = useState<any[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(true);
  const [isTyping, setIsTyping] = useState(false);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const navigate = useNavigate();
  const scrollRef = useRef<HTMLDivElement>(null);

  // Auto scroll to bottom
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
      // 1. Lấy danh sách conversation
      const res: any = await axiosClient.get('/chat/conversations');
      let items: any[] = [];
      if (Array.isArray(res)) {
         items = res;
      } else if (res && Array.isArray(res.items)) {
         items = res.items;
      } else if (res && Array.isArray(res.data)) {
         items = res.data;
      }
      
      // Filter type CUSTOMER_AI
      let conv = items.find((c: any) => c.type === 'CUSTOMER_AI');
      
      // Nếu chưa có thì tạo mới
      if (!conv) {
        const createRes = await axiosClient.post('/chat/conversations', { type: 'CUSTOMER_AI' });
        conv = createRes.data || createRes;
      }
      
      setConversationId(conv.id);

      // Load tin nhắn cũ
      const msgsRes: any = await axiosClient.get(`/chat/messages?conversationId=${conv.id}`);
      let oldMsgs: any[] = [];
      if (Array.isArray(msgsRes)) {
         oldMsgs = msgsRes;
      } else if (msgsRes && Array.isArray(msgsRes.items)) {
         oldMsgs = msgsRes.items;
      } else if (msgsRes && Array.isArray(msgsRes.data)) {
         oldMsgs = msgsRes.data;
      }
      
      // Filter out null/undefined elements just to be safe
      const validMsgs = oldMsgs.filter(m => m && typeof m === 'object');
      setMessages(validMsgs.reverse());
    } catch (err) {
      // Fallback
      setMessages([{ id: 'init', senderType: 'AI', content: { text: 'Chào bạn! Mình là AI Consultant của hệ thống. Bạn đang muốn tìm sản phẩm nào?' } }]);
    } finally {
      setLoading(false);
    }
  };

  const handleSend = async () => {
    if (!input.trim() || !conversationId) return;
    const text = input;
    setInput('');
    
    // Optimistic UI for user message
    const tempId = Date.now().toString();
    setMessages(prev => [...prev, { id: tempId, senderType: 'USER', content: { text } }]);
    setIsTyping(true);

    try {
      const response = await axiosClient.post('/chat/messages', {
        conversationId,
        type: 'TEXT',
        content: { text }
      });
      // BE trả về { message: UserMsg, aiMessage: AIMsg }
      const data = response.data || response;
      if (data.aiMessage) {
        setMessages(prev => {
          const list = [...prev];
          const lastIndex = list.findIndex(m => m.id === tempId);
          if (lastIndex !== -1 && data.message) list[lastIndex] = data.message;
          return [...list, data.aiMessage];
        });
      }
    } catch (err) {
      setMessages(prev => [...prev, { id: Date.now().toString(), senderType: 'AI', content: { text: 'Hệ thống đang bận, xin vui lòng thử lại sau.' } }]);
    } finally {
      setIsTyping(false);
    }
  };

  const renderContent = (msg: any) => {
    const text = msg.content?.text || '';
    const recs = msg.type === 'AI_RECOMMENDATION' ? (msg.content?.recommendations || []) : [];
    return (
      <div>
        {text && <p className="text-[13px] leading-relaxed whitespace-pre-wrap">{text}</p>}
        {recs.length > 0 && (
          <div className="mt-3 flex flex-nowrap overflow-x-auto gap-2 pb-2">
            {recs.map((rec: any, idx: number) => (
              <div onClick={() => navigate(`/product/${rec.productId}`)} key={idx} className="w-40 flex-shrink-0 bg-white rounded-lg p-2 shadow-sm border mt-1">
                 <div className="aspect-square rounded-md overflow-hidden bg-gray-100 mb-2">
                   {rec.imageUrl && <img src={rec.imageUrl} className="w-full h-full object-cover" />}
                 </div>
                 <div className="text-[10px] text-primary truncate font-bold">{rec.brand}</div>
                 <div className="text-xs font-semibold text-gray-800 line-clamp-1">{rec.name}</div>
                 <div className="text-xs font-bold mt-1">{rec.price ? formatPrice(rec.price) : '0đ'}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="flex flex-col h-full bg-[#f4f5f7]">
      <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 py-6 space-y-5">
        <div className="flex justify-center mb-6">
          <div className="bg-white text-primary px-4 py-1.5 rounded-full text-xs font-semibold flex items-center gap-1.5 shadow-sm">
            <Sparkles size={14} /> Trợ lý nước hoa tự động AI
          </div>
        </div>

        {loading && <div className="text-center text-xs text-gray-400">Đang đồng bộ chat...</div>}

        {messages.map(msg => {
          const isUser = msg.senderType === 'USER';
          return (
            <div key={msg.id} className={`flex gap-2.5 items-end ${isUser ? 'flex-row-reverse' : 'flex-row'}`}>
              {!isUser && (
                <div className="w-7 h-7 rounded-full bg-primary flex items-center justify-center shadow-sm">
                  <Bot size={14} className="text-white" />
                </div>
              )}
              <div className={`p-3 rounded-2xl max-w-[85%] relative shadow-sm ${isUser ? 'bg-primary text-white rounded-br-sm' : 'bg-white text-gray-800 rounded-bl-sm border border-gray-100'}`}>
                {renderContent(msg)}
              </div>
            </div>
          );
        })}
        {isTyping && (
          <div className="flex gap-2.5 items-end">
            <div className="w-7 h-7 rounded-full bg-primary flex items-center justify-center shadow-sm">
              <Bot size={14} className="text-white" />
            </div>
            <div className="p-3 bg-white border border-gray-100 rounded-2xl rounded-bl-sm shadow-sm flex gap-1">
               <span className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce"></span>
               <span className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: "0.2s"}}></span>
               <span className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: "0.4s"}}></span>
            </div>
          </div>
        )}
      </div>

      <div className="p-3 bg-white border-t border-gray-100 flex items-center gap-3">
        <div className="flex-1 bg-gray-100 rounded-xl flex items-center px-4 py-1">
          <input 
            type="text"
            className="flex-1 bg-transparent py-2 text-[14px] outline-none"
            placeholder="Hỏi AI về mùi hương..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            disabled={loading || isTyping}
          />
        </div>
        <button 
          onClick={handleSend}
          disabled={loading || isTyping || !input.trim()}
          className="bg-primary disabled:opacity-50 text-white w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 active:scale-95 transition-transform shadow-sm"
        >
          <Send size={18} className="translate-x-[1px]" />
        </button>
      </div>
    </div>
  );
}
