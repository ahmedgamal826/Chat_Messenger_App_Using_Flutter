import 'package:chat_messenger_app/pages/chat_page.dart';
import 'package:chat_messenger_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_service.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _controller = ScrollController();

  Map<String, dynamic>? userMap;

  void signOut() {
    // get auth service

    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  bool isLeading = false;

  final TextEditingController _search = TextEditingController();

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLeading = true;
    });

    await _firestore
        .collection('users')
        .where("name", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLeading = false;
      });

      print(userMap);
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }),
        title: Text(
          "Search",
          style: TextStyle(fontSize: 30),
        ),
        /*actions: [
          // sign out button
          IconButton(onPressed: signOut, icon: Icon(Icons.logout))
        ],*/
      ),
      body: Column(
        children: [
          Container(
              child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15, top: 70),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                  hintText: "Name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          )),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
              onPressed: onSearch,
              child: Text(
                "Search",
                style: TextStyle(fontSize: 35),
              )),
          SizedBox(
            height: 50,
          ),
          _buildUserList(),
        ],
      ),
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
            shrinkWrap: true,
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
    // _auth.currentUser!.email
    if (_search.text == data['name']) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
                color: Colors.white,
                child: userMap != null
                    ? ListTile(
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
                              style:
                                  TextStyle(fontSize: 25, color: Colors.black),
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
                      )
                    : Container()),
          ],
        ),
      );
    } else {
      // return empty container
      return Container();
    }
  }
}
