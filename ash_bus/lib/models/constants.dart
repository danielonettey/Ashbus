import 'dart:typed_data';
import 'package:ash_bus/models/address.dart';
import 'package:ash_bus/models/directionDetail.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//This shows all the constants used in the system

//Staff Hive Constants
const String MAINBOX = "mainBox";
const String FIRSTNAME = "fnm";
const String LASTNAME = "lnm";
const String EMAIL = "email";
const String MOBILE = "mobile";
const String GENDER = "male";
const String LOGIN = "false";
const int VIRTUAL_WALLET = 150;

//Driver Hive Constants
const String DRIVER_FIRSTNAME = "fnm";
const String DRIVER_LASTNAME = "lnm";
const String DRIVER_EMAIL = "email";
const String DRIVER_MOBILE = "mobile";
const String DRIVER_GENDER = "male";
String TRIP_ID = "";

//Error Messages
const String ERRORTEXT = "Please make sure all the fields are completed";
const String LOGIN_ERRORTEXT = "Incorrect email or pin";

//MAPS API KEY
String MAPS_KEY = "";

//Announcement Details
const String ANNOUNCEMENT = "";
const String AUTHOR = "Admin";
const String NOTIFIED = "n";

//Map Constants
var placeDirection = DirectionDetails();
Marker busMarker;
Uint8List imageData;
Uint8List LocationData;

//Flutterwave Constants
int amount = 3;
String secretKeyFLutterWave = "";

//Map variables
LatLngBounds latLngBounds;

//Position of the bus on the map
LatLng busPosition = LatLng(5.57688,-0.28334);

//Map Constants
bool newScreen = false;
DirectionDetails bus_pickUp_details;
GoogleMapController controller;
Set<Marker> markersSet = {};
Set<Circle> circleSet = {};
List<LatLng> pLineCordinates = [];
Set<Polyline> polyLineSet = {};

//Bus details
List listBuses;
String busNumber = "GA-8898-21";
String busId = "1";
String driverRatings = "Very Good";
String busStatus = "Available";
int busSeatOccupied = 0;
int busCapacity = 10;
bool busAtPickUp = false;


//Route details
String routeId = "1";
String route_start_location ="5.578898258509076, -0.18507248755001868";
String route_end_location= "5.76040329174269, -0.21992320289265815";
String route_encoded_points ="";
List listRoutes = [];
List userListBus = [];
String userId = "2";
String userTripId = "";
String userStaffTripId = "";
int userTripListID = 0;

//Wallet Constants
String walletAmountToPay = "";
List transaction = [];

//Other map Constants
bool routeObtained = false;
bool chooseOnMap = false;
bool confirmRide = false;
bool startTrip = false;
bool codeScanned = false;
String pickUpAddress = "";
LatLng pickUpLocation = LatLng(0,0);
String dropOffAddress = "Ashesi University";
LatLng dropOffLocation = LatLng(5.760520712974733, -0.21990174522088365);


//Colors constant
Color wineBackgroundColor = Color(0xff853D3D);


//MAP ROUTES
Address START_LOCATION = Address();
Address END_LOCATION = Address();
const String LOCATION_LAT = "";
const String LOCATION_LNG = "";
const String DESTINATION_LAT = "";
const String DESTINATION_LNG = "";
const String DESTINATION = "Ashesi University";



//Driver Details
const String DRIVER_ID = "";
const String DRIVER_LOGIN = "false";
String Driver_id = "";
String driverBus = "20";
String driverBusNumber = "GT-9965-20";
String driverMobile = "0559418732";
String driverAddress = "";
LatLng driverLocation = LatLng(5.5751017948673205, -0.28277586498131496);

//Route details
String driverBusRoute = "1";
String routeEncodedPoint = "";
LatLng routeStartLocation = LatLng(5.5751017948673205, -0.28277586498131496);
LatLng routeEndLocation = LatLng(5.5751017948673205, -0.28277586498131496);
List<LatLng> DriverPickUpLocations = [];
List<LatLng> DriverDropOffLocations = [];

//Onboarding List
List onboardingList = [
  ['Lorem some thing',"assets/icons/location1.png",
    "Lorem ipsum dolor sit amet, consectetur "
        "adipiscing elit, sed do eiusmod tempor incididunt ut labore et "
        "dolore magna aliqua. Ut enim ad minim veniam, quis nostrud"
  ],
  ['Lorem some body ', "assets/icons/location.png",
    "Lorem ipsum dolor sit amet, consectetur "
        "adipiscing elit, sed do eiusmod tempor incididunt ut labore et "
        "dolore magna aliqua. Ut enim ad minim veniam, quis nostrud"
  ],
  ['Lorem some one ', "assets/icons/location2.png",
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod "
        "tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim "
        "veniam, quis nostrud"
  ],
];

//Help Lists
List helpList = [
  "1. Stay in an airy room away from other people such as family "
      "members preferably with separate bathroom and toilet "
      "facilities. If you share the same bathroom and toilet ",
  "2. Always wash your hands with soap and water regularly "
      "or use an alcohol-based hand rub/sanitizer",
  "3. Cover your nose and mouth with a single use tissue when "
      "coughing and sneezing. Throw away used tissue immediately into a "
      "dustbin and wash your hands immediately with soap and water or an "
      "alcohol-based hand rub.",
  "4. Clean and disinfect frequently touched surfaces such as "
      "doorknobs/handles, bedside tables, bedframes, and other bedroom "
      "furniture daily with regular household disinfectant"

];
