//This is the main drawer widget of the application

import 'package:ash_bus/widgets/profileTab.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../main.dart';
import 'DrawerListTab.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {

  nextPage(String route){
    Navigator.pop(context);
    //Screen is not on google maps
    Constants.newScreen = true;

    //Disable choose on map option
    Constants.chooseOnMap = false;
    navigatorKey.currentState.pushNamed(route);
  }


  //Drawer List
  Map<String, List> drawerlist = {
    'Wallet': [Icons.payment, "/payment"],
    'Change Pin': [Icons.lock, "/change pin"],
//    'Support': [Icons.message, "/support"],
    'About': [Icons.info_outline,"/about"],
    'Help': [Icons.help_outline, "/help"],
    'Logout': [Icons.power_settings_new, "/"]
  };
  

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(top: height * 0.05, left: width * 0.05, right: width * 0.05),
      color: Colors.white,
      width: width * 0.75,
      child: Stack(
        children: <Widget>[
          //Upper part of sidebar
          Container(
            child: Column(
              children: <Widget>[
                //Profile Tab
                ProfileTab(name: "${Hive.box(Constants.MAINBOX).get(Constants.FIRSTNAME)} ${Hive.box(Constants.MAINBOX).get(Constants.LASTNAME)}",),
                //Divider
                Divider(
                  color: Color(0xffBDBDBD),
                  height: 5,
                ),
                //Drawer Lists
                Column(
                  children: drawerlist.entries.map((tab) => DrawerListTab(
                    name: tab.key,
                    icon: tab.value[0],
                    action: () {
                      if(tab.key == "Logout"){
                        Hive.box(Constants.MAINBOX).put(Constants.LOGIN, "false");
                      }
                      nextPage(tab.value[1]);
                    },
                  )).toList(),
                ),
              ],
            ),
          ),

          //Lower part of sidebar
          Positioned(
            bottom: 20,
            width: width * 0.65,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff853D3D),
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              padding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: width * 0.035),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.037,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      Text(
                        'Click here to login as a driver',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.032,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
