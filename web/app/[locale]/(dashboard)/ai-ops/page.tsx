"use client";

import React from "react";
import { motion } from "framer-motion";
import { Sparkles, Activity, Server, Database, AlertTriangle, Play, RefreshCw, Cpu, Zap, BrainCircuit } from "lucide-react";

export default function AIOperationsPage() {
    return (
        <div className="space-y-8 pb-20">
            {/* Header */}
            <div className="flex justify-between items-end">
                <div>
                    <h1 className="text-4xl font-serif text-luxury-black dark:text-white mb-2">AI <span className="italic">Operations</span></h1>
                    <p className="text-stone-400 text-sm">Monitor neural synthesis models, inference health, and predictive accuracy.</p>
                </div>
                <div className="flex gap-4">
                    <button className="bg-stone-100 dark:bg-white/5 text-stone-900 dark:text-white px-6 py-4 rounded-full text-[10px] font-bold tracking-widest uppercase flex items-center gap-3 transition-all border border-stone-200 dark:border-white/5 hover:bg-stone-200 dark:hover:bg-white/10">
                        <RefreshCw size={16} /> Retrain Cluster
                    </button>
                    <button className="bg-luxury-black dark:bg-accent text-white px-8 py-4 rounded-full text-[10px] font-bold tracking-widest uppercase flex items-center gap-3 hover:bg-stone-800 dark:hover:bg-accent/80 transition-all shadow-xl">
                        <Zap size={16} /> Deploy Manifest
                    </button>
                </div>
            </div>

            {/* Live Metrics */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                {[
                    { label: "Model Confidence", value: "98.4%", icon: BrainCircuit, color: "text-purple-500", trend: "+0.2%" },
                    { label: "Inference Latency", value: "124ms", icon: Zap, color: "text-amber-500", trend: "-12ms" },
                    { label: "Daily Predictions", value: "1.2k+", icon: Activity, color: "text-green-500", trend: "+15%" },
                    { label: "System Load", value: "42%", icon: Cpu, color: "text-blue-500", trend: "Stable" },
                ].map((stat, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ delay: i * 0.1 }}
                        className="glass dark:bg-stone-900/50 p-8 rounded-[2.5rem] border border-stone-100 dark:border-white/5"
                    >
                        <div className="flex justify-between items-start mb-6">
                            <div className={`p-4 rounded-2xl bg-stone-50 dark:bg-white/5 ${stat.color}`}>
                                <stat.icon size={22} />
                            </div>
                            <span className="text-[10px] text-stone-400 font-bold uppercase tracking-widest">{stat.trend}</span>
                        </div>
                        <h3 className="text-3xl font-serif text-stone-900 dark:text-white mb-2">{stat.value}</h3>
                        <p className="text-[10px] text-stone-400 font-bold tracking-widest uppercase">{stat.label}</p>
                    </motion.div>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Active Models */}
                <div className="lg:col-span-2 bg-white dark:bg-stone-900/40 rounded-[3rem] p-10 border border-stone-100 dark:border-white/5 shadow-sm transition-colors">
                    <h2 className="text-2xl font-serif text-luxury-black dark:text-white mb-8 flex items-center gap-4">
                        <Server size={24} className="text-accent" /> Active Neural Models
                    </h2>
                    <div className="space-y-6">
                        {[
                            { name: "Olfactory Identity Synthesizer", version: "v4.2.1", status: "In Production", load: 68, power: 92 },
                            { name: "Predictive Recommendation Engine", version: "v4.0.8", status: "In Production", load: 34, power: 88 },
                            { name: "Market Trend Analyzer", version: "v3.9.5", status: "Testing", load: 12, power: 95 }
                        ].map((model, i) => (
                            <div key={i} className="p-8 bg-stone-50 dark:bg-white/5 rounded-[2rem] border border-stone-100 dark:border-white/5 group hover:border-accent transition-all">
                                <div className="flex justify-between items-start mb-6">
                                    <div>
                                        <h4 className="text-sm font-bold text-luxury-black dark:text-white uppercase tracking-widest">{model.name}</h4>
                                        <p className="text-[10px] text-stone-400 font-mono mt-1">{model.version} • {model.status}</p>
                                    </div>
                                    <button className="p-2 border border-stone-200 dark:border-white/10 rounded-full hover:bg-white dark:hover:bg-accent transition-colors">
                                        <Play size={14} className="text-stone-400 group-hover:text-luxury-black dark:group-hover:text-white" />
                                    </button>
                                </div>
                                <div className="space-y-4">
                                    <div className="flex justify-between text-[9px] font-bold uppercase tracking-widest">
                                        <span className="text-stone-400">Computational Load</span>
                                        <span className="text-luxury-black dark:text-white">{model.load}%</span>
                                    </div>
                                    <div className="w-full h-1 bg-stone-200 dark:bg-white/10 rounded-full overflow-hidden">
                                        <motion.div
                                            initial={{ width: 0 }}
                                            animate={{ width: `${model.load}%` }}
                                            className="h-full bg-accent"
                                        />
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* System Logs & Alerts */}
                <div className="bg-white dark:bg-stone-900/40 rounded-[3rem] p-10 border border-stone-100 dark:border-white/5 shadow-sm transition-colors flex flex-col">
                    <h2 className="text-2xl font-serif text-luxury-black dark:text-white mb-8 flex items-center gap-4">
                        <AlertTriangle size={24} className="text-amber-500" /> Neural Logs
                    </h2>
                    <div className="flex-1 space-y-6 overflow-y-auto max-h-[500px] pr-2 scrollbar-hide">
                        {[
                            { time: "12:04:22", msg: "Inference drift detected in v4.2.1", type: "warning" },
                            { time: "11:58:10", msg: "Synthesis manifest successfully deployed", type: "info" },
                            { time: "11:42:05", msg: "Data node 'FR-Paris-01' high latency", type: "error" },
                            { time: "11:30:55", msg: "New customer DNA fingerprinting complete", type: "info" },
                            { time: "11:15:20", msg: "Unauthorized model access attempt blocked", type: "error" },
                            { time: "10:55:00", msg: "Database optimization cluster optimized", type: "info" }
                        ].map((log, i) => (
                            <div key={i} className="flex gap-4">
                                <span className="text-[9px] font-mono text-stone-400 pt-1">{log.time}</span>
                                <div className="flex-1">
                                    <p className={`text-xs font-medium ${log.type === 'error' ? 'text-red-500' :
                                            log.type === 'warning' ? 'text-amber-500' :
                                                'text-stone-500 dark:text-stone-400'
                                        }`}>
                                        {log.msg}
                                    </p>
                                </div>
                            </div>
                        ))}
                    </div>
                    <button className="mt-8 w-full py-4 border border-stone-100 dark:border-white/10 rounded-full text-[10px] font-bold tracking-widest uppercase text-stone-400 hover:text-luxury-black dark:hover:text-white transition-colors">
                        View Full Archives
                    </button>
                </div>
            </div>

            {/* Neural Cluster Health Section */}
            <div className="p-10 bg-luxury-black rounded-[3.5rem] text-white relative overflow-hidden">
                <div className="absolute top-0 right-0 w-1/3 h-full bg-accent/20 blur-[120px] pointer-events-none" />
                <div className="relative z-10 flex flex-col lg:flex-row justify-between items-center gap-12">
                    <div className="max-w-xl">
                        <div className="flex items-center gap-3 text-accent mb-6">
                            <Sparkles size={20} />
                            <span className="text-[10px] font-bold tracking-[.4em] uppercase">Architecture Integrity</span>
                        </div>
                        <h2 className="text-4xl font-serif mb-6 italic">Neural Mesh Core</h2>
                        <p className="text-stone-400 text-sm leading-relaxed mb-8">
                            Our proprietary synthesizer core is operating at peak computational efficiency. Predictive drift is currently 0.04% below the established threshold for Luxury Protocol.
                        </p>
                        <div className="flex gap-6">
                            <div className="flex items-center gap-2">
                                <Database size={16} className="text-accent" />
                                <span className="text-xs font-mono">1.2 PB Data Lake</span>
                            </div>
                            <div className="flex items-center gap-2">
                                <Server size={16} className="text-accent" />
                                <span className="text-xs font-mono">14 Clusters Active</span>
                            </div>
                        </div>
                    </div>
                    <div className="relative w-64 h-64 border-2 border-accent/20 rounded-full flex items-center justify-center p-8">
                        <div className="absolute inset-0 border-t-2 border-accent rounded-full animate-spin duration-[3s]" />
                        <BrainCircuit size={80} className="text-accent" />
                    </div>
                </div>
            </div>
        </div>
    );
}
