import 'package:appwrite/models.dart';
import 'package:appwrite_places/data/network/failure.dart';
import 'package:appwrite_places/data/request/request.dart';
import 'package:appwrite_places/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';

import 'base_usecase.dart';

class LoginUseCase
    implements
        BaseUseCase<LoginUseCaseInput, Session>,
        LoginUseCaseAnonymousSession<void, Session> {
  final Repository _repository;

  LoginUseCase(this._repository);

  @override
  Future<Either<Failure, Session>> execute(LoginUseCaseInput input) =>
      _repository.login(LoginRequest(input.email, input.password));

  @override
  Future<Either<Failure, Session>> anonymousSession(void input) =>
      _repository.anonymousSession();
}

class LoginUseCaseInput {
  String email, password;

  LoginUseCaseInput(this.email, this.password);
}

abstract class LoginUseCaseAnonymousSession<In, Out> {
  Future<Either<Failure, Out>> anonymousSession(In input);
}
