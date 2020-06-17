import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Creates custom app bar for agent application.
/// It has back button on the left, agent name in the centre and settings
/// option with option to sign out on the right
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  String appBarTitle;
  Color appBarColor;
  @override
  final Size preferredSize = Size.fromHeight(60);
  CustomAppBar(String appBarTitle, Color appBarColor){
    this.appBarTitle = appBarTitle;
    this.appBarColor = appBarColor;
  }
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      bottomOpacity: 0.0,
      title: Text(
        appBarTitle,
        style: GoogleFonts.montserrat(
          color: Colors.black,
          fontSize: 17,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
          Theme(
            data: Theme.of(context).copyWith(
            cardColor: Colors.white,
            ),
            child: new PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
              return {'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
            }).toList();
            },
          ),
        )
      ],
    );
  }
}

void handleClick(String value) {
  switch (value) {
    case 'Logout': {
      // TODO: Sign out agent and go to login page
    }
  }
}