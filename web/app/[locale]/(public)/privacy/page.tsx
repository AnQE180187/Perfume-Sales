"use client";

import React from "react";
import { InfoPageLayout } from "@/components/layout/InfoPageLayout";

export default function PrivacyPage() {
    return (
        <InfoPageLayout
            title="Privacy Covenant"
            subtitle="How we safeguard your olfactory identity and digital resonance."
        >
            <div className="space-y-12">
                <section>
                    <h2 className="text-2xl mb-6">Neural Data Integrity</h2>
                    <p>
                        Your olfactory preferences are unique to your biological and emotional profile.
                        We treat this neural data with the highest level of cryptographic security,
                        ensuring that your "Scent DNA" is never shared with third-party entities.
                    </p>
                </section>

                <section>
                    <h2 className="text-2xl mb-6">Biological Discretion</h2>
                    <p>
                        Any biological markers collected during the AI consultation process are
                        transiently processed and immediately anonymized. We do not store raw biological data
                        beyond the duration of your current synthesis session.
                    </p>
                </section>

                <section>
                    <h2 className="text-2xl mb-6">Concierge Transparency</h2>
                    <p>
                        You have the right to request a complete purge of your olfactory profile
                        from our systems at any time. Our concierge team is available to oversee
                        the manual deletion of your digital footprint within the House of Lumina.
                    </p>
                </section>
            </div>
        </InfoPageLayout>
    );
}
