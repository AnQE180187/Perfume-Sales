import { AuthGuard } from '@/components/auth/auth-guard';

export default function UsersAdmin() {
    return (
        <AuthGuard allowedRoles={['admin']}>
            <main className="p-8">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Member Directory</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Manage the Aura AI elite community.</p>
                </header>

                <div className="glass rounded-[2.5rem] border-border overflow-hidden">
                    <table className="w-full text-left font-body text-sm">
                        <thead className="bg-secondary/50 text-muted-foreground border-b border-border">
                            <tr>
                                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">Identity</th>
                                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">Role</th>
                                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">Status</th>
                                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-border/50">
                            {[1, 2, 3, 4, 5].map(i => (
                                <tr key={i} className="hover:bg-secondary/20 transition-colors group">
                                    <td className="px-8 py-6">
                                        <div className="flex flex-col">
                                            <span className="font-heading uppercase text-xs tracking-wider">Aura User {i}</span>
                                            <span className="text-[10px] text-muted-foreground">identity-00{i}@aura.ai</span>
                                        </div>
                                    </td>
                                    <td className="px-8 py-6">
                                        <span className="text-[10px] text-gold font-bold uppercase tracking-widest">Customer</span>
                                    </td>
                                    <td className="px-8 py-6">
                                        <span className="px-4 py-1.5 bg-emerald-500/10 text-emerald-500 rounded-full text-[8px] uppercase tracking-widest font-bold border border-emerald-500/20">Active</span>
                                    </td>
                                    <td className="px-8 py-6 text-right">
                                        <button className="text-[10px] uppercase font-heading tracking-widest text-muted-foreground hover:text-gold transition-colors">Manage</button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </main>
        </AuthGuard>
    );
}
