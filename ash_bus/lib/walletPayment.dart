import 'package:ash_bus/widgets/payementCardTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';import 'package:ash_bus/models/constants.dart' as Constants;
import 'package:hive/hive.dart';
import 'widgets/transactionHistoryTiles.dart';

//This is the main wallet page

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Account"),
          centerTitle: true,
          backgroundColor: Constants.wineBackgroundColor,
        ),
        body: Container(
          height: height,
          width: width,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  color: Constants.wineBackgroundColor,
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("GH₵", style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w500),),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(Hive.box(Constants.MAINBOX).get(Constants.VIRTUAL_WALLET) == null? "0": "${Hive.box(Constants.MAINBOX).get(Constants.VIRTUAL_WALLET)}",style: TextStyle(fontSize: 50,color: Colors.white, fontWeight: FontWeight.w600),),
                                Text(".00",style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.w500),),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height: 160,
                        width: double.infinity,
                        padding: EdgeInsets.all(width * 0.035),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            PaymentHeaderText(title: "Top up using",),

                            SizedBox(height: width * 0.035,),
                            Divider(height: 2,color: Colors.grey,thickness: 1.2,),
                            PaymentCardTile(),
                            PaymentCardTile(momo: true,),

                          ],
                        ),

                      ),
                      SizedBox(height: 20,)
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(width * 0.05),
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      PaymentHeaderText(title: "Transaction History",),

                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.from(Constants.transaction.reversed).map((hist)=> TransHistTile(
                            amount: hist["amount"],
                            date: hist["date"],
                            time: hist["time"],
                          )).toList()
                      ),

                    ],
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}

//This is the payment header text widget
class PaymentHeaderText extends StatelessWidget {
  final String title;
  const PaymentHeaderText({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      this.title, style: TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.w700),
    );
  }
}


