//This is the NFC widget
import 'package:flutter/material.dart';

class NFCSection extends StatefulWidget {
  final Function action;

  const NFCSection({Key key, this.action}) : super(key: key);
  @override
  _NFCSectionState createState() => _NFCSectionState();
}

class _NFCSectionState extends State<NFCSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NFCPartText(),
        NFCPart(action: widget.action,),
      ],
    );
  }
}

class NFCPart extends StatefulWidget {
  final Function action;
  const NFCPart({Key key, this.action}) : super(key: key);

  @override
  _NFCPartState createState() => _NFCPartState();
}

class _NFCPartState extends State<NFCPart> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: widget.action,
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xffB71500),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                )],
            ),
            padding: EdgeInsets.all(width * 0.15),
            width: width * 0.575,
            child: Image.asset("assets/icons/cursor.png"),
          ),
        ),
      ),
    );
  }
}

class NFCPartText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Text(
        "Please put your phone against the\n NFC tag installed in the bus\n to start the payment\n process",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16
        ),
      ),
    );
  }
}