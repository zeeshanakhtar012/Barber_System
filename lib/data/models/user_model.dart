class UserModel {
  final String id;
  final String? shopId;
  final String role; // 'super_admin', 'barber_admin', 'customer'
  final String name;
  final String email;
  final String phone;
  final String password;

  UserModel({
    required this.id,
    this.shopId,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      shopId: json['shopId'],
      role: json['role'] ?? 'customer',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }
}
