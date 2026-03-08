'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { userService } from '@/services/user.service';
import { useAuthStore } from '@/store/auth.store';
import { User, Mail, Shield, Edit2, Loader2 } from 'lucide-react';
import { useEffect, useState } from 'react';

type ProfileData = {
  id: string;
  email: string;
  phone?: string | null;
  role: string;
  fullName?: string | null;
  gender?: string | null;
  dateOfBirth?: string | null;
  address?: string | null;
  city?: string | null;
  country?: string | null;
  avatarUrl?: string | null;
  budgetMin?: number | null;
  budgetMax?: number | null;
  loyaltyPoints?: number;
  createdAt?: string;
};

export default function ProfilePage() {
  const { user: authUser, token, setAuth } = useAuthStore();
  const [data, setData] = useState<ProfileData | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState(false);
  const [form, setForm] = useState({
    fullName: '',
    gender: '',
    dateOfBirth: '',
    address: '',
    city: '',
    country: '',
    budgetMin: '' as string | number,
    budgetMax: '' as string | number,
  });

  const loadProfile = async () => {
    setLoading(true);
    setError(null);
    try {
      const me = await userService.getMe();
      setData(me);
      setForm({
        fullName: me.fullName ?? '',
        gender: me.gender ?? '',
        dateOfBirth: me.dateOfBirth ? me.dateOfBirth.slice(0, 10) : '',
        address: me.address ?? '',
        city: me.city ?? '',
        country: me.country ?? '',
        budgetMin: me.budgetMin ?? '',
        budgetMax: me.budgetMax ?? '',
      });
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProfile();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      const updated = await userService.updateProfile({
        fullName: form.fullName || undefined,
        gender: form.gender || undefined,
        dateOfBirth: form.dateOfBirth || undefined,
        address: form.address || undefined,
        city: form.city || undefined,
        country: form.country || undefined,
        budgetMin: typeof form.budgetMin === 'number' ? form.budgetMin : form.budgetMin ? Number(form.budgetMin) : undefined,
        budgetMax: typeof form.budgetMax === 'number' ? form.budgetMax : form.budgetMax ? Number(form.budgetMax) : undefined,
      });
      setData(updated);
      setEditing(false);
      if (token && authUser && (updated.fullName !== authUser.name || updated.email !== authUser.email)) {
        setAuth(
          { ...authUser, name: updated.fullName || updated.email, email: updated.email },
          token,
        );
      }
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <AuthGuard>
        <main className="p-8 max-w-5xl mx-auto flex items-center justify-center min-h-[400px]">
          <Loader2 className="w-8 h-8 animate-spin text-gold" />
        </main>
      </AuthGuard>
    );
  }

  return (
    <AuthGuard>
      <main className="p-8 max-w-5xl mx-auto">
        <header className="mb-12">
          <h1 className="text-4xl font-heading gold-gradient mb-2 uppercase tracking-tighter">
            Hồ sơ cá nhân
          </h1>
          <p className="text-muted-foreground font-body text-sm uppercase tracking-widest">
            Quản lý thông tin tài khoản của bạn
          </p>
        </header>

        {error && (
          <div className="mb-6 p-4 rounded-2xl bg-destructive/10 text-destructive text-sm">
            {error}
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
          <div className="lg:col-span-1 space-y-8">
            <div className="glass p-10 rounded-[3.5rem] border-gold/10 text-center relative group">
              <div className="w-32 h-32 rounded-[2.5rem] bg-secondary mx-auto mb-6 relative overflow-hidden border-2 border-border flex items-center justify-center">
                {data?.avatarUrl ? (
                  <img src={data.avatarUrl} alt="" className="w-full h-full object-cover" />
                ) : (
                  <User className="w-16 h-16 text-muted-foreground/50" />
                )}
              </div>
              <h2 className="font-heading text-xl text-foreground uppercase tracking-widest mb-1">
                {data?.fullName || data?.email || 'User'}
              </h2>
              <p className="text-[10px] text-gold uppercase tracking-[0.3em] font-bold">
                {data?.role ?? 'CUSTOMER'}
              </p>
            </div>

            <div className="glass p-8 rounded-[2.5rem] border-border space-y-6">
              <h3 className="font-heading text-[10px] uppercase tracking-widest text-muted-foreground mb-4">
                Bảo mật
              </h3>
              <div className="flex items-center gap-4 text-xs font-body text-foreground">
                <Shield className="w-4 h-4 text-emerald-500" />
                <span>Tài khoản được bảo vệ</span>
              </div>
            </div>
          </div>

          <div className="lg:col-span-2 space-y-8">
            <div className="glass p-10 rounded-[3rem] border-border">
              <div className="flex justify-between items-center mb-10">
                <h3 className="font-heading text-lg uppercase tracking-widest">Thông tin cá nhân</h3>
                {!editing ? (
                  <button
                    type="button"
                    onClick={() => setEditing(true)}
                    className="flex items-center gap-2 text-gold text-[10px] uppercase font-heading tracking-widest hover:underline"
                  >
                    <Edit2 className="w-3 h-3" /> Chỉnh sửa
                  </button>
                ) : (
                  <div className="flex gap-2">
                    <button
                      type="button"
                      onClick={handleSave}
                      disabled={saving}
                      className="flex items-center gap-2 px-4 py-2 rounded-xl bg-gold text-primary text-[10px] uppercase font-heading tracking-widest disabled:opacity-50"
                    >
                      {saving ? <Loader2 className="w-3 h-3 animate-spin" /> : null} Lưu
                    </button>
                    <button
                      type="button"
                      onClick={() => setEditing(false)}
                      className="px-4 py-2 rounded-xl border border-border text-[10px] uppercase font-heading tracking-widest"
                    >
                      Hủy
                    </button>
                  </div>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
                <div className="space-y-2">
                  <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                    Họ tên
                  </label>
                  {editing ? (
                    <input
                      type="text"
                      value={form.fullName}
                      onChange={(e) => setForm((f) => ({ ...f, fullName: e.target.value }))}
                      className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                    />
                  ) : (
                    <p className="font-body text-sm border-b border-border/50 pb-2">
                      {data?.fullName || '—'}
                    </p>
                  )}
                </div>
                <div className="space-y-2">
                  <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                    Email
                  </label>
                  <p className="font-body text-sm border-b border-border/50 pb-2 flex items-center gap-2">
                    <Mail className="w-3 h-3 text-muted-foreground" />
                    {data?.email || '—'}
                  </p>
                  <span className="text-[10px] text-muted-foreground">Email không thể thay đổi</span>
                </div>
                <div className="space-y-2">
                  <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                    Giới tính
                  </label>
                  {editing ? (
                    <select
                      value={form.gender}
                      onChange={(e) => setForm((f) => ({ ...f, gender: e.target.value }))}
                      className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                    >
                      <option value="">—</option>
                      <option value="MALE">Nam</option>
                      <option value="FEMALE">Nữ</option>
                      <option value="OTHER">Khác</option>
                    </select>
                  ) : (
                    <p className="font-body text-sm border-b border-border/50 pb-2">
                      {data?.gender === 'MALE' ? 'Nam' : data?.gender === 'FEMALE' ? 'Nữ' : data?.gender || '—'}
                    </p>
                  )}
                </div>
                <div className="space-y-2">
                  <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                    Ngày sinh
                  </label>
                  {editing ? (
                    <input
                      type="date"
                      value={form.dateOfBirth}
                      onChange={(e) => setForm((f) => ({ ...f, dateOfBirth: e.target.value }))}
                      className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                    />
                  ) : (
                    <p className="font-body text-sm border-b border-border/50 pb-2">
                      {data?.dateOfBirth
                        ? new Date(data.dateOfBirth).toLocaleDateString('vi-VN')
                        : '—'}
                    </p>
                  )}
                </div>
                <div className="space-y-2 md:col-span-2">
                  <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                    Địa chỉ
                  </label>
                  {editing ? (
                    <input
                      type="text"
                      value={form.address}
                      onChange={(e) => setForm((f) => ({ ...f, address: e.target.value }))}
                      className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                    />
                  ) : (
                    <p className="font-body text-sm border-b border-border/50 pb-2">
                      {data?.address || '—'}
                    </p>
                  )}
                </div>
                <div className="space-y-2">
                  <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                    Thành phố
                  </label>
                  {editing ? (
                    <input
                      type="text"
                      value={form.city}
                      onChange={(e) => setForm((f) => ({ ...f, city: e.target.value }))}
                      className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                    />
                  ) : (
                    <p className="font-body text-sm border-b border-border/50 pb-2">
                      {data?.city || '—'}
                    </p>
                  )}
                </div>
                <div className="space-y-2">
                  <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                    Quốc gia
                  </label>
                  {editing ? (
                    <input
                      type="text"
                      value={form.country}
                      onChange={(e) => setForm((f) => ({ ...f, country: e.target.value }))}
                      className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                    />
                  ) : (
                    <p className="font-body text-sm border-b border-border/50 pb-2">
                      {data?.country || '—'}
                    </p>
                  )}
                </div>
                {data?.role === 'CUSTOMER' && (
                  <>
                    <div className="space-y-2">
                      <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                        Ngân sách tối thiểu (VNĐ)
                      </label>
                      {editing ? (
                        <input
                          type="number"
                          value={form.budgetMin}
                          onChange={(e) =>
                            setForm((f) => ({
                              ...f,
                              budgetMin: e.target.value ? Number(e.target.value) : '',
                            }))
                          }
                          className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                        />
                      ) : (
                        <p className="font-body text-sm border-b border-border/50 pb-2">
                          {data?.budgetMin != null
                            ? new Intl.NumberFormat('vi-VN').format(data.budgetMin)
                            : '—'}
                        </p>
                      )}
                    </div>
                    <div className="space-y-2">
                      <label className="text-[8px] uppercase tracking-[0.3em] text-muted-foreground font-heading">
                        Ngân sách tối đa (VNĐ)
                      </label>
                      {editing ? (
                        <input
                          type="number"
                          value={form.budgetMax}
                          onChange={(e) =>
                            setForm((f) => ({
                              ...f,
                              budgetMax: e.target.value ? Number(e.target.value) : '',
                            }))
                          }
                          className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                        />
                      ) : (
                        <p className="font-body text-sm border-b border-border/50 pb-2">
                          {data?.budgetMax != null
                            ? new Intl.NumberFormat('vi-VN').format(data.budgetMax)
                            : '—'}
                        </p>
                      )}
                    </div>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      </main>
    </AuthGuard>
  );
}
