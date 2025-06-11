import 'package:intl/intl.dart';

class ContactUsModel {
  final int id;
  final String userId;
  final String message;
  final DateTime createdAt;
  final String? email;

  ContactUsModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
    this.email,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      id: json['id'],
      userId: json['userId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      if (email != null) 'email': email,
    };
  }
}
