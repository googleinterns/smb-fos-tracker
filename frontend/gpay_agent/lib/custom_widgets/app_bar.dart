/*
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agent_app/globals.dart';

/// Creates custom app bar for agent application.
/// It has back button on the left, agent name in the centre and settings
/// option with option to sign out on the right
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  String appBarTitle;
  Color appBarColor;
  @override
  final Size preferredSize = Size.fromHeight(60);
  BuildContext context1;

  CustomAppBar(String appBarTitle, Color appBarColor, BuildContext context) {
    this.appBarTitle = appBarTitle;
    this.appBarColor = appBarColor;
    this.context1 = context;
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


  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        {
          googleSignIn.signOut();
          Navigator.pop(context1);
        }
    }
  }
}
