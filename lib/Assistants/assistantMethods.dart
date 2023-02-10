// ignore_for_file: await_only_futures

import 'package:drivers_app/Assistants/requestAssistant.dart';
import 'package:drivers_app/DataHandler/appData.dart';
import 'package:drivers_app/configmap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

import '../Models/address.dart';
import '../Models/alluser.dart';
import '../Models/directionDetail.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${position.latitude},${position.longitude}&key=$mapKey";
    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][2]["long_name"];
      st4 = response["results"][0]["address_components"][3]["long_name"];
      placeAddress = "$st1, $st2, $st3, $st4";
      print(placeAddress);
      Address userPickUpAddress = Address();
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    print("init ${initialPosition.latitude},${initialPosition.longitude}");
    print("final ${finalPosition.latitude},${finalPosition.longitude}");
    String directionUrl =
        // "https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood&key=$mapKey";
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
    var res = await RequestAssistant.getRequest(directionUrl);
    DirectionDetails directionDetails = DirectionDetails();

    if (res == "failed") {
      "";
    }

    directionDetails.encodePoints =
        res["routes"][0]["overview_polyline"]["points"];
    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];
    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    //in terms USD
    double timeTravelFare = (directionDetails.durationValue! / 60) * 0.20;
    double distancTravelFare = (directionDetails.durationValue! / 1000) * 0.20;
    double totalFareAmount =
        (directionDetails.durationValue! + distancTravelFare);

    //local Currency
    //1$ = 160 RS
    //double totalLocalAmount = totalFareAmount*160;
    return totalFareAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child("users").child(userId);
    // print(reference.once().then((DatabaseEvent databaseEvent) {}));
    reference.once().then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        userCurrentInfo = Users.fromSnapshot(databaseEvent.snapshot);
      }
    });
  }
}
