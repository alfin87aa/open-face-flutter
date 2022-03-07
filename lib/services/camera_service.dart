import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService extends GetxService {
  int _cameraIndex = 0;
  List<CameraDescription> _cameras = [];
  late CameraController _cameraController;
  late InputImageRotation _cameraRotation;
  late String _imagePath;

  CameraController get cameraController => _cameraController;
  InputImageRotation get cameraRotation => _cameraRotation;
  String get imagePath => _imagePath;
  CameraDescription get cameraDescription => _cameras[_cameraIndex];

  Future<CameraService> init() async {
    _cameras = await availableCameras();
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == CameraLensDirection.front) {
        _cameraIndex = i;
      }
    }
    return this;
  }

  Future startLive() async {
    final camera = _cameras[_cameraIndex];
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController.initialize();
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

  Future<XFile> takePicture() async {
    await _cameraController.stopImageStream();
    XFile file = await _cameraController.takePicture();
    _imagePath = file.path;
    return file;
  }

  Size getImageSize() {
    assert(!_cameraController.value.isInitialized,
        'Camera controller not initialized');
    return Size(
      _cameraController.value.previewSize!.height,
      _cameraController.value.previewSize!.width,
    );
  }

  Future stopLive() async {
    await _cameraController.stopImageStream();
    await _cameraController.dispose();
  }
}
