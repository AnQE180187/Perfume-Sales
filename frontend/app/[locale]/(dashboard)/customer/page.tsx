import { AuthGuard } from '@/components/auth/auth-guard';

export default function CustomerDashboard() {
    return (
        <AuthGuard allowedRoles={['customer']}>
            <main className="p-8">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">My Sanctuary</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Tailored for your unique essence.</p>
                </header>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <div className="glass p-10 rounded-[3rem] border-gold/10">
                        <h2 className="text-xl font-heading mb-8 text-foreground uppercase tracking-widest">Signature Scent</h2>
                        <div className="aspect-[16/9] bg-gradient-to-br from-gold/10 to-transparent rounded-3xl flex items-center justify-center border border-border group overflow-hidden">
                            <div className="absolute inset-0 bg-[url('/hero-bottle.png')] bg-cover bg-center opacity-20 group-hover:scale-110 transition-transform duration-1000" />
                            <span className="relative z-10 text-gold font-heading tracking-[0.5em] uppercase text-xs animate-pulse">Analyzing Bio-Profile...</span>
                        </div>
                    </div>

                    <div className="grid grid-cols-1 gap-6">
                        <div className="glass p-8 rounded-[2rem] border-border hover:border-gold/30 transition-all">
                            <h3 className="text-gold font-heading text-[10px] uppercase tracking-[0.4em] mb-4">Membership</h3>
                            <p className="text-2xl font-heading text-foreground">Elite Gold Member</p>
                            <div className="mt-4 h-1 w-full bg-secondary rounded-full overflow-hidden">
                                <div className="h-full bg-gold w-[75%]" />
                            </div>
                        </div>
                        <div className="glass p-8 rounded-[2rem] border-border hover:border-ai/30 transition-all">
                            <h3 className="text-ai font-heading text-[10px] uppercase tracking-[0.4em] mb-4">AI Consultant</h3>
                            <p className="text-2xl font-heading text-foreground">Active Session</p>
                            <button className="mt-6 text-[10px] uppercase font-heading tracking-widest text-ai hover:text-white transition-colors">Resume Synthesis →</button>
                        </div>
                    </div>
                </div>
            </main>
        </AuthGuard>
    );
}
