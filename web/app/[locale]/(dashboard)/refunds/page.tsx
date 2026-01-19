"use client";

import React from "react";
import { motion } from "framer-motion";
import {
    RefreshCcw,
    Search,
    Filter,
    Eye,
    CheckCircle2,
    XCircle,
    Clock,
    ArrowUpRight,
    DollarSign,
    ShieldCheck,
    AlertTriangle
} from "lucide-react";
import { useTranslations } from "next-intl";

const refunds = [
    {
        id: "REF-001",
        orderId: "LM-8417",
        client: "Julian Vane",
        amount: "$85",
        reason: "Molecular Mismatch",
        status: "Pending",
        date: "Today, 10:15"
    },
    {
        id: "REF-002",
        orderId: "LM-8412",
        client: "Sarah Connor",
        amount: "$240",
        reason: "Shipping Stabilization Issue",
        status: "Approved",
        date: "Yesterday, 16:45"
    },
    {
        id: "REF-003",
        orderId: "LM-8408",
        client: "Thomas Anderson",
        amount: "$420",
        reason: "Identity Discrepancy",
        status: "Rejected",
        date: "Oct 22, 09:12"
    }
];

const statusStyles = {
    "Pending": "bg-amber-50 dark:bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-100 dark:border-amber-500/20",
    "Approved": "bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-100 dark:border-emerald-500/20",
    "Rejected": "bg-red-50 dark:bg-red-500/10 text-red-600 dark:text-red-400 border-red-100 dark:border-red-500/20"
};

const StatusIcon = ({ status }: { status: string }) => {
    switch (status) {
        case "Pending": return <Clock size={12} />;
        case "Approved": return <CheckCircle2 size={12} />;
        case "Rejected": return <XCircle size={12} />;
        default: return null;
    }
};

