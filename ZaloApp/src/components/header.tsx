import { useAtomValue } from "jotai";
import { useLocation, useNavigate } from "react-router-dom";
import { categoriesStateUpwrapped } from "@/state";
import { ChevronLeft } from "lucide-react";
import { useMemo } from "react";
import { useRouteHandle } from "@/hooks";

export default function Header() {
  const categories = useAtomValue(categoriesStateUpwrapped);
  const navigate = useNavigate();
  const location = useLocation();
  const [handle, match] = useRouteHandle();

  const title = useMemo(() => {
    if (handle) {
      if (typeof handle.title === "function") {
        return handle.title({ categories, params: match.params });
      } else {
        return handle.title;
      }
    }
  }, [handle, categories]);

  const showBack = location.key !== "default" && handle?.back !== false;

  // Logo header (Home / Profile) – no header shown, Home has its own inline header
  if (handle?.logo) {
    return null;
  }

  return (
    <div
      className="h-13 w-full flex items-center px-2 gap-1"
      style={{
        background: '#FFFFFF',
        borderBottom: '1px solid rgba(0,0,0,0.05)',
        minHeight: '52px',
      }}
    >
      {showBack && (
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 flex items-center justify-center rounded-xl active:scale-90 transition-transform flex-shrink-0"
          style={{ background: 'transparent' }}
        >
          <ChevronLeft size={22} className="text-foreground" strokeWidth={2.5} />
        </button>
      )}

      <div
        className="flex-1 text-base font-bold truncate"
        style={{ fontFamily: "'Playfair Display', serif" }}
      >
        {title}
      </div>
    </div>
  );
}
