import 'package:ash_bus/main.dart';
import 'package:ash_bus/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:ash_bus/models/constants.dart' as Constants;
import 'package:hive/hive.dart';

//This is the profile page

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //Controllerss
  final fname = TextEditingController();
  final lname = TextEditingController();
  final mobile = TextEditingController();
  final city = TextEditingController();
  final email = TextEditingController();
  final mainbox = Hive.box(Constants.MAINBOX);

  @override
  void initState() {
    fname.text = mainbox.get(Constants.FIRSTNAME);
    lname.text = mainbox.get(Constants.LASTNAME);
    mobile.text = mainbox.get(Constants.MOBILE);
    email.text = mainbox.get(Constants.EMAIL);
  }

  save(){
    mainbox.put(Constants.FIRSTNAME, fname.text);
    mainbox.put(Constants.LASTNAME, lname.text);
    mainbox.put(Constants.EMAIL, email.text);
    mainbox.put(Constants.MOBILE, mobile.text);
    navigatorKey.currentState.pushNamed("/");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(left: width * 0.325),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      ClipOval(
                        child: Material(
                          color: Colors.transparent, // button color
                          child: InkWell(
                            child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(Icons.close)
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                  child: Image.asset("assets/icons/profile.png"),
                ),

                ProfileTextFields(fController: fname,fHintText: "First Name",sController: lname,sHintText: "Last Name",),
                ProfileTextFields(fController: mobile,fHintText: "Mobile",sController: city,sHintText: "Country",),
                SizedBox(height: 15,),
                ProfileTextField(controller: email,hintText: "Email",),

                SizedBox(height: 180,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RedBtn(
                        action: save,
                        name: "SAVE",
                      ),
                      flex: 9,
                    ),
                    Expanded(
                      child: Container(),
                      flex: 1,
                    ),
                    Expanded(
                      child: RedBtn(
                        action: ()=>navigatorKey.currentState.pushNamed("/signup"),
                        name: "LOGOUT",
                      ),
                      flex: 9,
                    ),
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}

//This is the profile textfield widget
class ProfileTextFields extends StatefulWidget {
  final TextEditingController fController;
  final TextEditingController sController;
  final String fHintText;
  final String fTitle;
  final String sTitle;
  final String sHintText;

  const ProfileTextFields({Key key, this.fController, this.sController, this.fHintText, this.sHintText, this.fTitle, this.sTitle}) : super(key: key);
  @override
  _ProfileTextFieldsState createState() => _ProfileTextFieldsState();
}

class _ProfileTextFieldsState extends State<ProfileTextFields> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: ProfileTextField(controller: widget.fController,hintText: widget.fHintText,title: widget.fTitle,),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 4,
            child: ProfileTextField(controller: widget.sController,hintText: widget.sHintText,title: widget.sTitle),
          )
        ],
      ),
    );
  }
}

class ProfileTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String title;

  const ProfileTextField({Key key, this.controller, this.hintText, this.title}) : super(key: key);
  @override
  _ProfileTextFieldState createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.title != null ? widget.title: "",
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,

        ),
        contentPadding: EdgeInsets.all(0),
        hintText: widget.hintText,
      ),
    );
  }
}
