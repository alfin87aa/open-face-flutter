import 'package:get/get.dart';
import 'package:open_face/index.dart';

class FaceRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FaceRegisterController>(
        FaceRegisterController(cameraService: Get.find()));
  }
}
