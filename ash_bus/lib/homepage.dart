import 'dart:async';

import 'dart:typed_data';

import 'package:ash_bus/models/http.dart';
import 'package:ash_bus/walletPayment.dart';
import 'package:ash_bus/qrscanPage.dart';
import 'package:ash_bus/widgets/buttons.dart';
import 'package:ash_bus/widgets/drawer.dart';
import 'package:ash_bus/widgets/orderBusSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:ash_bus/models/constants.dart' as Constants;
import 'package:url_launcher/url_launcher.dart';

//This is the main page of the application


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  //Variables
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  LatLng chooseOnMapPosition = LatLng(5.5720735552603715, -0.2799524335806773);
  Marker marker;
  Marker pickUpMarker;
  bool newPickup = false;

  Circle circle;


  //Initial position when the starts
  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(5.5751017948673205, -0.28277586498131496),
    zoom: 13,
    bearing: 0,
  );

  //Get the bus icon to help pinpoint the location
  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/icons/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getLocationMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/icons/location_icon.png");
    return byteData.buffer.asUint8List();
  }


  //Update the map to have this location
  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData, Uint8List LocationData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {


      pickUpMarker = Marker(
          markerId: MarkerId("homei"),
          position: chooseOnMapPosition,
          zIndex: 3,
          flat: true,
          icon: BitmapDescriptor.defaultMarker
      );


      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          draggable: false,
          zIndex: 2,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
      );

      Constants.busMarker = Marker(
          markerId: MarkerId("bus"),
          position: Constants.busPosition,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)
      );


      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          strokeWidth: 5,
          zIndex: 1,
          strokeColor: Colors.white,
