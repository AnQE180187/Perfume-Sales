"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import {
    Users,
    Shield,
    UserPlus,
    Search,
    Filter,
    MoreHorizontal,
    CheckCircle2,
    XCircle,
    UserCheck,
    History,
    Key
} from "lucide-react";

const mockUsers = [
    { id: 1, name: "Alexander Dupont", email: "a.dupont@lumina.com", role: "Super Admin", status: "Active", access: ["all"], lastLogin: "2 mins ago" },
    { id: 2, name: "Sarah Jenkins", email: "s.jenkins@lumina.com", role: "AI Scientist", status: "Active", access: ["ai-analytics", "inventory"], lastLogin: "1 hour ago" },
    { id: 3, name: "Marcello Rossi", email: "m.rossi@lumina.com", role: "Warehouse Manager", status: "Inactive", access: ["inventory", "orders"], lastLogin: "2 days ago" },
    { id: 4, name: "Elena Gilbert", email: "e.gilbert@lumina.com", role: "Marketing Lead", status: "Active", access: ["journal", "clients"], lastLogin: "5 mins ago" },
];

export default function UsersRBACPage() {
    const [searchQuery, setSearchQuery] = useState("");
    const [activeTab, setActiveTab] = useState("Internal Staff");

    return (
        <div className="space-y-8 pb-20">
            {/* Header */}
            <div className="flex justify-between items-end">
                <div>
                    <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-2">Access <span className="italic">& Rights</span></h1>
                    <p className="text-stone-400 text-sm">Manage administrative access and role-based security protocols for the House of Lumina.</p>
                </div>
                <button className="bg-luxury-black dark:bg-accent text-white px-8 py-4 rounded-full text-[10px] font-bold tracking-widest uppercase flex items-center gap-3 hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-xl">
                    <UserPlus size={16} /> Invite Executive
                </button>
            </div>

            {/* Navigation Tabs */}
            <div className="flex gap-8 border-b border-stone-100 dark:border-white/5 pb-1">
                {["Internal Staff", "Permission Models", "Audit Logs"].map((tab) => (
                    <button
                        key={tab}
                        onClick={() => setActiveTab(tab)}
                        className={`pb-4 text-[10px] font-bold uppercase tracking-[.2em] transition-all relative ${activeTab === tab ? "text-accent" : "text-stone-400 hover:text-stone-600 dark:hover:text-stone-200"
                            }`}
                    >
                        {tab}
                        {activeTab === tab && (
                            <motion.div layoutId="activeTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-accent" />
                        )}
                    </button>
                ))}
            </div>

            {activeTab === "Internal Staff" && (
                <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="space-y-8"
                >
                    {/* Role Distribution Cards */}
                    <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                        {[
                            { label: "Total Privileged", value: "12", icon: Users, color: "text-blue-500" },
                            { label: "Active Nodes", value: "9", icon: CheckCircle2, color: "text-green-500" },
                            { label: "Revoked Access", value: "1", icon: XCircle, color: "text-red-500" },
                            { label: "Security Models", value: "5", icon: Shield, color: "text-accent" },
                        ].map((stat, i) => (
                            <div
                                key={i}
                                className="glass dark:bg-stone-900/50 p-6 rounded-[2rem] border border-stone-100 dark:border-white/5 shadow-sm"
                            >
                                <div className="flex justify-between items-start mb-4">
                                    <div className={`p-3 rounded-2xl bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/5 ${stat.color}`}>
                                        <stat.icon size={20} />
                                    </div>
                                </div>
                                <h3 className="text-2xl font-serif text-stone-900 dark:text-white mb-1">{stat.value}</h3>
                                <p className="text-[10px] text-stone-400 font-bold tracking-widest uppercase">{stat.label}</p>
                            </div>
                        ))}
                    </div>

                    {/* Filter & Search Bar */}
                    <div className="flex flex-col md:flex-row gap-4 items-center justify-between bg-white dark:bg-stone-900/40 p-4 rounded-[2rem] border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                        <div className="flex items-center gap-4 bg-stone-50 dark:bg-white/5 px-6 py-3 rounded-full w-full md:w-96 border border-stone-100 dark:border-white/5 transition-colors">
                            <Search size={18} className="text-stone-400" />
                            <input
                                type="text"
                                placeholder="Search by name or email..."
                                className="bg-transparent border-none outline-none text-sm w-full text-stone-900 dark:text-stone-100 transition-colors"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>
                        <div className="flex items-center gap-4">
                            <button className="flex items-center gap-2 px-6 py-2.5 rounded-full border border-stone-100 dark:border-white/5 text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all shadow-sm">
                                <Filter size={14} /> Role: All
                            </button>
                            <button className="flex items-center gap-2 px-6 py-2.5 rounded-full border border-stone-100 dark:border-white/5 text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-all shadow-sm">
                                Status: Active
                            </button>
                        </div>
                    </div>

                    {/* Users Table */}
                    <div className="bg-white dark:bg-stone-900/40 rounded-[2.5rem] border border-stone-100 dark:border-white/5 overflow-hidden shadow-sm transition-colors">
                        <table className="w-full text-left">
                            <thead>
                                <tr className="border-b border-stone-100 dark:border-white/5 bg-stone-50/50 dark:bg-white/2">
                                    <th className="px-8 py-6 text-[10px] font-bold tracking-[.2em] uppercase text-stone-400">Identity</th>
                                    <th className="px-8 py-6 text-[10px] font-bold tracking-[.2em] uppercase text-stone-400">Security Rank</th>
                                    <th className="px-8 py-6 text-[10px] font-bold tracking-[.2em] uppercase text-stone-400">Network Status</th>
                                    <th className="px-8 py-6 text-[10px] font-bold tracking-[.2em] uppercase text-stone-400">Last Pulse</th>
                                    <th className="px-8 py-6 text-right"></th>
                                </tr>
                            </thead>
                            <tbody>
                                {mockUsers.map((user) => (
                                    <tr key={user.id} className="border-b border-stone-100 dark:border-white/5 last:border-none group hover:bg-stone-50/80 dark:hover:bg-white/5 transition-all">
                                        <td className="px-8 py-6">
                                            <div className="flex items-center gap-4">
                                                <div className="w-10 h-10 rounded-full bg-stone-100 dark:bg-white/5 border border-stone-200 dark:border-white/10 flex items-center justify-center font-serif text-luxury-black dark:text-white transition-colors">
                                                    {user.name[0]}
                                                </div>
                                                <div>
                                                    <p className="text-sm font-bold text-luxury-black dark:text-white transition-colors">{user.name}</p>
                                                    <p className="text-[10px] text-stone-400 uppercase tracking-tighter">{user.email}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-8 py-6">
                                            <div className="flex items-center gap-2">
                                                <Shield size={14} className="text-accent" />
                                                <span className="text-[10px] font-bold tracking-widest uppercase text-stone-600 dark:text-stone-300 transition-colors">{user.role}</span>
                                            </div>
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className={`text-[9px] font-bold tracking-[.2em] uppercase px-3 py-1 rounded-full border ${user.status === "Active"
                                                    ? "bg-green-100 text-green-600 border-green-200 dark:bg-green-500/10 dark:text-green-400 dark:border-green-500/20"
                                                    : "bg-stone-100 text-stone-400 border-stone-200 dark:bg-white/5 dark:text-stone-500 dark:border-white/10"
                                                }`}>
                                                {user.status}
                                            </span>
                                        </td>
                                        <td className="px-8 py-6 text-[10px] text-stone-500 font-bold uppercase tracking-widest">{user.lastLogin}</td>
                                        <td className="px-8 py-6 text-right">
                                            <button className="p-2 hover:bg-white dark:hover:bg-stone-800 rounded-xl transition-all text-stone-400 hover:text-luxury-black dark:hover:text-white border border-transparent hover:border-stone-100 dark:hover:border-white/5">
                                                <MoreHorizontal size={18} />
                                            </button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </motion.div>
            )}

            {activeTab === "Permission Models" && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 py-12">
                    {[
                        { title: "Super Admin", icon: Shield, desc: "Infinite clearance. Access to neural cores, financial manifolds, and user synthesis.", nodes: 2 },
                        { title: "AI Scientist", icon: BrainCircuit, desc: "Deep access to model configuration, dataset archives, and inference metrics.", nodes: 3 },
                        { title: "Concierge Lead", icon: UserCheck, desc: "Management of client profiles, consultation results, and private collections.", nodes: 4 },
                        { title: "Logistics Master", icon: Key, desc: "Access to inventory manifolds, global shipping logs, and warehouse synchronization.", nodes: 3 }
                    ].map((role, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ delay: i * 0.1 }}
                            className="glass p-10 rounded-[3rem] border border-stone-100 dark:border-white/5 hover:border-accent transition-all group"
                        >
                            <div className="flex justify-between items-start mb-8">
                                <div className="w-16 h-16 rounded-[1.5rem] bg-stone-50 dark:bg-white/5 flex items-center justify-center text-stone-400 group-hover:text-accent group-hover:bg-accent/10 transition-all duration-500">
                                    <role.icon size={32} strokeWidth={1} />
                                </div>
                                <span className="text-[10px] font-bold text-accent tracking-widest">{role.nodes} ACTIVE NODES</span>
                            </div>
                            <h3 className="text-xl font-serif font-bold text-luxury-black dark:text-white mb-4 italic">{role.title}</h3>
                            <p className="text-sm text-stone-500 leading-relaxed font-light mb-8">{role.desc}</p>
                            <button className="text-[10px] font-bold uppercase tracking-[.3em] text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors">
                                Configure Protocol —
                            </button>
                        </motion.div>
                    ))}
                </div>
            )}

            {activeTab === "Audit Logs" && (
                <div className="bg-white dark:bg-stone-900/40 rounded-[2.5rem] border border-stone-100 dark:border-white/5 overflow-hidden shadow-sm p-10">
                    <div className="flex items-center gap-4 mb-10">
                        <History size={24} className="text-accent" />
                        <h2 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest">Operation Pulse</h2>
                    </div>
                    <div className="space-y-6">
                        {[
                            { time: "Today, 14:20", user: "Alexander D.", action: "Updated model confidence threshold", risk: "Low" },
                            { time: "Today, 12:05", user: "Sarah J.", action: "Exported Q4 AI Analytics manifest", risk: "Medium" },
                            { time: "Yesterday, 09:12", user: "System", action: "Automatic token rotation executed", risk: "Informational" },
                        ].map((log, i) => (
                            <div key={i} className="flex justify-between items-center py-4 border-b border-stone-50 dark:border-white/5 last:border-none">
                                <div className="flex flex-col">
                                    <span className="text-xs font-bold text-luxury-black dark:text-white">{log.action}</span>
                                    <span className="text-[10px] text-stone-400 uppercase tracking-tighter">{log.user} • {log.time}</span>
                                </div>
                                <span className={`text-[8px] font-bold px-3 py-1 rounded-full uppercase tracking-widest ${log.risk === 'Medium' ? 'bg-amber-500/10 text-amber-500' : 'text-stone-400 bg-stone-100 dark:bg-white/5'
                                    }`}>
                                    {log.risk}
                                </span>
                            </div>
                        ))}
                    </div>
                </div>
            )}

            {/* Role Management Info */}
            <div className="p-10 bg-accent/5 border border-accent/10 rounded-[3rem] relative overflow-hidden">
                <div className="absolute top-0 right-0 w-1/3 h-full bg-accent/10 blur-[100px] pointer-events-none" />
                <div className="flex items-center gap-6 mb-6">
                    <div className="w-12 h-12 bg-white dark:bg-zinc-900 rounded-2xl flex items-center justify-center shadow-lg">
                        <Shield className="text-accent" size={24} />
                    </div>
                    <h2 className="text-xl font-serif text-luxury-black dark:text-white uppercase tracking-widest">Protocol Intelligence</h2>
                </div>
                <p className="text-xs text-stone-500 dark:text-stone-400 leading-relaxed uppercase tracking-tighter max-w-2xl font-medium">
                    Lumina utilizes Attribute-Based Access Control (ABAC) synced with biometric neural hash verification. Any changes to security ranks will trigger a full system audit and temporary token invalidation.
                </p>
            </div>
        </div>
    );
}
