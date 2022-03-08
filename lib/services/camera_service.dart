import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CameraService extends GetxService {
  List<CameraDescription> _cameras = [];

  List<CameraDescription> get cameras => _cameras;

  Future<CameraService> init() async {
    _cameras = await availableCameras();

    return this;
  }
}
