import 'package:ash_bus/main.dart';
import 'package:ash_bus/profilePage.dart';
import 'package:ash_bus/widgets/buttons.dart';
import 'package:ash_bus/widgets/errorMessage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

//This is the sign up page

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final fname = TextEditingController();
  final lname = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final city = TextEditingController();

  bool checkedValue = false;
  bool error = false;

  saveInfo(){

    //Form validation
    if (fname.text.isEmpty || lname.text.isEmpty || email.text.isEmpty||
        city.text.isEmpty || mobile.text.isEmpty || checkedValue == false){
        setState(() {
          error = true;
        });
    }
    else{

      //Save Information locally
      Hive.box(Constants.MAINBOX).put(Constants.FIRSTNAME, fname.text);
      Hive.box(Constants.MAINBOX).put(Constants.LASTNAME, lname.text);
      Hive.box(Constants.MAINBOX).put(Constants.EMAIL, email.text);
      Hive.box(Constants.MAINBOX).put(Constants.MOBILE, mobile.text);

      //Save login activity
      Hive.box(Constants.MAINBOX).put(Constants.LOGIN, "true");

      //Set up virtual wallet
      Hive.box(Constants.MAINBOX).put(Constants.VIRTUAL_WALLET, 20);

      //Go to set the pin
      navigatorKey.currentState.pushNamed("/");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5CA960),
        title: Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.white
          ),
        ),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          padding: EdgeInsets.all(width * 0.05, ),
          height: height,
          color: Color(0xffF3FCF2),
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Welcome to AshBus",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.0635
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      "Be a part of this global transportation network",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),

                  ProfileTextFields(
                    fController: fname,
                    sController: lname,
                    fTitle: "First Name",
                    sTitle: "Last Name",
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: ProfileTextField(
                      title: "Email",
                      controller: email,
                    ),
                  ),

                  ProfileTextFields(
                    fController: mobile,
                    sController: city,
                    fTitle: "Mobile",
                    sTitle: "City",
                  ),

                  Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: checkedValue,
                          activeColor: Color(0xff66BB6A),
                          onChanged: (value) {
                            setState(() {
                              checkedValue = !checkedValue;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Check here to indicate that you have read and agree "
                                "to the terms and conditions of AshBus",
                            style: TextStyle(
                                fontSize: 12
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  error == true ? ErrorMessage(message: Constants.ERRORTEXT) : Container(),
                ],
              ),

              Column(
                children: <Widget>[
                  RedBtn(
                    action: saveInfo,
                    name: "Sign Up",
                    width: width,
                    onboarding: true,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: InkWell(
                      onTap: (){
                        navigatorKey.currentState.pushNamed("/login");
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Already have an account?",
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
    );
  }
}
