"use client";

import React, { useState } from 'react';
import { motion } from 'framer-motion';
import BrandManager from '@/components/admin/catalog/BrandManager';
import CategoryManager from '@/components/admin/catalog/CategoryManager';
import ScentFamilyManager from '@/components/admin/catalog/ScentFamilyManager';
import { Database, LayoutGrid, Palette, Flower } from 'lucide-react';

type Tab = 'brands' | 'categories' | 'scent-families';

const CatalogPage = () => {
    const [activeTab, setActiveTab] = useState<Tab>('brands');

    const tabs = [
        { id: 'brands', label: 'Brands', icon: LayoutGrid },
        { id: 'categories', label: 'Categories', icon: Palette },
        { id: 'scent-families', label: 'Scent Families', icon: Flower },
    ];

    const renderContent = () => {
        switch (activeTab) {
            case 'brands':
                return <BrandManager />;
            case 'categories':
                return <CategoryManager />;
            case 'scent-families':
                return <ScentFamilyManager />;
            default:
                return null;
        }
    };

    return (
        <div className="space-y-10 pb-20">
            {/* Header Area */}
            <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
                <div>
                    <h1 className="text-4xl font-serif text-luxury-black dark:text-white transition-colors tracking-tight">
                        Catalog <span className="italic">Management</span>
                    </h1>
                    <p className="text-[10px] text-stone-400 font-bold tracking-[.4em] uppercase mt-2">
                        Organize your product taxonomy.
                    </p>
                </div>
            </div>

            {/* Tabs */}
             <div className="flex gap-10 border-b border-stone-100 dark:border-white/5 pb-1">
                {tabs.map((tab) => (
                    <button
                        key={tab.id}
                        onClick={() => setActiveTab(tab.id as Tab)}
                        className={`pb-4 text-[10px] font-bold uppercase tracking-[.2em] transition-all relative flex items-center gap-2 ${activeTab === tab.id ? "text-accent" : "text-stone-400 hover:text-stone-600 dark:hover:text-stone-200"}`}
                    >
                        <tab.icon size={14} />
                        {tab.label}
                        {activeTab === tab.id && (
                            <motion.div layoutId="catalogTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-accent" />
                        )}
                    </button>
                ))}
            </div>
            
            {/* Content */}
            <div>
                {renderContent()}
            </div>
        </div>
    );
};

export default CatalogPage;
