import { AuthGuard } from '@/components/auth/auth-guard';
import { Settings2, Globe, Shield, Bell, Database } from 'lucide-react';

export default function AdminSettings() {
    return (
        <AuthGuard allowedRoles={['admin']}>
            <main className="p-8">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Core Configuration</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Environment & Neural Parameters</p>
                </header>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl">
                    {[
                        { title: 'Global Localization', desc: 'Sync multi-language and currency matrices', icon: Globe },
                        { title: 'Security Protocol', desc: 'Manage 2FA, RLS and API keys', icon: Shield },
                        { title: 'Neural Notifications', desc: 'Configure automated system alerts', icon: Bell },
                        { title: 'Data Sovereignty', desc: 'Manage database exports and backups', icon: Database },
                    ].map((setting, i) => (
                        <div key={i} className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all cursor-pointer group">
                            <div className="flex items-center gap-6">
                                <div className="w-14 h-14 rounded-2xl bg-secondary/50 flex items-center justify-center group-hover:bg-gold/10 transition-colors">
                                    <setting.icon className="w-6 h-6 text-gold" />
                                </div>
                                <div>
                                    <h3 className="font-heading text-foreground uppercase tracking-widest text-sm mb-1">{setting.title}</h3>
                                    <p className="text-[10px] text-muted-foreground uppercase tracking-widest leading-relaxed">{setting.desc}</p>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>

                <div className="mt-12 pt-8 border-t border-border/50 max-w-4xl flex justify-between items-center text-muted-foreground">
                    <span className="text-[10px] uppercase font-heading tracking-widest">Version 2.0.4-AI</span>
                    <button className="text-[10px] uppercase font-heading tracking-widest text-gold hover:underline underline-offset-4">Reload Manifest</button>
                </div>
            </main>
        </AuthGuard>
    );
}
