import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite_places/app/app_preferences.dart';
import 'package:appwrite_places/app/constants.dart';
import 'package:appwrite_places/data/request/request.dart';
import 'package:appwrite_places/domain/model/latitude_longitude.dart';
import 'package:http_parser/http_parser.dart';

class AppServiceClient {
  final Account _account;
  final Database _database;
  final Storage _storage;

  AppServiceClient(Client _client, AppPreferences _appPreferences)
      : _account = Account(_client),
        _database = Database(_client),
        _storage = Storage(_client);

  Future<Session> login(LoginRequest loginRequest) => _account.createSession(
      email: loginRequest.email, password: loginRequest.password);

  Future<User> register(LoginRequest loginRequest) => _account.create(
      userId: 'unique()',
      email: loginRequest.email,
      password: loginRequest.password,
      name: loginRequest.name);

  Future<Session> anonymousSession() => _account.createAnonymousSession();

  Future<Token> forgotPassword(String email) =>
      _account.createRecovery(email: email, url: Constant.baseUrl);

  Future<dynamic> deleteSession(String sessionId) =>
      _account.deleteSession(sessionId: sessionId);

  Future<File> createFile(Uint8List uint8list, String name) =>
      _storage.createFile(
          bucketId: Constant.buckedId,
          fileId: 'unique()',
          file: InputFile(
              file: MultipartFile.fromBytes('file', uint8list,
                  filename: name, contentType: MediaType('image', 'jpg'))),
          read: ['role:all'],
          write: ['role:all']);

  Future deleteFile(String idFile) =>
      _storage.deleteFile(bucketId: Constant.buckedId, fileId: idFile);

  Future<DocumentList> places(LatLng north, LatLng east, LatLng south,
          LatLng west, String typeBusiness) =>
      _database.listDocuments(collectionId: Constant.places, queries: [
        /*Query.lesser('latitude', north.latitude),
        Query.lesser('longitude', east.longitude),
        Query.greater('latitude', south.latitude),
        Query.greater('longitude', west.longitude),*/
        //NORTHEAST
        north.latitude < 0
            ? Query.lesser('latitude', north.latitude)
            : Query.greater('latitude', north.latitude),
        east.latitude < 0
            ? Query.lesser('longitude', east.longitude)
            : Query.greater('longitude', east.longitude),
        //SOUTHEAST
        south.latitude < 0
            ? Query.greater('latitude', south.latitude)
            : Query.lesser('latitude', south.latitude),
        east.latitude < 0
            ? Query.lesser('longitude', east.longitude)
            : Query.greater('longitude', east.longitude),
        //SOUTHOWEST
        south.latitude < 0
            ? Query.greater('latitude', south.latitude)
            : Query.lesser('latitude', south.latitude),
        west.latitude < 0
            ? Query.greater('longitude', west.longitude)
            : Query.lesser('longitude', west.longitude),
        //NORTHWEST
        north.latitude < 0
            ? Query.lesser('latitude', north.latitude)
            : Query.greater('latitude', north.latitude),
        west.latitude < 0
            ? Query.greater('longitude', west.longitude)
            : Query.lesser('longitude', west.longitude),
        Query.equal('type_business', typeBusiness)
      ]);
}
