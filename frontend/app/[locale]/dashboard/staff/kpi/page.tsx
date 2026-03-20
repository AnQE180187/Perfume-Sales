'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { BarChart3, Target, Award, TrendingUp, Package, DollarSign, Loader2 } from 'lucide-react';
import { useEffect, useState } from 'react';
import { staffReportsService, type DailyReport } from '@/services/staff-reports.service';

const formatVND = (n: number) =>
    new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(n);

export default function StaffKPI() {
    const [report, setReport] = useState<DailyReport | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const load = async () => {
            setLoading(true);
            try {
                const data = await staffReportsService.getDailyReport();
                setReport(data);
            } catch (e: any) {
                setError(e.message || 'Failed to load report');
            } finally {
                setLoading(false);
            }
        };
        void load();
    }, []);

    return (
        <AuthGuard allowedRoles={['staff', 'admin']}>
            <main className="p-8">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Performance Matrix</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">
                        Today&apos;s KPIs — {report?.date ?? new Date().toISOString().slice(0, 10)}
                    </p>
                </header>

                {error && (
                    <div className="mb-6 p-3 rounded-2xl border border-red-500/40 bg-red-500/5 text-xs text-red-500">
                        {error}
                    </div>
                )}

                {loading ? (
                    <div className="flex items-center justify-center py-20 text-muted-foreground text-sm">
                        <Loader2 className="w-5 h-5 mr-2 animate-spin" /> Loading report…
                    </div>
                ) : report ? (
                    <>
                        {/* Summary cards */}
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
                            <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group">
                                <div className="flex justify-between items-start mb-4">
                                    <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">Today&apos;s Revenue</h3>
                                    <DollarSign className="w-5 h-5 text-gold" />
                                </div>
                                <p className="text-3xl font-heading text-gold">{formatVND(report.totalRevenue)}</p>
                            </div>
                            <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group">
                                <div className="flex justify-between items-start mb-4">
                                    <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">Total Orders</h3>
                                    <Package className="w-5 h-5 text-gold" />
                                </div>
                                <p className="text-3xl font-heading text-foreground">{report.totalOrders}</p>
                                <p className="text-[10px] text-muted-foreground mt-1">{report.completedOrders} completed</p>
                            </div>
                            <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group">
                                <div className="flex justify-between items-start mb-4">
                                    <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">Avg Order Value</h3>
                                    <TrendingUp className="w-5 h-5 text-gold" />
                                </div>
                                <p className="text-3xl font-heading text-foreground">{formatVND(report.avgOrderValue)}</p>
                            </div>
                            <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all bg-gold/5 group">
                                <div className="flex justify-between items-start mb-4">
                                    <h3 className="text-gold text-[10px] uppercase tracking-[0.3em] font-heading">Completion Rate</h3>
                                    <Award className="w-5 h-5 text-gold" />
                                </div>
                                <p className="text-3xl font-heading text-foreground">
                                    {report.totalOrders > 0
                                        ? Math.round((report.completedOrders / report.totalOrders) * 100)
                                        : 0}%
                                </p>
                            </div>
                        </div>

                        {/* Top products */}
                        <div className="glass rounded-[2.5rem] border-border p-8">
                            <div className="flex items-center gap-3 mb-6">
                                <BarChart3 className="w-5 h-5 text-gold" />
                                <h2 className="font-heading text-lg uppercase tracking-widest">Top Selling Products</h2>
                            </div>
                            {report.topProducts.length === 0 ? (
                                <p className="text-sm text-muted-foreground text-center py-8">No sales data for today yet.</p>
                            ) : (
                                <div className="space-y-4">
                                    {report.topProducts.map((p, i) => {
                                        const maxQty = report.topProducts[0].totalQuantity;
                                        const pct = maxQty > 0 ? (p.totalQuantity / maxQty) * 100 : 0;
                                        return (
                                            <div key={i} className="space-y-2">
                                                <div className="flex justify-between items-end">
                                                    <div>
                                                        <span className="font-heading text-sm uppercase tracking-wider">{p.productName}</span>
                                                        <span className="text-[10px] text-muted-foreground ml-2">{p.variantName}</span>
                                                    </div>
                                                    <div className="text-right">
                                                        <span className="font-heading text-gold text-sm">{p.totalQuantity} sold</span>
                                                        <span className="text-[10px] text-muted-foreground ml-2">{formatVND(p.totalRevenue)}</span>
                                                    </div>
                                                </div>
                                                <div className="h-2 w-full bg-secondary/30 rounded-full overflow-hidden">
                                                    <div
                                                        className="h-full bg-gold rounded-full transition-all"
                                                        style={{ width: `${pct}%` }}
                                                    />
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            )}
                        </div>
                    </>
                ) : null}
            </main>
        </AuthGuard>
    );
}
