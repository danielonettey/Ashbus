import 'package:ash_bus/widgets/buttons.dart';
import 'package:ash_bus/widgets/pinTextFields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//This is the payment pin section
class PaymentPinSection extends StatefulWidget {
  final Function action;

  const PaymentPinSection({Key key, this.action}) : super(key: key);
  @override
  _PaymentPinSectionState createState() => _PaymentPinSectionState();
}

class _PaymentPinSectionState extends State<PaymentPinSection> {
  final myController = TextEditingController();
  String pin = "";

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    //List of keys
    var keys = new List<String>.generate(9, (i) => "${i + 1}");
    keys.add(""); //Non visible key
    keys.add("0");
    keys.add("-1"); // backspace key

    //Individual key
    Widget CustomKey(String number){
      return Container(
        width:  width * 0.25,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (){
              //Add keys
              if(number != "" && number != "-1"){
                setState(() {
                  if(pin.length <4){
                    pin += number;
                    myController.text = pin;
                  }
                });
              }

              //Delete keys
              else if (number == "-1" ){
                setState(() {
                  pin = pin.substring(0,pin.length - 1);
                  myController.text = pin;
                });
              }
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: number != "" ? number != "-1" ? Color(0xffFCFCFC): Color(0xffB71500) :  Colors.transparent,
                boxShadow: number != "" ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  )] : [],
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.all( number != "-1" ?  width * 0.04 : width * 0.055),
              child: number != "-1" ? Text(
                number,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: width * 0.075
                ),
              ) :
              Icon(
                Icons.backspace,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //Enter Pin information
          PinInfoText(),
          SizedBox(height: 10,),

          //Pin TextField
          PinTextField(controller: myController,),

          //Keys
          Container(
            width: width * 0.9,
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              runAlignment: WrapAlignment.center,
              runSpacing: width * 0.05,
              children:  keys.map((number) =>
                CustomKey("$number")
              ).toList()
            ),
          ),
          SizedBox(height: 40,),
          //Next button
          RedBtn(name: "NEXT",action: widget.action,)
        ],
      ),
    );
  }
}






