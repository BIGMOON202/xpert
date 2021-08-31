
class Application {
  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
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
}

const int kDefaultMeasurementsPerPage = 20;

enum API {
  test,
  stage,
  release
}