/// Model class for storing name of user
class Name {
  String firstName;
  String midName;
  String lastName;

  Name(this.firstName, this.midName, this.lastName);

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      json['firstName'] as String,
      json['middleName'] as String,
      json['lastName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'midName': midName,
        'lastName': lastName,
      };
}
