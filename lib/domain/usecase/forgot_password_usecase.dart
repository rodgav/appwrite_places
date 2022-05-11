import 'package:appwrite/models.dart';
import 'package:appwrite_places/data/network/failure.dart';
import 'package:appwrite_places/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';

import 'base_usecase.dart';

class ForgotPasswordUseCase implements BaseUseCase<String, Token> {
  final Repository _repository;

  ForgotPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, Token>> execute(String input) async {
    return await _repository.forgotPassword(input);
  }
}
