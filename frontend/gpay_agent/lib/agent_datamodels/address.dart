class Address{
  String street;
  String area;
  String city;
  String state;
  String pincode;
  String country;

  Address(this.street, this.area, this.city, this.state, this.pincode,
      this.country);

  factory Address.fromJson(Map<String, dynamic> json){
    return new Address(
       json['street'] as String,
       json['area'] as String,
      json['city'] as String,
      json['state'] as String,
      json['pincode'] as String,
        json['country'] as String
    );
  }

  String getAddress(){
    return street + ", " + area + ", " + city + ", " + state + ", " + pincode + ", " + country;
  }

}