import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, mobile, email, role];
}
