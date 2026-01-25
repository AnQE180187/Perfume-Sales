"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import {
    Settings,
    User,
    Bell,
    Shield,
    BrainCircuit,
    Sliders,
    Save,
    Plus,
    Globe,
    Languages,
    Database,
    Lock,
    Eye
} from "lucide-react";

export default function AdminSettingsPage() {
    const [activeTab, setActiveTab] = useState("AI Engine Parameters");

    return (
        <div className="flex flex-col gap-8 max-w-5xl pb-12">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-serif font-bold text-luxury-black dark:text-white transition-colors">System Configuration</h1>
                    <p className="text-sm text-stone-400 dark:text-stone-500">Manage the digital soul of the House of Lumina.</p>
                </div>
                <button className="flex items-center gap-3 bg-luxury-black dark:bg-accent text-white px-8 py-3.5 rounded-full text-xs font-bold tracking-widest uppercase hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-xl">
                    <Save size={16} /> Save Changes
                </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 text-luxury-black dark:text-white transition-colors">
                {/* Navigation Links */}
                <div className="space-y-4">
                    {[
                        { icon: Settings, label: "Platform General" },
                        { icon: BrainCircuit, label: "AI Engine Parameters" },
                        { icon: Globe, label: "Localization & Market" },
                        { icon: Shield, label: "Security & Access" },
                        { icon: Bell, label: "Notification Triggers" },
                        { icon: User, label: "Team Management" },
                    ].map((item) => (
                        <button
                            key={item.label}
                            onClick={() => setActiveTab(item.label)}
                            className={`w-full flex items-center gap-4 px-6 py-4 rounded-2xl text-[10px] font-bold tracking-widest uppercase transition-all ${activeTab === item.label
                                    ? "bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 shadow-sm text-luxury-black dark:text-white"
                                    : "text-stone-400 dark:text-stone-500 hover:bg-white/50 dark:hover:bg-white/5"
                                }`}
                        >
                            <item.icon size={16} strokeWidth={activeTab === item.label ? 2.5 : 1.5} className={activeTab === item.label ? "text-accent" : ""} />
                            {item.label}
                        </button>
                    ))}
                </div>

                {/* Main Settings Form */}
                <div className="lg:col-span-2 space-y-8 min-h-[600px]">
                    {activeTab === "AI Engine Parameters" && (
                        <motion.section
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="glass bg-white dark:bg-zinc-900 p-10 rounded-[3rem] border border-stone-200 dark:border-white/10 shadow-sm space-y-10 transition-colors"
                        >
                            <div className="flex items-center gap-3 mb-2">
                                <Sliders size={20} className="text-accent" />
                                <h2 className="text-xl font-serif font-bold text-luxury-black dark:text-white transition-colors">Neural Scent Engine</h2>
                            </div>

                            <div className="space-y-12">
                                <div className="space-y-6">
                                    <div className="flex justify-between">
                                        <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 transition-colors">Creative Temperature</label>
                                        <span className="text-xs font-bold text-accent">0.85 — High Artistry</span>
                                    </div>
                                    <div className="relative h-1 bg-stone-100 dark:bg-stone-800 rounded-full transition-colors">
                                        <div className="absolute top-1/2 left-[85%] -translate-y-1/2 w-4 h-4 rounded-full bg-accent border-4 border-white dark:border-zinc-900 shadow-md cursor-pointer transition-colors" />
                                        <div className="h-full bg-accent w-[85%] rounded-full" />
                                    </div>
                                    <p className="text-[10px] text-stone-400 dark:text-stone-500 leading-relaxed italic transition-colors font-light">
                                        Determines the "uniqueness" of AI matches. Higher values prioritize niche, unexpected note combinations.
                                    </p>
                                </div>

                                <div className="space-y-6">
                                    <div className="flex justify-between">
                                        <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 dark:text-stone-500 transition-colors">Sensitivity Threshold</label>
                                        <span className="text-xs font-bold text-accent">0.92 — Surgical Precision</span>
                                    </div>
                                    <div className="relative h-1 bg-stone-100 dark:bg-stone-800 rounded-full transition-colors">
                                        <div className="absolute top-1/2 left-[92%] -translate-y-1/2 w-4 h-4 rounded-full bg-accent border-4 border-white dark:border-zinc-900 shadow-md cursor-pointer transition-colors" />
                                        <div className="h-full bg-accent w-[92%] rounded-full" />
                                    </div>
                                </div>
                            </div>
                        </motion.section>
                    )}

                    {activeTab === "Localization & Market" && (
                        <motion.section
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="glass bg-white dark:bg-zinc-900 p-10 rounded-[3rem] border border-stone-200 dark:border-white/10 shadow-sm space-y-10 transition-colors"
                        >
                            <div className="flex items-center gap-3 mb-2">
                                <Languages size={20} className="text-accent" />
                                <h2 className="text-xl font-serif font-bold text-luxury-black dark:text-white transition-colors">Localization Patterns</h2>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                                <div className="space-y-4">
                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 transition-colors">Primary Dialect</label>
                                    <select className="w-full bg-stone-50 dark:bg-zinc-800 border border-stone-100 dark:border-white/5 py-4 px-6 rounded-2xl outline-none focus:border-accent text-xs text-luxury-black dark:text-white transition-colors">
                                        <option>English (International)</option>
                                        <option>Tiếng Việt</option>
                                        <option>Français (Heritage)</option>
                                    </select>
                                </div>
                                <div className="space-y-4">
                                    <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400 transition-colors">Currency Basis</label>
                                    <select className="w-full bg-stone-50 dark:bg-zinc-800 border border-stone-100 dark:border-white/5 py-4 px-6 rounded-2xl outline-none focus:border-accent text-xs text-luxury-black dark:text-white transition-colors">
                                        <option>USD ($)</option>
                                        <option>VND (₫)</option>
                                        <option>EUR (€)</option>
                                    </select>
                                </div>
                            </div>

                            <div className="space-y-6">
                                <h3 className="text-[10px] font-bold tracking-widest uppercase text-stone-400 border-b border-stone-100 dark:border-white/5 pb-2">Market Sensitivity</h3>
                                <div className="flex items-center justify-between p-4 bg-stone-50 dark:bg-white/5 rounded-2xl">
                                    <span className="text-xs font-bold uppercase tracking-widest">Regional Pricing Rules</span>
                                    <div className="w-12 h-6 bg-accent rounded-full relative">
                                        <div className="absolute right-1 top-1 w-4 h-4 bg-white rounded-full" />
                                    </div>
                                </div>
                            </div>
                        </motion.section>
                    )}

                    {activeTab === "Security & Access" && (
                        <motion.section
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="glass bg-white dark:bg-zinc-900 p-10 rounded-[3rem] border border-stone-200 dark:border-white/10 shadow-sm space-y-10 transition-colors"
                        >
                            <div className="flex items-center gap-3 mb-2">
                                <Lock size={20} className="text-accent" />
                                <h2 className="text-xl font-serif font-bold text-luxury-black dark:text-white transition-colors">Governance Protocols</h2>
                            </div>

                            <div className="space-y-8">
                                <div className="p-6 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl flex items-center justify-between">
                                    <div className="flex items-center gap-4">
                                        <Shield className="text-emerald-500" size={24} />
                                        <div>
                                            <h4 className="text-sm font-bold uppercase tracking-widest">Two-Factor Authentication</h4>
                                            <p className="text-[10px] text-stone-400 font-light mt-1 uppercase tracking-tighter">Mandatory for all Concierge Rank members.</p>
                                        </div>
                                    </div>
                                    <span className="text-[10px] font-bold text-emerald-500 uppercase tracking-widest">ENABLED</span>
                                </div>

                                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                                    <div className="p-6 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl">
                                        <h4 className="text-xs font-bold uppercase tracking-widest mb-4">Password Persistence</h4>
                                        <select className="w-full bg-transparent border-b border-stone-200 dark:border-white/10 py-2 outline-none text-xs">
                                            <option>Rotate every 90 days</option>
                                            <option>Indefinite / Manual</option>
                                        </select>
                                    </div>
                                    <div className="p-6 bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 rounded-2xl">
                                        <h4 className="text-xs font-bold uppercase tracking-widest mb-4">API Key Access</h4>
                                        <button className="text-[10px] font-bold text-accent uppercase tracking-widest flex items-center gap-2 hover:underline">
                                            <Plus size={14} /> GENERATE NEW TOKEN
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </motion.section>
                    )}

                    {activeTab === "Team Management" && (
                        <motion.section
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="glass bg-white dark:bg-zinc-900 p-10 rounded-[3rem] border border-stone-200 dark:border-white/10 shadow-sm transition-colors"
                        >
                            <div className="flex justify-between items-center mb-10">
                                <div className="flex items-center gap-3">
                                    <User size={20} className="text-accent" />
                                    <h2 className="text-xl font-serif font-bold text-luxury-black dark:text-white transition-colors">Concierge Team</h2>
                                </div>
                                <button className="p-3 bg-luxury-black dark:bg-accent text-white rounded-2xl hover:shadow-lg transition-all">
                                    <Plus size={18} />
                                </button>
                            </div>

                            <div className="space-y-4">
                                {[
                                    { name: "Alexander V.", role: "Head of Concierge", status: "Active" },
                                    { name: "Isabella Smith", role: "Scent Sommelier", status: "Offline" },
                                    { name: "Marcello R.", role: "Warehouse Master", status: "Active" },
                                ].map((member, i) => (
                                    <div key={i} className="flex justify-between items-center p-6 rounded-2xl border border-stone-50 dark:border-white/5 hover:bg-stone-50 dark:hover:bg-white/5 transition-all group">
                                        <div className="flex items-center gap-4">
                                            <div className="w-12 h-12 rounded-full bg-stone-100 dark:bg-zinc-800 flex items-center justify-center font-bold text-sm text-stone-500 dark:text-stone-400 group-hover:bg-accent group-hover:text-white transition-all">
                                                {member.name[0]}
                                            </div>
                                            <div>
                                                <h4 className="text-sm font-bold text-luxury-black dark:text-white transition-colors">{member.name}</h4>
                                                <p className="text-[10px] text-stone-400 dark:text-stone-500 uppercase tracking-widest font-bold transition-colors">{member.role}</p>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-3">
                                            <span className={`text-[9px] font-bold uppercase tracking-widest px-3 py-1 rounded-full ${member.status === 'Active' ? 'text-emerald-500 bg-emerald-50 dark:bg-emerald-500/10' : 'text-stone-300 dark:text-stone-600'}`}>
                                                {member.status}
                                            </span>
                                            <button className="p-2 text-stone-300 hover:text-luxury-black dark:hover:text-white transition-colors">
                                                <Eye size={16} />
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </motion.section>
                    )}

                    {/* Placeholder for other tabs */}
                    {(activeTab === "Platform General" || activeTab === "Notification Triggers") && (
                        <div className="flex flex-col items-center justify-center py-24 glass rounded-[3rem] border border-stone-100 dark:border-white/5">
                            <h3 className="text-xl font-serif text-stone-400 italic">Section Under Synthesis</h3>
                            <p className="text-[10px] uppercase font-bold tracking-widest text-stone-500 mt-2">Coming in next registry update.</p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
