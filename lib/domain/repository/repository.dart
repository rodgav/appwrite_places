import 'dart:typed_data';

import 'package:appwrite/models.dart';
import 'package:appwrite_places/data/network/failure.dart';
import 'package:appwrite_places/data/request/request.dart';
import 'package:appwrite_places/domain/model/type_business.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:appwrite_places/domain/model/place.dart';
import 'package:dartz/dartz.dart';

abstract class Repository {
  Future<Either<Failure, Session>> login(LoginRequest loginRequest);

  Future<Either<Failure, User>> register(LoginRequest loginRequest);

  Future<Either<Failure, Session>> anonymousSession();

  Future<Either<Failure, Token>> forgotPassword(String email);

  Future<Either<Failure, dynamic>> deleteSession(String sessionId);

  Future<Either<Failure, File>> createFile(Uint8List uint8list, String name);

  Future<Either<Failure, dynamic>> deleteFile(String idFile);
  Future<Either<Failure, List<TypeBusiness>>> typeBusiness();
  Future<Either<Failure, List<Place>>> places(LatLng north, LatLng east, LatLng south,
      LatLng west, String typeBusiness);
}
