'use client';

import { useState, useEffect } from 'react';
import { Link } from '@/lib/i18n';
import { orderService, Order, OrderListResponse } from '@/services/order.service';
import {
    Package,
    Eye,
    ChevronLeft,
    ChevronRight,
    Loader2,
    Search,
    Filter,
} from 'lucide-react';

export default function AdminOrdersPage() {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [pagination, setPagination] = useState({ skip: 0, take: 10, total: 0, pages: 0 });
    const [search, setSearch] = useState('');
    const [filterStatus, setFilterStatus] = useState<string | null>(null);

    const loadOrders = async (skip: number) => {
        setLoading(true);
        try {
            const response = await orderService.listAll(skip, pagination.take);
            setOrders(response.data);
            setPagination({
                skip,
                take: response.take,
                total: response.total,
                pages: response.pages,
            });
        } catch (error) {
            console.error('Failed to load orders:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadOrders(0);
    }, []);

    const filteredOrders = orders.filter((order) => {
        const matchesSearch =
            order.code.toLowerCase().includes(search.toLowerCase()) ||
            order.user?.email?.toLowerCase().includes(search.toLowerCase()) ||
            order.user?.name?.toLowerCase().includes(search.toLowerCase());

        const matchesStatus = !filterStatus || order.status === filterStatus;

        return matchesSearch && matchesStatus;
    });

    const currentPage = Math.floor(pagination.skip / pagination.take) + 1;

    return (
        <div className="min-h-screen bg-stone-50 dark:bg-zinc-950">
            <div className="container mx-auto px-6 py-8">
                {/* Header */}
                <div className="mb-8">
                    <div className="flex items-center gap-3 mb-4">
                        <Package className="text-gold" size={32} />
                        <h1 className="text-4xl font-serif text-luxury-black dark:text-white">
                            Quản Lý Đơn Hàng
                        </h1>
                    </div>
                    <p className="text-stone-600 dark:text-stone-400">
                        Tổng số đơn hàng: <span className="font-bold text-gold">{pagination.total}</span>
                    </p>
                </div>

                {/* Filters */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
                    <div className="relative">
                        <Search className="absolute left-3 top-3 text-stone-400" size={20} />
                        <input
                            type="text"
                            placeholder="Tìm kiếm mã đơn, email, tên..."
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            className="w-full pl-10 pr-4 py-2 rounded-lg border border-stone-200 dark:border-white/10 bg-white dark:bg-zinc-900 text-luxury-black dark:text-white placeholder-stone-400"
                        />
                    </div>

                    <div className="flex items-center gap-2">
                        <Filter size={20} className="text-stone-400" />
                        <select
                            value={filterStatus || ''}
                            onChange={(e) => setFilterStatus(e.target.value || null)}
                            className="flex-1 px-4 py-2 rounded-lg border border-stone-200 dark:border-white/10 bg-white dark:bg-zinc-900 text-luxury-black dark:text-white"
                        >
                            <option value="">Tất cả trạng thái</option>
                            <option value="PENDING">Đang chờ xử lý</option>
                            <option value="PROCESSING">Đang xử lý</option>
                            <option value="CONFIRMED">Đã xác nhận</option>
                            <option value="SHIPPED">Đang giao</option>
                            <option value="DELIVERED">Đã giao</option>
                            <option value="CANCELLED">Đã hủy</option>
                        </select>
                    </div>

                    <div className="text-right text-sm text-stone-600 dark:text-stone-400">
                        Hiển thị {filteredOrders.length} của {pagination.total}
                    </div>
                </div>

                {/* Table */}
                <div className="bg-white dark:bg-zinc-900 rounded-2xl border border-stone-100 dark:border-white/10 overflow-hidden">
                    {loading ? (
                        <div className="flex items-center justify-center py-20">
                            <Loader2 className="w-8 h-8 animate-spin text-gold" />
                        </div>
                    ) : filteredOrders.length === 0 ? (
                        <div className="py-20 text-center text-stone-400">
                            <Package size={48} className="mx-auto mb-4 opacity-50" />
                            <p>Không có đơn hàng</p>
                        </div>
                    ) : (
                        <div className="overflow-x-auto">
                            <table className="w-full">
                                <thead>
                                    <tr className="border-b border-stone-100 dark:border-white/10 bg-stone-50 dark:bg-zinc-800">
                                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-stone-600 dark:text-stone-400">
                                            Mã Đơn
                                        </th>
                                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-stone-600 dark:text-stone-400">
                                            Khách Hàng
                                        </th>
                                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-stone-600 dark:text-stone-400">
                                            Tổng Tiền
                                        </th>
                                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-stone-600 dark:text-stone-400">
                                            Thanh Toán
                                        </th>
                                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-stone-600 dark:text-stone-400">
                                            Trạng Thái
                                        </th>
                                        <th className="px-6 py-4 text-left text-xs font-bold uppercase tracking-wider text-stone-600 dark:text-stone-400">
                                            Ngày Tạo
                                        </th>
                                        <th className="px-6 py-4 text-center text-xs font-bold uppercase tracking-wider text-stone-600 dark:text-stone-400">
                                            Hành Động
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {filteredOrders.map((order) => (
                                        <tr
                                            key={order.id}
                                            className="border-b border-stone-100 dark:border-white/10 hover:bg-stone-50 dark:hover:bg-zinc-800 transition"
                                        >
                                            <td className="px-6 py-4">
                                                <span className="font-mono text-sm font-bold text-luxury-black dark:text-white">
                                                    {order.code}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div>
                                                    <p className="text-sm font-bold text-luxury-black dark:text-white">
                                                        {order.user?.name || 'N/A'}
                                                    </p>
                                                    <p className="text-xs text-stone-500 dark:text-stone-400">
                                                        {order.user?.email}
                                                    </p>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4">
                                                <span className="text-sm font-bold text-luxury-black dark:text-white">
                                                    {new Intl.NumberFormat('vi-VN', {
                                                        style: 'currency',
                                                        currency: 'VND',
                                                    }).format(order.finalAmount)}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <span
                                                    className={`text-xs font-bold px-3 py-1 rounded-full ${order.paymentStatus === 'PAID'
                                                            ? 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400'
                                                            : order.paymentStatus === 'PENDING'
                                                                ? 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400'
                                                                : 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400'
                                                        }`}
                                                >
                                                    {order.paymentStatus === 'PAID'
                                                        ? 'Đã Thanh Toán'
                                                        : order.paymentStatus === 'PENDING'
                                                            ? 'Chưa TT'
                                                            : 'Thất Bại'}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <span
                                                    className={`text-xs font-bold px-3 py-1 rounded-full ${order.status === 'DELIVERED'
                                                            ? 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400'
                                                            : order.status === 'SHIPPED'
                                                                ? 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400'
                                                                : order.status === 'CONFIRMED'
                                                                    ? 'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400'
                                                                    : order.status === 'CANCELLED'
                                                                        ? 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400'
                                                                        : 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400'
                                                        }`}
                                                >
                                                    {order.status === 'DELIVERED'
                                                        ? 'Đã Giao'
                                                        : order.status === 'SHIPPED'
                                                            ? 'Đang Giao'
                                                            : order.status === 'CONFIRMED'
                                                                ? 'Đã Xác Nhận'
                                                                : order.status === 'CANCELLED'
                                                                    ? 'Đã Hủy'
                                                                    : 'Chờ Xử Lý'}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <span className="text-xs text-stone-500 dark:text-stone-400">
                                                    {new Date(order.createdAt || '').toLocaleDateString('vi-VN')}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4 text-center">
                                                <Link
                                                    href={`/dashboard/admin/orders/${order.id}`}
                                                    className="inline-flex items-center gap-1 px-3 py-1 rounded-lg bg-gold/10 text-gold hover:bg-gold/20 transition text-sm font-bold"
                                                >
                                                    <Eye size={16} />
                                                    Chi Tiết
                                                </Link>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>

                {/* Pagination */}
                {pagination.pages > 1 && (
                    <div className="flex items-center justify-between mt-8">
                        <button
                            onClick={() => loadOrders(Math.max(0, pagination.skip - pagination.take))}
                            disabled={pagination.skip === 0}
                            className="flex items-center gap-2 px-4 py-2 rounded-lg bg-gold text-white disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gold/90 transition"
                        >
                            <ChevronLeft size={16} />
                            Trang Trước
                        </button>

                        <span className="text-sm text-stone-600 dark:text-stone-400">
                            Trang {currentPage} / {pagination.pages}
                        </span>

                        <button
                            onClick={() => loadOrders(pagination.skip + pagination.take)}
                            disabled={currentPage >= pagination.pages}
                            className="flex items-center gap-2 px-4 py-2 rounded-lg bg-gold text-white disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gold/90 transition"
                        >
                            Trang Sau
                            <ChevronRight size={16} />
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}
