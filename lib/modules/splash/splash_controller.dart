import 'package:get/get.dart';
import '../../index.dart';

class SplashController extends GetxController {
  @override
  void onReady() async {
    super.onReady();

    await Future.delayed(const Duration(milliseconds: 2000));
    Get.toNamed(Routes.HOME);
    // var storage = Get.find<GetStorage>();
    // try {
    //   if (storage.read('token') != null) {
    //     Get.toNamed(Routes.HOME);
    //   } else {
    //     Get.toNamed(Routes.AUTH);
    //   }
    // } catch (e) {
    //   Get.toNamed(Routes.AUTH);
    // }
  }
}
