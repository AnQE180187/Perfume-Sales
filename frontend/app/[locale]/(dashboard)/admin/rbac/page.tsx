import { AuthGuard } from '@/components/auth/auth-guard';
import { ShieldCheck, UserPlus, ShieldAlert } from 'lucide-react';
import { useTranslations } from 'next-intl';

export default function AdminRBAC() {
    const navT = useTranslations('navigation');

    return (
        <AuthGuard allowedRoles={['admin']}>
            <main className="p-8">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">{navT('admin.rbac')}</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Role-Based Permission Management</p>
                </header>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    {[
                        { label: 'Active Roles', value: '4', icon: ShieldCheck },
                        { label: 'Pending Approvals', value: '12', icon: UserPlus },
                        { label: 'Security Alerts', value: '0', icon: ShieldAlert }
                    ].map((stat, i) => (
                        <div key={i} className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all group">
                            <div className="flex justify-between items-start mb-4">
                                <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">{stat.label}</h3>
                                <stat.icon className="w-5 h-5 text-gold" />
                            </div>
                            <p className="text-4xl font-heading text-foreground">{stat.value}</p>
                        </div>
                    ))}
                </div>

                <div className="glass rounded-[2.5rem] border-border overflow-hidden">
                    <div className="p-8 border-b border-border">
                        <h2 className="font-heading text-lg uppercase tracking-widest">Role Matrix</h2>
                    </div>
                    <div className="p-8 text-center text-muted-foreground py-20 font-body">
                        The security matrix is being synchronized with the neural network.
                    </div>
                </div>
            </main>
        </AuthGuard>
    );
}
