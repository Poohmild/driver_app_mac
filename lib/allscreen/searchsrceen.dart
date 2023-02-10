// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, avoid_unnecessary_containers, prefer_const_constructors_in_immutables

import 'package:drivers_app/Assistants/requestAssistant.dart';
import 'package:drivers_app/DataHandler/appData.dart';
import 'package:drivers_app/Models/address.dart';
import 'package:drivers_app/Models/placePredictions.dart';
import 'package:drivers_app/configmap.dart';
import 'package:drivers_app/widget/divider.dart';
import 'package:drivers_app/widget/progressDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var input_pickup = TextEditingController();
  var input_dropoff = TextEditingController();
  List<PlacePredictions> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation!.placeName ?? "";
    input_pickup.text = placeAddress;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height / 20),
                    Stack(
                      children: [
                        GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.arrow_back)),
                        Center(
                          child: Text("Set Drop Off",
                              style: TextStyle(
                                  fontSize: 18, fontFamily: "Brand Bold")),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Image.asset("images/pickicon.png",
                            height: 16, width: 16),
                        SizedBox(width: 18),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              controller: input_pickup,
                              decoration: InputDecoration(
                                hintText: "PickUp Location",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset("images/desticon.png",
                            height: 16, width: 16),
                        SizedBox(width: 18),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              onChanged: (val) => findPlace(val),
                              controller: input_dropoff,
                              decoration: InputDecoration(
                                hintText: "Where to?",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            //tile for prediction
            SizedBox(height: 10),
            placePredictionList.length > 0
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      itemBuilder: (context, index) => PredictionTile(
                          placePredictions: placePredictionList[index]),
                      separatorBuilder: (BuildContext context, int index) {
                        return DividerWidget();
                      },
                      itemCount: placePredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123456789&components=country:th";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if (res == "failed") {
        return;
      }
      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  PredictionTile({Key? key, required this.placePredictions}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => getPlaceAddressDetail(placePredictions.place_id!, context),
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(height: 3),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text("${placePredictions.main_text}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 2),
                      Text("${placePredictions.secondary_text}",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 8),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetail(String placeId, context) async {
    showDialog(
        context: context,
        builder: (context) => ProgressDialog(
              message: "Setting Dropoff, Please wait....",
            ));
    String placeDetailUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var res = await RequestAssistant.getRequest(placeDetailUrl);
    Navigator.pop(context);
    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];
      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
      print("This is drop off location ::");
      print(address.placeName);
      Navigator.pop(context, "obtainDirection");
    }
  }
}
