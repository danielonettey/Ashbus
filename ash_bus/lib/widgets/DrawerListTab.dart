import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//This is a widget for a list in the drawer on the homepage

class DrawerListTab extends StatefulWidget {
  final String name;
  final IconData icon;
  final Function action;


  const DrawerListTab({Key key, this.name, this.icon, this.action}) : super(key: key);

  @override
  _DrawerListTabState createState() => _DrawerListTabState();
}

class _DrawerListTabState extends State<DrawerListTab> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: widget.action,
          child: Container(
            padding: EdgeInsets.only(left: 12.5, top: 10, bottom: 10),
            child: Row(
              children: <Widget>[
                Icon(
                  widget.icon,
                  color: Color(0xff707070),
                  size: 25,
                ),
                Container(
                  margin: EdgeInsets.only(left: width * 0.025),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
