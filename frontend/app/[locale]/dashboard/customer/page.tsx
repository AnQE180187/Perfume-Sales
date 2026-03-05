import { AuthGuard } from '@/components/auth/auth-guard';
import { Tag, Sparkles, ArrowUpRight, Zap, Coins, Inbox } from 'lucide-react';
import Link from 'next/link';

export default function CustomerDashboard() {
    return (
        <AuthGuard allowedRoles={['customer']}>
            <main className="p-8 max-w-7xl mx-auto">
                <header className="mb-12 flex justify-between items-end">
                    <div>
                        <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">My Sanctuary</h1>
                        <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Tailored for your unique essence.</p>
                    </div>
                    <div className="hidden md:flex gap-4">
                        <div className="glass px-6 py-3 rounded-2xl border-gold/10 flex items-center gap-3">
                            <Coins size={16} className="text-gold" />
                            <div className="text-left">
                                <p className="text-[8px] text-muted-foreground uppercase tracking-widest font-bold">Aura Credits</p>
                                <p className="text-xs font-heading text-foreground">1,250 PTS</p>
                            </div>
                        </div>
                    </div>
                </header>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12">
                    {/* Primary Highlight */}
                    <div className="lg:col-span-2 glass p-1 bg-gradient-to-br from-gold/20 via-transparent to-gold/5 rounded-[3rem]">
                        <div className="bg-background/40 backdrop-blur-3xl p-10 rounded-[2.9rem] h-full flex flex-col md:flex-row gap-10">
                            <div className="w-full md:w-1/2 aspect-square glass rounded-[2.5rem] border-gold/10 flex items-center justify-center relative overflow-hidden group">
                                <div className="absolute inset-0 bg-[url('/hero-bottle.png')] bg-cover bg-center opacity-10 group-hover:scale-110 transition-transform duration-1000" />
                                <div className="relative z-10 text-center">
                                    <Sparkles className="w-8 h-8 text-gold mx-auto mb-4 animate-pulse" />
                                    <span className="text-gold font-heading tracking-[0.4em] uppercase text-[10px]">Analyzing DNA...</span>
                                </div>
                            </div>
                            <div className="flex-1 flex flex-col justify-center">
                                <h2 className="text-2xl font-heading mb-4 text-foreground uppercase tracking-widest leading-tight">Your Neural Signature is evolving</h2>
                                <p className="text-sm text-muted-foreground font-body mb-8 leading-relaxed">
                                    Our AI has detected new olfactory resonances based on your recent interactions. Update your profile to synchronize.
                                </p>
                                <Link href="/dashboard/customer/quiz" className="bg-gold text-primary-foreground px-8 py-3.5 rounded-full font-heading text-[10px] uppercase tracking-widest font-bold hover:scale-105 transition-all text-center">
                                    Refresh Synthesis
                                </Link>
                            </div>
                        </div>
                    </div>

                    {/* Quick Stats Grid */}
                    <div className="grid grid-cols-1 gap-6">
                        <div className="glass p-8 rounded-[2.5rem] border-gold/10 flex flex-col justify-between group hover:border-gold/30 transition-all">
                            <div className="flex justify-between items-start mb-4">
                                <h3 className="text-gold font-heading text-[10px] uppercase tracking-[0.4em]">Membership</h3>
                                <ArrowUpRight size={14} className="text-muted-foreground group-hover:text-gold transition-colors" />
                            </div>
                            <div>
                                <p className="text-2xl font-heading text-foreground uppercase">Elite Gold</p>
                                <div className="mt-4 h-1 w-full bg-secondary rounded-full overflow-hidden">
                                    <div className="h-full bg-gold w-[75%]" />
                                </div>
                            </div>
                        </div>

                        <Link href="/dashboard/customer/promotions">
                            <div className="glass p-8 rounded-[2.5rem] border-gold/10 flex flex-col justify-between h-full bg-gradient-to-br from-transparent to-gold/5 hover:border-gold/30 transition-all group">
                                <div className="flex justify-between items-start mb-4">
                                    <div className="p-3 bg-gold/10 rounded-2xl text-gold group-hover:scale-110 transition-transform">
                                        <Tag size={20} />
                                    </div>
                                    <span className="bg-gold/20 text-gold text-[8px] px-2 py-1 rounded-full font-bold uppercase tracking-widest animate-pulse">New</span>
                                </div>
                                <div>
                                    <h3 className="text-lg font-heading text-foreground uppercase tracking-widest">Active Offers</h3>
                                    <p className="text-[10px] text-muted-foreground uppercase mt-1">3 Rewards available for synthesis</p>
                                </div>
                            </div>
                        </Link>
                    </div>
                </div>

                {/* Secondary Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    {[
                        { label: "My Orders", icon: Inbox, href: "/dashboard/customer/orders", color: "text-blue-400" },
                        { label: "Loyalty", icon: Coins, href: "/dashboard/customer/loyalty", color: "text-gold" },
                        { label: "AI Consultation", icon: Zap, href: "/dashboard/customer/ai-chat", color: "text-ai" },
                        { label: "Quiz Results", icon: Sparkles, href: "/dashboard/customer/quiz", color: "text-gold" }
                    ].map((item, i) => (
                        <Link key={i} href={item.href}>
                            <div className="glass px-6 py-5 rounded-3xl border-border hover:border-gold/30 transition-all flex items-center gap-4 group">
                                <div className={`w-12 h-12 rounded-2xl bg-secondary/50 flex items-center justify-center ${item.color} group-hover:scale-110 transition-transform`}>
                                    <item.icon size={20} />
                                </div>
                                <div>
                                    <h4 className="text-[10px] font-bold uppercase tracking-widest text-foreground">{item.label}</h4>
                                    <p className="text-[8px] text-muted-foreground uppercase tracking-tighter mt-0.5">Explore module →</p>
                                </div>
                            </div>
                        </Link>
                    ))}
                </div>
            </main>
        </AuthGuard>
    );
}
