//This is the back button widget
import 'package:flutter/material.dart';

class BackBtn extends StatefulWidget {
  @override
  _BackBtnState createState() => _BackBtnState();
}

class _BackBtnState extends State<BackBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 3,
            offset: Offset(0, 2),
          )],
      ),
      child: ClipOval(
        child: Material(
          color: Color(0xffF6F6F6),
          child: InkWell(
            child: Container(
              child: Icon(
                Icons.arrow_back,
                color: Color(0xffB71500),
              ),
            ),
            onTap: (){
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
