'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { Plus, X, Pencil, Trash2, Tag, Layers, Flower } from 'lucide-react';
import { catalogService, type CatalogItem } from '@/services/catalog.service';
import { useEffect, useState, useCallback } from 'react';

type TabType = 'brands' | 'categories' | 'scentFamilies';

export default function AdminCatalog() {
  const [activeTab, setActiveTab] = useState<TabType>('brands');
  const [items, setItems] = useState<CatalogItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showModal, setShowModal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [editId, setEditId] = useState<number | null>(null);
  const [form, setForm] = useState({ name: '', description: '' });

  const fetchItems = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      let data: CatalogItem[];
      switch (activeTab) {
        case 'brands':
          data = await catalogService.getBrands();
          break;
        case 'categories':
          data = await catalogService.getCategories();
          break;
        case 'scentFamilies':
          data = await catalogService.getScentFamilies();
          break;
      }
      setItems(data);
    } catch (e: unknown) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }, [activeTab]);

  useEffect(() => {
    fetchItems();
  }, [fetchItems]);

  const closeModal = () => {
    if (saving) return;
    setShowModal(false);
    setEditId(null);
    setForm({ name: '', description: '' });
  };

  const openCreate = () => {
    setEditId(null);
    setForm({ name: '', description: '' });
    setShowModal(true);
  };

  const openEdit = async (id: number) => {
    setEditId(id);
    setSaving(true);
    try {
      let data: CatalogItem;
      switch (activeTab) {
        case 'brands':
          data = await catalogService.getBrand(id);
          break;
        case 'categories':
          data = await catalogService.getCategory(id);
          break;
        case 'scentFamilies':
          data = await catalogService.getScentFamily(id);
          break;
      }
      setForm({ name: data.name, description: data.description || '' });
      setShowModal(true);
    } catch (e: unknown) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name.trim()) {
      setError('Name is required.');
      return;
    }
    setSaving(true);
    setError(null);
    try {
      const dto = {
        name: form.name.trim(),
        description: form.description.trim() || undefined,
      };
      if (editId) {
        switch (activeTab) {
          case 'brands':
            await catalogService.updateBrand(editId, dto);
            break;
          case 'categories':
            await catalogService.updateCategory(editId, dto);
            break;
          case 'scentFamilies':
            await catalogService.updateScentFamily(editId, dto);
            break;
        }
      } else {
        switch (activeTab) {
          case 'brands':
            await catalogService.createBrand(dto);
            break;
          case 'categories':
            await catalogService.createCategory(dto);
            break;
          case 'scentFamilies':
            await catalogService.createScentFamily(dto);
            break;
        }
      }
      closeModal();
      fetchItems();
    } catch (e: unknown) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: number) => {
    const typeName = activeTab === 'brands' ? 'brand' : activeTab === 'categories' ? 'category' : 'scent family';
    if (!confirm(`Delete this ${typeName}? This will update all related products.`)) return;
    try {
      switch (activeTab) {
        case 'brands':
          await catalogService.deleteBrand(id);
          break;
        case 'categories':
          await catalogService.deleteCategory(id);
          break;
        case 'scentFamilies':
          await catalogService.deleteScentFamily(id);
          break;
      }
      fetchItems();
    } catch (e: unknown) {
      setError((e as Error).message);
    }
  };

  const tabs = [
    { id: 'brands' as TabType, label: 'Brands', icon: Tag },
    { id: 'categories' as TabType, label: 'Categories', icon: Layers },
    { id: 'scentFamilies' as TabType, label: 'Scent Families', icon: Flower },
  ];

  const getTitle = () => {
    switch (activeTab) {
      case 'brands':
        return 'Brand Management';
      case 'categories':
        return 'Category Management';
      case 'scentFamilies':
        return 'Scent Family Management';
    }
  };

  return (
    <AuthGuard allowedRoles={['admin']}>
      <main className="p-8">
        <header className="mb-12 flex justify-between items-end">
          <div>
            <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Catalog Console</h1>
            <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Brand, Category & Scent Family Management</p>
          </div>
          <button
            onClick={openCreate}
            className="bg-gold text-primary-foreground px-6 py-3 rounded-full font-heading text-[10px] uppercase tracking-widest font-bold flex items-center gap-2 hover:scale-105 transition-all"
          >
            <Plus className="w-4 h-4" />
            Add New
          </button>
        </header>

        {/* Tabs */}
        <div className="flex gap-2 mb-8 border-b border-border">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-6 py-3 font-heading text-sm uppercase tracking-widest transition-all flex items-center gap-2 border-b-2 ${
                  activeTab === tab.id
                    ? 'border-gold text-gold'
                    : 'border-transparent text-muted-foreground hover:text-foreground'
                }`}
              >
                <Icon className="w-4 h-4" />
                {tab.label}
              </button>
            );
          })}
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-500/10 border border-red-500/30 rounded-2xl text-red-600 dark:text-red-400 text-sm">
            {error}
          </div>
        )}

        {loading ? (
          <div className="flex justify-center py-20">
            <span className="text-muted-foreground">Loading…</span>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {items.map((item) => (
              <div
                key={item.id}
                className="glass rounded-2xl border border-border p-6 hover:border-gold/30 transition-all group"
              >
                <div className="flex items-start justify-between mb-3">
                  <h3 className="font-heading text-lg text-foreground">{item.name}</h3>
                  <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button
                      onClick={() => openEdit(item.id)}
                      className="text-muted-foreground hover:text-gold transition-colors"
                      title="Edit"
                    >
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(item.id)}
                      className="text-muted-foreground hover:text-red-500 transition-colors"
                      title="Delete"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
                {item.description && (
                  <p className="text-sm text-muted-foreground line-clamp-2">{item.description}</p>
                )}
              </div>
            ))}
            {items.length === 0 && (
              <div className="col-span-full text-center py-12 text-muted-foreground">
                No {activeTab === 'brands' ? 'brands' : activeTab === 'categories' ? 'categories' : 'scent families'} found.
              </div>
            )}
          </div>
        )}

        {/* Modal */}
        {showModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60" onClick={closeModal}>
            <div
              className="bg-background border border-border rounded-[2rem] max-w-md w-full p-8"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-heading">
                  {editId ? `Edit ${getTitle()}` : `Create ${getTitle()}`}
                </h2>
                <button onClick={closeModal} className="p-2 hover:bg-secondary rounded-full">
                  <X className="w-5 h-5" />
                </button>
              </div>
              <form onSubmit={handleSubmit} className="space-y-6">
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">
                    Name *
                  </label>
                  <input
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                    value={form.name}
                    onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
                    required
                    placeholder="Enter name"
                  />
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">
                    Description
                  </label>
                  <textarea
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold min-h-[100px]"
                    value={form.description}
                    onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))}
                    placeholder="Enter description (optional)"
                  />
                </div>
                <div className="flex gap-4 pt-4">
                  <button
                    type="button"
                    onClick={closeModal}
                    className="flex-1 py-3 rounded-full border border-border text-muted-foreground hover:bg-secondary/50"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={saving}
                    className="flex-1 py-3 rounded-full bg-gold text-primary-foreground font-heading uppercase tracking-widest disabled:opacity-50"
                  >
                    {saving ? 'Saving…' : editId ? 'Save' : 'Create'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </main>
    </AuthGuard>
  );
}
