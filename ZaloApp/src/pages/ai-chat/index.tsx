import { useState } from 'react';
import { Bot, Send, Sparkles, User as UserIcon } from 'lucide-react';

export default function AiChatPage() {
  const [messages, setMessages] = useState([
    { id: 1, sender: 'AI', text: 'Chào bạn! Mình là trợ lý AI từ PerfumeGPT. Bạn đang tìm kiếm một mùi hương như thế nào?' }
  ]);
  const [input, setInput] = useState('');

  const handleSend = () => {
    if (!input.trim()) return;
    
    // Add User Message
    const newMessages = [...messages, { id: Date.now(), sender: 'USER', text: input }];
    setMessages(newMessages);
    setInput('');

    // Simulate AI response
    setTimeout(() => {
      setMessages(prev => [...prev, { 
        id: Date.now() + 1, 
        sender: 'AI', 
        text: 'Cảm ơn bạn. Dựa trên sở thích này, mình khuyên bạn nên làm thử bài trắc nghiệm nhé, hoặc tham khảo dòng nước hoa hương hoa nhài ngọt ngào hiện có tại cửa hàng.' 
      }]);
    }, 1000);
  };

  return (
    <div className="flex flex-col h-full bg-slate-50">
      {/* Header handled by Layout usually, but we have internal scroll */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="flex justify-center mb-6">
          <div className="bg-primary/10 text-primary px-4 py-2 rounded-full text-xs font-semibold flex items-center gap-2">
            <Sparkles size={16} /> PerfumeGPT Trợ Lý Hảo Hạng
          </div>
        </div>

        {messages.map(msg => (
          <div key={msg.id} className={`flex gap-3 ${msg.sender === 'USER' ? 'flex-row-reverse' : 'flex-row'}`}>
            <div className={`w-8 h-8 rounded-full flex-shrink-0 flex items-center justify-center ${msg.sender === 'USER' ? 'bg-blue-500 text-white' : 'bg-primary text-white'}`}>
              {msg.sender === 'USER' ? <UserIcon size={16} /> : <Bot size={16} />}
            </div>
            <div className={`p-3 rounded-2xl max-w-[75%] ${msg.sender === 'USER' ? 'bg-white shadow-sm text-gray-800' : 'bg-primary text-white'}`}>
              <p className="text-sm">{msg.text}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="p-4 bg-white border-t border-gray-100 flex items-center gap-2">
        <input 
          type="text"
          className="flex-1 bg-gray-100 rounded-full px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-primary/20"
          placeholder="Hỏi AI về mùi hương..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleSend()}
        />
        <button 
          onClick={handleSend}
          className="bg-primary text-white w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 active:scale-95 transition-transform"
        >
          <Send size={18} />
        </button>
      </div>
    </div>
  );
}
