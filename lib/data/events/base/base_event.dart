import 'package:tdlook_flutter_app/common/logger/logger.dart';

abstract class BaseEvent {
  BaseEvent() {
    logger.i('Root event with type ${runtimeType.toString()} triggered');
  }
}

abstract class ProgressEvent extends BaseEvent {
  double progress;
  ProgressEvent(this.progress) {
    logger.i('Progress event with type ${runtimeType.toString()} triggered progress: $progress');
  }
}

abstract class SuccessEvent extends BaseEvent {
  SuccessEvent() {
    logger.i('Success event with type ${runtimeType.toString()} triggered');
  }
}

abstract class FailureEvent extends BaseEvent {
  String reason;
  FailureEvent(this.reason) {
    logger.e('Failure event with type ${runtimeType.toString()} triggered reason: $reason');
  }
}
