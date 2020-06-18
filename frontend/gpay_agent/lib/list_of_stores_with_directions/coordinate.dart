class Coordinates {
  double latitude;
  double longitude;

  Coordinates({this.latitude, this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return new Coordinates(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}