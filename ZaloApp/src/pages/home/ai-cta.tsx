import TransitionLink from "@/components/transition-link";
import { Sparkles } from "lucide-react";

export default function AiCta() {
  return (
    <div className="px-4 py-2 mt-2">
      <TransitionLink
        to="/ai-quiz"
        className="block bg-gradient-to-r from-primary/10 to-primary/5 rounded-2xl p-4 border border-primary/20 cursor-pointer active:scale-95 duration-150 relative overflow-hidden"
      >
        <div className="flex items-center gap-3">
          <div className="bg-primary/20 w-12 h-12 rounded-full flex justify-center items-center flex-shrink-0 text-primary z-10">
            <Sparkles size={24} />
          </div>
          <div className="z-10">
            <h3 className="font-bold text-base text-gray-800">Khám Phá Mùi Hương</h3>
            <p className="text-xs text-gray-500 mt-0.5">Trắc nghiệm nhanh 1 phút bằng AI</p>
          </div>
        </div>
        {/* Decorative elements */}
        <div className="absolute right-[-10px] bottom-[-20px] opacity-10">
          <Sparkles size={100} />
        </div>
      </TransitionLink>
    </div>
  );
}
