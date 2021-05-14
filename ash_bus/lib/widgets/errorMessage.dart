//This is the error message widget
import 'package:flutter/material.dart';

class ErrorMessage extends StatefulWidget {
  final String message;

  const ErrorMessage({Key key, this.message}) : super(key: key);
  @override
  _ErrorMessageState createState() => _ErrorMessageState();
}

class _ErrorMessageState extends State<ErrorMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.red
              ),
            ),
          )
        ],
      ),
    );
  }
}

