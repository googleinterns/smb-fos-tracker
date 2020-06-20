//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:fos_tracker/charts_views/select_region.dart';
//
///// Class for rendering the main menu page having option for either tracking live location of agents or viewing verification status charts.
//class MenuView extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: ListView(padding: EdgeInsets.all(30), children: <Widget>[
//        Container(
//          child: Image.asset("images/menu_logo.png"),
//        ),
//        RaisedButton(
//          child: Text("Agent Live Tracking"),
//          onPressed: null,
//        ),
//        RaisedButton(
//          child: Text("Store Verification Analysis"),
//          onPressed: () {
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => SelectRegion(),
//                ));
//          },
//        ),
//      ]),
//    );
//  }
//}
