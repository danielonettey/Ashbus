//These are the backend functions of the application
import 'dart:async';
import 'dart:convert';
import 'package:ash_bus/models/directionDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:ash_bus/models/constants.dart' as Constants;
import '../main.dart';

//Get the announcements from the database
getAnnouncement() async {
  String myUrl = "https://bpcimobileapp.000webhostapp.com/getData.php";
  var req = await http.get(myUrl);
  var announcement = json.decode(req.body)[0];

  //Store data locally
  Hive.box(Constants.MAINBOX).put(Constants.ANNOUNCEMENT, announcement['message']);
  Hive.box(Constants.MAINBOX).put(Constants.AUTHOR, announcement['author']);

}

//Make momo payments
makeMomoPayment(amount, phone, network) async{
  try{
    var headers = {
      'authorization': 'Bearer ${Constants.secretKeyFLutterWave}',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request('POST', Uri.parse('https://api.flutterwave.com/v3/charges?type=mobile_money_ghana'));
    request.bodyFields = {
      'amount': amount.toString(),
      'tx_ref': 'postman_trias',
      'email': 'dnettey3@gmail.com',
      'phone_number': phone.toString(),
      'currency': 'GHS',
      'network': network.toString()
    };

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseText = await response.stream.bytesToString();
      var decodedData = jsonDecode(responseText);
      return decodedData["meta"]["authorization"]["redirect"];
    }
    else {
      print("Response reason phrase ::::: ${response.reasonPhrase}");
    }
  }

  catch(exp){
    print(exp);
  }








//
//
//  //get the data from the database
//  String url ='https://api.flutterwave.com/v3/charges?type=mobile_money_ghana';
//
//  print("Not working");
//
//  try{
//    var res = await http.post(url,body: {
//
//      "tx_ref":"1",
//      "amount":"1",
//      "currency":"GHS",
//      "voucher":"143256743",
//      "network":"MTN",
//      "email":"dnettey3@gmail.com",
//      "phone_number":"0559418732",
//      "fullname":"Patience Mensah"
//    }
//
//    );
//
//    var responseBody = json.decode(res.body);
//    print(responseBody);





    return ;

}


//Get address from coordinates
Future<dynamic > getRequestAddress(String url) async{
  http.Response response= await http.get(url);
  try {
    if(response.statusCode == 200){
      String jSonData = response.body;
      var decodedData = jsonDecode(jSonData);
      return decodedData;
    }

    else{
      return "Failed";
    }
  }
  catch(e){
      return "Failed";
  }

}

//Get coordinates from address
Future<String> searchCordinatesAddress(LatLng position) async {
  String placeAddress = "";
  String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${Constants.MAPS_KEY}";
  var response = await getRequestAddress(url);

  if(response != "Failed"){
    placeAddress = response["results"][0]["formatted_address"];
  }

  return placeAddress;
}

//Get the details of the user's confirmed pickup location
void obtainPickUpDetails(LatLng initialPos, LatLng finalPos) async{
  Constants.bus_pickUp_details = await obtainDirectionDetails(initialPos, finalPos);
}

// Get the direction and route details
Future<DirectionDetails> obtainDirectionDetails(LatLng initialPos, LatLng finalPos) async{
  String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPos.latitude},${initialPos.longitude}&destination=${finalPos.latitude},${finalPos.longitude}&key=${Constants.MAPS_KEY}";
  var response = await getRequestAddress(url);

  if(response == "Failed"){
    return null;
  }

  DirectionDetails directionDetails = DirectionDetails();
  directionDetails.encodedPoints = response["routes"][0]["overview_polyline"]["points"];
  directionDetails.distanceText = response["routes"][0]["legs"][0]["distance"]["text"];
  directionDetails.distanceVal = response["routes"][0]["legs"][0]["distance"]["value"];
  directionDetails.durationText = response["routes"][0]["legs"][0]["duration"]["text"];
  directionDetails.durationVal = response["routes"][0]["legs"][0]["duration"]["value"];

  return directionDetails;
}

//Get the place directions from one coordinate to another
Future<void> getPlaceDirection(LatLng initialPos, LatLng finalPos) async {
  Constants.placeDirection  = await obtainDirectionDetails(initialPos, finalPos);
  drawRoute(Constants.placeDirection.encodedPoints, initialPos, finalPos);
}

//Draw the route from the encoded points
drawRoute(String encodedPoints, LatLng initialPos, LatLng finalPos){

  //clear polyline on map
  Constants.pLineCordinates.clear();
  PolylinePoints polylinePoints = PolylinePoints();
  print("Encoded Points $encodedPoints");

  List<PointLatLng> decodedPolyLinePoints = polylinePoints.decodePolyline(encodedPoints);
  if(decodedPolyLinePoints.isNotEmpty){
    decodedPolyLinePoints.forEach((PointLatLng pointLatLng){
      Constants.pLineCordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
    });
  }

  Constants.polyLineSet.clear();
  Polyline polyline = Polyline(
      color: Colors.green,
      polylineId: PolylineId("lineID"),
      points: Constants.pLineCordinates,
      jointType: JointType.round,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true
  );
  Constants.polyLineSet.add(polyline);

  //Set camera bound for both positions
  setCameraBounds(initialPos, finalPos);
  Constants.controller.animateCamera(CameraUpdate.newLatLngBounds(Constants.latLngBounds, 70));

  Marker initalPosMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: Constants.START_LOCATION.placeName, snippet: "Location"),
      position: initialPos,
      markerId: MarkerId("initialPos")
  );

  Marker finalPosMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: Constants.END_LOCATION.placeName, snippet: "Destination"),
      position: finalPos,
      markerId: MarkerId("finalPos")
  );

  //Add Markers on the Map
  Constants.markersSet.add(initalPosMarker);
  Constants.markersSet.add(finalPosMarker);
}

