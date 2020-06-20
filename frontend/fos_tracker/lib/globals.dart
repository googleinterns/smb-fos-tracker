library fos_tracker.globals;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng startPosition;
Set<Marker> agentMarkers = new Set();
Set<Marker> merchantMarkers = new Set();
Set<Marker> verifiedMerchantMarkers = new Set();
LatLng currentPosition;
String pincode;

showAlertDialog(String title, String alertMessage, BuildContext context) {
  // This is the setup of the button to give user the choice to click on OK after reading the dialog.
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // This is the setup of the alert dialog based on the provided title.
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(
      alertMessage,
    ),
    actions: [
      okButton,
    ],
  );

  // This is where the alert dialog is displayed.
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
