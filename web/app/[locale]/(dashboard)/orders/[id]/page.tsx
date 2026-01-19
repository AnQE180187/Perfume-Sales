"use client";

import React from "react";
import { motion } from "framer-motion";
import {
    ArrowLeft,
    Ship,
    CreditCard,
    User,
    Clock,
    CheckCircle2,
    AlertCircle,
    Truck,
    Package,
    RefreshCcw,
    Printer,
    Download
} from "lucide-react";
import { useRouter } from "next/navigation";
import { useTranslations } from "next-intl";

const orderData = {
    id: "LM-8420",
    date: "Available 24 Oct 2026, 14:20",
    status: "Processing",
    client: {
        name: "Elena Gilbert",
        email: "elena.g@mysticfalls.com",
        phone: "+84 901 234 567",
        memberSince: "Jan 2026",
        rank: "Platinum Tier",
        avatar: "E"
    },
    items: [
        { id: 1, name: "Lumina No. 01 (Extrait)", sku: "LMN-001-EX", price: 240, quantity: 1, image: "https://images.unsplash.com/photo-1541643600914-78b084681c01?auto=format&fit=crop&q=80&w=100" },
        { id: 2, name: "Neural Discovery Set", sku: "LMN-DISC-01", price: 85, quantity: 1, image: "https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&q=80&w=100" }
    ],
    payment: {
        method: "Visa ending in 4242",
        status: "Settled",
        subtotal: 325,
        shipping: 25,
        tax: 0,
        total: 350
    },
    shipping: {
        method: "Priority Sillage Logistics",
        address: "123 Mystic Falls Dr, Mystic Falls, VA 22101, USA",
        trackingId: "LU-SH-99201",
        timeline: [
            { status: "Acquisition Received", date: "Oct 24, 14:20", completed: true },
            { status: "Molecular Stabilization", date: "Oct 24, 16:30", completed: true },
            { status: "Assigned to Logistics", date: "Oct 25, 09:00", completed: false },
            { status: "En Route to Destination", date: "Pending", completed: false }
        ]
    }
};

const statusStyles = {
    "Processing": "bg-blue-50 dark:bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-100 dark:border-blue-500/20",
    "Shipped": "bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 border-indigo-100 dark:border-indigo-500/20",
    "Delivered": "bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-100 dark:border-emerald-500/20",
    "Cancelled": "bg-stone-50 dark:bg-white/5 text-stone-400 dark:text-stone-500 border-stone-100 dark:border-white/10"
};

