import 'package:ash_bus/models/http.dart';
import 'package:ash_bus/widgets/buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:ash_bus/models/constants.dart' as Constants;
import 'driverPage.dart';
import 'main.dart';

//This is the driver welcome page

class DriverWelcomePage extends StatefulWidget {
  final Key _mapKey = UniqueKey();

  @override
  _DriverWelcomePageState createState() => _DriverWelcomePageState();
}

class _DriverWelcomePageState extends State<DriverWelcomePage> {
  String _selectedBus = "";
  String _selectedRoute = "";
  String errorText = "";
  Map listRoutes;

  //Start the trip and update the database
  startTrip() {
    if (_selectedBus != "" && _selectedRoute != "" ){
      setState(() {
        Constants.driverBus = _selectedBus;
        Constants.driverBusRoute = _selectedRoute;
        errorText = "";
      });

      //Save Bus Details
      Map busDetails = Constants.listBuses[int.parse(Constants.driverBus) - 1];
      Constants.busSeatOccupied = busDetails["seats_occupied"];
      Constants.busCapacity = busDetails["capacity"];
      Constants.driverBusNumber = busDetails["bus_number"];

      //Save the route details
      Map routeDetails = Constants.listRoutes[int.parse(Constants.driverBusRoute) - 1];
      String start_location = routeDetails["start_location"]; //Location Details
      String end_location = routeDetails["end_location"];
      List start_location_list = start_location.split(",");
      List end_location_list = end_location.split(",");
      Constants.routeStartLocation = LatLng(double.parse(start_location_list[0].toString().trim()), double.parse(start_location_list[1].toString().trim()));
      Constants.routeEndLocation = LatLng(double.parse(end_location_list[0].toString().trim()), double.parse(end_location_list[1].toString().trim()));
      Constants.routeEncodedPoint = routeDetails["route"];

      //Update Bus Route
      DriverUpdateBusRoute(Constants.driverBusNumber, Constants.driverBusRoute);
      //Create Trip
      DriverCreateTrip("${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}", Constants.driverBus.toString(), Hive.box(Constants.MAINBOX).get(Constants.DRIVER_ID).toString());

      //Clear the drop off and pick up locations
      Constants.DriverPickUpLocations.clear();
      Constants.DriverDropOffLocations.clear();

      //Move to driver trip page
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DriverPage(key: widget._mapKey,)),
      );
    }
    else{
      setState(() {
        errorText = "Please select the route and bus before starting a trip";
      });
    }
  }

  //Log out
  logout(){
    navigatorKey.currentState.pushNamed("/driver");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Constants.wineBackgroundColor,
            title: Text(
              "Driver - AshBus",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: Container(
            width: width,
            height: height,
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox( height: width * 0.025, ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("Welcome, ", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                      Text("${Hive.box(Constants.MAINBOX).get(Constants.DRIVER_FIRSTNAME)} ${Hive.box(Constants.MAINBOX).get(Constants.DRIVER_LASTNAME)}!",
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text("You can fill in the details below and start your trip. Do not forget to follow all safety protocols.", style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 20,),
                  Text("Please select your bus", style: TextStyle(fontWeight: FontWeight.w600, color: Constants.wineBackgroundColor)),
                  SizedBox(height: 10,),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: Constants.listBuses.map((bus)=> Container(
                        child: Row(
                          children: <Widget>[
                            Radio(
                              value: bus['id'].toString(),
                              groupValue: _selectedBus,
                              onChanged: (value) {
                                setState(() {
                                  _selectedBus = value;
                                });
                              },
                            ),
                            Text('${bus['bus_number']}')
                          ],
                        ),
                      )).toList()
                  ),
                  SizedBox(height: 20,),
                  //Select Route
                  Text("Please select your route", style: TextStyle(fontWeight: FontWeight.w600, color: Constants.wineBackgroundColor)),
                  SizedBox(height: 10,),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: Constants.listRoutes.map((route)=> Container(
                        child: Row(
                          children: <Widget>[
                            Radio(
                              value: route["id"].toString(),
                              groupValue: _selectedRoute,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoute = value;
                                });
                              },
                            ),
                            Text('${route["start_address"]} - ${route["end_address"]}')
                          ],
                        ),
                      )).toList()
                  ),
                  SizedBox(height: 10,),
                  Text("$errorText", style: TextStyle(fontWeight: FontWeight.w600, color: Constants.wineBackgroundColor)),
                  SizedBox(height: 10,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RedBtn(action: startTrip,name: "Start",onboarding: true,),
                      ),
                      SizedBox (width: width * 0.05,),
                      Expanded(
                        child: RedBtn(action: logout, name: "Logout",),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}
