import 'palm_anchors.dart';
import 'dart:math';

class PalmBox {
  final double xMin;
  final double yMin;
  final double width;
  final double height;
  final double score;

  PalmBox(this.xMin, this.yMin, this.width, this.height, this.score);
}

PalmBox? decodePalmBox(
    List<double> rawOutput, Anchor anchor, double scoreThreshold) {
  final score = sigmoid(rawOutput[17]);

  if (score < scoreThreshold) return null;

  final dx = rawOutput[0];
  final dy = rawOutput[1];
  final w = rawOutput[2];
  final h = rawOutput[3];

  final cx = anchor.xCenter + dx * 0.1;
  final cy = anchor.yCenter + dy * 0.1;
  final decodedW = w * 0.2;
  final decodedH = h * 0.2;

  final xMin = (cx - decodedW / 2).clamp(0.0, 1.0);
  final yMin = (cy - decodedH / 2).clamp(0.0, 1.0);

  return PalmBox(xMin, yMin, decodedW, decodedH, score);
}

double sigmoid(double x) => 1.0 / (1.0 + exp(-x));
