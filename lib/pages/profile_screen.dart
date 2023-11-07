import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

class Profile_Screen extends StatefulWidget {
  const Profile_Screen({super.key});

  @override
  State<Profile_Screen> createState() => _Profile_ScreenState();
}

class _Profile_ScreenState extends State<Profile_Screen> {
  late Map<String, dynamic> userMap;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Screen"),
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

    // if (_auth.currentUser!.email == data['email']) {
    if (_auth.currentUser!.email == data['email']) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          children: [
            CircleAvatar(
              radius: 100,
              backgroundColor: Colors.black,
              child: Stack(
                children: [
                  CircleAvatar(
                    minRadius: 15,
                    child: Text(
                      data['name'][0],
                      style: TextStyle(fontSize: 150),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 50,
                    left: 110,
                    child: Text(""),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            data['name'],
                            style: TextStyle(fontSize: 25, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            "Email ",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            data['email'],
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                          ),
                        ],
                      )
                    ],
                  ),
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
