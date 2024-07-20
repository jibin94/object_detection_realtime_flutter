import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection_realtime_flutter/bounding_boxes.dart';
import 'package:tflite_v2/tflite_v2.dart';

class RealTimeObjectDetection extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RealTimeObjectDetection({super.key, required this.cameras});

  @override
  RealTimeObjectDetectionState createState() => RealTimeObjectDetectionState();
}

class RealTimeObjectDetectionState extends State<RealTimeObjectDetection> {
  late CameraController _controller;
  bool isModelLoaded = false;
  List<dynamic>? recognitions;
  int imageHeight = 0;
  int imageWidth = 0;

  @override
  void initState() {
    super.initState();
    loadModel();
    initializeCamera(null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: 'assets/ssd_mobilenet.tflite',
      labels: 'assets/ssd_mobilenet.txt',
    );
    setState(() {
      isModelLoaded = res != null;
    });
  }

  void toggleCamera() {
    final lensDirection = _controller.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = widget.cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = widget.cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    initializeCamera(newDescription);
  }

  void initializeCamera(description) async {
    if (description == null) {
      _controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
    } else {
      _controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );
    }

    await _controller.initialize();

    if (!mounted) {
      return;
    }
    _controller.startImageStream((CameraImage image) {
      if (isModelLoaded) {
        runModel(image);
      }
    });
    setState(() {});
  }

  void runModel(CameraImage image) async {
    if (image.planes.isEmpty) return;

    var recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      model: 'SSDMobileNet',
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );

    setState(() {
      this.recognitions = recognitions;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Object Detection',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CameraPreview(_controller),
                ),
                if (recognitions != null)
                  BoundingBoxes(
                    recognitions: recognitions!,
                    previewH: imageHeight.toDouble(),
                    previewW: imageWidth.toDouble(),
                    screenH: MediaQuery.of(context).size.height * 0.8,
                    screenW: MediaQuery.of(context).size.width,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    toggleCamera();
                  },
                  icon: Icon(
                    _controller.description.lensDirection ==
                            CameraLensDirection.back
                        ? Icons.camera_front
                        : Icons.camera_rear,
                    size: 30,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
