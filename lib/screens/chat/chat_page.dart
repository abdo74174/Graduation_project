import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/chat_model.dart';
import 'package:graduation_project/components/chat/chat_pubble.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String contactId;
  final String contactName;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.contactId,
    required this.contactName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late CollectionReference messages;
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  String? email;

  @override
  void initState() {
    super.initState();
    messages = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');
    _initializeEmail();
  }

  void _initializeEmail() async {
    email = await UserServicee().getEmail();
    setState(() {});
  }

  final _controller = ScrollController();
  TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_controller.hasClients) {
      _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
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

        title: Text(
          widget.contactName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  messages.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          "Error fetching messages: ${snapshot.error}".tr()));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messagesList = snapshot.hasData
                    ? snapshot.data!.docs
                        .map((doc) => ChatModel.fromSnapshot(
                            doc as QueryDocumentSnapshot<Map<String, dynamic>>))
                        .toList()
                    : <ChatModel>[];

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return messagesList.isEmpty
                    ? Center(child: Text("No messages yet.".tr()))
                    : ListView.builder(
                        reverse: true,
                        controller: _controller,
                        itemCount: messagesList.length,
                        itemBuilder: (context, index) {
                          final message = messagesList[index];
                          bool isSender = message.senderId == email;
                          return isSender
                              ? ChatBubble(message: message, isSender: true)
                              : ChatBubbleForFriend(message: message);
                        },
                      );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: messageController,
              onSubmitted: (data) async {
                if (data.isNotEmpty) {
                  try {
                    await messages.add({
                      'message': data,
                      'createdAt': DateTime.now(),
                      'timestamp': FieldValue.serverTimestamp(),
                      'senderId': email,
                      'receiverId': widget.contactId,
                    });

                    await chats.doc(widget.chatId).set({
                      'contactName': widget.contactName,
                      'lastMessage': data,
                      'lastMessageTime': DateTime.now(),
                      'unreadCount': FieldValue.increment(1),
                      'contactId': widget.contactId,
                      'isPinned': false,
                      'participants': [email, widget.contactId],
                    }, SetOptions(merge: true));

                    messageController.clear();
                    _scrollToBottom();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error sending message: $e".tr())),
                    );
                  }
                }
              },
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.send),
                hintText: "Send Message".tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
