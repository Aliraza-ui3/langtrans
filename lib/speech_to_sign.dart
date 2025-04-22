import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToSignPage extends StatefulWidget {
  @override
  _SpeechToSignPageState createState() => _SpeechToSignPageState();
}

class _SpeechToSignPageState extends State<SpeechToSignPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "";
  List<String> _displayList = [];
  int _currentIndex = 0;
  Timer? _timer;

  final double displayTime = 1.0; // seconds per letter

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('🟡 Status: $status'),
      onError: (error) => print('🔴 Error: $error'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _spokenText = "";
        _displayList.clear();
        _currentIndex = 0;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
          });

          if (result.finalResult) {
            _speech.stop();
            _processText(_spokenText);
          }
        },
      );
    }
  }

  void _processText(String text) {
    String cleanedText = text.toUpperCase();
    print("🎙️ You said: $cleanedText");

    setState(() {
      _displayList = cleanedText.split('');
      _currentIndex = 0;
    });

    _timer = Timer.periodic(
      Duration(milliseconds: (displayTime * 1000).toInt()),
      (timer) {
        if (_currentIndex >= _displayList.length - 1) {
          timer.cancel();
          setState(() {
            _isListening = false; // ✅ Allow new input
          });
        } else {
          setState(() {
            _currentIndex++;
          });
        }
      },
    );
  }

  Widget _getImageWidget(String char) {
    if (char == " ") {
      return Center(
        child: Text(
          "SPACE",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    final path = 'assets/hand_sign/$char.jpg';
    print("🔍 Loading: $path");

    return Container(
      height: 256,
      width: 256,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Text(
          'No image for "$char"',
          style: TextStyle(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentChar =
        _displayList.isNotEmpty ? _displayList[_currentIndex] : "";

    return Scaffold(
      appBar: AppBar(
        title: Text("Speech to Sign"),
        backgroundColor: Color(0xFF657166),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDAEBE3), Color(0xFFFDE8D3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isListening ? null : _startListening,
              icon: Icon(Icons.mic, color: Colors.white),
              label: Text("Start Listening",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF657166),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _spokenText.isEmpty ? "Say something..." : _spokenText,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Expanded(
              child: Center(
                child: _displayList.isEmpty
                    ? Text(
                        "Signs will appear here",
                        style: TextStyle(fontSize: 18),
                      )
                    : _getImageWidget(currentChar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
