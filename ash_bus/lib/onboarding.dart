import 'package:ash_bus/main.dart';
import 'package:ash_bus/models/constants.dart';
import 'package:ash_bus/widgets/buttons.dart';
import 'package:flutter/material.dart';

//This is the onborading page
class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: OnBoarding(onBoardList: onboardingList,),
      ),
    );
  }
}

class Dot extends StatefulWidget {
  final bool active;
  const Dot({Key key, this.active}) : super(key: key);

  @override
  _DotState createState() => _DotState();
}

//This the dot widget
class _DotState extends State<Dot> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      margin: EdgeInsets.only(left: 7),
      width: 8,
      decoration: BoxDecoration(
          color: widget.active == true ? Color(0xff66BB6A):Color(0xffC4C4C4),
          shape: BoxShape.circle
      ),
    );
  }
}

//This is the dot row widget
class DotRow extends StatefulWidget {
  final int position;
  const DotRow({Key key, this.position}) : super(key: key);

  @override
  _DotRowState createState() => _DotRowState();
}

class _DotRowState extends State<DotRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Dot(active: widget.position == 1 ? true : false),
          Dot(active: widget.position == 2 ? true : false),
          Dot(active: widget.position == 3 ? true : false),
        ],
      ),
    );
  }
}

//
class OnBoarding extends StatefulWidget {
  final List onBoardList;
  const OnBoarding({Key key, this.onBoardList}) : super(key: key);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {

  int position;

  @override
  void initState() {
    // TODO: implement initState
    position = 1;
  }

  //Move to next screen
  nextScreen(){
    setState(() {
      if(position < 3){
        position += 1;
      }
    });
  }

  //Open driver login page
  openDriver(){
   navigatorKey.currentState.pushNamed("/driver");
  }

  //Open staff login page
  openStaff(){
    navigatorKey.currentState.pushNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Positioned(
          top: height * 0.15,
          width: width,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.085),
            child: Column(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    widget.onBoardList[position - 1][1],
                    height: height * 0.3,
                  ),
                ),

                SizedBox(height: height * 0.035,),

                Text(
                  widget.onBoardList[position - 1][0],
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 19
                  ),
                ),

                SizedBox(height: height * 0.015,),

                Text(
                  widget.onBoardList[position - 1][2],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15
                  ),
                ),

                SizedBox(height: height * 0.025,),

                DotRow(position: position,)

              ],
            ),
          ),
        ),

        Positioned(
          bottom: height * 0.05,
          width: width,
          child: Container(
            width: width,
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: position != 3 ? RedBtn(
              name: "NEXT",
              action: nextScreen,
              onboarding: true,
            ):
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RedBtn(
                      name: "Driver",
                      action: openDriver,
                      onboarding: true,
                      width: width * 0.375,
                    ),
                    RedBtn(
                      name: "Staff & Faculty",
                      action: openStaff,
                      width: width * 0.375,
                      border: true,
                    )
                  ],
                ),
          ),
        )
      ],
    );
  }
}
