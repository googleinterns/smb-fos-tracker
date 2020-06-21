import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Creates custom app bar for views containing bar chart.
/// It has back button on the left and title in the centre.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarTitle;
  final Color appBarColor;
  @override
  final Size preferredSize = Size.fromHeight(60);

  CustomAppBar({this.appBarTitle, this.appBarColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0.0,
      bottomOpacity: 0.0,
      title: Text(
        appBarTitle,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
