import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/AuthCredentials.dart';
import 'package:tdlook_flutter_app/Screens/TutorialPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enum_to_string/enum_to_string.dart';

class PrivacyPolicyPage extends StatefulWidget {

  final UserType userType;
  final AuthCredentials credentials;
  final bool showApply;

  const PrivacyPolicyPage({Key key, this.credentials, this.userType, this.showApply = true}): super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {

  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  WebView webView;
  WebViewController _controller;
  double contentHeight = 0;

  String get colorStr {
    var color = Colors.black;
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  bool _isLoading = true;

  bool _isApplied = false;
  bool _navigationRequestAllowed = true;
  ScrollController _scrollController;
  String privacyURL;
  bool _scrollButtonIsHidden = false;

  _loadHtmlFromAssets() async {
    var fileText = await rootBundle.loadString('assets/PRIVACY.html');

    privacyURL =  Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString();
    _controller.loadUrl(privacyURL).then((value) => {
        setState(() {
          _isLoading = false;
          print('loaded file');
        // _navigationRequestAllowed = false;
        })
    });
  }

  Future<void>  _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;

    _scrollController = ScrollController();

    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    if (io.Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    webView = WebView(
      initialUrl: Uri.dataFromString(
          '<html><body style="background-color: $colorStr"></body></html>',
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'))
          .toString(),
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
        _loadHtmlFromAssets();
      },
      onPageFinished: (some) async {
        double height = double.parse(
            await _controller.evaluateJavascript(
                "document.documentElement.scrollHeight;"));
        setState(() {
          _isLoading = false;
          contentHeight = height;
          print('height = $contentHeight');
        });
      },
      navigationDelegate: (NavigationRequest request) {

        if (request.url == privacyURL) {
          return NavigationDecision.navigate;
        }
        if (Application.shouldOpenLinks) {
          _launchInBrowser(request.url);
        }
        return NavigationDecision.prevent;
      },
    );
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
        prefs.setBool('agreement', true);

        print('USER= ${EnumToString.convertToString(widget.userType)}');

        if (widget.userType == UserType.salesRep) {
          Navigator.pushNamedAndRemoveUntil(context, '/events_list', (route) => false);

        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/choose_company', (route) => false);
        }
        
        if (prefs.getBool('intro_seen') != true) {
          Navigator.push(context, MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return TutorialPage();
            },
            fullscreenDialog: true,
          ));
        }
      }

      writeToken();
    }
  }

  @override
  Widget build(BuildContext context) {





    var nextButton = Align(
            alignment: Alignment.bottomCenter,
            child:Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
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

    Widget bottomPart() {
      if (widget.showApply == true) {
        return
          VisibilityDetector(
            key: Key('ApplyPrivacy'),
      onVisibilityChanged: (visibilityInfo) {
      var visiblePercentage = visibilityInfo.visibleFraction;
      print('onVisibilityChanged $visiblePercentage');
      setState(() {
        _scrollButtonIsHidden = visiblePercentage > 0;
        print('_scrollButtonIsHidden: $_scrollButtonIsHidden');
      });

      },
      child:
          Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    color: _backgroundColor),
            child: SafeArea(
                child: Container(

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
                                  Flexible(child: Text('I accept Privacy Policy and Terms of Use',
                                    style: TextStyle(color: Colors.white), maxLines: 3))],)),
                          nextButton])))));
      } else {
        return Container();
      }

    }

    void _scrollToBottom() {
      setState(() {
        _scrollButtonIsHidden = true;
      });
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease);
    }

    var scrollToBottomButton = FlatButton(
      child: Container(
        child: SizedBox(
          width: 96,
          height: 34,
          child: Icon(MdiIcons.chevronDown, color: Colors.white),),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(17)),
          border: Border.all(
            color: Colors.white ,
            width: 1.0 ,
          ),
        ),
      ),
        onPressed: _scrollToBottom);
    var container = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          // flex: 8,
          child: Container(
            color: Colors.black,
          child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                    child: Column(children: [Container( height: max(MediaQuery.of(context).size.height, contentHeight),
                    child: webView),
                  bottomPart()])),
        Visibility(visible: _isLoading, child: Container(color: _backgroundColor, child: Center(child: CircularProgressIndicator())))
              ]))),
        Visibility(
        visible: !_scrollButtonIsHidden,
        child: Align(
            alignment: Alignment.bottomCenter,
            child:SafeArea(child:  Padding(
                padding: EdgeInsets.only(bottom: 16, top: 16),
                child: scrollToBottomButton))))
    ]);

    // TODO: implement build
    var scaffold = Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: true,
          title: Row(
            //children align to center.
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Padding(padding: EdgeInsets.only(right: 56), child: Container(child: Text('Privacy Policy and Terms of Use', textAlign: TextAlign.center, maxLines: 3))))
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
