class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String bio;
  final String? avatarUrl;
  final List<Address> addresses;
  final List<String> favorites;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.bio,
    this.avatarUrl,
    required this.addresses,
    required this.favorites,
  });
}

class Address {
  final String id;
  final String type; // home, work, other
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.type,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.isDefault,
  });
} 