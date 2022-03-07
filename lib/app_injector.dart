import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DenpendencyInjection {
  static Future<void> init() async {
    await Get.putAsync(() => GetStorage.init());
  }
}
