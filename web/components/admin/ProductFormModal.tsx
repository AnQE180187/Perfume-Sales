"use client";

import React, { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, UploadCloud, Trash2 } from "lucide-react";
import { useForm, Controller } from "react-hook-form";
import { apiClient } from "@/lib/api-client";
import Image from "next/image";
import { toast } from "react-hot-toast";

// Interfaces based on Prisma schema
interface ProductImage {
    id: number;
    url: string;
    publicId: string;
    order: number;
}

interface Product {
    id: string;
    name: string;
    slug: string;
    brandId: number;
    categoryId?: number | null;
    scentFamilyId?: number | null;
    description?: string | null;
    gender?: string | null;
    longevity?: string | null;
    concentration?: string | null;
    price: number;
    currency: string;
    isActive: boolean;
    images: ProductImage[];
    inventories: { storeId: number; quantity: number }[];
}

interface Brand {
    id: number;
    name: string;
}

interface Category {
    id: number;
    name: string;
}

interface ScentFamily {
    id: number;
    name: string;
}

interface ProductFormData {
    name: string;
    slug: string;
    brandId: number | string;
    categoryId: number | string;
    scentFamilyId: number | string;
    description: string;
    gender: string;
    longevity: string;
    concentration: string;
    price: number;
    currency: string;
    isActive: boolean;
    stock: number;
}

interface ProductFormModalProps {
    isOpen: boolean;
    onClose: () => void;
    onProductSaved: () => void;
    currentProduct?: Product | null;
    mainStoreId: number;
}

