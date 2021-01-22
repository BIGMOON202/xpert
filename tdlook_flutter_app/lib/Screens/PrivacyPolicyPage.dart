import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/AuthCredentials.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enum_to_string/enum_to_string.dart';

class PrivacyPolicyPage extends StatefulWidget {

  final UserType userType;
  final AuthCredentials credentials;

  const PrivacyPolicyPage({Key key, this.credentials, this.userType}): super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {

  static Color _backgroundColor = SharedParameters().mainBackgroundColor;

  WebViewController _controller;


  bool _isApplied = false;

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/PRIVACY.html');
    _controller.loadUrl( Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  @override void initState() {
    // TODO: implement initState
    super.initState();
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  void _moveToNextPage() {
    if (_isApplied == true) {

      print('need to write');
      Future<void> writeToken() async {
        print('start write');
        print(widget.credentials);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('refresh', widget.credentials.refresh); // for string value
        prefs.setString('access', widget.credentials.access); // for string value
        prefs.setString('userType', EnumToString.convertToString(widget.userType));

        print('written');
        Navigator.pushNamedAndRemoveUntil(context, '/events_list', (route) => false);
      }

      writeToken();
    }
  }

  @override
  Widget build(BuildContext context) {

    var webView = WebView(
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
        _loadHtmlFromAssets();
      },
    );

    var nextButton = Align(
            alignment: Alignment.bottomCenter,
            child:Padding(
              padding: EdgeInsets.only(left: 12, right: 12),
              child:Container(
                width: double.infinity,
                child: MaterialButton(

                  onPressed: _isApplied == true ? _moveToNextPage : null,
                  disabledColor: Colors.white.withOpacity(0.5),
                  textColor: Colors.black,
                  child: Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                  color: Colors.white,
                  height: 50,
                  // padding: EdgeInsets.only(left: 12, right: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),

                  ),
                  // padding: EdgeInsets.all(4),
                )),
            ));

    var container = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 8,
          child: Container(
            color: Colors.black,
          child: webView)),
        Expanded(
            flex: 2,
            child: SafeArea(
                child: Container(
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.0),
        topRight: Radius.circular(15.0)),
        color: _backgroundColor),
                    child: Column(
                    children:[
                      Container(
                      child: Row(
                            children:[
                              Theme(
                                  data: ThemeData(unselectedWidgetColor: Colors.white),
                                  child: Checkbox(
                                    onChanged: (newValue) {
                                      setState(() {
                                        _isApplied = newValue;
                                      });
                                    },
                                    activeColor: HexColor.fromHex('1E7AE4'),
                                    checkColor: Colors.white,
                                    hoverColor: Colors.orange,
                                    value: _isApplied,
                                  )),
                              Text('I accept Terms and Conditions and Privacy Policy',
                              style: TextStyle(color: Colors.white),)],)),
                      nextButton])))),
    ]);

    // TODO: implement build
    var scaffold = Scaffold(
        appBar: AppBar(
          title: Text('Privacy policy'),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: Colors.black,
        body: Stack(children: [
          container,
        ])
    );


    return scaffold;
  }
}
