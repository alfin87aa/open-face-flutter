import 'package:get/get.dart';
import '../index.dart';
part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.FACE_REGISTER,
      page: () => const FaceRegisterScreen(),
      binding: FaceRegisterBinding(),
    ),
  ];
}