// Main Component
export const ProductFormModal = ({
    isOpen,
    onClose,
    onProductSaved,
    currentProduct,
    mainStoreId,
}: ProductFormModalProps) => {
    const {
        register,
        handleSubmit,
        control,
        reset,
        formState: { errors, isSubmitting },
    } = useForm<ProductFormData>({
        defaultValues: {
            name: "",
            slug: "",
            brandId: "",
            categoryId: "",
            scentFamilyId: "",
            description: "",
            gender: "Unisex",
            longevity: "",
            concentration: "",
            price: 0,
            currency: "VND",
            isActive: true,
            stock: 0,
        }
    });

    const [brands, setBrands] = useState<Brand[]>([]);
    const [categories, setCategories] = useState<Category[]>([]);
    const [scentFamilies, setScentFamilies] = useState<ScentFamily[]>([]);
    const [existingImages, setExistingImages] = useState<ProductImage[]>([]);
    const [newImages, setNewImages] = useState<File[]>([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const isEditMode = !!currentProduct;

    const fetchDropdownData = useCallback(async () => {
        setIsLoading(true);
        setError(null);
        try {
            const [brandsRes, categoriesRes, scentFamiliesRes] = await Promise.all([
                apiClient.get("/admin/brands"),
                apiClient.get("/admin/categories"),
                apiClient.get("/admin/scent-families"),
            ]);

            if (brandsRes.error) {
                throw new Error(`Brands: ${brandsRes.error}`);
            }
            if (categoriesRes.error) {
                throw new Error(`Categories: ${categoriesRes.error}`);
            }
            if (scentFamiliesRes.error) {
                throw new Error(`Scent Families: ${scentFamiliesRes.error}`);
            }
            
            setBrands(brandsRes.data || []);
            setCategories(categoriesRes.data || []);
            setScentFamilies(scentFamiliesRes.data || []);

        } catch (err: any) {
            const errorMessage = err.message || "Failed to load initial data. Please try again.";
            setError(errorMessage);
            console.error("Error fetching dropdown data:", err);
            toast.error(errorMessage);
        } finally {
            setIsLoading(false);
        }
    }, []);

    useEffect(() => {
        if (isOpen) {
            fetchDropdownData();
        }
    }, [isOpen, fetchDropdownData]);

    useEffect(() => {
        if (isOpen) {
            if (isEditMode && currentProduct) {
                // Edit mode
                const stock = currentProduct.inventories.find(inv => inv.storeId === mainStoreId)?.quantity ?? 0;
                reset({
                    name: currentProduct.name,
                    slug: currentProduct.slug,
                    brandId: currentProduct.brandId,
                    categoryId: currentProduct.categoryId ?? "",
                    scentFamilyId: currentProduct.scentFamilyId ?? "",
                    description: currentProduct.description ?? "",
                    gender: currentProduct.gender ?? "Unisex",
                    longevity: currentProduct.longevity ?? "",
                    concentration: currentProduct.concentration ?? "",
                    price: currentProduct.price,
                    currency: currentProduct.currency,
                    isActive: currentProduct.isActive,
                    stock: stock,
                });
                setExistingImages(currentProduct.images || []);
            } else {
                // Add mode
                reset({
                    name: "",
                    slug: "",
                    brandId: "",
                    categoryId: "",
                    scentFamilyId: "",
                    description: "",
                    gender: "Unisex",
                    longevity: "",
                    concentration: "",
                    price: 0,
                    currency: "VND",
                    isActive: true,
                    stock: 0,
                });
                setExistingImages([]);
            }
            setNewImages([]);
            setError(null);
        }
    }, [isOpen, isEditMode, currentProduct, reset, mainStoreId]);

    const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files) {
            setNewImages((prev) => [...prev, ...Array.from(e.target.files ?? [])]);
        }
    };

    const handleRemoveNewImage = (indexToRemove: number) => {
        setNewImages((prev) => prev.filter((_, index) => index !== indexToRemove));
    };

    const handleRemoveExistingImage = async (imageId: number) => {
        if (!currentProduct) return;
        toast.promise(
            apiClient.delete(`/admin/products/${currentProduct.id}/images/${imageId}`),
            {
                loading: 'Deleting image...',
                success: () => {
                    setExistingImages((prev) => prev.filter((img) => img.id !== imageId));
                    onProductSaved(); // Refresh data
                    return 'Image deleted!';
                },
                error: 'Failed to delete image.',
            }
        );
    };

    const onSubmit = async (data: ProductFormData) => {
        setError(null);

        const { brandId, categoryId, scentFamilyId, stock, ...rest } = data;
        const payload: any = { ...rest };

        // Add IDs only if they are not empty
        if (brandId && brandId !== "") payload.brandId = brandId;
        if (categoryId && categoryId !== "") payload.categoryId = categoryId;
        if (scentFamilyId && scentFamilyId !== "") payload.scentFamilyId = scentFamilyId;

        if(stock !== undefined && stock > 0) {
            payload.inventory = {
                storeId: mainStoreId,
                quantity: stock,
            };
        }

        console.log("Payload:", payload);

        try {
            let productResponse;
            if (isEditMode && currentProduct) {
                productResponse = await apiClient.patch(`/admin/products/${currentProduct.id}`, payload);
            } else {
                productResponse = await apiClient.post("/admin/products", payload);
            }

            const productId = productResponse.data?.id;
            if (!productId) {
                throw new Error("Failed to get product ID from response.");
            }

            // Handle image uploads
            if (newImages.length > 0) {
                const formData = new FormData();
                newImages.forEach(file => formData.append('images', file));
                await apiClient.post(`/admin/products/${productId}/images`, formData, {
                    headers: { 'Content-Type': 'multipart/form-data' }
                });
            }
            
            toast.success(`Product ${isEditMode ? 'updated' : 'created'} successfully!`);
            onProductSaved();
            onClose();

        } catch (err: unknown) {
            let errorMessage = `Failed to ${isEditMode ? 'update' : 'create'} product.`;
            if (err instanceof Error) {
                errorMessage = err.message;
            }
            setError(errorMessage);
            toast.error(errorMessage);
            console.error(err);
        }
    };

    if (!isOpen) return null;

    return (
        <AnimatePresence>
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="fixed inset-0 bg-black/50 z-[100] flex items-center justify-center p-4"
                onClick={onClose}
            >
                <motion.div
                    initial={{ scale: 0.9, opacity: 0, y: 50 }}
                    animate={{ scale: 1, opacity: 1, y: 0 }}
                    exit={{ scale: 0.9, opacity: 0, y: 50 }}
                    className="bg-white dark:bg-gray-900 rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] flex flex-col"
                    onClick={(e) => e.stopPropagation()}
                >
                    {/* Header */}
                    <div className="flex justify-between items-center p-6 border-b border-gray-200 dark:border-gray-700">
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                            {isEditMode ? "Edit Product" : "Create New Product"}
                        </h2>
                        <button
                            onClick={onClose}
                            className="p-2 rounded-full text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800"
                        >
                            <X size={24} />
                        </button>
                    </div>

                    {/* Form Body */}
                    <form onSubmit={handleSubmit(onSubmit)} className="flex-grow overflow-y-auto p-6 space-y-6">
                        {isLoading && <p>Loading data...</p>}
                        {error && <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">{error}</div>}

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Left Column */}
                            <div className="space-y-6">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Name</label>
                                    <input {...register("name", { required: "Name is required" })} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                                    {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name.message}</p>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Slug</label>
                                    <input {...register("slug", { required: "Slug is required" })} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                                    {errors.slug && <p className="text-red-500 text-xs mt-1">{errors.slug.message}</p>}
                                </div>
                                 <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Brand</label>
                                    <Controller
                                        name="brandId"
                                        control={control}
                                        rules={{ required: "Brand is required" }}
                                        render={({ field }) => (
                                            <select 
                                                {...field} 
                                                value={field.value || ""}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : "")}
                                                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600"
                                            >
                                                <option value="">Select a brand</option>
                                                {brands.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
                                            </select>
                                        )}
                                    />
                                    {errors.brandId && <p className="text-red-500 text-xs mt-1">{errors.brandId.message}</p>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Category</label>
                                    <Controller
                                        name="categoryId"
                                        control={control}
                                        render={({ field }) => (
                                            <select 
                                                {...field}
                                                value={field.value || ""}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : "")}
                                                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600"
                                            >
                                                <option value="">Select a category</option>
                                                {categories.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                                            </select>
                                        )}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Scent Family</label>
                                     <Controller
                                        name="scentFamilyId"
                                        control={control}
                                        render={({ field }) => (
                                            <select 
                                                {...field}
                                                value={field.value || ""}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : "")}
                                                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600"
                                            >
                                                <option value="">Select a scent family</option>
                                                {scentFamilies.map(sf => <option key={sf.id} value={sf.id}>{sf.name}</option>)}
                                            </select>
                                        )}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Description</label>
                                    <textarea {...register("description")} rows={4} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                                </div>
                            </div>
                            
                            {/* Right Column */}
                            <div className="space-y-6">
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Price</label>
                                        <input type="number" {...register("price", { required: true, valueAsNumber: true, min: 0 })} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                                        {errors.price && <p className="text-red-500 text-xs mt-1">A valid price is required.</p>}
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Stock</label>
                                        <input type="number" {...register("stock", { required: true, valueAsNumber: true, min: 0 })} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                                        {errors.stock && <p className="text-red-500 text-xs mt-1">A valid stock quantity is required.</p>}
                                    </div>
                                </div>
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Gender</label>
                                        <select {...register("gender")} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600">
                                            <option value="Unisex">Unisex</option>
                                            <option value="Male">Male</option>
                                            <option value="Female">Female</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Concentration</label>
                                        <input {...register("concentration")} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                                    </div>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Longevity</label>
                                    <input {...register("longevity")} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                                </div>
                                <div>
                                     <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
                                    <div className="mt-2 flex items-center">
                                         <Controller
                                            name="isActive"
                                            control={control}
                                            render={({ field }) => (
                                                <label className="inline-flex items-center cursor-pointer">
                                                  <input type="checkbox" className="sr-only peer" checked={field.value} onChange={field.onChange} />
                                                  <div className="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                                                  <span className="ms-3 text-sm font-medium text-gray-900 dark:text-gray-300">Active</span>
                                                </label>
                                            )}
                                        />
                                    </div>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Images</label>
                                    <div className="mt-2 flex flex-wrap gap-4">
                                        {existingImages.map(img => (
                                            <div key={img.id} className="relative w-24 h-24 rounded-md overflow-hidden">
                                                <Image src={img.url} alt="Existing product image" layout="fill" objectFit="cover" />
                                                <button type="button" onClick={() => handleRemoveExistingImage(img.id)} className="absolute top-1 right-1 bg-red-600 text-white rounded-full p-1">
                                                    <Trash2 size={12} />
                                                </button>
                                            </div>
                                        ))}
                                        {newImages.map((file, i) => (
                                            <div key={i} className="relative w-24 h-24 rounded-md overflow-hidden">
                                                <Image src={URL.createObjectURL(file)} alt="New product image" layout="fill" objectFit="cover" />
                                                <button type="button" onClick={() => handleRemoveNewImage(i)} className="absolute top-1 right-1 bg-red-600 text-white rounded-full p-1">
                                                    <Trash2 size={12} />
                                                </button>
                                            </div>
                                        ))}
                                        <label className="w-24 h-24 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-md flex flex-col items-center justify-center cursor-pointer hover:border-blue-500">
                                            <UploadCloud size={24} className="text-gray-400" />
                                            <span className="text-xs text-gray-500 mt-1">Upload</span>
                                            <input type="file" multiple onChange={handleImageChange} className="hidden" accept="image/*" />
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                    
                    {/* Footer */}
                    <div className="flex justify-end items-center p-6 border-t border-gray-200 dark:border-gray-700">
                        <button type="button" onClick={onClose} className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 dark:bg-gray-800 dark:text-gray-300 dark:border-gray-600">
                            Cancel
                        </button>
                        <button
                            type="submit"
                            onClick={handleSubmit(onSubmit)}
                            disabled={isSubmitting || isLoading}
                            className="ml-3 px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md shadow-sm hover:bg-blue-700 disabled:opacity-50"
                        >
                            {isSubmitting || isLoading ? 'Saving...' : (isEditMode ? 'Save Changes' : 'Create Product')}
                        </button>
                    </div>
                </motion.div>
            </motion.div>
        </AnimatePresence>
    );
};
