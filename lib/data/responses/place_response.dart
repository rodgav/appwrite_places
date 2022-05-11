import 'dart:convert';

import 'package:appwrite_places/domain/model/place.dart';

Place placeFromString(String str) => placeFromJson(json.decode(str));

String placeToString(Place data) => json.encode(placeToJson(data));

Place placeFromJson(Map<String, dynamic> json) => Place(
      name: json["name"],
      typeBusiness: json["type_business"],
      latitude: json["latitude"].toDouble(),
      longitude: json["longitude"].toDouble(),
      read: List<String>.from(json["\u0024read"].map((x) => x)),
      write: List<String>.from(json["\u0024write"].map((x) => x)),
      id: json["\u0024id"],
      collection: json["\u0024collection"],
    );

Map<String, dynamic> placeToJson(Place place) => {
      "name": place.name,
      "type_business": place.typeBusiness,
      "latitude": place.latitude,
      "longitude": place.longitude,
      "\u0024read": List<dynamic>.from(place.read.map((x) => x)),
      "\u0024write": List<dynamic>.from(place.write.map((x) => x)),
      "\u0024id": place.id,
      "\u0024collection": place.collection,
    };
