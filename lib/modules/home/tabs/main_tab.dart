import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../index.dart';

class MainTab extends GetView<HomeController> {
  const MainTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => RefreshIndicator(
          child: _buildGridView(),
          onRefresh: () => controller.loadUsers(),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return SafeArea(
      child: Stack(children: [
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: data!.length,
          itemBuilder: (BuildContext context, int index) => GestureDetector(
            onLongPress: () {
              controller.showPreview.value = true;
              controller.image.value = data![index].avatar!;
            },
            onLongPressEnd: (details) {
              controller.showPreview.value = false;
            },
            child: ClipRRect(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: data![index].avatar ??
                          'https://reqres.in/img/faces/1-image.jpg',
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    height: Get.width / 1.5,
                    width: Get.width / 1.5,
                  ),
                  Container(
                    width: Get.width / 1.5,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hexToColor('#9A434343'),
                    ),
                    child: Text(
                      '${data![index].lastName} ${data![index].firstName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (controller.showPreview.value == true) ...[
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: Container(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: SizedBox(
                height: Get.width * 0.8,
                width: Get.width * 0.8,
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: controller.image.value!,
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  List<Datum>? get data {
    return controller.users.value == null ? [] : controller.users.value!.data;
  }
}
