import 'package:google_maps_flutter/google_maps_flutter.dart';

//This is the direction details class for the maps

class DirectionDetails{
    int distanceVal;
    int durationVal;
    String distanceText;
    String durationText;
    String encodedPoints;
    List<LatLng> pointsOnRoute;

    DirectionDetails({this.distanceText,this.distanceVal,this.durationText, this.durationVal, this.encodedPoints, this.pointsOnRoute});
}