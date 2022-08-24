import 'dart:convert';

Building buildingFromJson(String str) => Building.fromJson(json.decode(str));

String buildingToJson(Building data) => json.encode(data.toJson());

class Building {
  Building({
    this.email,
    this.geom,
  });

  Building.withId({this.email, this.geom, this.id});

  String email;
  List<Geom> geom;
  int id;

  factory Building.fromJson(Map<String, dynamic> json) => Building(
        email: json["email"],
        geom: List<Geom>.from(json["geom"].map((x) => Geom.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "geom": List<dynamic>.from(geom.map((x) => x.toJson())),
      };

  factory Building.fromMap(Map<String, dynamic> map) {
    return Building.withId(
      id: map['id'],
      email: map['email'],
      geom: map['geom'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['email'] = email;
    map['geom'] = json.encode(geom);
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}

class Geom {
  Geom({
    this.latitude,
    this.longitude,
  });

  String latitude;
  String longitude;

  factory Geom.fromJson(Map<String, dynamic> json) => Geom(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
