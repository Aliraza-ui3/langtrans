import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextToSignPage extends StatefulWidget {
  @override
  _TextToSignPageState createState() => _TextToSignPageState();
}

class _TextToSignPageState extends State<TextToSignPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _displayList = [];
  int _currentIndex = 0;
  Timer? _timer;
  bool _isPlaying = false;

  final double displayTime = 2.0;

  void startDisplay() {
    String input = _controller.text.trim().toUpperCase();

    setState(() {
      _displayList = input.split('');
      _currentIndex = 0;
      _isPlaying = true;
    });

    _timer = Timer.periodic(
      Duration(milliseconds: (displayTime * 1000).toInt()),
      (timer) {
        if (_currentIndex >= _displayList.length - 1) {
          timer.cancel();
          setState(() {
            _isPlaying = false;
          });
        } else {
          setState(() {
            _currentIndex++;
          });
        }
      },
    );
  }

  Widget getImageForCharacter(String char) {
    if (char == ' ') {
      return Center(
        child: Text(
          "SPACE",
          style: GoogleFonts.poppins(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: Color(0xFF657166),
          ),
        ),
      );
    }

    final path = 'assets/hand_sign/$char.jpg';
    print("Trying to load image: $path");

    return Container(
      height: 260,
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFCFD6C4).withOpacity(0.5),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              'Image not found for "$char"',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentChar =
        _displayList.isNotEmpty ? _displayList[_currentIndex] : '';

    return Scaffold(
      backgroundColor: Color(0xFFFDE8D3),
      appBar: AppBar(
        backgroundColor: Color(0xFF657166),
        elevation: 4,
        centerTitle: true,
        title: Text(
          'Text to Sign Language',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF99CDD8), Color(0xFFF3C3B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 30),
            TextField(
              controller: _controller,
              enabled: !_isPlaying,
              style: GoogleFonts.poppins(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Enter text to convert",
                hintStyle: GoogleFonts.poppins(color: Colors.grey[700]),
                filled: true,
                fillColor: Color(0xFFFDE8D3),
                prefixIcon: Icon(Icons.edit, color: Color(0xFF657166)),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isPlaying ? null : startDisplay,
              icon: Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: Text(
                "Convert to Sign",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF657166),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: Center(
                child: _displayList.isEmpty
                    ? Text(
                        "Your sign output will appear here",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Color(0xFF657166),
                        ),
                      )
                    : getImageForCharacter(currentChar),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
