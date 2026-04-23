import { ChevronRight } from 'lucide-react';
import { Link } from '@/lib/i18n';
import { productService } from '@/services/product.service';
import { getTranslations } from 'next-intl/server';
import ProductDetail from '@/components/product/product-detail';
import { notFound } from 'next/navigation';

export default async function CollectionDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const tCommon = await getTranslations('common');

  let product;
  try {
    product = await productService.getById(id);
    if (!product) return notFound();
  } catch {
    return notFound();
  }

  return (
    <div className="min-h-screen bg-[linear-gradient(180deg,#f8f6f1_0%,#ffffff_34%,#fbfaf7_100%)] px-6 pb-20 pt-28 transition-colors dark:bg-[linear-gradient(180deg,#09090b_0%,#0c0c10_36%,#09090b_100%)] md:pt-32">
      <div className="mx-auto max-w-7xl">
        <nav className="mb-10 flex flex-wrap items-center gap-3 text-sm text-muted-foreground md:mb-12">
          <Link href="/" className="transition-colors hover:text-gold">{tCommon('odyssey')}</Link>
          <ChevronRight className="h-4 w-4" />
          <Link href="/collection" className="transition-colors hover:text-gold">{tCommon('catalog')}</Link>
          <ChevronRight className="h-4 w-4" />
          {product.brand && (
            <>
              <span>{product.brand.name}</span>
              <ChevronRight className="h-4 w-4" />
            </>
          )}
          <span className="font-medium text-gold">{product.name}</span>
        </nav>

        <ProductDetail product={product} />
      </div>
    </div>
  );
}