//          strokeColor: Color(0xffB71500),
          center: latlng,
          fillColor: Colors.transparent
      );
    });
  }

  //Allow camera to animate on the user location
  void CameraOnLocation(double lat, double lng){
    Constants.controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        bearing: 0,
        target: LatLng(lat, lng),
        tilt: 0,
        zoom: 16))
    );
  }


  //Get the location of the user
  void getCurrentLocation() async {

    try {
      Constants.imageData = await getMarker();
      Constants.LocationData = await getLocationMarker();
      var location = await _locationTracker.getLocation();

      print("Pressed on location");

      updateMarkerAndCircle(location, Constants.imageData, Constants.LocationData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription = _locationTracker.onLocationChanged().listen((newLocalData) {
        if (Constants.controller != null) {
          CameraOnLocation(newLocalData.latitude, newLocalData.longitude);
          updateMarkerAndCircle(newLocalData, Constants.imageData, Constants.LocationData);
        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void _onCameraMove(CameraPosition position) async{
    chooseOnMapPosition = position.target;

    //Update the marker for the pickup location
    this.setState(() {
      if(Constants.routeObtained == false){
        pickUpMarker = Marker(
            markerId: MarkerId("homei"),
            position: chooseOnMapPosition,
            icon: BitmapDescriptor.defaultMarker
        );
      }
      Constants.pickUpAddress = "Please wait, getting pickup location...";
    });
    newPickup = true;
  }

  //When the camera stops moving
  Future<void> _onCamerStopMoving() async {

    //Get the address of the new pickup location
    if(newPickup && !Constants.newScreen && Constants.chooseOnMap){
      print("New Pickup Location:::::: $newPickup");
      Constants.pickUpAddress = await searchCordinatesAddress(chooseOnMapPosition);

      setState(() {
        Constants.pickUpAddress = Constants.pickUpAddress;
      });

      print(Constants.pickUpAddress);
    }

  }


  //Show Location function upon start
  void startShowLocation() async {

    Constants.newScreen = false;

    try {
      Constants.imageData = await getMarker();
      Constants.LocationData = await getLocationMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, Constants.imageData, Constants.LocationData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      //Check if user would choose on the map
      if(Constants.chooseOnMap){
        chooseOnMapPosition = LatLng(location.latitude, location.longitude);
        CameraOnLocation(chooseOnMapPosition.latitude, chooseOnMapPosition.longitude);
        //Get the address of the new pickup location
        Constants.pickUpAddress = await searchCordinatesAddress(chooseOnMapPosition);
      }

      //Check if the route has been obtained and display route
      else if(Constants.routeObtained || Constants.startTrip){
        Constants.controller.animateCamera(CameraUpdate.newLatLngBounds(Constants.latLngBounds, 120));
        updateMarkerAndCircle(location, Constants.imageData, Constants.LocationData);

        Timer.periodic(Duration(seconds: 1), (Timer t)
        {
          getBusPosition();
        });


      }

      else{
        //Frequent updates of location marker when location changes
        _locationSubscription = _locationTracker.onLocationChanged().listen((newLocalData) {
          if (Constants.controller != null) {
              CameraOnLocation(newLocalData.latitude, newLocalData.longitude);
              updateMarkerAndCircle(newLocalData, Constants.imageData, Constants.LocationData);
          }
        });
      }

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  //Get Bus position
  getBusPosition() async {
    var details = await getData('http://dan3.pythonanywhere.com/bus_get/');

    for (int i = 0; i < details.length; i++) {
      if (details[i]["bus_number"] == Constants.userListBus[Constants.userTripListID]["bus"]["bus_number"]) {
        List temp = details[i]["location"].toString().split(",");

        Constants.busPosition = LatLng(double.parse(temp[0].toString().trim()), double.parse(temp[1].toString().trim()));

        print("Bus details Location: ${details[i]["location"]}");
        if (mounted) {
          setState(() {
            Constants.busMarker = Marker(
                markerId: MarkerId("bus"),
                position: Constants.busPosition,
                draggable: false,
                zIndex: 2,
                flat: true,
                anchor: Offset(0.5, 0.5),
                icon: BitmapDescriptor.fromBytes(Constants.imageData)
            );
          });
          //Get the time between the bus and the pickup location
          obtainPickUpDetails(Constants.busPosition, Constants.pickUpLocation);

          if(Constants.bus_pickUp_details.distanceVal < 20 ){
            //Bus is here
            print("Bus is here");

            //Give the staff notification
            busHereNotification('Bus has arrived!',"Please scan the QR code when you get on the bus");

              Constants.busAtPickUp = true;
          }


        }
        break;
      }
    }
  }

  //Start Simulation
  Future<void> startSimulation(List<LatLng> list_points)  async {
    int i = 0;
    Timer.periodic(Duration(milliseconds: 200), (Timer t) {
//      if(i == 5){
      if(i == list_points.length-1){
        t.cancel();
      }

      //Check if the bus is less than 10 metres from the pickup location
      if(Constants.bus_pickUp_details.distanceVal < 40 ){
        //Bus is here
        print("Bus is here");

        //Give the staff notification
        busHereNotification('Bus has arrived!',"Please scan the QR code when you get on the bus");

        setState(() {
          Constants.busAtPickUp = true;
        });
        t.cancel();
      }


      if (mounted){
        setState(()  {
          Constants.busPosition = list_points[i];

          Constants.busMarker = Marker(
              markerId: MarkerId("bus"),
              position: Constants.busPosition,
              draggable: false,
              zIndex: 2,
              flat: true,
              anchor: Offset(0.5, 0.5),
              icon: BitmapDescriptor.fromBytes(Constants.imageData)
          );

          obtainPickUpDetails(Constants.busPosition, Constants.pickUpLocation);
        });
      }
      else{
        return;
      }

      i +=1;
    });

  }

  //Display the pickup marker or not
  List<Marker> displayPickUp(){
    if(Constants.chooseOnMap == true || Constants.routeObtained == true){
      return [pickUpMarker];
    }
    else{
      return [];
    }
  }

  //Confirm pickup location
  Future<void> confirmPickUp() async {
    //Get the location of pickup
    Constants.pickUpLocation = chooseOnMapPosition;
    Constants.chooseOnMap = false;
    print("Clicked on");

    //Get the distance between the bus and the pickup location
    Constants.bus_pickUp_details = await obtainDirectionDetails(Constants.busPosition, Constants.pickUpLocation);

    setCameraBounds(Constants.pickUpLocation, Constants.busPosition);

    //Animate camera to show the buses available on the map
    Constants.controller.animateCamera(
        CameraUpdate.newLatLngBounds(Constants.latLngBounds, 120)
    );

    //Route has been obtained
    setState(() {
      Constants.routeObtained = true;
      pickUpMarker = Marker(
          markerId: MarkerId("homei"),
          position: Constants.pickUpLocation,
          zIndex: 3,
          flat: true,
          icon: BitmapDescriptor.defaultMarker
      );
    });
  }

  //Cancel Trip
  cancelTrip(){
    print("Pressed on cancel trip");
    setState(() {
      Constants.confirmRide = false;
      Constants.routeObtained = false;
      Constants.busAtPickUp = false;
      Constants.chooseOnMap = false;
      Constants.startTrip = false;
    });

    //Clear the polylines
    Constants.pLineCordinates.clear();
    Constants.polyLineSet.clear();
    
    //Remove the markers as well
    for(int i = 0; i < Constants.markersSet.length; i++){
      Constants.markersSet.remove(Constants.markersSet.elementAt(i));
    }



    startShowLocation();
  }

  //Get announcements
  getAnnouncement() async {
    var details = await getData("http://10.0.2.2:8000/announcement_get/");
    Hive.box(Constants.MAINBOX).put(Constants.ANNOUNCEMENT, details[details.length -1]["message"]);
    print(details);
  }

  //Start Trip
  startTrip(){
    print("Trip has started");
    setState(() {
      Constants.routeObtained = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScanPage()),
    );

    //Get the route for the journey
    getPlaceDirection(Constants.pickUpLocation, Constants.dropOffLocation);
  }

  //Open the side drawer
  openDrawer(){
    _drawerKey.currentState.openDrawer();
  }

  viewWallet(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WalletPage()),
    );
  }

  void chooseRide(){
    Constants.confirmRide = true;

    print("Ride has been confirmed");
    StaffAddTrip("${chooseOnMapPosition.latitude},${chooseOnMapPosition.longitude}");


    setCameraBounds(Constants.pickUpLocation, Constants.busPosition);

//    Animate camera to show the buses available on the map
    Constants.controller.animateCamera(
        CameraUpdate.newLatLngBounds(Constants.latLngBounds, 100)
    );
      getPlaceDirection(Constants.pickUpLocation, Constants.dropOffLocation);
  }

  //Call or message driver
  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  //Bus details widget
  Widget BusDetail(busNumber,busStatus,duration,amount,busCondition,seatsAvailable, id, index){
    Color inactiveColor = Colors.black45;
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: busStatus != "Available" ? null: (){
            print(id);
            Constants.userTripId = id.toString();
            Constants.userTripListID = index;
            chooseRide();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset("assets/icons/fromBus_icon.png",width: MediaQuery.of(context).size.width * 0.15,),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${busNumber}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700 , color: busStatus != "Available" ? inactiveColor: Colors.black),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.time_to_leave, color: Colors.black45, size: 15, ),
                          SizedBox(width: 3,),
                          Text("${duration}", style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),),
                          SizedBox(width: 5,),
                          Icon(Icons.payment, color: Colors.black45, size: 15, ),
                          SizedBox(width: 3,),
                          Text("${amount}", style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),),

                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text("${busStatus}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: busStatus != "Available" ? inactiveColor: Colors.green),),
                          Text(" || ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black45),),
                          Text("${busCondition}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: busStatus != "Available" ? inactiveColor: Colors.green),),
                        ],
                      )
                    ],
                  )
                ],
              ),

              //Seats Available
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      "${seatsAvailable}" ,
                      style: TextStyle(fontSize: 20, color: busStatus != "Available" ? inactiveColor: Colors.black, fontWeight: FontWeight.w700)
                  ),
                  Text(
                      "seats \navailable",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w600)
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  getBusDetails() async{
    var details = await getData('http://dan3.pythonanywhere.com/trip_get/');
    if(details != null){
      if (Constants.userListBus.isNotEmpty){
        Constants.userListBus.clear();
      }
      for(int i = 0; i < details.length;i++){
        if(details[i]["bus"]["status"] == "Available" ){
          Constants.userListBus.add(details[i]);
          print("Here");
        }
      }

      print(Constants.userListBus);
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAnnouncement();

    getBusDetails();

    //Get bus details
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _drawerKey,
        drawer: MainDrawer(),
        body: Container(
          child: Stack(
            children: <Widget>[

              //Main Page
              Positioned(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: GoogleMap(
                  mapType: MapType.terrain,
                  initialCameraPosition: initialLocation,
                  markers: Set.of((marker != null) ? [marker, Constants.busMarker] +  Constants.markersSet.toList() + displayPickUp() : []),
                  circles: Set.of((circle != null) ? [circle] : []),
                  compassEnabled: false,
                  myLocationEnabled: false,
                  polylines: Constants.polyLineSet,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCamerStopMoving,
                  onMapCreated: (GoogleMapController controller) async {
                    Constants.controller = controller;
                    print("Map has been created");
                      startShowLocation();
                    //Get the location when the map is created

                  },
                ),
              ),

              //Menu icon at the top left corner
              Positioned(
                  top: 20 + width * 0.025,
                  left: width * 0.05,
                  width: width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Material(
                            color: Colors.white,
                            child: InkWell(
                              child: Container(
                                child: Icon(
                                  Icons.menu,
                                  color: Color(0xffB71500),
                                ),
                                padding: EdgeInsets.all(width * 0.03),
                              ),
                              onTap: openDrawer,
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                          child: Icon(
                            Icons.location_searching,
                          ),
                          backgroundColor: Color(0xffB71500),
                          onPressed: () {
                            getCurrentLocation();
//                            startSimulation(Simulation.gbawe_weekendMunchies);
//                            cancelTrip();
                          })
                    ],
                  )
              ),

              //Lower part of the page to order for the bus
              !Constants.chooseOnMap ?
              DraggableScrollableActuator(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.30,
                  minChildSize: 0.15,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Card(
                        elevation: 12.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              topLeft: Radius.circular(25),
                            )
                        ),
                        color: Colors.white,
                        child: Container(
                          height: height,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: <Widget>[
                              !Constants.routeObtained && !Constants.confirmRide  ?
                              OrderBusSheet():
                              Constants.confirmRide ?
                              //Confirm Ride bottom
                              Container(
                                height: height * 0.8,
                                padding: EdgeInsets.symmetric( vertical: 20),
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        children: <Widget>[
                                          Text(Constants.startTrip == true ? "Trip has started!": Constants.busAtPickUp == true ? "Bus is here!": Constants.bus_pickUp_details.durationText == null ? "Calculating ETA of Bus" :"Bus arrives in ${Constants.bus_pickUp_details.durationText}!", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),),
                                          SizedBox(height: 20,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[

                                                    Text("${Constants.userListBus[Constants.userTripListID]["bus"]["bus_number"]}", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),),
                                                    Row(
                                                      children: <Widget>[
                                                        Icon(Icons.person,color: Colors.black54, size: 18,),
                                                        SizedBox(width: 4,),
                                                        Text("${Constants.userListBus[Constants.userTripListID]["driver"]["person"]["first_name"]} "
                                                            "${Constants.userListBus[Constants.userTripListID]["driver"]["person"]["last_name"]}",
                                                          style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),),
                                                      ],
                                                    ),

                                                    SizedBox(height: 10,),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                        "${Constants.userListBus[Constants.userTripListID]["bus"]["seats_occupied"]}" ,
                                                        style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700)
                                                    ),
                                                    Text(
                                                        "seats \navailable",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w600)
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),

                                          SizedBox(height: 20,),

                                          Divider(height: 2, color: Colors.black12, thickness: 1.2,),

                                          Container(
                                            child: Material(
                                              color: Colors.white,
                                              child: InkWell(
                                                onTap: ()=>{},
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 20),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(Icons.location_on),
                                                            SizedBox(width: 10,),
                                                            Container(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Container(
                                                                    width: width * 0.7,
                                                                    child: Text("${Constants.dropOffAddress}",
                                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17)
                                                                    ),
                                                                  ),
                                                                  Text("Change Destination", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600, fontSize: 13)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      Icon(Icons.arrow_forward_ios,color: Colors.black12,)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Divider(height: 2, color: Colors.black12, thickness: 1.2,),

                                          SizedBox(height: 20,),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.payment),
                                                  SizedBox(width: 10,),
                                                  Text("Cost of Transit", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
                                                ],
                                              ),
                                              Text("GH₵${Constants.userListBus[Constants.userTripListID]["cost"]}.00", style: TextStyle(fontWeight: FontWeight.w700,fontSize: 17),),
                                            ],
                                          ),

//                                        Show account error message
                                          Hive.box(Constants.MAINBOX).get(Constants.VIRTUAL_WALLET) >= Constants.amount ?
                                          Container():
                                          Column(
                                            children: <Widget>[
                                              SizedBox(height: 15,),
                                              Text(
                                                "Your balance is insufficient!, please view wallet and top up. ",
                                                style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14, color: Colors.red),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  TripIcons(action: ()=> _launchURL("tel:${Constants.userListBus[Constants.userTripListID]["driver"]["person"]["mobile"]}"),title: "Call \nDriver", icon: Icons.call, ),
                                                  TripIcons(action: ()=> _launchURL("sms:${Constants.userListBus[Constants.userTripListID]["driver"]["person"]["mobile"]}"),title: "Message \nDriver", icon: Icons.message, ),
                                                  TripIcons(action: viewWallet,title: "View \nWallet", icon: Icons.work, ),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              child: Constants.startTrip == false ?
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: RedBtn(action: startTrip, name: "Scan QR code",onboarding: true,disabled: Constants.busAtPickUp || Hive.box(Constants.MAINBOX).get(Constants.VIRTUAL_WALLET) < Constants.amount ,),
                                                  ),
                                                  SizedBox (width: width * 0.05,),
                                                  Expanded(
                                                    child: RedBtn(action: cancelTrip,name: "Cancel",),
                                                  ),
                                                ],
                                              ):
                                              RedBtn(action: cancelTrip,name: "End Trip",width: double.infinity,),

                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ):
                              //Select trip bottom
                              Container(
                                padding: EdgeInsets.symmetric( vertical: 10),
                                child: Column(
                                  children: <Widget>[
                                    ConfirmTopSection(message: "Confirm Ride!",),
                                    Constants.userListBus.isNotEmpty ?
                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: Constants.userListBus.asMap().entries.map((bus)=>
                                            BusDetail(bus.value["bus"]["bus_number"].toString(), bus.value["bus"]["status"].toString(),"5 min","GH 3","Good Condition",bus.value["bus"]["seats_occupied"],bus.value["id"],bus.key)).toList()
                                    ):
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Text(
                                        'Sorry there are not buses around.',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                  ],
                                ),
                              )

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ):
              //Confirm pickup location bottom
              Positioned(
                bottom: 0,
                width: width,
                child:
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      ConfirmTopSection(message: "Confirm pickup",),
                      SizedBox(height: 20,),

                      //Location of the pickup
                      Container(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.location_on, size: 19,),
                            SizedBox(width: 3,),
                            Text(
                              Constants.pickUpAddress.length < 40  ? Constants.pickUpAddress.toString()  : "${Constants.pickUpAddress.substring(0, 40)}...",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),)
                          ],
                        ),
                      ),
                      SizedBox(height: 30,),

                      //Confirm button
                      Container(
                        child: RedBtn(
                          action: confirmPickUp,
                          name: "CONFIRM",
                          width: double.infinity,

                        ),
                      )
                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}


class TripIcons extends StatelessWidget {
  final String title;
  final Function action;
  final IconData icon;

  const TripIcons({Key key, this.title, this.action, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlatButton.icon(onPressed: this.action, icon: Icon(this.icon), label: Container(), shape: CircleBorder(side: BorderSide(width: 2,color: Constants.wineBackgroundColor)), padding: EdgeInsets.only(top: 20, bottom: 20, left: 15,right: 10 ),),
          SizedBox(height: 5,),
          Text(this.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 13,fontWeight: FontWeight.w600),)
        ],
      ),
    );
  }
}



class ConfirmTopSection extends StatelessWidget {
  final String message;

  const ConfirmTopSection({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        SizedBox(height: 10,),

        Container(
          child: Text(this.message, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),),
        ),

        SizedBox(height: 15,),

        //Divider
        Container(
          width: double.infinity,
          height: 1,
          color: Color(0xffBDBDBD),
        ),
      ],
    );
  }
}



