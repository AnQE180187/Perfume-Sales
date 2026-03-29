import 'address.dart';
import 'ghn_models.dart';

class AddressFormState {
  final Address? editingAddress;
  final AddressLabel label;
  final String recipientName;
  final String phone;
  final String fullAddress;
  final String note;
  final int? provinceId;
  final int? districtId;
  final String? wardCode;
  final int? serviceId;
  final List<GhnProvince> provinces;
  final List<GhnDistrict> districts;
  final List<GhnWard> wards;
  final List<GhnServiceOption> services;
  final bool loadingProvinces;
  final bool loadingDistricts;
  final bool loadingWards;
  final bool loadingServices;
  final bool isSubmitting;
  final String? errorMessage;

  const AddressFormState({
    this.editingAddress,
    this.label = AddressLabel.home,
    this.recipientName = '',
    this.phone = '',
    this.fullAddress = '',
    this.note = '',
    this.provinceId,
    this.districtId,
    this.wardCode,
    this.serviceId,
    this.provinces = const [],
    this.districts = const [],
    this.wards = const [],
    this.services = const [],
    this.loadingProvinces = false,
    this.loadingDistricts = false,
    this.loadingWards = false,
    this.loadingServices = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  bool get canSubmit {
    return recipientName.trim().isNotEmpty &&
        phone.trim().isNotEmpty &&
        fullAddress.trim().isNotEmpty &&
        provinceId != null &&
        districtId != null &&
        wardCode != null &&
        wardCode!.isNotEmpty &&
        serviceId != null &&
        !isSubmitting;
  }

  bool get isEditing => editingAddress != null;

  AddressFormState copyWith({
    Address? editingAddress,
    AddressLabel? label,
    String? recipientName,
    String? phone,
    String? fullAddress,
    String? note,
    int? provinceId,
    int? districtId,
    String? wardCode,
    int? serviceId,
    List<GhnProvince>? provinces,
    List<GhnDistrict>? districts,
    List<GhnWard>? wards,
    List<GhnServiceOption>? services,
    bool? loadingProvinces,
    bool? loadingDistricts,
    bool? loadingWards,
    bool? loadingServices,
    bool? isSubmitting,
    String? errorMessage,
    bool clearProvince = false,
    bool clearDistrict = false,
    bool clearWard = false,
    bool clearService = false,
  }) {
    return AddressFormState(
      editingAddress: editingAddress ?? this.editingAddress,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      fullAddress: fullAddress ?? this.fullAddress,
      note: note ?? this.note,
      provinceId: clearProvince ? null : (provinceId ?? this.provinceId),
      districtId: clearDistrict ? null : (districtId ?? this.districtId),
      wardCode: clearWard ? null : (wardCode ?? this.wardCode),
      serviceId: clearService ? null : (serviceId ?? this.serviceId),
      provinces: provinces ?? this.provinces,
      districts: districts ?? this.districts,
      wards: wards ?? this.wards,
      services: services ?? this.services,
      loadingProvinces: loadingProvinces ?? this.loadingProvinces,
      loadingDistricts: loadingDistricts ?? this.loadingDistricts,
      loadingWards: loadingWards ?? this.loadingWards,
      loadingServices: loadingServices ?? this.loadingServices,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  factory AddressFormState.fromAddress(Address? address) {
    if (address == null) return const AddressFormState();
    return AddressFormState(
      editingAddress: address,
      label: address.label,
      recipientName: address.recipientName,
      phone: address.phone,
      fullAddress: address.fullAddress,
      note: address.note ?? '',
      provinceId: address.provinceId,
      districtId: address.districtId,
      wardCode: address.wardCode,
      serviceId: address.serviceId,
    );
  }
}
