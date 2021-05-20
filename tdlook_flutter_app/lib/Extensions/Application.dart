
class Application {
  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static API get apiType {
    return API.test;
  }

  static String get hostName {
    switch (Application.apiType) {
      case API.test:
        return 'wlb-expertfit-test.3dlook.me';
      case API.prod:
        return 'wlb-xpertfit.3dlook.me';
    }
  }

  static bool get shouldOpenLinks {
    return true;
  }
}

enum API {
  test,
  prod
}