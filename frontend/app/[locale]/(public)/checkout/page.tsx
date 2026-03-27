'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import { useTranslations, useLocale } from 'next-intl';
import { Link, useRouter } from '@/lib/i18n';
import { useParams } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import QRCode from 'qrcode';
import {
    ArrowLeft, ArrowRight, CreditCard, Wallet,
    MapPin, Phone, Loader2, Download, Tag, Check, X, User
} from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { cartService } from '@/services/cart.service';
import { orderService } from '@/services/order.service';
import { paymentService, type PayOSPaymentResponse } from '@/services/payment.service';
import { promotionService, type PromotionValidationResponse } from '@/services/promotion.service';
import { loyaltyService } from '@/services/loyalty.service';
import {
    ghnService,
    type GHNProvince,
    type GHNDistrict,
    type GHNWard,
    type GHNService,
} from '@/services/ghn.service';

type PaymentMethod = 'COD' | 'ONLINE' | null;

// QR Code Canvas Component
function QRCodeCanvas({ qrCodeValue }: { qrCodeValue: string }) {
    const t = useTranslations('checkout');
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
                {t('download_qr')}
            </button>
        </div>
    );
}

export default function CheckoutPage() {
    const t = useTranslations('checkout');
    const locale = useLocale();
    const router = useRouter();
    const { isAuthenticated } = useAuth();
    const [step, setStep] = useState(1);
    const [cartItems, setCartItems] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [shippingAddress, setShippingAddress] = useState('');
    const [recipientName, setRecipientName] = useState('');
    const [phone, setPhone] = useState('');
    const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>(null);
    const [orderId, setOrderId] = useState<string | null>(null);
    const [paymentData, setPaymentData] = useState<PayOSPaymentResponse | null>(null);

    // GHN address & shipping
    const [ghnEnabled, setGhnEnabled] = useState(false);
    const [provinces, setProvinces] = useState<GHNProvince[]>([]);
    const [districts, setDistricts] = useState<GHNDistrict[]>([]);
    const [wards, setWards] = useState<GHNWard[]>([]);
    const [services, setServices] = useState<GHNService[]>([]);
    const [provinceId, setProvinceId] = useState<number | null>(null);
    const [districtId, setDistrictId] = useState<number | null>(null);
    const [wardCode, setWardCode] = useState<string>('');
    const [selectedServiceId, setSelectedServiceId] = useState<number | null>(null);
    const [shippingFee, setShippingFee] = useState(0);
    const [loadingFee, setLoadingFee] = useState(false);
    const [feeError, setFeeError] = useState<string | null>(null);

    // Promotion states
    const [couponCode, setCouponCode] = useState('');
    const [appliedCoupon, setAppliedCoupon] = useState<PromotionValidationResponse | null>(null);
    const [isApplyingCoupon, setIsApplyingCoupon] = useState(false);
    const [couponError, setCouponError] = useState<string | null>(null);

    // Loyalty states
    const [loyaltyInfo, setLoyaltyInfo] = useState({ points: 0 });
    const [usePoints, setUsePoints] = useState(false);
    const [pointsToUse, setPointsToUse] = useState(0);

    useEffect(() => {
        if (!isAuthenticated) {
            router.replace('/login');
            return;
        }
        cartService.getCart().then((c) => {
            setCartItems(c.items);
            setLoading(false);
        }).catch(() => setLoading(false));

        loyaltyService.getStatus().then(setLoyaltyInfo);

        ghnService.isConfigured().then((r) => {
            if (r.configured) {
                setGhnEnabled(true);
                ghnService.getProvinces().then(setProvinces).catch(() => setProvinces([]));
            }
        }).catch(() => {});
    }, [isAuthenticated, router]);

    useEffect(() => {
        if (!provinceId) {
            setDistricts([]);
            setDistrictId(null);
            return;
        }
        ghnService.getDistricts(provinceId).then(setDistricts).catch(() => setDistricts([]));
        setDistrictId(null);
        setWardCode('');
        setWards([]);
        setServices([]);
        setSelectedServiceId(null);
        setShippingFee(0);
    }, [provinceId]);

    useEffect(() => {
        if (!districtId) {
            setWards([]);
            setWardCode('');
            setServices([]);
            setSelectedServiceId(null);
            setShippingFee(0);
            return;
        }
        ghnService.getWards(districtId).then(setWards).catch(() => setWards([]));
        ghnService.getServices(districtId).then((s) => {
            setServices(s);
            if (s.length > 0) setSelectedServiceId(s[0].service_id);
            else setSelectedServiceId(null);
        }).catch(() => setServices([]));
        setWardCode('');
        setShippingFee(0);
    }, [districtId]);

    const calculateFee = useCallback(async () => {
        if (!districtId || !wardCode || !selectedServiceId) return;
        setLoadingFee(true);
        setFeeError(null);
        try {
            const res = await ghnService.calculateFee({
                toDistrictId: districtId,
                toWardCode: wardCode,
                serviceId: selectedServiceId,
                weight: 500,
            });
            setShippingFee(res.total ?? 0);
        } catch (e: any) {
            setFeeError(e.message || 'Không thể tính phí');
            setShippingFee(0);
        } finally {
            setLoadingFee(false);
        }
    }, [districtId, wardCode, selectedServiceId]);

    useEffect(() => {
        if (districtId && wardCode && selectedServiceId) {
            calculateFee();
        } else {
            setShippingFee(0);
        }
    }, [districtId, wardCode, selectedServiceId, calculateFee]);

    const subtotal = cartItems.reduce((acc, i) => acc + i.variant.price * i.quantity, 0);
    const couponDiscount = appliedCoupon ? appliedCoupon.discountAmount : 0;
    const loyaltyDiscount = usePoints ? pointsToUse * 500 : 0; // matching REDEEM_VALUE in backend
    const total = Math.max(0, subtotal - couponDiscount - loyaltyDiscount + shippingFee);

    const canProceedStep1 = ghnEnabled
        ? Boolean(recipientName.trim() && phone.trim() && shippingAddress.trim() && provinceId && districtId && wardCode && selectedServiceId)
        : Boolean(shippingAddress.trim() && phone.trim());

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

    const handleCreateOrderIfNeeded = async (method: PaymentMethod): Promise<string | null> => {
        if (orderId) return orderId;

        if (!canProceedStep1) {
            alert(t('error_missing_info'));
            return null;
        }

        setSubmitting(true);
        try {
            const order = await orderService.create({
                shippingAddress: shippingAddress.trim(),
                recipientName: recipientName.trim() || undefined,
                phone: phone.trim(),
                promotionCode: appliedCoupon?.code,
                redeemPoints: usePoints ? pointsToUse : undefined,
                paymentMethod: method ?? undefined,
                ...(ghnEnabled && provinceId && districtId && wardCode && selectedServiceId
                    ? {
                        shippingProvinceId: provinceId,
                        shippingDistrictId: districtId,
                        shippingWardCode: wardCode,
                        shippingServiceId: selectedServiceId,
                        shippingFee,
                    }
                    : {}),
            });
            setOrderId(order.id);
            return order.id;
        } catch (e: any) {
            alert(e.response?.data?.message || e.message || 'Có lỗi xảy ra khi tạo đơn hàng');
            return null;
        } finally {
            setSubmitting(false);
        }
    };

    const handlePaymentMethodSelect = async (method: PaymentMethod) => {
        setPaymentMethod(method);
        const currentOrderId = await handleCreateOrderIfNeeded(method);
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
                alert(e.message || t('error_create_payment'));
            } finally {
                setSubmitting(false);
            }
        }
    };

    return (
        <div className="min-h-screen bg-background transition-colors">
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
                                {t('return_to_cart')}
                            </Link>

                            <h1 className="text-5xl md:text-7xl font-serif text-luxury-black dark:text-white mb-16 tracking-tighter">
                                {t('page_title_part1')} <span className="italic">{t('page_title_part2')}</span>
                            </h1>

                            <AnimatePresence mode="wait">
                                {/* Step 1: Shipping Information */}
                                {step === 1 && (
                                    <motion.div
                                        key="step1"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: -20 }}
                                        className="space-y-10"
                                    >
                                        {ghnEnabled && (
                                            <div className="space-y-3">
                                                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2 flex items-center gap-2">
                                                    <User size={14} />
                                                    {t('recipient_name')} *
                                                </label>
                                                <input
                                                    type="text"
                                                    value={recipientName}
                                                    onChange={(e) => setRecipientName(e.target.value)}
                                                    className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                    placeholder={t('name_placeholder')}
                                                />
                                            </div>
                                        )}

                                        {ghnEnabled && (
                                            <>
                                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                                    <div className="space-y-2">
                                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t('select_province')} *</label>
                                                    <select
                                                            value={provinceId ?? ''}
                                                            onChange={(e) => setProvinceId(e.target.value ? Number(e.target.value) : null)}
                                                            className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] px-5 py-4 outline-none focus:border-gold text-sm text-luxury-black dark:text-white"
                                                        >
                                                        <option value="">{t('select_province')}</option>
                                                            {provinces.map((p) => (
                                                                <option key={p.ProvinceID} value={p.ProvinceID}>{p.ProvinceName}</option>
                                                            ))}
                                                        </select>
                                                    </div>
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t('select_district')} *</label>
                                                        <select
                                                            value={districtId ?? ''}
                                                            onChange={(e) => setDistrictId(e.target.value ? Number(e.target.value) : null)}
                                                            disabled={!provinceId}
                                                            className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] px-5 py-4 outline-none focus:border-gold text-sm text-luxury-black dark:text-white disabled:opacity-50"
                                                        >
                                                            <option value="">{t('select_district')}</option>
                                                            {districts.map((d) => (
                                                                <option key={d.DistrictID} value={d.DistrictID}>{d.DistrictName}</option>
                                                            ))}
                                                        </select>
                                                    </div>
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t('select_ward')} *</label>
                                                        <select
                                                            value={wardCode}
                                                            onChange={(e) => setWardCode(e.target.value)}
                                                            disabled={!districtId}
                                                            className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] px-5 py-4 outline-none focus:border-gold text-sm text-luxury-black dark:text-white disabled:opacity-50"
                                                        >
                                                            <option value="">{t('select_ward')}</option>
                                                            {wards.map((w) => (
                                                                <option key={w.WardCode} value={w.WardCode}>{w.WardName}</option>
                                                            ))}
                                                        </select>
                                                    </div>
                                                </div>

                                                {services.length > 1 && (
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2">{t('shipping_service')}</label>
                                                        <select
                                                            value={selectedServiceId ?? ''}
                                                            onChange={(e) => setSelectedServiceId(e.target.value ? Number(e.target.value) : null)}
                                                            className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] px-5 py-4 outline-none focus:border-gold text-sm text-luxury-black dark:text-white"
                                                        >
                                                            {services.map((s) => (
                                                                <option key={s.service_id} value={s.service_id}>{s.short_name}</option>
                                                            ))}
                                                        </select>
                                                    </div>
                                                )}

                                                {(wardCode && selectedServiceId) && (
                                                    <div className="flex items-center gap-3 py-2">
                                                        {loadingFee ? (
                                                            <Loader2 size={18} className="animate-spin text-gold" />
                                                        ) : feeError ? (
                                                            <span className="text-[10px] text-red-500 font-bold uppercase">{feeError}</span>
                                                        ) : (
                                                            <span className="text-[10px] font-bold uppercase text-gold tracking-widest">
                                                                {t('shipping_fee')}: {new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(shippingFee)}
                                                            </span>
                                                        )}
                                                    </div>
                                                )}
                                            </>
                                        )}

                                        <div className="space-y-3">
                                            <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2 flex items-center gap-2">
                                                <MapPin size={14} />
                                                {ghnEnabled ? t('street_name') + ' *' : t('shipping_address') + ' *'}
                                            </label>
                                            <input
                                                type="text"
                                                value={shippingAddress}
                                                onChange={(e) => setShippingAddress(e.target.value)}
                                                className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                placeholder={ghnEnabled ? t('street_placeholder') : t('shipping_placeholder')}
                                            />
                                        </div>

                                        <div className="space-y-3">
                                            <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 pl-2 flex items-center gap-2">
                                                <Phone size={14} />
                                                {t('phone_number')} *
                                            </label>
                                            <input
                                                type="tel"
                                                value={phone}
                                                onChange={(e) => setPhone(e.target.value)}
                                                className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/10 rounded-[2rem] p-6 outline-none focus:border-gold transition-all text-sm text-luxury-black dark:text-white"
                                                placeholder={t('phone_placeholder')}
                                            />
                                        </div>

                                        <button
                                            onClick={() => setStep(2)}
                                            disabled={!canProceedStep1}
                                            className="w-full py-6 bg-gold-btn-gradient text-white rounded-full font-bold tracking-[.4em] uppercase text-[10px] shadow-2xl hover:scale-[1.02] active:scale-95 transition-all group disabled:opacity-50 disabled:cursor-not-allowed"
                                        >
                                            {t('continue_to_payment')}
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
                                            {t('select_payment_method')}
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
                                                    {t('cod')}
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
                                                    {t('online_payment')}
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
                                            {t('return_to_cart')}
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
                                                {t('qr_scan')}
                                            </h2>
                                            <p className="text-sm text-stone-400">
                                                {t('qr_desc')}
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
                                                <span>{t('waiting_confirmation')}</span>
                                            </div>
                                        </div>

                                        <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-2xl p-6">
                                            <p className="text-sm text-blue-800 dark:text-blue-200 text-center mb-4">
                                                <strong>{t('pay_via_payos_desc')}</strong>
                                            </p>
                                            <a
                                                href={paymentData.checkoutUrl || '#'}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="block w-full py-4 bg-gold text-white rounded-full font-bold tracking-[.3em] uppercase text-[10px] text-center hover:bg-gold/90 transition-all"
                                            >
                                                {t('pay_via_payos')}
                                                <ArrowRight size={16} className="inline ml-2" />
                                            </a>
                                        </div>

                                        <button
                                            onClick={() => setStep(2)}
                                            className="w-full py-4 border border-stone-200 dark:border-white/10 rounded-full font-bold tracking-[.3em] uppercase text-[10px] text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all"
                                        >
                                            {t('other_method')}
                                        </button>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>

                        {/* Order Summary Sidebar */}
                        <div className="w-full lg:w-[450px] sticky top-40 order-1 lg:order-2">
                            <div className="bg-white dark:bg-zinc-900 rounded-[4rem] p-12 border border-stone-100 dark:border-white/5 shadow-2xl">
                                <h3 className="text-2xl font-serif text-luxury-black dark:text-white uppercase tracking-[.2em] mb-12 pb-8 border-b border-stone-100 dark:border-white/5 italic">
                                    {t('order_summary')}
                                </h3>

                                <div className="space-y-10 mb-12 max-h-[50vh] overflow-y-auto">
                                    {loading ? (
                                        <div className="py-8 text-center text-stone-400 text-sm">{t('loading')}</div>
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
                                                {t('empty_cart')}
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
                                                placeholder={t('coupon_code')}
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
                                                {t('apply')}
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
                                            <Tag size={12} /> {t('coupon_success', { amount: new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(appliedCoupon.discountAmount) })}
                                        </p>
                                    )}

                                    {loyaltyInfo.points >= 100 && (
                                        <div className="mt-8 pt-6 border-t border-stone-100 dark:border-white/5">
                                            <label className="flex items-center gap-4 cursor-pointer group">
                                                <div className="relative">
                                                    <input
                                                        type="checkbox"
                                                        checked={usePoints}
                                                        onChange={(e) => {
                                                            setUsePoints(e.target.checked);
                                                            if (e.target.checked) setPointsToUse(Math.min(loyaltyInfo.points, Math.floor((subtotal - couponDiscount) / 500)));
                                                        }}
                                                        className="sr-only"
                                                    />
                                                    <div className={`w-10 h-6 rounded-full transition-colors ${usePoints ? 'bg-gold' : 'bg-stone-200 dark:bg-zinc-800'}`} />
                                                    <div className={`absolute left-1 top-1 w-4 h-4 bg-white rounded-full transition-transform ${usePoints ? 'translate-x-4' : ''}`} />
                                                </div>
                                                <div className="flex-1">
                                                    <p className="text-[10px] font-bold uppercase tracking-widest text-luxury-black dark:text-white">
                                                        {t('loyalty_points')}
                                                    </p>
                                                    <p className="text-[8px] text-stone-400 uppercase tracking-tighter">
                                                        {t('points_balance', { points: loyaltyInfo.points, value: new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(loyaltyInfo.points * 500) })}
                                                    </p>
                                                </div>
                                            </label>

                                            {usePoints && (
                                                <motion.div
                                                    initial={{ height: 0, opacity: 0 }}
                                                    animate={{ height: 'auto', opacity: 1 }}
                                                    className="mt-4 pl-14"
                                                >
                                                    <div className="flex items-center gap-4">
                                                        <input
                                                            type="number"
                                                            value={pointsToUse}
                                                            onChange={(e) => setPointsToUse(Math.min(loyaltyInfo.points, Number(e.target.value)))}
                                                            className="w-24 h-10 bg-stone-50 dark:bg-zinc-950 border border-stone-100 dark:border-white/5 rounded-xl px-4 text-xs font-bold outline-none border-gold"
                                                        />
                                                        <span className="text-[10px] text-stone-400 uppercase font-bold">{t('points_discount', { amount: new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(pointsToUse * 500) })}</span>
                                                    </div>
                                                </motion.div>
                                            )}
                                        </div>
                                    )}
                                </div>

                                <div className="space-y-6 pt-12 border-t border-stone-100 dark:border-white/5">
                                    <div className="space-y-4">
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>{t('subtotal')}</span>
                                            <span className="text-luxury-black dark:text-white">
                                                {new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(subtotal)}
                                            </span>
                                        </div>
                                        {appliedCoupon && (
                                            <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-green-500">
                                                <span>{t('coupon_code')}</span>
                                                <span className="">
                                                    -{new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(couponDiscount)}
                                                </span>
                                            </div>
                                        )}
                                        {usePoints && loyaltyDiscount > 0 && (
                                            <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-gold text-amber-500">
                                                <span>{t('loyalty_points')}</span>
                                                <span className="">
                                                    -{new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(loyaltyDiscount)}
                                                </span>
                                            </div>
                                        )}
                                        <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest text-stone-400">
                                            <span>{t('shipping_fee')}</span>
                                            <span className={shippingFee > 0 ? 'text-luxury-black dark:text-white' : 'text-gold'}>
                                                {ghnEnabled && shippingFee > 0
                                                    ? new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(shippingFee)
                                                    : t('shipping_free')}
                                            </span>
                                        </div>
                                    </div>

                                    <div className="pt-8 mt-6 flex justify-between items-center border-t border-stone-100 dark:border-white/10">
                                        <span className="text-[10px] font-bold tracking-[.5em] uppercase text-stone-400">
                                            {t('total')}
                                        </span>
                                        <span className="text-4xl font-serif text-luxury-black dark:text-white italic">
                                            {new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', { style: 'currency', currency: 'VND' }).format(total)}
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
