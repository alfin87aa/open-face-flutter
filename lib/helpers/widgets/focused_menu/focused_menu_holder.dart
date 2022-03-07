import 'package:flutter/material.dart';
import 'focused_menu_details.dart';

/// Reference: https://retroportalstudio.medium.com/focused-pop-up-menu-in-flutter-15766d0ab414
class FocusedMenuHolder extends StatefulWidget {
  final Widget child, menuContent;

  // ignore: use_key_in_widget_constructors
  const FocusedMenuHolder({
    Key? key,
    required this.child,
    required this.menuContent,
  });

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOffset = const Offset(0, 0);
  late Size childSize;

  getOffset() {
    dynamic renderBox = containerKey.currentContext!.findRenderObject();
    Size size = renderBox!.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      childOffset = Offset(offset.dx, offset.dy);
      childSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onLongPress: () async {
        getOffset();
        await Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) {
              animation = Tween(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: FocusedMenuDetails(
                  menuContent: widget.menuContent,
                  child: widget.child,
                  childOffset: childOffset,
                  childSize: childSize,
                ),
              );
            },
            fullscreenDialog: true,
            opaque: false,
          ),
        );
      },
      child: widget.child,
    );
  }
}
