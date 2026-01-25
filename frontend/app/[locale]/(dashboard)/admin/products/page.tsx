import { AuthGuard } from '@/components/auth/auth-guard';
import { Package, Plus, Search, Filter } from 'lucide-react';

export default function AdminProducts() {
    return (
        <AuthGuard allowedRoles={['admin']}>
            <main className="p-8">
                <header className="mb-12 flex justify-between items-end">
                    <div>
                        <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Inventory Console</h1>
                        <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Fragrance Collection Management</p>
                    </div>
                    <button className="bg-gold text-primary-foreground px-6 py-3 rounded-full font-heading text-[10px] uppercase tracking-widest font-bold flex items-center gap-2 hover:scale-105 transition-all">
                        <Plus className="w-4 h-4" />
                        Curate New
                    </button>
                </header>

                <div className="flex gap-4 mb-8">
                    <div className="flex-1 relative">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                        <input
                            type="text"
                            placeholder="Search by essence, brand or note..."
                            className="w-full bg-secondary/20 border border-border rounded-full py-3 pl-12 pr-4 text-sm outline-none focus:border-gold/50 transition-all font-body"
                        />
                    </div>
                    <button className="glass px-6 rounded-full border-border flex items-center gap-2 text-muted-foreground hover:text-foreground transition-all">
                        <Filter className="w-4 h-4" />
                        <span className="text-[10px] uppercase tracking-widest font-heading">Refine</span>
                    </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
                        <div key={i} className="glass rounded-[2rem] border-border overflow-hidden hover:border-gold/30 transition-all group">
                            <div className="aspect-square bg-secondary/30 relative">
                                <div className="absolute inset-0 flex items-center justify-center">
                                    <Package className="w-12 h-12 text-gold/20" />
                                </div>
                            </div>
                            <div className="p-6">
                                <p className="text-[10px] text-gold uppercase tracking-widest font-bold mb-1">Aura Premiere</p>
                                <h3 className="font-heading text-foreground mb-4">Essence {i}</h3>
                                <div className="flex justify-between items-center">
                                    <span className="font-heading text-lg">$240</span>
                                    <span className="text-[10px] text-muted-foreground uppercase tracking-widest">12 in stock</span>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            </main>
        </AuthGuard>
    );
}
