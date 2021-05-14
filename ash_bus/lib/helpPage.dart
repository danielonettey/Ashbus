import 'package:ash_bus/widgets/backBtn.dart';
import 'package:flutter/material.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

// THis is the help page

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackBtn(),
        centerTitle: true,
        title: Text(
          'Help',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: Container(
        width: width,
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20,),
            Column(
              children: Constants.helpList.map((helpInfo)=>Container(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  helpInfo,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500
                  ),
                ),
              )).toList()
            ),
          ],
        ),
      ),
    );
  }
}