import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TextToSignPage extends StatefulWidget {
  @override
  _TextToSignPageState createState() => _TextToSignPageState();
}

class _TextToSignPageState extends State<TextToSignPage> {
  String inputText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text to Sign')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AnimatedContainer(
              duration: 500.ms,
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  inputText.isEmpty ? "Animation will appear here" : inputText,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).moveY(begin: 30),
            const SizedBox(height: 20),
            TextField(
              onChanged: (val) {
                setState(() {
                  inputText = val;
                });
                // Later: show animated sign based on inputText
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter text",
                hintText: "e.g. Hello",
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .moveY(begin: 20),
          ],
        ),
      ),
    );
  }
}
