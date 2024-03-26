import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/app.dart';
import 'package:tdlook_flutter_app/application/config/app_env.dart';
import 'package:tdlook_flutter_app/application/configs/firebase_app.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/common/utils/store_utils.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppEnv.load();
  final store = await StoreUtils.fetchStoreApp();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      logger.e(details.exceptionAsString());
    } else {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
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
      if (kDebugMode) {
        logger.wtf(error.toString(), error, stackTrace);
      } else {
        FirebaseCrashlytics.instance.recordError(error, stackTrace);
      }
    });
  });
}
