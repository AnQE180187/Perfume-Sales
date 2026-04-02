'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';
import { Heart } from 'lucide-react';
import { Link } from '@/lib/i18n';
import { AuthGuard } from '@/components/auth/auth-guard';
import { favoriteService, type FavoriteItem } from '@/services/favorite.service';

export default function CustomerFavoritePage() {
  const [favorites, setFavorites] = useState<FavoriteItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadFavorites = async () => {
      try {
        const data = await favoriteService.getFavorites();
        setFavorites(data);
      } finally {
        setLoading(false);
      }
    };

    void loadFavorites();
    window.addEventListener(favoriteService.eventName, loadFavorites);
    return () => window.removeEventListener(favoriteService.eventName, loadFavorites);
  }, []);

  const handleRemoveFavorite = async (productId: string) => {
    await favoriteService.removeProduct(productId);
    const data = await favoriteService.getFavorites();
    setFavorites(data);
  };

  return (
    <AuthGuard allowedRoles={['customer']}>
      <main className="p-8 max-w-7xl mx-auto">
        <header className="mb-10">
          <h1 className="text-4xl font-heading gold-gradient uppercase tracking-tighter mb-2">
            Favorite Products
          </h1>
          <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">
            Danh sách nước hoa bạn đã lưu
          </p>
        </header>

        {loading ? (
          <p className="text-muted-foreground">Loading favorites...</p>
        ) : favorites.length === 0 ? (
          <div className="glass rounded-[3rem] border-border p-16 text-center">
            <Heart className="w-10 h-10 mx-auto text-muted-foreground mb-5" />
            <h2 className="font-heading text-xl uppercase tracking-widest mb-3">Chưa có sản phẩm yêu thích</h2>
            <Link
              href="/collection"
              className="inline-flex mt-4 px-8 py-3 rounded-full bg-gold text-primary-foreground text-[10px] font-bold tracking-widest uppercase"
            >
              Xem bộ sưu tập
            </Link>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {favorites.map((item) => (
              <div key={item.id} className="glass rounded-[2.5rem] border-border overflow-hidden">
                <div className="aspect-4/5 bg-secondary/20 relative">
                  {item.imageUrl ? (
                    <Image src={item.imageUrl} alt={item.name} fill className="object-cover" />
                  ) : null}
                </div>
                <div className="p-6 space-y-4">
                  <div>
                    <p className="text-[10px] text-gold uppercase tracking-widest font-bold">
                      {item.brandName || 'Brand'}
                    </p>
                    <h3 className="font-heading text-xl uppercase tracking-wider">{item.name}</h3>
                    {item.variantName ? (
                      <p className="text-[10px] text-muted-foreground uppercase tracking-widest mt-1">
                        Size: {item.variantName}
                      </p>
                    ) : null}
                  </div>
                  <p className="text-sm text-muted-foreground">
                    {typeof item.price === 'number'
                      ? new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.price)
                      : ''}
                  </p>
                  <div className="flex gap-3">
                    <Link
                      href={`/collection/${item.id}`}
                      className="flex-1 bg-gold text-primary-foreground py-3 rounded-2xl text-[10px] font-bold uppercase tracking-[0.2em] text-center"
                    >
                      Xem chi tiết
                    </Link>
                    <button
                      onClick={() => void handleRemoveFavorite(item.id)}
                      className="px-4 py-3 rounded-2xl border border-border text-[10px] uppercase tracking-[0.2em] hover:text-red-500 hover:border-red-400 transition-colors"
                    >
                      Xóa
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </AuthGuard>
  );
}
