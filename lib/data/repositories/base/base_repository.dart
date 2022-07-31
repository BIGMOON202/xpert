abstract class BaseRepository {
  /// Handles all exceptions occurred in the Repository layer
  Exception handleError(Object e) {
    throw getError(e);
  }

  Exception getError(Object e) {
    final error = e as Exception;

    Exception currentError;
    currentError = error;

    return currentError;
  }
}
