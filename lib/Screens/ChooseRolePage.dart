import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/LoginPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/presentation/pages/welcome/welcome_page.dart';

class ChooseRolePage extends StatefulWidget {
  @override
  _ChooseRolePageState createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  static Color _selectedColor = Colors.white.withOpacity(0.1);
  TextEditingController _textFieldController = TextEditingController();

  UserType? _selectedUserType;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _appVersion = 'App version: ' + packageInfo.version + ' (' + packageInfo.buildNumber + ')';
      });
    });
  }

  void _selectUserType(int atIndex) {
    setState(() {
      _selectedUserType = atIndex == 0 ? UserType.endWearer : UserType.salesRep;
    });
  }

  @override
  Widget build(BuildContext context) {
    var titleText = Padding(
      padding: EdgeInsets.only(top: 30, left: 40, right: 40, bottom: 0),
      child: Text(
        'Before start, select your role',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );

    var buttonsContainer = Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
            child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: AspectRatio(
                  aspectRatio: 1.9,
                  child: Container(
                    // height: 182,
                    color: _backgroundColor,
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: MaterialButton(
                              splashColor: Colors.transparent,
                              elevation: 0,
                              onPressed: () {
                                _selectUserType(0);
                              },
                              color: _selectedUserType == UserType.endWearer
                                  ? _selectedColor
                                  : _backgroundColor,
                              highlightColor: Colors.grey,
                              child: Center(
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(height: 4),
                                    AspectRatio(
                                        aspectRatio: 2.2,
                                        // width: 45,
                                        // height: 61,
                                        child: ResourceImage.imageWithName(
                                            _selectedUserType == UserType.endWearer
                                                ? UserType.endWearer.selectedImageName()
                                                : UserType.endWearer.unselectedImageName())),
                                    SizedBox(height: 10),
                                    Text(
                                      'I\'m the end-wearer',
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Text('Measure yourself',
                                        style: TextStyle(
                                            color: HexColor.fromHex('898A9D'), fontSize: 12),
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: MaterialButton(
                            splashColor: Colors.transparent,
                            elevation: 0,
                            onPressed: () {
                              _selectUserType(1);
                            },
                            color: _selectedUserType == UserType.salesRep
                                ? _selectedColor
                                : _backgroundColor,
                            highlightColor: Colors.grey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 4),
                                AspectRatio(
                                    aspectRatio: 2.2,
                                    // width: 45,
                                    // height:61,
                                    child: ResourceImage.imageWithName(
                                        _selectedUserType == UserType.salesRep
                                            ? UserType.salesRep.selectedImageName()
                                            : UserType.salesRep.unselectedImageName())),
                                SizedBox(height: 10),
                                Text('I\'m the sales rep',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center),
                                SizedBox(height: 4),
                                Text('Measure end-wearers',
                                    style:
                                        TextStyle(color: HexColor.fromHex('898A9D'), fontSize: 12),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))));

    void _moveToNextPage() {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (BuildContext context) => _selectedUserType == UserType.salesRep
              ? LoginPage(userType: _selectedUserType)
              : WelcomePage(
                  userType: UserType.endWearer,
                  appVersion: _appVersion,
                ),
        ),
      );
    }

    String _envEntered = '';
    Future<void> _displayTextInputDialog(BuildContext context) async {
      _textFieldController.value = Application.hostIsCustom
          ? TextEditingValue(text: Application.customHost ?? '')
          : TextEditingValue.empty;
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Switch to enviroment'),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    _envEntered = value;
                  });
                },
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Enter the host name"),
              ),
              actions: <Widget>[
                MaterialButton(
                  splashColor: Colors.transparent,
                  elevation: 0,
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text('RESET'),
                  onPressed: () {
                    Application.updateHost(testHost: null);
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                MaterialButton(
                  splashColor: Colors.transparent,
                  elevation: 0,
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('APPLY'),
                  onPressed: () {
                    // api set env
                    setState(() {
                      Application.updateHost(testHost: _envEntered);
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
    }

    var appVersionWidget = Text(_appVersion,
        style: TextStyle(color: HexColor.fromHex('898A9D'), fontSize: 12),
        textAlign: TextAlign.center);

    var nextButton = Visibility(
        visible: true,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
                child: Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Container(
                  width: double.infinity,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        appVersionWidget,
                        SizedBox(height: 16),
                        MaterialButton(
                          splashColor: Colors.transparent,
                          elevation: 0,
                          textTheme: ButtonTextTheme.accent,
                          onPressed: _selectedUserType != null
                              ? () {
                                  _moveToNextPage();
                                  logger.i('next button pressed');
                                }
                              : null,
                          textColor: Colors.black,
                          disabledColor: Colors.white.withOpacity(0.5),
                          child: Text(
                            'PROCEED',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          color: Colors.white,
                          height: 50,
                          // padding: EdgeInsets.only(left: 12, right: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                      ])),
            ))));

    var bottomPart = new FractionallySizedBox(
        alignment: Alignment.bottomCenter,
        heightFactor: 0.6,
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                color: HexColor.fromHex("#16181B")),
            child: Column(
              children: [titleText, Flexible(child: buttonsContainer)],
            ),
          ),
          nextButton
        ]));

    int tapCounter = 0;
    DateTime? lastTap;

    void _increaseTapsOrReset() {
      void reset() {
        tapCounter = 0;
        logger.i('reset');
      }

      if (lastTap != null) {
        var dif = DateTime.now().difference(lastTap!).inMilliseconds;
        logger.d('dif: ${dif}');
        if (dif > 500 && dif < 2000) {
          tapCounter += 1;
        } else {
          reset();
        }
      } else {
        reset();
      }

      lastTap = DateTime.now();

      if (tapCounter >= 3) {
        tapCounter = 0;
        _displayTextInputDialog(context);
      }
    }

    var versionView = GestureDetector(
      child: SizedBox(
        child: ResourceImage.imageWithName("expertfit_logo.png"),
        width: 171,
        height: 40,
      ),
      onDoubleTap: () {
        _increaseTapsOrReset();
      },
    );

    var topPart = new Container(
        child: SafeArea(
      child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: 1.0,
        child: Column(
          children: [
            versionView,
            Padding(
                padding: EdgeInsets.all(50),
                child: Text(
                  'Take the guesswork out of fitting and do it all in the convenience of your home. ExpertFit virtual sizing '
                  'technology is accurate and fast.',
                  style: TextStyle(color: HexColor.fromHex('898A9D')),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    ));

    var container = Container(
      color: Colors.black,
      child: bottomPart,
    );

    var stack = Stack(
      alignment: Alignment.bottomCenter,
      children: [container, topPart],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: stack,
    );
    return scaffold;
  }
}
