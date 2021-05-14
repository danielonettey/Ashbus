//This is the bus details widget

import 'package:ash_bus/models/constants.dart' as Constants;
import 'package:ash_bus/models/http.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusDetails extends StatefulWidget {
  final String busNumber;
  final String busCondition;
  final String busStatus;
  final String duration;
  final String amount;
  final int seatsAvailable;

  const BusDetails({Key key, this.busNumber, this.busCondition, this.busStatus, this.duration, this.amount, this.seatsAvailable}) : super(key: key);

  @override
  _BusDetailsState createState() => _BusDetailsState();
}

class _BusDetailsState extends State<BusDetails> {
  Color inactiveColor = Colors.black45;

  void chooseRide(){
      Constants.confirmRide = true;
      setCameraBounds(Constants.pickUpLocation, Constants.busPosition);

      //Animate camera to show the buses available on the map
      Constants.controller.animateCamera(
          CameraUpdate.newLatLngBounds(Constants.latLngBounds, 100)
      );
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: widget.busStatus != "Available" ? null: chooseRide,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset("assets/icons/fromBus_icon.png",width: width * 0.15,),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${widget.busNumber}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700 , color: widget.busStatus != "Available" ? inactiveColor: Colors.black),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.time_to_leave, color: Colors.black45, size: 15, ),
                          SizedBox(width: 3,),
                          Text("${widget.duration}", style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),),
                          SizedBox(width: 5,),
                          Icon(Icons.payment, color: Colors.black45, size: 15, ),
                          SizedBox(width: 3,),
                          Text("${widget.amount}", style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),),

                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text("${widget.busStatus}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.busStatus != "Available" ? inactiveColor: Colors.green),),
                          Text(" || ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black45),),
                          Text("${widget.busCondition}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.busStatus != "Available" ? inactiveColor: Colors.green),),
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
                      "${widget.seatsAvailable}" ,
                      style: TextStyle(fontSize: 20, color: widget.busStatus != "Available" ? inactiveColor: Colors.black, fontWeight: FontWeight.w700)
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
}