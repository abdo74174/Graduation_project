import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String message;
  final DateTime createdAt;
  final String senderId;
  final String receiverId;

  ChatModel({
    required this.message,
    required this.createdAt,
    required this.senderId,
    required this.receiverId,
  });

  factory ChatModel.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return ChatModel(
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
    );
  }
}
