import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/chat_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/components/chat/chat_pubble.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Firestore reference
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  // User email
  String? email;

  @override
  void initState() {
    super.initState();
    _initializeEmail();
  }

  // Initialize email from shared preferences
  void _initializeEmail() async {
    email = await UserServicee().getEmail();
    // email = "noha@gmail.com";
    setState(() {});
  }

  final _controller = ScrollController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messages.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Map the snapshot data into a list of ChatModels
          final messagesList = snapshot.data!.docs
              .map((doc) => ChatModel.fromSnapshot(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text(
                "MedChat",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: pkColor,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
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
                  ),
                ),
                // Message input field
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
                            'senderId': email, // Store sender's email
                            'receiverId':
                                'receiverEmail', // Store receiver's email (replace this)
                          });

                          messageController.clear();

                          // Scroll to the top after sending the message
                          _controller.animateTo(
                            0,
                            duration: Duration(seconds: 1),
                            curve: Curves.easeIn,
                          );
                        } catch (e) {
                          print('Error sending message: $e');
                        }
                      }
                    },
                    decoration: InputDecoration(
                      suffix: Icon(Icons.send),
                      hintText: "Send Message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Text("No messages available.");
        }
      },
    );
  }
}
