'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { storesService, type StockOverview, type StockOverviewStore, type Store } from '@/services/stores.service';
import { productService, type Product } from '@/services/product.service';
import { Plus, ArrowRightLeft } from 'lucide-react';
import { useEffect, useState, useCallback } from 'react';

export default function AdminStockPage() {
  const [overview, setOverview] = useState<StockOverview | null>(null);
  const [storeList, setStoreList] = useState<Store[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filterStoreId, setFilterStoreId] = useState<string>('');
  const [importModal, setImportModal] = useState(false);
  const [transferModal, setTransferModal] = useState(false);
  const [importForm, setImportForm] = useState({ storeId: '', variantId: '', quantity: 1, reason: '' });
  const [transferForm, setTransferForm] = useState({
    fromStoreId: '',
    toStoreId: '',
    variantId: '',
    quantity: 1,
    reason: '',
  });
  const [saving, setSaving] = useState(false);

  const fetchOverview = useCallback(async () => {
    try {
      const data = await storesService.getStockOverview(
        filterStoreId || undefined,
      );
      setOverview(data);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }, [filterStoreId]);

  const fetchStores = useCallback(async () => {
    try {
      const list = await storesService.list();
      setStoreList(list);
    } catch {
      // optional
    }
  }, []);

  const fetchProducts = useCallback(async () => {
    try {
      const res = await productService.adminList({ take: 100 });
      setProducts(res.items);
    } catch {
      // optional
    }
  }, []);

  useEffect(() => {
    fetchOverview();
  }, [fetchOverview]);

  useEffect(() => {
    fetchStores();
  }, [fetchStores]);

  useEffect(() => {
    if (importModal || transferModal) fetchProducts();
  }, [importModal, transferModal, fetchProducts]);

  const handleImport = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await storesService.adminImportStock({
        storeId: importForm.storeId,
        variantId: importForm.variantId,
        quantity: importForm.quantity,
        reason: importForm.reason || undefined,
      });
      setImportModal(false);
      setImportForm({ storeId: '', variantId: '', quantity: 1, reason: '' });
      fetchOverview();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const handleTransfer = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await storesService.transferStock({
        fromStoreId: transferForm.fromStoreId,
        toStoreId: transferForm.toStoreId,
        variantId: transferForm.variantId,
        quantity: transferForm.quantity,
        reason: transferForm.reason || undefined,
      });
      setTransferModal(false);
      setTransferForm({ fromStoreId: '', toStoreId: '', variantId: '', quantity: 1, reason: '' });
      fetchOverview();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const stores = overview?.stores ?? [];
  const storesForSelect = storeList.length ? storeList : stores.map((s) => ({ id: s.store.id, name: s.store.name, code: s.store.code }));
  const allVariants = products.flatMap((p) =>
    (p.variants ?? []).map((v) => ({
      id: v.id,
      name: `${p.name} – ${v.name}`,
      productName: p.name,
    })),
  );

  return (
    <AuthGuard allowedRoles={['admin']}>
      <main className="p-8">
        <header className="mb-12 flex flex-wrap items-center justify-between gap-4">
          <div>
            <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">
              Tồn kho theo quầy
            </h1>
            <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">
              Xem tồn, nhập hàng vào quầy, chuyển tồn giữa các quầy
            </p>
          </div>
          <div className="flex gap-3">
            <button
              type="button"
              onClick={() => setImportModal(true)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-gold text-primary font-heading text-xs uppercase tracking-widest hover:opacity-90"
            >
              <Plus className="w-4 h-4" /> Nhập tồn
            </button>
            <button
              type="button"
              onClick={() => setTransferModal(true)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-2xl border border-gold text-gold font-heading text-xs uppercase tracking-widest hover:bg-gold/10"
            >
              <ArrowRightLeft className="w-4 h-4" /> Chuyển quầy
            </button>
          </div>
        </header>

        {error && (
          <div className="mb-6 p-4 rounded-2xl bg-destructive/10 text-destructive text-sm">
            {error}
          </div>
        )}

        {loading ? (
          <div className="glass rounded-[2.5rem] p-12 text-center text-muted-foreground">
            Đang tải...
          </div>
        ) : (
          <>
            {overview && (
              <div className="mb-8 p-6 rounded-2xl glass border border-border">
                <p className="text-sm text-muted-foreground uppercase tracking-widest">
                  Tổng: {overview.summary.totalStores} quầy, {overview.summary.totalUnits} đơn vị
                </p>
              </div>
            )}

            <div className="space-y-8">
              {stores.length === 0 ? (
                <div className="glass rounded-[2.5rem] p-12 text-center text-muted-foreground">
                  Chưa có tồn theo quầy. Tạo quầy và nhập tồn từ &quot;Nhập tồn&quot;.
                </div>
              ) : (
                stores.map((s: StockOverviewStore) => (
                  <div
                    key={s.store.id}
                    className="glass rounded-[2.5rem] border border-border overflow-hidden"
                  >
                    <div className="px-8 py-5 bg-secondary/50 border-b border-border flex items-center justify-between">
                      <h2 className="font-heading uppercase tracking-wider text-gold">
                        {s.store.name}
                        {s.store.code && (
                          <span className="ml-2 text-muted-foreground font-body normal-case">
                            ({s.store.code})
                          </span>
                        )}
                      </h2>
                      <span className="text-sm text-muted-foreground">
                        Tổng: {s.totalUnits} đơn vị
                      </span>
                    </div>
                    <div className="overflow-x-auto">
                      <table className="w-full text-left font-body text-sm">
                        <thead className="text-muted-foreground border-b border-border">
                          <tr>
                            <th className="px-8 py-4 text-[10px] uppercase tracking-widest font-heading">
                              Sản phẩm / Variant
                            </th>
                            <th className="px-8 py-4 text-[10px] uppercase tracking-widest font-heading">
                              Số lượng
                            </th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-border/50">
                          {s.variants.length === 0 ? (
                            <tr>
                              <td colSpan={2} className="px-8 py-8 text-center text-muted-foreground">
                                Chưa có tồn
                              </td>
                            </tr>
                          ) : (
                            s.variants.map((v) => (
                              <tr key={v.variantId} className="hover:bg-secondary/20">
                                <td className="px-8 py-4">
                                  <span className="font-heading text-xs">{v.productName}</span>
                                  <span className="text-muted-foreground text-[10px] ml-2">
                                    {v.variantName}
                                  </span>
                                </td>
                                <td className="px-8 py-4 font-heading">{v.quantity}</td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>
                ))
              )}
            </div>
          </>
        )}

        {importModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
            <div className="glass rounded-[2.5rem] border border-border p-8 w-full max-w-md">
              <h2 className="text-xl font-heading uppercase tracking-wider mb-6">Nhập tồn vào quầy</h2>
              <form onSubmit={handleImport} className="space-y-4">
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Quầy
                  </label>
                  <select
                    value={importForm.storeId}
                    onChange={(e) => setImportForm((f) => ({ ...f, storeId: e.target.value }))}
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                    required
                  >
                    <option value="">-- Chọn quầy --</option>
                    {storesForSelect.map((s) => (
                      <option key={s.id} value={s.id}>
                        {s.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Variant (sản phẩm – dung tích)
                  </label>
                  <select
                    value={importForm.variantId}
                    onChange={(e) => setImportForm((f) => ({ ...f, variantId: e.target.value }))}
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                    required
                  >
                    <option value="">-- Chọn variant --</option>
                    {allVariants.map((v) => (
                      <option key={v.id} value={v.id}>
                        {v.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Số lượng
                  </label>
                  <input
                    type="number"
                    min={1}
                    value={importForm.quantity}
                    onChange={(e) =>
                      setImportForm((f) => ({ ...f, quantity: parseInt(e.target.value, 10) || 1 }))
                    }
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                  />
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Lý do (tùy chọn)
                  </label>
                  <input
                    type="text"
                    value={importForm.reason}
                    onChange={(e) => setImportForm((f) => ({ ...f, reason: e.target.value }))}
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                  />
                </div>
                <div className="flex gap-3 pt-4">
                  <button
                    type="submit"
                    disabled={saving}
                    className="flex-1 py-2.5 rounded-xl bg-gold text-primary font-heading text-xs uppercase tracking-widest disabled:opacity-50"
                  >
                    {saving ? 'Đang lưu...' : 'Nhập'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setImportModal(false)}
                    className="px-6 py-2.5 rounded-xl border border-border font-heading text-xs uppercase tracking-widest"
                  >
                    Hủy
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {transferModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
            <div className="glass rounded-[2.5rem] border border-border p-8 w-full max-w-md">
              <h2 className="text-xl font-heading uppercase tracking-wider mb-6">Chuyển tồn giữa quầy</h2>
              <form onSubmit={handleTransfer} className="space-y-4">
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Từ quầy
                  </label>
                  <select
                    value={transferForm.fromStoreId}
                    onChange={(e) =>
                      setTransferForm((f) => ({ ...f, fromStoreId: e.target.value }))
                    }
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                    required
                  >
                    <option value="">-- Chọn quầy --</option>
                    {storesForSelect.map((s) => (
                      <option key={s.id} value={s.id}>
                        {s.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Đến quầy
                  </label>
                  <select
                    value={transferForm.toStoreId}
                    onChange={(e) =>
                      setTransferForm((f) => ({ ...f, toStoreId: e.target.value }))
                    }
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                    required
                  >
                    <option value="">-- Chọn quầy --</option>
                    {storesForSelect.map((s) => (
                      <option key={s.id} value={s.id}>
                        {s.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Variant
                  </label>
                  <select
                    value={transferForm.variantId}
                    onChange={(e) =>
                      setTransferForm((f) => ({ ...f, variantId: e.target.value }))
                    }
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                    required
                  >
                    <option value="">-- Chọn variant --</option>
                    {allVariants.map((v) => (
                      <option key={v.id} value={v.id}>
                        {v.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Số lượng
                  </label>
                  <input
                    type="number"
                    min={1}
                    value={transferForm.quantity}
                    onChange={(e) =>
                      setTransferForm((f) => ({
                        ...f,
                        quantity: parseInt(e.target.value, 10) || 1,
                      }))
                    }
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                  />
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Lý do (tùy chọn)
                  </label>
                  <input
                    type="text"
                    value={transferForm.reason}
                    onChange={(e) =>
                      setTransferForm((f) => ({ ...f, reason: e.target.value }))
                    }
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                  />
                </div>
                <div className="flex gap-3 pt-4">
                  <button
                    type="submit"
                    disabled={saving}
                    className="flex-1 py-2.5 rounded-xl bg-gold text-primary font-heading text-xs uppercase tracking-widest disabled:opacity-50"
                  >
                    {saving ? 'Đang chuyển...' : 'Chuyển'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setTransferModal(false)}
                    className="px-6 py-2.5 rounded-xl border border-border font-heading text-xs uppercase tracking-widest"
                  >
                    Hủy
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </main>
    </AuthGuard>
  );
}
