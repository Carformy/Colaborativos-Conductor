import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NewTripHistory {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? car_details;
  String? driverName;
  String? timestamp;
  String? userName;
  String? userPhone;

  NewTripHistory(
      {this.time,
      this.originAddress,
      this.destinationAddress,
      this.status,
      this.fareAmount,
      this.car_details,
      this.driverName,
      this.timestamp,
      this.userName,
      this.userPhone});

  NewTripHistory.fromSnapshot(DataSnapshot dataSnapshot) {
    time = (dataSnapshot.value as Map)["time"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    status = (dataSnapshot.value as Map)["status"];
    fareAmount = (dataSnapshot.value as Map)["fareAmount"];
    car_details = (dataSnapshot.value as Map)["car_details"];
    driverName = (dataSnapshot.value as Map)["driverName"];
    timestamp = (dataSnapshot.value as Map)["timestamp"];
    userName = (dataSnapshot.value as Map)["userName"];
    userPhone = (dataSnapshot.value as Map)["userPhone"];
  }
}
