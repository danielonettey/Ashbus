import 'package:ash_bus/driverWelcomePage.dart';
import 'package:ash_bus/helpPage.dart';
import 'package:ash_bus/logInPage.dart';
import 'package:ash_bus/walletPayment.dart';
import 'package:ash_bus/onboarding.dart';
import 'package:ash_bus/profilePage.dart';
import 'package:ash_bus/signupPage.dart';
import 'package:ash_bus/homepage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ash_bus/makePaymentPage.dart';
import 'package:ash_bus/models/constants.dart' as Constants;


// This widget is the root of your application.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  //Enable notification and hive settings
  var initializationSettingsAndroid =
  AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid,iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
      });

  runApp(MyApp());
}

//Global Key for the main page
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => InitScreen(),
          '/login': (context) => LoginPage(),
          '/driver': (context) => LoginPage(driver: true,),
          '/driverWelcome': (context) => DriverWelcomePage(),
          '/signup': (context) => SignupPage(),
          '/makePayment': (context) => WalletPage(),
          '/profile': (context) => ProfilePage(),
          '/payment': (context) => WalletPage(),
          '/change pin': (context) => WalletPage(),
          '/support': (context) => HelpPage(),
          '/about': (context) => HelpPage(),
          '/help': (context) => HelpPage(),
        },
        navigatorKey: navigatorKey,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: "Quicksand"
        ),
      ),
    );
  }
}


//Initial Screen
class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {

  final Key _mapKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Hive.openBox(Constants.MAINBOX),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              final String login = Hive.box(Constants.MAINBOX).get(Constants.LOGIN);

              //Check if user has already logged in
              if (login == "user") {
                return HomePage();
              }
              else if(login == "driver"){
                return LoginPage(driver: true,);
              }

              else{
                return OnBoardingPage();
              }
            }
          } else {
            return Scaffold();
          }
        });
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}