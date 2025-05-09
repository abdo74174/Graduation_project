import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:easy_localization/easy_localization.dart';

class CustomizeSearchBar extends StatefulWidget {
  final List<ProductModel> products;
  final Function(String) onChanged;

  const CustomizeSearchBar({
    super.key,
    required this.products,
    required this.onChanged,
  });

  @override
  State<CustomizeSearchBar> createState() => _CustomizeSearchBarState();
}

class _CustomizeSearchBarState extends State<CustomizeSearchBar> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _controller = TextEditingController();
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    print('Attempting to start speech recognition');
    if (!_isListening) {
      // Request microphone permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
        return;
      }

      // Check if speech recognition is available
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        },
        onError: (errorNotification) {
          print(
              'Speech error: ${errorNotification.errorMsg}, Code: ${errorNotification.errorMsg}');
          setState(() => _isListening = false);
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Speech recognition error: ${errorNotification.errorMsg}'),
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );

      if (available) {
        print('Speech recognition initialized successfully');
        setState(() => _isListening = true);
        _showListeningModal();
        _speech.listen(
          onResult: (result) {
            print('Recognized words: ${result.recognizedWords}');
            setState(() {
              _lastWords = result.recognizedWords;
              _controller.text = _lastWords;
            });
            widget.onChanged(_lastWords);
          },
          localeId: context.locale.languageCode,
        );

        // Auto stop after 10 seconds
        Future.delayed(const Duration(seconds: 10), () {
          if (_isListening) {
            print('Auto-stopping speech recognition');
            _stopListening();
          }
        });
      } else {
        print('Speech recognition not available');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      print('Stopping speech recognition');
      _stopListening();
    }
  }

  void _stopListening() {
    print('Stopping speech recognition');
    _speech.stop();
    setState(() => _isListening = false);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showListeningModal() {
    print('Showing listening modal');
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic,
                      color: _isListening ? Colors.red : Colors.grey,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isListening ? "Listening...".tr() : "Stopped".tr(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        print('Stop button pressed in modal');
                        _stopListening();
                        setModalState(() {});
                      },
                      icon: const Icon(Icons.stop),
                      label: Text("Stop".tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (_isListening) {
        print('Modal dismissed, stopping speech recognition');
        _stopListening();
      }
    });
  }

  @override
  void dispose() {
    print('Disposing CustomizeSearchBar');
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: "Search...".tr(),
          hintStyle: TextStyle(color: Color(pkColor.value)),
          prefixIcon: IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening
                  ? Colors.red
                  : (isDark ? Colors.white : Color(pkColor.value)),
            ),
            onPressed: () {
              print('Microphone button pressed');
              _listen();
            },
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    print('Clear button pressed');
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(pkColor.value)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(pkColor.value)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(pkColor.value)),
          ),
        ),
      ),
    );
  }
}
