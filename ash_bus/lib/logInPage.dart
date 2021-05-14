import 'package:ash_bus/main.dart';
import 'package:ash_bus/models/http.dart';
import 'package:ash_bus/profilePage.dart';
import 'package:ash_bus/homepage.dart';
import 'package:ash_bus/widgets/buttons.dart';
import 'package:ash_bus/widgets/errorMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

//This is the log in page for both the driver and the staff and faculty

class LoginPage extends StatefulWidget {
  final bool driver;

  const LoginPage({Key key, this.driver}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pin = TextEditingController();
  var details;
  bool login = false;
  String errorText = "";
  bool loading = false;
  bool error = false;

  //Login
  saveInfo() async {
    setState(() {
      loading = true;
    });

    //Form validation
    if (email.text.isEmpty || pin.text.isEmpty){
        setState(() {
          error = true;
          errorText = "Please make sure all the fields are completed";
          loading = false;
        });
    }
    else{
      setState(() {
        error = false;
        errorText = "";
      });

      //Check if driver login and return details
      if(widget.driver == true){
        details = await getData('http://dan3.pythonanywhere.com/driver_get/');
      }
      else{
        details = await getData('http://dan3.pythonanywhere.com/staff_get/');
      }

      //Go through details
      for(var i = 0; i < details.length; i++){
        //Check user against credentials
        if(email.text.trim() == details[i]['person']['email']){
          if(widget.driver == true){
            //Save Information locally
            Hive.box(Constants.MAINBOX).put(Constants.DRIVER_FIRSTNAME, details[i]['person']['first_name']);
            Hive.box(Constants.MAINBOX).put(Constants.DRIVER_ID, details[i]['id']);
            Constants.Driver_id = details[i]['id'].toString();
            Hive.box(Constants.MAINBOX).put(Constants.DRIVER_LASTNAME, details[i]['person']['last_name']);
            Hive.box(Constants.MAINBOX).put(Constants.DRIVER_GENDER, details[i]['person']['gender']);
            Hive.box(Constants.MAINBOX).put(Constants.DRIVER_EMAIL, details[i]['person']['email']);
            Hive.box(Constants.MAINBOX).put(Constants.DRIVER_MOBILE, details[i]['person']['mobile']);

            //Save login activity
            Hive.box(Constants.MAINBOX).put(Constants.LOGIN, "driver");
            Constants.listBuses = await getData("http://dan3.pythonanywhere.com/bus_get/");
            Constants.listRoutes = await getData("http://dan3.pythonanywhere.com/route_get/");
            navigatorKey.currentState.pushNamed('/driverWelcome');
            print("Print login");
            break;
          }
          else{
            //Save Information locally
            Hive.box(Constants.MAINBOX).put(Constants.FIRSTNAME, details[i]['person']['first_name']);
            Hive.box(Constants.MAINBOX).put(Constants.LASTNAME, details[i]['person']['last_name']);
            Constants.userId = details[i]['id'].toString();
            Hive.box(Constants.MAINBOX).put(Constants.EMAIL, email.text);
            Hive.box(Constants.MAINBOX).put(Constants.GENDER, details[i]['person']['gender']);
            Hive.box(Constants.MAINBOX).put(Constants.EMAIL, details[i]['person']['email']);
            Hive.box(Constants.MAINBOX).put(Constants.MOBILE, details[i]['person']['mobile']);
            //Save login activity
            Hive.box(Constants.MAINBOX).put(Constants.LOGIN, "user");

            //Create virtual wallet
            Hive.box(Constants.MAINBOX).put(Constants.VIRTUAL_WALLET,0);

            //Go to homepage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => HomePage(),
                fullscreenDialog: true,
              ),
            );

            setState(() {
              loading = false;
            });
            break;

          }
        }
      }

      //Otherwise return back to login page
      if(login == false && Hive.box(Constants.MAINBOX).get(Constants.LOGIN) !="driver" &&  Hive.box(Constants.MAINBOX).get(Constants.LOGIN) !="user" ){
        setState(() {
          error = true;
          errorText = "Incorrect credentials, please try again!";
          loading = false;
        });
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return  WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.all(width * 0.05, ),
            height: height,
            color: Colors.white,
            width: width,
            child: SingleChildScrollView(
              child: Container(
                height: (height * 0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: height * 0.025,),
                        Image.asset("assets/icons/logo.jpg",width: height * 0.2,),
                        SizedBox(height: height * 0.015,),
                        Text(
                          widget.driver == true ? "Driver Login!" : "Staff & Faculty Login!",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.0635
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            "Welcome back to the global transportation network",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: ProfileTextField(
                            title: "Email",
                            controller: email,
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: ProfileTextField(
                            title: "Pin",
                            controller: pin,
                          ),
                        ),

                        SizedBox(
                          height: 15,
                        ),

                        error == true ? ErrorMessage(message: "$errorText") : Container(),

                        loading == true ?
                        SpinKitFadingCircle(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black12,
                              ),
                            );
                          },
                        ) : Container(),
                      ],
                    ),

                    Column(
                      children: <Widget>[
                        RedBtn(
                          action: saveInfo,
                          name: "Log In",
                          width: width,
                          onboarding: false,
                        ),
                        InkWell(
                          onTap: (){
                            widget.driver == true ? navigatorKey.currentState.pushNamed("/login") : navigatorKey.currentState.pushNamed("/driver");
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  widget.driver == true ? "Are you a staff or faculty" : "Are you a driver?" ,
                                  style: TextStyle(
                                      fontSize: 13
                                  ),
                                ),

                                SizedBox(width: 5,),

                                Text(
                                  "Click here to login",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xffB71500),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )

                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

