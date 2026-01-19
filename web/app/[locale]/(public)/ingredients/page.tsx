"use client";

import React from "react";
import { InfoPageLayout } from "@/components/layout/InfoPageLayout";

export default function IngredientsPage() {
    return (
        <InfoPageLayout
            title="The Anthology"
            subtitle="Explore the raw molecular heritage that defines our syntheses."
        >
            <div className="grid md:grid-cols-2 gap-12 italic text-stone-500">
                <div className="space-y-4">
                    <h3 className="text-luxury-black dark:text-white font-serif text-xl not-italic tracking-widest uppercase">The Resins</h3>
                    <p>Omani Frankincense, Aged Labdanum, Somalian Myrrh.</p>
                </div>
                <div className="space-y-4">
                    <h3 className="text-luxury-black dark:text-white font-serif text-xl not-italic tracking-widest uppercase">The Florals</h3>
                    <p>Grasse Jasmine Grandiflorum, Bulgarian Damask Rose, Florentine Iris.</p>
                </div>
                <div className="space-y-4">
                    <h3 className="text-luxury-black dark:text-white font-serif text-xl not-italic tracking-widest uppercase">The Woods</h3>
                    <p>Mysore Sandalwood, Indonesian Oud, Caledonian Cedar.</p>
                </div>
                <div className="space-y-4">
                    <h3 className="text-luxury-black dark:text-white font-serif text-xl not-italic tracking-widest uppercase">The Neutrals</h3>
                    <p>Ethical Ambergris, Molecular Musk, Clean Vetiver.</p>
                </div>
            </div>
        </InfoPageLayout>
    );
}
