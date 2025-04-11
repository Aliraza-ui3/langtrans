import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignToTextPage extends StatefulWidget {
  @override
  _SignToTextPageState createState() => _SignToTextPageState();
}

class _SignToTextPageState extends State<SignToTextPage> {
  CameraController? _controller;
  String detectedText = "Waiting for sign...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      final cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() {});
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign to Text')),
      body: _controller == null || !_controller!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ).animate().fadeIn(duration: 400.ms).moveY(begin: 20),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    detectedText,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .moveY(begin: 20),
              ],
            ),
    );
  }
}
