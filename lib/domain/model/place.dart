// To parse this JSON data, do
//
//     final place = placeFromJson(jsonString);
class Place {
  Place({
    required this.name,
    required this.typeBusiness,
    required this.latitude,
    required this.longitude,
    required this.read,
    required this.write,
    required this.id,
    required this.collection,
  });

  String name;
  String typeBusiness;
  double latitude;
  double longitude;
  List<String> read;
  List<String> write;
  String id;
  String collection;
}