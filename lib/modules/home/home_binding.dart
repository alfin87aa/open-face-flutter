import 'package:get/get.dart';
import 'home.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(apiRepository: Get.find()));
  }
}
