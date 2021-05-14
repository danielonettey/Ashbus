//This is the buttons widget
import 'package:flutter/material.dart';

class RedBtn extends StatefulWidget {
  final String name;
  final Function action;
  final bool onboarding;
  final double width;
  final bool border;
  final bool disabled;

  const RedBtn({Key key, this.name, this.action, this.onboarding, this.width, this.border, this.disabled}) : super(key: key);

  @override
  _RedBtnState createState() => _RedBtnState();
}

class _RedBtnState extends State<RedBtn> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: widget.width == null ? width * 0.75 : widget.width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.disabled == true ? null : widget.action,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.name == "SAVE" || widget.disabled == true ?  Color(0xffcccccc) : widget.onboarding == true ? Color(0xff66BB6A): widget.border == true ? Colors.white: Color(0xffB71500),
              border: widget.border == true ? Border.all(
                color: Color(0xff66BB6A),
                width: 2
              ) : null
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              widget.name,
              style: TextStyle(
                  decorationStyle: TextDecorationStyle.wavy,
                  fontSize: 17,
                  fontWeight: widget.border == true ? FontWeight.w600 : FontWeight.w500,
                  color: widget.border == true ? Color(0xff66BB6A) : Colors.white
              ),
            ),
          ),
        ),
      ),
    );
  }
}