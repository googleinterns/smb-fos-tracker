import 'package:flutter/material.dart';

import 'charts_views/select_time_span.dart';
import 'charts_views/verification_analysis_region_wise.dart';
import 'charts_views/verification_analysis_time_wise.dart';

void main() {
  runApp(FosTracker());
}

/// Class for the root stateless widget of application

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
      home: SelectTime(),
    );
  }
}
