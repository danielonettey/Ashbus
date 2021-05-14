//This is the order bus sheet section widget
import 'package:ash_bus/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

class OrderBusSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            DraggingHandle(),
            OrderBusItemGrid(),
            SizedBox(height: 15,),
            OrderBusItemInfo(toCampus: true,),
            OrderBusItemInfo(),
            SizedBox(height: 20,),
            Container(
              width: width,
              height: height * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Announcements',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                          fontSize: 14
                        ),
                      ),
                    ),
                    SizedBox(height: 7.5,),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        Hive.box(Constants.MAINBOX).get(Constants.ANNOUNCEMENT) !=null ? Hive.box(Constants.MAINBOX).get(Constants.ANNOUNCEMENT).toString(): "",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                          fontSize: 12
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
  }
}

class DraggingHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      height: 5,
      width: 100,
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16)
      ),
    );
  }
}

class OrderBusItemGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
        //to avoid scrolling conflict with the dragging sheet
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 20,
        shrinkWrap: true,
        children: <Widget>[
          OrderBusItem(toCampus: true,),
          OrderBusItem(),
        ],
      ),
    );
  }
}

class OrderBusItem extends StatelessWidget {
  final bool toCampus;
  const OrderBusItem({Key key, this.toCampus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: this.toCampus == true ?(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          } : () async{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage(toCampus: true,)),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Color(0xffF6F6F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  this.toCampus == true ? "assets/icons/toBus_icon.png" : "assets/icons/fromBus_icon.png",
                  width: 80,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    this.toCampus == true ? "TO" : "FROM",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ),
                Text(
                  'Campus',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15
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

class OrderBusItemInfo extends StatelessWidget {
  final bool toCampus;
  const OrderBusItemInfo({Key key, this.toCampus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      margin: EdgeInsets.only(top: 10),
      child: Row(
        children: <Widget>[
          Image.asset(
            toCampus == true ? "assets/icons/toBus_icon.png" : "assets/icons/fromBus_icon.png",
            width: 35,
          ),
          Container(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              toCampus == true ? ': From on-campus to off-campus' : ': From off-campus to on-campus',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500
              ),
            ),
          )
        ],
      ),
    );
  }
}
