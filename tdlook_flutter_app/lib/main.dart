import 'package:enum_to_string/enum_to_string.dart';
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
import 'package:tdlook_flutter_app/Screens/WaitingPage.dart';

class NavigationService{
  GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService(){
    navigationKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> pushNamedAndRemoveUntil(String _rn){
    return navigationKey.currentState.pushNamedAndRemoveUntil(_rn,(route) => false);
  }

  Future<dynamic> navigateToReplacement(String _rn){
    return navigationKey.currentState.pushReplacementNamed(_rn);
  }
  Future<dynamic> navigateTo(String _rn){
    return navigationKey.currentState.pushNamed(_rn);
  }
  Future<dynamic> navigateToRoute(MaterialPageRoute _rn){
    return navigationKey.currentState.push(_rn);
  }

  goback(){
    return navigationKey.currentState.pop();

  }
}

void main() {

    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) => {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then((val) {
  runApp(MaterialApp(
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            brightness: Brightness.light
          ),
          inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
              )
          )),
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
            return MaterialPageRoute(settings: settings, builder: (context) => EventsPage());
          } else if (settings.name == WaitingPage.route) {
            if (settings.arguments is WaitingPageArguments) {
              return MaterialPageRoute(settings: settings, builder: (context) => WaitingPage(arguments: settings.arguments));
            }
          } else if (settings.name == RecommendationsPage.route) {
            if (settings.arguments is RecommendationsPageArguments) {
              return MaterialPageRoute(settings: settings, builder: (context) => RecommendationsPage(arguments: settings.arguments));
            }
          } else if (settings.name == AnalizeErrorPage.route) {
            if (settings.arguments is AnalizeErrorPageArguments) {
              return MaterialPageRoute(settings: settings, builder: (context) => AnalizeErrorPage(arguments: settings.arguments));
            }
          } else if (settings.name == CameraCapturePage.route) {
            if (settings.arguments is CameraCapturePageArguments) {
              return MaterialPageRoute(settings: settings, builder: (context) => CameraCapturePage(arguments: settings.arguments));
            }
          } else if (settings.name == ChooseGenderPage.route) {
            if (settings.arguments is ChooseGenderPageArguments) {
              return MaterialPageRoute(settings: settings, builder: (context) => ChooseGenderPage(argument: settings.arguments));
            }
          } else if (settings.name == BadgePage.route) {
            if (settings.arguments is BadgePageArguments) {
              return MaterialPageRoute(settings: settings, builder: (context) => BadgePage(arguments: settings.arguments));
            }
          } else if (settings.name == ChooseCaptureModePage.route) {
            if (settings.arguments is ChooseCaptureModePageArguments) {
              return MaterialPageRoute(settings: settings, builder: (context) => ChooseCaptureModePage(argument: settings.arguments));
            }
          }
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(settings: settings, builder: (context) => LookApp());
        },
      ));
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

    Future<void> checkToken() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var accessToken = prefs.getString('access');
      _activeUserType = EnumToString.fromString(UserType.values, prefs.getString('userType'));
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
    } else if (_activeUserType == UserType.endWearer){
      return ChooseCompanyPage();
    } else {
      return EventsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.dark
    ));
    return _activeWidget();
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: Theme.of(context).appBarTheme.copyWith(brightness: Brightness.light),
        inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white)
            )
        ),
        accentColor: Colors.black,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        
        primarySwatch: Colors.green,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add_circle),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
