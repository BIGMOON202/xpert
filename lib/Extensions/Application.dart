import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:tdlook_flutter_app/application/config/app_config.dart';
import 'package:tdlook_flutter_app/application/config/app_env.dart';

class Application {
  static AppConfig get config {
    return BackstageAppConfig();
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static isSimulator() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return !iosInfo.isPhysicalDevice;
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      final isPhysicalDevice = androidInfo.isPhysicalDevice ?? false;
      return !isPhysicalDevice;
    }
    return false;
  }

  static bool isProMode = false;

  static bool get hostIsCustom {
    return _hostIsOverriden;
  }

  static String? get customHost {
    return _testHost;
  }

  static bool _hostIsOverriden = false;
  static String? _testHost;

  static Future<void> updateHost({String? testHost}) async {
    if (testHost == null) {
      _hostIsOverriden = false;
    } else {
      _hostIsOverriden = true;
      _testHost = testHost;
    }
  }

  static String get hostName {
    if (_hostIsOverriden == true && _testHost != null) {
      return _testHost!;
    }
    return AppEnv.host;
  }

  static bool get shouldOpenLinks {
    return true;
  }

  static bool get shouldShowWaistLevel {
    return true;
  }

  static bool get shouldShowOverlap {
    return true;
  }

  static int get gyroUpdatesFrequency {
    return 300; //in milliseconds
  }
}

const int kDefaultMeasurementsPerPage = 20;

enum API {
  test,
  stage,
  release,
  hotfix,
}
