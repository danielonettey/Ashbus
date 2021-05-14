import 'package:flutter/material.dart';

//This is the pin textfield widget

class PinTextField extends StatefulWidget {
  final TextEditingController controller;

  const PinTextField({Key key, this.controller}) : super(key: key);
  @override
  _PinTextFieldState createState() => _PinTextFieldState();
}

class _PinTextFieldState extends State<PinTextField> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.5,
      child: TextFormField(
        showCursor: false,
        readOnly: true,
        controller: widget.controller,
        maxLength: 4,
        keyboardType: TextInputType.number,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border:  InputBorder.none,
          filled: true,
          fillColor: Color(0xffF6F6F6),
        ),
      ),
    );
  }
}


class PinInfoText extends StatefulWidget {
  @override
  _PinInfoTextState createState() => _PinInfoTextState();
}

class _PinInfoTextState extends State<PinInfoText> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "Enter your 4 digit pin to\n confirm transaction",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.black,
            fontSize: 14.5,
            fontWeight: FontWeight.w600
        ),
      ),
    );
  }
}