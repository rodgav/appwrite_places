import 'package:appwrite_places/data/network/failure.dart';
import 'package:appwrite_places/domain/model/place.dart';
import 'package:appwrite_places/domain/repository/repository.dart';
import 'package:appwrite_places/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:appwrite_places/domain/model/latitude_longitude.dart';

class MainUseCase
    implements
        BaseUseCase<MainDeleteSessionUseCaseInput, dynamic>,
        MainUseCasePlaces<MainUseCaseInputPlace, List<Place>> {
  final Repository _repository;

  MainUseCase(this._repository);

  @override
  Future<Either<Failure, dynamic>> execute(
          MainDeleteSessionUseCaseInput input) =>
      _repository.deleteSession(input.sessionId);

  @override
  Future<Either<Failure, List<Place>>> places(MainUseCaseInputPlace input) =>
      _repository.places(
          input.north, input.east, input.south, input.west, input.typeBusiness);
}

class MainDeleteSessionUseCaseInput {
  String sessionId;

  MainDeleteSessionUseCaseInput(this.sessionId);
}

class MainUseCaseInputPlace {
  LatLng north, east, south, west;
  String typeBusiness;

  MainUseCaseInputPlace(
      this.north, this.east, this.south, this.west, this.typeBusiness);
}

abstract class MainUseCasePlaces<In, Out> {
  Future<Either<Failure, Out>> places(In input);
}
