import 'package:get/get.dart';
import 'package:open_face/index.dart';

class FaceRegisterBinding extends Bindings {
  @override
  void dependencies() {
    CameraService _cameraService = Get.find();
    Get.lazyPut<FaceRegisterController>((() => FaceRegisterController(
          cameras: _cameraService.cameras,
        )));
  }
}
