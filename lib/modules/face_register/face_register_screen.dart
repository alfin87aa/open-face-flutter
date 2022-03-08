import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_face/index.dart';

class FaceRegisterScreen extends GetView<FaceRegisterController> {
  const FaceRegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => liveFeedBody());
  }

  Widget liveFeedBody() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        CameraPreview(controller.cameraController),
        controller.customPaint.value
      ],
    );
  }
}
