'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { Box, RefreshCw, AlertTriangle, Activity, Loader2, Store } from 'lucide-react';
import { useEffect, useState, useCallback } from 'react';
import { staffInventoryService, type StaffInventoryOverview, type StaffInventoryLog } from '@/services/staff-inventory.service';
import { storesService, type Store as StoreType } from '@/services/stores.service';

export default function StaffInventory() {
    const [myStores, setMyStores] = useState<StoreType[]>([]);
    const [selectedStoreId, setSelectedStoreId] = useState<string>('');
    const [overview, setOverview] = useState<StaffInventoryOverview | null>(null);
    const [logs, setLogs] = useState<StaffInventoryLog[]>([]);
    const [loading, setLoading] = useState(true);
    const [loadingLogs, setLoadingLogs] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [variantFilter, setVariantFilter] = useState<string>('');
    const [selectedVariant, setSelectedVariant] = useState<string>('');
    const [importQty, setImportQty] = useState<number>(0);
    const [importReason, setImportReason] = useState<string>('');
    const [adjustDelta, setAdjustDelta] = useState<number>(0);
    const [adjustReason, setAdjustReason] = useState<string>('');
    const [submitting, setSubmitting] = useState(false);

    const loadMyStores = useCallback(async () => {
        try {
            const list = await storesService.getMyStores();
            setMyStores(list);
            if (list.length && !selectedStoreId) setSelectedStoreId(list[0].id);
            if (list.length === 0) setLoading(false);
        } catch {
            setError('Không tải được danh sách quầy');
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        void loadMyStores();
    }, [loadMyStores]);

    const loadOverview = useCallback(async () => {
        if (!selectedStoreId) return;
        setLoading(true);
        setError(null);
        try {
            const data = await staffInventoryService.getOverview(selectedStoreId);
            setOverview(data);
        } catch (e: any) {
            setError(e.message || 'Failed to load inventory overview');
        } finally {
            setLoading(false);
        }
    }, [selectedStoreId]);

    const loadLogs = useCallback(async (variantId?: string) => {
        if (!selectedStoreId) return;
        setLoadingLogs(true);
        try {
            const data = await staffInventoryService.getLogs({
                storeId: selectedStoreId,
                ...(variantId ? { variantId } : {}),
            });
            setLogs(data);
        } catch {
            // ignore
        } finally {
            setLoadingLogs(false);
        }
    }, [selectedStoreId]);

    useEffect(() => {
        if (selectedStoreId) {
            void loadOverview();
            void loadLogs();
        } else {
            setOverview(null);
            setLogs([]);
        }
    }, [selectedStoreId, loadOverview, loadLogs]);

    const handleImport = async () => {
        if (!selectedStoreId || !selectedVariant || importQty <= 0) return;
        setSubmitting(true);
        setError(null);
        try {
            const data = await staffInventoryService.importStock(selectedStoreId, selectedVariant, importQty, importReason || undefined);
            setOverview(data);
            setImportQty(0);
            setImportReason('');
            void loadLogs(selectedVariant);
        } catch (e: any) {
            setError(e.message || 'Failed to import stock');
        } finally {
            setSubmitting(false);
        }
    };

    const handleAdjust = async () => {
        if (!selectedStoreId || !selectedVariant || adjustDelta === 0) return;
        setSubmitting(true);
        setError(null);
        try {
            const data = await staffInventoryService.adjustStock(selectedStoreId, selectedVariant, adjustDelta, adjustReason || 'Adjustment');
            setOverview(data);
            setAdjustDelta(0);
            setAdjustReason('');
            void loadLogs(selectedVariant);
        } catch (e: any) {
            setError(e.message || 'Failed to adjust stock');
        } finally {
            setSubmitting(false);
        }
    };

    const variants = overview?.variants ?? [];
    const filteredVariants = variantFilter
        ? variants.filter(v =>
            v.name.toLowerCase().includes(variantFilter.toLowerCase()) ||
            (v.brand ?? '').toLowerCase().includes(variantFilter.toLowerCase()))
        : variants;

    const stats = overview?.stats;

    return (
        <AuthGuard allowedRoles={['staff', 'admin']}>
            <main className="p-8 space-y-8">
                <header className="mb-4">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Boutique Stock</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Inventory Oversight & Adjustments</p>
                </header>

                {error && (
                    <div className="mb-4 p-3 rounded-2xl border border-red-500/40 bg-red-500/5 text-xs text-red-600 dark:text-red-400">
                        {error}
                    </div>
                )}

                <div className="mb-6 flex items-center gap-4">
                    <Store className="w-5 h-5 text-gold" />
                    <label className="text-[10px] uppercase tracking-widest text-muted-foreground">Quầy:</label>
                    <select
                        value={selectedStoreId}
                        onChange={(e) => setSelectedStoreId(e.target.value)}
                        className="rounded-xl border border-border bg-background px-4 py-2 text-sm font-heading uppercase tracking-wider focus:border-gold/60"
                    >
                        <option value="">-- Chọn quầy --</option>
                        {myStores.map((s) => (
                            <option key={s.id} value={s.id}>{s.name}</option>
                        ))}
                    </select>
                    {!myStores.length && !loading && (
                        <span className="text-xs text-muted-foreground">Chưa được gán quầy. Liên hệ Admin.</span>
                    )}
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-4">
                    {loading ? (
                        <div className="col-span-full flex items-center justify-center py-10 text-muted-foreground text-sm">
                            <Loader2 className="w-4 h-4 mr-2 animate-spin" /> Loading inventory…
                        </div>
                    ) : (
                        <>
                            <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group">
                                <div className="flex justify-between items-start mb-4">
                                    <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">Total Units</h3>
                                    <Box className="w-5 h-5 text-gold" />
                                </div>
                                <p className="text-4xl font-heading text-foreground">
                                    {stats?.totalUnits.toLocaleString('vi-VN') ?? '0'}
                                </p>
                            </div>
                            <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group">
                                <div className="flex justify-between items-start mb-4">
                                    <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">Low Stock</h3>
                                    <AlertTriangle className="w-5 h-5 text-amber-500" />
                                </div>
                                <p className="text-4xl font-heading text-foreground">
                                    {stats?.lowStockCount ?? 0}
                                </p>
                            </div>
                            <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group">
                                <div className="flex justify-between items-start mb-4">
                                    <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">Recent Refill</h3>
                                    <RefreshCw className="w-5 h-5 text-gold" />
                                </div>
                                <p className="text-sm font-heading text-foreground">
                                    {stats?.latestImportAt
                                        ? new Date(stats.latestImportAt).toLocaleString('vi-VN')
                                        : 'No imports yet'}
                                </p>
                            </div>
                        </>
                    )}
                </div>

                {!selectedStoreId ? (
                    <div className="glass rounded-[2.5rem] p-12 text-center text-muted-foreground">
                        Chọn quầy ở trên để xem và thao tác tồn kho.
                    </div>
                ) : (
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Variants & stock table */}
                    <div className="lg:col-span-2 glass rounded-[2.5rem] border-border overflow-hidden">
                        <div className="p-6 border-b border-border flex items-center justify-between gap-4">
                            <h2 className="font-heading text-lg uppercase tracking-widest">Stock Ledger</h2>
                            <div className="flex items-center gap-3">
                                <input
                                    type="text"
                                    value={variantFilter}
                                    onChange={(e) => setVariantFilter(e.target.value)}
                                    placeholder="Filter by product or brand…"
                                    className="text-xs rounded-full border border-border bg-background px-4 py-2 outline-none focus:border-gold/60"
                                />
                            </div>
                        </div>
                        <div className="p-6 max-h-[480px] overflow-y-auto custom-scrollbar">
                            {loading ? (
                                <div className="flex items-center justify-center py-10 text-muted-foreground text-sm">
                                    <Loader2 className="w-4 h-4 mr-2 animate-spin" /> Loading…
                                </div>
                            ) : filteredVariants.length === 0 ? (
                                <div className="text-sm text-muted-foreground text-center py-10">
                                    No variants found.
                                </div>
                            ) : (
                                <div className="space-y-3">
                                    {filteredVariants.map((row) => {
                                        const isLow =
                                            row.stock > 0 &&
                                            row.stock <= 5;
                                        const isSelected = selectedVariant === row.id;
                                        return (
                                            <button
                                                key={row.id}
                                                type="button"
                                                onClick={() => {
                                                    setSelectedVariant(row.id);
                                                    void loadLogs(row.id);
                                                }}
                                                className={`w-full flex items-center justify-between p-4 rounded-3xl border transition-all text-left ${
                                                    isSelected
                                                        ? 'border-gold bg-gold/5'
                                                        : 'bg-secondary/10 border border-border/50 hover:border-gold/40'
                                                }`}
                                            >
                                                <div>
                                                    <p className="text-[10px] text-gold uppercase tracking-[0.2em] font-bold">
                                                        {row.brand ?? '—'}
                                                    </p>
                                                    <h4 className="font-heading uppercase text-xs tracking-wider">
                                                        {row.name} ({row.variantName})
                                                    </h4>
                                                </div>
                                                <div className="flex items-center gap-8">
                                                    <div className="text-right">
                                                        <p className="text-[10px] text-muted-foreground uppercase tracking-widest mb-1">
                                                            Quantity
                                                        </p>
                                                        <p className="font-heading">{row.stock}</p>
                                                    </div>
                                                    <div
                                                        className={`px-3 py-1.5 rounded-full border text-[8px] uppercase tracking-widest font-bold ${
                                                            row.stock === 0
                                                                ? 'bg-stone-500/10 border-stone-500/30 text-stone-500'
                                                                : isLow
                                                                ? 'bg-amber-500/10 border-amber-500/30 text-amber-500'
                                                                : 'bg-emerald-500/10 border-emerald-500/30 text-emerald-500'
                                                        }`}
                                                    >
                                                        {row.stock === 0
                                                            ? 'Out'
                                                            : isLow
                                                            ? 'Low'
                                                            : 'Optimal'}
                                                    </div>
                                                </div>
                                            </button>
                                        );
                                    })}
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Right side: forms + logs */}
                    <div className="space-y-6">
                        {/* Forms */}
                        <div className="glass rounded-[2rem] border-border p-6 space-y-4">
                            <h3 className="font-heading text-sm uppercase tracking-widest mb-2 flex items-center gap-2">
                                <Activity className="w-4 h-4 text-gold" /> Stock Operations
                            </h3>
                            <p className="text-[11px] text-muted-foreground mb-2">
                                Select a variant from the ledger to import or adjust stock.
                            </p>

                            <div className="space-y-3">
                                <div>
                                    <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                                        Selected Variant
                                    </label>
                                    <div className="text-xs font-heading">
                                        {selectedVariant
                                            ? variants.find(v => v.id === selectedVariant)?.name ??
                                              selectedVariant
                                            : 'None'}
                                    </div>
                                </div>

                                <div className="grid grid-cols-2 gap-3 mt-2">
                                    <div className="space-y-2">
                                        <label className="block text-[10px] uppercase tracking-widest text-muted-foreground">
                                            Import Quantity
                                        </label>
                                        <input
                                            type="number"
                                            value={importQty || ''}
                                            onChange={(e) => setImportQty(Number(e.target.value) || 0)}
                                            className="w-full text-xs rounded-xl border border-border bg-background px-3 py-2 outline-none focus:border-gold/60"
                                            placeholder="e.g. 10"
                                        />
                                        <input
                                            type="text"
                                            value={importReason}
                                            onChange={(e) => setImportReason(e.target.value)}
                                            className="w-full text-xs rounded-xl border border-border bg-background px-3 py-2 outline-none focus:border-gold/60"
                                            placeholder="Reason (optional)"
                                        />
                                        <button
                                            type="button"
                                            onClick={handleImport}
                                            disabled={!selectedVariant || importQty <= 0 || submitting}
                                            className="w-full mt-1 py-2.5 rounded-full bg-gold text-primary-foreground text-[10px] font-heading uppercase tracking-widest disabled:opacity-50"
                                        >
                                            {submitting ? 'Processing…' : 'Import'}
                                        </button>
                                    </div>
                                    <div className="space-y-2">
                                        <label className="block text-[10px] uppercase tracking-widest text-muted-foreground">
                                            Adjust Delta
                                        </label>
                                        <input
                                            type="number"
                                            value={adjustDelta || ''}
                                            onChange={(e) => setAdjustDelta(Number(e.target.value) || 0)}
                                            className="w-full text-xs rounded-xl border border-border bg-background px-3 py-2 outline-none focus:border-gold/60"
                                            placeholder="e.g. -2 or 5"
                                        />
                                        <input
                                            type="text"
                                            value={adjustReason}
                                            onChange={(e) => setAdjustReason(e.target.value)}
                                            className="w-full text-xs rounded-xl border border-border bg-background px-3 py-2 outline-none focus:border-gold/60"
                                            placeholder="Reason"
                                        />
                                        <button
                                            type="button"
                                            onClick={handleAdjust}
                                            disabled={!selectedVariant || adjustDelta === 0 || submitting}
                                            className="w-full mt-1 py-2.5 rounded-full bg-secondary text-foreground text-[10px] font-heading uppercase tracking-widest disabled:opacity-50"
                                        >
                                            {submitting ? 'Processing…' : 'Adjust'}
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Logs */}
                        <div className="glass rounded-[2rem] border-border p-6 max-h-[260px] overflow-y-auto custom-scrollbar">
                            <div className="flex items-center justify-between mb-3">
                                <h3 className="font-heading text-sm uppercase tracking-widest">
                                    Recent Inventory Logs
                                </h3>
                                {loadingLogs && (
                                    <Loader2 className="w-3 h-3 animate-spin text-muted-foreground" />
                                )}
                            </div>
                            {logs.length === 0 ? (
                                <div className="text-xs text-muted-foreground">
                                    No inventory logs yet.
                                </div>
                            ) : (
                                <div className="space-y-2 text-[11px]">
                                    {logs.map((log) => (
                                        <div
                                            key={log.id}
                                            className="flex items-start justify-between py-2 border-b border-border/40 last:border-b-0"
                                        >
                                            <div>
                                                <div className="font-heading">
                                                    {log.variant.product?.name} ({log.variant.name})
                                                </div>
                                                <div className="text-[10px] text-muted-foreground">
                                                    {log.type} {log.quantity > 0 ? `+${log.quantity}` : log.quantity}{' '}
                                                    {log.reason && `• ${log.reason}`}
                                                </div>
                                            </div>
                                            <div className="text-right text-[10px] text-muted-foreground">
                                                <div>
                                                    {new Date(log.createdAt).toLocaleString('vi-VN')}
                                                </div>
                                                {log.staff && (
                                                    <div>{log.staff.fullName ?? log.staff.email}</div>
                                                )}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>
                </div>
                )}
            </main>
        </AuthGuard>
    );
}

