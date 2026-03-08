'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { storesService, type StoreWithDetails } from '@/services/stores.service';
import { userService } from '@/services/user.service';
import { Store, Plus, Pencil, Trash2, UserPlus, UserMinus } from 'lucide-react';
import { useEffect, useState, useCallback } from 'react';

export default function AdminStoresPage() {
  const [stores, setStores] = useState<StoreWithDetails[]>([]);
  const [staffUsers, setStaffUsers] = useState<{ id: string; email: string; fullName: string | null; role: string }[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [modal, setModal] = useState<'create' | 'edit' | null>(null);
  const [editStore, setEditStore] = useState<StoreWithDetails | null>(null);
  const [assignModal, setAssignModal] = useState<StoreWithDetails | null>(null);
  const [form, setForm] = useState({ name: '', code: '', address: '', isActive: true });
  const [saving, setSaving] = useState(false);

  const fetchStores = useCallback(async () => {
    try {
      const data = await storesService.list();
      setStores(data);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchStaff = useCallback(async () => {
    try {
      const list = await userService.adminListUsers('STAFF');
      setStaffUsers(list);
    } catch {
      // optional
    }
  }, []);

  useEffect(() => {
    fetchStores();
    fetchStaff();
  }, [fetchStores, fetchStaff]);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await storesService.create({
        name: form.name,
        code: form.code || undefined,
        address: form.address || undefined,
        isActive: form.isActive,
      });
      setModal(null);
      setForm({ name: '', code: '', address: '', isActive: true });
      fetchStores();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const handleUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editStore) return;
    setSaving(true);
    try {
      await storesService.update(editStore.id, {
        name: form.name,
        code: form.code || undefined,
        address: form.address || undefined,
        isActive: form.isActive,
      });
      setModal(null);
      setEditStore(null);
      fetchStores();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Xóa quầy này? Dữ liệu tồn kho và gán nhân viên sẽ bị ảnh hưởng.')) return;
    try {
      await storesService.remove(id);
      fetchStores();
    } catch (e) {
      setError((e as Error).message);
    }
  };

  const handleAssign = async (storeId: string, userId: string) => {
    try {
      await storesService.assignStaff(storeId, userId);
      setAssignModal(null);
      fetchStores();
    } catch (e) {
      setError((e as Error).message);
    }
  };

  const handleUnassign = async (storeId: string, userId: string) => {
    try {
      await storesService.unassignStaff(storeId, userId);
      fetchStores();
    } catch (e) {
      setError((e as Error).message);
    }
  };

  const openEdit = (s: StoreWithDetails) => {
    setEditStore(s);
    setForm({
      name: s.name,
      code: s.code ?? '',
      address: s.address ?? '',
      isActive: s.isActive ?? true,
    });
    setModal('edit');
  };

  return (
    <AuthGuard allowedRoles={['admin']}>
      <main className="p-8">
        <header className="mb-12 flex flex-wrap items-center justify-between gap-4">
          <div>
            <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">
              Quản lý quầy / cửa hàng
            </h1>
            <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">
              CRUD quầy, gán nhân viên vào quầy
            </p>
          </div>
          <button
            type="button"
            onClick={() => {
              setForm({ name: '', code: '', address: '', isActive: true });
              setEditStore(null);
              setModal('create');
            }}
            className="flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-gold text-primary font-heading text-xs uppercase tracking-widest hover:opacity-90"
          >
            <Plus className="w-4 h-4" /> Thêm quầy
          </button>
        </header>

        {error && (
          <div className="mb-6 p-4 rounded-2xl bg-destructive/10 text-destructive text-sm">
            {error}
          </div>
        )}

        {loading ? (
          <div className="glass rounded-[2.5rem] p-12 text-center text-muted-foreground">Đang tải...</div>
        ) : (
          <div className="glass rounded-[2.5rem] border border-border overflow-hidden">
            <table className="w-full text-left font-body text-sm">
              <thead className="bg-secondary/50 text-muted-foreground border-b border-border">
                <tr>
                  <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">Quầy</th>
                  <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">Mã</th>
                  <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">Địa chỉ</th>
                  <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">Nhân viên</th>
                  <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading text-right">Thao tác</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border/50">
                {stores.map((s) => (
                  <tr key={s.id} className="hover:bg-secondary/20 transition-colors">
                    <td className="px-8 py-6">
                      <span className="font-heading uppercase text-xs tracking-wider">{s.name}</span>
                      {!s.isActive && (
                        <span className="ml-2 text-[10px] text-muted-foreground">(Ẩn)</span>
                      )}
                    </td>
                    <td className="px-8 py-6 text-[10px] text-muted-foreground">{s.code ?? '—'}</td>
                    <td className="px-8 py-6 text-[10px] text-muted-foreground max-w-[200px] truncate">
                      {s.address ?? '—'}
                    </td>
                    <td className="px-8 py-6">
                      <div className="flex flex-wrap gap-1">
                        {(s.users ?? []).map((u) => (
                          <span
                            key={u.user.id}
                            className="inline-flex items-center gap-1 px-2 py-1 rounded-lg bg-secondary text-[10px]"
                          >
                            {u.user.fullName || u.user.email}
                            <button
                              type="button"
                              onClick={() => handleUnassign(s.id, u.user.id)}
                              className="text-destructive hover:opacity-80"
                              title="Bỏ gán"
                            >
                              <UserMinus className="w-3 h-3" />
                            </button>
                          </span>
                        ))}
                        <button
                          type="button"
                          onClick={() => setAssignModal(s)}
                          className="text-[10px] text-gold uppercase tracking-widest hover:underline"
                        >
                          + Gán NV
                        </button>
                      </div>
                    </td>
                    <td className="px-8 py-6 text-right">
                      <button
                        type="button"
                        onClick={() => openEdit(s)}
                        className="p-2 text-muted-foreground hover:text-gold transition-colors"
                        title="Sửa"
                      >
                        <Pencil className="w-4 h-4" />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDelete(s.id)}
                        className="p-2 text-muted-foreground hover:text-destructive transition-colors"
                        title="Xóa"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {stores.length === 0 && (
              <div className="p-12 text-center text-muted-foreground">
                Chưa có quầy nào. Nhấn &quot;Thêm quầy&quot; để tạo.
              </div>
            )}
          </div>
        )}

        {/* Modal create / edit */}
        {(modal === 'create' || modal === 'edit') && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
            <div className="glass rounded-[2.5rem] border border-border p-8 w-full max-w-md">
              <h2 className="text-xl font-heading uppercase tracking-wider mb-6">
                {modal === 'create' ? 'Thêm quầy' : 'Sửa quầy'}
              </h2>
              <form onSubmit={modal === 'create' ? handleCreate : handleUpdate} className="space-y-4">
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Tên quầy
                  </label>
                  <input
                    type="text"
                    value={form.name}
                    onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                    required
                  />
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Mã (tùy chọn)
                  </label>
                  <input
                    type="text"
                    value={form.code}
                    onChange={(e) => setForm((f) => ({ ...f, code: e.target.value }))}
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                  />
                </div>
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Địa chỉ (tùy chọn)
                  </label>
                  <input
                    type="text"
                    value={form.address}
                    onChange={(e) => setForm((f) => ({ ...f, address: e.target.value }))}
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                  />
                </div>
                <label className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={form.isActive}
                    onChange={(e) => setForm((f) => ({ ...f, isActive: e.target.checked }))}
                    className="rounded"
                  />
                  <span className="text-sm">Đang hoạt động</span>
                </label>
                <div className="flex gap-3 pt-4">
                  <button
                    type="submit"
                    disabled={saving}
                    className="flex-1 py-2.5 rounded-xl bg-gold text-primary font-heading text-xs uppercase tracking-widest disabled:opacity-50"
                  >
                    {saving ? 'Đang lưu...' : 'Lưu'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setModal(null)}
                    className="px-6 py-2.5 rounded-xl border border-border font-heading text-xs uppercase tracking-widest"
                  >
                    Hủy
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Assign staff modal */}
        {assignModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
            <div className="glass rounded-[2.5rem] border border-border p-8 w-full max-w-md">
              <h2 className="text-xl font-heading uppercase tracking-wider mb-2">
                Gán nhân viên vào quầy: {assignModal.name}
              </h2>
              <p className="text-sm text-muted-foreground mb-6">Chọn nhân viên (role STAFF) để gán.</p>
              <ul className="space-y-2 max-h-60 overflow-y-auto">
                {staffUsers
                  .filter((u) => !assignModal.users?.some((x) => x.user.id === u.id))
                  .map((u) => (
                    <li key={u.id} className="flex items-center justify-between py-2 border-b border-border/50">
                      <span className="text-sm">{u.fullName || u.email}</span>
                      <button
                        type="button"
                        onClick={() => handleAssign(assignModal.id, u.id)}
                        className="text-[10px] text-gold uppercase tracking-widest hover:underline"
                      >
                        Gán
                      </button>
                    </li>
                  ))}
                {staffUsers.filter((u) => !assignModal.users?.some((x) => x.user.id === u.id)).length === 0 && (
                  <li className="text-sm text-muted-foreground">Không còn nhân viên nào để gán.</li>
                )}
              </ul>
              <button
                type="button"
                onClick={() => setAssignModal(null)}
                className="mt-6 w-full py-2.5 rounded-xl border border-border font-heading text-xs uppercase tracking-widest"
              >
                Đóng
              </button>
            </div>
          </div>
        )}
      </main>
    </AuthGuard>
  );
}
