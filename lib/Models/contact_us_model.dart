import 'package:graduation_project/Models/user_model.dart';

class ContactUs {
  final int messageId;
  final String message;
  final int userId;
  final User? user;

  ContactUs({
    required this.messageId,
    required this.message,
    required this.userId,
    this.user,
  });

  factory ContactUs.fromJson(Map<String, dynamic> json) {
    return ContactUs(
      messageId: json['messageId'],
      message: json['message'],
      userId: json['userId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'message': message,
      'userId': userId,
      'user': user?.toJson(),
    };
  }
}
