import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:wakelock/wakelock.dart';
import 'package:image/image.dart' as img;

import '../../index.dart';

class FaceRegisterController extends GetxController {
  List<CameraDescription> cameras;
  Interpreter interpreter;

  FaceRegisterController({
    required this.cameras,
    required this.interpreter,
  });

  final FaceDetector _faceDetector =
      GoogleMlKit.vision.faceDetector(const FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));

  late CameraDescription _camera;
  late CameraController _cameraController;
  late List<Face> _faces;

  bool _isFrontCamera = true;
  bool _isBusy = false;

  List<Face> get faces => _faces;
  CameraController get cameraController => _cameraController;
  Rx<CustomPaint> customPaint = CustomPaint(
    child: Container(),
  ).obs;
  RxBool isCameraReady = false.obs;
  Rx<XFile> imageFile = XFile('').obs;
  RxBool isCaptured = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _camera = cameras[1];
    await startCamera();
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

  Future takePicture() async {
    if (_faces.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'no face detection'.tr,
        backgroundColor: Colors.white,
        margin: const EdgeInsets.only(top: 50.0),
        duration: const Duration(seconds: 1),
      );
    } else if (_faces.length > 1) {
      Get.snackbar(
        'warning'.tr,
        'multiple face detection'.tr,
        backgroundColor: Colors.white,
        margin: const EdgeInsets.only(top: 50.0),
        duration: const Duration(seconds: 1),
      );
    } else {
      isCameraReady.value = false;
      await _cameraController.stopImageStream();
      imageFile.value = await _cameraController.takePicture();
      List faceDescriptor = await _convertToFaceDescriptor();
      if (kDebugMode) {
        print(faceDescriptor);
      }
      isCaptured.value = true;
    }
  }

  Future<List> _convertToFaceDescriptor() async {
    final bytes = await imageFile.value.readAsBytes();
    final img.Image? image = img.decodeImage(bytes);
    List input = _imageToByteListFloat32(image!, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    return List.from(output);
  }

  Float32List _imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  Future switchLiveCamera() async {
    if (_isFrontCamera) {
      _camera = cameras[0];
    } else {
      _camera = cameras[1];
    }
    _isFrontCamera = !_isFrontCamera;
    await _stopCamera();
    await startCamera();
  }

  Future startCamera() async {
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
    _faces = await _faceDetector.processImage(inputImage);

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          _faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint.value = CustomPaint(painter: painter);
    }
    _isBusy = false;
  }
}
