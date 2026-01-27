'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { Package, Plus, Search, X, Eye, EyeOff, Pencil, ImagePlus } from 'lucide-react';
import { productService, type Product } from '@/services/product.service';
import { catalogService } from '@/services/catalog.service';
import { useEffect, useState, useCallback } from 'react';

const MAX_IMAGES = 10;

type ExistingImage = { id: number; url: string; order: number };

function slugify(s: string) {
  return s
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '');
}

export default function AdminProducts() {
  const [products, setProducts] = useState<Product[]>([]);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showModal, setShowModal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [loadingProduct, setLoadingProduct] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [imageFiles, setImageFiles] = useState<Array<{ file: File; url: string }>>([]);
  const [existingImages, setExistingImages] = useState<ExistingImage[]>([]);
  const [brands, setBrands] = useState<{ id: number; name: string }[]>([]);
  const [categories, setCategories] = useState<{ id: number; name: string }[]>([]);
  const [scentFamilies, setScentFamilies] = useState<{ id: number; name: string }[]>([]);

  const [form, setForm] = useState({
    name: '',
    slug: '',
    brandId: 0,
    categoryId: '' as '' | number,
    scentFamilyId: '' as '' | number,
    description: '',
    gender: '',
    longevity: '',
    concentration: '',
    price: 0,
    currency: 'VND',
    isActive: true,
    stock: 0,
  });

  const fetchProducts = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await productService.adminList({ search: search || undefined, take: 50 });
      setProducts(res.items);
      setTotal(res.total);
    } catch (e: unknown) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }, [search]);

  const fetchCatalog = useCallback(async () => {
    try {
      const [b, c, s] = await Promise.all([
        catalogService.getBrands(),
        catalogService.getCategories(),
        catalogService.getScentFamilies(),
      ]);
      setBrands(b);
      setCategories(c);
      setScentFamilies(s);
    } catch {
      // Catalog optional for listing
    }
  }, []);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);

  useEffect(() => {
    if (showModal) fetchCatalog();
  }, [showModal, fetchCatalog]);

  useEffect(() => {
    if (showModal && editId) {
      setLoadingProduct(true);
      productService.adminGetById(editId)
        .then((p: Product) => {
          setForm({
            name: p.name,
            slug: p.slug,
            brandId: p.brandId,
            categoryId: p.categoryId ?? '',
            scentFamilyId: p.scentFamilyId ?? '',
            description: p.description ?? '',
            gender: p.gender ?? '',
            longevity: p.longevity ?? '',
            concentration: p.concentration ?? '',
            price: p.price,
            currency: p.currency || 'VND',
            isActive: p.isActive,
            stock: p.inventory?.quantity ?? 0,
          });
          setExistingImages((p.images ?? []) as ExistingImage[]);
        })
        .catch((e: unknown) => setError((e as Error).message))
        .finally(() => setLoadingProduct(false));
    }
  }, [showModal, editId]);

  // Cleanup object URLs on unmount
  useEffect(() => {
    return () => {
      imageFiles.forEach((x) => URL.revokeObjectURL(x.url));
    };
  }, [imageFiles]);

  const closeModal = () => {
    if (saving) return;
    setShowModal(false);
    setEditId(null);
    setImageFiles((prev) => {
      prev.forEach((x) => URL.revokeObjectURL(x.url));
      return [];
    });
    setExistingImages([]);
    setLoadingProduct(false);
  };

  const openCreate = () => {
    setEditId(null);
    setImageFiles([]);
    setExistingImages([]);
    setLoadingProduct(false);
    setForm({
      name: '',
      slug: '',
      brandId: brands[0]?.id ?? 0,
      categoryId: '',
      scentFamilyId: '',
      description: '',
      gender: '',
      longevity: '',
      concentration: '',
      price: 0,
      currency: 'VND',
      isActive: true,
      stock: 0,
    });
    setShowModal(true);
  };

  const openEdit = (id: string) => {
    setEditId(id);
    setImageFiles([]);
    setExistingImages([]);
    setLoadingProduct(true);
    setShowModal(true);
  };

  const onNameChange = (name: string) => {
    setForm((f) => ({ ...f, name, slug: editId ? f.slug : (f.slug || slugify(name)) }));
  };

  const totalImages = existingImages.length + imageFiles.length;
  const canAddMoreImages = totalImages < MAX_IMAGES;

  const addImageFiles = (files: FileList | null) => {
    if (!files?.length || !canAddMoreImages) return;
    const list = Array.from(files);
    const space = MAX_IMAGES - totalImages;
    const toAdd = list.slice(0, space).map((file) => ({
      file,
      url: URL.createObjectURL(file),
    }));
    setImageFiles((prev) => [...prev, ...toAdd].slice(0, MAX_IMAGES - existingImages.length));
  };

  const removeImageFile = (index: number) => {
    setImageFiles((prev) => {
      const item = prev[index];
      if (item) URL.revokeObjectURL(item.url);
      return prev.filter((_, i) => i !== index);
    });
  };

  const handleDeleteImage = async (img: ExistingImage) => {
    if (!editId) return;
    try {
      await productService.adminDeleteImage(editId, img.id);
      setExistingImages((prev) => prev.filter((x) => x.id !== img.id));
    } catch (e: unknown) {
      setError((e as Error).message);
    }
  };

  const toDto = () => ({
    name: form.name.trim(),
    slug: form.slug.trim(),
    brandId: form.brandId,
    categoryId: form.categoryId === '' ? null : form.categoryId,
    scentFamilyId: form.scentFamilyId === '' ? null : form.scentFamilyId,
    description: form.description || undefined,
    gender: form.gender || undefined,
    longevity: form.longevity || undefined,
    concentration: form.concentration || undefined,
    price: form.price,
    currency: form.currency,
    isActive: form.isActive,
    stock: form.stock > 0 ? form.stock : undefined,
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name.trim() || !form.slug.trim() || form.brandId <= 0 || form.price < 0) {
      setError('Please fill name, slug, brand and price.');
      return;
    }
    setSaving(true);
    setError(null);
    try {
      if (editId) {
        await productService.adminUpdate(editId, toDto());
        if (imageFiles.length > 0) {
          await productService.adminUploadImages(editId, imageFiles.map((x) => x.file));
        }
      } else {
        const product = await productService.adminCreate(toDto());
        if (imageFiles.length > 0) {
          await productService.adminUploadImages(product.id, imageFiles.map((x) => x.file));
        }
      }
      closeModal();
      fetchProducts();
    } catch (e: unknown) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const handleToggleVisibility = async (id: string, currentStatus: boolean) => {
    const action = currentStatus ? 'hide' : 'show';
    if (!confirm(`${action === 'hide' ? 'Hide' : 'Show'} this product?`)) return;
    try {
      if (currentStatus) {
        // Hide product (soft delete)
        await productService.adminDelete(id);
      } else {
        // Show product (restore)
        await productService.adminUpdate(id, { isActive: true });
      }
      fetchProducts();
    } catch (e: unknown) {
      setError((e as Error).message);
    }
  };

  return (
    <AuthGuard allowedRoles={['admin']}>
      <main className="p-8">
        <header className="mb-12 flex justify-between items-end">
          <div>
            <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">Inventory Console</h1>
            <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">Fragrance Collection Management</p>
          </div>
          <button
            onClick={openCreate}
            className="bg-gold text-primary-foreground px-6 py-3 rounded-full font-heading text-[10px] uppercase tracking-widest font-bold flex items-center gap-2 hover:scale-105 transition-all"
          >
            <Plus className="w-4 h-4" />
            Curate New
          </button>
        </header>

        <div className="flex gap-4 mb-8">
          <div className="flex-1 relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <input
              type="text"
              placeholder="Search by essence, brand or note..."
              className="w-full bg-secondary/20 border border-border rounded-full py-3 pl-12 pr-4 text-sm outline-none focus:border-gold/50 transition-all font-body"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
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
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {products.map((p) => (
              <div
                key={p.id}
                className={`glass rounded-[2rem] border-border overflow-hidden hover:border-gold/30 transition-all group ${
                  !p.isActive ? 'opacity-60' : ''
                }`}
              >
                <div className="aspect-square bg-secondary/30 relative overflow-hidden">
                  {p.images?.length ? (
                    <img src={p.images[0].url} alt={p.name} className="w-full h-full object-cover" />
                  ) : (
                    <div className="absolute inset-0 flex items-center justify-center">
                      <Package className="w-12 h-12 text-gold/20" />
                    </div>
                  )}
                  {!p.isActive && (
                    <div className="absolute top-2 right-2 bg-red-500/80 text-white text-[8px] px-2 py-1 rounded-full uppercase tracking-widest font-bold">
                      Hidden
                    </div>
                  )}
                </div>
                <div className="p-6">
                  <div className="flex items-start justify-between mb-1">
                    <p className="text-[10px] text-gold uppercase tracking-widest font-bold">{p.brand?.name ?? '—'}</p>
                    {!p.isActive && (
                      <span className="text-[8px] text-muted-foreground uppercase">Hidden</span>
                    )}
                  </div>
                  <h3 className="font-heading text-foreground mb-4">{p.name}</h3>
                  <div className="flex justify-between items-center">
                    <span className="font-heading text-lg">
                      {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: p.currency || 'VND' }).format(p.price)}
                    </span>
                    <span className="text-[10px] text-muted-foreground uppercase tracking-widest">
                      {p.inventory?.quantity ?? 0} in stock
                    </span>
                  </div>
                  <div className="mt-3 flex gap-2">
                    <button
                      onClick={() => openEdit(p.id)}
                      className="text-muted-foreground hover:text-gold transition-colors"
                      title="Edit"
                    >
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleToggleVisibility(p.id, p.isActive)}
                      className={`transition-colors ${
                        p.isActive
                          ? 'text-muted-foreground hover:text-orange-500'
                          : 'text-muted-foreground hover:text-green-500'
                      }`}
                      title={p.isActive ? 'Hide product' : 'Show product'}
                    >
                      {p.isActive ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {showModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60" onClick={closeModal}>
            <div
              className="bg-background border border-border rounded-[2rem] max-w-xl w-full max-h-[90vh] overflow-y-auto p-8"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-heading">{editId ? 'Edit Product' : 'Create Product'}</h2>
                <button onClick={closeModal} className="p-2 hover:bg-secondary rounded-full">
                  <X className="w-5 h-5" />
                </button>
              </div>
              {loadingProduct ? (
                <div className="py-12 text-center text-muted-foreground">Loading product…</div>
              ) : (
              <form onSubmit={handleSubmit} className="space-y-6">
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Name *</label>
                  <input
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                    value={form.name}
                    onChange={(e) => onNameChange(e.target.value)}
                    required
                  />
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Slug *</label>
                  <input
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                    value={form.slug}
                    onChange={(e) => setForm((f) => ({ ...f, slug: e.target.value }))}
                    required
                  />
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Brand *</label>
                  <select
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                    value={form.brandId || ''}
                    onChange={(e) => setForm((f) => ({ ...f, brandId: Number(e.target.value) }))}
                    required
                  >
                    <option value="">—</option>
                    {brands.map((b) => (
                      <option key={b.id} value={b.id}>{b.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Category</label>
                  <select
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                    value={form.categoryId === '' ? '' : form.categoryId}
                    onChange={(e) => setForm((f) => ({ ...f, categoryId: e.target.value === '' ? '' : Number(e.target.value) }))}
                  >
                    <option value="">—</option>
                    {categories.map((c) => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Scent Family</label>
                  <select
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                    value={form.scentFamilyId === '' ? '' : form.scentFamilyId}
                    onChange={(e) => setForm((f) => ({ ...f, scentFamilyId: e.target.value === '' ? '' : Number(e.target.value) }))}
                  >
                    <option value="">—</option>
                    {scentFamilies.map((s) => (
                      <option key={s.id} value={s.id}>{s.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Description</label>
                  <textarea
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold min-h-[80px]"
                    value={form.description}
                    onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Gender</label>
                    <input
                      className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                      value={form.gender}
                      onChange={(e) => setForm((f) => ({ ...f, gender: e.target.value }))}
                      placeholder="e.g. Unisex"
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Longevity</label>
                    <input
                      className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                      value={form.longevity}
                      onChange={(e) => setForm((f) => ({ ...f, longevity: e.target.value }))}
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Concentration</label>
                  <input
                    className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                    value={form.concentration}
                    onChange={(e) => setForm((f) => ({ ...f, concentration: e.target.value }))}
                    placeholder="e.g. Eau de Parfum"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Price (VND) *</label>
                    <input
                      type="number"
                      min={0}
                      className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                      value={form.price || ''}
                      onChange={(e) => setForm((f) => ({ ...f, price: Number(e.target.value) || 0 }))}
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">Stock</label>
                    <input
                      type="number"
                      min={0}
                      className="w-full bg-secondary/20 border border-border rounded-xl py-3 px-4 outline-none focus:border-gold"
                      value={form.stock || ''}
                      onChange={(e) => setForm((f) => ({ ...f, stock: Number(e.target.value) || 0 }))}
                    />
                  </div>
                </div>
                {/* Images (max 10) */}
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-2">
                    Images (max {MAX_IMAGES})
                  </label>
                  {editId && existingImages.length > 0 && (
                    <div className="flex flex-wrap gap-2 mb-3">
                      {existingImages.map((img) => (
                        <div key={img.id} className="relative group">
                          <img src={img.url} alt="" className="w-16 h-16 object-cover rounded-lg border border-border" />
                          <button
                            type="button"
                            onClick={() => handleDeleteImage(img)}
                            className="absolute top-0 right-0 w-5 h-5 bg-red-500 text-white rounded-full flex items-center justify-center text-xs opacity-0 group-hover:opacity-100 transition-opacity"
                            title="Remove image"
                          >
                            <X className="w-3 h-3" />
                          </button>
                        </div>
                      ))}
                    </div>
                  )}
                  {imageFiles.length > 0 && (
                    <div className="flex flex-wrap gap-2 mb-3">
                      {imageFiles.map((item, i) => (
                        <div key={i} className="relative group">
                          <img
                            src={item.url}
                            alt=""
                            className="w-16 h-16 object-cover rounded-lg border border-border border-dashed"
                          />
                          <button
                            type="button"
                            onClick={() => removeImageFile(i)}
                            className="absolute top-0 right-0 w-5 h-5 bg-red-500 text-white rounded-full flex items-center justify-center text-xs opacity-0 group-hover:opacity-100 transition-opacity"
                            title="Remove"
                          >
                            <X className="w-3 h-3" />
                          </button>
                        </div>
                      ))}
                    </div>
                  )}
                  {canAddMoreImages && (
                    <label className="inline-flex items-center gap-2 px-4 py-2 bg-secondary/30 border border-border border-dashed rounded-xl cursor-pointer hover:border-gold/50 transition-colors text-sm text-muted-foreground">
                      <ImagePlus className="w-4 h-4" />
                      Add images
                      <input
                        type="file"
                        accept="image/*"
                        multiple
                        className="sr-only"
                        onChange={(e) => { addImageFiles(e.target.files); e.target.value = ''; }}
                      />
                    </label>
                  )}
                  <p className="text-[10px] text-muted-foreground mt-1">{totalImages} / {MAX_IMAGES}</p>
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="isActive"
                    checked={form.isActive}
                    onChange={(e) => setForm((f) => ({ ...f, isActive: e.target.checked }))}
                    className="rounded border-border"
                  />
                  <label htmlFor="isActive" className="text-sm">Active</label>
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
                    {saving ? 'Saving…' : (editId ? 'Save' : 'Create')}
                  </button>
                </div>
              </form>
              )}
            </div>
          </div>
        )}
      </main>
    </AuthGuard>
  );
}
