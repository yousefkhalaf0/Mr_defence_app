abstract class Failures {
  final String message;

  Failures(this.message);
}

class ServerFailure extends Failures {
  ServerFailure(super.message);
}

class CacheFailure extends Failures {
  CacheFailure(super.message);
}

class NetworkFailure extends Failures {
  NetworkFailure(super.message);
}

class EmptyCacheFailure extends Failures {
  EmptyCacheFailure(super.message);
}

class EmptyFailure extends Failures {
  EmptyFailure(super.message);
}

class InvalidInputFailure extends Failures {
  InvalidInputFailure(super.message);
}

class InvalidPhoneNumberFailure extends Failures {
  InvalidPhoneNumberFailure(super.message);
}
