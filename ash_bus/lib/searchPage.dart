import 'package:ash_bus/models/address.dart';
import 'package:ash_bus/models/http.dart';
import 'package:ash_bus/models/placePredicion.dart';
import 'package:ash_bus/widgets/backBtn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

//This is search page
class SearchPage extends StatefulWidget {
  final bool toCampus;
  const SearchPage({Key key, this.toCampus}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  //Start and end location controllers
  TextEditingController startLocation = TextEditingController();
  TextEditingController destination = TextEditingController();
  List<PlacePrediction> placePredictionList = [];
  bool disableChooseOnMap = false;

  //Autocomplete for places
  void findPlace(String place_name) async{
    if(place_name.length > 1) {
      String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$place_name&key=${Constants.MAPS_KEY}&sessiontoken=1234567890&components=country:gh";
      var response = await getRequestAddress(url);
      if (response == "Failed") {
        return;
      }
      if (response["status"] == "OK"){
        var predictions = response["predictions"];
        var placesList = (predictions as List).map((e) => PlacePrediction.fromJson(e)).toList();
        setState(() {
          placePredictionList = placesList;
        });

        print("Working here to make sure it is working $placesList");
      }
    }
  }


  // Get the place address details from predications
  void getPlaceAddress(String place_id) async{
    String placeAddressurl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$place_id&key=${Constants.MAPS_KEY}";
    var response = await getRequestAddress(placeAddressurl);
    if (response == "Failed") {
      return;
    }

    //Check if it was successful
    if (response["status"] == "OK"){
      Address address = Address();
      address.placeName = response["result"]["name"];
      address.placeID = place_id;
      address.longitude = response["result"]["geometry"]["location"]["lng"];
      address.latitude = response["result"]["geometry"]["location"]["lat"];
      Constants.END_LOCATION = address;
      Navigator.pop(context);
    }
  }

  //Location widget for search page
  Widget LocationTextField(TextEditingController controller, bool destination){
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          destination == true ? Container(
            width: 30,
            child: Icon(
              Icons.location_on,
              color: Color(0xffB71500),
            ),
          ) : Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 10,
            width: 10,
            decoration: BoxDecoration(
                color: Color(0xff66BB6A),
                shape: BoxShape.circle
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (val){
                findPlace(val);
              },
              onTap: (){
                //Disable show on map functionality for destinations
                setState(() {
                  destination == false ?
                    disableChooseOnMap = false
                  :
                    disableChooseOnMap = true;
                });
              },
              style: TextStyle(
                  fontSize: 13
              ),
              decoration: InputDecoration(
                  hintText: "Enter ${destination == true ? "Destination" : "Location"}",
                  filled: true,
                  fillColor: Color(0xffF6F6F6),
                  border: InputBorder.none
              ),
            ),
          )
        ],
      ),
    );
  }

  //Prediction tiles widget for search page
  Widget PredictionTiles(PlacePrediction placePrediction){
    return Material(
      child: InkWell(
        onTap: (){
          getPlaceAddress(placePrediction.place_id);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(placePrediction.main_text != null ? placePrediction.main_text: "", overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
              SizedBox(height: 5,),
              Text(placePrediction.secondary_text != null ? placePrediction.secondary_text: "", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12),)
            ],
          ),
        ),
      ),
    );
  }

  void chooseOnMap(){
    Constants.chooseOnMap = true;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    //Initial values
    if (widget.toCampus == true){
      startLocation.text = "Ashesi University";
    }
    else{
      destination.text = "Ashesi University";
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 20,
          leading: BackBtn(),
          title: Text(
            'Set Location',
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600
            ),
          ),
        ),
        body: Container(
          height: height,
          color: Colors.white,
          width: width,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(width * 0.05),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                LocationTextField(startLocation,false),
                                SizedBox(height: 10,),
                                LocationTextField(destination, true,),
                              ],
                            ),
                            Positioned(
                              top: 29,
                              left: 14,
                              child: Container(
                                height: 43,
                                width: 2,
                                color: Color(0xffC4C4C4),
                              ),
                            )
                          ],
                        ),
                      ),
                      placePredictionList.length > 0 ?
                      Container(
                        color: Colors.white,
                        height: height * 0.5,
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ListView.separated(
                          itemBuilder: (content,index){
                            return PredictionTiles(placePredictionList[index]);
                          },
                          separatorBuilder: (BuildContext context, int index ) => Container(
                            height: 1,
                            width: double.infinity,
                            color: Color(0xffBDBDBD),
                          ),
                          itemCount: placePredictionList.length,
                          physics: ClampingScrollPhysics(),
                        ),
                      ) :Container()
                    ],
                  ),
                ),
              ),

              //Choose on map button
              disableChooseOnMap ? Container() :
              Positioned(
                bottom: 0,
                width: width,
                child: Material(
                  child: InkWell(
                    onTap: chooseOnMap,
                    child: Container(
                      color: Color(0xffB71500),
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(CupertinoIcons.location_solid, color: Colors.white,),
                          SizedBox(width: 3,),
                          Text("Choose on map", style: TextStyle(color: Colors.white),)
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
    );
  }
}