'use client';

import { useState, useEffect, useRef } from 'react';
import { Link, useRouter } from '@/lib/i18n';
import { motion, AnimatePresence } from 'framer-motion';
import QRCode from 'qrcode';
import {
    ArrowLeft, ArrowRight, CreditCard, Wallet, QrCode,
    MapPin, Phone, Loader2, Download, Tag, Check, X
} from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { cartService } from '@/services/cart.service';
import { orderService } from '@/services/order.service';
import { paymentService, type PayOSPaymentResponse } from '@/services/payment.service';
import { promotionService, type PromotionValidationResponse } from '@/services/promotion.service';

type PaymentMethod = 'COD' | 'ONLINE' | null;

// QR Code Canvas Component
function QRCodeCanvas({ qrCodeValue }: { qrCodeValue: string }) {
    const canvasRef = useRef<HTMLCanvasElement>(null);

    useEffect(() => {
        if (canvasRef.current && qrCodeValue) {
            QRCode.toCanvas(canvasRef.current, qrCodeValue, {
                errorCorrectionLevel: 'H',
                margin: 1,
                width: 256,
                color: {
                    dark: '#000',
                    light: '#fff',
                },
            });
        }
    }, [qrCodeValue]);

    return (
        <div className="flex flex-col items-center gap-4">
            <div className="bg-white p-4 rounded-2xl border-2 border-gold shadow-lg">
                <canvas ref={canvasRef} />
            </div>
            <button
                onClick={() => {
                    if (canvasRef.current) {
                        const link = document.createElement('a');
                        link.download = 'qr-code.png';
                        link.href = canvasRef.current.toDataURL();
                        link.click();
                    }
                }}
                className="flex items-center gap-2 text-xs text-gold hover:text-gold/80 transition"
            >
                <Download size={14} />
                Tải QR code
            </button>
        </div>
    );
}

