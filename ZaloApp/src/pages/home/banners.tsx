import Carousel from "@/components/carousel";
import { useAtomValue } from "jotai";
import { bannersState } from "@/state";
import { unwrap } from "jotai/utils";

// Unwrap async bannersState to avoid Suspense requirement
const bannersStateSync = unwrap(bannersState, (prev) => prev ?? []);

export default function Banners() {
  const banners = useAtomValue(bannersStateSync);

  if (!banners.length) {
    // Skeleton while loading
    return (
      <div className="px-4 pb-3">
        <div
          className="w-full rounded-3xl bg-skeleton animate-pulse"
          style={{ aspectRatio: "16/7" }}
        />
      </div>
    );
  }

  return (
    <div className="px-4 pb-3">
      <Carousel
        slides={banners.map((banner, i) => (
          <img
            key={i}
            className="w-full rounded-3xl object-cover"
            style={{ aspectRatio: "16/7" }}
            src={banner}
            alt={`Banner ${i + 1}`}
          />
        ))}
      />
    </div>
  );
}
