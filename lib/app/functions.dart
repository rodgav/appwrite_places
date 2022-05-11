import 'package:appwrite_places/domain/model/latitude_longitude.dart';
import 'dart:math' as math;

bool isEmailValid(String email) {
  return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}
// const earth = 6378.137;

LatLng toNorthPosition(LatLng latLng, double northDistance) {
  double earth = 6378;
  var pi = math.pi;
  var newLatitude = latLng.latitude + (northDistance / earth) * (180 / pi);
  return LatLng(newLatitude, latLng.longitude);
}



LatLng toEastPosition(LatLng latLng, double eastDistance) {
  double earth = 6378;
  var pi = math.pi;
  var newLongitude = latLng.longitude +
      (eastDistance / earth) * (180 / pi) / math.cos(latLng.latitude * pi / 180);
  return LatLng(latLng.latitude, newLongitude);
}



LatLng toSouthPosition(LatLng latLng, double southDistance) {
  double earth = 6378;
  var pi = math.pi;
  var newLatitude = latLng.latitude - (southDistance / earth) * (180 / pi);
  return LatLng(newLatitude, latLng.longitude);
}



LatLng toWestPosition(LatLng latLng, double westDistance) {
  double earth = 6378;
  var pi = math.pi;
  var newLongitude = latLng.longitude -
      (westDistance / earth) * (180 / pi) / math.cos(latLng.latitude * pi / 180);
  return LatLng(latLng.latitude, newLongitude);
}