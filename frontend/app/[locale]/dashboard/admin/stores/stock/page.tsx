'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { storesService, type StockOverview, type StockOverviewStore, type Store } from '@/services/stores.service';
import { productService, type Product } from '@/services/product.service';
import { Plus, ArrowRightLeft, Search, Trash2, Save, LayoutGrid, FileInput, Send, CheckCircle2, Loader2, AlertCircle, PackageSearch, Tag } from 'lucide-react';
import { useEffect, useState, useCallback, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

type BatchItem = {
  variantId: string;
  productName: string;
  variantName: string;
  brandName: string;
  quantity: number;
};

type TabType = 'overview' | 'batch-import' | 'transfer';

export default function AdminStockRedesignPage() {
  const [activeTab, setActiveTab] = useState<TabType>('overview');
  const [overview, setOverview] = useState<StockOverview | null>(null);
  const [storeList, setStoreList] = useState<Store[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  // Batch Import State
  const [importStoreId, setImportStoreId] = useState('');
  const [importItems, setImportItems] = useState<BatchItem[]>([]);
  const [importSearch, setImportSearch] = useState('');
  const [importReason, setImportReason] = useState('');

  // Transfer State
  const [transferFromId, setTransferFromId] = useState('');
  const [transferToId, setTransferToId] = useState('');
  const [transferItems, setTransferItems] = useState<BatchItem[]>([]);
  const [transferSearch, setTransferSearch] = useState('');
  const [transferReason, setTransferReason] = useState('');

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const [ov, stores, prodRes] = await Promise.all([
        storesService.getStockOverview(),
        storesService.list(),
        productService.adminList({ take: 200 }),
      ]);
      setOverview(ov);
      setStoreList(stores);
      setProducts(prodRes.items);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // --- Helpers ---
  const allVariants = useMemo(() => {
    return products.flatMap((p) =>
      (p.variants ?? []).map((v) => ({
        id: v.id,
        productName: p.name,
        variantName: v.name,
        brandName: p.brand?.name || 'Unknown Brand',
        fullName: `${p.name} — ${v.name}`,
        sku: v.sku,
        price: v.price,
      }))
    );
  }, [products]);

  const filteredVariantsImport = useMemo(() => {
    if (!importSearch.trim()) return allVariants.slice(0, 15);
    return allVariants.filter(v =>
      v.productName.toLowerCase().includes(importSearch.toLowerCase()) ||
      v.sku?.toLowerCase().includes(importSearch.toLowerCase()) ||
      v.brandName.toLowerCase().includes(importSearch.toLowerCase())
    ).slice(0, 30);
  }, [allVariants, importSearch]);

  const filteredVariantsTransfer = useMemo(() => {
    if (!transferFromId || !overview) return [];
    const sourceStore = overview.stores.find(s => s.store.id === transferFromId);
    if (!sourceStore) return [];

    const storeAssets = sourceStore.variants.map(v => ({
      id: v.variantId,
      productName: v.productName,
      variantName: v.variantName,
      brandName: v.brandName || 'Unknown Brand',
      fullName: `${v.productName} — ${v.variantName}`,
      quantity: v.quantity,
      sku: '',
    }));

    if (!transferSearch.trim()) return storeAssets.slice(0, 20);
    return storeAssets.filter(v =>
      v.productName.toLowerCase().includes(transferSearch.toLowerCase()) ||
      v.brandName.toLowerCase().includes(transferSearch.toLowerCase())
    ).slice(0, 30);
  }, [overview, transferFromId, transferSearch]);

  const addImportItem = (variant: typeof allVariants[0]) => {
    if (importItems.find(i => i.variantId === variant.id)) return;
    setImportItems([...importItems, {
      variantId: variant.id,
      productName: variant.productName,
      variantName: variant.variantName,
      brandName: variant.brandName,
      quantity: 1
    }]);
    setImportSearch('');
  };

  const addTransferItem = (variant: any) => {
    if (transferItems.find(i => i.variantId === variant.id)) return;
    setTransferItems([...transferItems, {
      variantId: variant.id,
      productName: variant.productName,
      variantName: variant.variantName,
      brandName: variant.brandName,
      quantity: 1
    }]);
    setTransferSearch('');
  };

  // --- Actions ---
  const handleBatchImport = async () => {
    if (!importStoreId || importItems.length === 0) return;
    setSaving(true);
    setError(null);
    try {
      for (const item of importItems) {
        await storesService.adminImportStock({
          storeId: importStoreId,
          variantId: item.variantId,
          quantity: item.quantity,
          reason: importReason || 'Batch Import Session',
        });
      }
      setSuccess(`Successfully imported ${importItems.length} items.`);
      setImportItems([]);
      setImportReason('');
      fetchData();
      setTimeout(() => setSuccess(null), 3000);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const handleBatchTransfer = async () => {
    if (!transferFromId || !transferToId || transferItems.length === 0) return;
    setSaving(true);
    setError(null);
    try {
      for (const item of transferItems) {
        await storesService.transferStock({
          fromStoreId: transferFromId,
          toStoreId: transferToId,
          variantId: item.variantId,
          quantity: item.quantity,
          reason: transferReason || 'Batch Transfer Session',
        });
      }
      setSuccess(`Successfully transferred ${transferItems.length} items.`);
      setTransferItems([]);
      setTransferReason('');
      fetchData();
      setTimeout(() => setSuccess(null), 3000);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <AuthGuard allowedRoles={['admin']}>
      <main className="p-8 max-w-[1800px] mx-auto">
        <header className="mb-10 flex justify-between items-end">
          <div className="flex items-center gap-4">
            <div className="p-4 bg-gold/10 rounded-3xl">
              <LayoutGrid className="w-8 h-8 text-gold" />
            </div>
            <div>
              <h1 className="text-5xl font-heading gold-gradient uppercase tracking-tighter leading-none">Inventory Matrix</h1>
              <p className="text-muted-foreground font-body text-[10px] uppercase tracking-[0.4em] mt-2">Professional Stock Management Suite</p>
            </div>
          </div>
          <div className="flex gap-2 bg-secondary/20 p-1.5 rounded-2xl border border-border">
            <button onClick={() => setActiveTab('overview')} className={`flex items-center gap-2 px-6 py-3 rounded-xl text-[10px] font-heading uppercase tracking-widest transition-all ${activeTab === 'overview' ? 'bg-background shadow-xl text-gold' : 'text-muted-foreground hover:text-foreground'}`}><LayoutGrid className="w-4 h-4" /> Global View</button>
            <button onClick={() => setActiveTab('batch-import')} className={`flex items-center gap-2 px-6 py-3 rounded-xl text-[10px] font-heading uppercase tracking-widest transition-all ${activeTab === 'batch-import' ? 'bg-background shadow-xl text-gold' : 'text-muted-foreground hover:text-foreground'}`}><FileInput className="w-4 h-4" /> Batch Import</button>
            <button onClick={() => setActiveTab('transfer')} className={`flex items-center gap-2 px-6 py-3 rounded-xl text-[10px] font-heading uppercase tracking-widest transition-all ${activeTab === 'transfer' ? 'bg-background shadow-xl text-gold' : 'text-muted-foreground hover:text-foreground'}`}><ArrowRightLeft className="w-4 h-4" /> Stock Transfer</button>
          </div>
        </header>

        {/* Status Messages */}
        <AnimatePresence mode="wait">
          {error && (
            <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0 }} className="mb-8 p-5 rounded-3xl bg-destructive/10 border border-destructive/20 text-destructive text-sm flex items-center gap-4">
              <AlertCircle className="w-5 h-5" /> {error}
            </motion.div>
          )}
          {success && (
            <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0 }} className="mb-8 p-5 rounded-3xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 text-sm flex items-center gap-4">
              <CheckCircle2 className="w-5 h-5" /> {success}
            </motion.div>
          )}
        </AnimatePresence>

        <div className="min-h-[700px]">
          {/* --- TAB 1: OVERVIEW GRID --- */}
          {activeTab === 'overview' && (
            <div className="grid grid-cols-1 gap-10">
              {loading ? (
                <div className="flex flex-col items-center justify-center py-32 gap-6">
                  <Loader2 className="w-12 h-12 animate-spin text-gold/50" />
                  <p className="text-[10px] uppercase tracking-[0.5em] text-muted-foreground animate-pulse">Syncing Global Assets...</p>
                </div>
              ) : (
                overview?.stores.map(storeData => (
                  <section key={storeData.store.id} className="glass rounded-[3.5rem] border border-border overflow-hidden">
                    <div className="px-10 py-8 bg-secondary/30 border-b border-border flex justify-between items-center">
                      <div>
                        <div className="flex items-center gap-3 mb-1">
                          <Tag className="w-4 h-4 text-gold" />
                          <h3 className="font-heading text-xl uppercase tracking-widest text-foreground">{storeData.store.name}</h3>
                        </div>
                        <p className="text-[10px] text-muted-foreground uppercase tracking-[0.2em] pl-7">Boutique ID: {storeData.store.code || 'SYS-DEFAULT'}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-heading text-3xl text-gold leading-none">{storeData.totalUnits}</p>
                        <p className="text-[9px] text-muted-foreground uppercase tracking-widest mt-2">Total SKU Units</p>
                      </div>
                    </div>
                    <div className="overflow-x-auto">
                      <table className="w-full text-left border-collapse">
                        <thead>
                          <tr className="border-b border-border/50 text-muted-foreground">
                            <th className="px-10 py-5 text-[10px] uppercase tracking-widest font-heading">Olfactory Asset / Identifier</th>
                            <th className="px-10 py-5 text-[10px] uppercase tracking-widest font-heading text-center">Edition / Size</th>
                            <th className="px-10 py-5 text-[10px] uppercase tracking-widest font-heading text-right">Available Inventory</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-border/20">
                          {storeData.variants.length === 0 ? (
                            <tr><td colSpan={3} className="px-10 py-20 text-center text-muted-foreground italic font-body text-sm opacity-50">Empty Boutique. No inventory records established.</td></tr>
                          ) : (
                            storeData.variants.map(v => (
                              <tr key={v.variantId} className="group hover:bg-gold/5 transition-all">
                                <td className="px-10 py-6">
                                  <p className="font-heading text-sm uppercase tracking-tight group-hover:text-gold transition-colors">{v.productName}</p>
                                  <p className="text-[10px] text-muted-foreground uppercase tracking-widest mt-1">{v.brandName}</p>
                                </td>
                                <td className="px-10 py-6 text-center">
                                  <span className="px-4 py-1.5 rounded-full bg-secondary text-[10px] uppercase tracking-widest font-heading border border-border group-hover:border-gold/30 group-hover:bg-gold/5 transition-all">{v.variantName}</span>
                                </td>
                                <td className="px-10 py-6 text-right">
                                  <span className={`font-heading text-lg ${v.quantity === 0 ? 'text-destructive' : v.quantity <= 5 ? 'text-amber-500' : 'text-foreground'}`}>
                                    {v.quantity}
                                  </span>
                                </td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  </section>
                ))
              )}
            </div>
          )}

          {/* --- TAB 2: BATCH IMPORT --- */}
          {activeTab === 'batch-import' && (
            <div className="flex flex-col gap-8">
              {/* Configuration Header */}
              <div className="glass p-10 rounded-[3rem] border-border flex flex-wrap gap-10 items-center">
                <div className="flex-1 min-w-[300px]">
                  <label className="text-[10px] uppercase tracking-[0.3em] text-muted-foreground block mb-3 font-heading">Destination Boutique</label>
                  <select
                    value={importStoreId}
                    onChange={e => setImportStoreId(e.target.value)}
                    className="w-full bg-secondary/30 border border-border rounded-2xl px-6 py-4 text-sm font-heading uppercase tracking-widest outline-none focus:border-gold transition-all"
                  >
                    <option value="">-- Choose Target Store --</option>
                    {storeList.map(s => <option key={s.id} value={s.id}>{s.name} ({s.code || 'POS'})</option>)}
                  </select>
                </div>
                <div className="flex-[2] min-w-[400px]">
                  <label className="text-[10px] uppercase tracking-[0.3em] text-muted-foreground block mb-3 font-heading">Import Metadata</label>
                  <input
                    type="text"
                    value={importReason}
                    onChange={e => setImportReason(e.target.value)}
                    placeholder="e.g. Q1 Seasonal Restock"
                    className="w-full bg-secondary/30 border border-border rounded-2xl px-6 py-4 text-sm font-body outline-none focus:border-gold transition-all"
                  />
                </div>
              </div>

              <div className="grid lg:grid-cols-5 gap-8 items-start">
                {/* Product Selector */}
                <div className="lg:col-span-2 glass rounded-[3rem] border-border overflow-hidden flex flex-col h-[800px]">
                  <div className="p-8 border-b border-border bg-secondary/10">
                    <div className="flex items-center gap-3 mb-6">
                      <PackageSearch className="w-5 h-5 text-gold" />
                      <h3 className="font-heading text-sm uppercase tracking-widest">Universal Product Catalog</h3>
                    </div>
                    <div className="relative">
                      <Search className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                      <input
                        type="text"
                        value={importSearch}
                        onChange={e => setImportSearch(e.target.value)}
                        placeholder="Filter by name, brand or sku..."
                        className="w-full bg-background border border-border rounded-2xl pl-14 pr-6 py-4 text-sm outline-none focus:border-gold transition-all"
                      />
                    </div>
                  </div>
                  <div className="flex-1 overflow-y-auto p-6 custom-scrollbar">
                    <div className="grid grid-cols-1 gap-3">
                      {filteredVariantsImport.map(v => (
                        <button
                          key={v.id}
                          onClick={() => addImportItem(v)}
                          className="flex items-center justify-between p-5 rounded-2xl bg-secondary/20 hover:bg-gold/10 border border-border hover:border-gold/30 transition-all text-left group"
                        >
                          <div className="flex-1 min-w-0 mr-4">
                            <p className="text-[9px] font-heading uppercase text-gold mb-1">{v.brandName}</p>
                            <p className="text-xs font-bold uppercase tracking-tight leading-tight group-hover:text-gold transition-colors">{v.productName}</p>
                            <div className="flex items-center gap-3 mt-2">
                              <span className="text-[9px] px-3 py-0.5 bg-background border border-border rounded-full font-heading text-foreground uppercase tracking-widest">{v.variantName}</span>
                              <span className="text-[8px] text-muted-foreground font-mono tracking-tighter">SKU: {v.sku || 'N/A'}</span>
                            </div>
                          </div>
                          <div className="p-3 bg-background rounded-xl border border-border group-hover:bg-gold group-hover:text-primary-foreground transition-all">
                            <Plus className="w-4 h-4" />
                          </div>
                        </button>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Processing List */}
                <div className="lg:col-span-3 glass rounded-[3rem] border-border overflow-hidden flex flex-col h-[800px]">
                  <div className="p-8 border-b border-border flex justify-between items-center bg-secondary/10">
                    <h3 className="font-heading text-sm uppercase tracking-widest">Staging Manifest ({importItems.length})</h3>
                    <button onClick={() => setImportItems([])} className="px-4 py-2 rounded-xl text-[9px] uppercase tracking-widest font-heading text-muted-foreground hover:text-destructive transition-all">Flush Session</button>
                  </div>
                  <div className="flex-1 overflow-y-auto p-6 custom-scrollbar">
                    {importItems.length === 0 ? (
                      <div className="h-full flex flex-col items-center justify-center text-muted-foreground/30 gap-6">
                        <FileInput className="w-20 h-20 stroke-[0.5px]" />
                        <p className="text-xs uppercase tracking-[0.5em] font-heading text-center max-w-xs leading-relaxed">Search and add products to begin</p>
                      </div>
                    ) : (
                      <div className="space-y-3">
                        <AnimatePresence>
                          {importItems.map((item, idx) => (
                            <motion.div
                              initial={{ opacity: 0, x: 20 }}
                              animate={{ opacity: 1, x: 0 }}
                              exit={{ opacity: 0, scale: 0.95 }}
                              key={item.variantId}
                              className="flex items-center justify-between p-5 rounded-2xl bg-secondary/20 border border-border hover:border-gold/30 transition-all text-left group"
                            >
                              <div className="flex-1 min-w-0 mr-4">
                                <p className="text-[9px] font-heading uppercase text-gold mb-1">{item.brandName}</p>
                                <p className="text-xs font-bold uppercase tracking-tight leading-tight">{item.productName}</p>
                                <div className="flex items-center gap-3 mt-2">
                                  <span className="text-[9px] px-3 py-0.5 bg-background border border-border rounded-full font-heading text-foreground uppercase tracking-widest">{item.variantName}</span>
                                </div>
                              </div>
                              <div className="flex items-center gap-4">
                                <div className="flex flex-col items-end">
                                  <label className="text-[8px] uppercase tracking-widest text-muted-foreground font-heading mb-1">Qty</label>
                                  <input
                                    type="number"
                                    value={item.quantity || ''}
                                    onChange={e => {
                                      const val = e.target.value === '' ? 0 : parseInt(e.target.value, 10);
                                      setImportItems(prev => prev.map((it, i) => i === idx ? { ...it, quantity: val } : it));
                                    }}
                                    className="w-20 bg-background border border-border rounded-xl px-3 py-2 text-center font-heading text-xs focus:border-gold outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none transition-all"
                                  />
                                </div>
                                <button onClick={() => setImportItems(prev => prev.filter((_, i) => i !== idx))} className="p-3 rounded-xl bg-destructive/5 text-destructive hover:bg-destructive hover:text-white transition-all">
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              </div>
                            </motion.div>
                          ))}
                        </AnimatePresence>
                      </div>
                    )}
                  </div>
                  <div className="p-10 border-t border-border bg-secondary/5">
                    <button
                      onClick={handleBatchImport}
                      disabled={saving || importItems.length === 0 || !importStoreId}
                      className="w-full py-6 bg-gold text-primary font-heading font-bold uppercase tracking-[0.4em] text-[11px] rounded-full shadow-2xl flex items-center justify-center gap-4 hover:scale-[1.02] transition-all disabled:opacity-50"
                    >
                      {saving ? <Loader2 className="w-5 h-5 animate-spin" /> : <Save className="w-5 h-5" />}
                      {saving ? 'Processing...' : 'Confirm Import Session'}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* --- TAB 3: TRANSFER --- */}
          {activeTab === 'transfer' && (
            <div className="flex flex-col gap-8">
              {/* Transfer Matrix Header */}
              <div className="glass p-10 rounded-[3rem] border-border grid md:grid-cols-3 gap-10 items-center">
                <div>
                  <label className="text-[10px] uppercase tracking-[0.3em] text-muted-foreground block mb-3 font-heading">Source Boutique</label>
                  <select
                    value={transferFromId}
                    onChange={e => setTransferFromId(e.target.value)}
                    className="w-full bg-secondary/30 border border-border rounded-2xl px-6 py-4 text-sm font-heading uppercase tracking-widest outline-none focus:border-gold transition-all"
                  >
                    <option value="">-- Choose Origin --</option>
                    {storeList.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                  </select>
                </div>
                <div className="flex justify-center relative">
                  <div className="p-5 bg-background border border-border rounded-full shadow-2xl text-gold z-10">
                    <ArrowRightLeft className="w-6 h-6" />
                  </div>
                  <div className="absolute top-1/2 left-0 w-full h-[1px] bg-border -z-0"></div>
                </div>
                <div>
                  <label className="text-[10px] uppercase tracking-[0.3em] text-muted-foreground block mb-3 font-heading">Target Boutique</label>
                  <select
                    value={transferToId}
                    onChange={e => setTransferToId(e.target.value)}
                    className="w-full bg-secondary/30 border border-border rounded-2xl px-6 py-4 text-sm font-heading uppercase tracking-widest outline-none focus:border-gold transition-all"
                  >
                    <option value="">-- Choose Destination --</option>
                    {storeList.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                  </select>
                </div>
              </div>

              <div className="grid lg:grid-cols-5 gap-8 items-start">
                {/* Asset Finder */}
                <div className="lg:col-span-2 glass rounded-[3rem] border-border overflow-hidden flex flex-col h-[800px]">
                  <div className="p-8 border-b border-border bg-secondary/10">
                    <div className="flex items-center gap-3 mb-6">
                      <Search className="w-5 h-5 text-gold" />
                      <h3 className="font-heading text-sm uppercase tracking-widest">Asset Finder</h3>
                    </div>
                    <div className="relative">
                      <Search className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                      <input
                        type="text"
                        value={transferSearch}
                        onChange={e => setTransferSearch(e.target.value)}
                        placeholder={transferFromId ? "Search in source..." : "Select source first..."}
                        disabled={!transferFromId}
                        className="w-full bg-background border border-border rounded-2xl pl-14 pr-6 py-4 text-sm outline-none focus:border-gold disabled:opacity-50 transition-all"
                      />
                    </div>
                  </div>
                  <div className="flex-1 overflow-y-auto p-6 custom-scrollbar">
                    {!transferFromId ? (
                      <div className="h-full flex flex-col items-center justify-center text-muted-foreground/30"><ArrowRightLeft className="w-12 h-12 mb-4 opacity-20" /><p className="text-[10px] uppercase tracking-widest font-heading">Select Source Boutique</p></div>
                    ) : filteredVariantsTransfer.length === 0 ? (
                      <div className="h-full flex flex-col items-center justify-center text-muted-foreground/30"><PackageSearch className="w-12 h-12 mb-4 opacity-20" /><p className="text-[10px] uppercase tracking-widest font-heading">No assets found</p></div>
                    ) : (
                      <div className="grid grid-cols-1 gap-3">
                        {filteredVariantsTransfer.map(v => (
                          <button
                            key={v.id}
                            onClick={() => addTransferItem(v)}
                            className="flex items-center justify-between p-5 rounded-2xl bg-secondary/20 hover:bg-luxury-black hover:text-white border border-border transition-all text-left group"
                          >
                            <div className="flex-1 min-w-0 mr-4">
                              <p className="text-[9px] font-heading uppercase text-gold mb-1 group-hover:text-gold/80">{v.brandName}</p>
                              <p className="text-xs font-bold uppercase tracking-tight leading-tight">{v.productName}</p>
                              <div className="flex items-center gap-3 mt-2">
                                <span className="text-[9px] px-3 py-0.5 bg-background text-luxury-black border border-border rounded-full font-heading group-hover:bg-white/10 group-hover:text-white">{v.variantName}</span>
                                <span className="text-[8px] text-muted-foreground group-hover:text-gold">In Stock: {v.quantity}</span>
                              </div>
                            </div>
                            <Send className="w-4 h-4 text-gold group-hover:translate-x-1 transition-transform" />
                          </button>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                {/* Manifest List */}
                <div className="lg:col-span-3 glass rounded-[3rem] border-border overflow-hidden flex flex-col h-[800px]">
                  <div className="p-8 border-b border-border flex justify-between items-center bg-secondary/10">
                    <h3 className="font-heading text-sm uppercase tracking-widest">Relocation Manifest ({transferItems.length})</h3>
                    <button onClick={() => setTransferItems([])} className="text-[9px] uppercase tracking-widest font-heading text-muted-foreground hover:text-destructive transition-colors">Clear All</button>
                  </div>
                  <div className="flex-1 overflow-y-auto p-6 custom-scrollbar">
                    {transferItems.length === 0 ? (
                      <div className="h-full flex flex-col items-center justify-center text-muted-foreground/30 gap-6 opacity-50">
                        <ArrowRightLeft className="w-20 h-20 stroke-[0.5px]" />
                        <p className="text-xs uppercase tracking-[0.5em] font-heading">Declare assets for movement</p>
                      </div>
                    ) : (
                      <div className="space-y-3">
                        {transferItems.map((item, idx) => (
                          <motion.div
                            initial={{ opacity: 0, scale: 0.98 }}
                            animate={{ opacity: 1, scale: 1 }}
                            key={item.variantId}
                            className="flex items-center justify-between p-5 rounded-2xl bg-secondary/20 border border-border hover:border-luxury-black/30 transition-all text-left group"
                          >
                            <div className="flex-1 min-w-0 mr-4">
                              <p className="text-[9px] font-heading uppercase text-gold mb-1">{item.brandName}</p>
                              <p className="text-xs font-bold uppercase tracking-tight leading-tight">{item.productName}</p>
                              <div className="flex items-center gap-3 mt-2">
                                <span className="text-[9px] px-3 py-0.5 bg-background border border-border rounded-full font-heading text-foreground uppercase tracking-widest">{item.variantName}</span>
                              </div>
                            </div>
                            <div className="flex items-center gap-4">
                              <div className="flex flex-col items-end">
                                <label className="text-[8px] uppercase tracking-widest text-muted-foreground font-heading mb-1">Move</label>
                                <input
                                  type="number"
                                  value={item.quantity || ''}
                                  onChange={e => {
                                    const val = e.target.value === '' ? 0 : parseInt(e.target.value, 10);
                                    setTransferItems(prev => prev.map((it, i) => i === idx ? { ...it, quantity: val } : it));
                                  }}
                                  className="w-20 bg-background border border-border rounded-xl px-3 py-2 text-center font-heading text-xs focus:border-gold outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none transition-all"
                                />
                              </div>
                              <button onClick={() => setTransferItems(prev => prev.filter((_, i) => i !== idx))} className="p-3 rounded-xl bg-destructive/5 text-destructive hover:bg-destructive hover:text-white transition-all">
                                <Trash2 className="w-4 h-4" />
                              </button>
                            </div>
                          </motion.div>
                        ))}
                      </div>
                    )}
                  </div>
                  <div className="p-10 border-t border-border">
                    <button
                      onClick={handleBatchTransfer}
                      disabled={saving || transferItems.length === 0 || !transferFromId || !transferToId}
                      className="w-full py-6 bg-luxury-black text-white dark:bg-gold dark:text-primary font-heading font-bold uppercase tracking-[0.4em] text-[11px] rounded-full shadow-2xl flex items-center justify-center gap-4 hover:scale-[1.02] transition-all disabled:opacity-50"
                    >
                      {saving ? <Loader2 className="w-5 h-5 animate-spin" /> : <Send className="w-5 h-5" />}
                      {saving ? 'Processing...' : 'Confirm Movement'}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </AuthGuard>
  );
}
