'use client';

import { useState, useEffect, useCallback } from 'react';
import Image from 'next/image';
import { Link } from '@/lib/i18n';
import { motion } from 'framer-motion';
import { Trash2, ArrowRight, ShieldCheck, Truck, RotateCcw } from 'lucide-react';
import { cartService, type Cart, type CartItem } from '@/services/cart.service';
import { useAuth } from '@/hooks/use-auth';

export default function CartPage() {
  const { isAuthenticated } = useAuth();
  const [cart, setCart] = useState<Cart | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchCart = useCallback(() => {
    if (!isAuthenticated) {
      setCart(null);
      setLoading(false);
      return;
    }
    setLoading(true);
    cartService
      .getCart()
      .then(setCart)
      .catch(() => setCart(null))
      .finally(() => setLoading(false));
  }, [isAuthenticated]);

  useEffect(() => {
    fetchCart();
  }, [fetchCart]);

  const updateQty = async (item: CartItem, delta: number) => {
    const q = Math.max(1, item.quantity + delta);
    try {
      const updated = await cartService.updateItem(item.id, q);
      setCart(updated);
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error(e);
    }
  };

  const remove = async (itemId: number) => {
    try {
      const updated = await cartService.removeItem(itemId);
      setCart(updated);
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error(e);
    }
  };

    if (!isAuthenticated) {
        return (
            <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
                <main className="container mx-auto px-6 py-32 text-center">
          <h1 className="text-4xl md:text-5xl font-serif text-luxury-black dark:text-white mb-6">Your Collection</h1>
          <p className="text-stone-500 dark:text-stone-400 mb-8">Please sign in to view your cart.</p>
          <Link href="/login" className="inline-block bg-gold text-white px-8 py-4 rounded-full font-bold tracking-widest uppercase">
            Sign In
          </Link>
                </main>
            </div>
        );
    }

    const items = cart?.items ?? [];
  const subtotal = items.reduce((acc, i) => acc + i.product.price * i.quantity, 0);

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors">
      <main className="container mx-auto px-6 py-32">
        <h1 className="text-4xl md:text-5xl font-serif text-luxury-black dark:text-white mb-12 transition-colors">
          Your Collection
        </h1>

        {loading ? (
          <div className="py-20 text-center text-stone-400">Loading…</div>
        ) : items.length === 0 ? (
          <div className="py-20 text-center">
            <p className="text-stone-500 dark:text-stone-400 mb-8">Your cart is empty.</p>
            <Link href="/collection" className="inline-block bg-gold text-white px-8 py-4 rounded-full font-bold tracking-widest uppercase">
              Continue Shopping
            </Link>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-16">
            <div className="lg:col-span-2 space-y-8">
              {items.map((item) => (
                <motion.div
                  key={item.id}
                  layout
                  className="flex flex-col sm:flex-row gap-8 p-8 glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-100 dark:border-white/10 shadow-sm items-center transition-colors"
                >
                  <div className="relative w-32 h-32 rounded-2xl overflow-hidden bg-stone-100 dark:bg-stone-800 flex-shrink-0 transition-colors">
                    {item.product.images?.[0]?.url ? (
                      <img src={item.product.images[0].url} alt={item.product.name} className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-stone-400">—</div>
                    )}
                  </div>
                  <div className="flex-1 text-center sm:text-left">
                    <h3 className="text-xl font-serif text-luxury-black dark:text-white mb-1 transition-colors">{item.product.name}</h3>
                    <p className="text-sm text-stone-400 mb-4">{new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.product.price)} each</p>
                    <div className="flex items-center justify-center sm:justify-start gap-6">
                      <div className="flex items-center gap-4 bg-stone-50 dark:bg-stone-800 px-4 py-2 rounded-full border border-stone-100 dark:border-white/10 transition-colors">
                        <button onClick={() => updateQty(item, -1)} className="text-stone-400 hover:text-luxury-black dark:hover:text-white text-xs font-bold">
                          —
                        </button>
                        <span className="text-xs font-bold text-stone-900 dark:text-stone-100">{item.quantity}</span>
                        <button onClick={() => updateQty(item, 1)} className="text-stone-400 hover:text-luxury-black dark:hover:text-white text-xs font-bold">
                          +
                        </button>
                      </div>
                      <button onClick={() => remove(item.id)} className="text-stone-300 hover:text-red-500 transition-colors">
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </div>
                  <div className="text-xl font-medium text-luxury-black dark:text-stone-100 transition-colors">
                    {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.product.price * item.quantity)}
                  </div>
                </motion.div>
              ))}

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-8">
                {[
                  { icon: Truck, title: 'White-Glove Delivery', desc: 'Complimentary on all orders.' },
                  { icon: ShieldCheck, title: 'Authenticity Guaranteed', desc: 'Sealed with our digital seal.' },
                  { icon: RotateCcw, title: 'Refill Service', desc: 'Sustainability in every bottle.' },
                ].map((g, i) => (
                  <div key={i} className="flex flex-col items-center text-center p-6 bg-white/40 dark:bg-zinc-900/40 rounded-3xl transition-colors">
                    <g.icon className="text-gold mb-4" size={24} strokeWidth={1} />
                    <h5 className="text-[10px] font-bold tracking-widest uppercase mb-2 text-luxury-black dark:text-white">{g.title}</h5>
                    <p className="text-[10px] text-stone-400 leading-relaxed uppercase tracking-tighter">{g.desc}</p>
                  </div>
                ))}
              </div>
            </div>

            <div className="lg:col-span-1">
              <div className="glass bg-white dark:bg-zinc-900 p-10 rounded-[2.5rem] border border-stone-100 dark:border-white/10 shadow-xl sticky top-32 transition-colors">
                <h2 className="text-2xl font-serif text-luxury-black dark:text-white mb-8">Summary</h2>
                <div className="space-y-4 mb-8">
                  <div className="flex justify-between text-sm">
                    <span className="text-stone-400 uppercase tracking-widest text-[10px] font-bold">Subtotal</span>
                    <span className="font-medium font-serif text-luxury-black dark:text-white">
                      {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                    </span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-stone-400 uppercase tracking-widest text-[10px] font-bold">Shipping</span>
                    <span className="text-gold text-[10px] font-bold uppercase tracking-widest">Complimentary</span>
                  </div>
                  <div className="h-px bg-stone-100 dark:bg-stone-800 my-4 transition-colors" />
                  <div className="flex justify-between items-baseline">
                    <span className="text-luxury-black dark:text-white font-bold uppercase tracking-widest text-xs">Total</span>
                    <span className="text-3xl font-serif text-luxury-black dark:text-white">
                      {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                    </span>
                  </div>
                </div>
                <div className="space-y-4">
                  <Link
                    href="/checkout"
                    className="block w-full bg-luxury-black dark:bg-gold text-white py-5 rounded-full font-bold tracking-widest uppercase flex items-center justify-center gap-3 hover:bg-stone-800 dark:hover:bg-gold/80 transition-all shadow-xl"
                  >
                    Proceed to Checkout <ArrowRight size={18} />
                  </Link>
                  <Link
                    href="/collection"
                    className="block w-full border border-stone-200 dark:border-stone-800 text-stone-400 dark:text-stone-500 py-5 rounded-full font-bold tracking-widest uppercase text-center text-xs hover:border-luxury-black dark:hover:border-white hover:text-luxury-black dark:hover:text-white transition-all"
                  >
                    Continue Shopping
                  </Link>
                </div>
                <div className="mt-8 text-center">
                  <p className="text-[10px] text-stone-400 uppercase tracking-widest leading-relaxed">
                    SECURE CHECKOUT POWERED BY <br />
                    <span className="text-luxury-black dark:text-white font-bold">AURA AI INTELLIGENCE</span>
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
