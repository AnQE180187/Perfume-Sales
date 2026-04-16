import TransitionLink from "@/components/transition-link";
import { Sparkles, MessageCircle } from "lucide-react";

export default function AiCta() {
  return (
    <div className="px-4 py-3 grid grid-cols-2 gap-3">
      {/* AI Chat Card */}
      <TransitionLink
        to="/ai-chat"
        className="relative block bg-gradient-to-br from-primary to-primary/80 rounded-2xl p-4 text-white overflow-hidden cursor-pointer active:scale-95 duration-150"
      >
        <MessageCircle size={28} className="mb-2" />
        <h3 className="font-bold text-sm leading-tight">Tư vấn AI</h3>
        <p className="text-[11px] opacity-80 mt-0.5">Chat với AI ngay</p>
        <div className="absolute right-[-12px] bottom-[-12px] opacity-20">
          <MessageCircle size={72} />
        </div>
      </TransitionLink>

      {/* AI Quiz Card */}
      <TransitionLink
        to="/ai-quiz"
        className="relative block bg-gradient-to-br from-gold/80 to-amber-500 rounded-2xl p-4 text-white overflow-hidden cursor-pointer active:scale-95 duration-150"
      >
        <Sparkles size={28} className="mb-2" />
        <h3 className="font-bold text-sm leading-tight">Tìm hương</h3>
        <p className="text-[11px] opacity-80 mt-0.5">Quiz 1 phút AI</p>
        <div className="absolute right-[-12px] bottom-[-12px] opacity-20">
          <Sparkles size={72} />
        </div>
      </TransitionLink>
    </div>
  );
}
