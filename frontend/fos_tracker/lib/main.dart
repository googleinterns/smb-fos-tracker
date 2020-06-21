import 'package:flutter/material.dart';

import 'menu.dart';

void main() {
  runApp(FosTracker());
}

/// Class for the root stateless widget of application.
/// It calls the main menu view.
class FosTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fos Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MenuView(),
    );
  }
}
