import 'package:ash_bus/models/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:qrcode/qrcode.dart';
import 'models/http.dart';

//This is the QR scan page

class QRScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  QRCaptureController _captureController = QRCaptureController();
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();

    _captureController.onCapture((data) {
      print('onCapture----$data');
      print("Bu number : ${Constants.userListBus[Constants.userTripListID]["bus"]["bus_number"].toString()}");
      if(data.toString() == "Ashbus"){
        print("Working");
        _captureController.pause();
        setState(() {
          Constants.codeScanned = true;
          Constants.startTrip = true;
          //Reduce ammount as well
          Hive.box(Constants.MAINBOX).put(Constants.VIRTUAL_WALLET, Hive.box(Constants.MAINBOX).get(Constants.VIRTUAL_WALLET) - Constants.amount);

          //Update trip with success payment
          StaffUpdateTrip();
        });
        Navigator.pop(context);
      }
      else{
        print("Not working");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: width * 0.8,
              height: height * 0.6,
              color: Colors.white,
              child: QRCaptureView(controller: _captureController),
            ),
          ],
        ),
      ),
    );
  }

}