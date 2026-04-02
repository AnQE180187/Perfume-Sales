'use client';

import { AuthGuard } from '@/components/auth/auth-guard';
import { userService } from '@/services/user.service';
import { authService } from '@/services/auth.service';
import { useAuthStore } from '@/store/auth.store';
import { User, Mail, Shield, Edit2, Loader2, CheckCircle, Send, Phone, Eye, EyeOff, X } from 'lucide-react';
import { useEffect, useState } from 'react';
import { toast } from 'sonner';

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
  emailVerified?: boolean;
};

export default function ProfilePage() {
  const { user: authUser, token, setAuth } = useAuthStore();
  const [data, setData] = useState<ProfileData | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState(false);
  const [sendingVerify, setSendingVerify] = useState(false);
  const [verifyMsg, setVerifyMsg] = useState<string | null>(null);

  const [changePasswordOpen, setChangePasswordOpen] = useState(false);
  const [changePasswordLoading, setChangePasswordLoading] = useState(false);
  const [changePasswordError, setChangePasswordError] = useState<string | null>(null);
  const [changePasswordSuccess, setChangePasswordSuccess] = useState<string | null>(null);
  const [showOldPassword, setShowOldPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [changePasswordForm, setChangePasswordForm] = useState({
    oldPassword: '',
    newPassword: '',
    confirmPassword: '',
  });
  const [form, setForm] = useState({
    fullName: '',
    phone: '',
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
        phone: me.phone ?? '',
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

  const openChangePassword = () => {
    setChangePasswordError(null);
    setChangePasswordForm({
      oldPassword: '',
      newPassword: '',
      confirmPassword: '',
    });
    setChangePasswordOpen(true);
  };

  const closeChangePassword = () => {
    setChangePasswordOpen(false);
    setChangePasswordLoading(false);
    setChangePasswordError(null);
    setChangePasswordSuccess(null);
  };

  const submitChangePassword = async () => {
    if (changePasswordLoading) return;

    setChangePasswordError(null);
    setChangePasswordSuccess(null);

    if (!changePasswordForm.oldPassword) {
      setChangePasswordError('Vui lòng nhập mật khẩu cũ');
      return;
    }

    if (!changePasswordForm.newPassword || changePasswordForm.newPassword.length < 6) {
      setChangePasswordError('Mật khẩu mới phải có ít nhất 6 ký tự');
      return;
    }

    if (changePasswordForm.newPassword !== changePasswordForm.confirmPassword) {
      setChangePasswordError('Xác nhận mật khẩu mới không khớp');
      return;
    }

    setChangePasswordLoading(true);
    try {
      await authService.changePassword({
        oldPassword: changePasswordForm.oldPassword,
        newPassword: changePasswordForm.newPassword,
      });

      toast.success('Đổi mật khẩu thành công!');
      setChangePasswordSuccess('Đổi mật khẩu thành công!');
      // Keep the modal open briefly so user can see confirmation.
      setTimeout(() => closeChangePassword(), 800);
    } catch (e: unknown) {
      setChangePasswordError((e as Error).message || 'Không thể đổi mật khẩu!');
    } finally {
      setChangePasswordLoading(false);
    }
  };

  const handleResendVerification = async () => {
    setSendingVerify(true);
    setVerifyMsg(null);
    try {
      const res = await authService.resendVerificationEmail();
      setVerifyMsg(res.message ?? 'Đã gửi email.');
    } catch (e) {
      setVerifyMsg((e as Error).message);
    } finally {
      setSendingVerify(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      const updated = await userService.updateProfile({
        fullName: form.fullName || undefined,
        phone: form.phone || undefined,
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

              <div className="pt-2">
                <button
                  type="button"
                  onClick={openChangePassword}
                  className="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl bg-gold text-primary text-[10px] uppercase font-heading tracking-widest hover:scale-[1.01] transition-all disabled:opacity-50"
                  disabled={changePasswordLoading}
                >
                  {changePasswordLoading ? <Loader2 className="w-3 h-3 animate-spin" /> : null}
                  Đổi Mật Khẩu
                </button>
              </div>
            </div>

            <div className="glass p-8 rounded-[2.5rem] border-border space-y-4">
              <h3 className="font-heading text-[10px] uppercase tracking-widest text-muted-foreground mb-4">
                Xác thực email
              </h3>
              {data?.emailVerified ? (
                <div className="flex items-center gap-4 text-xs font-body text-emerald-500">
                  <CheckCircle className="w-4 h-4" />
                  <span>Email đã được xác thực</span>
                </div>
              ) : (
                <div className="space-y-3">
                  <p className="text-xs text-muted-foreground">
                    Email chưa xác thực. (Tùy chọn – không ảnh hưởng sử dụng)
                  </p>
                  <button
                    type="button"
                    onClick={handleResendVerification}
                    disabled={sendingVerify}
                    className="flex items-center gap-2 px-4 py-2 rounded-xl border border-gold text-gold text-[10px] font-heading uppercase tracking-widest hover:bg-gold/10 disabled:opacity-50"
                  >
                    {sendingVerify ? <Loader2 className="w-3 h-3 animate-spin" /> : <Send className="w-3 h-3" />}
                    Gửi email xác thực
                  </button>
                  {verifyMsg && (
                    <p className="text-[10px] text-muted-foreground">{verifyMsg}</p>
                  )}
                </div>
              )}
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
                    Số điện thoại
                  </label>
                  {editing ? (
                    <input
                      type="tel"
                      value={form.phone}
                      onChange={(e) => setForm((f) => ({ ...f, phone: e.target.value }))}
                      className="w-full px-3 py-2 rounded-xl border border-border bg-background text-sm"
                      placeholder="+84 901 234 567"
                    />
                  ) : (
                    <p className="font-body text-sm border-b border-border/50 pb-2 flex items-center gap-2">
                      <Phone className="w-3 h-3 text-muted-foreground" />
                      {data?.phone || '—'}
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

      {changePasswordOpen ? (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-6"
          onMouseDown={(e) => {
            if (e.target === e.currentTarget) closeChangePassword();
          }}
          role="dialog"
          aria-modal="true"
        >
          <div className="w-full max-w-md glass rounded-[3rem] border border-gold/10 bg-background/70 shadow-2xl shadow-gold/10 p-6 md:p-10">
            <div className="flex items-start justify-between gap-4 mb-6">
              <div>
                <h2 className="text-2xl font-heading text-foreground uppercase tracking-widest">
                  Đổi mật khẩu
                </h2>
                <p className="text-sm text-muted-foreground mt-2 leading-relaxed">
                  Nhập mật khẩu cũ, mật khẩu mới và xác nhận lại.
                </p>
              </div>

              <button
                type="button"
                onClick={closeChangePassword}
                className="w-6 h-6 p-0.5 rounded-full border border-border text-muted-foreground hover:text-foreground hover:border-gold hover:bg-gold/5 transition-colors"
                aria-label="Close"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {changePasswordError ? (
              <div className="mb-4 p-3 rounded-2xl bg-destructive/10 text-destructive text-sm border border-destructive/20">
                {changePasswordError}
              </div>
            ) : null}
            {changePasswordSuccess ? (
              <div className="mb-4 p-3 rounded-2xl bg-emerald-500/10 text-emerald-600 text-sm border border-emerald-500/20">
                {changePasswordSuccess}
              </div>
            ) : null}

            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">
                  Mật khẩu cũ
                </label>
                <div className="relative">
                  <input
                    type={showOldPassword ? 'text' : 'password'}
                    value={changePasswordForm.oldPassword}
                    onChange={(e) =>
                      setChangePasswordForm((f) => ({ ...f, oldPassword: e.target.value }))
                    }
                    className="w-full bg-background/50 border border-border rounded-2xl py-3 px-4 pr-12 text-sm outline-none focus:border-gold transition-all"
                    autoComplete="current-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowOldPassword((s) => !s)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                    aria-label="Toggle old password visibility"
                  >
                    {showOldPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">
                  Mật khẩu mới
                </label>
                <div className="relative">
                  <input
                    type={showNewPassword ? 'text' : 'password'}
                    value={changePasswordForm.newPassword}
                    onChange={(e) =>
                      setChangePasswordForm((f) => ({ ...f, newPassword: e.target.value }))
                    }
                    className="w-full bg-background/50 border border-border rounded-2xl py-3 px-4 pr-12 text-sm outline-none focus:border-gold transition-all"
                    autoComplete="new-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowNewPassword((s) => !s)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                    aria-label="Toggle new password visibility"
                  >
                    {showNewPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-[10px] font-bold tracking-widest uppercase text-stone-400">
                  Xác nhận mật khẩu mới
                </label>
                <div className="relative">
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    value={changePasswordForm.confirmPassword}
                    onChange={(e) =>
                      setChangePasswordForm((f) => ({
                        ...f,
                        confirmPassword: e.target.value,
                      }))
                    }
                    className="w-full bg-background/50 border border-border rounded-2xl py-3 px-4 pr-12 text-sm outline-none focus:border-gold transition-all"
                    autoComplete="new-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword((s) => !s)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                    aria-label="Toggle confirm password visibility"
                  >
                    {showConfirmPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>
            </div>

            <div className="flex items-center gap-4 mt-8">
              <button
                type="button"
                onClick={closeChangePassword}
                disabled={changePasswordLoading}
                className="flex-1 px-4 py-3 rounded-2xl border border-border text-[10px] uppercase tracking-widest font-heading text-stone-500 hover:text-foreground hover:border-gold transition-colors disabled:opacity-50"
              >
                Hủy
              </button>
              <button
                type="button"
                onClick={() => void submitChangePassword()}
                disabled={changePasswordLoading}
                className="flex-1 px-4 py-3 rounded-2xl bg-gold text-primary-foreground text-[10px] uppercase tracking-widest font-heading hover:scale-[1.01] transition-all disabled:opacity-50"
              >
                {changePasswordLoading ? (
                  <span className="inline-flex items-center justify-center gap-2">
                    <Loader2 className="w-3 h-3 animate-spin" /> Dang doi...
                  </span>
                ) : (
                  'Xác nhận'
                )}
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </AuthGuard>
  );
}
