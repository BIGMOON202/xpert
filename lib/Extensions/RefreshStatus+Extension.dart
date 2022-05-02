
import 'package:pull_to_refresh/pull_to_refresh.dart';

extension RefreshStatusExtension on RefreshStatus {
  String title() {
    switch (this) {
      case RefreshStatus.idle:
        return 'Pull down to refresh';
      case RefreshStatus.canRefresh:
        return 'Release to refresh';
      default:
        return '';
    }
  }
}