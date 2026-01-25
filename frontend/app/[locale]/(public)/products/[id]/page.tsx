import { ChevronRight, ShoppingBag, Heart, ShieldCheck, Truck, Sparkles, BrainCircuit } from 'lucide-react';
import { Link } from '@/lib/i18n';

export default async function ProductDetailPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params;

    return (
        <div className="min-h-screen bg-background pt-32 px-6 pb-20">
            <div className="max-w-7xl mx-auto">
                <nav className="flex items-center gap-4 text-[10px] uppercase tracking-widest font-heading text-muted-foreground mb-12">
                    <Link href="/" className="hover:text-gold transition-colors">Odyssey</Link>
                    <ChevronRight className="w-3 h-3" />
                    <Link href="/collection" className="hover:text-gold transition-colors">Catalog</Link>
                    <ChevronRight className="w-3 h-3" />
                    <span className="text-gold">Midnight Jasmine</span>
                </nav>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-20">
                    {/* Visual Section */}
                    <div className="space-y-6">
                        <div className="aspect-[4/5] glass rounded-[3rem] border-border overflow-hidden relative group">
                            <div className="absolute inset-0 bg-gradient-to-tr from-gold/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-1000" />
                            <div className="absolute inset-x-0 bottom-0 p-12 text-center bg-gradient-to-t from-background to-transparent">
                                <span className="text-gold font-heading tracking-[0.5em] uppercase text-xs animate-pulse inline-flex items-center gap-3">
                                    <Sparkles className="w-4 h-4" /> Neural Scanning Active
                                </span>
                            </div>
                        </div>
                        <div className="grid grid-cols-4 gap-4">
                            {[1, 2, 3, 4].map((i) => (
                                <div key={i} className="aspect-square glass rounded-2xl border-border cursor-pointer hover:border-gold/30 transition-all overflow-hidden">
                                    <div className="w-full h-full bg-secondary/20" />
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Intellectual Section */}
                    <div className="flex flex-col justify-center">
                        <div className="space-y-2 mb-8">
                            <div className="flex items-center gap-3">
                                <span className="px-3 py-1 rounded-full glass border-gold/20 text-gold text-[8px] uppercase tracking-widest font-bold">Elite Series</span>
                                <span className="text-[10px] text-muted-foreground uppercase tracking-widest font-heading">Archived #MD-2401</span>
                            </div>
                            <h1 className="text-5xl lg:text-6xl font-heading text-foreground uppercase tracking-tighter leading-none">Midnight Jasmine</h1>
                            <p className="text-2xl font-heading gold-gradient">$210.00</p>
                        </div>

                        <div className="space-y-8 mb-12">
                            <p className="text-sm text-muted-foreground font-body leading-relaxed max-w-xl">
                                A nocturnally synthesized essence that captures the intersection of urban neon and raw botanical power. Engineered through 18,000 algorithmic variations to resonate with the wearer's nocturnal bio-rhythms.
                            </p>

                            <div className="space-y-6">
                                <h3 className="text-[10px] uppercase tracking-[0.3em] font-heading text-foreground border-b border-border/50 pb-4">Olfactory Architecture</h3>
                                <div className="grid grid-cols-3 gap-8">
                                    <div>
                                        <p className="text-[8px] text-muted-foreground uppercase tracking-widest mb-1">Synthesis Top</p>
                                        <p className="text-xs font-heading text-gold uppercase tracking-widest">Cold Pepper</p>
                                    </div>
                                    <div>
                                        <p className="text-[8px] text-muted-foreground uppercase tracking-widest mb-1">Biological Heart</p>
                                        <p className="text-xs font-heading text-gold uppercase tracking-widest">Midnight Bloom</p>
                                    </div>
                                    <div>
                                        <p className="text-[8px] text-muted-foreground uppercase tracking-widest mb-1">Algorithm Base</p>
                                        <p className="text-xs font-heading text-gold uppercase tracking-widest">Obsidian Musk</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div className="flex flex-col sm:flex-row gap-4 mb-12">
                            <button className="flex-1 bg-gold text-primary-foreground h-16 rounded-full font-heading text-xs uppercase font-bold tracking-[0.3em] hover:scale-[1.02] active:scale-95 transition-all shadow-xl shadow-gold/20 flex items-center justify-center gap-3">
                                <ShoppingBag className="w-4 h-4" /> Assemble Acquisition
                            </button>
                            <button className="w-16 h-16 glass border-border rounded-full flex items-center justify-center text-muted-foreground hover:text-red-400 group transition-all">
                                <Heart className="w-5 h-5 group-hover:fill-red-400/20" />
                            </button>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-10 border-t border-border/50">
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-xl glass border-gold/10 flex items-center justify-center shrink-0">
                                    <BrainCircuit className="w-5 h-5 text-gold" />
                                </div>
                                <div>
                                    <h4 className="text-[10px] uppercase font-heading tracking-widest text-foreground mb-1">Pattern Matching</h4>
                                    <p className="text-[8px] text-muted-foreground uppercase tracking-widest leading-relaxed">Matches your bio-profile with 98.4% precision.</p>
                                </div>
                            </div>
                            <div className="flex gap-4">
                                <div className="w-10 h-10 rounded-xl glass border-gold/10 flex items-center justify-center shrink-0">
                                    <ShieldCheck className="w-5 h-5 text-gold" />
                                </div>
                                <div>
                                    <h4 className="text-[10px] uppercase font-heading tracking-widest text-foreground mb-1">Authenticity Shield</h4>
                                    <p className="text-[8px] text-muted-foreground uppercase tracking-widest leading-relaxed">Indelible molecular signature for certification.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
