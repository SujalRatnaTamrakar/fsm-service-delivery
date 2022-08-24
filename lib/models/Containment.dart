import 'dart:convert';

Containment containmentFromJson(String str) =>
    Containment.fromJson(json.decode(str));

String containmentToJson(Containment data) => json.encode(data.toJson());

class Containment {
  Containment({
    this.latitude,
    this.longitude,
    this.email,
  });

  Containment.withId({this.email, this.longitude, this.latitude, this.id});

  String latitude;
  String longitude;
  String email;
  int id;

  factory Containment.fromJson(Map<String, dynamic> json) => Containment(
        latitude: json["latitude"],
        longitude: json["longitude"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "email": email,
      };

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['email'] = email;
    map['lat'] = latitude.toString();
    map['lon'] = longitude.toString();
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Containment.fromMap(Map<String, dynamic> map) {
    return Containment.withId(
        id: map['id'],
        email: map['email'],
        latitude: map['lat'],
        longitude: map['lon']);
  }
}
