import { Product, SelectedOptions } from "@/types";

export function getDefaultOptions(product?: Product): SelectedOptions {
  if (!product) return {};
  return {
    size: product.sizes?.[0],
    color: product.colors?.[0]?.name,
  };
}

export function isIdentical(
  option1: SelectedOptions,
  option2: SelectedOptions
) {
  return option1.size === option2.size && option1.color === option2.color;
}
