import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/AuthCredentials.dart';
import 'package:tdlook_flutter_app/Screens/TutorialPage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class PrivacyPolicyPage extends StatefulWidget {
  final UserType? userType;
  final AuthCredentials? credentials;
  final bool? showApply;

  const PrivacyPolicyPage({
    Key? key,
    this.credentials,
    this.userType,
    this.showApply = true,
  }) : super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  //final Completer<WebViewController> _controller = Completer<WebViewController>();

  //WebView? webView;
  WebViewPlusController? _controller;
  //double contentHeight = 0;

  String get colorStr {
    var color = Colors.black;
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  bool _isLoading = true;

  bool _isApplied = false;
  late ScrollController _scrollController;
  String? privacyURL;
  bool _scrollButtonIsHidden = false;
  //double _contentHeight = 0;
  late Completer<double> _completer;

  _loadHtmlFromAssets() async {
    var fileText = await rootBundle.loadString('assets/PRIVACY.html');

    privacyURL =
        Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
            .toString();
    _controller?.loadUrl(privacyURL!).then((value) => {
          setState(() {
            _isLoading = false;
            logger.i('loaded file');
          })
        });
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      logger.e('Could not launch $url');
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebViewPlus.platform = AndroidWebView();
    _isLoading = true;
    _completer = Completer<double>();
    _scrollController = ScrollController();
  }

  void _moveToNextPage() {
    if (_isApplied == true) {
      logger.i('need to write');
      Future<void> writeToken() async {
        logger.i('start write');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('refresh', widget.credentials?.refresh ?? ''); // for string value
        prefs.setString('access', widget.credentials?.access ?? ''); // for string value
        prefs.setString('userType', EnumToString.convertToString(widget.userType));
        prefs.setBool('agreement', true);

        logger.d('USER= ${EnumToString.convertToString(widget.userType)}');

        if (widget.userType == UserType.salesRep) {
          Navigator.pushNamedAndRemoveUntil(context, '/events_list', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/choose_company', (route) => false);
        }

        if (prefs.getBool('intro_seen') != true) {
          Navigator.push(
              context,
              MaterialPageRoute<Null>(
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
    _completer = Completer<double>();
    return FutureBuilder(
      future: _completer.future,
      builder: ((context, snapshot) {
        final data = snapshot.data;
        double contentHeight = 0;
        if (data is double) {
          contentHeight = data;
        }
        return _buildScaffold(contentHeight);
      }),
    );
  }

  Widget _buildScaffold(double contentHeight) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: Row(
          //children align to center.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 56),
                child: Container(
                  child: Text(
                    'Privacy Policy and Terms of Use',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ),
              ),
            )
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
      body: Platform.isAndroid ? _buildAndroidContent() : _buildIOSContent(contentHeight),
    );
  }

  Widget _buildIOSContent(double contentHeight) {
    final optimalHeight = max(MediaQuery.of(context).size.height, contentHeight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  controller: _scrollController,
                  child: Column(
                    children: [
                      Container(
                        height: optimalHeight,
                        child: _buildWebView(),
                      ),
                      _buildBottomPart(widget.showApply == true),
                    ],
                  ),
                ),
                Visibility(
                  visible: _isLoading,
                  child: Container(
                    color: _backgroundColor,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              ],
            ),
          ),
        ),
        Visibility(
          visible: !_scrollButtonIsHidden,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16, top: 16),
                child: _buildScrollToBottomButton(),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildAndroidContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            children: [
              _buildWebView(),
              Visibility(
                visible: _isLoading,
                child: Container(
                  color: _backgroundColor,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
        _buildBottomPart(widget.showApply == true),
      ],
    );
  }

  Widget _buildScrollToBottomButton() {
    return FlatButton(
        child: Container(
          child: SizedBox(
            width: 96,
            height: 34,
            child: Icon(MdiIcons.chevronDown, color: Colors.white),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(17)),
            border: Border.all(
              color: Colors.white,
              width: 1.0,
            ),
          ),
        ),
        onPressed: _scrollToBottom);
  }

  Widget _buildBottomPart(bool visible) {
    if (visible) {
      return VisibilityDetector(
        key: Key('ApplyPrivacy'),
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction;
          logger.d('onVisibilityChanged $visiblePercentage');
          if (mounted) {
            setState(() {
              _scrollButtonIsHidden = visiblePercentage > 0;
              logger.d('_scrollButtonIsHidden: $_scrollButtonIsHidden');
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            color: _backgroundColor,
          ),
          child: SafeArea(
            child: Container(
              child: Column(children: [
                Container(
                  child: Row(
                    children: [
                      Theme(
                          data: ThemeData(unselectedWidgetColor: Colors.white),
                          child: Checkbox(
                            onChanged: (newValue) {
                              setState(() {
                                _isApplied = newValue ?? false;
                              });
                            },
                            activeColor: HexColor.fromHex('1E7AE4'),
                            checkColor: Colors.white,
                            hoverColor: Colors.orange,
                            value: _isApplied,
                          )),
                      Flexible(
                        child: Text(
                          'I accept Privacy Policy and Terms of Use',
                          style: TextStyle(color: Colors.white),
                          maxLines: 3,
                        ),
                      )
                    ],
                  ),
                ),
                _buildNextButton()
              ]),
            ),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _buildNextButton() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: Container(
              width: double.infinity,
              child: MaterialButton(
                onPressed: _isApplied == true ? _moveToNextPage : null,
                disabledColor: Colors.white.withOpacity(0.5),
                textColor: Colors.black,
                child: Text(
                  'CONTINUE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                color: Colors.white,
                height: 50,
                // padding: EdgeInsets.only(left: 12, right: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                // padding: EdgeInsets.all(4),
              )),
        ));
  }

  Widget _buildWebView() {
    final initialUrl = Uri.dataFromString(
            '<html><body style="background-color: $colorStr"></body></html>',
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'))
        .toString();

    return WebViewPlus(
      initialUrl: initialUrl,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewPlusController webViewController) async {
        _controller = webViewController;
        _loadHtmlFromAssets();
      },
      onPageFinished: (some) async {
        final result = await _controller?.getHeight();
        if (!_completer.isCompleted) _completer.complete(result ?? 0);
        setState(() {
          _isLoading = false;
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

  void _scrollToBottom() async {
    setState(() {
      _scrollButtonIsHidden = true;
    });
    final result = await _controller?.getHeight();
    final height = (result ?? 0).toInt();
    _controller?.webViewController.scrollTo(0, height);
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
}
