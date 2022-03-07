import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DenpendencyInjection.init();
  await initServices();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness:
        Get.isPlatformDarkMode ? Brightness.light : Brightness.dark,
  ));

  runApp(const App());
  configLoading();
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: false,
      initialRoute: Routes.SPLASH,
      defaultTransition: Transition.fade,
      getPages: AppPages.routes,
      initialBinding: AppBinding(),
      smartManagement: SmartManagement.keepFactory,
      title: AppConfigs.appName,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      locale: TranslationService.locale,
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      builder: EasyLoading.init(),
    );
  }
}

Future<void> initServices() async {
  await Get.putAsync(() => CameraService().init());
}

ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  errorColor: Colors.red,
  backgroundColor: Colors.grey[850],
  textTheme: const TextTheme(caption: TextStyle(color: Colors.white))
      .apply(bodyColor: Colors.white, displayColor: Colors.white),
  appBarTheme: const AppBarTheme(color: Colors.black),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.white,
    disabledColor: Colors.grey,
  ),
);

ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  errorColor: Colors.red,
  backgroundColor: Colors.white,
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    color: Colors.white,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.black,
    disabledColor: Colors.grey,
  ),
);

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..loadingStyle = EasyLoadingStyle.custom
    // ..indicatorSize = 45.0
    ..radius = 10.0
    // ..progressColor = Colors.yellow
    ..backgroundColor = ColorConstants.lightGray
    ..indicatorColor = hexToColor('#64DEE0')
    ..textColor = hexToColor('#64DEE0')
    // ..maskColor = Colors.red
    ..userInteractions = false
    ..dismissOnTap = false
    ..animationStyle = EasyLoadingAnimationStyle.scale;
}
