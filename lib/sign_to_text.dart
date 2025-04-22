import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'sign_to_text_logic.dart';
import 'package:permission_handler/permission_handler.dart';

class SignToText extends StatefulWidget {
  const SignToText({Key? key}) : super(key: key);

  @override
  State<SignToText> createState() => _SignToTextState();
}

class _SignToTextState extends State<SignToText> {
  late CameraController _cameraController;
  Interpreter? _palmInterpreter;
  Interpreter? _landmarkInterpreter;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  List<Offset> _landmarks = [];

  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    await requestPermissions();
    await _loadModels();
    await _initializeCamera();
  }

  Future<void> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      debugPrint('❌ Camera permission not granted');
      return;
    }
  }

  Future<void> _loadModels() async {
    try {
      _palmInterpreter =
          await Interpreter.fromAsset('assets/palm_detection.tflite');
      _landmarkInterpreter =
          await Interpreter.fromAsset('assets/hand_landmark_full.tflite');
      debugPrint('✅ Models loaded successfully');
    } catch (e) {
      debugPrint('❌ Failed to load models: $e');
    }
  }

  Future<void> _initializeCamera() async {
    if (_isCameraInitialized ||
        _palmInterpreter == null ||
        _landmarkInterpreter == null) return;

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController.initialize();
      _isCameraInitialized = true;

      await _cameraController.startImageStream((CameraImage image) async {
        if (!_isDetecting && mounted) {
          _isDetecting = true;
          try {
            await _runInference(image);
          } catch (e) {
            debugPrint('❌ Error during inference: $e');
          }
          _isDetecting = false;
        }
      });

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
    }
  }

  Future<void> _runInference(CameraImage image) async {
    final rgbImage = _convertYUV420toImageColor(image);
    if (rgbImage == null) return;

    final resizedPalmInput = img.copyResize(rgbImage, width: 128, height: 128);
    final palmInput = List.generate(
      1,
      (_) => List.generate(
        128,
        (y) => List.generate(128, (x) {
          final pixel = resizedPalmInput.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        }),
      ),
    );

    final palmOutput = List.filled(1 * 18, 0.0).reshape([1, 18]);
    _palmInterpreter!.run(palmInput, palmOutput);

    // Simulating that palm is found at center — ideally you'd parse bounding box from output
    final handX = 0.5;
    final handY = 0.5;

    // Crop hand region from original image based on palm detection (dummy for now)
    final croppedImage = img.copyResize(rgbImage, width: 224, height: 224);

    final handInput = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = croppedImage.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        }),
      ),
    );

    final output = List.filled(1 * 63, 0.0).reshape([1, 63]);
    _landmarkInterpreter!.run(handInput, output);

    final List<Offset> points = [];
    for (int i = 0; i < 21; i++) {
      final x = output[0][i * 3].clamp(0.0, 1.0);
      final y = output[0][i * 3 + 1].clamp(0.0, 1.0);
      points.add(Offset(
        x * MediaQuery.of(context).size.width,
        y * MediaQuery.of(context).size.height,
      ));
    }

    if (mounted) {
      setState(() {
        _landmarks = points;
      });
    }
  }

  img.Image? _convertYUV420toImageColor(CameraImage image) {
    try {
      final width = image.width;
      final height = image.height;
      final uvRowStride = image.planes[1].bytesPerRow;
      final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      final imgBuffer = img.Image(width, height);

      for (int y = 0; y < height; y++) {
        final uvRow = y ~/ 2;
        for (int x = 0; x < width; x++) {
          final uvCol = x ~/ 2;
          final uvIndex = uvRow * uvRowStride + uvCol * uvPixelStride;

          final ypIndex = y * image.planes[0].bytesPerRow + x;
          if (ypIndex >= image.planes[0].bytes.length ||
              uvIndex >= image.planes[1].bytes.length ||
              uvIndex >= image.planes[2].bytes.length) {
            continue;
          }

          final yVal = image.planes[0].bytes[ypIndex];
          final uVal = image.planes[1].bytes[uvIndex];
          final vVal = image.planes[2].bytes[uvIndex];

          final r = (yVal + 1.370705 * (vVal - 128)).round().clamp(0, 255);
          final g = (yVal - 0.337633 * (uVal - 128) - 0.698001 * (vVal - 128))
              .round()
              .clamp(0, 255);
          final b = (yVal + 1.732446 * (uVal - 128)).round().clamp(0, 255);

          imgBuffer.setPixel(x, y, img.getColor(r, g, b));
        }
      }

      return imgBuffer;
    } catch (e) {
      debugPrint('❌ Error converting YUV to RGB: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _palmInterpreter?.close();
    _landmarkInterpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (!_isCameraInitialized || !_cameraController.value.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_cameraController),
                CustomPaint(
                  painter: SignToTextLogic(_landmarks),
                  child: Container(),
                ),
              ],
            ),
    );
  }
}
