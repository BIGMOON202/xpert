import 'dart:io' show Platform;
import 'package:device_info/device_info.dart';

class Application {
  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static isSimulator() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isIOS){
      var iosInfo = await deviceInfo.iosInfo;
      return !iosInfo.isPhysicalDevice;
    } else if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      return !androidInfo.isPhysicalDevice;
    }
    return false;
  }

  static API get apiType {
    return API.stage;
  }

  static bool get hostIsCustom {
    return _hostIsOverriden;
  }

  static String get customHost {
    return _testHost;
  }

  static bool _hostIsOverriden = false;
  static String _testHost;

  static Future<void> updateHost({String testHost}) {
    if (testHost == null) {
      _hostIsOverriden = false;
    } else {
      _hostIsOverriden = true;
      _testHost = testHost;
    }
  }

  static String get hostName {
    if (_hostIsOverriden == true && _testHost != null) {
      return _testHost;
    }

    switch (Application.apiType) {
      case API.test:
        return 'wlb-expertfit-test.3dlook.me';
      case API.stage:
        return 'wlb-xpertfit-stage.3dlook.me';
      case API.release:
        return 'wlb-xpertfit.3dlook.me';
    }
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
  release
}