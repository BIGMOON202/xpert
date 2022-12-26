import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/common/utils/store_app.dart';

abstract class StoreUtils {
  static Future<Store> fetchStoreApp() async {
    final _checker = AppVersionChecker();
    try {
      final status = await _checker.checkUpdate();
      final storeVersion = status.newVersion;
      logger.d('currentVersion: ${status.currentVersion}');
      logger.d('storeVersion: $storeVersion');
      logger.d('canUpdate: ${status.canUpdate}');
      if (storeVersion != null && status.canUpdate) {
        return Store(
          version: storeVersion,
          canUpdate: true,
        );
      } else {
        return Store.zero;
      }
    } catch (e) {
      return Store.zero;
    }
  }
}

class Store {
  final String version;
  final bool canUpdate;
  const Store({required this.version, required this.canUpdate});
  static Store zero = const Store(version: '0.0.0', canUpdate: false);
}
