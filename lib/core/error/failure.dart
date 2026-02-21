sealed class AppFailure {
  final String message;
  final dynamic extraData;
  AppFailure(this.message, {this.extraData});
}

class DatabaseFailure extends AppFailure {
  DatabaseFailure(super.message, {super.extraData});
}

class ValidationFailure extends AppFailure {
  ValidationFailure(super.message, {super.extraData});
}

class MigrationFailure extends AppFailure {
  MigrationFailure(super.message);
}

class UnexpectedFailure extends AppFailure {
  UnexpectedFailure(super.message);
}
