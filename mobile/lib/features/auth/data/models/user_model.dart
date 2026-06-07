class UserModel {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        mobile: json['mobile'] as String,
        email: json['email'] as String?,
        role: json['role'] as String? ?? 'user',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'email': email,
        'role': role,
      };
}
