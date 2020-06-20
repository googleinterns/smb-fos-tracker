import 'package:agent_app/agent_datamodels/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';


class LoadingMerchant extends StatefulWidget {
  @override
  LoadingMerchantState createState() => LoadingMerchantState();
}

/// Builds a loading circle widget that shows on screen while
/// fetching complete registered information of store in database.

class LoadingMerchantState extends State<LoadingMerchant> {
  final slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
    spinnerMode: true,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextWidget(
              name: "Starting Verification..",
              color: Colors.black,
            ),
            slider,
          ],
        ),
      ),
    );
  }
}
