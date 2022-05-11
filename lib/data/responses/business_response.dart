import 'dart:convert';

import 'package:appwrite_places/domain/model/type_business.dart';

TypeBusiness typeBusinessFromString(String str) =>
    typeBusinessFromJson(json.decode(str));

String typeBusinessToString(TypeBusiness data) =>
    json.encode(typeBusinessToJson(data));

TypeBusiness typeBusinessFromJson(Map<String, dynamic> json) => TypeBusiness(
      name: json["name"],
      description: json["description"],
      read: List<String>.from(json["\u0024read"].map((x) => x)),
      write: List<String>.from(json["\u0024write"].map((x) => x)),
      id: json["\u0024id"],
      collection: json["\u0024collection"],
    );

Map<String, dynamic> typeBusinessToJson(TypeBusiness typeBusiness) => {
      "name": typeBusiness.name,
      "description": typeBusiness.description,
      "\u0024read": List<dynamic>.from(typeBusiness.read.map((x) => x)),
      "\u0024write": List<dynamic>.from(typeBusiness.write.map((x) => x)),
      "\u0024id": typeBusiness.id,
      "\u0024collection": typeBusiness.collection,
    };
