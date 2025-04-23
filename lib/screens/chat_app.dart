import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  WebSocketChannel? _channel;
  List<String> messages = [];
  final String? _jwtToken =
      "yJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjYiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiTW9oYW1lZCAzc3JhbiIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2VtYWlsYWRkcmVzcyI6Im1AZ21haWwuY29tIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiVXNlciIsImV4cCI6MTc0NTIwOTQxOSwiaXNzIjoiQVBJIiwiYXVkIjoiTXlQcm9qZWN0In0.T2j7eX-pF1FN1ITg69HWt81xxpAWSkN9thwr2_7QEko"; // Replace with your JWT token

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  // Connect to WebSocket and handle errors
  Future<void> _connectToWebSocket() async {
    try {
      print("Attempting to connect to WebSocket...");
      _channel = WebSocketChannel.connect(
        Uri.parse(
            "wss://10.0.2.2:7273/ws"), // WebSocket URL (secure connection)
      );

      // Listen to the stream
      _channel?.stream.listen(
        (message) {
          setState(() {
            messages.add(message);
            print("Received message: $message");
          });
        },
        onError: (error) {
          // Log any errors from the WebSocket stream
          print("WebSocket error: $error");
          _showErrorDialog("WebSocket error: $error");
        },
        onDone: () {
          print("WebSocket connection closed.");
        },
      );
    } catch (e) {
      print("Error connecting to WebSocket: $e");
      _showErrorDialog("Error connecting to WebSocket: $e");
    }
  }

  // Send a message to the WebSocket server
  void _sendMessage() {
    if (_controller.text.isNotEmpty && _jwtToken != null) {
      final message = _controller.text;
      print("Sending message: $message");

      try {
        _channel?.sink.add(message); // Send message to WebSocket
        _controller.clear();
      } catch (e) {
        print("Error sending message: $e");
        _showErrorDialog("Error sending message: $e");
      }
    } else {
      print("Message or JWT token is empty.");
    }
  }

  // Show an error dialog with the error message
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _channel?.sink.close();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    messages[index],
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.6)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
