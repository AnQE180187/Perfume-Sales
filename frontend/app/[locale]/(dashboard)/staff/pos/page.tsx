'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { useTranslations } from 'next-intl';
import { useState } from 'react';
import { Search, ShoppingCart, CreditCard, Plus, Minus, Receipt } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export default function PosPage() {
    const navT = useTranslations('navigation');
    const [cart, setCart] = useState([
        { id: 1, name: "Aura No. 5 'Obsidian'", price: 1250, quantity: 1, variant: "100ml" },
        { id: 2, name: "Molecular Sample Set", price: 450, quantity: 2, variant: "Personalized" }
    ]);

    const total = cart.reduce((acc, item) => acc + (item.price * item.quantity), 0);

    return (
        <AuthGuard allowedRoles={['staff', 'admin']}>
            <div className="flex h-[calc(100vh-80px)] overflow-hidden">
                {/* Catalog Area */}
                <div className="flex-1 flex flex-col border-r border-border min-w-0">
                    <header className="p-8 border-b border-border flex justify-between items-center bg-secondary/10 shrink-0">
                        <div className="relative w-full max-w-lg">
                            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                            <input
                                type="text"
                                placeholder="Search products, batches or scan barcode..."
                                className="w-full bg-background border border-border rounded-full py-3.5 pl-12 pr-4 text-sm focus:border-gold/50 outline-none transition-all shadow-sm"
                            />
                        </div>
                    </header>

                    <div className="flex-1 overflow-y-auto p-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 custom-scrollbar">
                        {[1, 2, 3, 4, 5, 6].map(i => (
                            <motion.div
                                key={i}
                                whileHover={{ y: -5 }}
                                className="glass p-5 rounded-[2rem] border-border hover:border-gold/30 cursor-pointer group transition-all"
                            >
                                <div className="aspect-square bg-secondary/50 rounded-2xl mb-4 overflow-hidden relative">
                                    <div className="absolute inset-0 bg-gradient-to-tr from-gold/10 to-transparent" />
                                    <div className="absolute bottom-3 left-3 px-2 py-1 bg-background/80 backdrop-blur-md rounded-lg text-[9px] uppercase font-heading text-gold border border-gold/10">Stock: 14</div>
                                </div>
                                <h3 className="font-heading text-sm mb-1 line-clamp-1 uppercase tracking-tight">Fragrance Essence {i}</h3>
                                <div className="flex justify-between items-center mt-4">
                                    <span className="font-heading text-gold text-lg">${(850 + i * 10).toLocaleString()}</span>
                                    <button className="p-3 rounded-xl bg-gold/10 text-gold group-hover:bg-gold group-hover:text-primary-foreground transition-all">
                                        <Plus className="w-4 h-4" />
                                    </button>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </div>

                {/* Cart Area */}
                <div className="w-[400px] flex flex-col bg-secondary/10 shrink-0 p-8 shadow-2xl z-10 transition-colors">
                    <div className="flex items-center gap-3 mb-8">
                        <ShoppingCart className="w-6 h-6 text-gold" />
                        <h2 className="font-heading text-lg uppercase tracking-[0.2em]">Active Bin</h2>
                    </div>

                    <div className="flex-1 space-y-4 overflow-y-auto custom-scrollbar mb-8 pr-2">
                        <AnimatePresence>
                            {cart.map(item => (
                                <motion.div
                                    key={item.id}
                                    initial={{ opacity: 0, x: 20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: -20 }}
                                    className="glass p-5 rounded-2xl border-border flex gap-4 hover:border-gold/20 transition-colors"
                                >
                                    <div className="w-16 h-16 rounded-xl bg-secondary border border-border shrink-0" />
                                    <div className="flex-1 overflow-hidden">
                                        <p className="font-heading text-[10px] uppercase tracking-widest truncate">{item.name}</p>
                                        <div className="flex justify-between items-center mt-4">
                                            <div className="flex items-center gap-3 glass rounded-lg p-1 border-border">
                                                <button className="p-1 hover:text-gold transition-colors"><Minus className="w-3 h-3" /></button>
                                                <span className="text-xs font-heading w-4 text-center">{item.quantity}</span>
                                                <button className="p-1 hover:text-gold transition-colors"><Plus className="w-3 h-3" /></button>
                                            </div>
                                            <span className="font-heading text-sm text-gold">${(item.price * item.quantity).toLocaleString()}</span>
                                        </div>
                                    </div>
                                </motion.div>
                            ))}
                        </AnimatePresence>
                    </div>

                    <div className="space-y-4 border-t border-border pt-8 mt-auto">
                        <div className="flex justify-between text-muted-foreground text-[10px] uppercase tracking-widest font-heading">
                            <span>Subtotal</span>
                            <span>${total.toLocaleString()}</span>
                        </div>
                        <div className="flex justify-between text-2xl font-heading pt-4 text-foreground">
                            <span className="tracking-tighter uppercase">Total</span>
                            <span className="text-gold">${(total - 240).toLocaleString()}</span>
                        </div>

                        <div className="grid grid-cols-2 gap-4 mt-8">
                            <button className="py-4 glass border-border rounded-2xl font-heading text-[9px] uppercase tracking-[0.2em] hover:border-gold/50 transition-all flex flex-col items-center gap-2">
                                <Receipt className="w-4 h-4 text-gold" />
                                Hold
                            </button>
                            <button className="py-4 bg-gold text-primary-foreground font-heading font-bold rounded-2xl text-[9px] uppercase tracking-[0.2em] hover:scale-[1.02] active:scale-95 transition-all shadow-xl shadow-gold/20 flex flex-col items-center gap-2">
                                <CreditCard className="w-4 h-4" />
                                Charge
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </AuthGuard>
    );
}
