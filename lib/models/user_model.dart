// // class UserModel {
// //   final int id;
// //   final String name;
// //   final String email;
// //   final String? countryCode;
// //   final String? phone;
// //   final String? imagePath;
// //
// //   UserModel({
// //     required this.id,
// //     required this.name,
// //     required this.email,
// //     this.countryCode,
// //     this.phone,
// //     this.imagePath,
// //   });
// //
// //   factory UserModel.fromJson(Map<String, dynamic> json) {
// //     return UserModel(
// //       id: json['id'],
// //       name: json['name'],
// //       email: json['email'],
// //       countryCode: json['country_code'],
// //       phone: json['phone'],
// //       imagePath: json['imagePath'],
// //     );
// //   }
// // }
//
//
// class UserModel {
//   final int id;
//   final String name;
//   final String email;
//   final String? countryCode;
//   final String? phone;
//   final String? imagePath;
//   final String role; // Add role field
//
//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.countryCode,
//     this.phone,
//     this.imagePath,
//     required this.role, // Make it required
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       countryCode: json['country_code'],
//       phone: json['phone'],
//       imagePath: json['imagePath'] ?? json['image_path'],
//       role: json['role'] ?? 'user', // Default to 'user' if not provided
//     );
//   }
// }



class UserModel {
  final int id;
  final String name;
  final String email;
  final String? countryCode;
  final String? phone;
  final String? imagePath;
  final String role; // Non-nullable with default as 'kitchen'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.countryCode,
    this.phone,
    this.imagePath,
    this.role = 'Kitchen', // Default set to 'kitchen'
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      countryCode: json['country_code'],
      phone: json['phone'],
      imagePath: json['imagePath'] ?? json['image_path'],
      role: json['role'] ?? 'Kitchen', // Default to 'kitchen' if not provided
    );
  }
}