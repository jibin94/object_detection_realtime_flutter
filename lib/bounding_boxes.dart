import 'package:flutter/material.dart';

class BoundingBoxes extends StatelessWidget {
  final List<dynamic> recognitions;
  final double previewH;
  final double previewW;
  final double screenH;
  final double screenW;

  const BoundingBoxes({
    super.key,
    required this.recognitions,
    required this.previewH,
    required this.previewW,
    required this.screenH,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: recognitions.map((rec) {
        var x = rec["rect"]["x"] * screenW;
        var y = rec["rect"]["y"] * screenH;
        double w = rec["rect"]["w"] * screenW;
        double h = rec["rect"]["h"] * screenH;

        return Positioned(
          left: x,
          top: y,
          width: w,
          height: h,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 3,
              ),
            ),
            child: Text(
              "${rec["detectedClass"]} ${(rec["confidenceInClass"] * 100).toStringAsFixed(0)}% Width:${(w).ceil()} Heght: ${h.ceil()}",
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
                background: Paint()..color = Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
