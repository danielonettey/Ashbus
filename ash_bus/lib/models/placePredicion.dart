//This is the place prediction class
class PlacePrediction{
  String secondary_text;
  String place_id;
  String main_text;

  PlacePrediction({this.secondary_text, this.main_text, this.place_id});

  PlacePrediction.fromJson(Map<String,dynamic> json){
    secondary_text = json["structured_formatting"]["secondary_text"];
    place_id = json["place_id"];
    main_text = json["structured_formatting"]["main_text"];
  }
}