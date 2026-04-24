import TransitionLink from "@/components/transition-link";
import { useAtomValue } from "jotai";
import { categoriesState } from "@/state";
import { unwrap } from "jotai/utils";
import { Grid3x3 } from "lucide-react";

const categoriesSync = unwrap(categoriesState, (prev) => prev ?? []);

// Emoji icons for common perfume categories
const CATEGORY_ICONS: Record<string, string> = {
  nam: "🎩",
  nữ: "🌸",
  nu: "🌸",
  "nước hoa nữ": "🌸",
  "nước hoa nam": "🎩",
  unisex: "✨",
  woody: "🌲",
  floral: "🌺",
  citrus: "🍋",
  oriental: "🕌",
  fresh: "💧",
  sweet: "🍬",
  default: "🌸",
};

function getCategoryIcon(name: string): string {
  const lower = name.toLowerCase();
  for (const [key, emoji] of Object.entries(CATEGORY_ICONS)) {
    if (lower.includes(key)) return emoji;
  }
  return CATEGORY_ICONS.default;
}

export default function Category() {
  const categories = useAtomValue(categoriesSync);

  if (!categories.length) {
    return (
      <div className="px-4 pt-4 pb-2">
        <div className="flex gap-3 overflow-x-auto pb-2">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="flex-none flex flex-col items-center gap-2">
              <div className="w-16 h-16 rounded-2xl bg-skeleton animate-pulse" />
              <div className="w-12 h-3 rounded bg-skeleton animate-pulse" />
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="px-4 pt-4 pb-2">
      {/* Section header */}
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <Grid3x3 size={14} className="text-gold" />
          <span className="text-sm font-bold text-foreground tracking-wide">Danh mục</span>
        </div>
        <TransitionLink
          to="/categories"
          className="text-2xs text-gold font-semibold tracking-wider uppercase"
        >
          {() => <>Xem tất cả</>}
        </TransitionLink>
      </div>

      {/* Category scroll */}
      <div className="flex gap-3 overflow-x-auto pb-2" style={{ scrollbarWidth: "none" }}>
        {categories.map((category) => (
          <TransitionLink
            key={category.id}
            className="flex-none flex flex-col items-center gap-1.5 cursor-pointer active:scale-90 transition-transform duration-150"
            to={`/category/${category.id}`}
          >
            {() => (
              <>
                <div
                  className="w-16 h-16 rounded-2xl flex items-center justify-center overflow-hidden"
                  style={{
                    background: "linear-gradient(135deg, #F5F1ED, #E8E0D5)",
                    border: "1px solid rgba(212,175,55,0.2)",
                  }}
                >
                  {category.image ? (
                    <img
                      src={category.image}
                      className="w-full h-full object-cover rounded-2xl"
                      alt={category.name}
                    />
                  ) : (
                    <span className="text-2xl">{getCategoryIcon(category.name)}</span>
                  )}
                </div>
                <div className="text-center text-2xs font-medium text-foreground w-16 line-clamp-2 leading-tight">
                  {category.name}
                </div>
              </>
            )}
          </TransitionLink>
        ))}
      </div>
    </div>
  );
}
