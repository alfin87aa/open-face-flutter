import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../index.dart';

class MeTab extends GetView<HomeController> {
  const MeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: SizeConfig().screenHeight * .5,
          child: Stack(
            children: [
              Obx(
                () => _buildUserInfo(),
              ),
            ],
          ),
        ),
        _buildListItems(),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Me',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        _buildAvatar(),
        const SizedBox(
          height: 10,
        ),
        Text(
          '${controller.user.value!.email}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 10.0),
            Expanded(
              child: BorderButton(
                text: '100 follower',
                backgroundColor: Colors.white,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: BorderButton(
                text: '100 following',
                backgroundColor: Colors.white,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10.0),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: 110,
            width: 110,
            child: CachedNetworkImage(
              fit: BoxFit.fill,
              imageUrl: controller.user.value!.avatar ??
                  'https://reqres.in/img/faces/1-image.jpg',
              placeholder: (context, url) => const Image(
                image: AssetImage('assets/images/icon_success.png'),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Container(
            width: 110,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hexToColor('#9A434343'),
            ),
            child: Text(
              controller.user.value!.firstName ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItems() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: SizeConfig().screenHeight * .42,
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              IconTitleItem(
                title: 'Cards',
                icon: 'assets/icons/icon_discover.svg',
                onTap: () {
                  Get.toNamed(Routes.HOME + Routes.CARDS);
                },
              ),
              IconTitleItem(
                title: 'Resource',
                icon: 'assets/icons/icon_resource.svg',
                onTap: () {},
              ),
              IconTitleItem(
                title: 'Inbox',
                icon: 'assets/icons/icon_inbox.svg',
                onTap: () {},
              ),
              const SizedBox(
                height: 8,
              ),
              IconTitleItem(
                backgroundColor: ColorConstants.lightGray,
                paddingLeft: 16,
                paddingTop: 16,
                paddingRight: 16,
                padingBottom: 16,
                marginRight: 16,
                marginLeft: 5,
                drawablePadding: 10.0,
                title: 'sign out',
                icon: 'assets/icons/icon_sign_out.svg',
                onTap: () {
                  controller.signout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
