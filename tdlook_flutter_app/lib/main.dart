import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/AnalizeErrorPage.dart';
import 'package:tdlook_flutter_app/Screens/BadgePage.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCompanyPage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseGenderPage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseRolePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Screens/EventsPage.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/Screens/RecommendationsPage.dart';
import 'package:tdlook_flutter_app/Screens/WaistLevelPage.dart';
import 'package:tdlook_flutter_app/Screens/WaitingPage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'constants/language.dart';
import 'generated/l10n.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class NavigationService {
  GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> pushNamedAndRemoveUntil(String _rn) {
    return navigationKey.currentState
        .pushNamedAndRemoveUntil(_rn, (route) => false);
  }

  Future<dynamic> navigateToReplacement(String _rn) {
    return navigationKey.currentState.pushReplacementNamed(_rn);
  }

  Future<dynamic> navigateTo(String _rn) {
    return navigationKey.currentState.pushNamed(_rn);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _rn) {
    return navigationKey.currentState.push(_rn);
  }

  goback() {
    return navigationKey.currentState.pop();
  }
}

void main() async {
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) => {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  // Hundle Flutter errors and send to Crashlytics
  Function originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) async {
    await FirebaseCrashlytics.instance.recordFlutterError(details);
    originalOnError(details);
  };

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then((val) {
    runZonedGuarded(() {
      runApp(
        MaterialApp(
          theme: ThemeData(
              appBarTheme: AppBarTheme(brightness: Brightness.light),
              inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)))),
          navigatorKey: NavigationService.instance.navigationKey,
          debugShowCheckedModeBanner: false,
          // home: LookApp(),
          initialRoute: '/',
          routes: {
            '/': (context) => LookApp(),
            '/events_list': (context) => EventsPage(),
            '/choose_company': (context) => ChooseCompanyPage()
          },
          onGenerateRoute: (settings) {
            print('Need to find ${settings.name}');
            if (settings.name == '/events_list') {
              return MaterialPageRoute(
                  settings: settings, builder: (context) => EventsPage());
            } else if (settings.name == WaitingPage.route) {
              if (settings.arguments is WaitingPageArguments) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        WaitingPage(arguments: settings.arguments));
              }
            } else if (settings.name == RecommendationsPage.route) {
              if (settings.arguments is RecommendationsPageArguments) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        RecommendationsPage(arguments: settings.arguments));
              }
            } else if (settings.name == AnalizeErrorPage.route) {
              if (settings.arguments is AnalizeErrorPageArguments) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        AnalizeErrorPage(arguments: settings.arguments));
              }
            } else if (settings.name == CameraCapturePage.route) {
              if (settings.arguments is CameraCapturePageArguments) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        CameraCapturePage(arguments: settings.arguments));
              }
            } else if (settings.name == ChooseGenderPage.route) {
              if (settings.arguments is ChooseGenderPageArguments) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        ChooseGenderPage(argument: settings.arguments));
              }
            } else if (settings.name == BadgePage.route) {
              if (settings.arguments is BadgePageArguments) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        BadgePage(arguments: settings.arguments));
              }
            } else if (settings.name == ChooseCaptureModePage.route) {
              if (settings.arguments is ChooseCaptureModePageArguments) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        ChooseCaptureModePage(argument: settings.arguments));
              }
            }
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
                settings: settings, builder: (context) => LookApp());
          },
          locale: const Locale(Languages.en),
          localizationsDelegates: [
            S.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,

          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
        ),
      );
    }, (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    });
  });
}

class LookApp extends StatefulWidget {
  @override
  _LookAppState createState() => _LookAppState();
}

class _LookAppState extends State<LookApp> {
  bool _isAuthorized;
  UserType _activeUserType;

  @override
  void initState() {
    // TODO: implement initState
    //
    Future<void> checkToken() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var accessToken = prefs.getString('access');
      _activeUserType =
          EnumToString.fromString(UserType.values, prefs.getString('userType'));
      print('accessToken = $accessToken');
      setState(() {
        _isAuthorized = (accessToken != null);
      });
    }

    checkToken();
  }

  Widget _activeWidget() {
    if (_isAuthorized == null) {
      return Container();
    }

    if (_isAuthorized == false) {
      return ChooseRolePage();
    } else if (_activeUserType == UserType.endWearer) {
      return ChooseCompanyPage();
    } else {
      return EventsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.dark));
    return _activeWidget();
  }
}
