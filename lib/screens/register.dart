import 'package:fire_uber_driver/screens/register_auto.dart';
import 'package:fire_uber_driver/screens/sign_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fire_uber_driver/screens/login_screen.dart';
// import 'package:fire_uber_driver/screens/signin_screen.dart';
// import 'package:fire_uber_driver/screens/signup.dart';
import 'package:fire_uber_driver/screens/tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_database/firebase_database.dart';

class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String photoURL = '';
  String error = '';

  final email = TextEditingController();

  final password = TextEditingController();

  final address = TextEditingController();

  final displayName = TextEditingController();

  final lastName = TextEditingController();

  final phone = TextEditingController();

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
                automaticallyImplyLeading: true,
                title: Text('Register', style: TextStyle(color: Colors.white)),

                /**
				actions: <Widget>[
					FlatButton.icon(
						icon: Icon(Icons.person),
						label: Text(''),
						onPressed: () {
							widget.toggleView();
						},
					),
				],//action
				**/
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
                            controller: displayName,
                            //validator: (val) => val?.isEmpty ? 'Enter a FirstName' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Firstname'),
                            decoration: InputDecoration(
                                hintText: 'Firstname', labelText: 'Firstname'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                          child: TextFormField(
                            controller: lastName,
                            //validator: (val) => val.isEmpty ? 'Enter a Lastname' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Lastname'),
                            decoration: InputDecoration(
                                hintText: 'Lastname', labelText: 'Lastname'),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                          child: TextFormField(
                            controller: address,
                            //validator: (val) => val.isEmpty ? 'Enter a Address' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Address'),
                            decoration: InputDecoration(
                                hintText: 'Address', labelText: 'Address'),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                          child: TextFormField(
                            controller: phone,
                            //validator: (val) => val.isEmpty ? 'Enter a Phone' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Phone'),
                            decoration: InputDecoration(
                                hintText: 'Phonenumber',
                                labelText: 'Phonenumber'),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                          child: TextFormField(
                            controller: email,
                            //validator: (val) => val.isEmpty ? 'Enter a Email' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Email'),
                            decoration: InputDecoration(
                                hintText: 'Email', labelText: 'Email'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                          child: TextFormField(
                            controller: password,
                            //validator: (val) => val.isEmpty ? 'Enter a Password' : null,
                            obscureText: true,
                            //decoration: textInputDecoration.copyWith(hintText: 'Password'),
                            decoration: InputDecoration(
                                hintText: 'Password', labelText: 'Password'),
                          ),
                        ),

                        Text(
                          error,
                          style: TextStyle(
                              color: Colors.lightGreen.shade700, fontSize: 7.0),
                        ), //text

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

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterAuto(
                                              name: displayName.text,
                                              lastName: lastName.text,
                                              address: address.text,
                                              phone: phone.text,
                                              email: email.text,
                                              password: password.text,
                                            )),
                                  );
                                },
                                child: Text('Continue',
                                    style: TextStyle(color: Colors.white)),
                              ), //rec
                            ), //flat
                          ], //widget
                        ), //column
                        // Column(
                        //   children: <Widget>[
                        //     ButtonTheme(
                        //       minWidth: 320.0,
                        //       height: 45.0,
                        //       child: FlatButton(
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(7.0)),
                        //         color: Colors.lightGreen.shade700,
                        //         onPressed: () async {},
                        //         child: Text('Register User',
                        //             style: TextStyle(color: Colors.white)),
                        //       ), //rec
                        //     ), //flat
                        //   ], //widget
                        // ), //column

                        // Divider(),

                        // Column(
                        //   children: <Widget>[
                        //     ButtonTheme(
                        //       minWidth: 320.0,
                        //       height: 45.0,
                        //       child: FlatButton(
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(7.0)),
                        //         onPressed: () async {
                        //           //widget.toggleView();
                        //           Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                   builder: (context) => SignScreen()));
                        //         },
                        //         child: Text('Back to Login',
                        //             style: TextStyle(color: Colors.lightBlue)),
                        //       ), //rec
                        //     ), //flat
                        //   ], //widget
                        // ), //column

                        // Column(
                        //   children: <Widget>[
                        //     ButtonTheme(
                        //       minWidth: 320.0,
                        //       height: 45.0,
                        //       child: FlatButton(
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(7.0)),
                        //         color: Colors.lightGreen.shade700,
                        //         onPressed: () async {
                        //           //	widget.toggleView();
                        //           Navigator.push(context,
                        //               MaterialPageRoute(builder: (context) => Login()));
                        //         },
                        //         child: Text(
                        //           'Back to Login',
                        //           style: TextStyle(color: Colors.white),
                        //         ),
                        //       ), //rec
                        //     ), //flat
                        //   ], //widget
                        // ), //column
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
