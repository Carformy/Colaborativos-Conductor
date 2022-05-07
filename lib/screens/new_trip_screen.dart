import 'dart:async';

import 'package:fire_uber_driver/main_variables/main_variables.dart';
import 'package:fire_uber_driver/models/user_ride_request_information.dart';
import 'package:fire_uber_driver/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/google_map_provider.dart';
import '../progress/progress_dialog.dart';
import 'ride_summary.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({
    this.userRideRequestDetails,
  });

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Enter Pincode";
  Color? buttonColor = Colors.lightBlue;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  final pincode = TextEditingController();

  //Step 1:: when driver accepts the user ride request
  // originLatLng = driverCurrent Location
  // destinationLatLng = user PickUp Location

  //Step 2:: driver already picked up the user in his/her car
  // originLatLng = user PickUp Location => driver current Location
  // destinationLatLng = user DropOff Location
  Future<void> drawPolyLineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await GoogleMapProvider.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.red,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        width: 4,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    // Circle originCircle = Circle(
    //   circleId: const CircleId("originID"),
    //   fillColor: Colors.green,
    //   radius: 12,
    //   strokeWidth: 3,
    //   strokeColor: Colors.white,
    //   center: originLatLng,
    // );

    // Circle destinationCircle = Circle(
    //   circleId: const CircleId("destinationID"),
    //   fillColor: Colors.red,
    //   radius: 12,
    //   strokeWidth: 3,
    //   strokeColor: Colors.white,
    //   center: destinationLatLng,
    // );

    // setState(() {
    //   setOfCircle.add(originCircle);
    //   setOfCircle.add(destinationCircle);
    // });
  }

  @override
  void initState() {
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();
  }

  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  getDriversLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);

    geolocationDriverLivePostion =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your Position"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
        newTripGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      //updating driver location at real time in Database
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };
      FirebaseDatabase.instance
          .ref()
          .child("locations")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("driverLocation")
          .set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      var originLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      ); //Driver current Location

      var destinationLatLng;

      if (rideRequestStatus == "accepted") {
        destinationLatLng =
            widget.userRideRequestDetails!.originLatLng; //user PickUp Location
      } else //arrived
      {
        destinationLatLng = widget
            .userRideRequestDetails!.destinationLatLng; //user DropOff Location
      }

      var directionInformation =
          await GoogleMapProvider.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          //google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            //circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              var userPickUpLatLng =
                  widget.userRideRequestDetails!.originLatLng;

              drawPolyLineFromOriginToDestination(
                  driverCurrentLatLng, userPickUpLatLng!);

              getDriversLocationUpdatesAtRealTime();
            },
          ),

          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.lightBlueAccent,
                          // gradient: LinearGradient(
                          //   begin: Alignment.centerRight,
                          //   end: Alignment.centerLeft,
                          //   colors: [
                          //     Colors.greenAccent,
                          //     Colors.yellow,
                          //   ],
                          // ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "From",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    Text(
                                      widget.userRideRequestDetails!
                                              .originAddress!
                                              .substring(0, 27) +
                                          "...",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.lightBlueAccent,
                          // gradient: LinearGradient(
                          //   begin: Alignment.centerRight,
                          //   end: Alignment.centerLeft,
                          //   colors: [
                          //     Colors.greenAccent,
                          //     Colors.yellow,
                          //   ],
                          // ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_searching,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "To",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    Text(
                                      widget.userRideRequestDetails!
                                              .destinationAddress!
                                              .substring(0, 27) +
                                          "...",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 20.0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                    image: NetworkImage(widget
                                            .userRideRequestDetails!
                                            .userPhoto ??
                                        'images/Elegant.png'),
                                    fit: BoxFit.cover)),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userRideRequestDetails!.userName ??
                                        "Driver name",
                                    style: TextStyle(
                                      fontFamily: 'semi-bold',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    widget.userRideRequestDetails!.userPhone ??
                                        "Driver name",
                                    style: TextStyle(
                                      fontFamily: 'semi-bold',
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Distance',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      widget.userRideRequestDetails!.distance ??
                                          "0 km",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Duration',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      widget.userRideRequestDetails!.duration ??
                                          "0",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      widget.userRideRequestDetails!
                                              .totalPayment ??
                                          "0",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Padding(
                          //       padding: const EdgeInsets.all(2.0),
                          //       child: Column(
                          //         children: [
                          //           Text(
                          //             'Distance',
                          //             style: TextStyle(color: Colors.grey),
                          //           ),
                          //           Text(distance ?? "0 km"),
                          //         ],
                          //       ),
                          //     ),
                          //     Padding(
                          //       padding: const EdgeInsets.all(2.0),
                          //       child: Column(
                          //         children: [
                          //           Text(
                          //             'Duration',
                          //             style: TextStyle(color: Colors.grey),
                          //           ),
                          //           Text(duration ?? "0"),
                          //         ],
                          //       ),
                          //     ),
                          //     Padding(
                          //       padding: const EdgeInsets.all(2.0),
                          //       child: Column(
                          //         children: [
                          //           Text(
                          //             'Total',
                          //             style: TextStyle(color: Colors.grey),
                          //           ),
                          //           Text(totalPayment ?? "0"),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          //[driver has arrived at user PickUp Location] - Arrived Button
                          if (rideRequestStatus == "accepted") {
                            showDialog(
                                context: context,
                                builder: (BuildContext Context) {
                                  return ratingContainer();
                                });
                          }
                          //[user has already sit in driver's car. Driver start trip now] - Lets Go Button
                          else if (rideRequestStatus == "arrived") {
                            rideRequestStatus = "ontrip";

                            var tripDirectionDetails = await GoogleMapProvider
                                .obtainOriginToDestinationDirectionDetails(
                                    widget
                                        .userRideRequestDetails!.originLatLng!,
                                    widget.userRideRequestDetails!
                                        .destinationLatLng!);

                            print("tripDirectionDetails");
                            print(tripDirectionDetails);

                            //fare amount
                            double totalFareAmount = GoogleMapProvider
                                .calculateFareAmountFromOriginToDestination(
                                    tripDirectionDetails!);

                            FirebaseDatabase.instance
                                .ref()
                                .child("deals")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("distance")
                                .set(tripDirectionDetails.distance_value);

                            FirebaseDatabase.instance
                                .ref()
                                .child("deals")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("duration")
                                .set(tripDirectionDetails.duration_value);

                            FirebaseDatabase.instance
                                .ref()
                                .child("deals")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("fareAmount")
                                .set(totalFareAmount.toString());

                            FirebaseDatabase.instance
                                .ref()
                                .child("deals")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("status")
                                .set("ontrip");

                            FirebaseDatabase.instance
                                .ref()
                                .child("deals")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .once()
                                .then((snap) async {
                              if (snap.snapshot.value != null) {
                                FirebaseDatabase.instance
                                    .ref()
                                    .child("orders")
                                    .child(widget
                                        .userRideRequestDetails!.timestamp!)
                                    .set(snap.snapshot.value);
                              }
                            });

                            setState(() {
                              buttonTitle = "End Trip"; //end the trip
                              buttonColor = Colors.redAccent;
                            });
                          }
                          //[user/Driver reached to the dropOff Destination Location] - End Trip Button
                          else if (rideRequestStatus == "ontrip") {
                            endTripNow();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: buttonColor,
                          onPrimary: Colors.white,
                          shadowColor: Colors.greenAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                          minimumSize: Size(100, 40),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Center(
                            child: Text(
                              buttonTitle!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        // icon: const Icon(
                        //   Icons.directions_car,
                        //   color: Colors.white,
                        //   size: 25,
                        // ),
                        // label: Text(
                        //   buttonTitle!,
                        //   style: const TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          //ui
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     decoration: const BoxDecoration(
          //       color: Colors.black,
          //       borderRadius: BorderRadius.only(
          //         topLeft: Radius.circular(18),
          //       ),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.white30,
          //           blurRadius: 18,
          //           spreadRadius: .5,
          //           offset: Offset(0.6, 0.6),
          //         ),
          //       ],
          //     ),
          //     child: Padding(
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          //       child: Column(
          //         children: [
          //           //duration
          //           Text(
          //             durationFromOriginToDestination,
          //             style: const TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.lightGreenAccent,
          //             ),
          //           ),

          //           const SizedBox(
          //             height: 18,
          //           ),

          //           const Divider(
          //             thickness: 2,
          //             height: 2,
          //             color: Colors.grey,
          //           ),

          //           const SizedBox(
          //             height: 8,
          //           ),

          //           //user name - icon
          //           Row(
          //             children: [
          //               Text(
          //                 widget.userRideRequestDetails!.userName!,
          //                 style: const TextStyle(
          //                   fontSize: 20,
          //                   fontWeight: FontWeight.bold,
          //                   color: Colors.lightGreenAccent,
          //                 ),
          //               ),
          //               const Padding(
          //                 padding: EdgeInsets.all(10.0),
          //                 child: Icon(
          //                   Icons.phone_android,
          //                   color: Colors.grey,
          //                 ),
          //               ),
          //             ],
          //           ),

          //           const SizedBox(
          //             height: 18,
          //           ),

          //           //user PickUp Address with icon
          //           Row(
          //             children: [
          //               Image.asset(
          //                 "images/origin.png",
          //                 width: 30,
          //                 height: 30,
          //               ),
          //               const SizedBox(
          //                 width: 14,
          //               ),
          //               Expanded(
          //                 child: Container(
          //                   child: Text(
          //                     widget.userRideRequestDetails!.originAddress!,
          //                     style: const TextStyle(
          //                       fontSize: 16,
          //                       color: Colors.grey,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),

          //           const SizedBox(height: 20.0),

          //           //user DropOff Address with icon
          //           Row(
          //             children: [
          //               Image.asset(
          //                 "images/destination.png",
          //                 width: 30,
          //                 height: 30,
          //               ),
          //               const SizedBox(
          //                 width: 14,
          //               ),
          //               Expanded(
          //                 child: Container(
          //                   child: Text(
          //                     widget
          //                         .userRideRequestDetails!.destinationAddress!,
          //                     style: const TextStyle(
          //                       fontSize: 16,
          //                       color: Colors.grey,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),

          //           const SizedBox(
          //             height: 24,
          //           ),

          //           const Divider(
          //             thickness: 2,
          //             height: 2,
          //             color: Colors.grey,
          //           ),

          //           const SizedBox(height: 10.0),

          //           ElevatedButton.icon(
          //             onPressed: () async {
          //               //[driver has arrived at user PickUp Location] - Arrived Button
          //               if (rideRequestStatus == "accepted") {
          //                 showDialog(
          //                     context: context,
          //                     builder: (BuildContext Context) {
          //                       return ratingContainer();
          //                     });
          //               }
          //               //[user has already sit in driver's car. Driver start trip now] - Lets Go Button
          //               else if (rideRequestStatus == "arrived") {
          //                 rideRequestStatus = "ontrip";

          //                 var tripDirectionDetails = await GoogleMapProvider
          //                     .obtainOriginToDestinationDirectionDetails(
          //                         widget.userRideRequestDetails!.originLatLng!,
          //                         widget.userRideRequestDetails!
          //                             .destinationLatLng!);

          //                 print("tripDirectionDetails");
          //                 print(tripDirectionDetails);

          //                 //fare amount
          //                 double totalFareAmount = GoogleMapProvider
          //                     .calculateFareAmountFromOriginToDestination(
          //                         tripDirectionDetails!);

          //                 FirebaseDatabase.instance
          //                     .ref()
          //                     .child("deals")
          //                     .child(
          //                         widget.userRideRequestDetails!.rideRequestId!)
          //                     .child("distance")
          //                     .set(tripDirectionDetails.distance_value);

          //                 FirebaseDatabase.instance
          //                     .ref()
          //                     .child("deals")
          //                     .child(
          //                         widget.userRideRequestDetails!.rideRequestId!)
          //                     .child("duration")
          //                     .set(tripDirectionDetails.duration_value);

          //                 FirebaseDatabase.instance
          //                     .ref()
          //                     .child("deals")
          //                     .child(
          //                         widget.userRideRequestDetails!.rideRequestId!)
          //                     .child("fareAmount")
          //                     .set(totalFareAmount.toString());

          //                 FirebaseDatabase.instance
          //                     .ref()
          //                     .child("deals")
          //                     .child(
          //                         widget.userRideRequestDetails!.rideRequestId!)
          //                     .child("status")
          //                     .set("ontrip");

          //                 FirebaseDatabase.instance
          //                     .ref()
          //                     .child("deals")
          //                     .child(
          //                         widget.userRideRequestDetails!.rideRequestId!)
          //                     .once()
          //                     .then((snap) async {
          //                   if (snap.snapshot.value != null) {
          //                     FirebaseDatabase.instance
          //                         .ref()
          //                         .child("orders")
          //                         .child(
          //                             widget.userRideRequestDetails!.timestamp!)
          //                         .set(snap.snapshot.value);
          //                   }
          //                 });

          //                 setState(() {
          //                   buttonTitle = "End Trip"; //end the trip
          //                   buttonColor = Colors.redAccent;
          //                 });
          //               }
          //               //[user/Driver reached to the dropOff Destination Location] - End Trip Button
          //               else if (rideRequestStatus == "ontrip") {
          //                 endTripNow();
          //               }
          //             },
          //             style: ElevatedButton.styleFrom(
          //               primary: buttonColor,
          //             ),
          //             icon: const Icon(
          //               Icons.directions_car,
          //               color: Colors.white,
          //               size: 25,
          //             ),
          //             label: Text(
          //               buttonTitle!,
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  endTripNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    //get the tripDirectionDetails = distance travelled
    // var currentDriverPositionLatLng = LatLng(
    //   onlineDriverCurrentPosition!.latitude,
    //   onlineDriverCurrentPosition!.longitude,
    // );

    var tripDirectionDetails =
        await GoogleMapProvider.obtainOriginToDestinationDirectionDetails(
            widget.userRideRequestDetails!.originLatLng!,
            widget.userRideRequestDetails!.destinationLatLng!);

    print("tripDirectionDetails");
    print(tripDirectionDetails);

    //fare amount
    double totalFareAmount =
        GoogleMapProvider.calculateFareAmountFromOriginToDestination(
            tripDirectionDetails!);

    FirebaseDatabase.instance
        .ref()
        .child("deals")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("fareAmount")
        .set(totalFareAmount.toString());

    FirebaseDatabase.instance
        .ref()
        .child("deals")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("status")
        .set("ended");

    saveFareAmountToDriverEarnings(totalFareAmount);

    geolocationDriverLivePostion!.cancel();

    Navigator.pop(context);

    //display fare amount in dialog box
    // showDialog(
    //   context: context,
    //   builder: (BuildContext c) => FareAmountCollectionDialog(
    //     totalFareAmount: totalFareAmount,
    //   ),
    // );

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RideSummary(
                orderId: widget.userRideRequestDetails!.timestamp!.toString(),
                dealId: widget.userRideRequestDetails!.rideRequestId!)));

    //save fare amount to driver total earnings
  }

  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) //earnings sub Child exists
      {
        //12
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("earnings")
            .set(driverTotalEarnings.toString());
      } else //earnings sub Child do not exists
      {
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("earnings")
            .set(totalFareAmount.toString());
      }
    });
  }

  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("deals")
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    databaseReference.child("driverLocation").set(driverLocationDataMap);

    databaseReference.child("status").set("accepted");
    // databaseReference.child("driverId").set(onlineDriverData.id);
    // databaseReference.child("driverName").set(onlineDriverData.name);
    // databaseReference.child("driverPhone").set(onlineDriverData.phone);
    // databaseReference.child("car_details").set(
    //     onlineDriverData.car_brand.toString() +
    //         onlineDriverData.car_model.toString());

    saveRideRequestIdToDriverHistory();
  }

  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("tripsHistory");

    tripsHistoryRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .set(true);
  }

  Widget ratingContainer() {
    return AlertDialog(
        contentPadding: EdgeInsets.all(10),
        backgroundColor: Colors.lightBlue.shade100,
        content: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              // Text(
              //   'Pincode please',
              //   style: TextStyle(color: Colors.grey),
              //   textAlign: TextAlign.center,
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              TextFormField(
                controller: pincode,
                cursorColor: Colors.white,

                //validator: (val) => val?.isEmpty ? 'Enter a FirstName' : null,
                //decoration: textInputDecoration.copyWith(hintText: 'Firstname'),
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white),
                    labelStyle: TextStyle(color: Colors.lightBlue),
                    border: InputBorder.none,

                    //contentPadding:
                    //EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "Please enter Pincode",
                    labelText: 'Please enter Pincode'),
              ),
              SizedBox(
                height: 20,
              ),
              //gradientButton(() {}, 'Begin Trip')
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.lightBlue,
                  // gradient: LinearGradient(
                  //   begin: Alignment.centerRight,
                  //   end: Alignment.centerLeft,
                  //   colors: [
                  //     Colors.red,
                  //     Colors.black,
                  //   ],
                  // ),
                ),
                child: InkWell(
                  onTap: () async {
                    if (pincode.text ==
                        widget.userRideRequestDetails!.pincode) {
                      Navigator.pop(context);
                      rideRequestStatus = "arrived";

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext c) => ProgressDialog(
                          message: "Loading...",
                        ),
                      );

                      await drawPolyLineFromOriginToDestination(
                          widget.userRideRequestDetails!.originLatLng!,
                          widget.userRideRequestDetails!.destinationLatLng!);

                      Navigator.pop(context);

                      FirebaseDatabase.instance
                          .ref()
                          .child("deals")
                          .child(widget.userRideRequestDetails!.rideRequestId!)
                          .child("status")
                          .set(rideRequestStatus);

                      setState(() {
                        buttonTitle = "Start Trip"; //start the trip
                        buttonColor = Colors.lightBlue;
                      });
                    } else {
                      Fluttertoast.showToast(msg: "Pincode is incorrect");
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Submit",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'bold',
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  gradientButton(route, text) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.red,
            Colors.black,
          ],
        ),
      ),
      child: InkWell(
        onTap: () async {
          rideRequestStatus = "arrived";

          FirebaseDatabase.instance
              .ref()
              .child("deals")
              .child(widget.userRideRequestDetails!.rideRequestId!)
              .child("status")
              .set(rideRequestStatus);

          setState(() {
            buttonTitle = "Start Trip"; //start the trip
            buttonColor = Colors.lightBlue;
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext c) => ProgressDialog(
              message: "Loading...",
            ),
          );

          await drawPolyLineFromOriginToDestination(
              widget.userRideRequestDetails!.originLatLng!,
              widget.userRideRequestDetails!.destinationLatLng!);

          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'bold', fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
