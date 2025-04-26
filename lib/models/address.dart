class Address {
  final String id;
  final String userId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String? apartment;
  final bool isDefault;
  final String? label;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.apartment,
    this.isDefault = false,
    this.label,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      apartment: map['apartment'],
      isDefault: map['isDefault'] ?? false,
      label: map['label'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'apartment': apartment,
      'isDefault': isDefault,
      'label': label,
    };
  }

  String get fullAddress {
    final parts = [
      street,
      if (apartment != null) 'Apt $apartment',
      '$city, $state $zipCode',
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }
} 