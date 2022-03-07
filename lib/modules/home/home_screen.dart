import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_face/index.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: false,
                  floating: true,
                  snap: true,
                  stretchTriggerOffset: 10.0,
                  forceElevated: innerBoxIsScrolled,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: CupertinoTextField(
                              keyboardType: TextInputType.text,
                              placeholder: 'search'.tr,
                              prefix: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.search,
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Theme.of(context).backgroundColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Obx(
              () => RefreshIndicator(
                child: _buildHomeView(context),
                onRefresh: () => controller.loadUsers(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeView(BuildContext context) {
    return Stack(
      children: [
        _gridView(),
        _floatingBottomNavigation(context),
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
      ],
    );
  }

  Widget _gridView() {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
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
                  imageUrl: data![index].avatar ?? '',
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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
    );
  }

  Widget _floatingBottomNavigation(BuildContext context) {
    return Positioned(
      bottom: Get.height * 0.02,
      left: Get.width * 0.05,
      child: ClipRRect(
        child: Container(
          width: Get.width * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(500),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _menuItem(
                "register".tr,
                Icons.app_registration,
                Routes.FACE_REGISTER,
              ),
              _menuItem(
                "recognition".tr,
                Icons.face_outlined,
                Routes.FACE_REGISTER,
              ),
              _menuItem(
                "comparison".tr,
                Icons.compare,
                Routes.FACE_REGISTER,
              ),
              _menuItem(
                "sync".tr,
                Icons.sync,
                Routes.FACE_REGISTER,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(String menuName, IconData menuIcon, String navigation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: InkWell(
        onTap: () => Get.toNamed(navigation),
        child: Center(
          child: Column(
            children: [
              Icon(
                menuIcon,
              ),
              Text(menuName),
            ],
          ),
        ),
      ),
    );
  }

  List<Datum>? get data {
    return controller.users.value == null ? [] : controller.users.value!.data;
  }
}
