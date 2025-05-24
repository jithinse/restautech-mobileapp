class UserModel {
  final int id;
  final int? vendorId;
  final int? restaurantId;
  final String name;
  final String email;
  final String countryCode;
  final String phone;
  final String imagePath;
  final String role;  // Role field

  UserModel({
    required this.id,
    this.vendorId,
    this.restaurantId,
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phone,
    required this.imagePath,
    required this.role,  // Added role parameter
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      vendorId: json['vendor_id'],
      restaurantId: json['restaurant_id'],
      name: json['name'],
      email: json['email'],
      countryCode: json['country_code'],
      phone: json['phone'],
      imagePath: json['image_path'],
      role: json['role'] ?? 'Vendor',  // Default to 'Vendor' if not specified
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'restaurant_id': restaurantId,
      'name': name,
      'email': email,
      'country_code': countryCode,
      'phone': phone,
      'image_path': imagePath,
      'role': role,
    };
  }
}