export default function OrderDetailPage() {
    const router = useRouter();
    const t = useTranslations("Orders");
    const tCommon = useTranslations("Dashboard.sidebar");

    return (
        <div className="flex flex-col gap-8 pb-12">
            <header className="flex flex-col gap-4">
                <button
                    onClick={() => router.back()}
                    className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-stone-500 hover:text-luxury-black dark:hover:text-white transition-colors"
                >
                    <ArrowLeft size={14} /> Back to Manifest
                </button>
                <div className="flex justify-between items-end">
                    <div>
                        <div className="flex items-center gap-3 mb-1">
                            <h1 className="text-3xl font-serif font-bold text-luxury-black dark:text-white">{t("detail")} {orderData.id}</h1>
                            <span className={`text-[10px] px-3 py-1 rounded-full font-bold uppercase border ${statusStyles[orderData.status as keyof typeof statusStyles]}`}>
                                {orderData.status}
                            </span>
                        </div>
                        <p className="text-sm text-stone-500 uppercase tracking-widest font-medium">Placed on {orderData.date}</p>
                    </div>
                    <div className="flex gap-3">
                        <button className="p-3 glass rounded-2xl border border-stone-200 dark:border-white/10 hover:bg-stone-50 dark:hover:bg-white/5 transition-all text-stone-600 dark:text-stone-400">
                            <Printer size={18} />
                        </button>
                        <button className="p-3 glass rounded-2xl border border-stone-200 dark:border-white/10 hover:bg-stone-50 dark:hover:bg-white/5 transition-all text-stone-600 dark:text-stone-400">
                            <Download size={18} />
                        </button>
                        <button className="bg-luxury-black dark:bg-accent text-white px-8 py-3 rounded-2xl text-[10px] font-bold tracking-widest uppercase hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-lg flex items-center gap-2">
                            <RefreshCcw size={14} /> {t("updateStatus")}
                        </button>
                    </div>
                </div>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Main Content */}
                <div className="lg:col-span-2 flex flex-col gap-8">
                    {/* Items Section */}
                    <section className="glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-200 dark:border-white/10 overflow-hidden shadow-sm">
                        <div className="p-8 border-b border-stone-100 dark:border-white/5 flex items-center justify-between">
                            <h3 className="text-sm font-bold uppercase tracking-[.2em] flex items-center gap-2">
                                <Package size={16} className="text-accent" /> {t("items")}
                            </h3>
                            <span className="text-[10px] bg-stone-100 dark:bg-white/5 px-3 py-1 rounded-full font-bold">{orderData.items.length} Units</span>
                        </div>
                        <div className="overflow-x-auto">
                            <table className="w-full">
                                <tbody className="divide-y divide-stone-50 dark:divide-white/5">
                                    {orderData.items.map((item) => (
                                        <tr key={item.id}>
                                            <td className="p-8">
                                                <div className="flex gap-4 items-center">
                                                    <div className="w-16 h-16 rounded-2xl bg-stone-50 dark:bg-white/5 overflow-hidden border border-stone-100 dark:border-white/10">
                                                        <img src={item.image} alt={item.name} className="w-full h-full object-cover" />
                                                    </div>
                                                    <div className="flex flex-col">
                                                        <span className="text-sm font-bold text-luxury-black dark:text-white">{item.name}</span>
                                                        <span className="text-[10px] text-stone-400 uppercase tracking-tighter">SKU: {item.sku}</span>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="text-center text-xs font-bold text-stone-500">x{item.quantity}</td>
                                            <td className="p-8 text-right text-sm font-bold text-luxury-black dark:text-white">${item.price}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                        <div className="p-8 bg-stone-50/50 dark:bg-white/5 flex flex-col gap-4">
                            <div className="flex justify-between text-xs text-stone-500 uppercase tracking-widest font-bold">
                                <span>Subtotal</span>
                                <span>${orderData.payment.subtotal}</span>
                            </div>
                            <div className="flex justify-between text-xs text-stone-500 uppercase tracking-widest font-bold">
                                <span>Logistics & Stabilization</span>
                                <span>${orderData.payment.shipping}</span>
                            </div>
                            <div className="flex justify-between text-lg font-serif font-bold text-luxury-black dark:text-white pt-2 border-t border-stone-100 dark:border-white/10">
                                <span>Total Amount</span>
                                <span>${orderData.payment.total}</span>
                            </div>
                        </div>
                    </section>

                    {/* Payment Info */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <section className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm flex flex-col gap-6">
                            <h3 className="text-sm font-bold uppercase tracking-[.2em] flex items-center gap-2">
                                <CreditCard size={16} className="text-accent" /> {t("payment")}
                            </h3>
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 bg-stone-50 dark:bg-white/5 rounded-2xl flex items-center justify-center border border-stone-100 dark:border-white/10">
                                    <CreditCard size={20} className="text-stone-400" />
                                </div>
                                <div className="flex flex-col">
                                    <span className="text-xs font-bold text-luxury-black dark:text-white">{orderData.payment.method}</span>
                                    <span className="text-[10px] px-2 py-0.5 bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 rounded-full font-bold border border-emerald-100 dark:border-emerald-500/20 w-fit mt-1">
                                        {orderData.payment.status}
                                    </span>
                                </div>
                            </div>
                        </section>

                        <section className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm flex flex-col gap-6">
                            <h3 className="text-sm font-bold uppercase tracking-[.2em] flex items-center gap-2">
                                <Truck size={16} className="text-accent" /> Logistics Provider
                            </h3>
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 bg-stone-50 dark:bg-white/5 rounded-2xl flex items-center justify-center border border-stone-100 dark:border-white/10">
                                    <Ship size={20} className="text-stone-400" />
                                </div>
                                <div className="flex flex-col">
                                    <span className="text-xs font-bold text-luxury-black dark:text-white">{orderData.shipping.method}</span>
                                    <span className="text-[10px] text-stone-500 uppercase tracking-tighter mt-1">ID: {orderData.shipping.trackingId}</span>
                                </div>
                            </div>
                        </section>
                    </div>
                </div>

                {/* Side Content */}
                <div className="flex flex-col gap-8">
                    {/* Customer Profile */}
                    <section className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm">
                        <h3 className="text-sm font-bold uppercase tracking-[.2em] flex items-center gap-2 mb-8">
                            <User size={16} className="text-accent" /> {t("customer")}
                        </h3>
                        <div className="flex flex-col gap-6">
                            <div className="flex items-center gap-4">
                                <div className="w-16 h-16 rounded-full bg-accent flex items-center justify-center text-white text-2xl font-serif">
                                    {orderData.client.avatar}
                                </div>
                                <div className="flex flex-col text-stone-900 dark:text-white">
                                    <span className="text-lg font-bold">{orderData.client.name}</span>
                                    <span className="text-[10px] font-bold text-accent uppercase tracking-widest">{orderData.client.rank}</span>
                                </div>
                            </div>
                            <div className="grid grid-cols-1 gap-4 pt-4 border-t border-stone-100 dark:border-white/5">
                                <div className="flex flex-col">
                                    <span className="text-[8px] font-bold text-stone-400 uppercase tracking-widest">Email</span>
                                    <span className="text-xs font-bold text-luxury-black dark:text-white">{orderData.client.email}</span>
                                </div>
                                <div className="flex flex-col">
                                    <span className="text-[8px] font-bold text-stone-400 uppercase tracking-widest">Phone Resonance</span>
                                    <span className="text-xs font-bold text-luxury-black dark:text-white">{orderData.client.phone}</span>
                                </div>
                                <div className="flex flex-col">
                                    <span className="text-[8px] font-bold text-stone-400 uppercase tracking-widest">Delivery Coordinates</span>
                                    <span className="text-xs text-stone-600 dark:text-stone-400 leading-relaxed font-medium">{orderData.shipping.address}</span>
                                </div>
                            </div>
                        </div>
                    </section>

                    {/* Timeline */}
                    <section className="glass bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm">
                        <h3 className="text-sm font-bold uppercase tracking-[.2em] flex items-center gap-2 mb-8">
                            <Clock size={16} className="text-accent" /> {t("timeline")}
                        </h3>
                        <div className="flex flex-col gap-8">
                            {orderData.shipping.timeline.map((step, i) => (
                                <div key={i} className="flex gap-4 relative">
                                    {i !== orderData.shipping.timeline.length - 1 && (
                                        <div className={`absolute left-[9px] top-6 w-[2px] h-10 ${step.completed ? 'bg-accent' : 'bg-stone-100 dark:bg-white/5'}`} />
                                    )}
                                    <div className={`w-5 h-5 rounded-full border-4 flex flex-shrink-0 mt-1 transition-colors ${step.completed ? 'bg-accent border-accent/20' : 'bg-transparent border-stone-100 dark:border-white/5'}`}>
                                        {step.completed && <CheckCircle2 size={12} className="text-white m-auto" />}
                                    </div>
                                    <div className="flex flex-col">
                                        <span className={`text-xs font-bold ${step.completed ? 'text-luxury-black dark:text-white' : 'text-stone-400'}`}>{step.status}</span>
                                        <span className="text-[10px] text-stone-500">{step.date}</span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </section>

                    {/* Critical Actions */}
                    <button className="flex items-center justify-center gap-3 w-full p-6 glass border border-red-100 dark:border-red-500/20 text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-[2rem] transition-all font-bold uppercase text-[10px] tracking-widest mt-4">
                        <AlertCircle size={16} /> {t("issueRefund")}
                    </button>
                </div>
            </div>
        </div>
    );
}
