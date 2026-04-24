import { useState } from 'react';
import { Sparkles, RefreshCw, ChevronRight, Check } from 'lucide-react';
import TransitionLink from '@/components/transition-link';
import axiosClient from '@/services/axiosClient';
import { useNavigate } from 'react-router-dom';
import { formatPrice } from '@/utils/format';

const QUESTIONS = [
  {
    id: 'gender',
    emoji: '👤',
    title: 'Bạn đang tìm nước hoa cho ai?',
    subtitle: 'Chúng tôi sẽ lọc hương phù hợp nhất',
    options: [
      { label: 'Cho Nam', value: 'MALE', emoji: '🎩' },
      { label: 'Cho Nữ', value: 'FEMALE', emoji: '🌸' },
      { label: 'Unisex', value: 'UNISEX', emoji: '✨' },
    ],
  },
  {
    id: 'occasion',
    emoji: '🎯',
    title: 'Mục đích sử dụng chính?',
    subtitle: 'Mỗi dịp có một mùi hương riêng',
    options: [
      { label: 'Đi làm hằng ngày', value: 'Office', emoji: '💼' },
      { label: 'Đi hẹn hò', value: 'Dating', emoji: '💕' },
      { label: 'Sự kiện / Tiệc', value: 'Party', emoji: '🥂' },
      { label: 'Dùng hằng ngày', value: 'Daily', emoji: '🌞' },
    ],
  },
  {
    id: 'budget',
    emoji: '💰',
    title: 'Ngân sách của bạn?',
    subtitle: 'Chúng tôi tôn trọng mọi budget',
    options: [
      { label: 'Dưới 1 triệu', value: '1000000', emoji: '💚' },
      { label: '1 – 2.5 triệu', value: '2500000', emoji: '💛' },
      { label: '2.5 – 5 triệu', value: '5000000', emoji: '🧡' },
      { label: 'Thoải mái', value: '10000000', emoji: '💎' },
    ],
  },
  {
    id: 'family',
    emoji: '🌿',
    title: 'Phong cách hương bạn thích?',
    subtitle: 'Cảm nhận mùi hương qua từng từ ngữ',
    options: [
      { label: 'Hương gỗ ấm (Woody)', value: 'Woody', emoji: '🌲' },
      { label: 'Hương hoa cỏ (Floral)', value: 'Floral', emoji: '🌺' },
      { label: 'Tươi mát (Citrus)', value: 'Citrus', emoji: '🍋' },
      { label: 'Ngọt ngào (Sweet)', value: 'Sweet', emoji: '🍯' },
    ],
  },
  {
    id: 'longevity',
    emoji: '⏳',
    title: 'Mong muốn độ lưu hương?',
    subtitle: 'Để chọn nồng độ phù hợp',
    options: [
      { label: 'Nhẹ nhàng (3–5h)', value: 'Moderate', emoji: '🌬️' },
      { label: 'Lâu hơn (6–8h)', value: 'Long Lasting', emoji: '🕐' },
      { label: 'Rất lâu (>8h)', value: 'Eternal', emoji: '🔥' },
    ],
  },
];

