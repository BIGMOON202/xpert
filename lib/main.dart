import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/app.dart';
import 'package:tdlook_flutter_app/application/config/app_env.dart';
import 'package:tdlook_flutter_app/common/utils/store_utils.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class NavigationService {
  GlobalKey<NavigatorState>? navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic>? pushNamedAndRemoveUntil(String _rn) {
    return navigationKey?.currentState?.pushNamedAndRemoveUntil(_rn, (route) => false);
  }

  Future<dynamic>? navigateToReplacement(String _rn) {
    return navigationKey?.currentState?.pushReplacementNamed(_rn);
  }

  Future<dynamic>? navigateTo(String _rn) {
    return navigationKey?.currentState?.pushNamed(_rn);
  }

  Future<dynamic>? navigateToRoute(MaterialPageRoute _rn) {
    return navigationKey?.currentState?.push(_rn);
  }

  goback() {
    return navigationKey?.currentState?.pop();
  }
}

void main() async {
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) => {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await AppEnv.load();
  final store = await StoreUtils.fetchStoreApp();

  // Hundle Flutter errors and send to Crashlytics
  /// Handle Flutter errors and send to Crashlytics
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then((val) {
    runZonedGuarded(() {
      runApp(App(store: store));
    }, (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    });
  });
}