//Set Camera bounds for two positions
setCameraBounds(LatLng initialPos, LatLng finalPos){

  if(initialPos.latitude > finalPos.latitude && initialPos.longitude > finalPos.longitude ){
    Constants.latLngBounds = LatLngBounds(southwest: finalPos, northeast: initialPos);
  }
  else if(initialPos.latitude > finalPos.latitude){
    Constants.latLngBounds = LatLngBounds(southwest: LatLng(finalPos.latitude, initialPos.longitude), northeast: LatLng(initialPos.latitude, finalPos.longitude));
  }
  else if(initialPos.longitude > finalPos.longitude ){
    Constants.latLngBounds = LatLngBounds(southwest: LatLng(initialPos.latitude, finalPos.longitude), northeast: LatLng(finalPos.latitude, initialPos.longitude));
  }
  else{
    Constants.latLngBounds = LatLngBounds(southwest: initialPos, northeast: finalPos);
  }
}

//Send the notification when the bus arrives
void busHereNotification(String title, String body) async {

  var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 1));
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'alarm_notif',
    'alarm_notif',
    'Channel for Alarm notification',
    icon: 'ic_launcher',
    sound: null,
    largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
  );

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails( android:
  androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.schedule(0, title, body,
      scheduledNotificationDateTime, platformChannelSpecifics);
}

//Driver upload Location
DriverUploadLocation(trip_id, driver_id, bus_id, bus_location, bus_address, status) async{

  try{
    var request = http.MultipartRequest('POST', Uri.parse('http://dan3.pythonanywhere.com/trip_update/'));
    request.fields.addAll({
      'end_time': '10:20:17',
      'driver': driver_id,
      'bus': bus_id,
      'trip_id': trip_id,
      'bus_location': bus_location,
      'bus_status': status,
      'bus_address': bus_address
    });


    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  catch(exp){
    print("Working from exception");
    print(exp);
  }

  return;
}

//Get the data from a url
getData(String url) async {
  var request = http.Request('GET', Uri.parse(url));
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    var responseText = await response.stream.bytesToString();
    var decodedData = jsonDecode(responseText);
    print(decodedData);
    return decodedData;
  }
  else {
    print(response.reasonPhrase);
  }

  return null;

}

//The driver starts trip and updates the database
DriverCreateTrip(start_time, bus_id, driver_id) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('http://dan3.pythonanywhere.com/trip_create/'));
    request.fields.addAll({
      'start_time': start_time,
      'end_time': start_time,
      'bus': bus_id,
      'driver': driver_id,
      'cost': '3'
    });

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var responseText = await response.stream.bytesToString();
    }
    else {
      var responseText = await response.stream.bytesToString();
      Constants.TRIP_ID = jsonDecode(responseText)["id"].toString();
    }

  }

  catch(exp){
    print("Working from Driver Create Execption");
    print(exp);
  }

  return;
}


//Update the route that the bus will take in the database
DriverUpdateBusRoute(bus_number, route_id) async{
  try{
    var request = http.MultipartRequest('POST', Uri.parse('http://dan3.pythonanywhere.com/bus_update/'));
    request.fields.addAll({
      'status': 'Available',
      'bus_number': 'GT-8767-21',
      'route_id': '1'
    });

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

  }
  catch(exp){
    print("Working from Driver Create Execption");
    print(exp);
  }
}

//Get the locations of the staff from the database
DriverGetStaffLocation() async{
  try{
    var request = http.MultipartRequest('GET', Uri.parse('http://dan3.pythonanywhere.com/stafftrip_get/'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseText = await response.stream.bytesToString();
      var details = jsonDecode(responseText);

      for(int i=0;i<details.length;i++){
        if (details[i]["trip"] == Constants.TRIP_ID.toString()){
          //Get the pick up locations of staff
          List listPickupLocation = details[i]["pickup_location"].toString().split(",");
          LatLng pickUpLat = LatLng(double.parse(listPickupLocation[0].toString().trim()),double.parse(listPickupLocation[1].toString().trim()));

          //Get the drop off locations of staff
          List listDropOffLocation = details[i]["dropoff_location"].toString().split(",");
          LatLng dropOffLat = LatLng(double.parse(listDropOffLocation[0].toString().trim()),double.parse(listDropOffLocation[1].toString().trim()));
          Constants.DriverPickUpLocations.add(pickUpLat);
          Constants.DriverDropOffLocations.add(dropOffLat);
          break;
        }
      }
    }
    else {
      print(response.reasonPhrase);
    }
  }
  catch(exp){
    print("Working from Driver Get Staff Execption");
    print(exp);
  }
}

//Add a staff to a trip
StaffAddTrip(pickupLocation) async{
  try{
    var request = http.MultipartRequest('POST', Uri.parse('http://dan3.pythonanywhere.com/stafftrip_get/'));
    request.fields.addAll({
      'trip': Constants.userTripId.toString(),
      'staff': Constants.userId.toString(),
      'pickup_location': pickupLocation.toString(),
      'dropoff_time': '12:12:12',
    });

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }
  catch(exp){
    print(exp);
  }
}

//Update the staff details on a trip
StaffUpdateTrip() async{
  try{
    var request = http.MultipartRequest('POST', Uri.parse('http://dan3.pythonanywhere.com/stafftrip_update/'));
    request.fields.addAll({
      'dropoff_time': '12:20:20',
      'trip_id': Constants.userTripId,
      'dropoff_location': '5.092822,-0.212123',
      'dropoff_Address': 'Ashesi University',
      'payment': 'Success'
    });

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }
  catch(exp){
    print(exp);
  }
}