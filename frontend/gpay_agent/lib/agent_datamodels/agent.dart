import 'coordinates.dart';
import 'name.dart';

///Model class for storing agent details.
class Agent {
  String AgentEmail;
  Name AgentName;
  String AgentPhone;
  String AgentCreationDateTime;
  MapCoordinates AgentCoordinates;

  Agent(
    this.AgentEmail,
    this.AgentName,
    this.AgentPhone,
    this.AgentCreationDateTime,
    this.AgentCoordinates,
  );

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      json['email'] as String,
      Name.fromJson(json['name']),
      json['phone'] as String,
      json['agentCreationDateTime'] as String,
      MapCoordinates.fromJson(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() => {
        'AgentEmail': AgentEmail,
        'AgentName': AgentName.toJson(),
        'AgentPhone': AgentPhone,
        'AgentCreationDateTime': AgentCreationDateTime,
        'Coordinates': AgentCoordinates.toJson(),
      };

  String getName() {
    if ((AgentName.midName).isEmpty) {
      return (AgentName.firstName + " " + AgentName.lastName);
    } else {
      return (AgentName.firstName +
          " " +
          AgentName.midName +
          " " +
          AgentName.lastName);
    }
  }
}