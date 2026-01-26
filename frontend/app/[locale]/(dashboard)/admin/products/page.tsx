'use client';

import { useState, useEffect } from 'react';
import { AuthGuard } from '@/components/auth/auth-guard';
import { Package, Plus, Search, Filter, Edit, Trash2, X, Upload } from 'lucide-react';
import { productService, Product } from '@/services/product.service';
import { catalogService, Brand, Category } from '@/services/catalog.service';
import Image from 'next/image';
import { toast } from 'sonner';
import { AnimatePresence, motion } from 'framer-motion';

export default function AdminProducts() {
    const [products, setProducts] = useState<Product[]>([]);
    const [brands, setBrands] = useState<Brand[]>([]);
    const [categories, setCategories] = useState<Category[]>([]);
    const [scentFamilies, setScentFamilies] = useState<any[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingProduct, setEditingProduct] = useState<Product | null>(null);

    // Form State
    const [formData, setFormData] = useState({
        name: '',
        slug: '',
        brandId: '',
        categoryId: '',
        scentFamilyId: '',
        description: '',
        price: '',
        stock: '10',
        gender: 'unisex',
        concentration: 'EDP',
        isActive: true
    });

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        setIsLoading(true);
        try {
            const [prodRes, brandRes, catRes, scentRes] = await Promise.all([
                productService.adminList({ take: 50 }),
                catalogService.getBrands(),
                catalogService.getCategories(),
                catalogService.getScentFamilies()
            ]);
            setProducts(prodRes.data || []);
            setBrands(brandRes);
            setCategories(catRes);
            setScentFamilies(scentRes);
        } catch (error) {
            console.error('Failed to fetch data:', error);
            toast.error('Failed to synchronize with inventory');
        } finally {
            setIsLoading(false);
        }
    };

    const handleOpenModal = (product?: Product) => {
        if (product) {
            setEditingProduct(product);
            setFormData({
                name: product.name,
                slug: product.slug,
                brandId: product.brand.id.toString(),
                categoryId: product.category?.id.toString() || '',
                scentFamilyId: product.scentFamily?.id.toString() || '',
                description: product.description || '',
                price: product.price.toString(),
                stock: product.inventory?.quantity.toString() || '0',
                gender: product.gender || 'unisex',
                concentration: product.concentration || 'EDP',
                isActive: product.isActive
            });
        } else {
            setEditingProduct(null);
            setFormData({
                name: '',
                slug: '',
                brandId: brands[0]?.id.toString() || '',
                categoryId: '',
                scentFamilyId: '',
                description: '',
                price: '',
                stock: '10',
                gender: 'unisex',
                concentration: 'EDP',
                isActive: true
            });
        }
        setIsModalOpen(true);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const data = {
                ...formData,
                brandId: parseInt(formData.brandId),
                categoryId: formData.categoryId ? parseInt(formData.categoryId) : undefined,
                scentFamilyId: formData.scentFamilyId ? parseInt(formData.scentFamilyId) : undefined,
                price: parseInt(formData.price),
                stock: parseInt(formData.stock)
            };

            if (editingProduct) {
                await productService.update(editingProduct.id, data);
                toast.success('Product updated successfully');
            } else {
                await productService.create(data);
                toast.success('Product curated successfully');
            }
            setIsModalOpen(false);
            fetchData();
        } catch (error: any) {
            toast.error(error.response?.data?.message || 'Operation failed');
        }
    };

    const handleDelete = async (id: string) => {
        if (confirm('Are you sure you want to remove this essence from the collection?')) {
            try {
                await productService.remove(id);
                toast.success('Product removed');
                fetchData();
            } catch (error) {
                toast.error('Failed to remove product');
            }
        }
    };

    return (
        <AuthGuard allowedRoles={['ADMIN']}>
            <main className="p-8 pb-20">
                <header className="mb-12 flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
                    <div>
                        <div className="flex items-center gap-3 mb-4">
                            <div className="w-10 h-10 rounded-2xl bg-gold/10 flex items-center justify-center text-gold">
                                <Package size={24} />
                            </div>
                            <h1 className="text-4xl font-serif text-luxury-black dark:text-white uppercase tracking-tighter transition-colors">
                                Inventory Console
                            </h1>
                        </div>
                        <p className="text-stone-400 font-bold text-[10px] uppercase tracking-[0.4em] italic">
                            Architecting the Olfactory Future
                        </p>
                    </div>
                    <button
                        onClick={() => handleOpenModal()}
                        className="bg-luxury-black dark:bg-gold text-white px-8 py-4 rounded-full font-bold text-[10px] uppercase tracking-widest flex items-center gap-4 hover:scale-105 transition-all shadow-xl active:scale-95"
                    >
                        <Plus className="w-4 h-4" />
                        Curate New Essence
                    </button>
                </header>

                {/* Filters */}
                <div className="flex flex-col md:flex-row gap-4 mb-12">
                    <div className="flex-1 relative group">
                        <Search className="absolute left-6 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-300 group-focus-within:text-gold transition-colors" />
                        <input
                            type="text"
                            placeholder="Search by essence, brand or note..."
                            className="w-full bg-white dark:bg-zinc-900 border border-stone-100 dark:border-white/5 rounded-full py-4 pl-14 pr-6 text-xs outline-none focus:border-gold/50 transition-all font-sans text-stone-600 dark:text-stone-300 shadow-sm"
                        />
                    </div>
                    <div className="flex gap-4">
                        <button className="glass-dark px-8 rounded-full border border-stone-100 dark:border-white/5 flex items-center gap-3 text-stone-400 hover:text-gold transition-all text-[10px] font-bold uppercase tracking-widest">
                            <Filter className="w-4 h-4" />
                            Refine
                        </button>
                    </div>
                </div>

                {/* Products Grid */}
                {isLoading ? (
                    <div className="flex flex-col items-center justify-center py-40">
                        <div className="w-12 h-12 border-2 border-gold border-t-transparent rounded-full animate-spin mb-4" />
                        <p className="text-[10px] uppercase tracking-widest text-stone-400 font-bold">Synchronizing Databanks...</p>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                        {products.length === 0 ? (
                            <div className="col-span-full text-center py-20 glass rounded-[3rem] border-dashed border-2 border-stone-200 dark:border-white/5">
                                <Package className="w-16 h-16 text-stone-200 dark:text-white/5 mx-auto mb-4" />
                                <p className="text-stone-400 uppercase tracking-widest text-xs font-bold">No essences found in the current archival filter</p>
                            </div>
                        ) : products.map((product) => (
                            <div key={product.id} className="glass bg-white dark:bg-zinc-900 rounded-[3rem] border border-stone-100 dark:border-white/5 overflow-hidden hover:border-gold/30 transition-all group shadow-sm flex flex-col">
                                <div className="aspect-[3/4] bg-stone-50 dark:bg-zinc-800/50 relative overflow-hidden">
                                    {product.images?.[0] ? (
                                        <Image
                                            src={product.images[0].url}
                                            alt={product.name}
                                            fill
                                            className="object-cover group-hover:scale-110 transition-transform duration-1000"
                                        />
                                    ) : (
                                        <div className="absolute inset-0 flex items-center justify-center opacity-10">
                                            <Package size={80} />
                                        </div>
                                    )}
                                    <div className="absolute top-6 right-6 flex flex-col gap-2 translate-x-12 opacity-0 group-hover:translate-x-0 group-hover:opacity-100 transition-all duration-500">
                                        <button
                                            onClick={() => handleOpenModal(product)}
                                            className="w-10 h-10 bg-white dark:bg-zinc-900 rounded-xl flex items-center justify-center text-luxury-black dark:text-white hover:text-gold transition-colors shadow-xl"
                                        >
                                            <Edit size={18} />
                                        </button>
                                        <button
                                            onClick={() => handleDelete(product.id)}
                                            className="w-10 h-10 bg-white dark:bg-zinc-900 rounded-xl flex items-center justify-center text-red-500 hover:bg-red-500 hover:text-white transition-all shadow-xl"
                                        >
                                            <Trash2 size={18} />
                                        </button>
                                    </div>
                                    <div className="absolute bottom-6 left-6">
                                        <span className={`px-4 py-1.5 rounded-full text-[8px] font-bold uppercase tracking-widest shadow-xl border ${product.isActive ? 'bg-green-500/10 text-green-500 border-green-500/20' : 'bg-stone-500/10 text-stone-500 border-stone-500/20'}`}>
                                            {product.isActive ? 'Archived' : 'Draft'}
                                        </span>
                                    </div>
                                </div>
                                <div className="p-8 flex-1 flex flex-col">
                                    <div className="flex justify-between items-start mb-4">
                                        <div>
                                            <p className="text-[9px] text-gold uppercase tracking-[0.3em] font-bold mb-1">{product.brand?.name}</p>
                                            <h3 className="font-serif text-xl text-luxury-black dark:text-white transition-colors">{product.name}</h3>
                                        </div>
                                        <span className="font-serif text-lg text-luxury-black dark:text-stone-300">
                                            {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(product.price)}
                                        </span>
                                    </div>
                                    <div className="mt-auto pt-6 border-t border-stone-100 dark:border-white/5 flex justify-between items-center text-[10px] text-stone-400 font-bold uppercase tracking-widest">
                                        <p>{product.category?.name || 'Uncategorized'}</p>
                                        <p className={`${product.inventory?.quantity ? 'text-stone-500' : 'text-red-500'}`}>
                                            {product.inventory?.quantity || 0} in stock
                                        </p>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

                {/* Create/Edit Modal */}
                <AnimatePresence>
                    {isModalOpen && (
                        <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-luxury-black/60 backdrop-blur-md">
                            <motion.div
                                initial={{ opacity: 0, scale: 0.9, y: 20 }}
                                animate={{ opacity: 1, scale: 1, y: 0 }}
                                exit={{ opacity: 0, scale: 0.9, y: 20 }}
                                className="bg-white dark:bg-zinc-900 w-full max-w-4xl rounded-[4rem] overflow-hidden shadow-2xl border border-white/10"
                            >
                                <div className="p-12 md:p-16 h-[85vh] overflow-y-auto custom-scrollbar">
                                    <div className="flex justify-between items-center mb-12">
                                        <div>
                                            <h2 className="text-3xl font-serif text-luxury-black dark:text-white lowercase italic mb-2">
                                                {editingProduct ? 'Refine the Essence' : 'Curate New Essence'}
                                            </h2>
                                            <p className="text-[10px] text-stone-400 font-bold uppercase tracking-[0.4em]">Defining your olfactory signature</p>
                                        </div>
                                        <button onClick={() => setIsModalOpen(false)} className="w-12 h-12 rounded-2xl bg-stone-50 dark:bg-zinc-800 flex items-center justify-center text-stone-400 hover:text-gold transition-all">
                                            <X size={24} />
                                        </button>
                                    </div>

                                    <form onSubmit={handleSubmit} className="space-y-10">
                                        <div className="grid md:grid-cols-2 gap-10">
                                            {/* Basic Info */}
                                            <div className="space-y-6">
                                                <div className="space-y-2">
                                                    <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">Essence Name</label>
                                                    <input
                                                        required
                                                        value={formData.name}
                                                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all"
                                                        placeholder="e.g., Obsidian Mist"
                                                    />
                                                </div>
                                                <div className="space-y-2">
                                                    <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">URL Slug</label>
                                                    <input
                                                        required
                                                        value={formData.slug}
                                                        onChange={(e) => setFormData({ ...formData, slug: e.target.value })}
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all"
                                                        placeholder="obsidian-mist"
                                                    />
                                                </div>
                                                <div className="grid grid-cols-2 gap-6">
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">Price (VND)</label>
                                                        <input
                                                            required
                                                            type="number"
                                                            value={formData.price}
                                                            onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all"
                                                        />
                                                    </div>
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">Initial Stock</label>
                                                        <input
                                                            required
                                                            type="number"
                                                            value={formData.stock}
                                                            onChange={(e) => setFormData({ ...formData, stock: e.target.value })}
                                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all"
                                                        />
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Classification */}
                                            <div className="space-y-6">
                                                <div className="space-y-2">
                                                    <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">Maison (Brand)</label>
                                                    <select
                                                        required
                                                        value={formData.brandId}
                                                        onChange={(e) => setFormData({ ...formData, brandId: e.target.value })}
                                                        className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all appearance-none cursor-pointer"
                                                    >
                                                        {brands.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
                                                    </select>
                                                </div>
                                                <div className="grid grid-cols-2 gap-6">
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">Universe (Category)</label>
                                                        <select
                                                            value={formData.categoryId}
                                                            onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
                                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all appearance-none cursor-pointer"
                                                        >
                                                            <option value="">Select Category</option>
                                                            {categories.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                                                        </select>
                                                    </div>
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">Scent Family</label>
                                                        <select
                                                            value={formData.scentFamilyId}
                                                            onChange={(e) => setFormData({ ...formData, scentFamilyId: e.target.value })}
                                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all appearance-none cursor-pointer"
                                                        >
                                                            <option value="">Select Scent Family</option>
                                                            {scentFamilies.map(sf => <option key={sf.id} value={sf.id}>{sf.name}</option>)}
                                                        </select>
                                                    </div>
                                                </div>
                                                <div className="grid grid-cols-2 gap-6">
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">Concentration</label>
                                                        <select
                                                            value={formData.concentration}
                                                            onChange={(e) => setFormData({ ...formData, concentration: e.target.value })}
                                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all appearance-none cursor-pointer"
                                                        >
                                                            <option value="EDP">Eau de Parfum</option>
                                                            <option value="EDT">Eau de Toilette</option>
                                                            <option value="Extrait">Extrait de Parfum</option>
                                                            <option value="Cologne">Eau de Cologne</option>
                                                        </select>
                                                    </div>
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">Spirit (Gender)</label>
                                                        <select
                                                            value={formData.gender}
                                                            onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                                                            className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-2xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all appearance-none cursor-pointer"
                                                        >
                                                            <option value="unisex">Unisex</option>
                                                            <option value="masculine">Masculine</option>
                                                            <option value="feminine">Feminine</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div className="space-y-2">
                                            <label className="text-[10px] font-bold uppercase tracking-widest text-stone-400 pl-2">The Olfactory Narrative (Description)</label>
                                            <textarea
                                                rows={4}
                                                value={formData.description}
                                                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                                className="w-full bg-stone-50 dark:bg-white/5 border border-stone-100 dark:border-white/10 rounded-3xl px-6 py-4 text-xs dark:text-white outline-none focus:border-gold transition-all resize-none"
                                                placeholder="Describe the sensory voyage..."
                                            />
                                        </div>

                                        <div className="flex items-center gap-4 py-4 px-6 bg-stone-50 dark:bg-white/5 rounded-3xl border border-stone-100 dark:border-white/10">
                                            <input
                                                type="checkbox"
                                                id="isActive"
                                                checked={formData.isActive}
                                                onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                                                className="w-5 h-5 accent-gold cursor-pointer"
                                            />
                                            <label htmlFor="isActive" className="text-[10px] font-bold uppercase tracking-widest text-stone-500 cursor-pointer select-none">Make this essence available to the public collection</label>
                                        </div>

                                        <div className="pt-8 flex gap-6">
                                            <button
                                                type="submit"
                                                className="flex-1 bg-luxury-black dark:bg-gold text-white py-5 rounded-full font-bold text-[10px] uppercase tracking-widest shadow-2xl hover:scale-[1.02] active:scale-[0.98] transition-all"
                                            >
                                                {editingProduct ? 'Update Archival' : 'Finalize Curation'}
                                            </button>
                                            <button
                                                type="button"
                                                onClick={() => setIsModalOpen(false)}
                                                className="px-12 py-5 border border-stone-200 dark:border-white/10 text-stone-400 font-bold text-[10px] uppercase tracking-widest rounded-full hover:bg-stone-50 dark:hover:bg-white/5 transition-all"
                                            >
                                                Discard
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </motion.div>
                        </div>
                    )}
                </AnimatePresence>
            </main>
        </AuthGuard>
    );
}
