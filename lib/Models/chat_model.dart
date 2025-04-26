class ChatModel {
  final String message;
  final String id;
  ChatModel({required this.message, required this.id});

  factory ChatModel.fromJson(jsonData) {
    return ChatModel(message: jsonData['message'], id: jsonData['id']);
  }
}
