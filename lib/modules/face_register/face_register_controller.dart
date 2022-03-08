import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:wakelock/wakelock.dart';

import '../../index.dart';

class FaceRegisterController extends GetxController {
  List<CameraDescription> cameras;
  FaceRegisterController({
    required this.cameras,
  });

  bool _isBusy = false;
  final FaceDetector _faceDetector =
      GoogleMlKit.vision.faceDetector(const FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));

  late CameraDescription _camera;
  late CameraController _cameraController;
  bool _isFrontCamera = true;

  CameraController get cameraController => _cameraController;
  Rx<CustomPaint> customPaint = CustomPaint(
    child: Container(),
  ).obs;
  RxBool isCameraReady = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _camera = cameras[1];
    await _startCamera();
    await Wakelock.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void onClose() async {
    super.onClose();
    await _stopCamera();
    await Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  Future<XFile> takePicture() async {
    await _cameraController.stopImageStream();
    XFile file = await _cameraController.takePicture();

    return file;
  }

  Future switchLiveCamera() async {
    if (_isFrontCamera) {
      _camera = cameras[0];
    } else {
      _camera = cameras[1];
    }
    _isFrontCamera = !_isFrontCamera;
    await _stopCamera();
    await _startCamera();
  }

  Future _startCamera() async {
    _cameraController = CameraController(
      _camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController.initialize().then((_) => {
          _cameraController
              .startImageStream((image) => _processCameraImage(image))
        });
    isCameraReady.value = true;
  }

  Future _stopCamera() async {
    isCameraReady.value = false;
    await _cameraController.stopImageStream();
    await _cameraController.dispose();
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation =
        InputImageRotationMethods.fromRawValue(_camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;
    final faces = await _faceDetector.processImage(inputImage);
    if (kDebugMode) {
      print('Found ${faces.length} faces');
    }
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint.value = CustomPaint(painter: painter);
    }
    _isBusy = false;
  }
}
