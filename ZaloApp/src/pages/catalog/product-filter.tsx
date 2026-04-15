import { Select } from "@/components/lazyloaded";
import { SelectSkeleton } from "@/components/skeleton";
import { useAtom, useAtomValue } from "jotai";
import { Suspense } from "react";
import {
  selectedGenderState, gendersState,
  selectedBrandState, brandsState,
  selectedPriceRangeState, priceRangesState, PriceRange
} from "@/state";

export default function ProductFilter() {
  const genders = useAtomValue(gendersState);
  const [gender, setGender] = useAtom(selectedGenderState);
  
  const brands = useAtomValue(brandsState);
  const [brand, setBrand] = useAtom(selectedBrandState);
  
  const priceRanges = useAtomValue(priceRangesState);
  const [price, setPrice] = useAtom(selectedPriceRangeState);

  return (
    <div className="flex px-4 py-3 space-x-2 overflow-x-auto no-scrollbar">
      <Suspense fallback={<SelectSkeleton width={90} />}>
        <Select
          items={genders}
          value={genders.find(g => g.id === gender)}
          onChange={(val: any) => setGender(val?.id)}
          renderTitle={(selected?: any) => `Giới tính${selected ? `: ${selected.label}` : ""}`}
          renderItemLabel={(item: any) => item.label}
          renderItemKey={(item: any) => item.id}
        />
      </Suspense>

      <Suspense fallback={<SelectSkeleton width={110} />}>
        <Select
          items={priceRanges}
          value={priceRanges.find(p => p.id === price)}
          onChange={(val: any) => setPrice(val?.id as PriceRange)}
          renderTitle={(selected?: any) => `Giá${selected ? `: ${selected.label}` : ""}`}
          renderItemLabel={(item: any) => item.label}
          renderItemKey={(item: any) => item.id}
        />
      </Suspense>

      <Suspense fallback={<SelectSkeleton width={110} />}>
        <Select
          items={brands}
          value={brand}
          onChange={(val: any) => setBrand(val)}
          renderTitle={(selected?: string) => `Brand${selected ? `: ${selected}` : ""}`}
          renderItemKey={(item: string) => String(item)}
        />
      </Suspense>

      {(gender !== undefined || price !== undefined || brand !== undefined) && (
        <button
          className="bg-primary text-white text-xs whitespace-nowrap rounded-full h-8 flex-none px-3"
          onClick={() => {
            setGender(undefined);
            setPrice(undefined);
            setBrand(undefined);
          }}
        >
          Xoá bộ lọc
        </button>
      )}
    </div>
  );
}
