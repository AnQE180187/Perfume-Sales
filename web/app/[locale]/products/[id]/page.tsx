"use client";

import React, { useState, useEffect } from "react";
import ProductDetailClientPage from "./ProductDetailClientPage";

export default function ProductDetailPage() {
    const [isClient, setIsClient] = useState(false);

    useEffect(() => {
        setIsClient(true);
    }, []);

    return <>{isClient ? <ProductDetailClientPage /> : null}</>;
}