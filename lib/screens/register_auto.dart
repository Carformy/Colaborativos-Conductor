import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fire_uber_driver/screens/tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_database/firebase_database.dart';

import 'sign_screen.dart';

class RegisterAuto extends StatefulWidget {
  final String? name;
  final String? lastName;
  final String? address;
  final String? phone;
  final String? email;
  final String? password;

  RegisterAuto(
      {Key? key,
      this.name,
      this.lastName,
      this.address,
      this.phone,
      this.email,
      this.password})
      : super(key: key);

  @override
  State<RegisterAuto> createState() => _RegisterAutoState();
}

class _RegisterAutoState extends State<RegisterAuto> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String photoURL = '';
  String error = '';

  final carBrand = TextEditingController();

  final carModel = TextEditingController();

  final carNumber = TextEditingController();

  List<String> taxiTypes = ['Suv', 'Elegant', 'Simple', 'Motorcycle'];
  String? selectedTaxi = 'Suv';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              key: _scaffoldKey,

              appBar: AppBar(
                backgroundColor: Colors.lightBlue,
                elevation: 0.0,
                title: Text('Enter Car Details'),
                automaticallyImplyLeading: false,
              ), //appBar
              body: Container(
                color: Colors.grey.shade200,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                          child: TextFormField(
                            controller: carBrand,
                            decoration: InputDecoration(
                                hintText: 'Car Brand', labelText: 'Car Brand'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                          child: TextFormField(
                            controller: carModel,
                            decoration: InputDecoration(
                                hintText: 'Car Model', labelText: 'Car Model'),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                          child: TextFormField(
                            controller: carNumber,
                            decoration: InputDecoration(
                                hintText: 'Car Number',
                                labelText: 'Car Number'),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          child: DropdownButtonFormField<String>(
                            itemHeight: 50,
                            decoration: InputDecoration(
                              labelText: "Select Taxi Type",
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    width: 0,
                                    color: Colors.lightGreen.shade700),
                              ),
                            ),
                            value: selectedTaxi,
                            items: taxiTypes
                                .map((taxi) => DropdownMenuItem<String>(
                                    value: taxi,
                                    child: Text(taxi,
                                        style: TextStyle(fontSize: 14))))
                                .toList(),
                            onChanged: (taxi) {
                              setState(() {
                                print(taxi);
                                selectedTaxi = taxi;
                                print(selectedTaxi);
                              });
                            },
                          ),
                        ),

                        Column(
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 320.0,
                              height: 45.0,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                color: Colors.lightBlue,
                                onPressed: () async {
                                  // widget.toggleView();

                                  FirebaseAuth.instance
                                      .authStateChanges()
                                      .listen((User? user) async {
                                    if (user == null) {
                                      try {
                                        UserCredential userCredential =
                                            await FirebaseAuth.instance
                                                .createUserWithEmailAndPassword(
                                                    email: widget.email!,
                                                    password: widget.password!);
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == 'weak-password') {
                                          print(
                                              'The password provided is too weak.');
                                        } else if (e.code ==
                                            'email-already-in-use') {
                                          print(
                                              'The account already exists for that email.');
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    } else {
                                      var currentUser =
                                          FirebaseAuth.instance.currentUser;

                                      DatabaseReference ref = FirebaseDatabase
                                          .instance
                                          .ref("drivers");

                                      ref
                                          .child(currentUser!.uid)
                                          .set({
                                            "id": currentUser.uid,
                                            "name": widget.name!,
                                            "displayName": widget.name!,
                                            "lastName": widget.lastName!,
                                            "address": widget.address!,
                                            "phone": widget.phone!,
                                            "email": widget.email!,
                                            "carBrand": carBrand.text,
                                            "carModel": carModel.text,
                                            "carNumber": carNumber.text,
                                            "photoURL":
                                                "https://firebasestorage.googleapis.com/v0/b/my-uber-taxi.appspot.com/o/users%2Fu6Z55N9JyPQgPm0nMMPRhQCS9uG2?alt=media&token=ce5ad367-da5f-4cc1-857d-a87aa0496e3b",
                                            "carType": selectedTaxi,
                                            "isAvailable": true,
                                            "earnings": "0",
                                            "ratings": "5",
                                          })
                                          .then((value) => print("User Added"))
                                          .catchError((error) => print(
                                              "Failed to add user: $error"));
                                    }
                                  });
                                },
                                child: Text('Sign Up',
                                    style: TextStyle(color: Colors.white)),
                              ), //rec
                            ), //flat
                          ], //widget
                        ), //column

                        Divider(),

                        Column(
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 320.0,
                              height: 45.0,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignScreen()));
                                },
                                child: Text('Back to Login',
                                    style: TextStyle(color: Colors.lightBlue)),
                              ), //rec
                            ), //flat
                          ], //widget
                        ), //column
                      ],
                    ),
                  ),
                ),
              ), //textform
            );
          }

          return TabsScreen();
        });
  }
}
