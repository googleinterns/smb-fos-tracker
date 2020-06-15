import 'package:fos_tracker/coordinates.dart';

class Agent {
  String email;
  Coordinates coordinates;

  Agent({this.email, this.coordinates});

  factory Agent.fromJson(Map<String, dynamic> json) {
    return new Agent(
      email: json['email'],
      coordinates: Coordinates.fromJson(json['coordinates']),
    );
  }
}