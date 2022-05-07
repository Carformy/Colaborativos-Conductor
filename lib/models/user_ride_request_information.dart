import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation {
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;
  String? userPhoto;
  String? pincode;
  String? timestamp;
  String? totalPayment;
  String? duration;
  String? distance;

  UserRideRequestInformation(
      {this.originLatLng,
      this.destinationLatLng,
      this.originAddress,
      this.destinationAddress,
      this.rideRequestId,
      this.userName,
      this.userPhone,
      this.userPhoto,
      this.pincode,
      this.timestamp,
      this.totalPayment,
      this.duration,
      this.distance});
}
