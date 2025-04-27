import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String message;
  final String senderId;
  final String receiverId;
  final Timestamp createdAt;

  ChatModel({
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
  });

  factory ChatModel.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    return ChatModel(
      message: data['message'] as String,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      createdAt: data['createdAt'] as Timestamp,
    );
  }
}
