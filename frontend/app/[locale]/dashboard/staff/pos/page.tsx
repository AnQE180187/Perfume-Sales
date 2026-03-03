'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { useEffect, useState } from 'react';
import { Search, ShoppingCart, CreditCard, Plus, Minus, Receipt, QrCode } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { staffPosService, type PosOrder } from '@/services/staff-pos.service';
import type { Product } from '@/services/product.service';
import type { PayOSPaymentResponse } from '@/services/payment.service';

type PaymentMethod = 'CASH' | 'QR';

export default function PosPage() {
    const [products, setProducts] = useState<Product[]>([]);
    const [search, setSearch] = useState('');
    const [loadingProducts, setLoadingProducts] = useState(false);
    const [order, setOrder] = useState<PosOrder | null>(null);
    const [creatingOrder, setCreatingOrder] = useState(false);
    const [paying, setPaying] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>('CASH');
    const [qrPayment, setQrPayment] = useState<PayOSPaymentResponse | null>(null);

    const subtotal = order?.items?.reduce((acc, item) => acc + item.totalPrice, 0) ?? 0;

    const loadProducts = async (term: string) => {
        setLoadingProducts(true);
        setError(null);
        try {
            const list = await staffPosService.searchProducts(term);
            setProducts(list);
        } catch (e: any) {
            setError(e.message || 'Failed to load products');
        } finally {
            setLoadingProducts(false);
        }
    };

    useEffect(() => {
        // initial load
        loadProducts('');
    }, []);

    const ensureOrder = async () => {
        if (order) return order;
        setCreatingOrder(true);
        setError(null);
        try {
            const created = await staffPosService.createDraft();
            setOrder(created);
            return created;
        } catch (e: any) {
            setError(e.message || 'Failed to create draft order');
            throw e;
        } finally {
            setCreatingOrder(false);
        }
    };

    const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const value = e.target.value;
        setSearch(value);
        loadProducts(value);
    };

    const handleAddVariant = async (variantId: string) => {
        try {
            const current = await ensureOrder();
            const updated = await staffPosService.upsertItem(current.id, variantId, 1);
            setOrder(updated);
        } catch {
            // error đã set ở ensureOrder / upsert
        }
    };

    const handleChangeQuantity = async (variantId: string, delta: number) => {
        if (!order) return;
        const item = order.items.find(i => i.variantId === variantId);
        const currentQty = item?.quantity ?? 0;
        const nextQty = Math.max(0, currentQty + delta);
        try {
            const updated = await staffPosService.upsertItem(order.id, variantId, nextQty);
            setOrder(updated);
        } catch (e: any) {
            setError(e.message || 'Failed to update quantity');
        }
    };

    const handlePayCash = async () => {
        if (!order) return;
        setPaying(true);
        setError(null);
        try {
            const paid = await staffPosService.payCash(order.id);
            setOrder(paid);
            // đơn đã hoàn tất, có thể reset UI hoặc để staff tạo đơn mới
        } catch (e: any) {
            setError(e.message || 'Failed to complete payment');
        } finally {
            setPaying(false);
        }
    };

    const handleCreateQrPayment = async () => {
        if (!order || !order.items.length) return;
        setPaying(true);
        setError(null);
        try {
            const payment = await staffPosService.createQrPayment(order.id);
            setQrPayment(payment);
        } catch (e: any) {
            setError(e.message || 'Failed to create QR payment');
        } finally {
            setPaying(false);
        }
    };

    return (
        <AuthGuard allowedRoles={['staff', 'admin']}>
            <div className="flex h-[calc(100vh-80px)] overflow-hidden">
                {/* Catalog Area */}
                <div className="flex-1 flex flex-col border-r border-border min-w-0">
                    <header className="p-8 border-b border-border flex justify-between items-center bg-secondary/10 shrink-0">
                        <div className="relative w-full max-w-lg">
                            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                            <input
                                type="text"
                                value={search}
                                onChange={handleSearchChange}
                                placeholder="Search products, batches or scan barcode..."
                                className="w-full bg-background border border-border rounded-full py-3.5 pl-12 pr-4 text-sm focus:border-gold/50 outline-none transition-all shadow-sm"
                            />
                        </div>
                    </header>

                    <div className="flex-1 overflow-y-auto p-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 custom-scrollbar">
                        {loadingProducts ? (
                            <div className="col-span-full text-center text-muted-foreground text-sm">Loading products…</div>
                        ) : products.length === 0 ? (
                            <div className="col-span-full text-center text-muted-foreground text-sm">No products found.</div>
                        ) : (
                            products.flatMap((p) =>
                                (p.variants ?? []).map((v) => (
                                    <motion.div
                                        key={v.id}
                                        whileHover={{ y: -5 }}
                                        className="glass p-5 rounded-[2rem] border-border hover:border-gold/30 cursor-pointer group transition-all"
                                    >
                                        <div className="aspect-square bg-secondary/50 rounded-2xl mb-4 overflow-hidden relative">
                                            <div className="absolute inset-0 bg-gradient-to-tr from-gold/10 to-transparent" />
                                            <div className="absolute bottom-3 left-3 px-2 py-1 bg-background/80 backdrop-blur-md rounded-lg text-[9px] uppercase font-heading text-gold border border-gold/10">
                                                Stock: {v.stock}
                                            </div>
                                        </div>
                                        <h3 className="font-heading text-sm mb-1 line-clamp-1 uppercase tracking-tight">
                                            {p.name}
                                        </h3>
                                        <p className="text-[10px] text-muted-foreground uppercase tracking-[0.2em] mb-1">
                                            {p.brand?.name ?? '—'}
                                        </p>
                                        <p className="text-[10px] text-muted-foreground uppercase tracking-[0.2em] mb-2">
                                            {v.name}
                                        </p>
                                        <div className="flex justify-between items-center mt-4">
                                            <span className="font-heading text-gold text-lg">
                                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(v.price)}
                                            </span>
                                            <button
                                                onClick={() => handleAddVariant(v.id)}
                                                disabled={creatingOrder}
                                                className="p-3 rounded-xl bg-gold/10 text-gold group-hover:bg-gold group-hover:text-primary-foreground transition-all disabled:opacity-50"
                                            >
                                                <Plus className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </motion.div>
                                ))
                            )
                        )}
                    </div>
                </div>

                {/* Cart Area */}
                <div className="w-[400px] flex flex-col bg-secondary/10 shrink-0 p-8 shadow-2xl z-10 transition-colors">
                    <div className="flex items-center gap-3 mb-4">
                        <ShoppingCart className="w-6 h-6 text-gold" />
                        <h2 className="font-heading text-lg uppercase tracking-[0.2em]">Active Bin</h2>
                    </div>
                    {error && (
                        <div className="mb-4 text-xs text-red-500">
                            {error}
                        </div>
                    )}

                    <div className="flex-1 space-y-4 overflow-y-auto custom-scrollbar mb-8 pr-2">
                        <AnimatePresence>
                            {order?.items.map(item => (
                                <motion.div
                                    key={item.id}
                                    initial={{ opacity: 0, x: 20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: -20 }}
                                    className="glass p-5 rounded-2xl border-border flex gap-4 hover:border-gold/20 transition-colors"
                                >
                                    <div className="w-16 h-16 rounded-xl bg-secondary border border-border shrink-0" />
                                    <div className="flex-1 overflow-hidden">
                                        <p className="font-heading text-[10px] uppercase tracking-widest truncate">
                                            {item.variant.product?.name ?? 'Product'} — {item.variant.name}
                                        </p>
                                        <div className="flex justify-between items-center mt-4">
                                            <div className="flex items-center gap-3 glass rounded-lg p-1 border-border">
                                                <button
                                                    onClick={() => handleChangeQuantity(item.variantId, -1)}
                                                    className="p-1 hover:text-gold transition-colors"
                                                >
                                                    <Minus className="w-3 h-3" />
                                                </button>
                                                <span className="text-xs font-heading w-4 text-center">{item.quantity}</span>
                                                <button
                                                    onClick={() => handleChangeQuantity(item.variantId, 1)}
                                                    className="p-1 hover:text-gold transition-colors"
                                                >
                                                    <Plus className="w-3 h-3" />
                                                </button>
                                            </div>
                                            <span className="font-heading text-sm text-gold">
                                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.totalPrice)}
                                            </span>
                                        </div>
                                    </div>
                                </motion.div>
                            ))}
                        </AnimatePresence>
                        {!order?.items.length && (
                            <div className="text-xs text-muted-foreground text-center mt-8">
                                No items in the bin. Search and add products from the left.
                            </div>
                        )}
                    </div>

                    <div className="space-y-4 border-t border-border pt-8 mt-auto">
                        <div className="flex justify-between text-muted-foreground text-[10px] uppercase tracking-widest font-heading">
                            <span>Subtotal</span>
                            <span>
                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                            </span>
                        </div>
                        <div className="flex justify-between text-2xl font-heading pt-4 text-foreground">
                            <span className="tracking-tighter uppercase">Total</span>
                            <span className="text-gold">
                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                            </span>
                        </div>

                        <div className="mt-6 flex gap-2 text-[9px] font-heading uppercase tracking-[0.2em]">
                            <button
                                type="button"
                                onClick={() => setPaymentMethod('CASH')}
                                className={`flex-1 py-2 rounded-full border ${
                                    paymentMethod === 'CASH'
                                        ? 'border-gold bg-gold/10 text-gold'
                                        : 'border-border text-muted-foreground'
                                }`}
                            >
                                Cash
                            </button>
                            <button
                                type="button"
                                onClick={() => setPaymentMethod('QR')}
                                className={`flex-1 py-2 rounded-full border flex items-center justify-center gap-1 ${
                                    paymentMethod === 'QR'
                                        ? 'border-gold bg-gold/10 text-gold'
                                        : 'border-border text-muted-foreground'
                                }`}
                            >
                                <QrCode className="w-3 h-3" />
                                QR Pay
                            </button>
                        </div>

                        <div className="grid grid-cols-2 gap-4 mt-6">
                            <button
                                className="py-4 glass border-border rounded-2xl font-heading text-[9px] uppercase tracking-[0.2em] hover:border-gold/50 transition-all flex flex-col items-center gap-2"
                                disabled
                            >
                                <Receipt className="w-4 h-4 text-gold" />
                                Hold
                            </button>
                            {paymentMethod === 'CASH' ? (
                                <button
                                    onClick={handlePayCash}
                                    disabled={!order || !order.items.length || paying}
                                    className="py-4 bg-gold text-primary-foreground font-heading font-bold rounded-2xl text-[9px] uppercase tracking-[0.2em] hover:scale-[1.02] active:scale-95 transition-all shadow-xl shadow-gold/20 flex flex-col items-center gap-2 disabled:opacity-50"
                                >
                                    <CreditCard className="w-4 h-4" />
                                    {paying ? 'Processing…' : 'Charge Cash'}
                                </button>
                            ) : (
                                <button
                                    onClick={handleCreateQrPayment}
                                    disabled={!order || !order.items.length || paying}
                                    className="py-4 bg-gold text-primary-foreground font-heading font-bold rounded-2xl text-[9px] uppercase tracking-[0.2em] hover:scale-[1.02] active:scale-95 transition-all shadow-xl shadow-gold/20 flex flex-col items-center gap-2 disabled:opacity-50"
                                >
                                    <QrCode className="w-4 h-4" />
                                    {paying ? 'Generating…' : qrPayment ? 'Show QR Again' : 'Generate QR'}
                                </button>
                            )}
                        </div>

                        {paymentMethod === 'QR' && qrPayment && (
                            <div className="mt-6 space-y-2 text-[10px]">
                                <p className="font-heading uppercase tracking-[0.2em] text-muted-foreground">
                                    Scan QR in your banking app or open PayOS checkout:
                                </p>
                                <a
                                    href={qrPayment.checkoutUrl}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="inline-flex items-center justify-center px-4 py-2 rounded-full border border-gold text-gold text-[9px] font-heading uppercase tracking-[0.2em] hover:bg-gold/10"
                                >
                                    Open PayOS Checkout
                                </a>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </AuthGuard>
    );
}

