import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({Key? key, required this.message, required this.color})
      : super(key: key);

  final String message;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 32, bottom: 32, right: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32)),
        color: color,
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}

class ChatBubble2 extends StatelessWidget {
  const ChatBubble2({Key? key, required this.message, required this.color})
      : super(key: key);

  final String message;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 32, bottom: 32, right: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomLeft: Radius.circular(32)),
        color: color,
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
