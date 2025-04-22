import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sign_to_text_logic.dart';
import 'palm_anchors.dart';
import 'palm_decoder.dart';

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
  late List<Anchor> _anchors;

  @override
  void initState() {
    super.initState();
    _anchors = generateAnchors();
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
          await Interpreter.fromAsset('assets/palm_detection_lite.tflite');
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
        ResolutionPreset.medium,
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
    if (_palmInterpreter == null) {
      debugPrint('🛑 _palmInterpreter is null');
      return;
    }
    if (_landmarkInterpreter == null) {
      debugPrint('🛑 _landmarkInterpreter is null');
      return;
    }

    final rgbImage = _convertYUV420toImageColor(image);
    if (rgbImage == null) {
      debugPrint('🛑 rgbImage conversion failed (null)');
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Palm detection input: 192x192
    final palmInputImage = img.copyResize(rgbImage, width: 192, height: 192);
    final palmInput = List.generate(
      1,
      (_) => List.generate(
        192,
        (y) => List.generate(192, (x) {
          final pixel = palmInputImage.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        }),
      ),
    );

    final palmOutput = List.filled(1 * 2016 * 18, 0.0).reshape([1, 2016, 18]);
    try {
      _palmInterpreter!.run(palmInput, palmOutput);
    } catch (e) {
      debugPrint('❌ Error running palm model: $e');
      return;
    }

    PalmBox? bestBox;
    double bestScore = 0;

    for (int i = 0; i < 2016; i++) {
      final raw = palmOutput[0][i];
      final decoded = decodePalmBox(raw, _anchors[i], 0.75);
      if (decoded != null && decoded.score > bestScore) {
        bestBox = decoded;
        bestScore = decoded.score;
      }
    }

    if (bestBox == null) {
      debugPrint('❌ No hand detected');
      return;
    }

    final cropLeft = (bestBox.xMin * rgbImage.width).toInt();
    final cropTop = (bestBox.yMin * rgbImage.height).toInt();
    final cropWidth = (bestBox.width * rgbImage.width).toInt();
    final cropHeight = (bestBox.height * rgbImage.height).toInt();

    final cl = cropLeft.clamp(0, rgbImage.width - 1);
    final ct = cropTop.clamp(0, rgbImage.height - 1);
    final cw = cropWidth.clamp(1, rgbImage.width - cl);
    final ch = cropHeight.clamp(1, rgbImage.height - ct);

    final handRegion = img.copyCrop(rgbImage, cl, ct, cw, ch);
    final resizedHand = img.copyResize(handRegion, width: 224, height: 224);

    final handInput = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resizedHand.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        }),
      ),
    );

    final output = List.filled(1 * 63, 0.0).reshape([1, 63]);
    try {
      _landmarkInterpreter!.run(handInput, output);
    } catch (e) {
      debugPrint('❌ Error running landmark model: $e');
      return;
    }

    final List<Offset> points = [];
    for (int i = 0; i < 21; i++) {
      final normX = output[0][i * 3];
      final normY = output[0][i * 3 + 1];

      final absX = cl + normX * cw;
      final absY = ct + normY * ch;

      points.add(Offset(
        absX * screenWidth / rgbImage.width,
        absY * screenHeight / rgbImage.height,
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
