import 'dart:async';

import 'package:fire_uber_driver/main_variables/main_variables.dart';
import 'package:fire_uber_driver/models/user_ride_request_information.dart';
import 'package:fire_uber_driver/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/google_map_provider.dart';
import '../progress/progress_dialog.dart';

class OrderDetails extends StatefulWidget {
  String? orderId;
  OrderDetails({Key? key, this.orderId}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  List<Item> time = <Item>[
    const Item('5\$'),
    const Item('10\$'),
    const Item('20\$'),
    const Item('custom'),
  ];

  var _value;

  double? originLat;
  double? originLong;

  double? destLat;
  double? destLong;

  String? destName;
  String? originName;

  String? userPhoto;
  String? userName;
  String? userPhone;
  String? driverType;
  String? driverRating;
  String? carBrand;
  String? carModel;
  String? carNumber;
  String? pincode;
  String? duration;
  String? distance;
  String? totalPayment;
  String? orderDate;

  String? startAddress;
  String? destinationAddress;
  String? endAddress;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseDatabase.instance
        .ref()
        .child("orders")
        .child(widget.orderId!)
        .once()
        .then((snap) async {
      if (snap.snapshot.value != null) {
        double timeTraveledFareAmountPerMinute =
            await ((snap.snapshot.value as Map)["duration"] / 60)
                .truncate()
                .toDouble();
        double distanceTraveledFareAmountPerKilometer =
            await ((snap.snapshot.value as Map)["distance"] / 1000)
                .truncate()
                .toDouble();

        setState(() {
          userPhoto = (snap.snapshot.value as Map)["userPhoto"];
          userName = (snap.snapshot.value as Map)["userName"];
          userPhone = (snap.snapshot.value as Map)["userPhone"];
          driverType = (snap.snapshot.value as Map)["driverType"];
          driverRating = (snap.snapshot.value as Map)["driverRating"];
          carBrand = (snap.snapshot.value as Map)["carBrand"];
          carModel = (snap.snapshot.value as Map)["carModel"];
          carNumber = (snap.snapshot.value as Map)["carNumber"];
          pincode = (snap.snapshot.value as Map)["pincode"];
          startAddress = (snap.snapshot.value as Map)["originAddress"];
          endAddress = (snap.snapshot.value as Map)["destinationAddress"];
          duration = timeTraveledFareAmountPerMinute.toString() + " min";
          distance = distanceTraveledFareAmountPerKilometer.toString() + " km";
          totalPayment = (snap.snapshot.value as Map)["totalPayment"] + "\$";
          orderDate = (snap.snapshot.value as Map)["time"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ' + widget.orderId!,
              style: TextStyle(
                  color: Colors.white, fontFamily: "semibold", fontSize: 16),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _buildBody(),
      //bottomNavigationBar: _buildbtn(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
        child: Column(
      children: [
        _buildDriver(),
        _buildLocation(),
        _buildRideDetail(),
        _buildDate(),
        _buildBill(),
      ],
    ));
  }

  Widget _buildBill() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.lightBlue.shade100,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.lightBlue,
                    blurRadius: 2.0,
                    offset: Offset(0.0, 0.25))
              ]),
          padding: EdgeInsets.all(6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    backgroundColor: Colors.lightBlue,
                    label: Text("Total Price: ",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'bold',
                            color: Colors.white)),
                  ),
                  Chip(
                    backgroundColor: Colors.white,
                    label: Text(totalPayment ?? "0\$",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'bold',
                            color: Colors.lightBlue)),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildDate() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.lightBlue.shade100,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.lightBlue,
                    blurRadius: 2.0,
                    offset: Offset(0.0, 0.25))
              ]),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    backgroundColor: Colors.white,
                    label: Text("Date: ",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'bold',
                            color: Colors.lightBlue)),
                  ),
                  Chip(
                    backgroundColor: Colors.lightBlue,
                    label: Text(orderDate ?? "Date",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'bold',
                            color: Colors.white)),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildLocation() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.lightBlue.shade100,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.lightBlue,
                  blurRadius: 2.0,
                  offset: Offset(0.0, 0.25))
            ]),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddress(),
            SizedBox(height: 30),
            _buildDestination(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 18,
          color: Colors.lightBlue,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            // width: ,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startAddress ?? "not getting address",
                  style: const TextStyle(color: Colors.lightBlue, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestination() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 18,
          color: Colors.lightBlue,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            // width: ,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endAddress ?? "end address",
                  style: const TextStyle(color: Colors.lightBlue, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRideDetail() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.lightBlue.shade100,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.lightBlue,
                  blurRadius: 2.0,
                  offset: Offset(0.0, 0.25))
            ]),
        padding: EdgeInsets.all(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text("Distance",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 14,
                        fontFamily: "medium")),
                Text(distance ?? "0 km",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 16,
                        fontFamily: "semibold")),
              ],
            ),
            Column(
              children: [
                Text("Duration",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 14,
                        fontFamily: "medium")),
                Text(duration ?? "0 min",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 16,
                        fontFamily: "semibold")),
              ],
            ),
            Column(
              children: [
                Text("Total",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 14,
                        fontFamily: "medium")),
                Text(totalPayment ?? "0\$",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 16,
                        fontFamily: "semibold")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriver() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.lightBlue.shade100,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.lightBlue,
                    blurRadius: 2.0,
                    offset: Offset(0.0, 0.25))
              ]),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(userPhoto ?? "images/logo.png"),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Chip(
                      backgroundColor: Colors.lightBlue,
                      label: Text(userName ?? "driver Name",
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: "bold",
                              color: Colors.white)),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              // Container(
              //   child: ElevatedButton(
              //       child: Text("Detail",
              //           style: TextStyle(fontSize: 14, fontFamily: 'semibold')),
              //       onPressed: () {
              //         _settingModalBottomSheet(context);
              //       },
              //       style: ElevatedButton.styleFrom(
              //         primary: Color(0xFF3bd38a),
              //         onPrimary: Colors.white,
              //         padding: const EdgeInsets.symmetric(
              //             vertical: 10, horizontal: 10),
              //       )),
              // ),
            ],
          )),
    );
  }

  Widget _buildbtn() {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        child: btnText("Finish Trip"),
        onPressed: () {
          SystemNavigator.pop();

          Fluttertoast.showToast(msg: "Please Restart App Now");
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => Payment()));
        },
        style: btnStyle(),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 16,
      color: Color.fromARGB(255, 243, 243, 243),
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 360,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/profile.jpg"),
                  ),
                  SizedBox(height: 5),
                  Text("John Doe",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: "bold")),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIcon(),
                      _buildIcon(),
                      _buildIcon(),
                      _buildIcon(),
                      _buildIcon(),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Add Tips",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontFamily: "medium")),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10.0,
                          children: time.map((e) {
                            return _buildChip(
                              e.text,
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  _buildbtn(),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildChip(name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ChoiceChip(
        label: Text(name),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        selected: _value == name,
        selectedColor: Color(0xFF3bd38a),
        onSelected: (bool value) {
          setState(() {
            _value = value ? name : null;
          });
        },
        backgroundColor: Colors.grey,
        labelStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(Icons.star, color: Color(0xFF3bd38a), size: 14);
  }

  btnText(txt) {
    return Text(txt, style: TextStyle(fontSize: 16, fontFamily: 'semibold'));
  }

  btnStyle() {
    return ElevatedButton.styleFrom(
      primary: Colors.lightBlue,
      onPrimary: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
    );
  }
}

class Item {
  const Item(this.text);
  final String text;
}
