enum AddressLabel { home, office, gift }

extension AddressLabelX on AddressLabel {
  String get displayName {
    switch (this) {
      case AddressLabel.home:
        return 'Nhà riêng';
      case AddressLabel.office:
        return 'Văn phòng';
      case AddressLabel.gift:
        return 'Quà tặng';
    }
  }

  static AddressLabel fromRaw(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.contains('van')) return AddressLabel.office;
    if (value.contains('qua')) return AddressLabel.gift;
    return AddressLabel.home;
  }
}

class Address {
  final String id;
  final AddressLabel label;
  final String recipientName;
  final String phone;
  final String fullAddress;
  final int provinceId;
  final int districtId;
  final String wardCode;
  final int serviceId;
  final bool isDefault;
  final String? note;

  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    required this.provinceId,
    required this.districtId,
    required this.wardCode,
    required this.serviceId,
    required this.isDefault,
    this.note,
  });

  Address copyWith({
    String? id,
    AddressLabel? label,
    String? recipientName,
    String? phone,
    String? fullAddress,
    int? provinceId,
    int? districtId,
    String? wardCode,
    int? serviceId,
    bool? isDefault,
    String? note,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      fullAddress: fullAddress ?? this.fullAddress,
      provinceId: provinceId ?? this.provinceId,
      districtId: districtId ?? this.districtId,
      wardCode: wardCode ?? this.wardCode,
      serviceId: serviceId ?? this.serviceId,
      isDefault: isDefault ?? this.isDefault,
      note: note ?? this.note,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: (json['id'] ?? '').toString(),
      label: AddressLabelX.fromRaw(
        (json['label'] ?? json['type'] ?? json['tag'])?.toString(),
      ),
      recipientName: (json['recipientName'] ?? json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      fullAddress: (json['fullAddress'] ?? json['address'] ?? '').toString(),
      provinceId: _readInt(json['provinceId'] ?? json['shippingProvinceId']),
      districtId: _readInt(json['districtId'] ?? json['shippingDistrictId']),
      wardCode: (json['wardCode'] ?? json['shippingWardCode'] ?? '').toString(),
      serviceId: _readInt(json['serviceId'] ?? json['shippingServiceId']),
      isDefault: (json['isDefault'] ?? false) == true,
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'label': label.displayName,
      'recipientName': recipientName,
      'phone': phone,
      'fullAddress': fullAddress,
      'provinceId': provinceId,
      'districtId': districtId,
      'wardCode': wardCode,
      'serviceId': serviceId,
      'isDefault': isDefault,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
