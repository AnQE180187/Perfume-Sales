/** @type {import('tailwindcss').Config} */
module.exports = {
  purge: {
    enabled: true,
    content: ["./src/**/*.{js,jsx,ts,tsx,vue}"],
  },
  theme: {
    extend: {
      colors: {
        primary: "var(--primary)",
        "primary-light": "var(--primary-light)",
        gold: "var(--gold)",
        "gold-light": "var(--gold-light)",
        "gold-dark": "var(--gold-dark)",
        secondary: "var(--secondary)",
        background: "var(--background)",
        "background-ivory": "var(--background-ivory)",
        foreground: "var(--foreground)",
        section: "var(--section)",
        card: "var(--card)",
        inactive: "var(--inactive)",
        tabIndicator: "var(--tabIndicator)",
        subtitle: "var(--subtitle)",
        danger: "var(--danger)",
        success: "var(--success)",
        skeleton: "var(--skeleton)",
      },
      fontSize: {
        "3xs": ["10px", "14px"],
        "2xs": ["11px", "15px"],
        xs: ["12px", "16px"],
        sm: ["13px", "18px"],
        base: ["14px", "20px"],
        lg: ["15px", "22px"],
        xl: ["16px", "24px"],
        "2xl": ["18px", "26px"],
        "3xl": ["20px", "28px"],
        "4xl": ["24px", "32px"],
      },
      fontFamily: {
        serif: ["'Playfair Display'", "Georgia", "serif"],
        sans: ["'Montserrat'", "'Inter'", "system-ui", "sans-serif"],
      },
      borderRadius: {
        "2xl": "16px",
        "3xl": "20px",
        "4xl": "24px",
      },
      boxShadow: {
        gold: "0 4px 24px rgba(212, 175, 55, 0.2)",
        "gold-sm": "0 2px 12px rgba(212, 175, 55, 0.15)",
        luxury: "0 8px 32px rgba(0, 0, 0, 0.12)",
        "luxury-sm": "0 4px 16px rgba(0, 0, 0, 0.08)",
      },
      backgroundImage: {
        "gold-gradient": "linear-gradient(135deg, #E2D1B3, #D4AF37)",
        "luxury-gradient": "linear-gradient(135deg, #1a1a2e, #2d2d52)",
        "ivory-gradient": "linear-gradient(180deg, #FAF8F5, #F5F1ED)",
      },
      animation: {
        "pulse-slow": "pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        float: "float 3s ease-in-out infinite",
        shimmer: "shimmer 2s linear infinite",
      },
      keyframes: {
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-6px)" },
        },
        shimmer: {
          "0%": { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
      },
    },
  },
};
