export default function StaffDashboard() {
    return (
        <main className="p-8">
            <header className="mb-12">
                <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Artisan Console</h1>
                <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Refining the personalized fragrance experience.</p>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all">
                    <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading mb-4">Pending Requests</h3>
                    <p className="text-4xl font-heading text-foreground">12</p>
                </div>
                <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all">
                    <h3 className="text-muted-foreground text-[10px] uppercase tracking-[0.3em] font-heading mb-4">Crafting in Progress</h3>
                    <p className="text-4xl font-heading text-foreground">05</p>
                </div>
                <div className="glass p-8 rounded-[2.5rem] border-border hover:border-gold/30 transition-all bg-gold/5">
                    <h3 className="text-gold text-[10px] uppercase tracking-[0.3em] font-heading mb-4">Today's Revenue</h3>
                    <p className="text-4xl font-heading text-foreground">$4,280</p>
                </div>
            </div>
        </main>
    );
}
