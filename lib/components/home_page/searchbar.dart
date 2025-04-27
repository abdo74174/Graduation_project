import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:easy_localization/easy_localization.dart';

class CustomizeSearchBar extends StatefulWidget {
  final List products;
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
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() => _isListening = false);
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // Close the modal if still open
            }
          }
        },
        onError: (errorNotification) {
          print('Speech recognition error: $errorNotification');
          setState(() => _isListening = false);
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);

        _showListeningModal();

        _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              _controller.text = _lastWords;
            });
            widget.onChanged(_lastWords);
          },
        );

        // Auto stop after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (_isListening) {
            _stopListening();
          }
        });
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showListeningModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic, color: Colors.red, size: 80),
                const SizedBox(height: 20),
                Text(
                  "Listening...".tr(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _stopListening,
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
  }

  @override
  void dispose() {
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
          prefixIcon: IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening
                  ? Colors.red
                  : (isDark ? Colors.white : Colors.black),
            ),
            onPressed: _listen,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
