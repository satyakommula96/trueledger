sealed class AppFailure {
  final String message;
  AppFailure(this.message);
}

class DatabaseFailure extends AppFailure {
  DatabaseFailure(super.message);
}

class ValidationFailure extends AppFailure {
  ValidationFailure(super.message);
}

class MigrationFailure extends AppFailure {
  MigrationFailure(super.message);
}

class UnexpectedFailure extends AppFailure {
  UnexpectedFailure(super.message);
}
