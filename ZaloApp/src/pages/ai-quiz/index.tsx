import { useState } from 'react';
import { ArrowLeft, Sparkles, RefreshCw } from 'lucide-react';
import TransitionLink from '@/components/transition-link';
import axiosClient from '@/services/axiosClient';
import { useNavigate } from 'react-router-dom';
import { formatPrice } from '@/utils/format';

const QUESTIONS = [
  { id: 'gender', title: 'Bạn đang tìm nước hoa cho ai?', options: [{ label: 'Cho Nam', value: 'MALE' }, { label: 'Cho Nữ', value: 'FEMALE' }, { label: 'Unisex', value: 'UNISEX' }] },
  { id: 'occasion', title: 'Mục đích sử dụng chính?', options: [{ label: 'Cho bản thân làm việc', value: 'Office' }, { label: 'Đi hẹn hò', value: 'Dating' }, { label: 'Dự sự kiện / Tiệc tùng', value: 'Party' }, { label: 'Dùng hằng ngày', value: 'Daily' }] },
  { id: 'budget', title: 'Ngân sách của bạn khoảng bao nhiêu?', options: [{ label: 'Dưới 1 triệu', value: '500000' }, { label: '1 - 2.5 triệu', value: '2500000' }, { label: '2.5 - 5 triệu', value: '5000000' }, { label: 'Thoải mái', value: '10000000' }] },
  { id: 'family', title: 'Bạn thích phong cách hương nào?', options: [{ label: 'Hương gỗ (Woody)', value: 'Woody' }, { label: 'Hương hoa cỏ (Floral)', value: 'Floral' }, { label: 'Tươi mát (Citrus)', value: 'Citrus' }, { label: 'Ngọt ngào (Gourmand)', value: 'Sweet' }] },
  { id: 'longevity', title: 'Bạn mong muốn độ lưu hương ra sao?', options: [{ label: 'Thoang thoảng (3-6h)', value: 'Moderate' }, { label: 'Lưu lâu (6-8h)', value: 'Long Lasting' }, { label: 'Bám tỏa tốt (>8h)', value: 'Eternal' }] }
];

