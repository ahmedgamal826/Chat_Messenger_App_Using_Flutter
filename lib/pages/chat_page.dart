import 'dart:io';

import 'package:chat_messenger_app/components/chat_bubble.dart';
import 'package:chat_messenger_app/components/my_text_field.dart';
import 'package:chat_messenger_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverUserName;
  final String receiverUserStatus;
  //final Timestamp date;

  // final Map<String, dynamic>? userMap;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverUserName,
    required this.receiverUserStatus,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((XFile) {
      if (XFile != null) {
        imageFile = File(XFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!);

    String imageUrl = await uploadTask.ref.getDownloadURL();

    print(imageUrl);
  }

  final _controller = ScrollController();

  void sendMessage() async {
    // only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);

      // clear the text controller after sending the message

      _messageController.clear();
      _controller.animateTo(
        0,
        duration: Duration(milliseconds: 40),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.account_circle_rounded,
                    size: 40,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Text(
                          widget.receiverUserName,
                          style: TextStyle(fontSize: 25),
                        ),
                        Text(
                          widget.receiverUserStatus,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
      body: Column(
        children: [
          // messages
          Expanded(
            child: _buildMessageList(),
          ),

          // user input

          _buildMessageInput(),
        ],
      ),
    );
  }

  // build message List
  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          return ListView(
            reverse: true,
            controller: _controller,

            //messageController.clear();

            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  TextEditingController get messageController => _messageController;

  // build message item

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align the messages to right if the sender is the current user , otherwise to the left

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            (data['senderId'] == _firebaseAuth.currentUser!.uid)
                ? ChatBubble2(
                    message: data['message'],
                    color: Colors.blue,
                  )
                : ChatBubble(
                    message: data['message'],
                    color: Colors.black,
                  ),
          ],
        ),
      ),
    );
  }

  // build message input

  Widget _buildMessageInput() {
    return Row(
      children: [
        // textfield
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextField(
              controller: _messageController,
              obscureText: false,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  fillColor: Colors.grey[100],
                  filled: true,
                  hintText: 'Send Message',
                  hintStyle: const TextStyle(color: Colors.grey)),
            ),
          ),
        ),

        // send button

        IconButton(
            icon: const Icon(
              Icons.send,
              size: 33,
              color: Colors.blue,
            ),
            onPressed: sendMessage)
      ],
    );
  }
}
