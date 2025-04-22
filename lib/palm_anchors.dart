class Anchor {
  final double xCenter;
  final double yCenter;
  final double width;
  final double height;

  Anchor(this.xCenter, this.yCenter, this.width, this.height);
}

List<Anchor> generateAnchors({
  int inputWidth = 192,
  int inputHeight = 192,
}) {
  final List<int> strides = [8, 16, 16, 16]; // Used by palm detector
  final List<int> anchorCounts = [2, 6, 6, 6];

  final List<Anchor> anchors = [];

  for (int i = 0; i < strides.length; i++) {
    final stride = strides[i];
    final anchorCount = anchorCounts[i];

    final featureMapHeight = (inputHeight / stride).ceil();
    final featureMapWidth = (inputWidth / stride).ceil();

    for (int y = 0; y < featureMapHeight; y++) {
      for (int x = 0; x < featureMapWidth; x++) {
        final xCenter = (x + 0.5) * stride / inputWidth;
        final yCenter = (y + 0.5) * stride / inputHeight;

        for (int a = 0; a < anchorCount; a++) {
          anchors.add(Anchor(
              xCenter, yCenter, 1.0, 1.0)); // width/height = 1.0 (normalized)
        }
      }
    }
  }

  return anchors;
}
