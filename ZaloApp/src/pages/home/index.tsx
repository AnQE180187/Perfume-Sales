import { useNavigate } from "react-router-dom";
import Banners from "./banners";
import SearchBar from "../../components/search-bar";
import Category from "./category";
import FlashSales from "./flash-sales";
import BestSellers from "./best-sellers";
import HorizontalDivider from "@/components/horizontal-divider";
import AiCta from "./ai-cta";
import { Sparkles } from "lucide-react";

const HomePage: React.FunctionComponent = () => {
  const navigate = useNavigate();
  return (
    <div className="min-h-full bg-section relative">
      <div className="bg-background pt-2">
        <SearchBar onClick={() => navigate("/search")} />
        <Banners />
        <AiCta />
      </div>
      <div className="bg-background space-y-2 mt-2">
        <Category />
      </div>
      <HorizontalDivider />
      <BestSellers />
      <HorizontalDivider />
      <FlashSales />

      {/* Floating AI Chat Button */}
      <button
        id="fab-ai-chat"
        onClick={() => navigate("/ai-chat")}
        className="fixed bottom-24 right-4 z-50 w-14 h-14 rounded-full bg-primary shadow-xl shadow-primary/40 flex items-center justify-center text-white active:scale-90 transition-transform"
      >
        <Sparkles size={24} />
      </button>
    </div>
  );
};

export default HomePage;

