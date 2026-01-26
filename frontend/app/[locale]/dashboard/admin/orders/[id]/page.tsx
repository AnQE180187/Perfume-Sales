'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { Link, useRouter } from '@/lib/i18n';
import { orderService, Order } from '@/services/order.service';
import {
    Package,
    ArrowLeft,
    Loader2,
    MapPin,
    Phone,
    Mail,
    Calendar,
    DollarSign,
} from 'lucide-react';

export default function AdminOrderDetailPage() {
    const router = useRouter();
    const params = useParams();
    const orderId = params?.id as string;

    const [order, setOrder] = useState<Order | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (orderId) {
            loadOrder();
        }
    }, [orderId]);

    const loadOrder = async () => {
        setLoading(true);
        try {
            const data = await orderService.getAdminById(orderId);
            setOrder(data);
        } catch (error) {
            console.error('Failed to load order:', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex items-center justify-center">
                <Loader2 className="w-8 h-8 animate-spin text-gold" />
            </div>
        );
    }

    if (!order) {
        return (
            <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 flex items-center justify-center">
                <div className="text-center">
                    <p className="text-stone-600 dark:text-stone-400 mb-4">Không tìm thấy đơn hàng</p>
                    <Link
                        href="/dashboard/admin/orders"
                        className="text-gold hover:underline font-bold"
                    >
                        Quay lại
                    </Link>
                </div>
            </div>
        );
    }

    const statusColors: Record<string, string> = {
        PENDING: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400',
        PROCESSING: 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400',
        CONFIRMED: 'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400',
        SHIPPED: 'bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-400',
        DELIVERED: 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400',
        CANCELLED: 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400',
    };

    const paymentStatusColors: Record<string, string> = {
        PENDING: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400',
        PAID: 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400',
        FAILED: 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400',
        REFUNDED: 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400',
    };

    const statusLabels: Record<string, string> = {
        PENDING: 'Chờ Xử Lý',
        PROCESSING: 'Đang Xử Lý',
        CONFIRMED: 'Đã Xác Nhận',
        SHIPPED: 'Đang Giao',
        DELIVERED: 'Đã Giao',
        CANCELLED: 'Đã Hủy',
    };

    const paymentLabels: Record<string, string> = {
        PENDING: 'Chờ Thanh Toán',
        PAID: 'Đã Thanh Toán',
        FAILED: 'Thanh Toán Thất Bại',
        REFUNDED: 'Đã Hoàn Tiền',
    };

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950">
            <div className="container mx-auto px-6 py-8">
                {/* Header */}
                <div className="mb-8">
                    <Link
                        href="/dashboard/admin/orders"
                        className="inline-flex items-center gap-2 text-gold hover:text-gold/80 transition mb-4"
                    >
                        <ArrowLeft size={20} />
                        Quay Lại
                    </Link>

                    <div className="flex items-center gap-3">
                        <Package className="text-gold" size={32} />
                        <h1 className="text-4xl font-serif text-luxury-black dark:text-white">
                            Chi Tiết Đơn Hàng
                        </h1>
                    </div>
                </div>

                {/* Order Info */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    {/* Order Code & Status */}
                    <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-stone-100 dark:border-white/10">
                        <p className="text-xs uppercase tracking-wider text-stone-600 dark:text-stone-400 mb-2">
                            Mã Đơn Hàng
                        </p>
                        <p className="text-2xl font-mono font-bold text-luxury-black dark:text-white mb-4">
                            {order.code}
                        </p>
                        <div className="space-y-2">
                            <div>
                                <p className="text-xs uppercase tracking-wider text-stone-600 dark:text-stone-400 mb-1">
                                    Trạng Thái Đơn
                                </p>
                                <span
                                    className={`inline-block text-xs font-bold px-3 py-1 rounded-full ${statusColors[order.status] || statusColors.PENDING
                                        }`}
                                >
                                    {statusLabels[order.status] || order.status}
                                </span>
                            </div>
                            <div>
                                <p className="text-xs uppercase tracking-wider text-stone-600 dark:text-stone-400 mb-1">
                                    Trạng Thái Thanh Toán
                                </p>
                                <span
                                    className={`inline-block text-xs font-bold px-3 py-1 rounded-full ${paymentStatusColors[order.paymentStatus] ||
                                        paymentStatusColors.PENDING
                                        }`}
                                >
                                    {paymentLabels[order.paymentStatus] || order.paymentStatus}
                                </span>
                            </div>
                        </div>
                    </div>

                    {/* Customer Info */}
                    <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-stone-100 dark:border-white/10">
                        <p className="text-xs uppercase tracking-wider text-stone-600 dark:text-stone-400 mb-4">
                            Thông Tin Khách Hàng
                        </p>
                        <div className="space-y-3">
                            <div className="flex gap-3">
                                <Mail size={18} className="text-gold flex-shrink-0 mt-0.5" />
                                <div>
                                    <p className="text-xs text-stone-600 dark:text-stone-400">Email</p>
                                    <p className="text-sm font-bold text-luxury-black dark:text-white">
                                        {order.user?.email}
                                    </p>
                                </div>
                            </div>
                            <div className="flex gap-3">
                                <Phone size={18} className="text-gold flex-shrink-0 mt-0.5" />
                                <div>
                                    <p className="text-xs text-stone-600 dark:text-stone-400">Số Điện Thoại</p>
                                    <p className="text-sm font-bold text-luxury-black dark:text-white">
                                        {order.phone}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Amount Info */}
                    <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-stone-100 dark:border-white/10">
                        <p className="text-xs uppercase tracking-wider text-stone-600 dark:text-stone-400 mb-4">
                            Thông Tin Thanh Toán
                        </p>
                        <div className="space-y-3">
                            <div>
                                <p className="text-xs text-stone-600 dark:text-stone-400 mb-1">
                                    Tổng Tiền Hàng
                                </p>
                                <p className="text-xl font-bold text-luxury-black dark:text-white">
                                    {new Intl.NumberFormat('vi-VN', {
                                        style: 'currency',
                                        currency: 'VND',
                                    }).format(order.totalAmount)}
                                </p>
                            </div>
                            {order.discountAmount > 0 && (
                                <div>
                                    <p className="text-xs text-stone-600 dark:text-stone-400 mb-1">
                                        Giảm Giá
                                    </p>
                                    <p className="text-lg font-bold text-red-600">
                                        -{' '}
                                        {new Intl.NumberFormat('vi-VN', {
                                            style: 'currency',
                                            currency: 'VND',
                                        }).format(order.discountAmount)}
                                    </p>
                                </div>
                            )}
                            <div className="pt-3 border-t border-stone-200 dark:border-white/10">
                                <p className="text-xs text-stone-600 dark:text-stone-400 mb-1">
                                    Tổng Thanh Toán
                                </p>
                                <p className="text-2xl font-bold text-gold">
                                    {new Intl.NumberFormat('vi-VN', {
                                        style: 'currency',
                                        currency: 'VND',
                                    }).format(order.finalAmount)}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Shipping Address */}
                <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-stone-100 dark:border-white/10 mb-8">
                    <div className="flex items-center gap-3 mb-4">
                        <MapPin className="text-gold" size={20} />
                        <h2 className="text-xl font-serif font-bold text-luxury-black dark:text-white">
                            Địa Chỉ Giao Hàng
                        </h2>
                    </div>
                    <p className="text-sm text-luxury-black dark:text-white">
                        {order.shippingAddress}
                    </p>
                </div>

                {/* Order Items */}
                <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-stone-100 dark:border-white/10">
                    <h2 className="text-xl font-serif font-bold text-luxury-black dark:text-white mb-6">
                        Danh Sách Sản Phẩm
                    </h2>

                    {order.items && order.items.length > 0 ? (
                        <div className="space-y-4">
                            {order.items.map((item) => (
                                <div
                                    key={item.productId}
                                    className="flex justify-between items-center p-4 rounded-lg bg-stone-50 dark:bg-zinc-800 border border-stone-100 dark:border-white/10"
                                >
                                    <div className="flex-1">
                                        <p className="font-bold text-luxury-black dark:text-white mb-1">
                                            {item.product?.name}
                                        </p>
                                        <p className="text-sm text-stone-600 dark:text-stone-400">
                                            Số lượng: {item.quantity} × {' '}
                                            {new Intl.NumberFormat('vi-VN', {
                                                style: 'currency',
                                                currency: 'VND',
                                            }).format(item.unitPrice)}
                                        </p>
                                    </div>
                                    <div className="text-right">
                                        <p className="font-bold text-luxury-black dark:text-white">
                                            {new Intl.NumberFormat('vi-VN', {
                                                style: 'currency',
                                                currency: 'VND',
                                            }).format(item.totalPrice)}
                                        </p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    ) : (
                        <p className="text-stone-600 dark:text-stone-400">Không có sản phẩm</p>
                    )}
                </div>

                {/* Footer */}
                <div className="mt-8 text-sm text-stone-600 dark:text-stone-400 grid grid-cols-2 gap-4">
                    <div>
                        <Calendar size={16} className="inline mr-2" />
                        Ngày tạo: {new Date(order.createdAt || '').toLocaleString('vi-VN')}
                    </div>
                    <div className="text-right">
                        Cập nhật: {new Date(order.updatedAt || '').toLocaleString('vi-VN')}
                    </div>
                </div>
            </div>
        </div>
    );
}
