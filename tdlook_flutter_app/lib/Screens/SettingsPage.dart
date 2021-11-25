import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/UIComponents/Loading.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

class SettingsPage extends StatefulWidget {
  static var route = '/settings_page';

  SettingsPage({Key key}): super(key:key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool _proMode;
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    initSettings();
    //setup values
  }

  void initSettings() async {
    this._prefs = await SharedPreferences.getInstance();
    setState(() {
      _proMode = _prefs.getBool(SessionParameters.keyProMode) ?? false;
    });
  }

  void saveSettings() async {
    _prefs.setBool(SessionParameters.keyProMode, _proMode);
    Application.isProMode = _proMode;
  }

  Future<bool> _onWillPop() async {
    saveSettings();
    Navigator.of(context).pop(true);
    return true;
  }

  // Future<bool> _onWillPop() async {
  //   return (await showDialog(
  //     context: context,
  //     builder: (context) => new AlertDialog(
  //       title: new Text('Are you sure?'),
  //       content: new Text('Do you want to exit an App'),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: new Text('No'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(true),
  //           child: new Text('Yes'),
  //         ),
  //       ],
  //     ),
  //   )) ?? false;
  // }

  @override
  Widget build(BuildContext context) {

    var icon = SizedBox(
      width: 112,
      height: 192,
      child: ResourceImage.imageWithName('ic_sound_on.png'),
    );

    var centerWidget =
    Center(child:SafeArea(child:
    Padding(
      padding: EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon,
          SizedBox(height: 50),
          Text('Please check the sound on your phone.\nTo use voice instructions, it must be turned on.',
              maxLines: 4,
              textAlign:  TextAlign.center,
              style: TextStyle(color: SessionParameters().mainFontColor, fontWeight: FontWeight.normal, fontSize: 14))],
      ),
    )
    ));


    Widget buildOption(String title, String description) {

      Widget switchWidget() {
        if (_proMode != null) {
          return CupertinoSwitch(
              activeColor: HexColor.fromHex('1E7AE4'),
              value: _proMode, onChanged: (bool newValue) {
            setState(() {
              _proMode = newValue;
            });
          });
        } else {
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        }
      }

      var container = Container(
          color: SessionParameters().mainBackgroundColor,
          child: Padding(
          padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: HexColor.fromHex('2D2F32')),
              child: Padding(padding: EdgeInsets.all(20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ), SizedBox(height: 6),Text(
                          description,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis)
                      ]),
                      switchWidget()
                    ]),
              ),
            ),
          ));
      return container;
    }


    var container = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          buildOption('Pro version', 'You can turn instructions on or off')
        ],
    );

    var stack = Stack(
      children: [
        container
      ],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: SessionParameters().mainBackgroundColor,
      body: stack,
    );

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: scaffold,
    );


    return scaffold;
  }




}