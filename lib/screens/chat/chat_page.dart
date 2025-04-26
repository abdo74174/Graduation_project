import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/chat_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/components/chat/chat_pubble.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});
  CollectionReference messages =
      FirebaseFirestore.instance.collection(Kpmessages);

  String email = "ab@gmail.com";
  String email2 = "a@gmail.com";
  final _controller = ScrollController();
  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: messages.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // ignore: non_constant_identifier_names
            List<ChatModel> MessagesList = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              MessagesList.add(ChatModel.fromJson(snapshot.data!.docs[i]));
            }
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
                        itemCount: MessagesList.length,
                        itemBuilder: (context, index) {
                          return MessagesList[index].id == email
                              ? ChatBubble(
                                  message: MessagesList[index],
                                )
                              : ChatBubbleForFriend(
                                  message: MessagesList[index],
                                );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: messageController,
                      onSubmitted: (data) async {
                        try {
                          print("______________________starting");
                          await messages.add({
                            'message': data,
                            'createdAt': DateTime.now(),
                            'timestamp': FieldValue.serverTimestamp(),
                            'id': email // optional but useful
                          });

                          messageController.clear();

                          _controller.animateTo(
                            0,
                            duration: Duration(seconds: 1),
                            curve: Curves.easeIn,
                          );
                          print('Message sent: $data');
                        } catch (e) {
                          print("------------------------------------------");
                          print(e);
                        }
                      },
                      decoration: InputDecoration(
                        suffix: Icon(Icons.send),
                        hintText: "Send Message",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Text("Loading");
          }
        });
  }
}
