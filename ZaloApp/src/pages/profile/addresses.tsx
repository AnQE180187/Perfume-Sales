import { useState, useEffect } from "react";
import { ArrowLeft, MapPin, Plus, Trash2, Edit2, CheckCircle2 } from "lucide-react";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import axiosClient from "@/services/axiosClient";

export default function AddressesPage() {
  const navigate = useNavigate();
  const [addresses, setAddresses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  // Form State
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    streetLine1: "",
    city: "",
    state: "",
    postalCode: "",
    country: "VN",
  });

  const fetchAddresses = async () => {
    try {
      setLoading(true);
      const res: any = await axiosClient.get("/addresses");
      const list = Array.isArray(res) ? res : res.data || [];
      setAddresses(list);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAddresses();
  }, []);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSave = async () => {
    try {
      const payload = {
         streetLine1: formData.streetLine1,
         city: formData.city,
         state: formData.state,
         postalCode: formData.postalCode || '000000',
         country: formData.country,
      };

      if (editingId) {
        await axiosClient.patch(`/addresses/${editingId}`, payload);
        toast.success("Cập nhật địa chỉ thành công");
      } else {
        await axiosClient.post("/addresses", payload);
        toast.success("Thêm địa chỉ thành công");
      }
      setShowForm(false);
      setEditingId(null);
      setFormData({ streetLine1: "", city: "", state: "", postalCode: "", country: "VN" });
      fetchAddresses();
    } catch (err) {
      toast.error("Có lỗi xảy ra khi lưu địa chỉ");
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm("Bạn có chắc chắn muốn xoá địa chỉ này?")) return;
    try {
      await axiosClient.delete(`/addresses/${id}`);
      toast.success("Đã xoá địa chỉ");
      fetchAddresses();
    } catch (err) {
      toast.error("Không thể xoá địa chỉ");
    }
  };

  const setAsDefault = async (id: string) => {
    try {
      await axiosClient.patch(`/addresses/${id}/default`);
      toast.success("Đã đặt làm mặc định");
      fetchAddresses();
    } catch (err) {
      toast.error("Lỗi khi cập nhật");
    }
  };

  if (showForm) {
    return (
      <div className="min-h-full bg-section">
        <div className="bg-white p-4 flex gap-3 items-center sticky top-0 z-10 border-b">
          <button onClick={() => { setShowForm(false); setEditingId(null); }} className="p-1 -ml-1">
            <ArrowLeft size={24} />
          </button>
          <div className="text-lg font-bold">{editingId ? "Sửa địa chỉ" : "Thêm mới"}</div>
        </div>
        <div className="p-4 space-y-4">
          <input type="text" name="streetLine1" value={formData.streetLine1} onChange={handleInputChange} placeholder="Số nhà, Tên đường" className="w-full bg-white border border-gray-200 rounded-xl py-3 px-4" />
          <input type="text" name="city" value={formData.city} onChange={handleInputChange} placeholder="Quận / Huyện" className="w-full bg-white border border-gray-200 rounded-xl py-3 px-4" />
          <input type="text" name="state" value={formData.state} onChange={handleInputChange} placeholder="Tỉnh / Thành phố" className="w-full bg-white border border-gray-200 rounded-xl py-3 px-4" />
          <button onClick={handleSave} className="w-full bg-primary text-white font-bold py-3.5 rounded-xl mt-6 active:scale-95 transition-transform">
            Lưu địa chỉ
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-full bg-section">
      <div className="bg-white p-4 flex gap-3 items-center sticky top-0 z-10 border-b">
        <button onClick={() => navigate(-1)} className="p-1 -ml-1">
          <ArrowLeft size={24} />
        </button>
        <div className="text-lg font-bold">Địa chỉ nhận hàng</div>
      </div>

      <div className="p-4 space-y-3">
        {loading ? (
           <div className="h-20 bg-gray-200 rounded-xl animate-pulse"></div>
        ) : addresses.length === 0 ? (
           <div className="text-center py-10 text-gray-500 flex flex-col items-center">
             <MapPin size={40} className="mb-2 text-gray-300" />
             Chưa có địa chỉ nào được lưu
           </div>
        ) : (
          addresses.map((addr) => (
            <div key={addr.id} className="bg-white p-4 rounded-xl border border-gray-100 shadow-sm relative">
              <div className="flex gap-2 items-start mb-2">
                 <MapPin className="text-primary mt-0.5" size={18} />
                 <div className="flex-1">
                    <p className="font-semibold text-gray-800">{addr.streetLine1}</p>
                    <p className="text-sm text-gray-500">{addr.city}, {addr.state}</p>
                 </div>
              </div>
              <div className="flex justify-between items-center mt-3 pt-3 border-t border-gray-100">
                <button 
                  onClick={() => addr.isDefault ? null : setAsDefault(addr.id)}
                  className={`flex items-center gap-1.5 text-xs font-medium ${addr.isDefault ? 'text-primary' : 'text-gray-400'}`}
                >
                  <CheckCircle2 size={16} /> {addr.isDefault ? 'Mặc định' : 'Đặt mặc định'}
                </button>

                <div className="flex gap-4">
                  <button onClick={() => {
                     setEditingId(addr.id);
                     setFormData({
                       streetLine1: addr.streetLine1 || '',
                       city: addr.city || '',
                       state: addr.state || '',
                       postalCode: addr.postalCode || '',
                       country: addr.country || 'VN'
                     });
                     setShowForm(true);
                  }} className="text-blue-500 p-1"><Edit2 size={16} /></button>
                  <button onClick={() => handleDelete(addr.id)} className="text-red-500 p-1"><Trash2 size={16} /></button>
                </div>
              </div>
            </div>
          ))
        )}

        <button 
          onClick={() => { setEditingId(null); setFormData({ streetLine1: "", city: "", state: "", postalCode: "", country: "VN" }); setShowForm(true); }}
          className="w-full mt-4 flex items-center justify-center gap-2 py-3.5 border-2 border-dashed border-primary text-primary rounded-xl font-semibold bg-white"
        >
          <Plus size={20} /> Thêm địa chỉ mới
        </button>
      </div>
    </div>
  );
}
