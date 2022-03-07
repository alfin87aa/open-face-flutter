import 'package:flutter/material.dart';

import '../../../index.dart';

class InboxTab extends StatelessWidget {
  const InboxTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Inbox'),
      ),
      body: Container(
        color: const Color(0XFFF5F5F5),
        child: ListView(
          children: [
            const SendMsgBox(message: "Hello"),
            const ReceiveMsgBox(message: "Hi, how are you"),
            const SendMsgBox(message: "I am great how are you doing"),
            const ReceiveMsgBox(message: "I am also fine"),
            const SendMsgBox(message: "Can we meet tomorrow?"),
            const ReceiveMsgBox(
                message: "Yes, of course we will meet tomorrow"),
          ],
        ),
      ),
    );
  }
}
