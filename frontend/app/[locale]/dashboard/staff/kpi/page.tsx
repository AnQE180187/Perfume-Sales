import { AuthGuard } from '@/components/auth/auth-guard';
import { BarChart3, Target, Award, Zap } from 'lucide-react';

export default function StaffKPI() {
    return (
        <AuthGuard allowedRoles={['staff', 'admin']}>
            <main className="p-8">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Performance Matrix</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Achieving Artisan Excellence</p>
                </header>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
                    <div className="glass p-10 rounded-[3rem] border-border relative overflow-hidden group">
                        <div className="absolute top-0 right-0 w-32 h-32 bg-gold/5 rounded-full blur-3xl -mr-16 -mt-16 group-hover:bg-gold/10 transition-all"></div>
                        <div className="flex items-center gap-4 mb-8">
                            <Award className="w-8 h-8 text-gold" />
                            <h2 className="font-heading text-xl uppercase tracking-widest">Personal Rating</h2>
                        </div>
                        <p className="text-6xl font-heading text-foreground mb-4">4.9<span className="text-2xl text-gold">/5.0</span></p>
                        <p className="text-[10px] text-muted-foreground uppercase tracking-widest font-heading font-medium">Top 2% of Global Artisans</p>
                    </div>

                    <div className="glass p-10 rounded-[3rem] border-border relative overflow-hidden group">
                        <div className="flex items-center gap-4 mb-8">
                            <Target className="w-8 h-8 text-gold" />
                            <h2 className="font-heading text-xl uppercase tracking-widest">Monthly Target</h2>
                        </div>
                        <div className="space-y-6">
                            <div>
                                <div className="flex justify-between text-[10px] uppercase font-heading tracking-widest mb-2">
                                    <span>Fulfillment Speed</span>
                                    <span className="text-gold">85%</span>
                                </div>
                                <div className="h-1.5 w-full bg-secondary/30 rounded-full overflow-hidden">
                                    <div className="h-full bg-gold w-[85%] rounded-full"></div>
                                </div>
                            </div>
                            <div>
                                <div className="flex justify-between text-[10px] uppercase font-heading tracking-widest mb-2">
                                    <span>Client Satisfaction</span>
                                    <span className="text-gold">98%</span>
                                </div>
                                <div className="h-1.5 w-full bg-secondary/30 rounded-full overflow-hidden">
                                    <div className="h-full bg-gold w-[98%] rounded-full"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {[
                        { label: 'Avg Review', value: '4.92', icon: StarIcon },
                        { label: 'Crafting Time', value: '18m', icon: Zap },
                        { label: 'Returns', value: '0.2%', icon: RefreshCwIcon }
                    ].map((stat, i) => (
                        <div key={i} className="glass p-8 rounded-[2rem] border-border hover:border-gold/30 transition-all">
                            <div className="flex justify-between items-start mb-4">
                                <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading">{stat.label}</h3>
                                <stat.icon className="w-4 h-4 text-gold/50" />
                            </div>
                            <p className="text-3xl font-heading text-foreground">{stat.value}</p>
                        </div>
                    ))}
                </div>
            </main>
        </AuthGuard>
    );
}

function StarIcon(props: any) {
    return (
        <svg
            {...props}
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
        >
            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
        </svg>
    )
}

function RefreshCwIcon(props: any) {
    return (
        <svg
            {...props}
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
        >
            <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
            <path d="M21 3v5h-5" />
            <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
            <path d="M3 21v-5h5" />
        </svg>
    )
}
