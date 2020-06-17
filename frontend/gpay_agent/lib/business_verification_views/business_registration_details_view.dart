///*
//import 'package:flutter/material.dart';
//import 'package:agent_app/business_verification_views/business_verification_view.dart';
//
///// Loads in Merchant data, and displays the data.
//class MerchantHomeView extends StatefulWidget {
//  _MerchantHomeViewState createState() => _MerchantHomeViewState();
//}
//
//class _MerchantHomeViewState extends State<MerchantHomeView> {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Colors.white,
//      appBar: AppBar(
//        backgroundColor: Colors.white,
//        elevation: 0.0,
//        bottomOpacity: 0.0,
//        leading: IconButton(
//          icon: Icon(Icons.arrow_back, color: Colors.black),
//          onPressed: () {
//            Navigator.pop(context);
//          },
//        ),
//      ),
//      body: ListView(padding: const EdgeInsets.all(8.0), children: <Widget>[
//        Container(
//          height: 50.0,
//          child: const Center(
//            child: Text(
//              'Merchant details',
//              style: TextStyle(
//                fontSize: 20.0,
//              ),
//            ),
//          ),
//        ),
//        Image.asset('assets/verification_images/shop.png'),
//        Container(
//          height: 50.0,
//          child: const Center(
//            child: Text(
//              'Merchant Name : ',
//              textAlign: TextAlign.left,
//              style: TextStyle(
//                fontSize: 20.0,
//              ),
//            ),
//          ),
//        ),
//        Container(
//          height: 50.0,
//          child: const Center(
//            child: Text(
//              'Store Name : ',
//              textAlign: TextAlign.left,
//              style: TextStyle(fontSize: 20.0),
//            ),
//          ),
//        )
//      ]),
//      floatingActionButton: FloatingActionButton.extended(
//        onPressed: () {
//          Navigator.push(context,
//              MaterialPageRoute(builder: (context) => MyHomePage()));
//        },
//        tooltip: 'Next',
//        shape: RoundedRectangleBorder(),
//        label: Text(
//          'Next',
//          style: TextStyle(fontSize: 16.0),
//        ),
//      ),
//    );
//  }
//}
//*/
