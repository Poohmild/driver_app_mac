// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print, unused_local_variable

import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:drivers_app/Assistants/assistantMethods.dart';
import 'package:drivers_app/DataHandler/appData.dart';
import 'package:drivers_app/Models/directionDetail.dart';
import 'package:drivers_app/allscreen/loginscreen.dart';
import 'package:drivers_app/allscreen/searchsrceen.dart';
import 'package:drivers_app/configmap.dart';
import 'package:drivers_app/widget/divider.dart';
import 'package:drivers_app/widget/progressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainSrceen extends StatefulWidget {
  const MainSrceen({super.key});

  @override
  State<MainSrceen> createState() => _MainSrceenState();
}

class _MainSrceenState extends State<MainSrceen> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  DirectionDetails? tripDirectionDetails;

  var geoLocator = Geolocator();

  List<LatLng> pLineCoordinates = [];

  Position? currentPosition;

  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double bottomPaddingOfMap = 0;
  double riderDeatilContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300.0;

  bool drawerOpen = true;

  var colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  var colorizeTextStyle = TextStyle(
    fontSize: 55.0,
    fontFamily: 'Signatra',
  );

  DatabaseReference? rideRequestRef;

  @override
  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.ref().child("Ride Requests").push();
    var pickup = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropoff = Provider.of<AppData>(context, listen: false).dropOffLocation;
    Map pickUpLocmap = {
      "latiude": pickup!.latitude.toString(),
      "longtiude": pickup.longitude.toString()
    };
    Map dropOffLocmap = {
      "latiude": dropoff!.latitude.toString(),
      "longtiude": dropoff.longitude.toString()
    };

    Map riderinfoMap = {
      "driver_id": "waiting",
      "payment_medthod": "cash",
      "pickup": pickUpLocmap,
      "dropoff": dropOffLocmap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo!.name,
      "rider_phone": userCurrentInfo!.phone,
      "pickup_address": pickup.placeName,
      "dropoff_address": dropoff.placeName
    };
    rideRequestRef!.set(riderinfoMap);
  }

  void cancelRideRequest() {
    rideRequestRef!.remove();
  }

  void displayRequestRideCintainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      riderDeatilContainerHeight = 0;
      bottomPaddingOfMap = 240.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  void displayRiderDetailContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      riderDeatilContainerHeight = 240.0;
      bottomPaddingOfMap = 240.0;
      drawerOpen = false;
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      riderDeatilContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your Address :: $address");
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255,
        child: Drawer(
            child: ListView(
          children: [
            SizedBox(
              height: 165,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Image.asset("images/user_icon.png", height: 65, width: 65),
                    SizedBox(height: 6),
                    Column(
                      children: [
                        Text(
                          "Profile Name",
                          style:
                              TextStyle(fontSize: 16, fontFamily: "Brand Bold"),
                        ),
                        SizedBox(height: 6),
                        Text("Visit Profile")
                      ],
                    )
                  ],
                ),
              ),
            ),
            DividerWidget(),
            SizedBox(height: 12),
            //Drawer
            ListTile(
              leading: Icon(Icons.history),
              title: Text("History", style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("View Profile", style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About", style: TextStyle(fontSize: 15)),
            ),
            InkWell(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                    (route) => false);
              },
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text("Sign Out", style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        )),
      ),
      body: Stack(
        children: [
          GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
              trafficEnabled: true,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {
                  bottomPaddingOfMap = 300.0;
                });
                locatePosition();
              }),
          //HamburgerButton for Drawer
          Positioned(
            top: 38,
            left: 22,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldkey.currentState!.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white,
                        blurRadius: 6,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(drawerOpen ? Icons.menu : Icons.close,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      Text(
                        "Hi there, ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "Where to?, ",
                        style:
                            TextStyle(fontSize: 20, fontFamily: "Brand Bold"),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                          if (res == "obtainDirection") {
                            displayRiderDetailContainer();
                            print("get");
                          }
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height / 15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7))
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 10),
                                Text("Search Drop Off")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.grey),
                          SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    Provider.of<AppData>(context)
                                                .pickUpLocation !=
                                            null
                                        ? Provider.of<AppData>(context)
                                            .pickUpLocation!
                                            .placeName!
                                        : "Add Home",
                                    overflow: TextOverflow.ellipsis),
                                SizedBox(height: 4),
                                Text(
                                  "Your living home address",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      DividerWidget(),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.work, color: Colors.grey),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(height: 4),
                              Text(
                                "Your office address",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12),
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(
                height: riderDeatilContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset("images/taxi.png",
                                      height: 70, width: 80),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Car",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Brand Bold"),
                                      ),
                                      Text(
                                        tripDirectionDetails != null
                                            ? tripDirectionDetails!
                                                .distanceText!
                                            : "",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontFamily: "Brand Bold"),
                                      ),
                                      // Expanded(child: Container()),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                tripDirectionDetails != null
                                    ? "\$${AssistantMethods.calculateFares(tripDirectionDetails!)}"
                                    : "",
                                style: TextStyle(fontFamily: "Brand Bold"),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckDollar,
                                size: 18, color: Colors.black54),
                            SizedBox(width: 16),
                            Text("Cash"),
                            SizedBox(width: 6),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.black54, size: 16)
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: InkWell(
                          onTap: () {
                            displayRequestRideCintainer();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.blueAccent),
                            child: Padding(
                              padding: EdgeInsets.all(17),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Request",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Icon(Icons.local_taxi,
                                      color: Colors.white, size: 26)
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 0.5,
                        blurRadius: 16,
                        color: Colors.black54,
                        offset: Offset(0.7, 0.7))
                  ]),
              height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.center,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              'Requesting a Ride...',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                            ),
                            ColorizeAnimatedText(
                              'Please wait...',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                            ),
                            ColorizeAnimatedText(
                              'Finding a Driver...',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                            ),
                          ],
                          isRepeatingAnimation: true,
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 22.0),
                    Container(
                      height: 60.0,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                              width: 2.0, color: Colors.grey.shade300)),
                      child: Icon(
                        Icons.close,
                        size: 26,
                      ),
                    ),
                    SizedBox(height: 22.0),
                    InkWell(
                      onTap: () {
                        cancelRideRequest();
                        resetApp();
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Cancel Ride",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    print("pickup $pickUpLatLng");
    var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos.longitude!);
    print("drop $dropOffLatLng");
    showDialog(
      context: context,
      builder: (context) => ProgressDialog(
        message: "Please wait...",
      ),
    );
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);
    print("This is Encode Polint ::");
    print(details.encodePoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodePoints!);

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: Colors.pink,
          polylineId: PolylineId("polylineID"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          geodesic: true);
      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: "my Location"),
        position: pickUpLatLng,
        markerId: MarkerId("pickupId"));
    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
        position: dropOffLatLng,
        markerId: MarkerId("dropOffId"));
    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });
    Circle pickLocCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeColor: Colors.blueAccent,
        circleId: CircleId("pickUpId"));
    Circle dropOffLocCircle = Circle(
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12,
        strokeColor: Colors.deepPurple,
        circleId: CircleId("dropOffId"));
    setState(() {
      circlesSet.add(pickLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}
