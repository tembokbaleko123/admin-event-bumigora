import 'package:aplikasi_kampus/core/constants/app_strings.dart';

class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? AppStrings.roleMhs,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isMahasiswa => role == AppStrings.roleMhs;
  bool get isDosen => role == AppStrings.roleDosen;
  bool get isAdmin => role == AppStrings.roleAdmin;
}