export default function CheckoutPage() {
    const router = useRouter();
    const { isAuthenticated } = useAuth();
    const [step, setStep] = useState(1);
    const [cartItems, setCartItems] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [shippingAddress, setShippingAddress] = useState('');
    const [phone, setPhone] = useState('');
    const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>(null);
    const [orderId, setOrderId] = useState<string | null>(null);
    const [paymentData, setPaymentData] = useState<PayOSPaymentResponse | null>(null);

    // Promotion states
    const [couponCode, setCouponCode] = useState('');
    const [appliedCoupon, setAppliedCoupon] = useState<PromotionValidationResponse | null>(null);
    const [isApplyingCoupon, setIsApplyingCoupon] = useState(false);
    const [couponError, setCouponError] = useState<string | null>(null);

    useEffect(() => {
        if (!isAuthenticated) {
            router.replace('/login');
            return;
        }
        cartService.getCart().then((c) => {
            setCartItems(c.items);
            setLoading(false);
        }).catch(() => setLoading(false));
    }, [isAuthenticated, router]);

    const subtotal = cartItems.reduce((acc, i) => acc + i.variant.price * i.quantity, 0);
    const discountAmount = appliedCoupon ? appliedCoupon.discountAmount : 0;
    const total = subtotal - discountAmount;

    const handleApplyCoupon = async () => {
        if (!couponCode.trim()) return;
        setIsApplyingCoupon(true);
        setCouponError(null);
        try {
            const result = await promotionService.validate(couponCode.trim(), subtotal);
            setAppliedCoupon(result);
        } catch (e: any) {
            setCouponError(e.response?.data?.message || 'Mã giảm giá không hợp lệ');
            setAppliedCoupon(null);
        } finally {
            setIsApplyingCoupon(false);
        }
    };

    const handleRemoveCoupon = () => {
        setAppliedCoupon(null);
        setCouponCode('');
        setCouponError(null);
    };

    const handleCreateOrderIfNeeded = async (): Promise<string | null> => {
        if (orderId) return orderId;

        if (!shippingAddress.trim() || !phone.trim()) {
            alert('Vui lòng nhập đầy đủ địa chỉ và số điện thoại');
            return null;
        }

        setSubmitting(true);
        try {
            const order = await orderService.create({
                shippingAddress: shippingAddress.trim(),
                phone: phone.trim(),
                promotionCode: appliedCoupon?.code
            });
            setOrderId(order.id);
            return order.id;
        } catch (e: any) {
            alert(e.message || 'Có lỗi xảy ra khi tạo đơn hàng');
            return null;
        } finally {
            setSubmitting(false);
        }
    };

    const handlePaymentMethodSelect = async (method: PaymentMethod) => {
        setPaymentMethod(method);
        const currentOrderId = await handleCreateOrderIfNeeded();
        if (!currentOrderId) return;

        if (method === 'COD') {
            setSubmitting(true);
            // In a real app, you might confirm the COD order on the backend here
            router.push(`/checkout/success?orderId=${currentOrderId}`);
        } else if (method === 'ONLINE') {
            setSubmitting(true);
            try {
                const payment = await paymentService.createPayment(currentOrderId);
                setPaymentData(payment);
                // Move to step 3 to show the QR code
                setStep(3);
            } catch (e: any) {
                alert(e.message || 'Có lỗi xảy ra khi tạo thanh toán');
            } finally {
                setSubmitting(false);
            }
        }
    };

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
            <main className="container mx-auto px-6 py-32 lg:py-40">
                <div className="max-w-7xl mx-auto">
                    <div className="flex flex-col lg:flex-row justify-between items-start gap-16 lg:gap-24">
                        {/* Main Checkout Flow */}
                        <div className="flex-1 w-full order-2 lg:order-1">
                            <Link
                                href="/cart"
                                className="inline-flex items-center gap-3 text-[10px] font-bold tracking-[.4em] uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors mb-16 group"
                            >
                                <ArrowLeft size={16} className="group-hover:-translate-x-2 transition-transform" />
                                Quay lại giỏ hàng
                            </Link>

                            <h1 className="text-5xl md:text-7xl font-serif text-luxury-black dark:text-white mb-16 tracking-tighter">
                                Thanh <span className="italic">toán</span>
                            </h1>

                            <AnimatePresence mode="wait">
                                {/* Step 1: Shipping Information */}
                                {step === 1 && (
                                    <motion.div
                                        key="step1"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-12"
                                    >
                                        <div className="space-y-3">
                                            <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2 flex items-center gap-2">
                                                <MapPin size={14} />
                                                Địa chỉ giao hàng *
                                            </label>
                                            <input
                                                type="text"
                                                value={shippingAddress}
                                                onChange={(e) => setShippingAddress(e.target.value)}
                                                className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                placeholder="Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố"
                                                required
                                            />
                                        </div>

                                        <div className="space-y-3">
                                            <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2 flex items-center gap-2">
                                                <Phone size={14} />
                                                Số điện thoại *
                                            </label>
                                            <input
                                                type="tel"
                                                value={phone}
                                                onChange={(e) => setPhone(e.target.value)}
                                                className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                placeholder="0901234567"
                                                required
                                            />
                                        </div>

                                        <button
                                            onClick={() => setStep(2)}
                                            disabled={!shippingAddress.trim() || !phone.trim()}
                                            className="w-full py-6 bg-luxury-black dark:bg-gold text-white rounded-full font-bold tracking-[.4em] uppercase text-[10px] shadow-2xl hover:bg-stone-800 dark:hover:bg-gold/80 transition-all group disabled:opacity-50 disabled:cursor-not-allowed"
                                        >
                                            Tiếp tục đến thanh toán
                                            <ArrowRight size={16} className="inline ml-4 group-hover:translate-x-2 transition-transform" />
                                        </button>
                                    </motion.div>
                                )}

                                {/* Step 2: Payment Method */}
                                {step === 2 && (
                                    <motion.div
                                        key="step2"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-8"
                                    >
                                        <h2 className="text-2xl font-serif text-luxury-black dark:text-white mb-8">
                                            Chọn phương thức thanh toán
                                        </h2>

                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                            {/* COD */}
                                            <button
                                                onClick={() => handlePaymentMethodSelect('COD')}
                                                disabled={submitting}
                                                className="p-8 rounded-[2rem] border-2 border-stone-200 dark:border-white/10 bg-white dark:bg-zinc-900 flex flex-col items-center gap-4 text-center hover:border-gold transition-all group disabled:opacity-50"
                                            >
                                                {submitting && paymentMethod === 'COD' ? <Loader2 className="animate-spin" /> : <Wallet className="text-gold" size={40} strokeWidth={1.5} />}
                                                <span className="text-sm font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white">
                                                    Thanh toán khi nhận hàng
                                                </span>
                                                <span className="text-[10px] text-stone-400 uppercase tracking-wider">
                                                    COD
                                                </span>
                                            </button>

                                            {/* Online */}
                                            <button
                                                onClick={() => handlePaymentMethodSelect('ONLINE')}
                                                disabled={submitting}
                                                className="p-8 rounded-[2rem] border-2 border-stone-200 dark:border-white/10 bg-white dark:bg-zinc-900 flex flex-col items-center gap-4 text-center hover:border-gold transition-all group disabled:opacity-50"
                                            >
                                                {submitting && paymentMethod === 'ONLINE' ? <Loader2 className="animate-spin" /> : <CreditCard className="text-gold" size={40} strokeWidth={1.5} />}
                                                <span className="text-sm font-bold tracking-[.2em] uppercase text-luxury-black dark:text-white">
                                                    Thanh toán online
                                                </span>
                                                <span className="text-[10px] text-stone-400 uppercase tracking-wider">
                                                    VietQR / PayOS
                                                </span>
                                            </button>
                                        </div>

                                        <button
                                            onClick={() => setStep(1)}
                                            className="w-full py-4 border border-stone-200 dark:border-white/10 rounded-full font-bold tracking-[.3em] uppercase text-[10px] text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all"
                                        >
                                            Quay lại
                                        </button>
                                    </motion.div>
                                )}

                                {/* Step 3: Online QR Code Display */}
                                {step === 3 && paymentData && (
                                    <motion.div
                                        key="online-payment"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-8"
                                    >
                                        <div className="text-center space-y-4">
                                            <h2 className="text-2xl font-serif text-luxury-black dark:text-white">
                                                Quét mã QR để thanh toán
                                            </h2>
                                            <p className="text-sm text-stone-400">
                                                Mở app ngân hàng và quét mã QR bên dưới để hoàn tất thanh toán
                                            </p>
                                        </div>

                                        <div className="flex flex-col items-center gap-6 p-12 bg-white dark:bg-zinc-900 rounded-[2rem] border border-stone-100 dark:border-white/10">
                                            {paymentData.qrCode ? (
                                                <QRCodeCanvas qrCodeValue={paymentData.qrCode} />
                                            ) : (
                                                <div className="w-64 h-64 bg-stone-100 dark:bg-zinc-800 flex items-center justify-center rounded-2xl">
                                                    <Loader2 className="w-16 h-16 text-stone-400 animate-spin" />
                                                </div>
                                            )}

                                            <div className="text-center space-y-2">
                                                <p className="text-sm font-bold text-luxury-black dark:text-white">
                                                    {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(paymentData.amount)}
                                                </p>
                                                <p className="text-[10px] text-stone-400 uppercase tracking-wider">
                                                    {paymentData.accountName}
                                                </p>
                                                <p className="text-[10px] text-stone-400 font-mono">
                                                    {paymentData.accountNumber}
                                                </p>
                                            </div>

                                            <div className="flex items-center gap-3 text-sm text-stone-400">
                                                <Loader2 className="w-4 h-4 animate-spin" />
                                                <span>Đang chờ xác nhận thanh toán...</span>
                                            </div>
                                        </div>

                                        <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-2xl p-6">
                                            <p className="text-sm text-blue-800 dark:text-blue-200 text-center mb-4">
                                                <strong>Hoặc nhấn nút bên dưới để thanh toán qua trang PayOS</strong>
                                            </p>
                                            <a
                                                href={paymentData.checkoutUrl || '#'}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="block w-full py-4 bg-gold text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] text-center hover:bg-gold/90 transition-all"
                                            >
                                                Thanh toán qua PayOS
                                                <ArrowRight size={16} className="inline ml-2" />
                                            </a>
                                        </div>

                                        <button
                                            onClick={() => setStep(2)}
                                            className="w-full py-4 border border-stone-200 dark:border-white/10 rounded-full font-bold tracking-[.3em] uppercase text-[10px] text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all"
                                        >
                                            Chọn phương thức khác
                                        </button>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>

                        {/* Order Summary Sidebar */}
                        <div className="w-full lg:w-[450px] sticky top-40 order-1 lg:order-2">
                            <div className="bg-white dark:bg-zinc-900 rounded-[4rem] p-12 border border-stone-100 dark:border-white/5 shadow-2xl">
                                <h3 className="text-2xl font-serif text-luxury-black dark:text-white uppercase tracking-[.2em] mb-12 pb-8 border-b border-stone-100 dark:border-white/5 italic">
                                    Đơn hàng
                                </h3>

                                <div className="space-y-10 mb-12 max-h-[50vh] overflow-y-auto">
                                    {loading ? (
                                        <div className="py-8 text-center text-stone-400 text-sm">Đang tải…</div>
                                    ) : cartItems.length > 0 ? (
                                        cartItems.map((item) => (
                                            <div key={item.id} className="flex gap-6 group">
                                                <div className="relative w-24 h-32 rounded-2xl overflow-hidden bg-stone-50 dark:bg-zinc-800 flex-shrink-0 border border-stone-100 dark:border-white/5">
                                                    {item.variant.product.images?.[0]?.url ? (
                                                        <img src={item.variant.product.images[0].url} alt={item.variant.product.name} className="w-full h-full object-cover" />
                                                    ) : (
                                                        <div className="w-full h-full flex items-center justify-center text-stone-500">—</div>
                                                    )}
                                                </div>
                                                <div className="flex-1">
                                                    <div className="flex justify-between items-start mb-2">
                                                        <div>
                                                            <h4 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-wider">
                                                                {item.variant.product.name}
                                                            </h4>
                                                            <p className="text-[10px] text-gold uppercase tracking-widest font-bold">
                                                                {item.variant.name}
                                                            </p>
                                                        </div>
                                                        <span className="text-sm font-medium text-luxury-black dark:text-white">
                                                            {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.variant.price * item.quantity)}
                                                        </span>
                                                    </div>
                                                    <p className="text-[10px] text-stone-400 uppercase tracking-widest italic mb-6">
                                                        × {item.quantity}
                                                    </p>
                                                </div>
                                            </div>
                                        ))
                                    ) : (
                                        <div className="py-20 text-center space-y-4 opacity-30">
                                            <p className="text-[10px] font-bold tracking-widest uppercase italic">
                                                Giỏ hàng trống
                                            </p>
                                        </div>
                                    )}
                                </div>

                                {/* Coupon Section */}
                                <div className="mt-8 pt-8 border-t border-stone-100 dark:border-white/5">
                                    <div className="flex gap-3">
                                        <div className="relative flex-1">
                                            <input
                                                type="text"
                                                value={couponCode}
                                                onChange={(e) => setCouponCode(e.target.value.toUpperCase())}
                                                placeholder="MÃ GIẢM GIÁ"
                                                disabled={!!appliedCoupon || isApplyingCoupon}
                                                className="w-full h-14 bg-stone-50 dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-2xl px-6 text-xs font-bold tracking-[.3em] uppercase focus:ring-0 focus:border-gold transition-all disabled:opacity-50"
                                            />
                                            {appliedCoupon && (
                                                <div className="absolute right-4 top-1/2 -translate-y-1/2 text-green-500">
                                                    <Check size={20} />
                                                </div>
                                            )}
                                        </div>
                                        {appliedCoupon ? (
                                            <button
                                                onClick={handleRemoveCoupon}
                                                className="h-14 aspect-square bg-stone-100 dark:bg-white/5 rounded-2xl flex items-center justify-center text-stone-400 hover:text-red-500 transition-colors"
                                            >
                                                <X size={20} />
                                            </button>
                                        ) : (
                                            <button
                                                onClick={handleApplyCoupon}
                                                disabled={!couponCode || isApplyingCoupon}
                                                className="px-8 bg-luxury-black dark:bg-white text-white dark:text-luxury-black rounded-2xl text-[10px] font-bold tracking-[.3em] uppercase hover:scale-[1.02] active:scale-95 transition-all disabled:opacity-50 flex items-center gap-3"
                                            >
                                                {isApplyingCoupon ? <Loader2 className="animate-spin" size={16} /> : <Tag size={16} />}
                                                Áp dụng
                                            </button>
                                        )}
                                    </div>
                                    {couponError && (
                                        <p className="mt-4 text-[10px] font-bold text-red-500 uppercase tracking-widest leading-relaxed">
                                            {couponError}
                                        </p>
                                    )}
                                    {appliedCoupon && (
                                        <p className="mt-4 text-[10px] font-bold text-green-500 uppercase tracking-widest leading-relaxed flex items-center gap-2">
                                            <Tag size={12} /> Áp dụng thành công: Giảm {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(appliedCoupon.discountAmount)}
                                        </p>
                                    )}
                                </div>

                                <div className="space-y-6 pt-12 border-t border-stone-100 dark:border-white/5">
                                    <div className="space-y-4">
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>Tạm tính</span>
                                            <span className="text-luxury-black dark:text-white">
                                                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                                            </span>
                                        </div>
                                        {appliedCoupon && (
                                            <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-green-500">
                                                <span>Giảm giá</span>
                                                <span className="">
                                                    -{new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(discountAmount)}
                                                </span>
                                            </div>
                                        )}
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>Phí vận chuyển</span>
                                            <span className="text-gold">Miễn phí</span>
                                        </div>
                                    </div>

                                    <div className="pt-8 mt-6 flex justify-between items-center border-t border-stone-100 dark:border-white/10">
                                        <span className="text-[10px] font-bold tracking-[.5em] uppercase text-stone-400">
                                            Tổng cộng
                                        </span>
                                        <span className="text-4xl font-serif text-luxury-black dark:text-white italic">
                                            {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total)}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
