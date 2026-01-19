"use client";

import * as React from "react";
import { Moon, Sun } from "lucide-react";
import { useTheme } from "next-themes";
import { motion } from "framer-motion";

export function ThemeToggle() {
    const { theme, setTheme } = useTheme();
    const [mounted, setMounted] = React.useState(false);

    React.useEffect(() => {
        setMounted(true);
    }, []);

    if (!mounted) return <div className="p-2 w-10 h-10" />;

    return (
        <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
            className="p-2.5 rounded-full glass border border-stone-200 dark:border-white/10 text-luxury-black dark:text-white hover:bg-stone-100 dark:hover:bg-white/5 transition-all"
            aria-label="Toggle Theme"
        >
            {theme === "dark" ? (
                <Sun size={18} strokeWidth={1.5} />
            ) : (
                <Moon size={18} strokeWidth={1.5} />
            )}
        </motion.button>
    );
}
