import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/ChatListModel.dart';
import 'package:graduation_project/screens/chat/chat_page.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  String? email;

  @override
  void initState() {
    super.initState();
    _initializeEmail();
  }

  void _initializeEmail() async {
    email = await UserServicee().getEmail();
    setState(() {});
  }

  String formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  void _startNewChat() async {
    final userEmail = await UserServicee().getEmail();
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to start a chat'.tr())),
      );
      return;
    }

    const contactEmail = 'abdulrhmanosama744@gmail.com';
    if (contactEmail == userEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot chat with yourself'.tr())),
      );
      return;
    }

    try {
      const contactName = 'Support';
      final chatId = '${userEmail}_$contactEmail';
      await chats.doc(chatId).set({
        'contactName': contactName,
        'lastMessage': '',
        'lastMessageTime': DateTime.now(),
        'unreadCount': 0,
        'contactId': contactEmail,
        'isPinned': false,
        'participants': [userEmail, contactEmail],
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatId: chatId,
            contactId: contactEmail,
            contactName: contactName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting chat: $e'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (email == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Chats".tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _startNewChat,
            icon: const Icon(Icons.support_agent, color: Colors.white),
            tooltip: 'Chat with Support'.tr(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search chats...".tr(),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chats
                  .where('participants', arrayContains: email)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child:
                          Text("Error fetching chats: ${snapshot.error}".tr()));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No chats available.".tr()));
                }

                final chatList = snapshot.data!.docs
                    .map((doc) => ChatListModel.fromSnapshot(doc))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final chat = chatList[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue,
                          child: Text(
                            chat.contactName.isNotEmpty
                                ? chat.contactName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          chat.contactName.isNotEmpty
                              ? chat.contactName
                              : "Unknown Contact".tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          chat.lastMessage.isNotEmpty
                              ? chat.lastMessage
                              : "No messages yet".tr(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatTimestamp(chat.lastMessageTime),
                              style: TextStyle(
                                color: chat.unreadCount > 0
                                    ? Colors.blue
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            if (chat.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  chat.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          if (chat.contactId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  chatId: chat.chatId,
                                  contactId: chat.contactId,
                                  contactName: chat.contactName,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Invalid contact ID".tr()),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: Colors.blue,
        tooltip: 'Chat with Support'.tr(),
        child: const Icon(Icons.support_agent),
      ),
    );
  }
}
