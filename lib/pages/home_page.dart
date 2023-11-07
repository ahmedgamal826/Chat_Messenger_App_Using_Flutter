import 'package:chat_messenger_app/pages/profile_screen.dart';
import 'package:chat_messenger_app/pages/search_page.dart';
import 'package:chat_messenger_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../model/chat_user.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("Online");

      // online
    } else {
      setStatus("Offline");
      // offline
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _controller = ScrollController();

  final nameController = TextEditingController();

  late Map<String, dynamic> userMap;

  //void onSearch() async {}

  // sign user out
  void signOut() {
    // get auth service

    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: signOut),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(),
                  ),
                );
              },
              // search icon
              icon: Icon(
                Icons.search,
                size: 30,
              )),
          Padding(
            padding: const EdgeInsets.only(right: 5, left: 3),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile_Screen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.account_circle_rounded,
                  size: 40,
                  color: Colors.white,
                )),
          )
        ],
        title: Text(
          "Chats",
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: _buildUserList(),
    );
  }

  // build a list of users except for the current logged in user

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('leading..');
          }

          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        });
  }

  // build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // display all users except current user

    if (_auth.currentUser!.displayName != data['name']) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      minRadius: 25,
                      child: Text(
                        data['name'][0],
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      data['name'],
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                  ],
                )

                //
                ,
                onTap: () {
                  //_controller.position.maxScrollExtent;
                  // pass the clicked user's ID to the chat page

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverUserEmail: data['email'],
                        receiverUserID: data['uid'],
                        receiverUserName: data['name'],
                        receiverUserStatus: data['status'],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // return empty container
      return Container();
    }
  }
}
