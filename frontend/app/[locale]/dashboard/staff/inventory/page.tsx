import { AuthGuard } from '@/components/auth/auth-guard';
import { Box, RefreshCw, AlertTriangle, CheckCircle2 } from 'lucide-react';

export default function StaffInventory() {
    return (
        <AuthGuard allowedRoles={['staff', 'admin']}>
            <main className="p-8">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Boutique Stock</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Inventory Oversight & Alerts</p>
                </header>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    {[
                        { label: 'Total Units', value: '4,102', icon: Box },
                        { label: 'Low Stock', value: '08', icon: AlertTriangle, color: 'text-amber-500' },
                        { label: 'Recent Refill', value: '14 Jan', icon: RefreshCw }
                    ].map((stat, i) => (
                        <div key={i} className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group">
                            <div className="flex justify-between items-start mb-4">
                                <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">{stat.label}</h3>
                                <stat.icon className={`w-5 h-5 ${stat.color || 'text-gold'}`} />
                            </div>
                            <p className="text-4xl font-heading text-foreground">{stat.value}</p>
                        </div>
                    ))}
                </div>

                <div className="glass rounded-[2.5rem] border-border overflow-hidden">
                    <div className="p-8 border-b border-border flex justify-between items-center">
                        <h2 className="font-heading text-lg uppercase tracking-widest">Stock Ledger</h2>
                        <button className="text-[10px] uppercase tracking-widest font-heading text-gold hover:underline">Manual Audit</button>
                    </div>
                    <div className="p-8">
                        <div className="space-y-4">
                            {[
                                { item: 'Midnight Jasmine (50ml)', brand: 'Aura Premium', qty: '12', status: 'Optimal' },
                                { item: 'Solar Amber (100ml)', brand: 'Aura Premium', qty: '02', status: 'Critical' },
                                { item: 'Velvet Oud (50ml)', brand: 'Elite Series', qty: '45', status: 'Optimal' },
                            ].map((row, i) => (
                                <div key={i} className="flex items-center justify-between p-6 rounded-3xl bg-secondary/10 border border-border/50">
                                    <div>
                                        <p className="text-[10px] text-gold uppercase tracking-[0.2em] font-bold">{row.brand}</p>
                                        <h4 className="font-heading uppercase text-xs tracking-wider">{row.item}</h4>
                                    </div>
                                    <div className="flex items-center gap-12">
                                        <div className="text-right">
                                            <p className="text-[10px] text-muted-foreground uppercase tracking-widest mb-1">Quantity</p>
                                            <p className="font-heading">{row.qty}</p>
                                        </div>
                                        <div className={`px-4 py-1.5 rounded-full border text-[8px] uppercase tracking-widest font-bold ${row.status === 'Critical' ? 'bg-amber-500/10 border-amber-500/30 text-amber-500' : 'bg-emerald-500/10 border-emerald-500/30 text-emerald-500'}`}>
                                            {row.status}
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </main>
        </AuthGuard>
    );
}
