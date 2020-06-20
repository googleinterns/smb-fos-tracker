import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Defines a theme text widget for app.
/// Sets default font size to 20 and distance from text
/// container edges to 8 pixels.

class TextWidget extends StatelessWidget {
  TextWidget({this.name, this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        name,
        style: TextStyle(color: color, fontSize: 20),
      ),
    );
  }
}