export default function AiQuizPage() {
  const [step, setStep] = useState(0); // 0 means Intro, 1-5 mean Questions, 6 means results
  const [answers, setAnswers] = useState<Record<string, any>>({});
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<any[]>([]);
  const navigate = useNavigate();

  const handleSelect = async (questionId: string, value: string) => {
    const newAnswers = { ...answers, [questionId]: value };
    setAnswers(newAnswers);

    if (step < QUESTIONS.length) {
      setTimeout(() => setStep(step + 1), 300); // 1 to 2..5
    } else {
      // Finished all 5 questions, Submit to backend
      setStep(step + 1);
      setLoading(true);
      try {
        const payload = {
          gender: newAnswers.gender,
          occasion: newAnswers.occasion,
          budgetMax: Number(newAnswers.budget),
          preferredFamily: newAnswers.family,
          longevity: newAnswers.longevity
        };
        const res = await axiosClient.post('/quiz/submit', { answers: payload });
        setResults(res.data?.recommendations || []);
      } catch (err) {
        console.error("AI Quiz Error", err);
      } finally {
        setLoading(false);
      }
    }
  };

  const renderIntro = () => (
    <div className="flex flex-col items-center justify-center p-6 text-center h-full">
      <div className="bg-primary/10 w-20 h-20 rounded-full flex items-center justify-center text-primary mb-6">
        <Sparkles size={40} />
      </div>
      <h1 className="text-2xl font-bold mb-2">Tìm ra mùi hương chân ái</h1>
      <p className="text-gray-500 mb-8 text-sm leading-relaxed">
        Chỉ mất 1 phút để trả lời 5 câu hỏi lướt nhanh. Hệ thống AI của PerfumeGPT sẽ tính toán và đưa ra lọ nước hoa tương thích 99% với phong cách của bạn.
      </p>
      <button
        className="w-full bg-primary text-white py-3.5 rounded-xl font-medium text-lg active:scale-95 transition-transform shadow-lg shadow-primary/30"
        onClick={() => setStep(1)}
      >
        Bắt đầu ngay
      </button>
      <TransitionLink to="/" className="mt-6 text-gray-400 font-medium text-sm flex items-center gap-1">
        <ArrowLeft size={16} /> Bỏ qua
      </TransitionLink>
    </div>
  );

  const renderQuestion = () => {
    const qIndex = step - 1;
    const q = QUESTIONS[qIndex];
    return (
      <div className="flex flex-col h-full bg-white px-6 py-8">
        <div className="flex gap-1 mb-8">
          {QUESTIONS.map((_, idx) => (
            <div key={idx} className={`h-1.5 flex-1 rounded-full ${idx <= qIndex ? 'bg-primary' : 'bg-gray-100'}`} />
          ))}
        </div>
        <div className="text-sm text-primary font-semibold mb-2">Câu hỏi {step}/5</div>
        <h2 className="text-2xl font-bold text-gray-800 mb-8 leading-tight">{q.title}</h2>
        <div className="flex flex-col gap-3">
          {q.options.map(opt => {
            const isSelected = answers[q.id] === opt.value;
            return (
              <div
                key={opt.value}
                onClick={() => handleSelect(q.id, opt.value)}
                className={`w-full p-4 rounded-xl border-2 text-left font-medium transition-all duration-200 active:scale-95 flex items-center justify-between ${isSelected ? 'border-primary bg-primary/5 text-primary' : 'border-gray-100 bg-white text-gray-700'
                  }`}
              >
                {opt.label}
                {isSelected && <Sparkles size={16} />}
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  const renderResults = () => (
    <div className="bg-gray-50 min-h-full px-4 py-8">
      <div className="text-center mb-8">
        <Sparkles className="text-primary mx-auto mb-3" size={32} />
        <h1 className="text-xl font-bold text-gray-800">Kết quả phân tích AI</h1>
        <p className="text-sm text-gray-500 mt-2">Dựa trên DNA mùi hương của bạn, đây là những ứng viên sáng giá nhất.</p>
      </div>
      {loading ? (
        <div className="flex flex-col items-center justify-center p-10 opacity-70">
          <RefreshCw className="animate-spin text-primary mb-4" size={30} />
          <p className="text-sm text-gray-500 font-semibold animate-pulse">Trí tuệ nhân tạo đang phân tích...</p>
        </div>
      ) : (
        <div className="space-y-4">
          {results.map((rec, i) => (
            <div onClick={() => rec.productId && navigate(`/product/${rec.productId}`)} key={i} className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 flex gap-4 active:scale-[0.98] transition-transform">
              <div className="w-24 h-24 rounded-xl bg-gray-100 overflow-hidden flex-shrink-0">
                {rec.imageUrl ? <img src={rec.imageUrl} className="w-full h-full object-cover" /> : <div className="w-full h-full bg-gray-200" />}
              </div>
              <div className="flex-1 min-w-0 flex flex-col justify-center">
                <div className="text-xs text-primary font-bold tracking-widest mb-1">{rec.brand || 'PERFUMEGPT'}</div>
                <h3 className="font-semibold text-gray-800 text-sm truncate">{rec.name}</h3>
                <p className="text-xs text-gray-500 my-1 line-clamp-2 leading-relaxed bg-primary/5 rounded p-1.5">{rec.reason}</p>
                <div className="font-bold text-sm mt-1">{rec.price ? formatPrice(rec.price) : 'Xem chi tiết'}</div>
              </div>
            </div>
          ))}
          <button onClick={() => { setStep(0); setAnswers({}); }} className="w-full mt-6 py-3 border border-primary text-primary rounded-xl font-semibold opacity-80 hover:opacity-100">
            Làm lại bài kiểm tra
          </button>
        </div>
      )}
    </div>
  );

  if (step === 0) return renderIntro();
  if (step <= 5) return renderQuestion();
  return renderResults();
}
