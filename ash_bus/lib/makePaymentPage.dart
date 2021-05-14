import 'package:ash_bus/widgets/backBtn.dart';
import 'package:ash_bus/widgets/confirmSection.dart';
import 'package:ash_bus/widgets/nfcSection.dart';
import 'package:ash_bus/widgets/paymentPinSection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//This is the make payment page

class MakePaymentPage extends StatefulWidget {
  final double amount;

  const MakePaymentPage({Key key, this.amount}) : super(key: key);
  @override
  _MakePaymentPageState createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  int intialStep = 1;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    //Move to next activity
    nextStep(){
      setState(() {
        //Leave page when done
        intialStep < 3 ?
          intialStep+=1
         : Navigator.pop(context);
      });
    }

    //Get color for stepper per section
    Color getColor(int step){
      return intialStep > step ? Color(0xff66BB6A): Color(0xffC4C4C4);
    }

    //Stepper at the upper part of page
    Widget Stepper(String title, Color color){
      return Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle
              ),
            ),
            SizedBox(height: 7.5),
            Text(
              "$title",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600
              ),
            )
          ],
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,

        //Back arrow
        leading: BackBtn(),
        title: Text(
          'Make Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600

          ),
        ),
        actions: <Widget>[
          //Price
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 10),
            child: Text(
              "₵${widget.amount.toStringAsFixed(2)}",
              style: TextStyle(
                color: Color(0xffB71500),
                fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        ],
      ),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        color: Colors.white,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20,),
              Container(
                width: width * 0.8,
                height: 55,
                child: Stack(
                  children: <Widget>[

                    //Line Steppers
                    Positioned(
                      left: 7,
                      top: 10,
                      child: Container(
                        width: width * 0.35,
                        height: 2,
                        color: getColor(1),
                      ),
                    ),
                    Positioned(
                      right: 17,
                      top: 10,
                      child: Container(
                        width: width * 0.35,
                        height: 2,
                        color: getColor(2),
                      ),
                    ),

                    //Round Steppers
                    Positioned(
                      left: 0,
                      child: Stepper("NFC",getColor(0)),
                    ),
                    Positioned(
                      left: width * 0.35,
                      child: Stepper("Pin", getColor(1)),
                    ),
                    Positioned(
                      right: 0,
                      child: Stepper("Status", getColor(2)),
                    ),

                  ],
                ),
              ),
              SizedBox(height: 10,),

              //Steps
              intialStep == 1?
              NFCSection(action: nextStep):
              intialStep == 2?
              PaymentPinSection(action: nextStep,):
              ConfirmSection(action: nextStep),

            ],
          ),
        ),
      ),
    );
  }
}



