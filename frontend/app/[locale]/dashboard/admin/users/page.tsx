'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { userService, type AdminUser } from '@/services/user.service';
import { storesService } from '@/services/stores.service';
import { Users, Loader2, Pencil, Store, UserPlus, UserMinus } from 'lucide-react';
import { useEffect, useState, useCallback } from 'react';

const ROLE_LABELS: Record<string, string> = {
  ADMIN: 'Admin',
  STAFF: 'Nhân viên',
  CUSTOMER: 'Khách hàng',
};

export default function UsersAdmin() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [stores, setStores] = useState<{ id: string; name: string; code?: string | null }[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [roleFilter, setRoleFilter] = useState<string>('');
  const [editModal, setEditModal] = useState<AdminUser | null>(null);
  const [storeModal, setStoreModal] = useState<AdminUser | null>(null);
  const [editForm, setEditForm] = useState({ role: '', isActive: true });
  const [saving, setSaving] = useState(false);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await userService.adminListUsers(roleFilter || undefined);
      setUsers(list);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }, [roleFilter]);

  const fetchStores = useCallback(async () => {
    try {
      const list = await storesService.list();
      setStores(list);
    } catch {
      // optional
    }
  }, []);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  useEffect(() => {
    if (storeModal) fetchStores();
  }, [storeModal, fetchStores]);

  const handleUpdateRole = async () => {
    if (!editModal) return;
    setSaving(true);
    setError(null);
    try {
      await userService.adminUpdateUser(editModal.id, {
        role: editForm.role || undefined,
        isActive: editForm.isActive,
      });
      setEditModal(null);
      fetchUsers();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const handleAssignStore = async (storeId: string, userId: string) => {
    try {
      await storesService.assignStaff(storeId, userId);
      setStoreModal(null);
      fetchUsers();
    } catch (e) {
      setError((e as Error).message);
    }
  };

  const handleUnassignStore = async (storeId: string, userId: string) => {
    try {
      await storesService.unassignStaff(storeId, userId);
      fetchUsers();
    } catch (e) {
      setError((e as Error).message);
    }
  };

  const openEdit = (u: AdminUser) => {
    setEditModal(u);
    setEditForm({ role: u.role, isActive: u.isActive });
  };

  const userStores = (u: AdminUser) => u.stores ?? [];
  const isStaff = (u: AdminUser) => u.role === 'STAFF';

  return (
    <AuthGuard allowedRoles={['admin']}>
      <main className="p-8">
        <header className="mb-12">
          <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">
            Quản lý người dùng
          </h1>
          <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">
            Xem danh sách, đổi role, gán quầy cho nhân viên
          </p>
        </header>

        {error && (
          <div className="mb-6 p-4 rounded-2xl bg-destructive/10 text-destructive text-sm">
            {error}
          </div>
        )}

        <div className="mb-6 flex items-center gap-4">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-heading">
            Lọc role:
          </label>
          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
            className="rounded-xl border border-border bg-background px-4 py-2 text-sm font-heading uppercase tracking-wider"
          >
            <option value="">Tất cả</option>
            <option value="ADMIN">Admin</option>
            <option value="STAFF">Nhân viên</option>
            <option value="CUSTOMER">Khách hàng</option>
          </select>
        </div>

        <div className="glass rounded-[2.5rem] border-border overflow-hidden">
          <table className="w-full text-left font-body text-sm">
            <thead className="bg-secondary/50 text-muted-foreground border-b border-border">
              <tr>
                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">
                  Người dùng
                </th>
                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">
                  Role
                </th>
                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">
                  Quầy (Staff)
                </th>
                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading">
                  Trạng thái
                </th>
                <th className="px-8 py-5 text-[10px] uppercase tracking-widest font-heading text-right">
                  Thao tác
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border/50">
              {loading ? (
                <tr>
                  <td colSpan={5} className="px-8 py-12 text-center">
                    <Loader2 className="w-6 h-6 animate-spin text-gold mx-auto" />
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-8 py-12 text-center text-muted-foreground">
                    Không có người dùng nào
                  </td>
                </tr>
              ) : (
                users.map((u) => (
                  <tr key={u.id} className="hover:bg-secondary/20 transition-colors">
                    <td className="px-8 py-6">
                      <div className="flex flex-col">
                        <span className="font-heading uppercase text-xs tracking-wider">
                          {u.fullName || u.email}
                        </span>
                        <span className="text-[10px] text-muted-foreground">{u.email}</span>
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <span className="text-[10px] font-bold uppercase tracking-widest text-gold">
                        {ROLE_LABELS[u.role] ?? u.role}
                      </span>
                    </td>
                    <td className="px-8 py-6">
                      {isStaff(u) ? (
                        <div className="flex flex-wrap gap-1 items-center">
                          {userStores(u).map((s) => (
                            <span
                              key={s.store.id}
                              className="inline-flex items-center gap-1 px-2 py-1 rounded-lg bg-secondary text-[10px]"
                            >
                              {s.store.name}
                              <button
                                type="button"
                                onClick={() => handleUnassignStore(s.store.id, u.id)}
                                className="text-destructive hover:opacity-80"
                                title="Bỏ gán quầy"
                              >
                                <UserMinus className="w-3 h-3" />
                              </button>
                            </span>
                          ))}
                          <button
                            type="button"
                            onClick={() => setStoreModal(u)}
                            className="text-[10px] text-gold uppercase tracking-widest hover:underline flex items-center gap-1"
                          >
                            <Store className="w-3 h-3" /> Gán quầy
                          </button>
                        </div>
                      ) : (
                        <span className="text-[10px] text-muted-foreground">—</span>
                      )}
                    </td>
                    <td className="px-8 py-6">
                      <span
                        className={`px-4 py-1.5 rounded-full text-[8px] uppercase tracking-widest font-bold border ${
                          u.isActive
                            ? 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20'
                            : 'bg-stone-500/10 text-stone-500 border-stone-500/20'
                        }`}
                      >
                        {u.isActive ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td className="px-8 py-6 text-right">
                      <button
                        type="button"
                        onClick={() => openEdit(u)}
                        className="flex items-center gap-1 text-[10px] uppercase font-heading tracking-widest text-muted-foreground hover:text-gold transition-colors"
                      >
                        <Pencil className="w-3 h-3" /> Sửa
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Edit role modal */}
        {editModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
            <div className="glass rounded-[2.5rem] border border-border p-8 w-full max-w-md">
              <h2 className="text-xl font-heading uppercase tracking-wider mb-2">
                Sửa người dùng: {editModal.fullName || editModal.email}
              </h2>
              <p className="text-sm text-muted-foreground mb-6">{editModal.email}</p>
              <div className="space-y-4">
                <div>
                  <label className="block text-[10px] uppercase tracking-widest text-muted-foreground mb-1">
                    Role
                  </label>
                  <select
                    value={editForm.role}
                    onChange={(e) => setEditForm((f) => ({ ...f, role: e.target.value }))}
                    className="w-full px-4 py-2.5 rounded-xl border border-border bg-background"
                  >
                    <option value="CUSTOMER">Khách hàng</option>
                    <option value="STAFF">Nhân viên</option>
                    <option value="ADMIN">Admin</option>
                  </select>
                </div>
                <label className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={editForm.isActive}
                    onChange={(e) => setEditForm((f) => ({ ...f, isActive: e.target.checked }))}
                    className="rounded"
                  />
                  <span className="text-sm">Đang hoạt động</span>
                </label>
              </div>
              <div className="flex gap-3 mt-6">
                <button
                  type="button"
                  onClick={handleUpdateRole}
                  disabled={saving}
                  className="flex-1 py-2.5 rounded-xl bg-gold text-primary font-heading text-xs uppercase tracking-widest disabled:opacity-50"
                >
                  {saving ? 'Đang lưu...' : 'Lưu'}
                </button>
                <button
                  type="button"
                  onClick={() => setEditModal(null)}
                  className="px-6 py-2.5 rounded-xl border border-border font-heading text-xs uppercase tracking-widest"
                >
                  Hủy
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Assign store modal (for Staff) */}
        {storeModal && isStaff(storeModal) && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
            <div className="glass rounded-[2.5rem] border border-border p-8 w-full max-w-md">
              <h2 className="text-xl font-heading uppercase tracking-wider mb-2">
                Gán quầy cho: {storeModal.fullName || storeModal.email}
              </h2>
              <p className="text-sm text-muted-foreground mb-6">Chọn quầy để gán nhân viên.</p>
              <ul className="space-y-2 max-h-60 overflow-y-auto">
                {stores
                  .filter(
                    (s) =>
                      !userStores(storeModal).some((us) => us.store.id === s.id),
                  )
                  .map((s) => (
                    <li
                      key={s.id}
                      className="flex items-center justify-between py-2 border-b border-border/50"
                    >
                      <span className="text-sm">{s.name}</span>
                      <button
                        type="button"
                        onClick={() =>
                          handleAssignStore(s.id, storeModal.id)
                        }
                        className="text-[10px] text-gold uppercase tracking-widest hover:underline flex items-center gap-1"
                      >
                        <UserPlus className="w-3 h-3" /> Gán
                      </button>
                    </li>
                  ))}
                {stores.filter(
                  (s) =>
                    !userStores(storeModal).some((us) => us.store.id === s.id),
                ).length === 0 && (
                  <li className="text-sm text-muted-foreground">
                    Đã gán hết quầy hoặc chưa có quầy.
                  </li>
                )}
              </ul>
              <button
                type="button"
                onClick={() => setStoreModal(null)}
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
