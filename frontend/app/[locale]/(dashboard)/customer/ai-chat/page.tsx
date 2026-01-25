'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { useTranslations } from 'next-intl';
import { useState } from 'react';
import { Send, Sparkles, BrainCircuit, User } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export default function AiChatPage() {
    const navT = useTranslations('navigation');
    const [messages, setMessages] = useState([
        { role: 'ai', content: "Greetings. I am PerfumeGPT. I've analyzed your bio-profile 'Obsidian V' and detected a shift in your emotional frequency towards 'Contemplative'. Shall we explore deeper, colder aquatic notes for your next synthesis?" }
    ]);
    const [input, setInput] = useState('');

    const handleSend = () => {
        if (!input.trim()) return;
        setMessages([...messages, { role: 'user', content: input }]);
        setInput('');
        setTimeout(() => {
            setMessages(prev => [...prev, { role: 'ai', content: "Intriguing choice. Integrating Cedarwood and molecular Ozone to balance that preference. Calculating longevity..." }]);
        }, 1000);
    };

    return (
        <AuthGuard allowedRoles={['customer']}>
            <div className="flex flex-col h-[calc(100vh-80px)] overflow-hidden">
                <div className="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar">
                    <AnimatePresence>
                        {messages.map((msg, i) => (
                            <motion.div
                                key={i}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                className={cn(
                                    "flex gap-4 max-w-3xl",
                                    msg.role === 'user' ? "ml-auto flex-row-reverse" : ""
                                )}
                            >
                                <div className={cn(
                                    "w-10 h-10 rounded-2xl flex items-center justify-center shrink-0 border",
                                    msg.role === 'ai' ? "bg-gold/10 border-gold/20" : "bg-secondary border-border"
                                )}>
                                    {msg.role === 'ai' ? <Sparkles className="w-5 h-5 text-gold" /> : <User className="w-5 h-5" />}
                                </div>
                                <div className={cn(
                                    "p-6 rounded-3xl glass text-sm leading-relaxed",
                                    msg.role === 'ai' ? "border-gold/20 text-foreground" : "border-border bg-secondary/30"
                                )}>
                                    {msg.content}
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </div>

                <div className="p-8 bg-background/50 backdrop-blur-xl shrink-0">
                    <div className="max-w-4xl mx-auto relative group">
                        <div className="absolute -inset-1 bg-gradient-to-r from-gold/50 to-ai/50 rounded-full opacity-20 group-hover:opacity-100 transition duration-500 blur" />
                        <div className="relative flex items-center bg-secondary/80 border border-border rounded-full p-2 pl-8 focus-within:border-gold/50 transition-all shadow-2xl">
                            <input
                                type="text"
                                value={input}
                                onChange={(e) => setInput(e.target.value)}
                                onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                                placeholder="Describe a mood, a memory, or a molecular preference..."
                                className="flex-1 bg-transparent border-none outline-none text-sm font-body py-4"
                            />
                            <button
                                onClick={handleSend}
                                className="w-12 h-12 rounded-full bg-gold flex items-center justify-center text-primary-foreground hover:scale-105 active:scale-95 transition-all shadow-xl"
                            >
                                <Send className="w-5 h-5" />
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </AuthGuard>
    );
}

function cn(...classes: any[]) {
    return classes.filter(Boolean).join(' ');
}
