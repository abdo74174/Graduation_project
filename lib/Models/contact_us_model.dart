import 'package:intl/intl.dart';

class ContactUsModel {
  final String problemType;
  final String message;
  final String? email;
  final int? userId;
  final DateTime createdAt;

  ContactUsModel({
    required this.problemType,
    required this.message,
    this.email,
    this.userId,
    required this.createdAt,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      problemType: json['problemType'] ?? '',
      message: json['message'] ?? '',
      email: json['email'],
      userId: json['userId'],
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.utc(1970, 1, 1).toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemType': problemType,
      'message': message,
      'email': email,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
