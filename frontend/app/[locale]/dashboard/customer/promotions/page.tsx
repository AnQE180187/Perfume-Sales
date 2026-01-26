import { AuthGuard } from '@/components/auth/auth-guard';
import { Tag, Zap, Timer, Sparkles } from 'lucide-react';

export default function CustomerPromotions() {
    return (
        <AuthGuard allowedRoles={['customer']}>
            <main className="p-8">
                <header className="mb-12">
                    <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Limited Synthesis</h1>
                    <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Exclusive opportunities and rare decants.</p>
                </header>

                <div className="space-y-8">
                    <div className="glass p-1 bg-gradient-to-r from-gold/30 via-transparent to-gold/30 rounded-[3rem]">
                        <div className="bg-background/80 backdrop-blur-3xl p-12 rounded-[2.9rem] flex flex-col md:flex-row items-center gap-12 relative overflow-hidden">
                            <div className="absolute top-0 right-0 p-8">
                                <Sparkles className="w-8 h-8 text-gold animate-pulse" />
                            </div>
                            <div className="w-full md:w-1/3 aspect-square glass rounded-[3rem] border-gold/20 flex items-center justify-center">
                                <div className="text-center">
                                    <p className="text-6xl font-heading text-gold mb-2">25<span className="text-2xl">%</span></p>
                                    <p className="text-[10px] text-muted-foreground uppercase tracking-widest font-bold">OFF</p>
                                </div>
                            </div>
                            <div className="flex-1 text-center md:text-left">
                                <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-gold/10 border border-gold/20 text-gold text-[8px] uppercase tracking-widest font-bold mb-6">
                                    <Timer className="w-3 h-3" />
                                    Expiring in 08:42:12
                                </div>
                                <h2 className="text-3xl font-heading text-foreground uppercase tracking-widest mb-4">Lunar Eclipse Event</h2>
                                <p className="text-sm text-muted-foreground font-body leading-relaxed mb-8 max-w-xl">
                                    Our AI has predicted a surge in nocturnal fragrance demand. Apply code <span className="text-gold font-bold">LUNAR25</span> to your next darkness-themed acquisition.
                                </p>
                                <button className="bg-gold text-primary-foreground px-10 py-4 rounded-full font-heading text-[10px] uppercase tracking-[0.2em] font-bold hover:scale-105 transition-all shadow-xl shadow-gold/20">
                                    Claim Invitation
                                </button>
                            </div>
                        </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                        {[
                            { title: 'Artisan Referral', desc: 'Invite a fellow connoisseur and receive a 10ml rare decant of your choice.', tag: 'Ongoing' },
                            { title: 'Birthday Gifting', desc: 'Notify us of your arrival date for a personalized biological synthesis.', tag: 'Anniversary' },
                        ].map((promo, i) => (
                            <div key={i} className="glass p-10 rounded-[2.5rem] border-border hover:border-gold/20 transition-all group">
                                <div className="flex justify-between items-start mb-6">
                                    <h3 className="font-heading text-lg uppercase tracking-widest">{promo.title}</h3>
                                    <span className="bg-secondary/50 text-muted-foreground text-[8px] uppercase tracking-widest font-bold px-3 py-1.5 rounded-full border border-border">{promo.tag}</span>
                                </div>
                                <p className="text-xs text-muted-foreground font-body leading-relaxed mb-8">{promo.desc}</p>
                                <button className="text-gold font-heading text-[10px] uppercase tracking-widest flex items-center gap-2 group-hover:translate-x-2 transition-transform">
                                    Learn More <Zap className="w-3 h-3" />
                                </button>
                            </div>
                        ))}
                    </div>
                </div>
            </main>
        </AuthGuard>
    );
}
