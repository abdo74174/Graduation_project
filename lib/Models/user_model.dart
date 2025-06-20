import 'dart:typed_data';
import 'package:graduation_project/Models/contact_us_model.dart';
import 'product_model.dart';

// Add UserStatus enum to match backend
enum UserStatus { active, blocked, deactivated }

class UserModel {
  final int id;
  final String? name;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? resetToken;
  final DateTime? resetTokenExpires;
  final String phone;
  final String? medicalSpecialist;
  final String? address;
  final String? profileImage;
  final DateTime createdAt;
  final String kindOfWork;
  late final UserStatus status; // Changed from int to UserStatus
  final bool isAdmin;
  final List<ProductModel> products;
  final List<ContactUsModel> contactUsMessages;

  UserModel({
    required this.id,
    this.name,
    required this.email,
    required this.status,
    this.password,
    this.confirmPassword,
    this.resetToken,
    this.resetTokenExpires,
    required this.phone,
    this.medicalSpecialist,
    this.address,
    this.profileImage,
    required this.createdAt,
    required this.kindOfWork,
    required this.isAdmin,
    required this.products,
    required this.contactUsMessages,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Convert status integer to enum
    final statusValue = json['status'] ?? json['Status'] ?? 0;
    final status = UserStatus.values[statusValue];

    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      status: status,
      password: json['password'],
      confirmPassword: json['confirmPassword'],
      resetToken: json['resetToken'],
      resetTokenExpires: json['resetTokenExpires'] != null
          ? DateTime.parse(json['resetTokenExpires'])
          : null,
      phone: json['phone'] ?? '',
      medicalSpecialist: json['medicalSpecialist'],
      address: json['address'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      kindOfWork: json['kindOfWork'] ?? 'Doctor',
      isAdmin: json['isAdmin'] ?? false,
      products: (json['products'] as List?)
              ?.map((item) => ProductModel.fromJson(item))
              .toList() ??
          [],
      contactUsMessages: (json['contactUsMessages'] as List?)
              ?.map((item) => ContactUsModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status.index, // Convert enum to integer
      'password': password,
      'confirmPassword': confirmPassword,
      'resetToken': resetToken,
      'resetTokenExpires': resetTokenExpires?.toIso8601String(),
      'phone': phone,
      'medicalSpecialist': medicalSpecialist,
      'address': address,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'kindOfWork': kindOfWork,
      'isAdmin': isAdmin,
      'products': products.map((product) => product.toJson()).toList(),
      'contactUsMessages':
          contactUsMessages.map((message) => message.toJson()).toList(),
    };
  }
}
