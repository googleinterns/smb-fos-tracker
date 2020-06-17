/// Model class for storing location coordinates of user
class MapCoordinates{
  double latitude;
  double longitude;

  MapCoordinates(
    this.latitude,
    this.longitude
  );

  Map<String, dynamic> toJson() =>
      {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory MapCoordinates.fromJson(Map<String, dynamic> json) {
    return new MapCoordinates(
      json['latitude'] as double,
      json['longitude'] as double,
    );
  }

//  factory MapCoordinates.fromJson(Map<String, dynamic> json) {
//    return MapCoordinates(
//      latitude: json['latitude'] ,
//      longitude: json['longitude']
//    );
//  }
}
