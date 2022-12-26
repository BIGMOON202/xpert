import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tdlook_flutter_app/Screens/AnalizeErrorPage.dart';
import 'package:tdlook_flutter_app/Screens/BadgePage.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCompanyPage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseGenderPage.dart';
import 'package:tdlook_flutter_app/Screens/EventsPage.dart';
import 'package:tdlook_flutter_app/Screens/RecommendationsPage.dart';
import 'package:tdlook_flutter_app/Screens/WaitingPage.dart';
import 'package:tdlook_flutter_app/application/themes/app_themes.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/common/utils/store_utils.dart';
import 'package:tdlook_flutter_app/constants/language.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';
import 'package:tdlook_flutter_app/main.dart';
import 'package:tdlook_flutter_app/presentation/pages/main/look_page.dart';
import 'package:tdlook_flutter_app/presentation/pages/update/update_app_page.dart';

class App extends StatelessWidget {
  final Store store;
  const App({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return MaterialApp(
      theme: AppTheme.current,
      navigatorKey: NavigationService.instance.navigationKey,
      debugShowCheckedModeBanner: false,
      // home: LookApp(),
      initialRoute: '/',
      routes: {
        '/': (context) => store.canUpdate ? UpdateAppPage(storeVersion: store.version) : LookApp(),
        '/events_list': (context) => EventsPage(),
        '/choose_company': (context) => ChooseCompanyPage()
      },
      onGenerateRoute: (settings) {
        logger.d('Need to find ${settings.name}');
        if (settings.name == '/events_list') {
          return MaterialPageRoute(settings: settings, builder: (context) => EventsPage());
        } else if (settings.name == WaitingPage.route) {
          if (settings.arguments is WaitingPageArguments) {
            return MaterialPageRoute(
                settings: settings,
                builder: (context) =>
                    WaitingPage(arguments: settings.arguments as WaitingPageArguments));
          }
        } else if (settings.name == RecommendationsPage.route) {
          if (settings.arguments is RecommendationsPageArguments) {
            return MaterialPageRoute(
                settings: settings,
                builder: (context) => RecommendationsPage(
                    arguments: settings.arguments as RecommendationsPageArguments));
          }
        } else if (settings.name == AnalizeErrorPage.route) {
          if (settings.arguments is AnalizeErrorPageArguments) {
            return MaterialPageRoute(
                settings: settings,
                builder: (context) =>
                    AnalizeErrorPage(arguments: settings.arguments as AnalizeErrorPageArguments));
          }
        } else if (settings.name == CameraCapturePage.route) {
          if (settings.arguments is CameraCapturePageArguments) {
            return MaterialPageRoute(
                settings: settings,
                builder: (context) =>
                    CameraCapturePage(arguments: settings.arguments as CameraCapturePageArguments));
          }
        } else if (settings.name == ChooseGenderPage.route) {
          if (settings.arguments is ChooseGenderPageArguments) {
            return MaterialPageRoute(
                settings: settings,
                builder: (context) =>
                    ChooseGenderPage(argument: settings.arguments as ChooseGenderPageArguments));
          }
        } else if (settings.name == BadgePage.route) {
          if (settings.arguments is BadgePageArguments) {
            return MaterialPageRoute(
                settings: settings,
                builder: (context) =>
                    BadgePage(arguments: settings.arguments as BadgePageArguments));
          }
        } else if (settings.name == ChooseCaptureModePage.route) {
          if (settings.arguments is ChooseCaptureModePageArguments) {
            return MaterialPageRoute(
                settings: settings,
                builder: (context) => ChooseCaptureModePage(
                    argument: settings.arguments as ChooseCaptureModePageArguments));
          }
        }
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(settings: settings, builder: (context) => LookApp());
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
    );
  }
}
