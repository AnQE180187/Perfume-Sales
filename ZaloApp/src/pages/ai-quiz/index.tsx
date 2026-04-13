import { useState } from 'react';
import { ArrowLeft, ArrowRight, Sparkles } from 'lucide-react';
import TransitionLink from '@/components/transition-link';

export default function AiQuizPage() {
  const [step, setStep] = useState(1);
  
  return (
    <div className="h-full bg-white flex flex-col items-center justify-center p-6 text-center">
      <div className="bg-primary/10 w-20 h-20 rounded-full flex items-center justify-center text-primary mb-6">
        <Sparkles size={40} />
      </div>
      <h1 className="text-2xl font-bold mb-2">Tìm ra mùi hương chân ái</h1>
      <p className="text-gray-500 mb-8 text-sm leading-relaxed">
        Chỉ mất 1 phút để trả lời 5 câu hỏi đơn giản. PerfumeGPT sẽ sử dụng trí tuệ nhân tạo để gợi ý những lọ nước hoa phù hợp nhất với phong cách và hoàn cảnh sử dụng của bạn.
      </p>
      
      <button 
        className="w-full bg-primary text-white py-3.5 rounded-xl font-medium text-lg active:scale-95 transition-transform shadow-lg shadow-primary/30"
        onClick={() => alert("Tính năng Quiz đang được liên kết với Backend")}
      >
        Bắt đầu trắc nghiệm
      </button>

      <TransitionLink to="/" className="mt-6 text-gray-400 font-medium text-sm flex items-center gap-1">
        <ArrowLeft size={16} /> Quay lại trang chủ
      </TransitionLink>
    </div>
  );
}
