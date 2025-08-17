import 'package:flutter/material.dart';
import 'chat_interface.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[200],
      body: SafeArea(
        child: ChatInterface(),
      ),
    );
  }
}