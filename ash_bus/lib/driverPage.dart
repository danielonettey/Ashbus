import 'dart:async';
import 'dart:typed_data';
import 'package:ash_bus/driverWelcomePage.dart';
import 'package:ash_bus/models/http.dart';
import 'package:ash_bus/widgets/buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

//THis is the driver page

class DriverPage extends StatefulWidget {
  DriverPage({ @required Key key}) : super(key:key);

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  //Variables
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Set<Marker> markers = {};
  Circle circle;
  bool trip_started = false;


  //Initial position when the starts
  static final CameraPosition initialLocation = CameraPosition(
    target: Constants.driverLocation,
    zoom: 13,
    bearing: 0,
  );

  //Get the bus icon to help pinpoint the location
  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/icons/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  //Update the map to have this location
  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("mroee"),
          position: latlng,
          rotation: newLocalData.heading,
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
      var location = await _locationTracker.getLocation();
      updateMarkerAndCircle(location, Constants.imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription = _locationTracker.onLocationChanged().listen((newLocalData) {
        if (Constants.controller != null) {
          Constants.driverLocation = LatLng(newLocalData.latitude, newLocalData.longitude);

          if(trip_started){
            DriverUploadLocation(Constants.TRIP_ID.toString(), Constants.Driver_id, Constants.driverBus.toString(), "${Constants.driverLocation.latitude},${Constants.driverLocation.longitude}", "Address", "Available");

            //Get the pickup and dropoff locations of staff
            DriverGetStaffLocation();
            for(int i = 0; i < Constants.DriverDropOffLocations.length; i++){
              //Add driver pickup locations to map
              Constants.markersSet.add(
                  marker = Marker(
                      markerId: MarkerId("Pickup$i"),
                      position: Constants.DriverPickUpLocations[i],
                      draggable: false,
                      zIndex: 2,
                      flat: true,
                      anchor: Offset(0.5, 0.5),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                  )
              );
              //Add driver dropoff locations to map
              Constants.markersSet.add(
                  marker = Marker(
                      markerId: MarkerId("dropoff$i"),
                      position: Constants.DriverDropOffLocations[i],
                      draggable: false,
                      zIndex: 2,
                      flat: true,
                      anchor: Offset(0.5, 0.5),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                  )
              );
            }
          }
          updateMarkerAndCircle(newLocalData, Constants.imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  //Cancel Trip
  cancel(){
    print("Pressed on cancel trip");
    setState(() {
      trip_started = false;
    });
    DriverUploadLocation(Constants.TRIP_ID.toString(), Constants.Driver_id, Constants.driverBus.toString(), "${Constants.driverLocation.latitude},${Constants.driverLocation.longitude}", "Address", "Unavailable");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DriverWelcomePage()),
    );
  }

  //Start Trip
  start(){
    setState(() {
      trip_started = true;
    });

    Constants.markersSet.clear();
    DriverUploadLocation(Constants.TRIP_ID.toString(), Constants.Driver_id.toString(), Constants.driverBus.toString(), "${Constants.driverLocation.latitude},${Constants.driverLocation.longitude}", "Address", "Available");
    getPlaceDirection(Constants.routeStartLocation, Constants.routeEndLocation);
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
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Stack(
            children: <Widget>[

              //Main Page
              Positioned(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: GoogleMap(
                  mapType: MapType.terrain,
                  key: widget.key,
                  initialCameraPosition: initialLocation,
                  markers: Set.of((marker != null) ? [marker] +  Constants.markersSet.toList() : []),
                  circles: Set.of((circle != null) ? [circle] : []),
                  compassEnabled: false,
                  myLocationEnabled: false,
                  polylines: Constants.polyLineSet,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    Constants.controller = controller;
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
                            )],
                        ),
                        child: ClipOval(
                          child: Material(
                            color: Colors.white,
                            child: InkWell(
                              child: Container(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Color(0xffB71500),
                                ),
                                padding: EdgeInsets.all(width * 0.03),
                              ),
                              onTap: cancel,
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
                          })
                    ],
                  )
              ),

//              Lower part of the page to order for the bus
              Positioned(
                bottom: 0,
                width: width,
                child:
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 10),
                  color: Colors.transparent,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RedBtn(action: trip_started ? start : start,name: trip_started ?  "Cancel Trip" :"Start Trip",onboarding: trip_started ? false :true,),
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