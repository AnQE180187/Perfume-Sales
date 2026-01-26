'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { User, Mail, Shield, Smartphone, Camera, Edit2 } from 'lucide-react';
import { useParams } from 'next/navigation';
import { useAuth } from '@/hooks/use-auth';

export default function GenericProfilePage() {
    const params = useParams();
    const role = (params.role as string) || 'user';
    const { user: authUser } = useAuth();

    const user = {
        full_name: authUser?.fullName || authUser?.name || 'Explorer',
        email: authUser?.email || 'no-email@aura.ai',
        role: role.toUpperCase()
    };

    return (
        <AuthGuard allowedRoles={[role as any]}>
            <main className="p-8 max-w-5xl mx-auto">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Identity Core</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Managing your {role} digital essence.</p>
                </header>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
                    <div className="lg:col-span-1 space-y-8">
                        <div className="glass p-10 rounded-[3.5rem] border-gold/10 text-center relative group">
                            <div className="w-32 h-32 rounded-[2.5rem] bg-secondary mx-auto mb-6 relative overflow-hidden border-2 border-border group-hover:border-gold/30 transition-all">
                                {authUser?.avatarUrl ? (
                                    <img src={authUser.avatarUrl} alt="Profile" className="w-full h-full object-cover" />
                                ) : (
                                    <User className="w-full h-full p-6 text-muted-foreground/30" />
                                )}
                                <div className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer">
                                    <Camera className="w-6 h-6 text-white" />
                                </div>
                            </div>
                            <h2 className="font-heading text-xl text-foreground uppercase tracking-widest mb-1">{user.full_name}</h2>
                            <p className="text-[10px] text-gold uppercase tracking-[0.3em] font-bold">{user.role}</p>
                        </div>

                        <div className="glass p-8 rounded-[2.5rem] border-border space-y-6">
                            <h3 className="font-heading text-[10px] uppercase tracking-widest text-muted-foreground mb-4">Security Matrix</h3>
                            <div className="flex items-center gap-4 text-xs font-body text-foreground">
                                <Shield className="w-4 h-4 text-emerald-500" />
                                <span>2FA Operational</span>
                            </div>
                            <div className="flex items-center gap-4 text-xs font-body text-foreground">
                                <Smartphone className="w-4 h-4 text-gold" />
                                <span>Verified Device</span>
                            </div>
                        </div>
                    </div>

                    <div className="lg:col-span-2 space-y-8">
                        <div className="glass p-10 rounded-[3rem] border-border">
                            <div className="flex justify-between items-center mb-10">
                                <h3 className="font-heading text-lg uppercase tracking-widest">Metadata</h3>
                                <button className="flex items-center gap-2 text-gold text-[10px] uppercase font-heading tracking-widest hover:underline">
                                    <Edit2 className="w-3 h-3" /> Edit
                                </button>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
                                <div className="space-y-2">
                                    <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">Display Name</label>
                                    <p className="font-body text-sm border-b border-border/50 pb-2">{user.full_name}</p>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">User Reference</label>
                                    <p className="font-body text-sm border-b border-border/50 pb-2">@{user.full_name.toLowerCase().replace(' ', '.')}.aura</p>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">Digital Post</label>
                                    <p className="font-body text-sm border-b border-border/50 pb-2">{user.email}</p>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">Role Status</label>
                                    <p className="font-body text-sm border-b border-border/50 pb-2 uppercase">{role}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </AuthGuard>
    );
}
