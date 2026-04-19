import { useState, useEffect } from "react";
import { User, Phone, Check, ArrowLeft, Mail, Calendar } from "lucide-react";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import axiosClient from "@/services/axiosClient";
import TransitionLink from "@/components/transition-link";
import { useAtom } from "jotai";
import { systemUserState } from "@/state";

export default function EditProfilePage() {
  const navigate = useNavigate();
  const [systemUser, setSystemUser] = useAtom(systemUserState);

  const [loading, setLoading] = useState(false);
  const [fetching, setFetching] = useState(true);

  const [formData, setFormData] = useState({
    fullName: "",
    phone: "",
    gender: "",
    dateOfBirth: "",
  });

  useEffect(() => {
    async function loadData() {
      try {
        const res: any = await axiosClient.get("/users/me");
        setFormData({
          fullName: res.fullName || "",
          phone: res.phone || "",
          gender: res.gender || "",
          dateOfBirth: res.dateOfBirth ? new Date(res.dateOfBirth).toISOString().split('T')[0] : "",
        });
      } catch (err) {
         console.error(err);
      } finally {
        setFetching(false);
      }
    }
    loadData();
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSave = async () => {
    const phoneRegex = /^(0|\+84)[0-9]{9,10}$/;
    if (!formData.fullName.trim()) {
      toast.error("Vui lòng nhập họ tên");
      return;
    }
    if (formData.phone && !phoneRegex.test(formData.phone.trim())) {
      toast.error("Số điện thoại không hợp lệ");
      return;
    }
    try {
      setLoading(true);
      const res: any = await axiosClient.patch("/users/me", {
        fullName: formData.fullName,
        phone: formData.phone,
        gender: formData.gender,
        dateOfBirth: formData.dateOfBirth ? new Date(formData.dateOfBirth).toISOString() : undefined,
      });
      // Optionally update systemUser jotai atom if it holds basic info
      if (systemUser) {
         setSystemUser({ ...systemUser, ...res });
      }
      toast.success("Cập nhật thành công!");
      navigate("/profile");
    } catch (err: any) {
      toast.error(err?.response?.data?.message || "Cập nhật thất bại");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-full bg-section">
      <div className="bg-white p-4 flex gap-3 items-center sticky top-0 z-10 border-b">
        <button onClick={() => navigate(-1)} className="p-1 -ml-1">
          <ArrowLeft size={24} />
        </button>
        <div className="text-lg font-bold">Chỉnh sửa hồ sơ</div>
      </div>

      {fetching ? (
        <div className="p-4 space-y-4">
           {/* Skeleton loader */}
           <div className="h-12 bg-gray-200 rounded-xl animate-pulse"></div>
           <div className="h-12 bg-gray-200 rounded-xl animate-pulse"></div>
           <div className="h-12 bg-gray-200 rounded-xl animate-pulse"></div>
        </div>
      ) : (
        <div className="p-4 space-y-4">
          <div className="relative">
            <User className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="text"
              name="fullName"
              placeholder="Họ và tên"
              value={formData.fullName}
              onChange={handleChange}
              className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none focus:border-primary"
            />
          </div>

          <div className="relative">
            <Phone className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="tel"
              name="phone"
              placeholder="Số điện thoại"
              value={formData.phone}
              onChange={handleChange}
              className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none focus:border-primary"
            />
          </div>

          <div className="flex gap-4">
            <label className="flex items-center gap-2 text-sm bg-white border p-3 rounded-xl flex-1 cursor-pointer">
              <input type="radio" name="gender" value="MALE" checked={formData.gender === 'MALE'} onChange={handleChange} className="accent-primary" />
              Nam
            </label>
            <label className="flex items-center gap-2 text-sm bg-white border p-3 rounded-xl flex-1 cursor-pointer">
              <input type="radio" name="gender" value="FEMALE" checked={formData.gender === 'FEMALE'} onChange={handleChange} className="accent-primary" />
              Nữ
            </label>
          </div>

          <div className="relative">
            <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="date"
              name="dateOfBirth"
              value={formData.dateOfBirth}
              onChange={handleChange}
              className="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-4 text-sm focus:outline-none focus:border-primary"
            />
          </div>

          <button
            onClick={handleSave}
            disabled={loading}
            className={`w-full bg-primary text-white font-bold py-3.5 rounded-xl shadow-lg mt-6 ${loading ? 'opacity-70' : 'active:scale-95 transition-all'}`}
          >
            {loading ? "Đang lưu..." : "Lưu thay đổi"}
          </button>
        </div>
      )}
    </div>
  );
}
