"use client";

import React, { useState, useEffect, useCallback } from 'react';
import { apiClient } from '@/lib/api-client';
import { toast } from 'react-hot-toast';
import { Plus, Edit, Trash2 } from 'lucide-react';
import { motion } from 'framer-motion';

interface Category {
    id: number;
    name: string;
    description: string | null;
}

const CategoryManager = () => {
    const [categories, setCategories] = useState<Category[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [currentCategory, setCurrentCategory] = useState<Category | null>(null);

    const fetchCategories = useCallback(async () => {
        setIsLoading(true);
        try {
            const res = await apiClient.get<Category[]>('/admin/categories');
            if (res.data) {
                setCategories(res.data);
            } else {
                throw new Error(res.error || "Failed to fetch categories");
            }
        } catch (err: any) {
            setError(err.message);
            toast.error(err.message);
        } finally {
            setIsLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchCategories();
    }, [fetchCategories]);

    const handleEdit = (category: Category) => {
        setCurrentCategory(category);
        setIsModalOpen(true);
    };

    const handleAdd = () => {
        setCurrentCategory(null);
        setIsModalOpen(true);
    };

    const handleDelete = async (id: number) => {
        if (window.confirm('Are you sure you want to delete this category?')) {
            toast.promise(
                apiClient.delete(`/admin/categories/${id}`),
                {
                    loading: 'Deleting category...',
                    success: () => {
                        fetchCategories();
                        return 'Category deleted successfully!';
                    },
                    error: 'Failed to delete category.',
                }
            );
        }
    };
    
    const handleSave = (category: Category | { name: string; description: string | null }) => {
        const isEditing = 'id' in category && category.id !== undefined;
        const promise = isEditing 
            ? apiClient.patch(`/admin/categories/${category.id}`, category)
            : apiClient.post('/admin/categories', category);

        toast.promise(promise, {
            loading: `${isEditing ? 'Updating' : 'Creating'} category...`,
            success: () => {
                setIsModalOpen(false);
                fetchCategories();
                return `Category ${isEditing ? 'updated' : 'created'} successfully!`;
            },
            error: `Failed to ${isEditing ? 'update' : 'create'} category.`,
        });
    };

    return (
        <div>
            <div className="flex justify-end mb-4">
                <button
                    onClick={handleAdd}
                    className="px-4 py-2 bg-blue-600 text-white rounded-md flex items-center gap-2"
                >
                    <Plus size={16} /> Add Category
                </button>
            </div>
            
            {isLoading && <p>Loading categories...</p>}
            {error && <p className="text-red-500">{error}</p>}

            <div className="bg-white dark:bg-gray-900 shadow-md rounded-lg overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead className="bg-gray-50 dark:bg-gray-800">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                        {categories.map((category) => (
                            <tr key={category.id}>
                                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">{category.name}</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">{category.description}</td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    <button onClick={() => handleEdit(category)} className="text-indigo-600 hover:text-indigo-900 dark:text-indigo-400 dark:hover:text-indigo-200 mr-4"><Edit size={16}/></button>
                                    <button onClick={() => handleDelete(category.id)} className="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-200"><Trash2 size={16}/></button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            {isModalOpen && (
                <CategoryFormModal
                    category={currentCategory}
                    onClose={() => setIsModalOpen(false)}
                    onSave={handleSave}
                />
            )}
        </div>
    );
};


const CategoryFormModal = ({ category, onClose, onSave }: { category: Category | null, onClose: () => void, onSave: (data: any) => void }) => {
    const [name, setName] = useState(category?.name || '');
    const [description, setDescription] = useState(category?.description || '');

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        onSave({ id: category?.id, name, description });
    };
    
    return (
        <motion.div initial={{ opacity: 0}} animate={{ opacity: 1}} exit={{ opacity: 0 }} className="fixed inset-0 bg-black/50 z-[100] flex items-center justify-center p-4">
            <div className="bg-white dark:bg-gray-900 rounded-lg shadow-xl w-full max-w-md" onClick={(e) => e.stopPropagation()}>
                 <form onSubmit={handleSubmit}>
                    <div className="p-6">
                        <h3 className="text-lg font-medium mb-4">{category ? 'Edit' : 'Add'} Category</h3>
                        <div className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium">Name</label>
                                <input value={name} onChange={e => setName(e.target.value)} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium">Description</label>
                                <textarea value={description} onChange={e => setDescription(e.target.value)} rows={3} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm dark:bg-gray-800 dark:border-gray-600" />
                            </div>
                        </div>
                    </div>
                    <div className="px-6 py-4 bg-gray-50 dark:bg-gray-800 flex justify-end gap-4">
                        <button type="button" onClick={onClose} className="px-4 py-2 text-sm rounded-md">Cancel</button>
                        <button type="submit" className="px-4 py-2 text-sm rounded-md bg-blue-600 text-white">Save</button>
                    </div>
                 </form>
            </div>
        </motion.div>
    );
};

export default CategoryManager;
