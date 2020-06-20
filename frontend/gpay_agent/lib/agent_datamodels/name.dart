/// Model class for storing name of user
class Name {
  String firstName;
  String midName;
  String lastName;

  Name(String first, String mid, String last){
    this.firstName = first;
    this.midName = mid;
    this.lastName = last;
  }

  /// Creates new Name object from json string.
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

  String getName(){
    return firstName+" "+midName + " "+ lastName;
  }
}
