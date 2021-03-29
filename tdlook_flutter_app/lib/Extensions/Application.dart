
class Application {
  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static API get apiType {
    return API.prod;
  }

  static String get hostName {
    switch (Application.apiType) {
      case API.test:
        return 'wlb-expertfit-test.3dlook.me';
      case API.prod:
        return 'wlb-xpertfit.3dlook.me';
    }
  }
}

enum API {
  test,
  prod
}