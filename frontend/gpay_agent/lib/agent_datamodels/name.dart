/// Model class for storing name of user
class Name{
  String firstName;
  String midName;
  String lastName;

  Name(String first, String mid, String last){
    this.firstName = first;
    this.midName = mid;
    this.lastName = last;
  }

//  Name({
//    this.firstName,
//    this.midName,
//    this.lastName
//  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return new Name(
      json['firstName'] as String,
      json['middleName'] as String,
      json['lastName'] as String,
    );
  }

//  factory Name.fromJson(Map<String, dynamic> json) {
//    return Name(
//      firstName: json['firstName'],
//      midName:  json['middleName'],
//      lastName: json['lastName'],
//    );
//  }

  Map<String, dynamic> toJson() =>
      {
        'firstName': firstName,
        'midName': midName,
        'lastName': lastName,
      };

  String getName(){
    return firstName+" "+midName + " "+ lastName;
  }
}
