import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

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

  CameraController get cameraController => _cameraController;
  Rx<CustomPaint> customPaint = CustomPaint(
    child: Container(),
  ).obs;

  @override
  void onInit() async {
    super.onInit();
    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == CameraLensDirection.front) {
        _camera = cameras[i];
      }
    }
    _cameraController = CameraController(
      _camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController.initialize().then((value) => {
          _cameraController
              .startImageStream((image) => _processCameraImage(image))
        });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void onClose() async {
    super.onClose();
    await _cameraController.stopImageStream();
    await _cameraController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  Future<XFile> takePicture() async {
    await _cameraController.stopImageStream();
    XFile file = await _cameraController.takePicture();
    return file;
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  Size getImageSize() {
    assert(!_cameraController.value.isInitialized,
        'Camera controller not initialized');
    return Size(
      _cameraController.value.previewSize!.height,
      _cameraController.value.previewSize!.width,
    );
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
