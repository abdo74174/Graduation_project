import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListModel {
  final String chatId;
  final String contactId;
  final String contactName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;
  final List<String> participants;

  ChatListModel({
    required this.chatId,
    required this.contactId,
    required this.contactName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isPinned,
    required this.participants,
  });

  factory ChatListModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatListModel(
      chatId: snapshot.id,
      contactId: data['contactId'] ?? '',
      contactName: data['contactName'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: data['unreadCount'] ?? 0,
      isPinned: data['isPinned'] ?? false,
      participants: List<String>.from(data['participants'] ?? []),
    );
  }
}
