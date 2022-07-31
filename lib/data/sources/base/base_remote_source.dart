import 'package:tdlook_flutter_app/utilt/logger.dart';

typedef JsonData = Map<String, dynamic>;
typedef Id = int;

abstract class BaseRemoteSource {
  /// Handles all exceptions occurred in the Repository layer
  Exception handleError(Object e) {
    logger.e("Remote source exeption: ${e.toString()}");
    throw getError(e);
  }

  Exception getError(Object e) {
    final error = e as Exception;

    Exception currentError;
    currentError = error;

    return currentError;
  }
}
