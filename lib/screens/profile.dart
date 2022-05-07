import 'package:fire_uber_driver/screens/auto_update.dart';
import 'package:fire_uber_driver/screens/profile_update.dart';
import 'package:fire_uber_driver/screens/sign_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/users.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _userId;

  Users? user;

  @override
  void initState() {
    //getRestaurants();
    super.initState();

    var currentUser_uid = FirebaseAuth.instance.currentUser!.uid;

    // final ref = FirebaseDatabase.instance.ref();
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser_uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        setState(() {
          user = Users.fromSnapshot(snap.snapshot);

          print("driver_details");
          print(user);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.lightBlue,
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'Account',
        style: TextStyle(
          fontFamily: 'medium',
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage('${user?.photoURL}'
                          //'assets/payment.png',
                          //'${user?.photoURL}',
                          ),
                      radius: 40,

                      // Image.network(
                      //   ),
                    ),
                    Chip(
                      backgroundColor: Colors.lightBlue.shade100,
                      label: Text(
                        '${user?.name}' ' ${user?.lastName}',
                        style: TextStyle(
                            fontFamily: 'medium',
                            fontSize: 25,
                            color: Colors.lightBlue),
                      ),
                    ),
                    Text('${user?.email}',
                        style:
                            TextStyle(fontSize: 15, color: Colors.lightBlue)),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 20.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Account',
                      style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'regular',
                          color: Colors.lightBlue),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileUpdate()));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.lightBlue,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text('Edit Profile',
                                  style: TextStyle(color: Colors.lightBlue)),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.lightBlue,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => ProfileUpdate()));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AutoUpdate()));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_taxi,
                            color: Colors.lightBlue,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text('Edit Auto',
                                  style: TextStyle(color: Colors.lightBlue)),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.lightBlue,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                        FirebaseAuth.instance.signOut();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignScreen()));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            color: Colors.lightBlue,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text('Log Out',
                                  style: TextStyle(color: Colors.blue)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