export default function RefundsPage() {
    const t = useTranslations("Refunds");

    return (
        <div className="flex flex-col gap-8">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-serif font-bold text-luxury-black dark:text-white transition-colors">{t("title")}</h1>
                    <p className="text-sm text-stone-500 dark:text-stone-500 uppercase tracking-widest font-medium mt-1">Manage global synthesis reversals.</p>
                </div>
                <div className="flex gap-4">
                    <button className="flex items-center gap-2 px-6 py-3 glass dark:bg-zinc-900 border border-stone-200 dark:border-white/10 rounded-2xl text-[10px] font-bold uppercase tracking-widest hover:bg-stone-50 dark:hover:bg-white/5 transition-all text-luxury-black dark:text-white">
                        <Filter size={14} /> Refine Criteria
                    </button>
                    <button className="bg-luxury-black dark:bg-accent text-white px-8 py-3 rounded-2xl text-[10px] font-bold tracking-widest uppercase hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-lg flex items-center gap-2">
                        <RefreshCcw size={14} /> Bulk Reconcile
                    </button>
                </div>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {[
                    { label: "Pending Reversal", value: "12", change: "$1,420 Total", color: "text-amber-500", icon: Clock },
                    { label: "Successful Refunds", value: "148", change: "+14 this week", color: "text-emerald-500", icon: ShieldCheck },
                    { label: "Fraud Protection", value: "99.9%", change: "Resonance Verified", color: "text-indigo-500", icon: ShieldCheck },
                    { label: "Revenue Impact", value: "1.2%", change: "Within safety bounds", color: "text-stone-500", icon: AlertTriangle }
                ].map((stat, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.1 }}
                        className="glass bg-white dark:bg-zinc-900 p-6 rounded-[2rem] border border-stone-200 dark:border-white/10 shadow-sm transition-colors relative overflow-hidden group"
                    >
                        <div className="absolute -right-4 -top-4 text-stone-100 dark:text-white/5 transition-colors group-hover:scale-110 duration-500">
                            <stat.icon size={100} strokeWidth={0.5} />
                        </div>
                        <p className="text-[10px] uppercase tracking-widest text-stone-500 dark:text-stone-500 font-bold mb-3 relative">{stat.label}</p>
                        <h4 className="text-2xl font-bold text-luxury-black dark:text-white mb-2 transition-colors relative">{stat.value}</h4>
                        <span className={`text-[10px] font-bold ${stat.color} relative`}>{stat.change}</span>
                    </motion.div>
                ))}
            </div>

            <section className="glass bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-stone-200 dark:border-white/10 shadow-sm overflow-hidden transition-colors">
                <div className="p-8 border-b border-stone-100 dark:border-white/5 flex gap-4 items-center">
                    <div className="flex-1 relative">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400" size={16} />
                        <input
                            type="text"
                            placeholder="Find refund requests by ID or client resonance..."
                            className="w-full pl-12 pr-6 py-4 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-xl text-xs outline-none focus:border-accent transition-all"
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead>
                            <tr className="text-[10px] font-bold tracking-[.2em] uppercase text-stone-400 border-b border-stone-100 dark:border-white/5 transition-colors">
                                <th className="p-8 pb-4">Refund ID</th>
                                <th className="pb-4">Original Order</th>
                                <th className="pb-4">Client Identity</th>
                                <th className="pb-4">{t("reason")}</th>
                                <th className="pb-4 text-center">{t("status")}</th>
                                <th className="pb-4">{t("amount")}</th>
                                <th className="p-8 pb-4 text-right">Operations</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-stone-50 dark:divide-white/5 transition-colors">
                            {refunds.map((refund, i) => (
                                <tr key={i} className="group hover:bg-stone-50 dark:hover:bg-white/5 transition-all">
                                    <td className="p-8 text-xs font-bold text-luxury-black dark:text-white">{refund.id}</td>
                                    <td>
                                        <div className="flex items-center gap-2 group/link cursor-pointer">
                                            <span className="text-xs font-bold text-accent">{refund.orderId}</span>
                                            <ArrowUpRight size={10} className="text-accent opacity-0 group-hover/link:opacity-100 transition-opacity" />
                                        </div>
                                    </td>
                                    <td>
                                        <span className="text-xs font-bold text-luxury-black dark:text-white">{refund.client}</span>
                                    </td>
                                    <td>
                                        <span className="text-xs text-stone-600 dark:text-stone-400 italic">{refund.reason}</span>
                                    </td>
                                    <td className="text-center">
                                        <span className={`inline-flex items-center gap-1.5 text-[10px] px-3 py-1 rounded-full font-bold uppercase border transition-colors ${statusStyles[refund.status as keyof typeof statusStyles]}`}>
                                            <StatusIcon status={refund.status} />
                                            {refund.status}
                                        </span>
                                    </td>
                                    <td>
                                        <span className="text-xs font-bold text-luxury-black dark:text-white underline decoration-accent/30 underline-offset-4">{refund.amount}</span>
                                    </td>
                                    <td className="p-8 text-right">
                                        <div className="flex justify-end gap-2">
                                            <button className="flex items-center gap-2 px-4 py-2 glass dark:bg-zinc-800 border border-stone-200 dark:border-white/10 rounded-xl text-[10px] font-bold uppercase tracking-widest hover:bg-stone-50 dark:hover:bg-white/5 transition-all text-luxury-black dark:text-white">
                                                <Eye size={14} /> View
                                            </button>
                                            {refund.status === "Pending" && (
                                                <button className="bg-luxury-black dark:bg-accent text-white px-4 py-2 rounded-xl text-[10px] font-bold tracking-widest uppercase hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-md">
                                                    {t("process")}
                                                </button>
                                            )}
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                <footer className="p-8 pt-6 border-t border-stone-100 dark:border-white/5 bg-stone-50/50 dark:bg-white/5 transition-colors flex justify-between items-center text-[10px] font-bold uppercase tracking-widest text-stone-500 dark:text-stone-500">
                    <span>Registry shows 3 requests awaiting reconciliation</span>
                    <div className="flex gap-4">
                        <button className="hover:text-luxury-black dark:hover:text-white transition-colors cursor-pointer">Previous Phase</button>
                        <button className="text-luxury-black dark:text-white transition-colors cursor-pointer">Next Phase</button>
                    </div>
                </footer>
            </section>
        </div>
    );
}
