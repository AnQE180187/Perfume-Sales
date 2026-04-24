import ProductItem from "@/components/product-item";
import { useAtom, useAtomValue } from "jotai";
import { Suspense, useEffect, useRef, useState } from "react";
import { keywordState, recommendedProductsState, searchResultState } from "@/state";
import { Search, X, Sparkles } from "lucide-react";
import { unwrap } from "jotai/utils";

// Unwrap async search result for use outside Suspense
const searchResultSync = unwrap(searchResultState, (prev) => prev ?? []);
const recommendedSync = unwrap(recommendedProductsState, (prev) => prev ?? []);

function SearchResultList() {
  const searchResult = useAtomValue(searchResultSync);
  return (
    <div>
      {/* Results count */}
      <div className="px-4 py-3 flex items-center gap-2">
        <span className="text-sm font-bold text-foreground">Kết quả</span>
        <div
          className="px-2 py-0.5 rounded-full text-2xs font-bold"
          style={{ background: 'rgba(212,175,55,0.12)', color: '#D4AF37' }}
        >
          {searchResult.length}
        </div>
      </div>

      {searchResult.length > 0 ? (
        <div className="grid grid-cols-2 gap-3 px-4 pb-4">
          {searchResult.map((product) => (
            <ProductItem key={product.id} product={product} />
          ))}
        </div>
      ) : (
        <div className="flex flex-col items-center justify-center py-16 px-6 text-center">
          <div className="text-5xl mb-4">🔍</div>
          <div className="text-base font-bold text-foreground mb-2">Không tìm thấy sản phẩm</div>
          <p className="text-xs text-subtitle leading-relaxed">
            Hãy thử từ khoá khác hoặc để AI gợi ý mùi hương cho bạn
          </p>
        </div>
      )}
    </div>
  );
}

function RecommendedProducts() {
  const products = useAtomValue(recommendedSync);
  if (!products.length) return null;
  return (
    <div className="px-4">
      <div className="flex items-center gap-2 py-3">
        <Sparkles size={14} className="text-gold" />
        <span className="text-sm font-bold text-foreground">Có thể bạn quan tâm</span>
      </div>
      <div className="grid grid-cols-2 gap-3 pb-4">
        {products.slice(0, 6).map((product) => (
          <ProductItem key={product.id} product={product} />
        ))}
      </div>
    </div>
  );
}

function SearchResultSkeleton() {
  return (
    <div className="px-4 pt-2">
      <div className="grid grid-cols-2 gap-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i}>
            <div className="aspect-square rounded-2xl bg-skeleton animate-pulse" />
            <div className="mt-2 h-3 w-3/4 bg-skeleton rounded animate-pulse" />
            <div className="mt-1 h-3 w-1/2 bg-skeleton rounded animate-pulse" />
          </div>
        ))}
      </div>
    </div>
  );
}

// Popular search suggestions
const POPULAR_SEARCHES = [
  "Chanel No.5", "Dior Sauvage", "nước hoa nữ hương hoa",
  "nước hoa nam gỗ ấm", "tom ford", "unisex"
];

export default function SearchPage() {
  const inputRef = useRef<HTMLInputElement>(null);
  const [localKeyword, setLocalKeyword] = useState("");
  const [keyword, setKeyword] = useAtom(keywordState);

  useEffect(() => {
    if (inputRef.current) inputRef.current.focus();
    return () => setKeyword("");
  }, []);

  const handleSearch = (value: string) => {
    setLocalKeyword(value);
    setKeyword(value);
  };

  const clearSearch = () => {
    setLocalKeyword("");
    setKeyword("");
    if (inputRef.current) inputRef.current.focus();
  };

  return (
    <div className="min-h-full" style={{ background: '#FAF8F5' }}>
      {/* Search input */}
      <div className="px-4 pt-4 pb-3">
        <div
          className="flex items-center gap-3 rounded-2xl px-4"
          style={{
            background: '#FFFFFF',
            border: '1px solid rgba(212,175,55,0.2)',
            boxShadow: '0 2px 12px rgba(0,0,0,0.06)',
            height: '48px',
          }}
        >
          <Search size={18} className="text-inactive flex-shrink-0" />
          <input
            ref={inputRef}
            type="text"
            value={localKeyword}
            onChange={(e) => setLocalKeyword(e.target.value)}
            onKeyUp={(e) => {
              if (e.key === "Enter") handleSearch(localKeyword);
            }}
            onBlur={() => handleSearch(localKeyword)}
            placeholder="Tìm kiếm nước hoa..."
            className="flex-1 bg-transparent text-sm outline-none"
            style={{ color: '#0D0D0D' }}
          />
          {localKeyword && (
            <button onClick={clearSearch} className="flex-shrink-0 active:scale-90 transition-transform">
              <X size={16} className="text-inactive" />
            </button>
          )}
        </div>
      </div>

      {keyword ? (
        <Suspense fallback={<SearchResultSkeleton />}>
          <SearchResultList />
        </Suspense>
      ) : (
        <>
          {/* Popular searches */}
          <div className="px-4 pb-4">
            <div className="text-xs font-bold text-foreground mb-3 tracking-wide">Tìm kiếm phổ biến</div>
            <div className="flex flex-wrap gap-2">
              {POPULAR_SEARCHES.map((term) => (
                <button
                  key={term}
                  onClick={() => handleSearch(term)}
                  className="px-3 py-1.5 rounded-full text-xs font-medium active:scale-95 transition-transform"
                  style={{
                    background: '#FFFFFF',
                    border: '1px solid rgba(0,0,0,0.08)',
                    color: '#6B6B6B',
                  }}
                >
                  {term}
                </button>
              ))}
            </div>
          </div>

          {/* Divider */}
          <div className="mx-4 h-px" style={{ background: 'rgba(212,175,55,0.12)' }} />

          <Suspense fallback={null}>
            <RecommendedProducts />
          </Suspense>
        </>
      )}
    </div>
  );
}
