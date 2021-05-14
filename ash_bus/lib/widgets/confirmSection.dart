//This is the confirm section widget
import 'package:ash_bus/widgets/buttons.dart';
import 'package:flutter/material.dart';

class ConfirmSection extends StatefulWidget {
  final Function action;

  const ConfirmSection({Key key, this.action}) : super(key: key);
  @override
  _ConfirmSectionState createState() => _ConfirmSectionState();
}

class _ConfirmSectionState extends State<ConfirmSection> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: 60,),
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            width: width * 0.4,
            height: width * 0.4,
            decoration: BoxDecoration(
                color: Color(0xff66BB6A),
                shape: BoxShape.circle
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: width * 0.2,
            ),
          ),
          Text(
            'Transaction was\n successful!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16
            ),
          ),
          SizedBox(height: 150,),
          RedBtn(name: "FINISH",action: widget.action,)
        ],
      ),
    );
  }
}
