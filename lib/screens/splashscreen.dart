import 'dart:async';

import 'package:fire_uber_driver/screens/tabs.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      Navigator.push(context, MaterialPageRoute(builder: (c) => TabsScreen()));
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.lightBlue.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('images/splash.json'),
              Text(
                "Uber Driver Application",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue.shade500,
                    fontWeight: FontWeight.bold),
              ),
              // Image.asset("images/logo1.png"),
              // const SizedBox(
              //   height: 10,
              // ),
              // const Text(
              //   "Uber & inDriver Clone App",
              //   style: TextStyle(
              //       fontSize: 24,
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
