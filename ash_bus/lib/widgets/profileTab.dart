import 'package:ash_bus/main.dart';
import 'package:flutter/material.dart';

//This is the profile tab for the drawer on the homepage

class ProfileTab extends StatefulWidget {
  final String name;

  const ProfileTab({Key key, this.name}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 15, top: 15),
      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: (){
            Navigator.pop(context);
            navigatorKey.currentState.pushNamed("/profile");
          },
          child: Row(
            children: <Widget>[
              Container(
                child: Image.asset(
                  "assets/icons/profile.png",
                  width: 55,
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: width * 0.025),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Text(
                      widget.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17
                      ),
                    ),

                    Text(
                      'View Profile',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
