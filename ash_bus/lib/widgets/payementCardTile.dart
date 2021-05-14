//This is the payment card tile widget
import 'package:ash_bus/models/constants.dart';
import 'package:ash_bus/models/http.dart';
import 'package:ash_bus/widgets/webViewPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

class PaymentCardTile extends StatefulWidget {
final String number;
final bool momo;
const PaymentCardTile({Key key, this.number, this.momo}) : super(key: key);

@override
_PaymentCardTileState createState() => _PaymentCardTileState();
}

class _PaymentCardTileState extends State<PaymentCardTile> {

  final phone = TextEditingController();
  final amount = TextEditingController();
  final network = TextEditingController();

  //Open the web view to confirm OTP verification
  openWebView() async{
        String otp_url = await makeMomoPayment(amount.text,phone.text,network.text);
        Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewPage(url: otp_url,)),
    );
  }

  //Open modal to edit card details before payment
  openCard()  {
    phone.text = Hive.box(MAINBOX).get(Constants.DRIVER_MOBILE);
    amount.text = "3";
    network.text = "Vodafone";

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: wineBackgroundColor,
                    ),
                  ),
                ),
                Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: phone,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                            labelText: "Phone Number"
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: amount,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              labelText: "Amount",

                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          controller: network,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                              labelText: "Network"
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: wineBackgroundColor,
                          child: Text("Make Payment", style: TextStyle(color: Colors.white),),
                          onPressed: () {
                            Constants.walletAmountToPay = amount.text;

                            openWebView();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: widget.momo == true ? (){

          } : openCard,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: <Widget>[
                Icon(widget.momo == true ? Icons.add_circle: Icons.payment, size: 27,),
                SizedBox(width: 7.5,),
                Text(widget.momo == true ? "Add Card":"Mobile Money - ${Hive.box(Constants.MAINBOX).get(Constants.DRIVER_MOBILE)}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}