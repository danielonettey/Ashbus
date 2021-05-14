//This is the transaction history tile

import 'package:flutter/material.dart';

class TransHistTile extends StatefulWidget {
  final String date;
  final String amount;
  final String time;

  const TransHistTile({Key key, this.date, this.amount, this.time}) : super(key: key);

  @override
  _TransHistTileState createState() => _TransHistTileState();
}

class _TransHistTileState extends State<TransHistTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: ()=>{},
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Account top up ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),),
                          SizedBox(height: 2,),
                          Text("${widget.date} - ${widget.time} ", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),),
                        ],
                      ),

                      Text("${widget.amount}.00 ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17),),
                    ],
                  ),
                ),
                Divider(color: Colors.black12, height: 2,thickness: 1,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}