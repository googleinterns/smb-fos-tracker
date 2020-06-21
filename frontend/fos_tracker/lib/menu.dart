import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fos_tracker/charts_views/verification_analysis_time_wise.dart';
import 'package:fos_tracker/charts_views/verification_analysis_region_wise.dart';
import 'package:fos_tracker/main_view.dart';

/// Class for rendering the main menu page having option for either tracking live location of agents or viewing verification status charts based on region and week.
class MenuView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            Column(children: <Widget>[
              Container(
                child: Image.asset("images/menu_logo.png"),
              ),
              CustomButton(
                title: "Agent Live Tracking",
                icon: Icon(
                  Icons.add_location,
                  color: Colors.white,
                  size: 30,
                ),
                function: new MainView(),
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                title: "Verification Analysis By Region",
                icon: Icon(
                  Icons.insert_chart,
                  color: Colors.white,
                  size: 30,
                ),
                function: new RegionalAnalysis(),
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                title: "Verification Analysis By Week",
                icon: Icon(
                  Icons.date_range,
                  color: Colors.white,
                  size: 30,
                ),
                function: new TimeAnalysis(),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Class for creating custom button structure
class CustomButton extends StatelessWidget {
  final String title;
  final Icon icon;
  final StatefulWidget function;

  CustomButton({this.title, this.icon, this.function});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: ButtonTheme(
        height: 70,
        buttonColor: Colors.blue,
        child: RaisedButton(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              icon,
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => function,
                ));
          },
        ),
      ),
    );
  }
}
