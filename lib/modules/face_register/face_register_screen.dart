import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_face/index.dart';

class FaceRegisterScreen extends GetView<FaceRegisterController> {
  const FaceRegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Obx(() => liveCamera()),
            header(),
            Positioned(bottom: 10.0, child: bottom())
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () => controller.takePicture(),
        child: Container(
          height: 80,
          width: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.circle_outlined,
            size: 80,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget liveCamera() {
    var _camera = controller.cameraController;
    double _aspectRatio = _camera.value.previewSize != null
        ? _camera.value.previewSize!.height / _camera.value.previewSize!.width
        : 1.0;

    return Center(
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            controller.isCameraReady.value
                ? CameraPreview(_camera)
                : Container(),
            controller.customPaint.value
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 50,
              width: 50,
              child: const Center(
                  child: Icon(
                Icons.arrow_back_ios_new,
              )),
            ),
          ),
          const SizedBox(
            width: 90,
          )
        ],
      ),
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.black, Colors.transparent],
        ),
      ),
    );
  }

  Widget bottom() {
    return Container(
      color: Colors.transparent,
      height: Get.height * 0.1,
      width: Get.width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: 30,
              onPressed: () {},
              icon: const Icon(
                Icons.flash_off,
                color: Colors.white,
              ),
            ),
            IconButton(
              iconSize: 30,
              onPressed: () => controller.switchLiveCamera(),
              icon: const Icon(
                Icons.cameraswitch_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
