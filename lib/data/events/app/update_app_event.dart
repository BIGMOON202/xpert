import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/data/events/base/base_event.dart';

abstract class UpdateaAppEvent extends BaseEvent {
  UpdateaAppEvent() {
    logger.i('Update app event with type ${runtimeType.toString()} triggered');
  }
}

class UpdateaAppInitEvent extends UpdateaAppEvent {
  UpdateaAppInitEvent();
}

class UpdateaAppSuccessEvent extends UpdateaAppEvent {
  final String storeVersion;
  UpdateaAppSuccessEvent({
    required this.storeVersion,
  });
}

class UpdateaAppFailureEvent extends UpdateaAppEvent {
  UpdateaAppFailureEvent();
}