export default function AiQuizPage() {
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState<Record<string, any>>({});
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<any[]>([]);
  const navigate = useNavigate();

  const handleSelect = async (questionId: string, value: string) => {
    const newAnswers = { ...answers, [questionId]: value };
    setAnswers(newAnswers);

    if (step < QUESTIONS.length) {
      setTimeout(() => setStep(step + 1), 350);
    } else {
      setStep(step + 1);
      setLoading(true);
      try {
        const payload = {
          gender: newAnswers.gender,
          occasion: newAnswers.occasion,
          budgetMax: Number(newAnswers.budget),
          preferredFamily: newAnswers.family,
          longevity: newAnswers.longevity,
        };
        const res: any = await axiosClient.post('/quiz/submit', { answers: payload });
        setResults(res?.recommendations || res?.data?.recommendations || []);
      } catch {
        // empty results
      } finally {
        setLoading(false);
      }
    }
  };

  // INTRO
  if (step === 0) {
    return (
      <div
        className="flex flex-col min-h-full"
        style={{ background: '#FAF8F5' }}
      >
        {/* Hero top */}
        <div
          className="relative px-6 pt-12 pb-16 text-center"
          style={{ background: 'linear-gradient(160deg, #1a1a2e 0%, #2d2d52 100%)' }}
        >
          <div
            className="absolute top-[-30px] right-[-30px] w-40 h-40 rounded-full opacity-30"
            style={{ background: 'radial-gradient(circle, rgba(212,175,55,0.5) 0%, transparent 70%)' }}
          />
          <div
            className="w-20 h-20 rounded-3xl mx-auto mb-5 flex items-center justify-center animate-float"
            style={{
              background: 'linear-gradient(135deg, rgba(212,175,55,0.2), rgba(212,175,55,0.05))',
              border: '2px solid rgba(212,175,55,0.4)',
              boxShadow: '0 0 30px rgba(212,175,55,0.25)',
            }}
          >
            <Sparkles size={36} className="text-gold" />
          </div>
          <h1
            className="text-2xl font-bold text-white mb-2"
            style={{ fontFamily: "'Playfair Display', serif" }}
          >
            Scent DNA Quiz
          </h1>
          <p className="text-sm text-white/60 leading-relaxed">
            5 câu hỏi để AI phân tích "DNA mùi hương" của bạn và đưa ra Top 3 gợi ý hoàn hảo.
          </p>
        </div>

        {/* Content */}
        <div className="flex-1 px-5 pt-6 pb-8">
          {/* Steps preview */}
          <div className="mb-6 space-y-3">
            {QUESTIONS.map((q, i) => (
              <div key={i} className="flex items-center gap-3">
                <div
                  className="w-8 h-8 rounded-xl flex items-center justify-center text-sm flex-shrink-0"
                  style={{ background: '#F0ECE6', border: '1px solid rgba(212,175,55,0.2)' }}
                >
                  {q.emoji}
                </div>
                <span className="text-sm text-subtitle">{q.title}</span>
              </div>
            ))}
          </div>

          <button
            className="w-full py-4 rounded-2xl font-bold text-sm uppercase tracking-wider active:scale-95 transition-transform"
            style={{
              background: 'linear-gradient(135deg, #E2D1B3, #D4AF37)',
              color: '#1a1a2e',
              boxShadow: '0 4px 20px rgba(212,175,55,0.35)',
            }}
            onClick={() => setStep(1)}
          >
            Bắt đầu phân tích ✨
          </button>

          <TransitionLink to="/" className="mt-4 block text-center text-sm text-subtitle">
            {() => <>Bỏ qua, xem sản phẩm</>}
          </TransitionLink>
        </div>
      </div>
    );
  }

  // QUESTIONS
  if (step <= QUESTIONS.length) {
    const qIndex = step - 1;
    const q = QUESTIONS[qIndex];
    const progress = (step / QUESTIONS.length) * 100;

    return (
      <div className="flex flex-col min-h-full" style={{ background: '#FAF8F5' }}>
        {/* Progress bar */}
        <div className="h-1 bg-skeleton">
          <div
            className="h-full transition-all duration-500"
            style={{
              width: `${progress}%`,
              background: 'linear-gradient(135deg, #E2D1B3, #D4AF37)',
            }}
          />
        </div>

        <div className="flex-1 flex flex-col px-5 pt-6 pb-8">
          {/* Step indicator */}
          <div className="flex items-center gap-3 mb-5">
            <div
              className="w-10 h-10 rounded-2xl flex items-center justify-center text-xl"
              style={{ background: '#F0ECE6' }}
            >
              {q.emoji}
            </div>
            <div>
              <div className="text-2xs text-gold font-bold tracking-widest uppercase">
                Câu {step}/{QUESTIONS.length}
              </div>
              <div className="text-2xs text-subtitle">{q.subtitle}</div>
            </div>
          </div>

          <h2
            className="text-xl font-bold text-foreground mb-6 leading-snug"
            style={{ fontFamily: "'Playfair Display', serif" }}
          >
            {q.title}
          </h2>

          <div className="flex flex-col gap-3">
            {q.options.map(opt => {
              const isSelected = answers[q.id] === opt.value;
              return (
                <button
                  key={opt.value}
                  onClick={() => handleSelect(q.id, opt.value)}
                  className="w-full p-4 rounded-2xl text-left font-medium transition-all duration-200 active:scale-[0.98] flex items-center gap-3"
                  style={isSelected ? {
                    background: 'linear-gradient(135deg, #1a1a2e, #2d2d52)',
                    color: '#FAF8F5',
                    border: '1.5px solid rgba(212,175,55,0.4)',
                    boxShadow: '0 4px 16px rgba(26,26,46,0.2)',
                  } : {
                    background: '#FFFFFF',
                    color: '#0D0D0D',
                    border: '1.5px solid rgba(0,0,0,0.08)',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.04)',
                  }}
                >
                  <span className="text-xl">{opt.emoji}</span>
                  <span className="flex-1">{opt.label}</span>
                  {isSelected && <Check size={16} className="text-gold" />}
                </button>
              );
            })}
          </div>
        </div>
      </div>
    );
  }

  // RESULTS
  return (
    <div className="min-h-full" style={{ background: '#FAF8F5' }}>
      {/* Header */}
      <div
        className="px-5 pt-8 pb-10 text-center"
        style={{ background: 'linear-gradient(160deg, #1a1a2e 0%, #2d2d52 100%)' }}
      >
        <div className="text-4xl mb-3">🎉</div>
        <h1
          className="text-xl font-bold text-white mb-2"
          style={{ fontFamily: "'Playfair Display', serif" }}
        >
          DNA Mùi Hương Của Bạn
        </h1>
        <p className="text-sm text-white/60">
          Dựa trên phân tích AI, đây là Top gợi ý dành riêng cho bạn
        </p>
      </div>

      <div className="px-4 pt-4 pb-8 space-y-4">
        {loading ? (
          <div className="flex flex-col items-center justify-center py-16 gap-4">
            <div
              className="w-16 h-16 rounded-full flex items-center justify-center animate-pulse-slow"
              style={{
                background: 'linear-gradient(135deg, rgba(212,175,55,0.2), rgba(212,175,55,0.05))',
                border: '2px solid rgba(212,175,55,0.3)',
              }}
            >
              <Sparkles size={28} className="text-gold animate-spin" style={{ animationDuration: '2s' }} />
            </div>
            <p className="text-sm font-semibold text-subtitle animate-pulse">
              AI đang phân tích DNA mùi hương...
            </p>
          </div>
        ) : results.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-subtitle">Không tìm thấy kết quả phù hợp</p>
            <button
              onClick={() => { setStep(0); setAnswers({}); setResults([]); }}
              className="mt-4 px-6 py-2.5 rounded-2xl text-sm font-bold"
              style={{ background: '#F0ECE6', color: '#1a1a2e' }}
            >
              Làm lại
            </button>
          </div>
        ) : (
          <>
            {results.map((rec, i) => (
              <div
                key={i}
                onClick={() => rec.productId && navigate(`/product/${rec.productId}`)}
                className="rounded-3xl overflow-hidden cursor-pointer active:scale-[0.98] transition-transform"
                style={{
                  background: '#FFFFFF',
                  border: '1px solid rgba(212,175,55,0.15)',
                  boxShadow: '0 4px 20px rgba(0,0,0,0.08)',
                }}
              >
                {/* Rank badge */}
                <div className="flex gap-4 p-4">
                  <div className="relative flex-shrink-0">
                    <div className="w-24 h-24 rounded-2xl overflow-hidden bg-skeleton">
                      {rec.imageUrl ? (
                        <img src={rec.imageUrl} className="w-full h-full object-cover" alt={rec.name} />
                      ) : (
                        <div className="w-full h-full" style={{ background: '#F0ECE6' }} />
                      )}
                    </div>
                    <div
                      className="absolute -top-1.5 -left-1.5 w-6 h-6 rounded-full flex items-center justify-center text-xs font-black"
                      style={{
                        background: i === 0
                          ? 'linear-gradient(135deg, #E2D1B3, #D4AF37)'
                          : i === 1 ? '#E8E0D5' : '#F0ECE6',
                        color: '#1a1a2e',
                      }}
                    >
                      {i + 1}
                    </div>
                  </div>

                  <div className="flex-1 min-w-0">
                    {rec.brand && (
                      <div className="text-2xs font-bold tracking-wider text-gold uppercase mb-0.5">
                        {rec.brand}
                      </div>
                    )}
                    <h3 className="text-sm font-bold text-foreground leading-snug">{rec.name}</h3>
                    {rec.reason && (
                      <p className="text-xs text-subtitle leading-relaxed mt-1 line-clamp-3">
                        {rec.reason}
                      </p>
                    )}
                    {rec.price && (
                      <div className="text-sm font-bold text-primary mt-2">
                        {formatPrice(rec.price)}
                      </div>
                    )}
                  </div>

                  <ChevronRight size={16} className="text-gold flex-shrink-0 mt-1" />
                </div>
              </div>
            ))}

            <button
              onClick={() => { setStep(0); setAnswers({}); setResults([]); }}
              className="w-full py-3.5 rounded-2xl text-sm font-bold mt-2 active:scale-95 transition-transform"
              style={{
                background: '#F0ECE6',
                color: '#1a1a2e',
                border: '1.5px solid rgba(212,175,55,0.2)',
              }}
            >
              <RefreshCw size={14} className="inline mr-2" />
              Làm lại bài kiểm tra
            </button>
          </>
        )}
      </div>
    </div>
  );
}
